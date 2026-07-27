#!/bin/bash
# task-id-validator.sh — PreToolUse gate (invoked by dispatch.py, rule R6)
#
# Blocks `git commit` when message references T-NNN with no matching
# docs/specs/T-NNN-*.md file. Catches the failure mode where Claude
# promotes a floating concept (IDEA-N) to a T-NNN-tagged commit before
# /todo has produced a spec.
#
# Invocation (from .claude/hooks/dispatch.py):
#   bash task-id-validator.sh <bash_command>
#     $1 — the Bash command being run (from tool_input.command)
#
# Behavior:
#   - exit 0 → allow tool call (no T-NNN in commit, or all specs exist)
#   - exit 2 → block tool call, print reason to stderr
#
# Defensive: if any check is unclear, allow (exit 0). Hook errs on permissive.
#
# What it reads:
#   - $1 (the Bash command being run)
#   - docs/specs/*.md filenames (existence check only — never reads contents)
# What it writes:
#   - stderr only when blocking
# Network: none
# Runtime: <50ms (regex + file glob)
# Secrets: none touched

set -uo pipefail

cmd="${1:-}"
[[ -z "$cmd" ]] && exit 0

# Only fire on `git commit` (not checkout, branch, log, etc.)
echo "$cmd" | grep -qE 'git[[:space:]]+commit' || exit 0

GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$GIT_ROOT" || exit 0

# Extract T-NNN references from the command (catches both `-m "..."` and heredoc forms)
ids=$(echo "$cmd" | grep -oE 'T-[0-9]{3,4}' | sort -u)
[[ -z "$ids" ]] && exit 0

missing=()
while IFS= read -r tid; do
  [[ -z "$tid" ]] && continue
  # grep's T-[0-9]{3,4} truncates lettered splits (T-567a -> T-567), so fall
  # back to a lettered-suffix glob before declaring the id missing.
  spec=$(ls "docs/specs/${tid}-"*.md 2>/dev/null | head -1)
  [[ -z "$spec" ]] && spec=$(ls "docs/specs/${tid}"[a-z]-*.md 2>/dev/null | head -1)
  [[ -z "$spec" ]] && missing+=("$tid")
done <<< "$ids"

if [[ ${#missing[@]} -gt 0 ]]; then
  {
    echo "[BLOCKED by task-id-validator.sh]"
    echo "Commit message references T-NNN with no matching spec file:"
    echo
    for m in "${missing[@]}"; do
      echo "  - $m → docs/specs/${m}-*.md does not exist"
    done
    echo
    echo "Reason: T-NNN must reference a registered task with a spec file."
    echo "Floating concepts use IDEA-N (no spec) — see CLAUDE.md § Task ID Discipline."
    echo
    echo "Fix one of:"
    echo "  - If the work IS tracked: verify spec filename matches the T-NNN."
    echo "  - If the work is NOT tracked yet: run /todo add to register, then commit with the assigned T-NNN."
    echo "  - If commit doesn't actually need a T-NNN ref: rewrite message without it."
  } >&2
  exit 2
fi

exit 0
