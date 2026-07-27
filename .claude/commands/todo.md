---
name: todo
description: 'Manage active task list in docs/TASK.md. Usage: /todo [add <text>] [done <id>] [start <id>] [list]'
---

> **Style:** Load `caveman-distillate` skill — terse responses, no filler, fragments OK.

Manage the active task list in `docs/TASK.md`.

Arguments: $ARGUMENTS

> **Naming convention (see CLAUDE.md § Task ID Discipline):**
> - `IDEA-N` — floating concept, no spec yet. Lives in session-inbox or chat.
> - `T-NNN` — registered task with spec file. Assigned ONLY by `/todo add` after grill-me + Diablo + spec creation.
> - Promotion `IDEA-N → T-NNN`: IDEA number is NOT inherited. T-NNN takes next available number from `docs/specs/` sequence.
> - If you see `T-NNN` referenced anywhere (commit, doc, chat) without `docs/specs/T-NNN-*.md` existing — that's a violation. Hook `.claude/hooks/task-id-validator.sh` blocks commits with such refs.

---

## Actions

### `/todo` or `/todo list`
Read `docs/TASK.md`. For EACH In Progress + Backlog task, show **1–2 plain-language sentences** — NOT the
terse title, NOT a table. The owner is a busy product-owner who doesn't hold tech state; a bare `T-585 —
split charts_charts.py` means nothing to them.

**Per task, produce:**
- **Sentence 1 — the problem / pain** (in human terms: what's broken, missing, or annoying today, and who
  it hurts). 
- **Sentence 2 — what the fix delivers** (what changes / becomes possible when it's done).

**Where the text comes from** (in order): the task's spec `docs/specs/T-NNN-*.md` — `## 1. Overview` +
`## 2. Objectives` + `## 7. Success Criteria` carry the problem and the outcome. No spec → derive from the
TASK.md Task cell. If the spec frontmatter has a `human_summary:` field (written by `/todo add`, below),
use it verbatim.

**Style (HARD — CLAUDE.md § Communication Style):** plain language, no jargon. Never `T-585 — split
charts_charts.py`. Instead: «T-585 — файл с графиками разросся так, что его тяжело менять без риска.
Разбивка на части делает правки безопаснее; 2 из 3 частей готовы, не задеплоено». Keep the priority
grouping the owner already sees. Show the `T-NNN` + risk/status flags, then the two sentences.

Format:
```
Backlog — по приоритету

<risk/priority group heading>:
- **T-NNN** <🔴/status flag if any> — <problem sentence>. <fix-delivers sentence>.
```

---

### `/todo add <description>`

This is NOT a simple append. Follow ALL steps.

**STEP 0 — Size triage (MANDATORY — drives every downstream step)**

Before any other work, classify the task by expected change size. The full ceremony (grill-me + spec + Diablo) costs ~20-30 min. For trivial work it is pure waste. For non-trivial work it prevents catastrophes. The judgment happens HERE, not implicitly later.

<output_format type="todo_size_triage">
📐 Size triage for: <one-line task description>

Best estimate (pick exactly one):
  □ TRIVIAL  (≤10 lines, single file, fix is obvious from problem statement)
  □ SMALL    (≤50 lines, single file, well-defined behavior, no new concepts)
  □ MEDIUM   (50-200 lines, 2-3 files, new behavior or refactor)
  □ LARGE    (200+ lines, new module, or cross-system impact)

Selected: <TRIVIAL | SMALL | MEDIUM | LARGE>
Reasoning: <one line justifying the pick — files affected, complexity signal>

