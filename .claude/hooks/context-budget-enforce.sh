#!/usr/bin/env bash
# Stop hook — context budget enforcement (WARN by default, hard block opt-in).
#
# Fires at every Claude stop attempt. When context fill exceeds the threshold
# AND docs/handoff.md is stale, emits the handoff instruction to stderr.
#
# Default mode (soft): message is a WARNING — exit 0, stop is allowed.
# Hard mode (CTX_BUDGET_HARD=1): exit 2 forces Claude to continue and write
# the handoff before actually stopping (old behavior).
#
# Exit 0 = allow stop (under threshold OR fresh handoff OR soft mode warning).
# Exit 2 = force continue (hard mode only) with stderr message as instruction.
# Any error inside the hook → exit 0 (never block Claude due to hook bugs).

set -uo pipefail

# Never block on missing git — templates can be non-repo.
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -d "$GIT_ROOT/.git" ] || exit 0

HANDOFF_FILE="$GIT_ROOT/docs/handoff.md"

# --- PRIMARY signal: real context % from the session transcript ---------------
# Stop hooks DO NOT receive model / context_window / rate_limits on stdin (those
# are statusLine-only — confirmed against Claude Code docs, v2.1.153+). The Stop
# hook payload DOES carry `transcript_path`. We parse the transcript's last usage
# record to compute the REAL context fill, model-independently. This replaces the
# old commit/line proxies (which falsely tripped at low real context — e.g. many
# bookkeeping [BACKUP] commits at 27% real usage). Proxies are now FALLBACK only.
#
# Config:
#   CTX_BUDGET_PCT             block when real context fill exceeds this % (default 75)
#   CTX_BUDGET_WINDOW_TOKENS   context window size; 200000 default, set 1000000 for 1M models
#   CTX_BUDGET_HARD            1 = block (exit 2) when over; default 0 = warn only (exit 0)
CTX_PCT_LIMIT=${CTX_BUDGET_PCT:-75}
CTX_WINDOW=${CTX_BUDGET_WINDOW_TOKENS:-200000}
CTX_HARD=${CTX_BUDGET_HARD:-0}

# Capture stdin once (Stop hook JSON payload). Never fail the hook on read error.
STDIN_JSON=$(cat 2>/dev/null || echo '')

# Used tokens = last transcript usage (input + cache_read + cache_creation).
# 0 means "could not determine" → we fall back to the commit/line proxies below.
USED_TOKENS=$(printf '%s' "$STDIN_JSON" | python3 -c '
import json,sys
try:
    d=json.load(sys.stdin)
except Exception:
    print(0); sys.exit(0)
tp=d.get("transcript_path") or ""
used=0
try:
    with open(tp) as f:
        for line in f:
            line=line.strip()
            if not line: continue
            try: o=json.loads(line)
            except Exception: continue
            u=(o.get("message") or {}).get("usage") or o.get("usage")
            if isinstance(u,dict):
                t=(u.get("input_tokens") or 0)+(u.get("cache_read_input_tokens") or 0)+(u.get("cache_creation_input_tokens") or 0)
                if t: used=t   # keep the LAST non-zero usage = current context size
except Exception:
    pass
print(used)
' 2>/dev/null || echo 0)
USED_TOKENS=${USED_TOKENS:-0}

# Auto-correct the window for 1M-context models. A session can never load more
# tokens than its real window, so USED > CTX_WINDOW proves the window is larger
# than the 200k assumption → promote to the 1M tier. Makes the % accurate without
# per-user config (the common case: Opus/Sonnet on a 1M-context plan reporting
# e.g. 302k tokens, which is ~30% of 1M, not 151% of 200k).
if [ "${USED_TOKENS:-0}" -gt "${CTX_WINDOW:-0}" ]; then
  CTX_WINDOW=1000000
fi

CTX_PCT=0
[ "${CTX_WINDOW:-0}" -gt 0 ] && [ "${USED_TOKENS:-0}" -gt 0 ] && CTX_PCT=$(( USED_TOKENS * 100 / CTX_WINDOW ))

# --- FALLBACK signal: commit/line proxies (only used when transcript unreadable)
MAX_COMMITS=${CTX_BUDGET_MAX_COMMITS:-10}
MAX_LINES=${CTX_BUDGET_MAX_LINES:-800}

# --- Find the comparison base: last [HANDOFF] commit, else 4h window fallback ---
LAST_HANDOFF_HASH=$(git -C "$GIT_ROOT" log --grep='^\[HANDOFF\]' -1 --format='%H' 2>/dev/null || true)

COMMITS=0
LINES=0

# Sum insertions+deletions across a set of commits given by `git log` format filter.
# Per-commit --shortstat aggregation avoids the initial-commit parent lookup bug.
# LC_ALL=C forces C locale so "insertion"/"deletion" words match across systems
# (DA-002: Ukrainian/other locales emit translated strings that would silently
# zero out line counts).
_sum_lines_from_log() {
  LC_ALL=C git -C "$GIT_ROOT" log --shortstat --format='' "$@" 2>/dev/null \
    | awk '/insertion|deletion/ {
        for (i=1;i<=NF;i++) {
          if ($i ~ /^[0-9]+$/ && ($(i+1) ~ /insertion/ || $(i+1) ~ /deletion/)) s+=$i
        }
      } END { print s+0 }'
}

