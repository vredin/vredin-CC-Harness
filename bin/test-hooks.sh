#!/usr/bin/env bash
# test-hooks.sh — hermetic test stand for .claude/hooks/dispatch.py
#
# Creates a throwaway git repo in mktemp -d, controls the last commit,
# feeds dispatch.py stdin-JSON fixtures, asserts exit codes.
#
# What it reads:  .claude/hooks/dispatch.py (+ its delegated scripts)
# What it writes: temp dir only (removed on exit); PASS/SKIP/FAIL to stdout
# Network: none. Runtime: seconds. Secrets: none (R10 fixture uses a fake
#          token assembled at runtime — never a scannable literal).
#
# R10 (gitleaks) cases run only when the gitleaks binary is installed;
# otherwise they are reported as SKIP.
#
# Exit: 0 if all cases pass (SKIPs allowed), 1 if any FAIL.

set -u

TEMPLATE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DISPATCH="$TEMPLATE_ROOT/.claude/hooks/dispatch.py"

if [ ! -f "$DISPATCH" ]; then
  echo "FATAL: dispatch.py not found at $DISPATCH" >&2
  exit 1
fi

TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

REPO="$TMP/repo"
OUTSIDE="$TMP/outside"
mkdir -p "$REPO" "$OUTSIDE"
touch "$OUTSIDE/note.txt"

git -C "$REPO" init -q
git_commit() { git -C "$REPO" -c user.email=t@t.t -c user.name=t commit --allow-empty -qm "$1"; }
git_commit "[BACKUP] test stand init"
echo "x = 1" > "$REPO/module.py"

PASS=0
SKIP=0
FAIL=0

# json builders (paths embedded safely via python json.dumps)
bash_json() {  # $1=command
  python3 -c 'import json,sys; print(json.dumps({"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":sys.argv[1]},"cwd":sys.argv[2],"session_id":"test-hooks","transcript_path":""}))' "$1" "$REPO"
}
file_json() {  # $1=file_path [$2=tool_name] [$3=new_string]
  python3 -c 'import json,sys; print(json.dumps({"hook_event_name":"PreToolUse","tool_name":sys.argv[2],"tool_input":{"file_path":sys.argv[1],"old_string":"x = 1","new_string":sys.argv[3]},"cwd":sys.argv[4],"session_id":"test-hooks","transcript_path":""}))' "$1" "${2:-Edit}" "${3:-x = 2}" "$REPO"
}

run_case() {  # $1=name $2=expected_exit $3=stdin [env pairs...]
  local name="$1" expected="$2" stdin="$3"
  shift 3
  printf '%s' "$stdin" | env CLAUDE_PROJECT_DIR="$REPO" "$@" python3 "$DISPATCH" PreToolUse >/dev/null 2>"$TMP/stderr.txt"
  local rc=$?
  if [ "$rc" -eq "$expected" ]; then
    echo "PASS: $name"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $name (expected exit $expected, got $rc)"
    sed 's/^/       stderr: /' "$TMP/stderr.txt" | head -5
    FAIL=$((FAIL + 1))
  fi
}

echo "=== dispatch.py hook tests (repo: $REPO) ==="

# --- Bash rules ------------------------------------------------------------

run_case "R5 commit without prefix blocked"        2 "$(bash_json 'git commit -m "did some stuff"')"
run_case "R5 commit [CHANGE] allowed"              0 "$(bash_json 'git commit -m "[CHANGE] x"')"
run_case "R5 commit single-quoted no prefix"       2 "$(bash_json "git commit -m 'oops no prefix'")"
run_case "R5 commit --message= no prefix"          2 "$(bash_json 'git commit --message="plain msg"')"
run_case "R6 [CHANGE] T-999 without spec blocked"  2 "$(bash_json 'git commit -m "[CHANGE] T-999: x"')"
run_case "R7 rm -rf blocked"                       2 "$(bash_json 'rm -rf /tmp/whatever')"
run_case "R7 git add -A blocked"                   2 "$(bash_json 'git add -A && git status')"
run_case "R7 git add -A bypass env"                0 "$(bash_json 'git add -A && git status')" CLAUDE_ALLOW_BROAD_ADD=1
run_case "R7 git add . blocked"                    2 "$(bash_json 'git add .')"
run_case "R7 git add specific file allowed"        0 "$(bash_json 'git add src/app.py')"
run_case "R7 git reset --hard blocked"             2 "$(bash_json 'git reset --hard HEAD~1')"
run_case "R8 DROP TABLE blocked"                   2 "$(bash_json 'psql -c "DROP TABLE users;"')"
run_case "R8 DELETE with WHERE allowed"            0 "$(bash_json 'psql -c "DELETE FROM users WHERE id = 1;"')"
run_case "R8 DELETE without WHERE blocked"         2 "$(bash_json 'psql -c "DELETE FROM users;"')"
run_case "R11 integ tests on prod DB blocked"      2 "$(bash_json 'DB_MIGRATE_URL=postgresql://u@h/app_db pytest tests/integration/ -q')"
run_case "R11 integ tests on test DB allowed"      0 "$(bash_json 'DB_MIGRATE_URL=postgresql://u@h/app_test pytest tests/integration/ -q')"
run_case "R11 container pytest w/o test URL blocked" 2 "$(bash_json 'ssh vps3 "docker compose run --rm api pytest tests/integration/ -q"')"
run_case "R11 container pytest with test URL allowed" 0 "$(bash_json 'docker compose run -e TEST_DATABASE_URL=postgresql://u@h/app_test --rm api pytest tests/integration/ -q')"
run_case "R11 bypass env"                          0 "$(bash_json 'DB_MIGRATE_URL=postgresql://u@h/app_db pytest tests/integration/ -q')" CLAUDE_ALLOW_DESTRUCTIVE=1
run_case "R11 commit msg mentioning terms allowed" 0 "$(bash_json 'git commit -m "[FIX] guard pytest tests/integration DB_MIGRATE_URL=x/prod"')"
run_case "R12 compose down -v blocked"             2 "$(bash_json 'docker compose down -v')"
run_case "R12 remote compose down --volumes blocked" 2 "$(bash_json 'ssh vps3 "cd /opt/app && docker compose down --volumes"')"
run_case "R12 docker volume rm blocked"            2 "$(bash_json 'docker volume rm app_pgdata')"
run_case "R12 compose down w/o -v allowed"         0 "$(bash_json 'docker compose down')"
run_case "R12 compose up allowed"                  0 "$(bash_json 'ssh vps3 "docker compose up -d --build"')"
run_case "plain ls allowed"                        0 "$(bash_json 'ls -la')"

