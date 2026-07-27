#!/usr/bin/env bash
# glitchtip.sh — query self-hosted GlitchTip from CLI / claude sessions.
# Used by /fix STEP 1 (check if same error already known) and /general (runtime diagnostics).
#
# Usage:
#   glitchtip.sh recent [<project-slug>] [<days=7>]     # list issues in last N days
#   glitchtip.sh show <issue-id>                         # issue metadata
#   glitchtip.sh stacktrace <issue-id>                   # latest event with full stack
#   glitchtip.sh search <project-slug> <query>           # title search
#   glitchtip.sh stats <project-slug>                    # 24h count + by-level breakdown
#   glitchtip.sh projects                                # list all known projects
#   glitchtip.sh ping                                    # auth + connectivity check
#
# Token resolution order:
#   1. $GLITCHTIP_TOKEN env var (highest priority)
#   2. macOS Keychain: security find-generic-password -s GLITCHTIP_TOKEN -a $USER -w
#   3. Fail with hint
#
# Project slug auto-detect (for `recent` only):
#   1. explicit arg
#   2. docs/STACK.md field: `glitchtip_project_slug: <name>`
#   3. fail with hint to pass explicit slug

set -euo pipefail

GLITCHTIP_URL="${GLITCHTIP_URL:-https://your-glitchtip.example.com}"
ORG_SLUG="${GLITCHTIP_ORG:-your-org}"

# --- token resolution ---
if [ -z "${GLITCHTIP_TOKEN:-}" ]; then
    if command -v security >/dev/null 2>&1; then
        GLITCHTIP_TOKEN=$(security find-generic-password -s GLITCHTIP_TOKEN -a "$USER" -w 2>/dev/null || true)
    fi
fi
if [ -z "${GLITCHTIP_TOKEN:-}" ]; then
    cat >&2 <<EOF
glitchtip.sh: GLITCHTIP_TOKEN not set.
Get token: https://your-glitchtip.example.com/profile/auth-tokens
Save to keychain (macOS):
  security add-generic-password -s GLITCHTIP_TOKEN -a "\$USER" -w '<token>' -U
Or set in env: export GLITCHTIP_TOKEN=...
EOF
    exit 1
fi

AUTH=(-H "Authorization: Bearer $GLITCHTIP_TOKEN")

# --- project slug from STACK.md (used by `recent` and friends if no arg) ---
_detect_project() {
    if [ -f docs/STACK.md ]; then
        local s
        s=$(grep -E '^glitchtip_project_slug:' docs/STACK.md 2>/dev/null | head -1 | sed -E 's/^[^:]+:[[:space:]]*//;s/[[:space:]]*$//' || true)
        if [ -n "$s" ]; then
            echo "$s"
            return 0
        fi
    fi
    return 1
}

_require_jq() {
    if ! command -v jq >/dev/null 2>&1; then
        echo "glitchtip.sh: jq not found. Install: brew install jq" >&2
        exit 1
    fi
}

# --- commands ---
cmd="${1:-}"
case "$cmd" in
    ping)
        _require_jq
        curl -sf "${AUTH[@]}" "$GLITCHTIP_URL/api/0/organizations/$ORG_SLUG/" \
            | jq -r '"OK: org=\(.slug) name=\(.name)"' \
            || { echo "auth or connectivity failed" >&2; exit 1; }
        ;;
    projects)
        _require_jq
        curl -sf "${AUTH[@]}" "$GLITCHTIP_URL/api/0/organizations/$ORG_SLUG/projects/" \
            | jq -r '.[] | "\(.slug)\t\(.name)\t\(.platform // "?")"'
        ;;
    recent)
        _require_jq
        proj="${2:-$(_detect_project || echo '')}"
        if [ -z "$proj" ]; then
            echo "glitchtip.sh recent: project slug required (arg or STACK.md glitchtip_project_slug field)" >&2
            exit 1
        fi
        days="${3:-7}"
        # GlitchTip uses ISO date in `start`/`end` query params via statsPeriod shorthand
        curl -sf "${AUTH[@]}" "$GLITCHTIP_URL/api/0/projects/$ORG_SLUG/$proj/issues/?statsPeriod=${days}d&limit=20" \
            | jq -r '.[] | "id=\(.id) | \(.lastSeen[0:19]) | count=\(.count) | level=\(.level) | \(.title)"' \
            || { echo "API call failed (project=$proj)" >&2; exit 1; }
        ;;
    show)
        _require_jq
        issue_id="${2:?issue id required}"
        curl -sf "${AUTH[@]}" "$GLITCHTIP_URL/api/0/issues/$issue_id/" \
            | jq '{id, shortId, title, culprit, level, status, count, userCount, firstSeen, lastSeen, project: .project.slug, permalink}'
        ;;
    stacktrace)
        _require_jq
        issue_id="${2:?issue id required}"
        curl -sf "${AUTH[@]}" "$GLITCHTIP_URL/api/0/issues/$issue_id/events/latest/" \
            | jq '{id, title: .title, dateCreated, message, exception: (.entries[]? | select(.type=="exception") | .data.values[] | {type, value, stacktrace: (.stacktrace.frames | map({filename, function, lineNo, contextLine}) | .[-10:])})}'
        ;;
    search)
        _require_jq
        proj="${2:?project slug required}"
        query="${3:?search query required}"
        # GlitchTip search via `query` param — searches title/culprit
        curl -sf "${AUTH[@]}" --get --data-urlencode "query=$query" \
            "$GLITCHTIP_URL/api/0/projects/$ORG_SLUG/$proj/issues/?limit=10" \
            | jq -r '.[] | "id=\(.id) | \(.lastSeen[0:19]) | \(.title)"'
        ;;
    stats)
        _require_jq
        proj="${2:?project slug required}"
        # GlitchTip /stats/ endpoint returns time-bucketed counts; we just sum
        curl -sf "${AUTH[@]}" "$GLITCHTIP_URL/api/0/projects/$ORG_SLUG/$proj/stats/?stat=received&since=$(date -v-1d +%s)" 2>/dev/null \
            | jq -r 'add | "events in last 24h: \(. // 0)"' \
            || echo "stats endpoint unavailable or empty"
        ;;
    *)
        head -25 "$0" | grep -E '^#' | sed 's/^# \?//'
        exit 1
        ;;
esac
