---
name: analyze-spec
description: "Full requirements analysis pipeline. Takes a raw TZ either from a file path OR from text pasted in the current chat, and produces: normalized spec, Diablo critique, gap analysis, decision matrices with alternatives, verification report, second Diablo pass, and final report. All outputs land in specs/analysis/<slug>/."
argument-hint: "[path/to/tz.md — optional; if omitted, pulls TZ from the most recent paste in chat]"
---

# /analyze-spec — Requirements Analysis Orchestrator

Full pipeline for analyzing any technical specification. Takes raw TZ → produces a single self-contained PDF report backed by technical audit artifacts on disk.

## ⛔ PIPELINE INVARIANT — BLOCKING DIRECTIVE — READ FIRST

**Stages 0-8 are ONE atomic operation, not 9 separate operations.**

After producing the artifact for a stage, you do NOT stop and wait. You do NOT summarize and wait for input. You do NOT ask "should I continue?". The next instruction in this command file IS your continuation — read it and execute it.

**Default behaviour between stages: continue immediately.** Treat every "##" stage heading after the current one as the next thing to do, not as a checkpoint requiring approval.

### The ONLY valid stopping points

These are the ONLY conditions that pause the pipeline. Anything else — including "I just wrote a big file and feel like a natural break" — is NOT a stopping point.

1. **Step 0 inline-mode**: cannot find a TZ block in conversation history → ABORT with usage message.
2. **Step 0 product clarification**: ambiguous product names found → ASK USER and wait for reply.
3. **Step 5 decision table** triggers a STOP row (FATAL > 0 with loop budget exhausted, or coverage < 50%).
4. **Step 6 BLOCKED verdict** with loop budget exhausted (set DRAFT mode, then continue to Step 7 — DRAFT is not a stop).
5. **User types `/stop`** or equivalent explicit abort.
6. **A tool call returns an error** that prevents continuation (file not found, gh auth, etc.) — report the error and wait.

If none of the above triggered: **the pipeline MUST continue to the next Step in this file without pause, summary, or user-confirmation request.**

### Self-check at every stage transition

After writing each stage's artifact, before any "summary to user", silently ask:

> "Have I just hit one of the 6 STOP conditions above? If no — start the next Step in the same response. The summary I want to write IS the kind of natural break I'm forbidden from taking."

If your answer to that question is "no STOP triggered" — then your next action is the first instruction of the next Step. The Stage N → Stage N+1 boundary is a paragraph break in this file, not a session break.

### Telemetry vs stopping

It is OK to print short status messages between stages (`> Stage 2 — Diablo on spec`). It is NOT OK to print a summary and end your turn. Telemetry is one line; stopping is yielding control.

## Arguments

TARGET: $ARGUMENTS

Flags (optional, may appear in any order after TARGET or without TARGET):
- `--lang ru|uk|en` — report language (default: `ru`)
- `--pdf` — generate PDF version of final-report at Step 9 (default: off)
- `--no-preamble` — skip interactive preamble questions (requires explicit `--lang` and decision on `--pdf`)

TARGET может быть: (a) путь к файлу, (b) пусто, (c) строка-флаг (тогда TZ берётся inline из чата). Режим выбирается в Step 0.

---

## STEP 0 — Resolve input source and set up (dual mode)

### Mode A — file path

TARGET non-empty AND points to an existing file:

1. `source_tag = "file"`
2. `spec_path = TARGET`
3. `slug = basename(TARGET) without extension, kebab-cased` (e.g. `my-client-tz.md` → `my-client-tz`)
4. Read the file to confirm it's readable.
5. Announce: `Analyzing file \`<TARGET>\` → specs/analysis/<slug>/. Pipeline: 8 stages.`

### Mode B — inline paste from chat

TARGET is empty OR points to a path that does NOT exist:

1. Scan backwards through the current conversation for the **most recent substantial TZ-like text block**. Heuristics:
   - ≥150 words
   - Reads like a specification (contains requirements, goals, architectural claims, business context, vendor/technology names, or structured sections)
   - Provided by the **user** (not by the assistant, not from memory/skill files)
   - NOT a slash command invocation, NOT a one-liner clarification, NOT a code snippet

