# Read-Only Fan-Out — parallel Workflow for safe phases

> SSOT for the OPT-IN parallel fan-out hooks injected into `/todo`, `/fix`, `/orchestrate`.
> Read this when a command's read-only phase (research / doc-reading / prior-knowledge search /
> test-writing / audit) spans several independent units and you consider parallelizing it.

---

## Why read-only only

The Workflow tool (`parallel` / `pipeline`) fans work out to leaf subagents with clean isolated
context. The hard danger with fan-out is **shared mutable target**: two agents writing into the
same codebase share that codebase's schema as an implicit source of truth, so blind parallel
writes diverge or conflict (see `workflow-planner/reference/applicability.md` § shared mutable target).

Read-only work has NO shared-mutable-target problem:
- Reading docs / code / KB / runtime errors — agents only read; no conflict possible.
- Auditing — pure read.
- Writing tests — SAFE ONLY with a phase-0 anchor that assigns each agent a DISTINCT file path.
  **Trap:** spec scenarios are NOT files. In pytest several `test_*` functions for one feature live
  in ONE file (`tests/test_auth.py`); blind agents told "write tests for scenario X / Y" each derive
  the same filename → last-write-wins clobber. So never fan out *per scenario* — fan out *per file*,
  with the exact path fixed in each prompt. See "Test-writing fan-out" below.

So fan-out is SAFE here without `isolation:'worktree'`. The write phases (implement, fix-the-bug,
migrate) stay sequential — those keep the TDD ceremony and the shared-target discipline.

---

## The gate (when to fan out — ALL must hold)

1. **3+ independent units.** Three or more same-type read-only chunks (sources, files, subsystems,
   audit dimensions). 1-2 units → run serially, fan-out overhead is not worth it.
2. **Genuinely independent.** Apply the divergence test from `applicability.md`: *"if launched blind in
   parallel, would facts diverge between chunks?"* If the chunks cite a shared source not yet fixed —
   either fix the source first (phase-0 anchor) or run serial.
3. **Read-only or isolated-write.** Reads, or each agent writes a distinct file. No two agents write
   the same file. No worktree needed.
4. **Volume justifies background overhead.** A workflow runs in the background and costs tokens.
   For TRIVIAL/SMALL work, serial is cheaper and clearer.

If any fails → run the phase serially as written. Do NOT fan out.

---

## Opt-in — never mandatory

The Workflow tool is expensive and **requires explicit user opt-in** (per its own contract and the
project's cost-aware rule: subagents cost 7-10x, see `skill-routing.md` § Cost-Aware Agent Usage).

Opt-in works differently for interactive vs autonomous commands:

- **`/todo`, `/fix` (interactive) → OFFER and wait.** Mid-flow, present the offer and proceed serially
  unless the user says yes:
  ```
  This read-only phase has N independent units (<list>). I can fan them out via the
  Workflow tool (read-only, no write conflict) — roughly <est> faster, costs tokens.
  Run as workflow? Otherwise I proceed serially.
  ```
- **`/orchestrate` (autonomous) → PRE-AUTHORIZED flag, no mid-run prompt.** It runs unattended to the
  end (principle 6, UNSTOPPABLE BACKLOG); a blocking offer would deadlock. Fan-out fires only if the
  user passed `/orchestrate --fanout` before the run. No flag → serial, no prompt.

Proceed serially unless opted in (offer accepted, or flag pre-set). Never silently spawn a background
workflow.

---

## How to build it

When the user opts in:

1. Load skill `.claude/skills/workflow-planner/` — it owns the applicability gate, the primitives
   reference, and plan→script translation.
2. Express the phase as:
   - **Independent searches/reads → one `parallel` barrier** when the next step needs all results
     at once (merge / decide). Each branch gets its query/target in the prompt (agents are blind).
   - **Stream of items through stages → `pipeline`** (default) when each unit flows on its own
     (e.g. write-test-file-then-self-check, one distinct file per item — see test-writing rules).
3. `.filter(Boolean)` collections after the barrier; if fewer than expected survived, degrade
   explicitly (tell the user the result is partial) — never glue `null` into the next prompt.
4. No `isolation:'worktree'` for pure reads. Only test-writing to distinct files — still no worktree
   (different files don't conflict).

---

## Per-command fan-out points (the injected hooks)

| Command | Phase | Units to fan out | Primitive |
|---|---|---|---|
| `/todo` | STEP 2.5 prior-knowledge | Outline shared KB / Outline project / local grep — 3 independent searches | `parallel` → merge |
| `/todo` | STEP 3 research | 3+ independent subsystems/files to understand | `parallel` → synthesize |
| `/fix` | STEP 0.5 prior-knowledge | Outline / FAILS+PATTERNS grep / GlitchTip — 3 independent lookups | `parallel` → decide |
| `/fix` | STEP 4 root cause | 3+ independent call-paths each analyzable standalone | `parallel` → compare |
| `/orchestrate` | spec-check research | 3+ subsystems to read before implementing | `parallel` → synthesize |
| `/orchestrate` | test-writing | one agent per distinct test FILE (path fixed in prompt) — see below | `pipeline` (write + self-check) |
| `/orchestrate` | backlog audit | independent audit dimensions / areas | `parallel` → merge gaps |

Write phases (`/fix` STEP 5/6.5 the actual fix, `/orchestrate` STEP 3 implement) are NOT here —
they stay sequential.

### Test-writing fan-out — extra rules (collision-safe)

Only fan out test-writing when there are 3+ DISTINCT target files. Then:
1. **Phase-0 anchor** (one agent, sequential): map scenarios → files, produce the exact file-path
   list + the conftest/fixture inventory + existing-test style notes. This is the shared source.
2. **Fan-out** (`pipeline`): one agent per file. Each prompt carries (a) its EXACT file path, (b) the
   fixture inventory + style notes from phase 0, (c) only the scenarios assigned to that file.
3. Prefer `opts.agentType: 'test-writer'` so technique-mapping is preserved (requires the role
   registered at session start). Without it, the phase-0 inventory in the prompt is mandatory —
   blind default agents otherwise duplicate fixtures and mismatch import paths.

If scenarios don't split cleanly into 3+ files → run the `test-writer` agent serially. Do not fan out.

---

## Anti-rules

- **Never make the offer mandatory.** Serial is the default; fan-out is opt-in.
- **Never fan out writes to a shared file.** That is the shared-mutable-target trap — keep serial.
- **Never fan out 1-2 units.** Below the 3+ threshold the overhead loses.
- **Never skip the divergence test** for "make several artifacts citing one source" — anchor first.
- **Never invent Workflow primitives.** Only `agent / parallel / pipeline / phase / log` exist
  (see `workflow-planner/reference/workflow-primitives.md` § Fabrications).
