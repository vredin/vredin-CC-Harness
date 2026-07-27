---
name: intent
description: 'Greenfield entry — convert vague intent ("хочу систему X") into a structured PRD via research + Diablo + verification. Outputs docs/prd/PRD-NNN.md, ready for /decompose. Use when no requirements exist yet.'
argument-hint: <vague intent or path to brief>
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion, WebSearch, WebFetch, Glob, Grep
model: opus
---

> **Style:** Load `caveman-distillate` skill — terse, evidence-first.

# /intent — Vague idea → PRD

Input: **$ARGUMENTS** (one-line intent OR path to brief document)

If `$ARGUMENTS` is a file path that exists → read it. Otherwise treat as intent text.

This command produces a PRD. **Does not** create epics or tasks. After PRD is finalized,
run `/decompose PRD-NNN` to split into epics → tasks.

`/intent` is the **compact** in-template path. It runs a lighter version of the full
requirements analysis. For greater depth, use the vendored requirements-analyzer commands
instead — they are now first-class in this template:
- **`/design-system <goal>`** — goal → full system-design report + build-vs-buy + min/mid/max
  scope (ISO/IEC/IEEE 29148, evidence-required, Diablo attacks twice). Deep alternative to `/intent`.
- **`/analyze-spec <TZ>`** — if you already have a spec document.
- Upstream idea-validation first? → `/market-research` → `/value-prop` (product-method).
- Full greenfield chain + when to use which: `docs/rules-references/greenfield-pipeline.md`.

Router rule: if the idea is fuzzy/high-stakes or the user wants build-vs-buy and rigor →
offer `/design-system`. If the idea is already clear and they want a quick PRD in-template →
proceed with `/intent`. Either way, the output feeds `/decompose`.

---

## STEP 1 — Pre-flight

1. Check that `docs/prd/` exists; create if not (`mkdir -p docs/prd`)
2. Find next free PRD-NNN number: `ls docs/prd/PRD-*.md 2>/dev/null | grep -oE 'PRD-[0-9]+' | sort -r | head -1`
3. Load skills: `spec-normalizer`, `verification-pass`, `humanizer`, `decision-matrix`, `planning`

## STEP 1.5 — Office Hours interrogation (mandatory before research)

Before any research happens, push back on user's framing. Most "I want X" requests describe the symptom, not the product. Six forcing questions, **one at a time** via `AskUserQuestion`. Wait for answer before next.

**Q1 — Concrete pain (not hypothesis)**:
> "Опиши ПОСЛЕДНИЙ раз когда эта проблема реально стрельнула. Кто? Когда? Сколько потеряли времени/денег/клиентов? Если не можешь вспомнить конкретный случай — это hypothesis, не problem. Готов отказаться от идеи?"

If user can't name a concrete recent incident → flag in PRD §8 as «No validated pain — proceeding on hypothesis».

**Q2 — Reframe attempt (challenge their words)**:
> "Ты сказал «$ARGUMENTS». Но судя по описанию, ты строишь не [literal interpretation], а [reframed bigger thing]. Согласен с reframe? Или literal interpretation точнее?"

Example: «I want a daily briefing app» → reframe to «AI chief of staff with daily briefing as one of N capabilities». Force user to confirm or reject.

**Q3 — Hidden capabilities** (extract what they didn't realize they're describing):
> "Из твоего описания я вижу 3-5 capabilities которые ты НЕ упомянул явно: [list]. Какие из них реально нужны? Какие out of scope?"

**Q4 — Premise challenges (4 пункта, бьёт по assumptions)**:
> "Ты исходишь из 4 предпосылок: [P1, P2, P3, P4]. По каждой — agree / disagree / adjust?"

If user disagrees with P1 → may unlock 10x simpler solution.