2. If a TZ-block found:
   - Generate `timestamp = YYYY-MM-DD-HHMM` from current time.
   - Ensure `specs/` directory exists (`mkdir -p specs`).
   - Save the TZ text to `specs/inline-<timestamp>.md` with a header comment on line 1:
     ```
     <!-- Source: inline paste from chat, <ISO timestamp> -->
     ```
   - `source_tag = "inline"`
   - `spec_path = specs/inline-<timestamp>.md`
   - `slug = "inline-<timestamp>"`
   - Announce: `TZ captured from chat → \`<spec_path>\`. Analyzing → specs/analysis/<slug>/. Pipeline: 8 stages.`

3. If NO TZ-block found in the conversation:
   - Abort with exactly this message:
     > **No TZ to analyze.** Usage:
     > - `/analyze-spec path/to/tz.md` — analyze a file
     > - Paste a TZ in chat, then run `/analyze-spec` (no arguments)
     > - Or ask naturally in chat: *"проанализируй это ТЗ"* after pasting text

### Prepare output directory

```
mkdir -p specs/analysis/<slug>
```

### Preamble — ask language + PDF (interactive unless --no-preamble)

If flags `--lang` and a `--pdf`/no-PDF decision were NOT both provided:

Ask the user ONE consolidated question:

> Before I start the pipeline (usually 10–20 minutes):
>
> 1. Report language? `ru` (default), `uk`, `en`
> 2. Generate PDF at the end? `y` / `N` (default: no — can generate later)
>
> Reply: "ru, no pdf" / "uk, pdf" / "en, pdf" / press Enter for defaults.

Parse the response. Set:
```
LANG=<ru|uk|en>         # default ru
PDF_AT_END=<yes|no>     # default no
```

If `--no-preamble` was passed — use flag values, skip the question.

### Ambiguous-product pre-flight

Read `$SPEC_PATH` once more. Extract all product/vendor/framework/service names mentioned in the TZ (e.g., "OpenClaw", "Freepik", "Higgsfield", "Mac Mini", "Instagram", "Google Maps").

For each name, run ONE `WebSearch "<name>"` (quick scan). Classify:

- **Well-known, unambiguous** (≥5 of top 10 point to the same company/product, and description matches TZ context) → OK, proceed.
- **Ambiguous or unverifiable** (multiple candidates, or zero relevant hits) → list them for user:

> В ТЗ упомянуты следующие продукты / сервисы, которые мне нужно уточнить до старта, потому что иначе анализ их решения будет неточным:
>
> - **"<name>"** — нашёл несколько возможных кандидатов:
>   - Candidate A: https://... (short description, stars, updated)
>   - Candidate B: https://...
>   - Candidate C: https://...
>
>   Подскажи точный URL (или "это внутренний продукт, нет публичной страницы").
>
> - **"<another name>"** — не нашёл ничего релевантного. Возможно внутренний продукт? Опиши в двух словах что это.

Wait for user response. Parse URLs/clarifications. Save them into `$ANALYSIS_DIR/product-clarifications.md` (one entry per clarified name, format: `<name> → <URL or "internal, <description>">`). researcher will read this file in Step 4.

If user replies "skip" or "proceed anyway" — proceed but record in `product-clarifications.md` that names are unverified.

Set env (carry through pipeline):
```
ANALYSIS_DIR=specs/analysis/<slug>
SPEC_PATH=<spec_path>
SOURCE_TAG=<source_tag>    # "file" | "inline"
LANG=<ru|uk|en>
PDF_AT_END=<yes|no>
```

---

## STEP 1 — Normalize spec