Routing:
  TRIVIAL  → STOP /todo. Re-run as: /quick-plan <task>
              Reason: /todo ceremony costs 20-30 min, adds zero safety on trivial work.
  SMALL    → /todo continues BUT skip STEP 1 (grill) + STEP 4.5 (security review) + STEP 5 (spec-Diablo).
              Keep: STEP 2.5 (prior knowledge), STEP 4 (minimal spec, mandatory-7 sections only).
              Frontmatter: step_5_diablo: skipped:size-triage-SMALL (impl-Diablo catches issues later).
              Test scope: only the directly affected test file/function.
  MEDIUM   → Standard /todo flow EXCEPT STEP 5 (spec-Diablo) — skipped; the implementation-stage
              Diablo (/da impl, auto in /orchestrate STEP 7.5) covers it. Spec = mandatory-7 sections
              (see STEP 4); the rest by need. Frontmatter: step_5_diablo: skipped:size-triage-MEDIUM.
              Test scope: affected module's tests + integration tests touching it.
  LARGE    → Standard /todo flow, ALL STEPs incl. STEP 5 (spec-Diablo), full 13-section spec
              + flag for /review on the implementation PR.
              Test scope: full module test suite.

Skipped steps will be marked in spec frontmatter as `skipped:size-triage-SMALL` (not free skips — Diablo sees the marker and can override).
</output_format>

**Anti-rules for STEP 0:**
- Never default to MEDIUM "just to be safe" — that defeats the point. Be honest about the size.
- Never escalate SMALL → MEDIUM during execution without re-running STEP 0 explicitly (user must approve scope creep).
- If unsure between two adjacent tiers — pick the LOWER one and let later steps reveal if it was wrong (cheaper to escalate than to over-engineer upfront).

If TRIVIAL is selected — output the redirect message and STOP. Do not proceed to STEP 1.
If SMALL — note skipped steps in spec frontmatter `workflow_progress.step_1_grill_me: skipped:size-triage-SMALL`, proceed to STEP 2.5.
If MEDIUM or LARGE — proceed to STEP 1.

---

**STEP 1 — Grill the user (replaces ConfidenceChecker)**

Load skill: `.claude/skills/grill-me/SKILL.md`.

Walk the decision tree for the new task. **Questions in batches of up to 3**, each question with a recommended answer. A second batch only if the answers to the first opened genuinely new ground — otherwise stop asking. Resolve each branch's dependencies before moving to the next.

If a question can be answered by exploring the codebase — explore first, ask only if the codebase doesn't answer.

Stop conditions (any one):
- Shared understanding is reached (no remaining unknowns)
- User says "enough" or "skip the rest"
- 2 batches asked (≈6 questions) without new information surfacing → escalate: "Specs may be premature; consider /general first to investigate."

What to grill:
- Which files/components/screens are affected?
- Current vs expected behavior — quote actual current behavior, not assumed
- Acceptance criteria — measurable, not "works correctly"
- Edge cases not mentioned (empty / null / Unicode / huge / concurrent)
- Failure modes the user hasn't considered
- Dependencies on other tasks, external systems, or in-flight work
- Scope: one task vs split? too narrow? too broad?

**Adversarial interrogation (BA + QA-hacker) — MEDIUM/LARGE:** load
`docs/rules-references/adversarial-interrogation.md` and walk its classes (A–K) against THIS feature
before it is coded: fewer/more/empty/wrong-type params, retry after a dropped connection (idempotency),
the user changing their mind mid-flow (cancellation/rollback), a link/token expiring, flooding with no
rate limit, an object arriving where a scalar was expected. Ask only the classes that apply, batched with
the rest (respect the 3-per-batch limit). Each unresolved question becomes a Section 9 QA-Hacker case or,
if it needs a policy value (link TTL, retry allowed?), a `/rule`. This is the pre-ship half of the oracle;
`/gaps domain` STEP 3.46 is the post-ship half.

**STEP 2.5 — Search prior knowledge BEFORE researching (mandatory)**

Before reading code or external docs, check what's already known. Many tasks
duplicate or contradict prior decisions; surfacing them now is cheaper than
discovering during implementation.