# --- R9 size-guard -----------------------------------------------------------

dd if=/dev/zero of="$REPO/big.bin" bs=1024 count=2048 2>/dev/null  # 2MB
echo "small" > "$REPO/small.txt"

run_case "R9 git add 2MB file blocked"             2 "$(bash_json 'git add big.bin')"
run_case "R9 git add 2MB file bypass env"          0 "$(bash_json 'git add big.bin')" CLAUDE_ALLOW_BIG_FILE=1
run_case "R9 git add small file allowed"           0 "$(bash_json 'git add small.txt')"
run_case "R9 git add nonexistent path allowed"     0 "$(bash_json 'git add no/such/file.py')"

# commit with a 2MB file actually staged → blocked; bypass lifts it
git -C "$REPO" add big.bin
run_case "R9 commit with staged 2MB file blocked"  2 "$(bash_json 'git commit -m "[CHANGE] x"')"
run_case "R9 commit staged 2MB bypass env"         0 "$(bash_json 'git commit -m "[CHANGE] x"')" CLAUDE_ALLOW_BIG_FILE=1
git -C "$REPO" reset -q -- big.bin
rm -f "$REPO/big.bin" "$REPO/small.txt"

# --- R10 gitleaks-gate -------------------------------------------------------

if command -v gitleaks >/dev/null 2>&1; then
  # Fake GitHub PAT assembled from two string halves so this test file itself
  # never contains a token literal that a repo-wide gitleaks scan would flag.
  FAKE_PAT="ghp_""x7Q9zL2mK4pR8sT1vW3yB5nC6dE0fGhJkLm1"
  printf 'github_token = %s\n' "$FAKE_PAT" > "$REPO/leaky.env"
  git -C "$REPO" add leaky.env
  run_case "R10 staged secret blocks commit"       2 "$(bash_json 'git commit -m "[CHANGE] x"')"
  git -C "$REPO" reset -q -- leaky.env
  rm -f "$REPO/leaky.env"

  echo "nothing secret here" > "$REPO/clean.txt"
  git -C "$REPO" add clean.txt
  run_case "R10 clean staged commit allowed"       0 "$(bash_json 'git commit -m "[CHANGE] x"')"
  git -C "$REPO" reset -q -- clean.txt
  rm -f "$REPO/clean.txt"
else
  echo "SKIP: R10 staged secret blocks commit (gitleaks not installed)"
  echo "SKIP: R10 clean staged commit allowed (gitleaks not installed)"
  SKIP=$((SKIP + 2))
fi

# --- File rules ------------------------------------------------------------

# R1 (backup-gate) was removed 2026-07-03: ordinary Edit/Write are insured by
# native Claude Code checkpoints (/rewind). Edits must pass regardless of the
# last commit's prefix. Prove it with a non-BACKUP last commit:
git_commit "[CHANGE] something landed"
run_case "Edit allowed with non-BACKUP last commit (R1 removed)" 0 "$(file_json "$REPO/module.py")"
run_case "Edit allowed for file outside git root"                0 "$(file_json "$OUTSIDE/note.txt")"

# R2 config protection is independent of last-commit prefix
run_case "R2 Edit CLAUDE.md blocked"               2 "$(file_json "$REPO/CLAUDE.md")"
run_case "R2 Edit CLAUDE.md bypass env"            0 "$(file_json "$REPO/CLAUDE.md")" CLAUDE_CONFIG_EDIT_OK=1
run_case "R2 Edit .claude/settings.json blocked"   2 "$(file_json "$REPO/.claude/settings.json")"

# --- Robustness ------------------------------------------------------------

run_case "broken JSON fail-open"                   0 '{this is not json'
run_case "unknown tool_name allowed"               0 '{"hook_event_name":"PreToolUse","tool_name":"Glob","tool_input":{"pattern":"*.py"}}'
run_case "empty tool_input allowed"                0 '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{}}'

# ---------------------------------------------------------------------------

echo
echo "=== Result: $PASS passed, $SKIP skipped, $FAIL failed ==="
[ "$FAIL" -eq 0 ] || exit 1
exit 0
