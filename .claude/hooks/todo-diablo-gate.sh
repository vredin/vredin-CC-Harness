#!/bin/bash
# todo-diablo-gate.sh — PreToolUse gate (invoked by dispatch.py, rule R4)
#
# Blocks Edit/Write of docs/TASK.md when adding a NEW T-NNN row whose spec
# does NOT have a valid step_5_diablo frontmatter verdict.
#
# Invocation (from .claude/hooks/dispatch.py):
#   bash todo-diablo-gate.sh <file_path> <new_content>
#     $1 — file_path from tool_input
#     $2 — proposed new content (Edit's new_string OR Write's content)
#
# Behavior:
#   - exit 0 → allow tool call
#   - exit 2 → block tool call, print reason to stderr (Claude reads it)
#
# Defensive: if any check is unclear, allow (exit 0). Hook errs on permissive.

set -uo pipefail

f="${1:-}"
new="${2:-}"

# Only fire on docs/TASK.md
[[ -z "$f" ]] && exit 0
case "$f" in
  *docs/TASK.md|docs/TASK.md) : ;;
  *) exit 0 ;;
esac

# Root from the FILE's location (session cwd may differ when editing another project)
GIT_ROOT=$(git -C "$(dirname "$f")" rev-parse --show-toplevel 2>/dev/null) \
  || GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$GIT_ROOT" || exit 0

# No proposed content → nothing to judge (defensive allow)
[[ -z "$new" ]] && exit 0

# Find T-NNN ids in NEW content
new_ids=$(printf '%s\n' "$new" | grep -oE 'T-[0-9]{3,4}' | sort -u)
[[ -z "$new_ids" ]] && exit 0

# Find T-NNN ids ALREADY in current TASK.md (so we only check newly-added)
current_ids=""
[[ -f docs/TASK.md ]] && current_ids=$(grep -oE 'T-[0-9]{3,4}' docs/TASK.md 2>/dev/null | sort -u)

violations=()

while IFS= read -r tid; do
  [[ -z "$tid" ]] && continue
  # Skip if already in TASK.md (status change, not new add)
  if [[ -n "$current_ids" ]] && printf '%s\n' "$current_ids" | grep -qx "$tid"; then
    continue
  fi

  # New T-NNN — check spec frontmatter. grep's T-[0-9]{3,4} extraction truncates
  # lettered splits (T-567a/T-567b both extract as bare "T-567"), so fall back to
  # a lettered-suffix glob when the bare id has no spec — and validate EVERY
  # matching file (not just the first), since a bare id can expand to multiple
  # split specs that must ALL have a valid verdict.
  specs=$(ls docs/specs/${tid}-*.md 2>/dev/null)
  if [[ -z "$specs" ]]; then
    specs=$(ls docs/specs/${tid}[a-z]-*.md 2>/dev/null)
  fi
  if [[ -z "$specs" ]]; then
    violations+=("$tid: spec file missing in docs/specs/. Run /todo or /quick-plan first.")
    continue
  fi

  while IFS= read -r spec; do
    [[ -z "$spec" ]] && continue
    spec_id=$(basename "$spec" | grep -oE '^T-[0-9]{3,4}[a-z]?')

    # Extract step_5_diablo value from spec YAML frontmatter
    verdict=$(awk '
      /^---[[:space:]]*$/ { fm = !fm; next }
      fm && /^[[:space:]]*step_5_diablo:/ {
        sub(/^[^:]*:[[:space:]]*/, "")
        sub(/[[:space:]]*$/, "")
        gsub(/"/, "")
        print
        exit
      }
    ' "$spec")

    # Prefix match: a trailing note after the verdict is VALID and encouraged
    # (e.g. "ACCEPTABLE (was FIX FIRST, resolved: ...)"). Blocking verdicts are
    # checked first so "FIX_FIRST ..." never sneaks through as a note.
    case "$verdict" in
      BLOCKED*|FIX_FIRST*|"FIX FIRST"*)
        violations+=("$spec_id: Diablo verdict '$verdict' — resolve findings, re-run /da, set 'ACCEPTABLE (was FIX FIRST, resolved: <what>)'. Blocking verdicts never enter the backlog.")
        ;;
      ACCEPTABLE*|PROCEED_CAUTION*|"PROCEED CAUTION"*)
        ;;
      skipped:*)
        # Size-triage skip (SMALL/MEDIUM) or explicit user /skip — spec-Diablo
        # deferred to impl-Diablo (/da impl, auto in /orchestrate STEP 7.5).
        ;;
      "")
        violations+=("$spec_id: spec missing 'step_5_diablo' frontmatter. Set EXACTLY one of: 'skipped:size-triage-SMALL' | 'skipped:size-triage-MEDIUM' (S/M) | 'ACCEPTABLE' | 'PROCEED_CAUTION — <note>' (L, from /da spec $spec_id).")
        ;;
      *)
        violations+=("$spec_id: unknown step_5_diablo value '$verdict'. Use EXACTLY: 'ACCEPTABLE[ (note)]' | 'PROCEED_CAUTION[ — note]' | 'skipped:<reason>'. A resolved FIX FIRST = 'ACCEPTABLE (was FIX FIRST, resolved: <what>)'. Do NOT invent other formats.")
        ;;
    esac
  done <<< "$specs"
done <<< "$new_ids"

if [[ ${#violations[@]} -gt 0 ]]; then
  {
    echo "[BLOCKED by todo-diablo-gate.sh]"
    echo "Cannot add T-NNN to docs/TASK.md without a valid Diablo verdict in spec frontmatter."
    echo
    for v in "${violations[@]}"; do
      echo "  - $v"
    done
    echo
    echo "Fix: complete /todo workflow STEP 5 (run /da spec T-NNN), update spec frontmatter step_5_diablo, then retry."
    echo "Reference: workflow.md § Process Step Discipline + .claude/commands/todo.md STEP 5."
  } >&2
  exit 2
fi

exit 0
