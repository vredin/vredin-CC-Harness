#!/usr/bin/env bash
# PreCompact hook — audit-only snapshot before context compaction.
# Fires on BOTH manual /compact and auto-compact (~95%).
# Cannot block compaction (async, exit code ignored) — purely defensive.
#
# What it does:
#   1. Reads JSON from stdin: session_id, transcript_path, cwd, trigger
#   2. Sanitizes every field that will touch the filesystem
#   3. Copies transcript to .claude/session-log/compact-<trigger>-<ts>-<shortid>.jsonl
#   4. Appends one-line audit entry to .claude/session-log/compact-audit.log
#   5. Writes a marker hint file .claude/session-log/LAST_COMPACT_HINT.md
#      (primary delivery channel — workflow.md § Surviving Compaction reads it)
#   6. Prints short summary to stdout (best-effort, post-compact context)
#   7. Rotates old snapshots (keeps newest 20) and truncates audit log
#   8. Deep-rotates session-log: snapshots >30 days deleted; if dir >200MB,
#      oldest snapshots deleted until under cap (hook-errors.log untouched)
#
# Related: T-001 in docs/TASK.md, .claude/rules/workflow.md § Surviving Compaction

set -euo pipefail

# ------- Defaults (set FIRST so `set -u` is safe on every branch) -------
SESSION_ID="unknown"
TRANSCRIPT=""
CWD_IN=""
TRIGGER="unknown"

# ------- Read stdin -------
PAYLOAD=$(cat 2>/dev/null || echo '{}')

# ------- Parse (jq → python3 → defaults) -------
if command -v jq >/dev/null 2>&1; then
  SESSION_ID=$(printf '%s' "$PAYLOAD" | jq -r '.session_id // "unknown"' 2>/dev/null || printf 'unknown')
  TRANSCRIPT=$(printf '%s' "$PAYLOAD" | jq -r '.transcript_path // ""' 2>/dev/null || printf '')
  CWD_IN=$(printf '%s'     "$PAYLOAD" | jq -r '.cwd // ""'             2>/dev/null || printf '')
  TRIGGER=$(printf '%s'    "$PAYLOAD" | jq -r '.trigger // "unknown"'  2>/dev/null || printf 'unknown')
