#!/bin/bash
# test-scope-validator.sh — PreToolUse hook on Bash matcher.
#
# Blocks `pytest`, `npx vitest run`, `npx playwright test`, `npx jest`,
# `npm test` (and variants) when invoked WITHOUT a scope filter AND the
# recent diff touched ≤2 source files. Enforces CLAUDE.md § Targeted
# Test Discipline.
#
# Behavior:
#   - exit 0 → allow (no test command, or scoped, or many files changed)
#   - exit 2 → block, print scope-filter suggestion to stderr
#
# Overrides (one of):
#   - Set env: CLAUDE_HOOK_ALLOW_FULL_TEST_SUITE=1
#   - Add to command: `--all` or `--full` or `--full-suite`
#
# Defensive: any ambiguity → allow. Hook errs on permissive.
#
# What it reads:
#   - $CLAUDE_TOOL_INPUT_COMMAND
#   - git diff --name-only (uncommitted + staged + HEAD~1..HEAD)
# What it writes:
#   - stderr only when blocking
# Network: none
# Runtime: <50ms

set -uo pipefail

cmd="${CLAUDE_TOOL_INPUT_COMMAND:-}"
[[ -z "$cmd" ]] && exit 0

# Override env var
[[ "${CLAUDE_HOOK_ALLOW_FULL_TEST_SUITE:-0}" = "1" ]] && exit 0

# Detect test invocation kind
test_kind=""
if echo "$cmd" | grep -qE '(^|[^a-z])pytest([[:space:]]|$)|(uv run|python -m) pytest'; then
  test_kind="pytest"
elif echo "$cmd" | grep -qE '(npx|pnpm) vitest|(yarn|pnpm|npm) run vitest'; then
  test_kind="vitest"
elif echo "$cmd" | grep -qE '(npx|pnpm) playwright[[:space:]]+test|(yarn|pnpm|npm) run.*playwright'; then
  test_kind="playwright"
elif echo "$cmd" | grep -qE '(npx|pnpm|yarn) jest'; then
  test_kind="jest"
elif echo "$cmd" | grep -qE '(^|[^a-z])(npm|pnpm|yarn|bun)[[:space:]]+(run[[:space:]]+)?test([[:space:]]|$)'; then
  test_kind="npm-test"
fi

[[ -z "$test_kind" ]] && exit 0

# Explicit override flag in command
if echo "$cmd" | grep -qE '(--all|--full|--full-suite)([[:space:]]|$)'; then
  exit 0
fi

# Detect if command already carries a scope filter
has_scope=false
case "$test_kind" in
  pytest)
    # Scope = explicit .py file path OR :: method syntax OR -k filter OR -m mark.
    # Bare directory (tests/, src/) does NOT count — it runs the whole dir.
    if echo "$cmd" | grep -qE 'pytest[[:space:]][^|;&]*\.py([[:space:]]|::|$)'; then has_scope=true; fi
    if echo "$cmd" | grep -qE 'pytest[[:space:]][^|;&]*::'; then has_scope=true; fi
    if echo "$cmd" | grep -qE 'pytest[[:space:]][^|;&]*(-k[[:space:]]+\S|--collect-only|-m[[:space:]]+\S)'; then has_scope=true; fi
    ;;
  vitest)
    # Scope = file path with .test./.spec. OR -t/--filter OR --testNamePattern
    if echo "$cmd" | grep -qE 'vitest[[:space:]]+[^|;&]*(\.test\.|\.spec\.)'; then has_scope=true; fi
    if echo "$cmd" | grep -qE 'vitest[[:space:]]+[^|;&]*(-t[[:space:]]+\S|--filter|--testNamePattern)'; then has_scope=true; fi
    ;;
  playwright)
    # Scope = .spec. file path OR --grep/-g pattern
    if echo "$cmd" | grep -qE 'playwright[[:space:]]+test[[:space:]]+[^|;&]*\.spec\.'; then has_scope=true; fi
    if echo "$cmd" | grep -qE 'playwright[[:space:]]+test[[:space:]]+[^|;&]*(--grep|-g[[:space:]])'; then has_scope=true; fi
    ;;
  jest)
    if echo "$cmd" | grep -qE 'jest[[:space:]]+[^|;&]*(\.test\.|\.spec\.|-t[[:space:]]|--testNamePattern|--testPathPattern)'; then has_scope=true; fi
    ;;
  npm-test)
    # npm test runs whatever package.json says. Cannot reliably check scope here.
    # We treat it as unscoped by default — user must use direct runner or override.
    has_scope=false
    ;;
esac

[[ "$has_scope" = "true" ]] && exit 0

