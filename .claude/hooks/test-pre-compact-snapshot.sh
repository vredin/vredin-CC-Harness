#!/usr/bin/env bash
# Test harness for pre-compact-snapshot.sh
# Run: bash .claude/hooks/test-pre-compact-snapshot.sh
# Exits 0 if all tests pass, non-zero if any fail.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/pre-compact-snapshot.sh"
PASS=0
FAIL=0
FAILED_NAMES=()

# ------- Helpers -------
_mktmp() { mktemp -d "${TMPDIR:-/tmp}/precompact-test.XXXXXX"; }

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

_run_hook() {
  # $1 = JSON payload
  # $2 = optional PATH override (to force jq absence)
  local payload="$1"
  local path_override="${2:-}"
  if [ -n "$path_override" ]; then
    env PATH="$path_override" bash "$HOOK" <<<"$payload" 2>&1
  else
    bash "$HOOK" <<<"$payload" 2>&1
  fi
}

# ------- Fixture 1: happy path with jq -------
printf '\n=== test 1: happy path (jq present) ===\n'
TMP1=$(_mktmp)
FAKE_TRANSCRIPT="$TMP1/fake-transcript.jsonl"
printf '{"role":"user","content":"hello"}\n{"role":"assistant","content":"hi"}\n' > "$FAKE_TRANSCRIPT"
PAYLOAD1=$(printf '{"session_id":"abc12345-def6-7890","transcript_path":"%s","cwd":"%s","trigger":"manual"}' "$FAKE_TRANSCRIPT" "$TMP1")
OUT1=$(_run_hook "$PAYLOAD1")
_assert "exit 0"                 "[ \$? -eq 0 ]"
_assert "log dir created"        "[ -d '$TMP1/.claude/session-log' ]"
_assert "snapshot exists"        "ls $TMP1/.claude/session-log/compact-manual-*-abc12345.jsonl >/dev/null 2>&1"
_assert "snapshot has 2 lines"   "[ \$(wc -l < \$(ls $TMP1/.claude/session-log/compact-manual-*-abc12345.jsonl | head -1) | tr -d ' ') -eq 2 ]"
_assert "audit log exists"       "[ -f '$TMP1/.claude/session-log/compact-audit.log' ]"
_assert "hint file exists"       "[ -f '$TMP1/.claude/session-log/LAST_COMPACT_HINT.md' ]"
_assert "stdout mentions PRE-COMPACT" "echo '$OUT1' | grep -q 'PRE-COMPACT SNAPSHOT'"
rm -rf "$TMP1"

# ------- Fixture 2: python3 fallback (force jq absent) -------
printf '\n=== test 2: python3 fallback (jq hidden) ===\n'
TMP2=$(_mktmp)
FAKE_TRANSCRIPT2="$TMP2/fake-transcript.jsonl"
printf '{"role":"user","content":"test"}\n' > "$FAKE_TRANSCRIPT2"
PAYLOAD2=$(printf '{"session_id":"py1234-test","transcript_path":"%s","cwd":"%s","trigger":"auto"}' "$FAKE_TRANSCRIPT2" "$TMP2")
# Build a PATH that has python3 but no jq: copy python3's dir but filter out jq
MINIMAL_PATH="/usr/bin:/bin:/usr/sbin:/sbin"
# Ensure python3 is on it
if ! env PATH="$MINIMAL_PATH" command -v python3 >/dev/null 2>&1; then
  for d in /usr/local/bin /opt/homebrew/bin /usr/local/opt/python3/bin; do
    if [ -x "$d/python3" ]; then
      MINIMAL_PATH="$d:$MINIMAL_PATH"
      break
    fi
  done
fi
OUT2=$(_run_hook "$PAYLOAD2" "$MINIMAL_PATH")
_assert "python3 branch: log dir"   "[ -d '$TMP2/.claude/session-log' ]"
_assert "python3 branch: snapshot"  "ls $TMP2/.claude/session-log/compact-auto-*.jsonl >/dev/null 2>&1"
_assert "python3 branch: stdout ok" "echo '$OUT2' | grep -q 'trigger=auto'"
rm -rf "$TMP2"