# Commit count excludes bookkeeping commits ([BACKUP]/[HANDOFF]/[META]) — they
# represent no context-filling work and previously inflated the proxy (e.g. an
# empty [BACKUP] before every edit). Only substantive commits count.
if [ -n "${LAST_HANDOFF_HASH:-}" ]; then
  COMMITS=$(git -C "$GIT_ROOT" log --oneline "${LAST_HANDOFF_HASH}..HEAD" 2>/dev/null | grep -vE '\[(BACKUP|HANDOFF|META)\]' | wc -l | tr -d ' ')
  LINES=$(_sum_lines_from_log "${LAST_HANDOFF_HASH}..HEAD")
  BASE_LABEL="last [HANDOFF] commit ${LAST_HANDOFF_HASH:0:7}"
else
  COMMITS=$(git -C "$GIT_ROOT" log --since='4 hours ago' --oneline 2>/dev/null | grep -vE '\[(BACKUP|HANDOFF|META)\]' | wc -l | tr -d ' ')
  LINES=$(_sum_lines_from_log --since='4 hours ago')
  BASE_LABEL='4h window (no [HANDOFF] commit found)'
fi
COMMITS=${COMMITS:-0}

LINES=${LINES:-0}

# --- Handoff freshness check ---
# Fresh if ANY of:
#   (1) last commit subject starts with [HANDOFF] (user just committed handoff;
#       self-staleness race from committing handoff immunises here — DA-003)
#   (2) handoff.md exists AND contains the required section headers AND
#       mtime >= last non-HANDOFF work commit time (DA-005 content-check
#       closes the "touch empty file" escape hatch)
# On any parse error → unknown → default to NO (block-biased for known file
# presence, allow-biased for unknown-mtime — see DA-007 below).
HANDOFF_FRESH='no'

LAST_SUBJECT=$(git -C "$GIT_ROOT" log -1 --format='%s' 2>/dev/null || echo '')
if printf '%s' "$LAST_SUBJECT" | grep -q '^\[HANDOFF\]'; then
  HANDOFF_FRESH='yes'
elif [ -f "$HANDOFF_FILE" ]; then
  # Content check: handoff.md must mention at least 3 of the 5 required sections
  REQUIRED_HEADERS=(
    'Completed This Session'
    'In Progress'
    'Next Session Should'
    'Context That Would Be Lost'
    'Unanswered Question'
  )
  HEADER_HITS=0
  for h in "${REQUIRED_HEADERS[@]}"; do
    if grep -q -- "$h" "$HANDOFF_FILE" 2>/dev/null; then
      HEADER_HITS=$((HEADER_HITS + 1))
    fi
  done

  if [ "$HEADER_HITS" -ge 3 ]; then
    # Compare handoff mtime to last non-[HANDOFF] work commit time. If no
    # such commit exists (only [HANDOFF] commits in history), fresh by default.
    # DA-009: avoid `--invert-grep` (git >= 2.4) so hook degrades gracefully on
    # older git installs. Portable approach: list hash + subject, filter out
    # [HANDOFF] with plain grep, take first. LC_ALL=C protects the filter from
    # any locale-specific git log reformatting.
    LAST_WORK_HASH=$(LC_ALL=C git -C "$GIT_ROOT" log --format='%H %s' -n 100 2>/dev/null \
      | grep -v ' \[HANDOFF\]' \
      | head -1 \
      | awk '{print $1}' \
      || echo '')
    if [ -z "${LAST_WORK_HASH:-}" ]; then
      HANDOFF_FRESH='yes'
    else
      # Portable stat: BSD (-f %m) first, GNU (-c %Y) fallback.
      # DA-007: on exotic platforms where neither works, leave HANDOFF_MTIME
      # empty and bias toward allow-stop (set fresh=yes). Hook bugs must never
      # block — per the "never block Claude due to hook bugs" principle.
      HANDOFF_MTIME=$(stat -f %m "$HANDOFF_FILE" 2>/dev/null || stat -c %Y "$HANDOFF_FILE" 2>/dev/null || echo '')
      LAST_WORK_TIME=$(git -C "$GIT_ROOT" log -1 --format='%ct' "$LAST_WORK_HASH" 2>/dev/null || echo '')
      if [ -z "${HANDOFF_MTIME:-}" ] || [ -z "${LAST_WORK_TIME:-}" ]; then
        HANDOFF_FRESH='yes'   # unknown → allow (hook-bug safety)
      elif [ "$HANDOFF_MTIME" -ge "$LAST_WORK_TIME" ]; then
        HANDOFF_FRESH='yes'
      fi
    fi
  fi
fi