# Determine size of recent change
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$GIT_ROOT" || exit 0

uncommitted=$(git diff --name-only 2>/dev/null || true)
staged=$(git diff --name-only --cached 2>/dev/null || true)
last_commit=$(git diff --name-only HEAD~1 HEAD 2>/dev/null || true)

# If there are uncommitted/staged changes, prefer those (current work). Else use last commit.
if [[ -n "$uncommitted" || -n "$staged" ]]; then
  recent_files=$(printf '%s\n%s\n' "$uncommitted" "$staged" | sort -u | grep -v '^$' || true)
else
  recent_files=$(echo "$last_commit" | grep -v '^$' || true)
fi

# Empty diff = no idea what's being tested, be permissive (allow)
[[ -z "$recent_files" ]] && exit 0

# Filter to source files only: exclude tests, docs, configs, hidden dirs.
# Note: tests/ excluded because a test-file edit alone doesn't justify running ALL tests —
# the agent should still scope to the specific changed test file.
# Patterns use `(^|/)` to match path segment anywhere, not just at filename start
# (catches frontend/tests/..., backend/tests/..., etc.).
src_files=$(echo "$recent_files" | grep -vE '(^|/)tests?/|(^|/)docs/|\.md$|\.txt$|\.json$|\.yaml$|\.yml$|\.toml$|\.lock$|(^|/)\.claude/|(^|/)\.github/|(^|/)\.vscode/|(^|/)\.idea/|(^|/)README|(^|/)CHANGELOG' || true)
src_count=$(echo "$src_files" | grep -c . 2>/dev/null || true)
src_count=${src_count:-0}

# Allow if zero source-file changes (probably running tests after config/docs change).
# The agent is doing diagnostic work, not validating a fix — full suite is fine.
[[ "$src_count" -eq 0 ]] && exit 0

# Otherwise: ANY source change requires explicit test scope. There is no "diff too big to scope"
# escape — large refactors should be tested by module/dir, not by running all 445 specs.
# If the agent genuinely wants the full suite (e.g. pre-deploy sanity check), use:
#   - CLAUDE_HOOK_ALLOW_FULL_TEST_SUITE=1 prefix
#   - or --all / --full / --full-suite flag in the command
# Per CLAUDE.md § Targeted Test Discipline.

# Derive scope hint from diff: unique top-2-level directories of changed source files.
# Helps the agent pick a specific spec file/directory without re-grep-ing the diff.
scope_hint=$(echo "$src_files" | awk -F/ 'NF>=2 {print $1"/"$2}' | sort -u | head -5)

# Block: source diff present + unscoped test command (any count, no threshold)
{
  echo "[BLOCKED by test-scope-validator.sh]"
  echo "Test command without scope filter. Recent diff touched ${src_count} source file(s):"
  echo "$src_files" | head -10 | sed 's/^/  - /'
  if [[ "$src_count" -gt 10 ]]; then
    echo "  ... and $((src_count - 10)) more"
  fi
  echo
  echo "Changed directories (use as scope hint):"
  echo "$scope_hint" | sed 's/^/  - /'
  echo
  echo "CLAUDE.md § Targeted Test Discipline — run ONLY tests directly related."
  echo "There is no diff-size threshold that justifies running the FULL suite — large"
  echo "refactors should be tested by module/dir, not by running every spec."
  echo
  case "$test_kind" in
    pytest)
      echo "Examples:"
      echo "  uv run pytest tests/test_<area>.py -v"
      echo "  uv run pytest -k '<keyword>' -v"
      echo "  uv run pytest tests/test_X.py::TestClass::test_method"
      ;;
    vitest)
      echo "Examples:"
      echo "  npx vitest run src/<area>.test.ts"
      echo "  npx vitest run -t '<test name pattern>'"
      ;;
    playwright)
      echo "Examples:"
      echo "  npx playwright test tests/e2e/<feature>.spec.ts"
      echo "  npx playwright test --grep '<pattern>'"
      ;;
    jest)
      echo "Examples:"
      echo "  npx jest <test file>"
      echo "  npx jest -t '<pattern>'"
      ;;
    npm-test)
      echo "'npm test' runs whatever package.json defines — usually the full suite."
      echo "Recommended: invoke the underlying runner directly with scope."
      echo "If 'npm test' is required (e.g. CI parity) — use override below."
      ;;
  esac
  echo
  echo "Override (if intentional full suite):"
  echo "  CLAUDE_HOOK_ALLOW_FULL_TEST_SUITE=1 ${cmd}"
  echo "or add '--all' / '--full' to the command."
} >&2
exit 2
