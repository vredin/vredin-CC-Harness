# Greenfield Pipeline — idea → validated → spec → build

Vendored from two external frameworks into this template (vendor-core integration):
- **product-method** (from `ideas-generator`) — idea discovery + product validation via Jobs-To-Be-Done, RICE, Riskiest-Assumption-Test, unit economics.
- **requirements-analyzer** — rigorous requirements analysis (ISO/IEC/IEEE 29148, evidence-required, Diablo attacks twice, verification pass).

The template already owned the back end (`/decompose` → `/orchestrate`). This wires a proper front end onto it.

## The chain

```
Stage 0  DISCOVER / VALIDATE      product-method (JTBD / RICE / RAT)
  /market-research  → GO / NARROW / PIVOT: segments, market size, competitors-by-Job, pivots
  /value-prop       → strongest testable value prop + RICE + RAT cards
  /diagnose         → (existing product) weak links to profit + growth moves
  /advisor          → conversational advisor; routes to the right producer skill
  /ce-ideate        → generate & score raw ideas   /analyze-interviews → mine interviews
        │
Stage 1  ANALYZE INTO A VETTED SPEC   requirements-analyzer (ISO 29148, evidence, Diablo×2)
  /design-system <goal>   → goal, no spec → system-design report + build-vs-buy + min/mid/max scope
  /analyze-spec <TZ>      → have a spec → normalized spec + gaps + decision matrices + verification + report (--pdf)
  /product-requirements   → segment+value → build-ready PRD (~90% edge cases)
        │
Stage 2  DECOMPOSE & BUILD          template
  /decompose <PRD | report>  → docs/adr/ + docs/epics/ + docs/specs/T-NNN  (4 Diablo gates)
  /orchestrate               → implements the backlog (spec → tests → code → verify → commit → deploy)
```

**Canonical happy path:** `/market-research → /value-prop → /design-system → /decompose → /orchestrate`.

## When to use which entry point

| Situation | Start at |
|---|---|
| Raw idea, unsure it's worth building | `/market-research` |
| Idea validated, need the pitch/priorities | `/value-prop` |
| Existing product with users, "what next?" | `/diagnose` |
| Only a goal, want a rigorous design + build-vs-buy | `/design-system` |
| Already have a written TZ / spec | `/analyze-spec` |
| Segment + value settled, want the build spec | `/product-requirements` |
| Idea already clear, want a quick PRD without leaving the template | `/intent` (compact; routes to `/design-system` for depth) |

## `/intent` vs `/design-system`

`/intent` is the **compact** path (6 office-hours questions → 5-min recon → decision matrix → PRD). `/design-system` is the **deep** path (full requirements analysis: ISO 29148 normalization, evidence-required with sources, Diablo attacks both the spec and the researcher's report, verification pass, optional stakeholder PDF). Both outputs feed `/decompose`. Prefer `/design-system` for fuzzy or high-stakes ideas and when build-vs-buy matters.

## Dedup note (why some skills weren't copied twice)

The template already had `spec-normalizer`, `decision-matrix`, `verification-pass` (identical to requirements-analyzer's — the template descended from it) and its own canonical `diablo` agent. The vendored commands reuse those in place. `humanizer` got requirements-analyzer's `references/anti-ai-ru.md` added (additive) without overwriting the template's SKILL.md. product-method's own `/setup` was **not** vendored (name clash with the template's `/setup`).

## Optional external tools (NOT vendored)

These are not Claude-Code skills, so they stay external and optional. Reference only.

- **Trends-MCP** — cloud MCP server for live trend signals (Google/YouTube/TikTok/Reddit/Amazon/app-installs) to point ideation at real gaps. Free key at `https://trendsmcp.ai` (100 req/mo). Wire via a project's `.mcp.json`. Feeds Stage 0 (`/market-research`, `/ce-ideate`).
- **ideafactory** — a local web app (pnpm, localhost `5173`/`3000`) that turns a direction into a scored tree of dozens of developed ideas. Runs on your machine under your Claude Code subscription. Heavier alternative to `/ce-ideate` for Stage 0. Lives in `ideas-generator/ideafactory/`.

Both are documented in `~/PycharmProjects/tmp/ideas-generator/README.md`.

## Deliverable locations

- product-method skills write to wherever they're told (usually chat + a file on request).
- `/analyze-spec` → `specs/analysis/<slug>/final-report.md` (+ `final-report.pdf` with `--pdf`).
- `/design-system` → wraps `/analyze-spec`, same output shape.
- `/intent` → `docs/prd/PRD-NNN-<slug>.md`.
- `/decompose` → `docs/adr/`, `docs/epics/`, `docs/specs/T-NNN-*.md`.

## Provenance

- product-method canon lives at `product-method/canon/` (project root — skills read it by that relative path).
- Contracts `PRODUCER-CONTRACT.md` / `READABILITY-CONTRACT.md` live at `.claude/skills/` (skills reference them as `../`).