**Q5 — 10-star product hiding inside (Garry Tan's CEO pattern)**:
> "Если бы я делал это в YC и хотел построить 10-star product (не 5-star MVP) — фича была бы [bigger vision]. Это твой амбициозный потолок? Или 5-star MVP сейчас — реалистичнее?"

User's choice between «build for now / build for scale» frames whole PRD.

**Q6 — Narrowest wedge (smallest thing that delivers signal)**:
> "Что самая узкая версия которую можно отгрузить ЗАВТРА чтобы получить feedback от реальных пользователей? Не MVP — wedge. Часто это 10% scope."

Output of STEP 1.5 → mental notes, will become PRD §1 (validated pain), §4 (out of scope), §9 (phasing).

If user signals impatience («давай дальше», «ясно, поехали»):
- Acknowledge their answer to current Q
- DO NOT skip remaining Q's silently
- Confirm: «Pre-research interrogation: STEP 1.5 has 6 questions, мы на Q[N]. Continue? `/skip office-hours <reason>` to bypass explicitly?»
- Per workflow.md § Process Step Discipline — silent skip = banned

## STEP 2 — Outline read-before-start (mandatory)

Search Outline before starting — may already be a similar product / pattern documented.
```
mcp__outline__list_documents
  query: "<keywords from intent>"
  collectionId: <shared_kb_id>      # Best Practices + Tricks
  limit: 5

mcp__outline__list_documents
  query: "<keywords>"
  collectionId: <project_collection_id>   # existing PRDs in this project
  limit: 5
```

If similar PRD found in same project → ask user: «Existing PRD-XX covers this. Extend it, or create new?» Don't silently create duplicates.

## STEP 3 — Research (compact, NOT 8-stage requirements-analyzer)

Three parallel research questions:
1. **What exists** — search GitHub / awesome-lists / docs for existing solutions in this domain. WebSearch + WebFetch on top 3 hits. Aim: 5-min recon, not 50-min deep dive.
2. **What's the simplest possible MVP** — single sentence definition.
3. **Build vs buy** — is there an off-the-shelf option that solves 80%?

Output (mental, not yet written): brief notes for STEP 4.

## STEP 4 — Propose 2-3 solution variants

Use `decision-matrix` skill format. Axes (auto-pick from `decision-matrix/axes-library.md`):
- Implementation effort (weeks)
- Maintenance burden (ongoing)
- User-facing fit (features delivered)
- Reversibility (lock-in)
- Cost ($)

Each cell = `{score, confidence, source_id}` per skill rules — NEVER bare numbers.

Variants to consider:
- A: Minimal MVP from scratch (lowest scope)
- B: Build on existing OSS (e.g. fork + customize)
- C: Buy / SaaS adapter (lowest effort)

Show matrix to user. Ask: «Which variant for the PRD? [A/B/C/refine matrix/skip — describe own]»

## STEP 5 — Compose PRD via spec-normalizer

Load `spec-normalizer` skill. Apply its YAML structure to the chosen variant.

Render to `docs/prd/PRD-NNN-<slug>.md` with these sections:

```markdown
# PRD-NNN: <Title>

**Created**: YYYY-MM-DD
**Status**: Draft → Review → Accepted → Implemented
**Source**: <intent / brief / contract>

## 1. Problem
What user pain does this solve? One paragraph.

## 2. Users
Primary user persona + their context. Who is NOT a user (out of scope)?

## 3. Goals (measurable)
- [ ] Functional: <observable outcome>
- [ ] Non-functional: <perf/security/uptime target>

## 4. Non-goals
What we explicitly do NOT solve.

## 5. User stories
- As a <role>, I want to <action>, so that <outcome>.
(3-7 stories; if more, this should be split into multiple PRDs)

## 5.5 User Journey (MANDATORY — Diablo BLOCKED if empty)
Numbered happy path. ≥3 steps. Each step: page/screen/surface → action → result.
Example for web app:
1. User lands on /login → enters email → receives magic link
2. User clicks link → routed to /dashboard → sees account summary
3. User clicks "Add transaction" → modal opens → submits form → row appears in list

For CLI/bot: same shape — surface (terminal command or bot message), action, result.
For backend-only API service: describe consuming-app journey, not internal calls.

## 5.6 Test Strategy (MANDATORY — Diablo BLOCKED if empty)
Required:
- Unit: which modules/layers (`app/services/`, `app/models/`)
- Integration: which boundaries (DB, external APIs — list the APIs by name)
- E2E: which user flows from §5.5 are covered by Playwright/equivalent
- Coverage target per layer (e.g. unit 80%, integration 60%, e2e: 100% of §5.5 happy paths)

## 6. Acceptance criteria (measurable)
For each goal in §3, what is the testable assertion?

## 7. Solution variant chosen
Reference to decision matrix from /intent STEP 4.
**Trade-offs accepted**:
- Gave up: <X>
- In favour of: <Y>

## 8. Risks (top 5)
| ID | Risk | Likelihood | Impact | Mitigation |
|----|------|------------|--------|------------|

## 9. Phasing (optional — if PRD spans >1 sprint)
- Phase 1 (MVP): <minimum to deliver §3.functional[0]>
- Phase 2 (v1): ...
- Phase 3 (later): ...

## 10. Open questions
Unanswered things to be resolved during /decompose.

## Sources
[1] URL — what was confirmed via WebFetch on YYYY-MM-DD
[2] ...
```

## STEP 6 — Diablo gate on PRD (mandatory)

Invoke `/da spec docs/prd/PRD-NNN-<slug>.md`.

Diablo MUST attack:
- §1 Problem too vague?
- §3 Goals not measurable? («хорошо работает» is banned)
- §4 Non-goals missing — what will scope-creep into?
- **§5.5 User Journey: BLOCKED if empty, fewer than 3 steps, or describes data flow instead of user-facing flow. No INFERRED hallucination of journeys without explicit user input.**
- **§5.6 Test Strategy: BLOCKED if empty or missing one of {unit, integration, e2e} layers without explicit "skip: <reason>" annotation.**
- §6 Acceptance criteria reflective of goals?
- §8 Risks: are top 5 real or strawmen?
- §9 Phasing realistic per Phase 1?
- §10 Open questions are real (not «we'll figure out later» = blocker)

**NOT mandatory at /intent stage** (defer to /decompose; producing them here = INFERRED hallucination):
- Deploy Plan: generated as T-000 scaffold by /decompose phase 0
- Secrets List: derived by /orchestrate from backlog scan + service-secrets.md lookup
- Visual Design: triggered by /decompose post-Gate-1 UJ content scan; produces T-001 design exploration task

If verdict is `BLOCKED` or `FIX FIRST`:
1. Report Diablo findings to user
2. User addresses (ask via `AskUserQuestion` if scope decisions needed)
3. Update PRD-NNN
4. Re-run Diablo
5. Loop until `ACCEPTABLE` or `PROCEED CAUTION`

## STEP 7 — verification-pass

Load `verification-pass` skill. For every claim in the PRD that contains:
- Numerical metrics (percentages, $, time)
- Product / library names
- Third-party feature claims
- External standards (ISO, OWASP, etc.)

→ verify via WebFetch / WebSearch. Tag each as `[verified]` / `[unverified]` / `[contradicted]`.

If ≥1 contradicted → STOP, fix the PRD, re-verify.

## STEP 8 — humanizer pass

Load `humanizer` skill. Apply anti-AI-text patterns to the PRD draft. Removes "delve", "tapestry", em-dash overuse, sycophantic openers. PRD reads natural.

## STEP 9 — Commit

```bash
git add docs/prd/PRD-NNN-<slug>.md
git commit -m "[CHANGE] PRD-NNN: <title>

Variant chosen: <A/B/C from STEP 4>
Diablo verdict: ACCEPTABLE
Verified claims: N
Sources: K external"
```

## STEP 10 — Auto-publish to Outline

Read `.claude/.setup.json` → `outline.auto_publish.adrs_to_project` (PRDs use same flag).

If `true` (default):
```
mcp__outline__create_document
  title: "PRD-NNN: <title>"
  collectionId: <project_collection_id>
  parentDocumentId: <PRDs sub-page id>
  text: <full PRD markdown>
  publish: true
```

## STEP 11 — Confirm + suggest next

```
✓ PRD-NNN: <title> created
File: docs/prd/PRD-NNN-<slug>.md
Outline: <url or "skipped — MCP unavailable">
Diablo: ACCEPTABLE (or PROCEED CAUTION + N items)
Status: Draft

Next:
  /decompose PRD-NNN     ← split into architecture decisions, epics, tasks
```

---

## Hard rules

- NEVER skip Diablo gate (STEP 6) — that's the whole point of this command
- NEVER skip verification-pass (STEP 7) — galmlucinations get caught here
- If user can't answer key questions in PRD →  STEP 10's "Open questions" section gets entries; do NOT silently invent
- PRD is a contract for the team. If acceptance criteria aren't measurable, the PRD is wrong; don't ship.
- /decompose is a separate command — this command does NOT auto-trigger it. PRD must be reviewed before decomposition.
