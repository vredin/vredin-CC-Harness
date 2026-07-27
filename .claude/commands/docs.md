---
name: docs
description: 'Documentation lifecycle — init missing docs, sync from code, create ADR, publish to Outline, audit drift.'
argument-hint: [init | sync | adr <title> | publish | audit]
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
model: sonnet
---

> **Style:** Load `caveman-distillate` skill.

# /docs — Documentation lifecycle

Mode: `$ARGUMENTS` (one of: `init`, `sync`, `adr <title>`, `publish`, `audit`)

---

## STEP −1 — Clarify intent (interactive routing — runs FIRST)

Parse `$ARGUMENTS`. If it already names a mode (`init` / `sync` / `adr` / `publish` / `audit` /
`sync --publish`) → skip this step, proceed with it (this keeps the rare one-time `init` reachable via
`/docs init`). If **no argument** (or an unrecognized one) → ask via `AskUserQuestion`
(per `docs/rules-references/interactive-routing.md`):

> **Q: «Что сделать с документацией?»**
> - Проверить, где доки разошлись с кодом (audit) — только чтение, ничего не меняет *(рекомендовано)*
> - Обновить доки из кода (sync) — правит ARCHITECTURE/API/CONVENTIONS по факту
> - Записать архитектурное решение (adr) — спрошу заголовок следующим шагом
> - Выложить доки в Outline (publish)

Map the pick to the mode. If **adr** chosen → ask a one-line follow-up for the title, then run
`adr <title>`. (Need to create missing doc stubs on a fresh project? That is `/docs init` — run it
explicitly; it is not in the daily menu.) Never print raw usage; never default silently.

---

## Mode: `init`

Create missing documentation stubs. Idempotent (skip files that exist).

| File | Created if missing | Source |
|---|---|---|
| `docs/STACK.md` | yes | Template stub, fill from `/init-project` answers |
| `docs/CONTEXT.md` | yes | Template stub (domain glossary) |
| `docs/RUNBOOK.md` | yes | Template stub (incident response) |
| `docs/RULES.md` | yes | Business rules template — NEVER answer rate/policy questions without it |
| `docs/prd/` | yes (empty + .gitkeep) | Created by /intent — Product Requirement Documents |
| `docs/epics/` | yes (empty + .gitkeep) | Created by /decompose — logical groups of tasks |
| `docs/CONVENTIONS.md` | yes | Template stub + Python section if Python in stack |
| `docs/KNOWLEDGE.md` | yes | Empty stub for ADR-summary |
| `docs/FAILS.md` | yes | Header only — entries grow over time |
| `docs/PATTERNS.md` | yes | Header only |
| `docs/TASK.md` | yes | Backlog/In Progress headers |
| `docs/adr/0001-template.md` | yes | ADR template |
| `docs/reports/` | yes | Directory only |
| `docs/specs/` | yes | Directory only |
| `docs/archive/TASK_ARCHIVE.md` | yes | Header only |

After init: report which files were created vs already existed.

---

## Mode: `sync`

Audit + update documentation from real code. Read-mostly with surgical edits.

### STEP 1 — ARCHITECTURE.md
1. Glob the source root (`app/`, `src/`, etc — read from `docs/STACK.md`).
2. Identify entry points (FastAPI routers, React app root, CLI handlers).
3. Build module map: top-level packages → public interfaces.
4. **Stub detection on services** (parallel to STEP 2 endpoint stubs):
   - Read each service module's primary functions (skip `__init__`, helpers).
   - Apply same patterns as STEP 2.3 (NotImplementedError, "not implemented" strings, single-line returns, TODO/Phase comments).
   - In the module map, annotate stubs:
     ```
     ├── recommender.py        # Monthly buy recommendation engine **[STUB — phase 2]**
     ├── ticker_analysis.py    # Per-ticker LLM analysis **[PARTIAL — handles single ticker, no batch]**
     ├── llm.py                # OpenRouter client wrapper
     ```