> **Read-only fan-out (OPT-IN, MEDIUM/LARGE only):** the searches below (shared KB / local grep)
> are independent read-only lookups. If all are live, you MAY offer to run them in parallel via
> the Workflow tool (read-only, no worktree). OFFER only — proceed serially unless the user opts
> in. See `docs/rules-references/readonly-fanout.md`; load `.claude/skills/workflow-planner/` to
> build the script.

### Shared Knowledge Base (primary)
Resolve backend per `docs/OUTLINE-CONTRACT.md` § Backend, search Fails + Best Practices for
`<3-5 keywords from task>`.

### Local fallback (only if the shared backend is unreachable)
```bash
grep -lE "<task keywords>" docs/KNOWLEDGE.md docs/PATTERNS.md docs/RULES.md 2>/dev/null
```
Looking for: prior `Best Practices` (validated patterns) + similar `Fails` (gotchas to avoid).

### `docs/adr/` + `docs/RULES.md` — decisions and rules (always local, backend-independent)
```bash
grep -lE "<task keywords>" docs/adr/*.md docs/RULES.md 2>/dev/null
```
Looking for: existing ADRs that constrain implementation, business rules
(R-NNN) that must be respected, prior architecture for this area.

### Decision

**If 1+ ADRs found**: include in spec section 3 (Prerequisites) — "Constrained by ADR-NNN: <decision>". Don't relitigate accepted decisions.

**If 1+ Best Practices found**: include in spec section 5 (Technical Approach) — "Following pattern: <name>; URL: <Outline URL>". Reuse known-good designs.

**If similar Fails found**: include in spec section 8 (BQC Risks) — "Avoid F-NNN: <pattern>". Specific failure modes to design around.

**If 1+ R-NNN business rules found**: include in spec section 8 — "Must respect R-NNN: <rule>". Don't accidentally violate.

**If contradicting prior decision**: flag, ask user explicitly:
> "This task seems to contradict ADR-NNN: <decision>. Are you intentionally overturning it (will require new ADR) or did you not know about it?"

**If nothing found**: proceed to STEP 3 with confidence this is fresh ground.

This costs 1-2 MCP calls (~3 seconds). Saves the "we already decided this" / "this contradicts production assumption" surprise during implementation.

---

**STEP 3 — Research the problem**

Read the relevant code. Understand what exists, what's broken, what constraints apply.
Use Context7 / WebSearch if the task involves external libraries or APIs you're unsure about.

> **Read-only fan-out (OPT-IN, MEDIUM/LARGE):** if understanding the task means reading 3+
> INDEPENDENT subsystems/areas, you MAY offer to fan out the reading via the Workflow tool
> (`parallel` → synthesize; read-only, no worktree). OFFER only. A single coherent file chain
> stays serial. See `docs/rules-references/readonly-fanout.md`.

**STEP 4 — Write a Structured Spec**

Assign T-NNN: find next available number from `docs/specs/` sequence. If task came from an `IDEA-N` reference (session-inbox or chat) — IDEA number is NOT inherited; T-NNN gets a fresh number. Mark the source IDEA-N in `.claude/session-inbox.md` as `[x] IDEA-N: ... (promoted to T-NNN)`.

**Section requirements by size (from STEP 0):**
- **MEDIUM (and SMALL)** — mandatory 7 sections: Overview (§1), Scope (§4), Technical Approach (§5), Deliverables (§6), Success Criteria (§7), Risks (§8), Testing (§9). The rest (Objectives, Prerequisites, Layer Impact Map, Red Flags, Dependencies) — по потребности, одной строкой или опустить.
- **LARGE** — full 13-section form.
- **UI Coverage Matrix (§13)** — frontend tasks only, ANY size (as before).

Create `docs/specs/T-NNN-slug.md`:

