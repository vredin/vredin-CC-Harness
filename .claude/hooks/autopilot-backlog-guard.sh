#!/usr/bin/env bash
# Stop hook — AUTOPILOT backlog guard (PROTOTYPE, osint).
#
# Problem it solves: Claude Code is turn-based — a turn ends when the model stops
# calling tools and writes a checkpoint. After 3-4 tasks the model naturally stops
# and waits for a human. bypass-permissions removes PERMISSION stops but not
# TURN-END stops; /goal and /orchestrate are soft loops the model exits anyway.
# This hook is the DETERMINISTIC "keep going while there is work" driver.
#
# Mechanism: on every Stop attempt, if autopilot is ON (flag file present) and the
# agent has NOT declared done/blocked via a sentinel, return exit 2 to force the
# model to continue with the next task. Circuit breaker caps consecutive forced
# continues so a spin can never burn tokens without bound.
#
# Opt-in:   active ONLY when .claude/autopilot.flag exists (touch to start, rm to stop).
# Stop when: agent's last message contains `AUTOPILOT-DONE:` or `AUTOPILOT-BLOCKED:`,
#            OR the continue-cap (AUTOPILOT_CAP, default 25) is reached.
# Fail-open: any error/uncertainty → exit 0 (allow stop). Never trap due to a bug.
#
# Must be the LAST Stop hook in settings.json (exit 2 short-circuits later hooks).

set -uo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
FLAG="$GIT_ROOT/.claude/autopilot.flag"
[ -f "$FLAG" ] || exit 0                      # opt-in: no flag → normal stop behavior

CAP=${AUTOPILOT_CAP:-25}
CNT_FILE="$GIT_ROOT/.claude/session-log/autopilot-continues.count"
mkdir -p "$(dirname "$CNT_FILE")" 2>/dev/null || true

STDIN_JSON=$(cat 2>/dev/null || echo '')

# --- last assistant text from the transcript (Stop payload carries transcript_path) ---
LAST_TEXT=$(printf '%s' "$STDIN_JSON" | python3 -c '
import json,sys
try: d=json.load(sys.stdin)
except Exception: print(""); sys.exit(0)
tp=d.get("transcript_path") or ""
last=""
try:
    with open(tp) as f:
        for line in f:
            line=line.strip()
            if not line: continue
            try: o=json.loads(line)
            except Exception: continue
            m=o.get("message") or {}
            if m.get("role")=="assistant":
                c=m.get("content")
                if isinstance(c,str): last=c
                elif isinstance(c,list):
                    t="".join(b.get("text","") for b in c if isinstance(b,dict) and b.get("type")=="text")
                    if t: last=t
except Exception:
    pass
print(last[-2000:])
' 2>/dev/null || echo "")

# --- sentinel: agent declared done/blocked → allow stop, end the autopilot run ---
if printf '%s' "$LAST_TEXT" | grep -qE 'AUTOPILOT-(DONE|BLOCKED)'; then
  rm -f "$FLAG" "$CNT_FILE" 2>/dev/null || true
  echo "[AUTOPILOT] done/blocked sentinel found → stopping, autopilot flag cleared." >&2
  exit 0
fi

# --- circuit breaker: reset the counter when the flag is newer than the counter (fresh run) ---
if [ ! -f "$CNT_FILE" ] || [ "$FLAG" -nt "$CNT_FILE" ]; then
  echo 0 > "$CNT_FILE" 2>/dev/null || true
fi
CNT=$(cat "$CNT_FILE" 2>/dev/null || echo 0); CNT=${CNT:-0}
case "$CNT" in ''|*[!0-9]*) CNT=0;; esac

if [ "$CNT" -ge "$CAP" ]; then
  echo "[AUTOPILOT] continue-cap ($CAP) reached with no DONE/BLOCKED sentinel — pausing to avoid runaway. Re-touch .claude/autopilot.flag to resume." >&2
  exit 0
fi
CNT=$((CNT+1)); echo "$CNT" > "$CNT_FILE" 2>/dev/null || true

# --- force continuation ---
cat >&2 <<EOF
[AUTOPILOT active — forced continue $CNT/$CAP] Do NOT stop here.
Pick the next open task from docs/TASK.md and execute it through the full project
workflow (spec → tests → implement → verify → commit → deploy per the project rules).
You may stop ONLY by writing one of these on its own line:
  AUTOPILOT-DONE: <one-line summary>          — when docs/TASK.md backlog is genuinely empty
  AUTOPILOT-BLOCKED: <exactly what you need>   — real blocker only
A real blocker = missing secret (credential-halt), a Diablo BLOCKED/FIX-FIRST verdict, a
destructive op needing approval, or a decision only the owner can make. Do NOT fake progress
to escape the loop, and do NOT emit DONE while open tasks remain.
EOF
exit 2
