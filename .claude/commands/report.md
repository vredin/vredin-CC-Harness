---
name: report
description: 'Daily progress report — what was done, what is in progress, what is blocked. Posts to Outline + saves locally. Designed for /loop daily.'
argument-hint: [today | yesterday | YYYY-MM-DD]
allowed-tools: Read, Write, Bash
model: sonnet
---

> **Style:** Load `caveman-distillate` skill — terse responses.

# /report — Daily Status

Period: `${ARGUMENTS:-today}` (default: today)

---

## STEP 1 — Determine period and resolve project

```bash
case "${ARGUMENTS:-today}" in
  today)     SINCE=$(date -v0H -v0M -v0S +%Y-%m-%d) ;;
  yesterday) SINCE=$(date -v-1d -v0H +%Y-%m-%d); UNTIL=$(date -v0H +%Y-%m-%d) ;;
  *)         SINCE="$ARGUMENTS" ;;
esac
PROJECT=$(basename "$(pwd)")
```

---

## STEP 2 — Gather data

| Source | Command | Purpose |
|---|---|---|
| Git activity | `git log --since=$SINCE --pretty='%h %s' --no-merges` | Commits this period |
| Files changed | `git log --since=$SINCE --name-only --pretty='' \| sort -u` | Touched files |
| Closed tasks | `grep '$SINCE' docs/archive/TASK_ARCHIVE.md` | T-NNN done |
| In progress | `awk '/## In Progress/,/##/' docs/TASK.md` | Active tasks |
| New fails | search Outline `Knowledge Base / Fails` for docs created since $SINCE with project tag | What broke |
| Last report | search Outline `Knowledge Base / Daily Status` for `<project>` last entry | Delta basis |

If git log is empty AND no TASK movements AND no new fails → output `No activity for $PROJECT on $SINCE` and STOP. Do not publish empty reports.

---

## STEP 3 — Compose report

Template:
```markdown
# Daily Report — <PROJECT> — <DATE>

## Done (<N> commits)
- T-NNN: <title> — <one-line outcome> [<commit_sha>]
- T-NNN: <title> — <one-line outcome> [<commit_sha>]

## In Progress
- T-NNN: <title> — <state in one sentence>

## Blocked / Needs decision
- <blocker> — needs <user input | external | architectural call>

## Learned this session
- F-NNN: <fail title> (link to Outline)
- <new pattern observed, if non-trivial>

## Tomorrow / Next session
- T-NNN, T-NNN  
- <or: "no specific plan, /todo list to choose">

## Metrics
- Files touched: <N>
- Tests added: <N>
- LOC delta: +<N> -<N>
```

**Rules for composition:**
- One bullet per task. No prose paragraphs.
- "Done" = commit landed AND tests pass. If commit landed but tests broken → put it in "Blocked".
- "Tomorrow" must reference task IDs or say "no plan". Vague aspirations are banned.
- If an entry has no useful content, omit the section entirely (no "—" placeholders).

---

## STEP 3.5 — humanizer pass (mandatory before persist)

Daily reports are **read by humans** (you in the morning, team if shared).
Apply `humanizer` skill to the assembled report:
- Removes em-dash overuse, "delve", "tapestry", "pivotal" patterns
- Strips sycophantic openers
- Prevents AI-prose-soup that makes daily logs unreadable
- Keeps facts intact — only prose style changes

Pass the report draft through `humanizer` skill ONCE before STEP 4.

---

## STEP 4 — Persist

### Local
Write to `docs/reports/<DATE>.md` (append `-2`, `-3` if multiple reports per day).

### Shared Knowledge Base (auto, no prompt)

Read `.claude/.setup.json` → `outline.auto_publish.daily_status_to_shared`.
If `false`, or the backend is unreachable → skip the remote write; local report still saved.

If `true` (default):
1. Resolve backend per `docs/OUTLINE-CONTRACT.md` § Backend.
2. Search `Knowledge Base / Daily Status` (category `daily-status` in github mode) for an
   existing entry titled/filed `<PROJECT> — <DATE>`.
3. If exists → update it with the full new body. If not → create it.
4. Capture returned URL (cloud) or `bin/github-kb.sh` OK line (github).

This goes to **Shared** Daily Status, NOT the project's own docs — daily status is a single
cross-project timeline, not a project-specific archive.

---

## STEP 5 — Confirm

```
✅ Daily report — <PROJECT> — <DATE>
Local: docs/reports/<DATE>.md
KB:    <url, or "skipped">
N commits, M tasks done, K blocked
```

---

## Designed for /loop

```bash
# Set up via /loop skill (one-time per machine):
/loop "0 18 * * *" /report

# This fires at 18:00 daily and runs /report autonomously.
# Empty days produce no output (STEP 2 short-circuit).
```

## Rules

- NEVER fabricate task titles or outcomes — read from TASK.md / TASK_ARCHIVE.md / commit messages
- If git history is too noisy (>50 commits in period) — refuse and ask user to narrow period
- PII in commit messages → DO NOT publish to Outline; ask user to redact first
- Daily Status entries are ephemeral — pruning policy in /docs sync (older than 90 days → archive)
