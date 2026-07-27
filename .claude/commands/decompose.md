---
name: decompose
description: 'Decompose a PRD or external requirements doc into Architecture (ADRs) → Epics → Tasks via 4 Diablo gates. Output: docs/adr/, docs/epics/, docs/specs/T-NNN-*. Use AFTER /intent or with external requirements doc.'
argument-hint: <PRD-NNN | path-to-requirements-doc>
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion, Glob, Grep
model: opus
---

> **Style:** Load `caveman-distillate` skill — terse, evidence-first.

# /decompose — PRD → Architecture → Epics → Tasks

Input: **$ARGUMENTS** (one of):
- `PRD-NNN` reference (must exist in `docs/prd/`)
- Path to external requirements doc (`.md` / `.pdf` / `.docx`)
- `inline:<paste>` for quick input

**Insight from BMAD v6**: «Epics created AFTER architecture, not before.» Tech choices affect work breakdown. So the order is: PRD → ADRs → Epics → Tasks. Skipping the architecture step produces epics that don't align with chosen tech.

This command runs **4 Diablo gates**: PRD review (skip if from /intent — already gated) → Architecture → Epics → Tasks. Each gate must pass before next phase.

---

## STEP 0 — Resolve input

```bash
ARG="$ARGUMENTS"
case "$ARG" in
  PRD-*)            INPUT="docs/prd/${ARG}-*.md" ;;
  inline:*)         echo "${ARG#inline:}" > "/tmp/decompose-input-$$.md"; INPUT="/tmp/decompose-input-$$.md" ;;
  *.md|*.pdf|*.docx) INPUT="$ARG" ;;
  *)                echo "FAIL: unrecognized input — expected PRD-NNN, file path, or inline:..."; exit 1 ;;
esac
```

If PDF or DOCX: convert to markdown via existing tooling or ask user to provide markdown version.

## STEP 1 — Read input + load skills

1. Read `$INPUT` fully — never excerpt
2. Load skills: `spec-normalizer`, `decision-matrix`, `verification-pass`, `humanizer`, `improve-codebase-architecture`, `planning`
3. Load agent: Diablo

If input is external (not PRD-NNN), normalize it via `spec-normalizer` into PRD format first → save as `docs/prd/PRD-NNN-<slug>.md` → run Diablo gate ZERO on it before proceeding. Skip if input was already a PRD-NNN.

## STEP 2 — Outline read-before-start

```
mcp__outline__list_documents
  query: "<keywords from PRD>"
  collectionId: <project_collection_id>
  limit: 10
```

Look for:
- Existing ADRs (Decisions sub-page) — what tech was already chosen?
- Existing Epics — overlap with this PRD?
- Existing Tasks (T-NNN) — already addressed parts?

If overlap found → ask user: «PRD overlaps with existing X. Decompose only delta, or replace?»

## STEP 2.5 — Generate T-000-scaffold.md (project-level SSOT — ITEM 1)

Goal: one project-level artifact containing Secrets List + Deploy Plan + Test Strategy. Per-task specs REFERENCE T-000 by section, never duplicate. Replaces what used to be per-task `§5 Secrets / §6 Deploy / §7 Tests` (rejected as FATAL SSOT violation in self-audit 2026-05-29 ITEM C).

Generate `docs/specs/T-000-scaffold.md`:

```markdown
---
id: T-000
title: Project Scaffold — Secrets / Deploy / Tests
status: live
type: scaffold
---

## §1 Secrets List
Each entry: env_var_name → service → acquisition_url (where user gets the value).
Schema enforced by S1 surgery — pure key references, NOT values.

| env_var | service | acquire_from | required_by |
|---|---|---|---|
| MONOBANK_TOKEN | monobank | https://api.monobank.ua/personal/auth | T-007, T-008 |
| ... | ... | ... | ... |

Generation rule: scan PRD + ADRs for external service mentions. Lookup canonical env var name from `docs/rules-references/service-secrets.md`. If service not in lookup → add a TODO row with `acquire_from: TODO — extend service-secrets.md`.

## §2 Deploy Plan
Reference to docs/STACK.md fields. NEVER inline values (S1 surgery — pre-commit hook blocks IPs/hostnames/paths in this section if they also live in STACK.md).

| stack_md_field | purpose |
|---|---|
| ssh_alias | SSH target |
| deploy_runtime | docker-compose/systemd/pm2 |
| deploy_branch | git branch to pull |
| deploy_services | service list to (re)start |
| health_endpoint | post-deploy smoke check URL |

Refer to `/deploy` skill for execution. T-000 §2 is the ROSTER of fields, not the values.

## §3 Test Strategy
Layer split with concrete commands:
- **Unit**: `lint_cmd`+`typecheck_cmd` from STACK.md; pytest scoped to `tests/unit/`
- **Integration**: `tests/integration/` against real DB (docker compose up postgres redis)
- **E2E**: Playwright scoped to PRD §5.5 User Journey happy paths (one .spec.ts per journey)
- Coverage targets: per PRD §5.6 (which is mandatory at /intent stage)
```