elif command -v python3 >/dev/null 2>&1; then
  # Print 4 lines: session_id, transcript_path, cwd, trigger — one per line.
  # No eval, no f-string escapes, no cleverness.
  _OUT=$(printf '%s' "$PAYLOAD" | python3 -c '
import json, sys
try:
    d = json.loads(sys.stdin.read())
    if not isinstance(d, dict):
        d = {}
except Exception:
    d = {}
print(d.get("session_id") or "unknown")
print(d.get("transcript_path") or "")
print(d.get("cwd") or "")
print(d.get("trigger") or "unknown")
' 2>/dev/null || printf 'unknown\n\n\nunknown\n')
  # Read the 4 lines into vars
  { IFS= read -r SESSION_ID || SESSION_ID="unknown"
    IFS= read -r TRANSCRIPT || TRANSCRIPT=""
    IFS= read -r CWD_IN     || CWD_IN=""
    IFS= read -r TRIGGER    || TRIGGER="unknown"
  } <<<"$_OUT"
  [ -z "$SESSION_ID" ] && SESSION_ID="unknown"
  [ -z "$TRIGGER" ]    && TRIGGER="unknown"
fi

# ------- Sanitize every field that touches the filesystem -------
# Allow only [A-Za-z0-9._-], cap length. Prevents path traversal, shell metachars,
# and injection through hook input even if Claude Code's spec drifts.
_sanitize() {
  # $1 = input, $2 = max length
  printf '%s' "$1" | tr -c 'A-Za-z0-9._-' '_' | cut -c1-"${2:-64}"
}

TRIGGER=$(_sanitize "$TRIGGER" 16)
SESSION_ID=$(_sanitize "$SESSION_ID" 64)
SHORT_ID="${SESSION_ID:0:8}"
[ -z "$TRIGGER" ]  && TRIGGER="unknown"
[ -z "$SHORT_ID" ] && SHORT_ID="unknown"

# Clamp cwd: must be an existing absolute path without '..' segments, else fall back.
if [ -n "$CWD_IN" ] && [ "${CWD_IN:0:1}" = "/" ] && ! printf '%s' "$CWD_IN" | grep -q '\.\.' && [ -d "$CWD_IN" ]; then
  TARGET_DIR="$CWD_IN"
else
  TARGET_DIR="$PWD"
fi

# Clamp transcript_path: require absolute path and existing regular file, else treat as missing.
if [ -n "$TRANSCRIPT" ] && [ "${TRANSCRIPT:0:1}" = "/" ] && ! printf '%s' "$TRANSCRIPT" | grep -q '\.\.' && [ -f "$TRANSCRIPT" ]; then
  :
else
  TRANSCRIPT=""
fi

LOG_DIR="$TARGET_DIR/.claude/session-log"
INBOX="$TARGET_DIR/.claude/session-inbox.md"
HANDOFF="$TARGET_DIR/docs/handoff.md"

# ------- Create log dir (verbose failure instead of silent exit) -------
if ! mkdir -p "$LOG_DIR" 2>/dev/null; then
  cat <<EOF
[PRE-COMPACT SNAPSHOT] cannot create $LOG_DIR — snapshot SKIPPED.
Check directory permissions. Without this the audit trail is not being written
and your post-compact recovery falls back to the auto-compaction summary only.
EOF
  exit 0
fi

TS=$(date -u +%Y%m%dT%H%M%SZ)
SNAPSHOT="$LOG_DIR/compact-${TRIGGER}-${TS}-${SHORT_ID}.jsonl"
AUDIT="$LOG_DIR/compact-audit.log"
HINT="$LOG_DIR/LAST_COMPACT_HINT.md"

# ------- Snapshot transcript -------
SIZE="0"
if [ -n "$TRANSCRIPT" ]; then
  if cp "$TRANSCRIPT" "$SNAPSHOT" 2>/dev/null; then
    SIZE=$(wc -l < "$SNAPSHOT" 2>/dev/null | tr -d ' ' || printf '?')
  else
    SNAPSHOT="(copy failed)"
  fi
else
  SNAPSHOT="(no transcript path provided)"
fi

# ------- Append audit line -------
printf '%s  trigger=%s  session=%s  lines=%s  path=%s\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$TRIGGER" "$SHORT_ID" "$SIZE" "$SNAPSHOT" \
  >> "$AUDIT" 2>/dev/null || true

# ------- Rescue unfinished tasks from session-inbox.md → handoff.md -------
# When compaction fires, .claude/session-inbox.md may have unfinished items
# ([ ], [~], [!]). Append them to docs/handoff.md so the next session reads
# them at SessionStart and resumes. Closes the "task lost during compaction"
# failure mode. Best-effort: never blocks the snapshot path.
# MUST run before HINT block — HINT references $UNFINISHED_COUNT.
UNFINISHED_COUNT=0
if [ -f "$INBOX" ]; then
  # Match lines like:  - [ ] ...   - [~] ...   - [!] ...   (with optional leading space)
  UNFINISHED=$(grep -E '^[[:space:]]*-[[:space:]]*\[[ ~!]\]' "$INBOX" 2>/dev/null || true)
  if [ -n "$UNFINISHED" ]; then
    UNFINISHED_COUNT=$(printf '%s\n' "$UNFINISHED" | grep -c '^' 2>/dev/null || echo 0)
    mkdir -p "$(dirname "$HANDOFF")" 2>/dev/null || true
    {
      printf '\n## Rescued from session-inbox by pre-compact hook\n\n'
      printf 'ts: %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
      printf 'trigger: %s\n' "$TRIGGER"
      printf 'session: %s\n' "$SHORT_ID"
      printf 'source: %s\n\n' "$INBOX"
      printf '%s\n' "$UNFINISHED"
      printf '\n_Continue these tasks in the next session. Update statuses ([x] done, [~] in progress, [!] blocked) in `.claude/session-inbox.md` as you go._\n'
    } >> "$HANDOFF" 2>/dev/null || true
  fi
fi

# ------- Marker hint file (primary delivery — not stdout) -------
# workflow.md § Surviving Compaction instructs post-compact Claude to read this.
cat > "$HINT" 2>/dev/null <<EOF
# Last Compact Hint — written by PreCompact hook

ts: $(date -u +%Y-%m-%dT%H:%M:%SZ)
trigger: $TRIGGER
session: $SHORT_ID
snapshot: $SNAPSHOT
snapshot_lines: $SIZE
audit: $AUDIT
inbox_rescued_items: $UNFINISHED_COUNT

## Post-compact recovery order (per workflow.md § Surviving Compaction)

1. If \`docs/handoff.md\` exists — read it FIRST, resume, then delete it.
   (Pre-compact hook may have just appended a "Rescued from session-inbox" section
   with $UNFINISHED_COUNT unfinished tasks — those are your continuation list.)
2. If the auto-compaction summary captured the user's last message — proceed normally.
3. Otherwise: grep the snapshot for the user's last few messages:
     grep '"role":"user"' "$SNAPSHOT" | tail -5
   Surface what you find to the user and ask for confirmation before acting.
4. Nothing recoverable? Ask the user to repeat their last request. Do not guess.
EOF

# ------- Rotate: keep newest 20 snapshots, truncate audit log to 1000 lines -------
# BSD and GNU compatible — use a simple pipeline.
(
  cd "$LOG_DIR" 2>/dev/null || exit 0
  # Delete all but the 20 newest compact-*.jsonl files
  ls -1t compact-*.jsonl 2>/dev/null | tail -n +21 | while IFS= read -r _old; do
    [ -n "$_old" ] && rm -f "$_old" 2>/dev/null || true
  done
  # Truncate audit log to newest 1000 lines
  if [ -f "$AUDIT" ]; then
    _lines=$(wc -l < "$AUDIT" 2>/dev/null | tr -d ' ')
    if [ -n "$_lines" ] && [ "$_lines" -gt 1000 ] 2>/dev/null; then
      tail -n 1000 "$AUDIT" > "${AUDIT}.tmp" 2>/dev/null && mv "${AUDIT}.tmp" "$AUDIT" 2>/dev/null || true
    fi
  fi
) || true

# ------- Deep rotation: 30-day age cap + 200MB size cap on session-log -------
# Precedent: one project's session-log grew to 1.1GB. Deletes ONLY
# compact-*.jsonl — hook-errors.log is never touched; compact-audit.log gets
# the 1000-line cap above plus a 1MB safety trim here. BSD/GNU compatible.
(
  cd "$LOG_DIR" 2>/dev/null || exit 0
  # 1. Snapshots older than 30 days → delete
  find . -maxdepth 1 -type f -name 'compact-*.jsonl' -mtime +30 -exec rm -f {} + 2>/dev/null || true
  # 2. Directory total >200MB → delete oldest snapshots until under the cap
  _MAX_KB=$((200 * 1024))
  _total=$(du -sk . 2>/dev/null | awk '{print $1}')
  if [ -n "$_total" ] && [ "$_total" -gt "$_MAX_KB" ] 2>/dev/null; then
    ls -1tr compact-*.jsonl 2>/dev/null | while IFS= read -r _old; do
      [ -n "$_old" ] && rm -f "$_old" 2>/dev/null || true
      _total=$(du -sk . 2>/dev/null | awk '{print $1}')
      [ -n "$_total" ] || break
      [ "$_total" -gt "$_MAX_KB" ] 2>/dev/null || break
    done
  fi
  # 3. Audit log safety trim: >1MB → keep newest 1000 lines
  if [ -f "$AUDIT" ]; then
    _bytes=$(wc -c < "$AUDIT" 2>/dev/null | tr -d ' ')
    if [ -n "$_bytes" ] && [ "$_bytes" -gt 1048576 ] 2>/dev/null; then
      tail -n 1000 "$AUDIT" > "${AUDIT}.tmp" 2>/dev/null && mv "${AUDIT}.tmp" "$AUDIT" 2>/dev/null || true
    fi
  fi
) || true

# ------- Stdout summary (best-effort; HINT file is the primary channel) -------
cat <<EOF
[PRE-COMPACT SNAPSHOT] trigger=$TRIGGER session=$SHORT_ID
Transcript snapshot: $SNAPSHOT ($SIZE lines)
Audit log: $AUDIT
Hint file: $HINT
Inbox rescued: $UNFINISHED_COUNT unfinished tasks → $HANDOFF
---
POST-COMPACT: read $HINT and follow workflow.md § Surviving Compaction.
EOF

exit 0