```markdown
# T-NNN: <title>

**Created**: YYYY-MM-DD
**Risk**: Low | Medium | High
**Status**: Backlog
**human_summary**: <1–2 plain-language sentences for `/todo list` — sentence 1 = the problem/pain in human
terms (what's broken/missing/annoying + who it hurts), sentence 2 = what the fix delivers. NO jargon, no
file names as the point. This is what the busy owner reads instead of the terse title.>

## 1. Overview
2-3 sentences: what, why, how it fits the product.

## 2. Objectives
- [ ] Specific measurable objective 1
- [ ] Specific measurable objective 2

## 3. Prerequisites
- Required tasks / tools / env

## 4. Scope
**In scope**: what will be built
**Out of scope**: what is explicitly deferred

## 5. Technical Approach
Architecture, design patterns, affected files.

## 6. Deliverables
| File | Purpose |
|------|---------|
| path/to/file | description |

## 7. Success Criteria
- Functional: what must work
- Tests: what tests must pass

## 8. Implementation Notes & BQC Risks
| If task involves... | Risk | Mitigation |
|---------------------|------|------------|
| State mutation | Duplicate-trigger | Optimistic lock / disabled state |
| External API | Timeout / failure | Timeout + backoff + error boundary |
| Auth resource | Auth bypass | Enforce auth at resource boundary |
| Write path | Data loss | Transaction + compensation |
| UI fetch | Missing states | Loading / empty / error states |

## 9. Testing Strategy
- Unit: ...
- Integration: ...
- E2E: ...
- QA Hacker: adversarial cases — every unresolved 🔴/🟡 from the STEP 1 adversarial interrogation
  (`docs/rules-references/adversarial-interrogation.md`, classes A–K) lands here as a concrete case:
  bad-type/empty/extra params, retry/double-submit idempotency, mid-flow cancellation, token/link expiry,
  no-rate-limit flooding, concurrent edits. Each must be a test that FAILS without the guard.

## 10. Layer Impact Map
| Layer | Impact | Files |
|-------|--------|-------|
| [e.g. API routes] | high | [e.g. src/routes/cameras.py] |
| [e.g. DB models] | low | — |
| [e.g. Frontend] | medium | [e.g. src/components/List.tsx] |
| [e.g. Tests] | high | [e.g. tests/test_feature.py] |

## 11. Red Flags
- <hidden dependency that could break unexpectedly>
- <assumption that might be wrong>
- <part of the spec that is vague or contradictory>

## 12. Dependencies
- External libraries
- Cross-task dependencies

## 13. UI Coverage Matrix (mandatory for ALL frontend tasks — skip only for backend-only tasks)

> **Purpose:** Prevent "task marked done but form is missing half the PRD fields."
> List every PRD requirement this task covers. Defer the rest explicitly to a named task.

| PRD Ref | Requirement / Field | Status |
|---------|---------------------|--------|
| §x.x F-xx | <field or control from PRD> | ✅ In scope / ❌ Deferred to T-NNN |

**Rules:**
- Every field from the referenced PRD section must appear in this table.
- A field is either "In scope" (built in this task) or "Deferred to T-NNN" (an existing or new task ID).
- "Deferred" means the deferred task MUST exist in TASK.md before this task is marked done.
- Never leave a PRD field without a row — silence = untracked = ship gap.
- If a field was intentionally excluded from V1 scope: "❌ V2 — out of V1 scope per PRD §12."

**Done condition for UI tasks:**
☐ All PRD fields for this screen are either implemented or explicitly deferred to a named task.
☐ No missing states (loading / empty / error) on any data-fetching component.
☐ Playwright E2E spec covers main user flow end-to-end (not just unit tests).
☐ Design tokens from `.claude/commands/ui-ux-pro-max.md` applied (if skill exists in project).
```

**STEP 4.5 — Security Threat Assessment**

Determine if the task touches any security-sensitive area:
- Authentication, authorization, session management
- Payments, financial transactions, balances, credits
- File uploads, downloads, storage
- User data, PII, sensitive information
- External API integrations, webhooks, OAuth
- Permissions, roles, access control, admin functions
- Cryptography, tokens, secrets, password handling

