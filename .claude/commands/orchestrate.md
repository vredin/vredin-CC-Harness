---
name: orchestrate
description: 'Run the task orchestrator — executes backlog tasks one by one using the full dev workflow. Usage: /orchestrate [T-NNN]'
---

> **Style:** Load `caveman-distillate` skill — terse responses, no filler, fragments OK.

Use the orchestrator agent to execute tasks from `docs/TASK.md`.

Arguments: $ARGUMENTS

If arguments specify a task ID (e.g. `T-009`) — start with that task.
Otherwise — start with the first In Progress task, or the first Backlog task if nothing is in progress.

**Flag `--fanout`** (optional, pre-authorization for read-only parallelism): if present in arguments,
the autonomous run MAY fan out its read-only phases (spec-check research, test-writing, backlog audit)
via the Workflow tool when 3+ independent units exist. Without the flag → every phase runs serially.
The flag is granted ONCE up front (cost confirmation) — orchestrate NEVER prompts mid-run for fan-out
(would deadlock an unattended run). Write phases always stay sequential. See
`.claude/skills/orchestrate/SKILL.md` § Read-Only Fan-Out and `docs/rules-references/readonly-fanout.md`.

---

## Flag `--auto` — background conductor (multi-agent, truly hands-off)

> Solves "I'm tired of typing continue." The normal `/orchestrate` runs in the interactive main loop, so
> the turn ends at a checkpoint and waits for you. `--auto` runs a **background Workflow conductor**
> instead: a deterministic manager loop (Opus at the judgment nodes) that, per backlog task, spawns a
> **worker subagent** which runs the whole task to completion WITHOUT asking you to continue (subagents
> don't turn-end-stop the way the main loop does), then an **Opus reviewer** verifies the diff, the
> conductor commits, and moves to the next — looping until the backlog is empty or a task hits a real
> blocker. It surfaces to you ONCE (at the end, or on a blocker), not every 3-4 tasks.

**When `--auto` is present, do NOT run STEP 0..STEP N below in the main loop.** Instead:

1. **Confirm scope + cost.** State the task cap, the mode, and that it spends Workflow tokens unattended.
   Refuse if a 🔴 backup/restore/ops-safety task is open and unaddressed (Database Protection Protocol —
   the conductor's backlog reader already prioritises those first, but flag it).
2. **Invoke the Workflow tool** with the conductor script:
   ```
   Workflow({ scriptPath: ".claude/workflows/orchestrate-auto.js",
              args: { project: "<abs path to this project>", mode: "write", cap: <N, default 5> } })
   ```
   - `mode: "dry-run"` → READ-ONLY validation: worker produces a plan per task, Opus reviews, no writes.
     Use this the FIRST time on a new project to see the loop work safely.
   - `mode: "write"` → SEQUENTIAL real work: worker writes failing test → implements → green → lint; Opus +
     Diablo review the actual `git diff`; conductor commits. **Never deploys** (run `/deploy` separately).
     Stops the loop on a genuine BLOCKED verdict.
   - `cap` bounds how many tasks one run chews through (token safety). Re-invoke to continue.
3. **Background.** The workflow returns a task id and runs unattended; you get one completion notification.
   Read its returned `{done|reviewed, blocked, note}` and report per-task outcomes + any blocker.

Guardrails baked into the script (`.claude/workflows/orchestrate-auto.js`): 🔴/backup tasks first;
write mode is sequential on the shared tree (no parallel-write conflicts); every task is test-first and
Opus/Diablo-reviewed before commit; **no auto-deploy**; a real blocker stops the loop and surfaces to you.

Contrast with the `autopilot-backlog-guard.sh` Stop-hook (prototype): that forces the SINGLE main agent to
keep going in your interactive session. `--auto` is the multi-agent, background, independently-reviewed
version — higher quality, fully hands-off, costs more. Pick the hook for a live session, `--auto` to
walk away.

---

---

## STEP 0a — Credential-halt prerequisite check (MANDATORY — ITEM 2 from SELF-AUDIT-2026-05-29)

Before any other STEP, run the credential scan:

```bash
bash .claude/hooks/credential-halt.sh
```

Behavior:
- **Greenfield mode** (specs count < 5): soft-warn only, proceeds
- **Mature mode** (specs count ≥ 5): HARD STOP on any missing required env var

**Scope: services of THIS run only, not the whole backlog.** The hook scans every spec; before stopping, check which tasks this run will actually execute (the T-NNN from arguments, or the next unblocked backlog tasks). A missing var used only by tasks OUTSIDE this run → soft-warn, proceed. HARD STOP only when the missing secret is needed by a task in the current run and no unblocked alternative task exists.

If that hard-stop condition holds → STOP. Do NOT proceed to STEP 0. Print the hook output to user. The output lists exact env vars + acquisition URLs. User must update `.env.production` then re-invoke `/orchestrate`.

Override (use sparingly, only for legitimate cases like running orchestrate without external services): `CLAUDE_HOOK_ALLOW_MISSING_SECRETS=1 /orchestrate`

Why this exists: Mono_Dashboard and TelegramFactory orchestrate runs in May 2026 never paused for credentials, produced broken scaffolds that took user days to fix manually. The hook scans `docs/specs/T-NNN-*.md` for external service mentions via `docs/rules-references/service-secrets.md` lookup table (with aliases per S4 Diablo surgery), then verifies each canonical env var has non-empty value in `.env*` files.

## STEP 0b — Design-system gate (if T-001 exists)

If `docs/specs/T-001-design-exploration.md` exists with `status: blocked` (injected by /decompose STEP 3.5 for projects with frontend UI):

```bash
test -f design-system/MASTER.md || { echo "STOP: T-001 design exploration blocking. Run /ui-explore <product>, pick variant, commit design-system/MASTER.md before proceeding."; exit 1; }
```

This prevents the "винегрет" failure mode (Mono_Dashboard: 52 features implemented before unified design system → user manually added T-053+T-054 after the fact).

---

## STEP 0 — Set explicit `/goal` BEFORE starting (MANDATORY)

Per workflow.md § Definition of Done Discipline — orchestrator without explicit completion condition will «keep improving» indefinitely. Set `/goal` derived from the spec's **Section 7 (Success Criteria)** before STEP 1.

<output_format type="orchestrator_goal_setup">
📐 Goal condition for T-NNN:

/goal <measurable condition from spec Section 7 + STACK.md test commands + no-regression constraint>
</output_format>

**Template for the condition:**

```
/goal All Section 7 Success Criteria for T-NNN met AND <lint_cmd from STACK.md> exits 0 AND <test_backend from STACK.md> shows no failed tests for the affected module. No files outside Section 6 (Deliverables) are modified.
```

If spec's Section 7 is vague («works correctly», «no bugs») — STOP. Spec needs a Diablo re-pass to harden Success Criteria before `/orchestrate` can run. Do not invent measurable criteria not in the spec.

If `/goal` not set — orchestrator runs without exit condition and may loop on aesthetic refactors indefinitely. This wastes tokens and time. Do not skip STEP 0.

---
