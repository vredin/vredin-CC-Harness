#!/usr/bin/env bash
# Test harness for context-budget-enforce.sh
# Run: bash .claude/hooks/test-context-budget-enforce.sh
# Exits 0 if all tests pass, non-zero if any fail.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/context-budget-enforce.sh"
PASS=0
FAIL=0
FAILED_NAMES=()

_mktmp() { mktemp -d "${TMPDIR:-/tmp}/ctxbudget-test.XXXXXX"; }

_assert() {
  local name="$1"
  local cond="$2"
  if eval "$cond"; then
    PASS=$((PASS + 1))
    printf '  ok   %s\n' "$name"
  else
    FAIL=$((FAIL + 1))
    FAILED_NAMES+=("$name")
    printf '  FAIL %s — condition: %s\n' "$name" "$cond"
  fi
}

# Assert a grep pattern appears in a file (avoids passing multiline content
# through eval, which chokes on parens / quotes in hook output).
_assert_grep() {
  local name="$1"
  local pattern="$2"
  local file="$3"
  if grep -q -- "$pattern" "$file" 2>/dev/null; then
    PASS=$((PASS + 1))
    printf '  ok   %s\n' "$name"
  else
    FAIL=$((FAIL + 1))
    FAILED_NAMES+=("$name")
    printf '  FAIL %s — pattern %q not found in %s\n' "$name" "$pattern" "$file"
  fi
}

_assert_nogrep() {
  local name="$1"
  local pattern="$2"
  local file="$3"
  if ! grep -q -- "$pattern" "$file" 2>/dev/null; then
    PASS=$((PASS + 1))
    printf '  ok   %s\n' "$name"
  else
    FAIL=$((FAIL + 1))
    FAILED_NAMES+=("$name")
    printf '  FAIL %s — pattern %q unexpectedly found in %s\n' "$name" "$pattern" "$file"
  fi
}

# Writes a "valid" handoff.md containing at least 3 required section headers,
# so the content-check in the hook treats it as real (not an empty touch file).
_write_valid_handoff() {
  local dir="$1"
  mkdir -p "$dir/docs"
  cat > "$dir/docs/handoff.md" <<'EOF'
# Session Handoff — test

## Completed This Session
- test

## In Progress (not finished)
- test

## Next Session Should
1. test

## Context That Would Be Lost
- test

## User's Last Unanswered Question
- none
EOF
}

# Initialise an ephemeral git repo with N dummy commits and optional handoff.md
# Usage: _setup_repo <tmpdir> <num_commits> [handoff_touch=yes|no] [handoff_before_last_commit=yes|no] [handoff_valid=yes|no]
_setup_repo() {
  local dir="$1"
  local n_commits="$2"
  local touch_handoff="${3:-no}"
  local handoff_before_last="${4:-no}"
  local handoff_valid="${5:-yes}"   # default to valid content for realism
  (
    cd "$dir" || exit 1
    git init -q
    git config user.email "test@test"
    git config user.name "test"
    git commit --allow-empty -q -m "init"
    mkdir -p docs
    for i in $(seq 1 "$n_commits"); do
      {
        for j in $(seq 1 100); do
          printf 'line %d of commit %d\n' "$j" "$i"
        done
      } > "file_${i}.txt"
      git add "file_${i}.txt"
      git commit -q -m "[CHANGE] commit ${i}"
    done
    if [ "$touch_handoff" = "yes" ]; then
      if [ "$handoff_valid" = "yes" ]; then
        _write_valid_handoff "$dir"
      else
        printf 'handoff\n' > docs/handoff.md   # empty/invalid for content-check test
      fi
      if [ "$handoff_before_last" = "yes" ]; then
        if command -v touch >/dev/null 2>&1; then
          touch -t 200001010000 docs/handoff.md
        fi
      fi
    fi
  )
}

_run_hook() {
  local dir="$1"
  shift
  (
    cd "$dir" || exit 1
    # Hook reads no stdin in Stop mode but we pass empty JSON for symmetry
    "$@" bash "$HOOK" </dev/null 2>&1
  )
}

# Runs the hook, captures combined stderr+stdout into OUTFILE, stores exit in RCVAR.
# Usage: _capture_hook <tmpdir> <outfile> <rcvar> [env args...]
_capture_hook() {
  local dir="$1"
  local outfile="$2"
  local rcvar="$3"
  shift 3
  (
    cd "$dir" || exit 1
    "$@" bash "$HOOK" </dev/null >"$outfile" 2>&1
  )
  eval "$rcvar=$?"
}