After T-000 commit + auto-publish to Outline `Project: <name> / Architecture`.

## STEP 3 — Architecture (ADR generation) ← Diablo gate 1

Goal: identify 3-7 architectural decisions this PRD requires.

For each major design choice (DB, framework, auth, deploy, integrations, observability):

1. Check `docs/adr/` for existing decision — if exists and applicable → reuse, link from new ADRs
2. If no existing decision → propose 2-3 options via `decision-matrix` skill format
3. User picks one (AskUserQuestion)
4. Render `docs/adr/<NNNN>-<slug>.md` per existing template

**Diablo gate 1**:
Invoke `/da plan` against the full set of new ADRs.
Diablo attacks:
- Hidden decision NOT made — what didn't you choose because you didn't notice?
- Decisions that conflict with existing ADRs?
- Decisions made without alternatives considered?
- Decisions implying tooling/infra not in `docs/STACK.md`?

**Gate 1 sub-step — T-000 derivability mechanical check (ITEM 5, S2 surgery — NOT Diablo judgment):**

```bash
# Verify T-000 §1 can be derived non-empty (or PRD explicitly declares "secrets: none")
grep -ciE 'api|key|token|secret|credential' docs/prd/PRD-*.md | tail -1 | awk -F: '{exit ($2==0)?0:1}' \
  || grep -ciE 'secrets[[:space:]]*:[[:space:]]*none' docs/prd/PRD-*.md > /dev/null \
  || { echo "Gate 1 sub-check: PRD mentions API/key/token/secret but T-000 §1 will be empty. Either populate PRD §5.5 with the consumer service flows OR declare 'secrets: none' explicitly."; exit 1; }

# Verify §2 deploy fields will resolve from STACK.md (or are explicitly TBD)
for field in ssh_alias deploy_runtime deploy_path; do
  grep -qE "^${field}:" docs/STACK.md || echo "WARNING: STACK.md missing $field — T-000 §2 will have unresolved reference"
done
```

If sub-step fails → Diablo verdict downgrades to BLOCKED regardless of architectural quality.

`BLOCKED` → user resolves, re-run gate. Loop until `ACCEPTABLE` / `PROCEED CAUTION`.

After gate: commit each ADR + auto-publish to Outline `Project: <name> / Decisions`.

## STEP 3.5 — UJ-content trigger for T-001 design exploration (ITEM 3 — S5 HARD/SOFT split surgery)

Read PRD `## 5.5 User Journey` content.

**HARD triggers (inject T-001 design exploration as BLOCKED-awaiting-user):**
- URL paths: `/dashboard`, `/login`, `/<route>`
- HTML element nouns: button, form, modal, table, chart, dropdown, navbar, sidebar
- Bot UI primitives: "inline keyboard", "inline button", "callback button"

**SOFT triggers (warn + ASK user via AskUserQuestion):**
- PDF output, email rendering, notification screens — may or may not need design exploration