5. **Schema completeness** — read all `__tablename__` from models. Cross-check that every table appears in the Data Model section. Flag missing tables (don't silently drop them).
6. Compare with existing `docs/ARCHITECTURE.md`. If sections drifted (module deleted/renamed/moved, stub→real status changed, table added/removed) → mark with `[DRIFT]` comment, propose update diff.
7. Use `improve-codebase-architecture/LANGUAGE.md` glossary. NEVER write "service", "boundary", "API alone".

### STEP 2 — API.md
1. Find all FastAPI/Express/etc route definitions.
2. **Read each endpoint's function body** — not just signature. Cheap step, prevents the "documented as functional, actually a stub" failure mode.
3. **Detect stubs** — for each endpoint, check the body against these patterns and tag accordingly:

   **Hard stub indicators** (any one → `**STUB**`):
   - Body contains `raise NotImplementedError`
   - Flash/return message matches case-insensitive: `"not implemented"`, `"not yet implemented"`, `"todo"`, `"placeholder"`, `"coming soon"`
   - Body is `pass` with no logic
   - Body is single-line redirect with no real work (e.g. `return RedirectResponse(...)` and no DB/service call before it)

   **Soft stub indicators** (combination of 2+ → `**PARTIAL**`):
   - Body has `TODO` / `FIXME` / `XXX` / `HACK` comment AND function does something but skips a code path
   - Body has `# Phase N:` style comment indicating planned future work
   - Body wraps a service call but the service itself is a stub (recursive check, depth=1)
   - Function body < 5 statements AND uses placeholder data (hardcoded list, mock dict)

   **Real implementation** (none of above): no annotation needed.

   For each endpoint detected as STUB / PARTIAL, capture:
   - The exact stub marker (which pattern matched + line number)
   - What the function should do per its name / surrounding comments

4. Generate flat table: `method | path | auth | response | notes`. The `notes` column carries the stub annotation.

   Format:
   ```markdown
   | POST | `/admin/ingest-course` | yes | Redirect | **STUB** — flash "not implemented yet"; planned: PDF upload → ingestion/course.py → course_chunks |
   | POST | `/sync/prices` | yes | Redirect | Triggers price sync via services/prices.py |
   | GET  | `/admin/migrate` | yes | Redirect | **PARTIAL** — handles "to" arg but ignores "from"; see Phase 2 comment |
   ```

5. **Auth annotation** — read at TWO levels (don't trust single source):
   - Router-level: `APIRouter(dependencies=[Depends(login_required)])` or `APIRouter(prefix=..., dependencies=[...])`
   - Endpoint-level: `@router.get("/foo", dependencies=[...])`
   - If either has `login_required` → `Auth: yes`
   - Note any role-level checks (`require_admin`, `require_role("X")`) explicitly: `Auth: yes (admin)` etc.
   - Default: `Auth: —` (open)

   **Don't infer admin role from URL** (e.g. `/admin/*` doesn't mean admin auth) — must verify explicit code.

6. Compare with existing `docs/API.md`. Mark routes that vanished, changed signature, or **changed stub status** (formerly STUB → real, or vice versa).

### STEP 3 — CONVENTIONS.md
1. Detect added/removed dependencies in `pyproject.toml` / `package.json`.
2. Flag tool changes ("ruff added → update format command in CONVENTIONS").

### STEP 4 — Report
```
DOCS SYNC — <DATE>

ARCHITECTURE.md: <N drift items, see diff below>
API.md:          <M new endpoints, K changed, J removed>
CONVENTIONS.md:  <updates needed>

Apply changes? [y/n/per-file]
```

Apply mode = surgical edits (Edit tool), no rewrites of user-authored sections (those marked `<!-- USER -->`).

---

## Mode: `adr <title>`

Create new ADR.

1. Find next free number: `ls docs/adr/ | grep -E '^[0-9]{4}-' | sort -r | head -1`.
2. New file: `docs/adr/<NNNN>-<slug>.md` from `docs/adr/0001-template.md`.
3. Pre-fill: title, today's date, deciders=`<git config user.name>`.
4. Open for user input (return path, instruct user to fill).
5. After save: link from `docs/KNOWLEDGE.md` summary table.

Trigger: usually after `improve-codebase-architecture` skill grilling produces a rejection worth recording.

---

## Mode: `publish`

Read `.claude/.setup.json` → `outline.mode`.

**`mode = "github"` or `"local"`** → no-op per `docs/OUTLINE-CONTRACT.md` § Backend. This
project's own `docs/*.md`, once committed and pushed, IS the publication — nothing else to
do. Report: "Publish: n/a in <mode> mode — docs/*.md is already the publication once pushed." STOP.

**`mode = "cloud"`** — mirror local `docs/` to Outline `Project: <name>` collection:

1. Read project Outline collection ID from `.claude/.setup.json` (`outline.project_collection_id`).
   - If missing → "Run `/setup` → Bootstrap project collection first." STOP.
2. For each of these top-level docs (only published ones):
   - `docs/ARCHITECTURE.md` → "Architecture" sub-page
   - `docs/API.md` → "API Reference" sub-page (if exists)
   - `docs/RUNBOOK.md` → "Runbook" sub-page
   - `docs/KNOWLEDGE.md` → "Knowledge" sub-page
   - `docs/RULES.md` → "Rules" sub-page
   - For each `docs/adr/<NNNN>-*.md` → its own page under "Decisions"
   - For each `docs/prd/PRD-*.md` → its own page under "PRDs"
   - For each `docs/epics/EPIC-*.md` → its own page under "Epics"
3. Update logic:
   - Search Outline for existing doc with matching title or path
   - If exists → `mcp__outline__update_document` with new body
   - If not → `mcp__outline__create_document` under appropriate parent
4. Report mapping local → Outline URL.

NOT mirrored (transient or project-internal):
- `docs/STACK.md`, `docs/CONTEXT.md`, `docs/CONVENTIONS.md` (machine-readable config, not narrative knowledge)
- `docs/TASK.md`, `docs/specs/`, `docs/reports/`, `docs/handoff/`, `docs/archive/`
- `docs/FAILS.md` (those flow to **Shared/Fails** via `/fix` auto-publish, not via `/docs publish`)
- `docs/PATTERNS.md` (publishes to **Shared/Best Practices** only when explicitly flagged via `/improve-arch`)

### STEP 3.5 — humanizer pass on auto-generated docs (mandatory)

ARCHITECTURE.md, API.md, RUNBOOK.md, KNOWLEDGE.md content is **read by humans** (devs onboarding, code reviewers, future you). Apply `humanizer` skill to any text section that auto-generation produced:
- Module map descriptions
- Endpoint Notes column
- ADR rationale
- RUNBOOK procedures

Tables and code blocks pass through unchanged. Prose paragraphs get humanizer.

This prevents the «sounds like AI wrote it» problem in your project's primary
reference documents.

## Mode: `sync --publish` (chained: sync first, then publish)

For use via `/loop` (weekly Monday):

1. Run `sync` mode — audit drift, apply fixes
2. If sync produced changes → run `publish` mode automatically
3. If sync found no drift → skip publish (Outline is up-to-date)
4. If sync found drift but apply was rejected — DON'T publish stale local; report and exit

Loop registration: `/loop "0 9 * * 1" /docs sync --publish`

This is the gated auto-publish for project docs — only republishes when local files
actually changed AND sync confirmed they reflect reality.

---

## Mode: `audit`

Find docs/code drift without applying changes. Read-only.

Output:
```
DOCS AUDIT — <DATE>

ARCHITECTURE.md
  ❌ References module `app/legacy/` (deleted in commit abc1234)
  ⚠️  Section "Caching" outdated — Redis no longer in pyproject.toml

API.md
  ❌ Lists endpoint POST /v1/old-thing (removed)
  ⚠️  POST /api/cameras has different request shape since commit def5678

CONVENTIONS.md
  ⚠️  References "black" — replaced by "ruff format" 3 weeks ago

STACK.md
  ✓ in sync

Run /docs sync to apply fixes.
```

---

## Designed for /loop

```bash
# Weekly Monday 9:00 — audit + alert if drift found
/loop "0 9 * * 1" /docs audit
```

If audit finds drift, you decide whether to run sync. Auto-sync without review can stomp manual edits — explicit gate required.

---

## Rules

- NEVER overwrite sections marked `<!-- USER -->` — those are user-authored.
- Sync is surgical (Edit tool), never wholesale rewrite.
- ADR files are immutable once written — supersede with new ADR.
- Publish to Outline only after successful sync — stale local = stale Outline = worse than missing.