If YES → **Invoke `Rex` agent** in RED mode:
> "Review spec T-NNN for security risks. Identify attack vectors this feature introduces, missing security controls in the technical approach, and adversarial test scenarios."

Map Rex output into the spec:
- **Section 8 (BQC Risks)** — add each security risk as a row with mitigation
- **Section 9 (QA Hacker)** — add adversarial test cases (auth bypass, IDOR, injection, race conditions)
- **Section 11 (Red Flags)** — add security red flags from the analysis

Verdicts:
- **CRITICAL risk in spec** → revise Section 5 (Technical Approach) before proceeding. Do NOT add to backlog with an unmitigated CRITICAL.
- **HIGH risk** → mitigation must be explicit in Section 8 before proceeding.
- **CLEAN** → add note to Section 8: "Security-reviewed: no threats identified."

If task does NOT touch security-sensitive areas → skip this step.

---

**STEP 5 — Diablo Spec Review (LARGE / architectural only)**

**Size gate (from STEP 0):** SMALL/MEDIUM → skip this step. Write `step_5_diablo: skipped:size-triage-<TIER>` in frontmatter and proceed to STEP 6 — the implementation-stage Diablo (`/da impl`, auto in `/orchestrate` STEP 7.5) catches real problems later, when there is code to attack. Run STEP 5 for: LARGE tasks, OR any size with architectural impact (new module boundary, cross-system contract, data model change).

For LARGE/architectural: run `/da spec T-NNN` (Diablo). Capture verdict in spec frontmatter. Schema is strict — all 6 fields required, no extras.

**Frontend tasks have an additional Diablo check (per SELF-AUDIT-2026-05-28 FINDING-3):** spec `## 13. UI Coverage Matrix` must list, for every interactive element, all four states: loading / empty / error / success. Diablo verdict is BLOCKED if any state row is «TBD», «implicit», «covered by base.html» without a specific test ID, or missing entirely. Root cause: silent UI failures (OSINT F-024/F-064/F-065, SLUGGER F-085, AI-calendar F-023) all shared an unenforced UI matrix.

<output_format type="spec_frontmatter_workflow_progress">
```yaml
---
workflow_progress:
  step_1_grill_me: complete | skipped:<reason>
  step_2_5_prior_knowledge: complete | skipped:<reason>
  step_3_research: complete
  step_4_spec: complete
  step_4_5_security: complete | skip:not-applicable | CRITICAL:<details>
  step_5_diablo: ACCEPTABLE | PROCEED_CAUTION | FIX_FIRST | BLOCKED | skipped:<reason>
---
```
</output_format>

<output_schema>
{
  "type": "object",
  "required": ["workflow_progress"],
  "properties": {
    "workflow_progress": {
      "type": "object",
      "required": ["step_1_grill_me", "step_2_5_prior_knowledge", "step_3_research", "step_4_spec", "step_4_5_security", "step_5_diablo"],
      "additionalProperties": false,
      "properties": {
        "step_1_grill_me": {"type": "string", "pattern": "^(complete|skipped:.+)$"},
        "step_2_5_prior_knowledge": {"type": "string", "pattern": "^(complete|skipped:.+)$"},
        "step_3_research": {"const": "complete"},
        "step_4_spec": {"const": "complete"},
        "step_4_5_security": {"type": "string", "pattern": "^(complete|skip:not-applicable|CRITICAL:.+)$"},
        "step_5_diablo": {"type": "string", "pattern": "^(ACCEPTABLE|PROCEED_CAUTION|FIX_FIRST|BLOCKED|skipped:.+)$"}
      }
    }
  },
  "skip_reason_rule": "ANY 'skipped:<reason>' MUST cite either the STEP 0 size-triage tier (skipped:size-triage-SMALL / skipped:size-triage-MEDIUM) or an explicit user /skip token from session — never Sonnet-rationalized"
}
</output_schema>