**No injection (zero false positive):**
- §UJ empty (per ITEM 4 it's mandatory; if empty Diablo blocked at /intent — should not occur here)
- §UJ contains only API/CLI mentions: `curl`, `/api/`, terminal command, cron, daemon

If HARD trigger fires:
```bash
# Inject T-001 as first task — /orchestrate refuses T-002+ until design-system/MASTER.md exists
cat > docs/specs/T-001-design-exploration.md <<EOF
---
id: T-001
title: Design exploration via /ui-explore
status: blocked
blocking_reason: AWAITING_USER — run /ui-explore <product-name>, pick variant, commit design-system/MASTER.md
---

## Description
Project has user-facing UI per PRD §5.5. Before any feature task can be implemented,
design exploration must produce design-system/MASTER.md. This task is auto-injected
by /decompose STEP 3.5 to prevent the "винегрет" failure (Mono_Dashboard 2026-05).

## Acceptance Criteria
- [ ] /ui-explore run with 3 mockup variants
- [ ] User picked variant via /da review
- [ ] design-system/MASTER.md committed to repo
- [ ] T-001 status updated to done

## Technical Notes
Does NOT auto-run /ui-explore. User invokes manually. /orchestrate STEP 0 refuses to
proceed to T-002+ until design-system/MASTER.md exists on disk.
EOF
```

## STEP 4 — Epic decomposition ← Diablo gate 2

Goal: split PRD work into 3-7 logical epic groups.

Heuristic for splitting (BMAD-inspired):
- One epic per major architectural slice (e.g. «Auth», «Data ingestion», «Reporting»)
- Each epic should deliverable ≥1 user story end-to-end
- Epics MUST be orderable — there should exist a dependency DAG between them

For each epic, propose:
- Title (1 line)
- Goal (1-2 sentences)
- User stories included (refs to PRD §5)
- Acceptance criteria (refs to PRD §6)
- Architectural ADRs constraining it (refs to STEP 3)
- Estimated tasks count (broad: 2-3 / 4-7 / 8+)
- Prerequisites: which other epics must complete first

Show user the proposed split with a dependency diagram (text):
```
EPIC-001: Auth foundation
EPIC-002: Data ingestion          (deps: 001)
EPIC-003: Dashboard               (deps: 001, 002)
EPIC-004: LLM-powered analysis    (deps: 002)
```

User confirms / refines.

**Diablo gate 2**:
Invoke `/da plan` against the epic split.
Diablo attacks:
- Epic missing — what work isn't covered by any epic?
- Epic overlap — two epics doing same thing?
- Wrong sequencing — does dep order respect technical reality (DB before API before UI)?
- Epic too big (≥10 tasks predicted) — should be split further?
- Epic too small (1 task) — should be inlined into adjacent epic?

`BLOCKED` → user resolves, re-run gate.

After gate: render `docs/epics/EPIC-NNN-<slug>.md` per epic, commit, auto-publish.

## STEP 5 — Task decomposition (per epic) ← Diablo gate 3

For each epic, generate ordered task list with deps.

For each task:
- Title + slug
- Parent epic (`parent_epic: EPIC-NNN`)
- Acceptance criteria (subset of epic's AC)
- Dependencies (`depends_on: [T-NNN, T-NNN]`)
- Estimated effort (S/M/L/XL — tshirt sizes; not hours)
- Risk level (Low/Med/High → routes to `/todo add` BQC matrix)

Spec format: same as `/todo add` produces, with extra `parent_epic` field.

Show user task list per epic. User confirms / refines.

**Diablo gate 3**:
Invoke `/da spec` against the FULL task set (cross-epic).
Diablo attacks:
- Missing prerequisite tasks (DB schema before queries; auth before protected routes)
- Hidden cross-epic deps (task in epic B implicitly needs task in epic A)
- Tasks that are actually multiple tasks
- Tasks with vague AC («works correctly» banned)
- Tasks duplicating prior closed T-NNN — not new work

`BLOCKED` → user resolves, re-run gate.

After gate: render `docs/specs/T-NNN-<slug>.md` per task with `parent_epic` field, append to TASK.md backlog in dependency order, optionally `gh issue create` per task.

**MANDATORY frontmatter in every rendered spec** (the todo-diablo-gate hook blocks TASK.md registration without it):
- `size: S|M|L`
- `step_5_diablo:` — EXACTLY one of these formats, no invented variants:
  - S/M → `skipped:size-triage-SMALL` / `skipped:size-triage-MEDIUM`
  - L → the REAL gate-3 verdict: `ACCEPTABLE` or `PROCEED_CAUTION — <note>` (trailing note allowed)
  - L that got FIX FIRST and was then resolved → `ACCEPTABLE (was FIX FIRST, resolved: <what>)` — NOT "FIX_FIRST_RESOLVED", NOT "reviewed:...", no custom prefixes
  - T-000 scaffold / blocked placeholders → `skipped:decompose-batch-gates-<date>`
  - Verdict still FIX FIRST or BLOCKED → the task does NOT enter TASK.md until resolved.

## STEP 5.5 — Traceability matrix ← HARD GATE (no unmapped requirement)

> Tanchiki lesson: PRD promised sound, mouse, lives/score, leaderboard UI — each evaporated
> at a different stage, and no review could see it because nothing mapped PRD lines to tasks.
> The matrix makes every loss explicit and reviewable.

Build `docs/prd/PRD-NNN-trace.md`:

1. **Split composite PRD lines into atomic requirements.** «настройки: управление/звук» is TWO
   requirements (controls, sound); «счёт/рекорд, жизни, уровень» is THREE+. Assign each an
   R-id (`PRD-R-NN`) at THIS granularity — composite lines are exactly where features die.
2. One table row per atomic requirement:

```markdown
| R-id | PRD § | Requirement (human words) | EPIC | T-NNN | Status |
|---|---|---|---|---|---|
| PRD-R-01 | §5.6 | Sound on/off in settings | EPIC-004 | T-033 | mapped |
| PRD-R-02 | §5.2 | Mouse input on desktop | — | — | post-MVP: owner 2026-07-… |
| PRD-R-03 | §7   | Real-place maps | EPIC-006 | dropped: superseded by ADR-0009 |
```

3. Allowed Status values: `mapped` (has a live T-NNN), `post-MVP: <who/when decided>`,
   `dropped: <reason + ADR/decision ref>`. **Nothing else. Blank is not a status.**
4. **GATE (deterministic, no Diablo needed):** any requirement with no row, or a row with
   blank Status → STOP. Fix the mapping (create the missing task via the task list, or get
   an explicit post-MVP/dropped decision from the user) before STEP 6.
5. The matrix is a living SSOT: `/orchestrate` updates Status on archive; scope pivots update
   rows (see workflow.md § PRD Traceability Protocol); `/gaps vs-prd` audits against it.

## STEP 6 — verification-pass + humanizer

Load `verification-pass`. Re-verify all claims in:
- Each new ADR
- Each new EPIC
- Each new T-NNN spec

Catch any product/number claims that snuck through Diablo. Tag `[verified]` / `[unverified]` / `[contradicted]`. If contradicted → STOP, fix.

Load `humanizer`. Apply to all generated docs (ADRs, EPICs, T-NNN specs). Removes AI-text patterns. Once.

## STEP 7 — Commit batch

Single batch commit:
```bash
git add docs/prd/PRD-NNN-*.md \
        docs/adr/<new-ADRs>.md \
        docs/epics/EPIC-*.md \
        docs/specs/T-*.md \
        docs/TASK.md

git commit -m "[CHANGE] PRD-NNN decomposed: <N> ADRs, <M> epics, <K> tasks

PRD: <PRD-NNN>
Architecture: <list of new ADR-NNN>
Epics: <list of EPIC-NNN>
Tasks: <K total, breakdown per epic>

Diablo gates passed: 4 (PRD/ADR/Epic/Task)
Verification: <N verified, M unverified flagged>
Sources: <K external>"
```

## STEP 8 — Auto-publish to Outline

Per `.claude/.setup.json` flags:
- PRD updated → Outline `Project: <name> / PRDs / PRD-NNN`
- Each new ADR → `Project: <name> / Decisions`
- Each new EPIC → `Project: <name> / Epics`
- Tasks remain LOCAL (T-NNN specs in repo only — not noisy in Outline)

## STEP 9 — Confirm

```
✓ PRD-NNN decomposed
ADRs: <list> (Outline: Project / Decisions)
Epics: <list> (Outline: Project / Epics)
Tasks: <count> (TASK.md backlog, local only)

Next:
  /orchestrate           ← starts executing tasks in dependency order
```

---

## Hard rules

- 4 Diablo gates are MANDATORY. Skipping = decomposition that surprises during implementation.
- NEVER create epics without ADRs (BMAD v6 ordering)
- NEVER create tasks without parent_epic
- NEVER skip the dependency DAG check — orchestrator relies on it
- Tasks remain LOCAL by design — they churn too fast to mirror in Outline; ADRs and Epics are stable enough
- `verification-pass` is mandatory — catches what Diablo missed (different angle)
- If user can't answer architectural question → STOP, don't pick at random; ADR with «TBD» blocks downstream