# ------- Fixture 1: under threshold (no handoff, 2 commits, ~200 lines) -------
printf '\n=== test 1: under threshold — no block ===\n'
TMP1=$(_mktmp); OUT1="$TMP1/hook.out"
_setup_repo "$TMP1" 2 no
_capture_hook "$TMP1" "$OUT1" RC1 env CTX_BUDGET_MAX_COMMITS=6 CTX_BUDGET_MAX_LINES=500
_assert       "under: exit 0"          "[ $RC1 -eq 0 ]"
_assert_nogrep "under: no block output" 'HARD BLOCK' "$OUT1"
rm -rf "$TMP1"

# ------- Fixture 2: over commit threshold, no handoff, HARD mode → must block -------
printf '\n=== test 2: over commits, no handoff, CTX_BUDGET_HARD=1 → BLOCK ===\n'
TMP2=$(_mktmp); OUT2="$TMP2/hook.out"
_setup_repo "$TMP2" 8 no
_capture_hook "$TMP2" "$OUT2" RC2 env CTX_BUDGET_HARD=1 CTX_BUDGET_MAX_COMMITS=6 CTX_BUDGET_MAX_LINES=10000
_assert       "over commits: exit 2"          "[ $RC2 -eq 2 ]"
_assert_grep  "over commits: HARD BLOCK"      'HARD BLOCK'       "$OUT2"
_assert_grep  "over commits: mentions handoff" 'docs/handoff.md' "$OUT2"
# With 8 [CHANGE] + 1 init = 9 commits in the 4h window (no [HANDOFF] anchor)
_assert_grep  "over commits: mentions 9"      'commits=9/'       "$OUT2"
rm -rf "$TMP2"

# ------- Fixture 2b: over threshold, no handoff, DEFAULT (soft) mode → warn, exit 0 -------
printf '\n=== test 2b: over commits, no handoff, no CTX_BUDGET_HARD → WARN + exit 0 ===\n'
TMP2B=$(_mktmp); OUT2B="$TMP2B/hook.out"
_setup_repo "$TMP2B" 8 no
_capture_hook "$TMP2B" "$OUT2B" RC2B env CTX_BUDGET_MAX_COMMITS=6 CTX_BUDGET_MAX_LINES=10000
_assert        "soft default: exit 0"           "[ $RC2B -eq 0 ]"
_assert_grep   "soft default: WARNING emitted"  'CONTEXT BUDGET — WARNING' "$OUT2B"
_assert_grep   "soft default: mentions handoff" 'docs/handoff.md'          "$OUT2B"
_assert_nogrep "soft default: no HARD BLOCK"    'HARD BLOCK'               "$OUT2B"
rm -rf "$TMP2B"

# ------- Fixture 3: over line threshold, no handoff, HARD mode → must block -------
printf '\n=== test 3: over lines, no handoff, CTX_BUDGET_HARD=1 → BLOCK ===\n'
TMP3=$(_mktmp); OUT3="$TMP3/hook.out"
_setup_repo "$TMP3" 3 no   # 3 commits * 100 lines = 300 lines
_capture_hook "$TMP3" "$OUT3" RC3 env CTX_BUDGET_HARD=1 CTX_BUDGET_MAX_COMMITS=100 CTX_BUDGET_MAX_LINES=200
_assert       "over lines: exit 2"        "[ $RC3 -eq 2 ]"
_assert_grep  "over lines: HARD BLOCK"    'HARD BLOCK' "$OUT3"
_assert_grep  "over lines: line signal"   'lines=300/' "$OUT3"
rm -rf "$TMP3"

# ------- Fixture 4: over threshold WITH fresh+valid handoff → allow stop -------
printf '\n=== test 4: over threshold + fresh VALID handoff → allow ===\n'
TMP4=$(_mktmp); OUT4="$TMP4/hook.out"
_setup_repo "$TMP4" 8 yes no yes   # 8 commits + valid handoff content
touch "$TMP4/docs/handoff.md"      # guarantee mtime >= last commit
_capture_hook "$TMP4" "$OUT4" RC4 env CTX_BUDGET_MAX_COMMITS=6 CTX_BUDGET_MAX_LINES=500
_assert        "fresh handoff: exit 0"          "[ $RC4 -eq 0 ]"
_assert_nogrep "fresh handoff: no block output" 'HARD BLOCK' "$OUT4"
rm -rf "$TMP4"

# ------- Fixture 5: stale handoff (older than last commit) → treat as missing, block -------
printf '\n=== test 5: stale handoff (mtime < last commit) → BLOCK ===\n'
TMP5=$(_mktmp); OUT5="$TMP5/hook.out"
_setup_repo "$TMP5" 8 yes yes
_capture_hook "$TMP5" "$OUT5" RC5 env CTX_BUDGET_HARD=1 CTX_BUDGET_MAX_COMMITS=6 CTX_BUDGET_MAX_LINES=10000
_assert      "stale handoff: exit 2"         "[ $RC5 -eq 2 ]"
_assert_grep "stale handoff: fresh=no"       'handoff fresh: no' "$OUT5"
rm -rf "$TMP5"