> **This frontmatter is self-report by Sonnet — NOT an enforcement gate.** The actual gate is the PreToolUse hook `.claude/hooks/todo-diablo-gate.sh` that blocks Edit/Write of `docs/TASK.md` when `step_5_diablo` is missing or BLOCKED/FIX_FIRST. The hook accepts `skipped:<reason>` (size-triage SMALL/MEDIUM path).

If Diablo verdict is **BLOCKED** or **FIX FIRST** — STOP. Do NOT proceed to STEP 6. Fix the spec, re-run `/da spec T-NNN`, repeat until ACCEPTABLE or PROCEED CAUTION.

If Diablo verdict is **ACCEPTABLE** or **PROCEED CAUTION** — proceed to STEP 6.

**STEP 6 — Add to TASK.md**

1. Read `docs/TASK.md`
2. Assign next available T-NNN id
3. Add row to Backlog with link to spec

(PreToolUse hook fires here — verifies spec frontmatter `step_5_diablo` value before allowing the Edit/Write to TASK.md.)

**STEP 7 — Confirm**

<output_format type="todo_add_confirmation">
```
✓ T-NNN added: <title>
Risk: <level>
Spec: docs/specs/T-NNN-slug.md
GitHub: <issue URL>
Diablo verdict: ACCEPTABLE | PROCEED CAUTION
```
</output_format>

<output_schema>
{
  "required_fields": ["T-NNN", "title", "Risk", "Spec", "Diablo verdict"],
  "optional_fields": ["GitHub"],
  "T-NNN_pattern": "^T-[0-9]{3,4}$",
  "risk_enum": ["Low", "Medium", "High"],
  "spec_path_format": "docs/specs/T-NNN-<slug>.md (matching the actual file created)",
  "verdict_enum_at_confirm": ["ACCEPTABLE", "PROCEED CAUTION"],
  "anti_rule": "STEP 7 fires only if STEP 5 verdict was ACCEPTABLE or PROCEED CAUTION — BLOCKED/FIX_FIRST never reach STEP 7"
}
</output_schema>

---

### `/todo done <id>`
1. Read `docs/TASK.md`
2. Get latest commit: `git log -1 --format="%h %s"`
3. Remove row from In Progress / Backlog
4. Append to `docs/archive/TASK_ARCHIVE.md`: `| T-NNN | Task | YYYY-MM-DD | <commit> |`
5. Confirm: "✓ Task <id> archived with commit <hash>"

---

### `/todo start <id>`
1. Read `docs/TASK.md`
2. Move row Backlog → In Progress
3. Confirm: "✓ Task <id> moved to In Progress"

---

## Notes
- `/todo` is STRICTLY planning only — never write implementation code
- Completed tasks go to `docs/archive/TASK_ARCHIVE.md` — NEVER stay in TASK.md
- Archive entries MUST include git commit hash
- **All STEPs are mandatory unless user types `/skip <step-name> <reason>` explicitly** (see workflow.md § Process Step Discipline)
- grill-me is mandatory for `/todo add` MEDIUM/LARGE (batches of up to 3 questions, each with a recommended answer) — to skip, user MUST type `/skip grill-me <reason>` (typically "trivial typo" — but for trivial work, prefer `/quick-plan` from the start)
- Diablo spec review (STEP 5) runs for LARGE/architectural only; SMALL/MEDIUM mark `step_5_diablo: skipped:size-triage-<TIER>` — impl-Diablo covers them later. PreToolUse hook `.claude/hooks/todo-diablo-gate.sh` BLOCKS TASK.md write if `step_5_diablo` is missing or BLOCKED/FIX_FIRST (accepts `skipped:<reason>`)
- For trivial work — use `/quick-plan` instead of `/todo`. `/quick-plan` does not have the full step ceremony.