# --- Decision ---
# Primary: real context %. Fallback: commit/line proxies (only when transcript
# usage was unreadable, i.e. USED_TOKENS==0). The model is irrelevant here — we
# measure actual fill, not a per-model proxy.
OVER='no'
if [ "${USED_TOKENS:-0}" -gt 0 ]; then
  [ "${CTX_PCT:-0}" -gt "$CTX_PCT_LIMIT" ] && OVER='yes'
  SIGNAL="real context ${CTX_PCT}% (${USED_TOKENS}/${CTX_WINDOW} tokens, limit ${CTX_PCT_LIMIT}%)"
else
  { [ "${COMMITS:-0}" -gt "$MAX_COMMITS" ] || [ "${LINES:-0}" -gt "$MAX_LINES" ]; } && OVER='yes'
  SIGNAL="proxies (transcript unreadable): commits=$COMMITS/$MAX_COMMITS, lines=$LINES/$MAX_LINES since $BASE_LABEL"
fi

# --- Circuit breaker (DA-004) ---
# If this hook has already blocked N times in the last WINDOW seconds, give up
# and allow stop — prevents infinite stop-continue loops if Claude's reaction
# doesn't satisfy the freshness check (e.g. reads files first, never writes
# handoff). State lives in a single tmp file with monotonic append of timestamps.
TRIP_FILE="${GIT_ROOT}/.claude/session-log/context-budget-trips.log"
TRIP_WINDOW=${CTX_BUDGET_TRIP_WINDOW:-300}   # 5 minutes
TRIP_MAX=${CTX_BUDGET_TRIP_MAX:-3}
mkdir -p "$(dirname "$TRIP_FILE")" 2>/dev/null || true
NOW=$(date +%s 2>/dev/null || echo 0)

# Count existing trip timestamps within window and prune stale ones.
RECENT_TRIPS=0
if [ -f "$TRIP_FILE" ] && [ "${NOW:-0}" -gt 0 ]; then
  PRUNED=$(awk -v cutoff=$((NOW - TRIP_WINDOW)) '$1 >= cutoff { print $1 }' "$TRIP_FILE" 2>/dev/null || echo '')
  printf '%s\n' "$PRUNED" | grep -v '^$' > "$TRIP_FILE.tmp" 2>/dev/null && mv "$TRIP_FILE.tmp" "$TRIP_FILE" 2>/dev/null || true
  RECENT_TRIPS=$(wc -l < "$TRIP_FILE" 2>/dev/null | tr -d ' ' || echo 0)
fi

if [ "$CTX_HARD" = '1' ] && [ "$OVER" = 'yes' ] && [ "$HANDOFF_FRESH" = 'no' ] && [ "${RECENT_TRIPS:-0}" -ge "$TRIP_MAX" ]; then
  cat >&2 <<EOF
[CONTEXT BUDGET — CIRCUIT BREAKER TRIPPED] Hook would block for the $((RECENT_TRIPS + 1))th time in ${TRIP_WINDOW}s, giving up to avoid infinite loop.

Signal: $SIGNAL | handoff_fresh=$HANDOFF_FRESH

You are allowed to stop, BUT the context budget is still over threshold. Before the next message please:
1. Write docs/handoff.md properly
2. Commit as [HANDOFF]
3. /compact

Reset circuit breaker: rm $TRIP_FILE
EOF
  exit 0
fi

if [ "$OVER" = 'yes' ] && [ "$HANDOFF_FRESH" = 'no' ]; then
  if [ "$CTX_HARD" = '1' ]; then
    MODE_LABEL='HARD BLOCK'
  else
    MODE_LABEL='WARNING'
  fi
  # Record block attempts for circuit breaker (hard mode only — soft mode never loops)
  [ "$CTX_HARD" = '1' ] && [ "${NOW:-0}" -gt 0 ] && printf '%s\n' "$NOW" >> "$TRIP_FILE" 2>/dev/null || true
  # Emit instruction; hard mode forces Claude to continue with handoff-writing task
  cat >&2 <<EOF
[CONTEXT BUDGET — $MODE_LABEL] Over threshold AND docs/handoff.md is stale/missing.

Signal: $SIGNAL
  handoff fresh: $HANDOFF_FRESH

Do this NOW before you can stop:
1. Write docs/handoff.md — follow template in .claude/rules/workflow.md § Session End — Handoff Protocol. Required sections:
   - Completed This Session
   - In Progress (not finished)
   - Next Session Should (concrete first 3 actions)
   - Context That Would Be Lost
   - User's Last Unanswered Question (CRITICAL)
2. git add docs/handoff.md
3. git commit -m "[HANDOFF] <one-line summary>"
4. Run /compact
5. Only then is it safe to stop

Override for genuine false positives:
  - CTX_BUDGET_PCT=85            raise the real-context block threshold (default 75)
  - CTX_BUDGET_WINDOW_TOKENS=1000000   for 1M-context models (default 200000)
  - CTX_BUDGET_MAX_COMMITS / CTX_BUDGET_MAX_LINES   fallback-proxy limits (used only if transcript unreadable)
  - CTX_BUDGET_HARD=1            enforce as a blocking gate (default: warning only)
  - or temporarily disable this hook in .claude/settings.json.
EOF
  [ "$CTX_HARD" = '1' ] && exit 2
  exit 0
fi

exit 0