# ------- Fixture 6: not a git repo → graceful exit 0 -------
printf '\n=== test 6: no git repo → exit 0 silent ===\n'
TMP6=$(_mktmp); OUT6="$TMP6/hook.out"
_capture_hook "$TMP6" "$OUT6" RC6
_assert        "no git: exit 0"            "[ $RC6 -eq 0 ]"
_assert_nogrep "no git: silent (no BLOCK)" 'HARD BLOCK' "$OUT6"
rm -rf "$TMP6"

# ------- Fixture 6b: empty/contentless handoff.md fails content-check → BLOCK (DA-005) -------
printf '\n=== test 6b: contentless handoff.md → BLOCK (content check) ===\n'
TMP6B=$(_mktmp); OUT6B="$TMP6B/hook.out"
_setup_repo "$TMP6B" 8 yes no no   # 8 commits, handoff touched but INVALID content
touch "$TMP6B/docs/handoff.md"      # fresh mtime but empty content
_capture_hook "$TMP6B" "$OUT6B" RC6B env CTX_BUDGET_HARD=1 CTX_BUDGET_MAX_COMMITS=6 CTX_BUDGET_MAX_LINES=10000
_assert      "contentless: exit 2"          "[ $RC6B -eq 2 ]"
_assert_grep "contentless: handoff fresh=no" 'handoff fresh: no' "$OUT6B"
rm -rf "$TMP6B"

# ------- Fixture 6c: last commit is [HANDOFF] → fresh regardless of mtime (DA-003) -------
printf '\n=== test 6c: last commit is [HANDOFF] → allow ===\n'
TMP6C=$(_mktmp); OUT6C="$TMP6C/hook.out"
(
  cd "$TMP6C" || exit 1
  git init -q
  git config user.email "test@test"
  git config user.name "test"
  git commit --allow-empty -q -m "init"
  mkdir -p docs
  for i in $(seq 1 8); do
    printf 'noise %d\n' "$i" > "f_${i}.txt"
    git add "f_${i}.txt"
    git commit -q -m "[CHANGE] noise ${i}"
  done
  # Write valid handoff AND commit it as [HANDOFF] — last commit subject now matches
  cat > docs/handoff.md <<'H'
# Handoff
## Completed This Session
## In Progress
## Next Session Should
## Context That Would Be Lost
## Unanswered Question
H
  git add docs/handoff.md
  git commit -q -m "[HANDOFF] session done"
)
_capture_hook "$TMP6C" "$OUT6C" RC6C env CTX_BUDGET_MAX_COMMITS=6 CTX_BUDGET_MAX_LINES=500
_assert        "last-handoff commit: exit 0"   "[ $RC6C -eq 0 ]"
_assert_nogrep "last-handoff commit: no block" 'HARD BLOCK' "$OUT6C"
rm -rf "$TMP6C"

# ------- Fixture 6d: circuit breaker trips after N blocks (DA-004) -------
printf '\n=== test 6d: circuit breaker trip after max blocks ===\n'
TMP6D=$(_mktmp); OUT6D_1="$TMP6D/hook1.out"; OUT6D_2="$TMP6D/hook2.out"; OUT6D_3="$TMP6D/hook3.out"; OUT6D_4="$TMP6D/hook4.out"
_setup_repo "$TMP6D" 8 no
# First 3 invocations should block (exit 2), 4th should circuit-break (exit 0)
_capture_hook "$TMP6D" "$OUT6D_1" RC6D1 env CTX_BUDGET_HARD=1 CTX_BUDGET_MAX_COMMITS=6 CTX_BUDGET_MAX_LINES=10000 CTX_BUDGET_TRIP_MAX=3 CTX_BUDGET_TRIP_WINDOW=3600
_capture_hook "$TMP6D" "$OUT6D_2" RC6D2 env CTX_BUDGET_HARD=1 CTX_BUDGET_MAX_COMMITS=6 CTX_BUDGET_MAX_LINES=10000 CTX_BUDGET_TRIP_MAX=3 CTX_BUDGET_TRIP_WINDOW=3600
_capture_hook "$TMP6D" "$OUT6D_3" RC6D3 env CTX_BUDGET_HARD=1 CTX_BUDGET_MAX_COMMITS=6 CTX_BUDGET_MAX_LINES=10000 CTX_BUDGET_TRIP_MAX=3 CTX_BUDGET_TRIP_WINDOW=3600
_capture_hook "$TMP6D" "$OUT6D_4" RC6D4 env CTX_BUDGET_HARD=1 CTX_BUDGET_MAX_COMMITS=6 CTX_BUDGET_MAX_LINES=10000 CTX_BUDGET_TRIP_MAX=3 CTX_BUDGET_TRIP_WINDOW=3600
_assert      "breaker trip 1: exit 2"        "[ $RC6D1 -eq 2 ]"
_assert      "breaker trip 2: exit 2"        "[ $RC6D2 -eq 2 ]"
_assert      "breaker trip 3: exit 2"        "[ $RC6D3 -eq 2 ]"
_assert      "breaker trip 4: exit 0 (broke)" "[ $RC6D4 -eq 0 ]"
_assert_grep "breaker trip 4: message"       'CIRCUIT BREAKER TRIPPED' "$OUT6D_4"
rm -rf "$TMP6D"

