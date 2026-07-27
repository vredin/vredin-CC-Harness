#!/usr/bin/env bash
# credential-halt.sh — /orchestrate STEP 0 prerequisite check
# Per SELF-AUDIT-2026-05-29 ITEM 2 (3rd Diablo pass: PROCEED CAUTION + S4 surgery).
#
# Purpose: scan docs/specs/T-NNN-*.md for external service mentions, derive required
# env vars via docs/rules-references/service-secrets.md lookup, halt if any are
# missing from .env / .env.production / .env.example.
#
# Invocation: bash .claude/hooks/credential-halt.sh
# Exit codes: 0 = all secrets present (or soft-warn mode), 1 = hard halt
#
# Modes:
#   - greenfield (< 5 specs): soft-warn only
#   - mature (≥ 5 specs in docs/specs/): hard halt on missing required var
#
# Override: CLAUDE_HOOK_ALLOW_MISSING_SECRETS=1 to bypass during emergencies

set -uo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "credential-halt: not a git repo, skipping"; exit 0; }
cd "$GIT_ROOT" || exit 0

if [ "${CLAUDE_HOOK_ALLOW_MISSING_SECRETS:-0}" = "1" ]; then
  echo "credential-halt: CLAUDE_HOOK_ALLOW_MISSING_SECRETS=1 set, bypassing"
  exit 0
fi

LOOKUP="docs/rules-references/service-secrets.md"
SPECS_DIR="docs/specs"
ENV_FILES=(.env .env.production .env.example)

if [ ! -d "$SPECS_DIR" ]; then
  echo "credential-halt: no docs/specs/ — greenfield, skipping"
  exit 0
fi

spec_count=$(ls "$SPECS_DIR"/T-*.md 2>/dev/null | wc -l | tr -d ' ')
[ "$spec_count" = "0" ] && { echo "credential-halt: zero specs, skipping"; exit 0; }

MODE="soft"
[ "$spec_count" -ge 5 ] && MODE="hard"

if [ ! -f "$LOOKUP" ]; then
  echo "credential-halt: $LOOKUP missing, cannot enforce"
  exit 0
fi

# Aggregate spec text (Technical Notes + Description sections)
SPEC_TEXT=$(cat "$SPECS_DIR"/T-*.md 2>/dev/null | tr '[:upper:]' '[:lower:]')

# Drift check: env_var values in lookup MUST exist in .env.example (S4 surgery)
if [ -f ".env.example" ]; then
  drift_errors=0
  while IFS= read -r line; do
    var=$(echo "$line" | sed -E 's/^[[:space:]]*env_var:[[:space:]]*//;s/,.*//')
    [ -z "$var" ] || [ "$var" = "NONE" ] && continue
    if ! grep -qE "^${var}=" .env.example; then
      echo "DRIFT: $LOOKUP lists $var but .env.example has no key for it"
      drift_errors=$((drift_errors+1))
    fi
  done < <(grep -E '^[[:space:]]*env_var:' "$LOOKUP")
  if [ "$drift_errors" -gt 0 ]; then
    echo ""
    echo "service-secrets.md is out of sync with .env.example ($drift_errors mismatches)"
    echo "Fix .env.example OR remove stale entries from service-secrets.md before re-running /orchestrate"
    [ "$MODE" = "hard" ] && exit 1
  fi
fi

# Parse lookup: emit "alias|env_var|acquire_from" tuples
parse_lookup() {
  python3 - "$LOOKUP" <<'PY'
import sys, re
text = open(sys.argv[1]).read()
entries = re.findall(
    r'- service:\s*(\S+)\s*\n\s*aliases:\s*\[([^\]]+)\]\s*\n\s*env_var:\s*(\S+)\s*\n\s*acquire_from:\s*(\S[^\n]*)',
    text
)
for service, aliases, env_var, acquire in entries:
    alias_list = [a.strip().lower() for a in aliases.split(',')]
    alias_list.append(service.lower())
    for alias in set(alias_list):
        print(f"{alias}|{env_var}|{acquire.strip()}")
PY
}

LOOKUP_DATA=$(parse_lookup)
[ -z "$LOOKUP_DATA" ] && { echo "credential-halt: lookup parse returned empty"; exit 0; }

# For each lookup alias, check if it appears in any spec
missing_count=0
warn_count=0
declare -A SEEN_VARS

while IFS='|' read -r alias env_var acquire; do
  [ -z "$alias" ] && continue
  [ "$env_var" = "NONE" ] && continue

  # Skip if we already reported this env_var
  [ -n "${SEEN_VARS[$env_var]:-}" ] && continue

  # Spec mentions the service (case-insensitive, Unicode handled by tr above)?
  if echo "$SPEC_TEXT" | grep -qF "$alias"; then
    SEEN_VARS["$env_var"]=1

    # Check env files for non-empty value (split comma-separated env_var lists)
    found_anywhere=0
    IFS=',' read -ra VARS <<< "$env_var"
    for v in "${VARS[@]}"; do
      for ef in "${ENV_FILES[@]}"; do
        [ -f "$ef" ] || continue
        if grep -qE "^${v}=.+" "$ef" 2>/dev/null && ! grep -qE "^${v}=[[:space:]]*$" "$ef" 2>/dev/null; then
          found_anywhere=1
          break 2
        fi
      done
    done

    if [ "$found_anywhere" = "0" ]; then
      echo ""
      echo "MISSING: $env_var (service: $alias)"
      echo "  Acquire from: $acquire"
      echo "  Add to .env.production then re-run /orchestrate"
      missing_count=$((missing_count+1))
    fi
  fi
done <<< "$LOOKUP_DATA"

# Soft-warn for unknown services mentioned in specs (not in lookup at all)
# (skipping this in v1 for performance — extend later if false-negatives appear)

echo ""
echo "credential-halt: mode=$MODE, specs=$spec_count, missing=$missing_count"

if [ "$missing_count" -gt 0 ]; then
  if [ "$MODE" = "hard" ]; then
    echo "HARD STOP: $missing_count required secret(s) missing. /orchestrate cannot proceed."
    echo "Override: CLAUDE_HOOK_ALLOW_MISSING_SECRETS=1 (use only if you accept the failure mode)"
    exit 1
  else
    echo "SOFT WARN (greenfield, $spec_count < 5 specs): proceeding, but expect failures during implementation"
    exit 0
  fi
fi

echo "All required secrets present"
exit 0