Invoke skill `spec-normalizer`. Inputs:
- Raw TZ text from `$SPEC_PATH` (either the user's file OR the saved inline paste).
- `$SOURCE_TAG` — so the skill can note the provenance in `spec.yaml` `meta.source`.

Output:
- `$ANALYSIS_DIR/spec.yaml` (skill writes)
- Summary printed to conversation (≤15 lines).

If spec-normalizer finds zero `design_choices` entries: continue anyway, but add a note for researcher: "TZ has no explicit design choices — researcher will skip stage 4 unless it infers implicit choices from requirements."

---

## STEP 2 — Diablo on spec

Invoke the `Diablo` agent in **Spec mode**. Inputs:
- `$ANALYSIS_DIR/spec.yaml`
- Raw TZ text (for context ISO-29148 attack needs)

Output:
- `$ANALYSIS_DIR/devil-spec.md`

Diablo writes its own file. Verify it was written; if empty or <50 lines, re-invoke with prompt "Diablo produced an underweight critique — attack again, at least 5 findings".

---

## STEP 3 — Gap analysis (idea-atomizer)

Invoke built-in skill `idea-atomizer` (standard Anthropic skill). Inputs:
- Raw TZ text (idea-atomizer works best on prose, not YAML)
- Brief:
  > Focus on: (1) contradictions between stated goals and stated requirements; (2) hidden assumptions that would kill the project; (3) missing dimensions.
  >
  > For missing dimensions, load `.claude/skills/spec-normalizer/references/operational-checklist.md` and check each of its 10 categories explicitly: control interface, operator model, lifecycle, outputs (photo/video/?), storage, observability, collaboration, integrations, security-ops, recovery. Any category not addressed in the TZ counts as a gap.
  >
  > Also check: legal dimension (regulatory, likeness rights, platform ToS, AI disclosure), accessibility, i18n, cost ceiling.

Orchestrator captures idea-atomizer's decomposition and writes it to `$ANALYSIS_DIR/gaps.md` via the Write tool (idea-atomizer itself does not write files).

If fewer than 5 atomic flaws/gaps emerge from any non-trivial TZ, something is wrong — re-invoke with sharper prompt including the operational-checklist categories explicitly.

---

## STEP 4 — Research alternatives

Invoke the `researcher` agent. Inputs:
- `$ANALYSIS_DIR/spec.yaml`
- Raw TZ (for context)
- `$ANALYSIS_DIR/product-clarifications.md` (if exists) — contains user's URL resolutions for ambiguous product names from Step 0
- Access to `.claude/skills/decision-matrix/SKILL.md` and `axes-library.md`

Tools researcher is expected to use:
- `WebSearch` — discovering alternatives, community sentiment (Reddit/HN)
- `WebFetch` on `github.com/<org>/<repo>` — repo metadata (stars, last commit, contributors)
- `WebFetch` on pricing / docs pages — verify specific claims
- `Context7` MCP if connected — authoritative library docs
- `Read` — spec.yaml

Additional research duties triggered by `spec.yaml.aspirational_claims` being non-empty:
- For each aspirational claim of type `foundation` / `future_expansion` / `roi_argument` / `vendor_lock_in_avoidance` / `scalability_promise` — researcher MUST run a prior-art search:
  - `WebSearch "<topic> in-house build vs outsource case study"` — for ROI arguments
  - `WebSearch "<topic> agent framework expansion multi-domain"` — for foundation claims
  - `WebSearch "site:reddit.com <topic> postmortem"` — for honest failure-mode reporting
- Findings go into a per-claim block that report-writer consumes for Section 3.4 audit.

Output files (researcher writes both):
- `$ANALYSIS_DIR/alternatives.md` — one section per design choice, human-readable
- `$ANALYSIS_DIR/matrix.md` — one matrix per design choice, table form with [N] citations

**Quality gate before continuing:** researcher must produce ≥1 matrix per `design_choice` in spec.yaml. If design_choices = 0 (skip flag from stage 1), researcher outputs a file with: "No explicit design choices — no matrices produced. See Diablo's critique for implicit tech questions."

---

## STEP 5 — Verification pass

Invoke skill `verification-pass`. Inputs:
- `$ANALYSIS_DIR/alternatives.md`
- `$ANALYSIS_DIR/matrix.md`

Output:
- `$ANALYSIS_DIR/verification.md`

**Hard gate — decision table:**

| Condition | Action |
|---|---|
| FATAL findings > 0 (existence-unverified / name-mismatch) | STOP, re-invoke researcher with fatal list, max 2 loops. If still failing — go to DRAFT mode (continue pipeline but label final report as `DRAFT — FATAL issues unresolved`). |
| Contradicted findings > 5 | STOP, re-invoke researcher with contradicted list, max 1 loop. If still failing — go to DRAFT mode. |
| Contradicted findings 1–5 | CONTINUE, pass the contradicted list to writing of final report as "Исправления перед отправкой заказчику" section. |
| Coverage ratio < 50% | STOP, report insufficient data, abort pipeline. |
| Coverage ratio 50–70% | CONTINUE, flag for Diablo verification pass. |
| Coverage ratio > 70% | CONTINUE normally. |

After the gate decision: **always announce it explicitly** so the user sees:

> Verification: coverage XX%, FATAL=N, contradicted=M. Decision: CONTINUE / STOP / DRAFT. Continuing to stage 6.

Then immediately start Step 6 (per Pipeline Invariant).

---

## STEP 6 — Diablo on report (Verification mode)

Invoke the `Diablo` agent in **Verification mode**. Inputs:
- `$ANALYSIS_DIR/alternatives.md`
- `$ANALYSIS_DIR/matrix.md`
- `$ANALYSIS_DIR/verification.md`

Output:
- `$ANALYSIS_DIR/devil-verification.md`

This is the second Diablo pass. It attacks the analyst's own work, not the user's TZ. Look for: hallucinations missed by verification-pass, missing axes, weight rationalization, confirmation bias in alt selection, cherry-picked sources.

**BLOCKED verdict enforcement:**

Parse Diablo's output for the Verdict line. If `BLOCKED`:

1. If ≤ 2 loops of researcher re-invocation have been done so far:
   - Collect all DA-F## items from devil-verification.md.
   - Re-invoke `researcher` with brief: "fix these specific findings, do not redo the entire report: <list>". Give access to `$ANALYSIS_DIR/devil-verification.md`.
   - Re-run verification-pass (Step 5) on updated output.
   - Re-run Diablo Verification (this Step 6).
2. If loops exhausted OR Diablo still BLOCKED after 2 loops:
   - Set `FINAL_REPORT_MODE=DRAFT`.
   - Continue to Step 7, but Step 7 instructs report-writer to add a prominent top banner: "⚠ DRAFT — известные проблемы не исправлены, см. раздел «Что требует ответа от инициатора»".

If Diablo verdict is `PROCEED WITH CAUTION`, `FIX FIRST`, or `ACCEPTABLE`: continue to Step 7 immediately.

Regardless of verdict: the pipeline does NOT stop here unless loops are still in progress.

---

## STEP 7 — Final report (via report-writer skill)

Invoke skill `report-writer` (lives at `.claude/skills/report-writer/SKILL.md`). This skill replaces previous usage of built-in `writing-plans` — the latter was a poor fit (it produces implementation plans, not decision reports).

Inputs passed to report-writer:
- `$ANALYSIS_DIR` — the skill will read all 7 intermediate artifacts
- `$SPEC_PATH` — raw TZ for direct quotation in Section 1
- `$LANG` — report language (`ru` / `uk` / `en`)
- `$FINAL_REPORT_MODE` — if `DRAFT` (set by Step 6 when BLOCKED unresolved), skill adds top-banner warning
- Auto-loaded references:
  - `.claude/skills/humanizer/SKILL.md`
  - `.claude/skills/humanizer/references/anti-ai-ru.md` (for ru output)
  - `.claude/skills/spec-normalizer/references/operational-checklist.md` (for grouping operational open questions)

The skill enforces hard rules from its SKILL.md (12 rules): no framework internals in output, no cross-references to other files, resolve internal IDs to plain text, numbered TZ excerpt, glossary for jargon, footnotes (not flat source list), hyperlinks on first mention, anti-AI stylistic scans, political/geographic invariants.

Output:
- `$ANALYSIS_DIR/final-report.md` — **the only user-facing deliverable**

If report-writer produces output that violates the anti-checklist (forbidden words found, internal IDs leaked, etc.) — re-invoke with the specific violations listed.

---

## STEP 8 — Announce completion

Tell the user ONE clear message. Do NOT list the internal files (they're for audit only, not for the reader):

```
Анализ готов.

Финальный отчёт: `specs/analysis/<slug>/final-report.md`
<if PDF_AT_END=yes after Step 9: "PDF: `specs/analysis/<slug>/final-report.pdf`">
<if FINAL_REPORT_MODE=DRAFT: "⚠ Режим DRAFT — известные проблемы не исправлены, открой отчёт и посмотри раздел 'Что требует ответа от инициатора'.">

Ключевой вывод (одним абзацем):
<report-writer заполняет из Section 2 final-report.md — первые 2-3 предложения>
```

Технические артефакты пайплайна (spec.yaml, gaps.md, matrix.md, и прочие) остаются на диске для аудита, но читателю отчёта не показываются.

---

## STEP 9 — PDF output

**Execute ONLY if `PDF_AT_END=yes`** (set during Step 0 preamble or via `--pdf` flag). Otherwise skip — user can always generate PDF later on demand.

If executing:

Pre-flight check: verify `uv` is installed.
```bash
which uv
```
If missing — tell user: "Для PDF нужен `uv`. Установить: `brew install uv`. Финальный отчёт (.md) уже готов, PDF можно сгенерировать после установки командой из `.claude/skills/pdf-creator/SKILL.md`." Skip PDF step.

If `uv` present, render ONLY `final-report.md`. **ALWAYS include `DYLD_LIBRARY_PATH=/opt/homebrew/lib` prefix on macOS** — without it, `uv`'s isolated Python environment cannot find libgobject/libpango from Homebrew:

```bash
DYLD_LIBRARY_PATH=/opt/homebrew/lib uv run --with weasyprint --with markdown \
    .claude/skills/pdf-creator/scripts/md_to_pdf.py \
    --lang $LANG \
    specs/analysis/<slug>/final-report.md
```

On Linux hosts `DYLD_LIBRARY_PATH` is macOS-only and will be ignored — that's fine, the command still works.

Output: `specs/analysis/<slug>/final-report.pdf` — single self-contained PDF with TOC, footnotes, hyperlinks, page numbers.

Do NOT render the other `.md` files as PDFs. The deliverable is one document.

If weasyprint fails with `cannot load library 'libgobject-2.0.0'` even with the prefix:
1. Check: `brew list | grep pango` — is pango installed?
2. If not: `brew install pango gdk-pixbuf libffi`
3. Retry with the prefixed command.

Report exact error to user; the markdown version is still valid if PDF fails.

---

## Failure modes and recovery

- **spec-normalizer produces invalid YAML** → re-invoke with "your previous output didn't parse, fix: <error>"
- **researcher didn't do any web lookups** → re-invoke with explicit "you MUST run `WebSearch` at least once per decision AND `WebFetch` on each candidate's github.com page — parametric recall alone is a HARD invariant violation per CLAUDE.md"
- **Inline mode picks the wrong block** (e.g., pipeline grabs a prior chat message that wasn't the TZ) → before proceeding to Step 1, confirm with user: "Found this as the TZ (first 200 chars): `<excerpt>`. Right one, or did you mean a different message?" Only continue after user confirms.
- **Ambiguous product still ambiguous after user clarification** → save as `[internal, no public URL]` in `product-clarifications.md`. researcher scores remaining axes but marks product-specific cells as `?` and flags in alternatives.md.
- **Verification loop diverges** (FATAL found again after 2 fix attempts) → switch to DRAFT mode (set FINAL_REPORT_MODE=DRAFT), continue to Step 6+7. Final report carries a top-banner warning.
- **report-writer violates anti-checklist** (forbidden words found via grep) → re-invoke with specific violation list. Max 2 loops. If still violating — save anyway but print warning to user: "final-report.md содержит <N> нарушений anti-checklist — смотри grep результат."
- **PDF generation fails** (uv missing / weasyprint error) → report error, leave .md version as deliverable, continue to Step 8 without PDF.

---

## What this command does NOT do

- Does not write code or prototype anything.
- Does not make the decision for the user — outputs compromises, reader chooses.
- Does not enforce an overall "approve / reject" verdict on the TZ — findings are per-issue, final-report summarizes.
- Does not modify the user's TZ file. Read-only input.
- Does not expose pipeline internals (agent names, skill names, stage numbers) to the final report's reader.
- Does not recommend Russian services (see CLAUDE.md Invariant 0).
- Does not use RUB or Moscow time in any output.