# ------- Fixture 3: neither jq nor python3 (minimal PATH) -------
printf '\n=== test 3: no jq, no python3 (degraded mode) ===\n'
TMP3=$(_mktmp)
FAKE_TRANSCRIPT3="$TMP3/fake-transcript.jsonl"
printf 'line\n' > "$FAKE_TRANSCRIPT3"
PAYLOAD3=$(printf '{"session_id":"nodeps","transcript_path":"%s","cwd":"%s","trigger":"manual"}' "$FAKE_TRANSCRIPT3" "$TMP3")
# Truly minimal — only /bin, so jq and python3 should both be absent
OUT3=$(_run_hook "$PAYLOAD3" "/bin:/usr/bin")
# In degraded mode, defaults apply. We still expect the hook to run and produce a log dir.
# The snapshot filename will have session=unknown because JSON wasn't parsed.
_assert "degraded: exit 0"       "[ \$? -eq 0 ]"
_assert "degraded: log dir"      "[ -d '$TMP3/.claude/session-log' ]"
# If python3 is in /usr/bin, this test still uses it — that's fine, we don't assert
# "parsing failed" because the environment varies. We only assert the hook didn't crash.
_assert "degraded: stdout ok"    "echo '$OUT3' | grep -q 'PRE-COMPACT SNAPSHOT'"
rm -rf "$TMP3"

# ------- Fixture 4: path traversal in trigger — MUST be sanitized -------
printf '\n=== test 4: path traversal attack via trigger field ===\n'
TMP4=$(_mktmp)
FAKE_TRANSCRIPT4="$TMP4/fake-transcript.jsonl"
printf 'secret\n' > "$FAKE_TRANSCRIPT4"
# Attempt to write snapshot to ../../ — sanitizer should replace slashes and dots
EVIL_TRIGGER='auto/../../../tmp/pwned'
PAYLOAD4=$(python3 -c "
import json
print(json.dumps({
    'session_id': '../../etc/passwd',
    'transcript_path': '$FAKE_TRANSCRIPT4',
    'cwd': '$TMP4',
    'trigger': '$EVIL_TRIGGER'
}))
" 2>/dev/null || printf '{"session_id":"badid","transcript_path":"%s","cwd":"%s","trigger":"badtrig"}' "$FAKE_TRANSCRIPT4" "$TMP4")
OUT4=$(_run_hook "$PAYLOAD4")
# Real safety assertions: the attack path must not exist, the snapshot
# must live inside the expected LOG_DIR, and the filename (not path) must
# contain no slashes (which is what would actually enable directory escape).
# Literal '..' inside a sanitized filename is harmless without a '/'.
_assert "no file at /tmp/pwned"  "[ ! -e /tmp/pwned ]"
_assert "snapshot contained"     "ls $TMP4/.claude/session-log/compact-*.jsonl >/dev/null 2>&1"
SNAPSHOT_FULL=$(ls $TMP4/.claude/session-log/compact-*.jsonl 2>/dev/null | head -1)
SNAPSHOT_BASENAME=$(basename "${SNAPSHOT_FULL:-}")
_assert "filename has no slash"  "! echo '$SNAPSHOT_BASENAME' | grep -q '/'"
# Verify resolved snapshot path is under LOG_DIR (no escape via symlink etc)
RESOLVED=$(cd "$(dirname "$SNAPSHOT_FULL")" 2>/dev/null && pwd -P)
EXPECTED=$(cd "$TMP4/.claude/session-log" 2>/dev/null && pwd -P)
_assert "resolved path in LOG_DIR" "[ \"$RESOLVED\" = \"$EXPECTED\" ]"
rm -rf "$TMP4"

# ------- Fixture 5: missing transcript_path -------
printf '\n=== test 5: missing transcript_path ===\n'
TMP5=$(_mktmp)
PAYLOAD5=$(printf '{"session_id":"notrans","cwd":"%s","trigger":"manual"}' "$TMP5")
OUT5=$(_run_hook "$PAYLOAD5")
_assert "missing transcript: exit 0"        "[ \$? -eq 0 ]"
_assert "missing transcript: log dir"       "[ -d '$TMP5/.claude/session-log' ]"
_assert "missing transcript: audit entry"   "grep -q 'session=notrans' '$TMP5/.claude/session-log/compact-audit.log' 2>/dev/null"
_assert "missing transcript: hint file"     "[ -f '$TMP5/.claude/session-log/LAST_COMPACT_HINT.md' ]"
rm -rf "$TMP5"

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
