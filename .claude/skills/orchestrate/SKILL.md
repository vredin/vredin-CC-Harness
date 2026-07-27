---
name: orchestrate
description: "Conductor: autonomous multi-agent pipeline. Picks tasks from backlog, implements, verifies, loops until done or blocked."
argument-hint: "next-task | stabilize | write-tests"
---

# Orchestrate — Conductor Skill

You are the **conductor**. You orchestrate agents and skills as an autonomous pipeline.
The user gives a high-level goal; you break it into steps, delegate, collect results,
decide next action, and loop until done or blocked.

## Core Principles

1. **File-based state** — each step writes output to `artifacts/conductor/`. Next step reads files, not context.
2. **Keep/Discard git loop** — code change + quality gate pass = `[CHANGE]` commit (keep). Gate fail after ONE retry = `git checkout -- .` (discard), mark task BLOCKED, next task.
3. **Append-only log** — every action logged to `artifacts/conductor/session.jsonl`.
4. **Don't stop** — loop until all work is done or you hit a true blocker.
5. **NEVER ask permission** — create todos, run agents, commit autonomously. Only stop if truly blocked (external service down, destructive git op requested, cost confirmation needed).
6. **UNSTOPPABLE BACKLOG RULE** — NEVER stop mid-execution while PLANNED items exist in the backlog. "Seems complex", "needs more info", "might break something" are NOT valid blockers — investigate and solve autonomously. Only stop if the task literally cannot proceed without a human action (missing credentials, physical device offline, money cost).
7. **SUBAGENT COMPLETION ≠ PIPELINE COMPLETION** — when any sub-step (analysis, fix, audit) returns a result, that is a STEP completion, not the pipeline end. Always check: are there PLANNED tasks? If yes → continue. Only stop when backlog is empty AND re-audit finds 0 new gaps.
8. **DA at every implementation** — run Devil's Advocate attack before every `[CHANGE]` commit. BLOCKED verdict = fix before committing.
9. **Questions queue, report at the end** — never ask the user mid-run; accumulate questions (dedup: one cause = one question) and emit them in the final run report. Mid-run output only when a decision changed, never as a pulse. Final report is plain language for a non-engineer owner: done / blocked+why (one line per task) / queued questions.
10. **Blocker level: TASK ≠ RUN** — any per-task blocker (security CRITICAL, ADR conflict, scope exceeded, 2 failed attempts) marks THAT task BLOCKED and moves on. Full stop only: backlog empty, all remaining BLOCKED, context ≥80%, or missing secret for the current task with no alternative.

---

## Read-Only Fan-Out (PRE-AUTHORIZED, autonomous-safe)

Write phases stay sequential (Step 3 IMPLEMENT keeps the shared-mutable-target discipline + TDD).
The **read-only phases** below MAY fan out via the Workflow tool when they span 3+ independent units:

| Phase | Units | Primitive |
|---|---|---|
| Step 2 SPEC CHECK research | 3+ subsystems to read before implementing | `parallel` → synthesize |
| Test-writing | one agent per DISTINCT test FILE (phase-0 anchor fixes paths + fixtures) | `pipeline` (write + self-check) |
| Step 5 / backlog audit | independent audit dimensions or areas | `parallel` → merge gaps |

**Default is SERIAL.** Unlike `/todo` and `/fix` (interactive — they OFFER and wait), `/orchestrate`
runs autonomously to the end (principle 6, UNSTOPPABLE BACKLOG). A mid-run offer that blocks on user
input would deadlock an unattended run. So:

- Fan-out fires ONLY when the user pre-authorized it before the run: `/orchestrate --fanout`.
- Without that flag → run every phase serially. NEVER prompt mid-run for fan-out (would violate
  principle 6: serial is always available, so the task can always proceed).
- The flag is the cost confirmation (principle 5) — granted once, up front, not per phase.