# ------- Fixture 6e: portable last-work-hash (DA-009 — no --invert-grep) -------
# History: init, work×3, [HANDOFF], work×2. After the last work commit, valid
# handoff.md is touched AFTER the last work commit → must allow.
# Validates the grep-based filter correctly finds the last non-[HANDOFF] commit.
printf '\n=== test 6e: portable non-handoff commit detection ===\n'
TMP6E=$(_mktmp); OUT6E="$TMP6E/hook.out"
(
  cd "$TMP6E" || exit 1
  git init -q
  git config user.email "test@test"
  git config user.name "test"
  git commit --allow-empty -q -m "init"
  mkdir -p docs
  for i in 1 2 3; do
    printf 'work %d\n' "$i" > "w_${i}.txt"
    git add "w_${i}.txt"
    git commit -q -m "[CHANGE] work ${i}"
  done
  cat > docs/handoff.md <<'H'
# Handoff
## Completed This Session
## In Progress
## Next Session Should
## Context That Would Be Lost
## Unanswered Question
H
  git add docs/handoff.md
  git commit -q -m "[HANDOFF] earlier"
  # 5 more non-[HANDOFF] work commits AFTER the handoff
  for i in 4 5 6 7 8; do
    printf 'post %d\n' "$i" > "p_${i}.txt"
    git add "p_${i}.txt"
    git commit -q -m "[CHANGE] post ${i}"
  done
  # Explicitly backdate handoff.md to force the mtime < last-work-commit condition
  # (in real sessions the gap is many seconds; test fixture runs in <1s, so same-
  # second tie makes the freshness check pass unless we force a gap).
  touch -t 200001010000 docs/handoff.md
)
_capture_hook "$TMP6E" "$OUT6E" RC6E env CTX_BUDGET_HARD=1 CTX_BUDGET_MAX_COMMITS=2 CTX_BUDGET_MAX_LINES=10000
# After [HANDOFF] earlier, we expect 5 post commits > limit 2 → block, and
# handoff.md mtime should be older than last work commit → stale → block.
_assert      "DA-009 portable: exit 2"         "[ $RC6E -eq 2 ]"
_assert_grep "DA-009 portable: HARD BLOCK"     'HARD BLOCK' "$OUT6E"
_assert_grep "DA-009 portable: 5 post commits" 'commits=5/' "$OUT6E"
rm -rf "$TMP6E"

# ------- Fixture 7: [HANDOFF] commit exists → count only post-handoff commits -------
printf '\n=== test 7: [HANDOFF] commit anchors comparison base ===\n'
TMP7=$(_mktmp); OUT7="$TMP7/hook.out"
(
  cd "$TMP7" || exit 1
  git init -q
  git config user.email "test@test"
  git config user.name "test"
  git commit --allow-empty -q -m "init"
  mkdir -p docs
  for i in $(seq 1 8); do
    printf 'old commit %d\n' "$i" > "old_${i}.txt"
    git add "old_${i}.txt"
    git commit -q -m "[CHANGE] old ${i}"
  done
  cat > docs/handoff.md <<'H'
# Baseline handoff
## Completed This Session
- prior work
## In Progress
- ongoing
## Next Session Should
1. continue
## Context That Would Be Lost
- misc
## Unanswered Question
- none
H
  git add docs/handoff.md
  git commit -q -m "[HANDOFF] session baseline"
  for i in 1 2; do
    printf 'post line\n' > "post_${i}.txt"
    git add "post_${i}.txt"
    git commit -q -m "[CHANGE] post ${i}"
  done
  touch docs/handoff.md
)
_capture_hook "$TMP7" "$OUT7" RC7 env CTX_BUDGET_MAX_COMMITS=6 CTX_BUDGET_MAX_LINES=500
_assert        "post-handoff: exit 0"   "[ $RC7 -eq 0 ]"
_assert_nogrep "post-handoff: no block" 'HARD BLOCK' "$OUT7"
rm -rf "$TMP7"

# ------- Summary -------
printf '\n====\n'
printf 'Passed: %d\n' "$PASS"
printf 'Failed: %d\n' "$FAIL"
if [ "$FAIL" -gt 0 ]; then
  printf 'Failed tests:\n'
  for n in "${FAILED_NAMES[@]}"; do
    printf '  - %s\n' "$n"
  done
  exit 1
fi
printf 'ALL PASS\n'
exit 0