Rules: read-only or isolated-write only, no `isolation:'worktree'` needed; below 3 units run serial;
the actual implement/fix edits are NEVER fanned out; test-writing fan-out requires the per-file
phase-0 anchor (see reference). Full gate + how-to: `docs/rules-references/readonly-fanout.md`;
load `.claude/skills/workflow-planner/` to build the script.

---

## Sub-commands

Parse `$ARGUMENTS` to determine pipeline:

### `/orchestrate next-task`

Pick the highest-priority PLANNED task and execute it end-to-end.

```
Step 1: READ BACKLOG
  Read: docs/TASK.md
  Find: first PLANNED/Backlog task by priority
  If none → run audit (see below) OR report "backlog empty"

Step 2: SPEC CHECK
  Read: docs/specs/T-NNN-slug.md
  Verify AC is clear enough to implement
  If spec unclear: write missing AC, re-check

Step 3: IMPLEMENT
  [BACKUP] commit
  Implement all AC
  Run quality gate (lint + types + tests)
  DA implementation attack
  [CHANGE] commit with DA verdict

Step 4: UPDATE BACKLOG
  Mark task DONE in docs/TASK.md
  Append to docs/archive/TASK_ARCHIVE.md with commit hash
  Append to docs/timeline.md

Step 5: NEXT
  Check docs/TASK.md for more PLANNED items
  If exist → back to Step 1
  If empty → run /audit → continue from new tasks
  Truly done → End of Run: ONE batched push/deploy + prod e2e + final report
  (per-task deploy only with --deploy-each flag)
```

### `/orchestrate stabilize`

Run tests, fix failures, loop until green.

```
Step 1: RUN TESTS
  [adapt command to project stack]
  Output: test results

Step 2: ANALYZE
  Classify failures: logic error / locator drift / state race / infra
  If 0 failures → report green, STOP

Step 3: FIX (per failure, max 2 attempts = one retry)
  [BACKUP] commit
  Apply fix
  Re-run failing test only
  Pass → [CHANGE] commit
  2nd fail → git checkout -- . → mark BLOCKED → continue with next failure

Step 4: RE-RUN ALL → back to Step 1
  Max 5 total loops
```

---

## State Management

### Session log: `artifacts/conductor/session.jsonl`

Append one JSON line per action:
```json
{"ts": "2026-01-01T09:00:00Z", "cmd": "next-task", "step": "implement", "task": "T-042", "result": "done", "commit": "abc123"}
{"ts": "2026-01-01T09:05:00Z", "cmd": "next-task", "step": "implement", "task": "T-043", "result": "blocked", "reason": "missing API key"}
```

### Resume protocol

On start, check `artifacts/conductor/session.jsonl`:
- If exists: read last entry → "Resuming from step {step}" → continue
- If not: fresh start

---

## Error Handling

| Situation | Action |
|-----------|--------|
| Quality gate fails | Log, retry ONCE, then discard + mark BLOCKED, next task |
| Any other step fails | ONE retry → second failure = mark task BLOCKED (one-line reason), next task |
| DA returns BLOCKED | Fix the issue, re-run DA, do not commit |
| Spec missing or unclear | Write missing spec sections, then continue |
| Backlog empty | Run project audit → generate new tasks → continue |
| Context ≥ 80% full | Write `artifacts/conductor/handoff.md`, tell user to restart |
| External service unavailable | Log as infrastructure blocker, move to next task |
| Question for the user arises | Queue it (dedup) for the final report — never pause the run |

---

## What This Skill Does NOT Do

- Does NOT deploy per task — the End-of-Run batched push/deploy is PRE-AUTHORIZED by the user invoking `/orchestrate`; explicit confirmation is required only for destructive ops on shared resources (DB drops, force push, prod data deletion)
- Does NOT run operations with significant cost (cloud, paid APIs) without confirmation
- Does NOT modify `CLAUDE.md`, rules, or agent definitions
- Does NOT skip DA review before `[CHANGE]` commits
