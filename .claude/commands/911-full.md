---
name: 911-full
description: 'FULL cheatsheet — every template command grouped by use case. ~14K tokens. Use only when /911 (mini) wasnt enough. Default to /911 first.'
allowed-tools: Read
model: sonnet
---

**INSTRUCTIONS:**

1. **Read the project's language setting** — check `CLAUDE.md` `## Language` section. Common values: `English`, `Russian`, `Ukrainian`, `Bulgarian`.

2. **Print the cheatsheet below** to the user. Do NOT summarize. Do NOT ask "What's next?". Do NOT write anything before or after the cheatsheet.

3. **If language is NOT English** — translate the prose to that language while printing:
   - **Translate**: table descriptions, "when to use" hints, decision-tree text, hard-rules text, section header subtitles
   - **DO NOT translate**: command names (`/todo`, `/fix`, etc.), file paths (`docs/RULES.md`), tool names (Diablo, Rex, code-reviewer), code blocks, frontmatter, technical abbreviations (TDD, ADR, PRD, MCP, AC, BQC), Outline collection names (`Knowledge Base / Fails`)
   - **Keep table structure intact** — row count and columns unchanged

4. The user typed `/911` because they forgot what commands exist. They want to SEE the cheatsheet, not be told it's ready.

5. If language setting is unclear or missing → default to English.

---

# 911 — Template command cheatsheet

> If you forgot what `/<thing>` does — run `/911`. If you forgot whether a command exists — run `/911`. Default destination when stuck.

---

## 🟢 Daily (memorize these 4)

| Command | One-liner | When to use |
|---|---|---|
| `/todo add <description>` | Spec-first task planning with grill-me + Diablo | New task surfaced; need executable T-NNN with risk matrix and AC. Skip if /decompose just generated tasks. |
| `/orchestrate` | Autonomous backlog execution; reads TASK.md, runs full pipeline per task (test-writer → static → tests → code-reviewer → perf → security → Diablo → commit) | Want to pick up the next backlog task and ship end-to-end without micro-managing |
| `/general <question>` | Verified Q&A with mandatory evidence-first; no speculation | Anything informational: «why does X happen?», «how does Y work?», «what's in production now?» |
| `/rule <statement>` | Capture business rule (rate / fee / formula / policy) into docs/RULES.md | When a new business rule comes up — INSTEAD of remembering it. Auto-publishes to Outline `Project: <name> / Rules` |

## 🟡 Setup & init (rare, mostly one-time)

| Command | One-liner | When to use |
|---|---|---|
| `/setup` | Wizard for: Fresh install / Reconfigure MCP / Verify health / Bootstrap project collection / Register loops / Setup launchd schedules / Migrate v2→v3 | First time on a machine; after token rotation; after migration; periodic health check |
| `/init-project [path]` | Scaffold new project from template (interactive) | Only when starting a new project. Once per project. |
| `/911` | This cheatsheet | Right now |

## 🔵 Greenfield (idea → build) & decomposition

Full pipeline: `docs/rules-references/greenfield-pipeline.md`. Canonical chain: `/market-research → /value-prop → /design-system → /decompose → /orchestrate`.

**Stage 0 — validate the idea** (product-method — Jobs-To-Be-Done, RICE, Riskiest-Assumption-Test)

| Command | One-liner | When to use |
|---|---|---|
| `/market-research <idea>` | GO/NARROW/PIVOT verdict: segments, market size, competitors-by-Job, pivots | New idea, unsure it's worth building. Front door for greenfield. |
| `/value-prop <segment>` | Strongest testable value prop + RICE + Riskiest-Assumption-Test cards | Idea validated, need the pitch + priorities |
| `/diagnose` | Live product: weak links to profit + growth moves | Existing product with users; «what next / a metric dropped» |
| `/advisor` | Conversational product advisor; routes to the right producer skill | Not sure which greenfield step you need |
| `/ce-ideate <theme>` | Generate + score raw ideas | Need options before choosing one |
| `/analyze-interviews` | Mine customer interviews → Jobs / segments | You already have interview transcripts |
| `/go-to-market` | Landing + ad copy + growth plan for one segment | After the PRD, for launch communication |

**Stage 1 — analyze into a vetted spec** (requirements-analyzer — ISO/IEC/IEEE 29148, evidence-required, Diablo attacks twice)

| Command | One-liner | When to use |
|---|---|---|
| `/design-system <goal>` | Goal, no spec → system-design report + build-vs-buy + min/mid/max scope | Greenfield, want rigor + build-vs-buy. **Deep alternative to `/intent`.** |
| `/analyze-spec <TZ file \| paste>` | Raw spec → normalized + gaps + decision matrices + verification + report (`--pdf`) | You already have a written TZ / spec document |
| `/product-requirements <segment+value>` | Build-ready PRD with ~90% edge cases | Segment + value settled, want the build spec |
| `/intent <vague-idea>` | Compact idea → PRD (office-hours + 5-min recon + Diablo); routes to `/design-system` for depth | Quick in-template path when the idea is already clear |

**Stage 2 — decompose & build**

| Command | One-liner | When to use |
|---|---|---|
| `/decompose <PRD \| report>` | → Architecture (ADRs) → Epics → Tasks via 4 Diablo gates | After a PRD / analysis is ready. Feeds /orchestrate. |
| `/quick-plan <description>` | Lightweight implementation plan saved to specs/ | Quick informal plan; not for production specs. Use /todo add or the greenfield chain for real work. |

## 🔴 On-demand (rare, but important when needed)

| Command | One-liner | When to use |
|---|---|---|
| `/fix <bug-description \| #issue>` | Disciplined bug fix: failing-test-first + Outline check + Diablo + auto-publish F-NNN | Real bug. NOT for typos — for those just edit. |
| `/review [scope]` | Full pre-merge pipeline (this template's custom command): static pre-pass (run_static.sh incl. file/func size, complexity, cognitive, duplication) + code-reviewer + Rex + impeccable + Diablo + blind verification | Before merging changes. If unsure, use /review. Shadows the newer built-in `/review` (which is GitHub-PR review). |
| `/code-review [level]` \| `/code-review ultra` | Claude Code **built-in**: reviews the current working diff (low→max effort); `ultra` = deep multi-agent cloud review of the branch/PR | Cross-check the template's `/review`, or when you want the built-in diff review. `ultra` for a thorough billed pass on security-critical branches. |
| `/da [spec\|plan\|impl\|review] [target]` | Explicit Diablo invocation | Hand-pick: attack a spec/plan/impl when you don't trust auto-flows |
| `/improve-arch [path]` | Refactor for depth (Ousterhout-style) — ADR generation, module deepening | When code feels shallow / hard-to-test / needs restructure. NOT for routine bugfix. |
| `/council <question>` | Opus + Sonnet parallel deliberation; surfaces disagreement | Architecture forks, build-vs-buy, security-critical decisions where one model's bias matters |
| `/codex:review` / `/codex:adversarial-review` | OpenAI Codex CLI second opinion (different model family) | Cross-model independent review. Run on security-critical changes; pre-deploy on auth/payments |
| `/gaps [missing\|modern\|both\|vs-prd\|domain\|tests\|<path>]` | Service-level audit. Modes: missing (vs SaaS checklist), modern (vs 2025-26 idioms), vs-prd (promised-but-absent), **domain** (business-logic correctness vs RULES.md + BA/QA-hacker robustness, FMEA-scored), **tests** (does the suite hunt bugs — test smells + anti-regression + opt-in mutation testing; works with NO docs). Bare `/gaps` asks which. | Periodic checkup; before release; numbers wrong (domain); tests feel weak (tests) |
| `/global-audit [scope]` | Whole-service audit: 11 read-only domain lenses in parallel (incl. correctness-vs-RULES + robustness/HAZOP) → dedup → FMEA-score (S·O·D, incl. Detection axis) → blind-verify → Diablo gate → one report. Bare `/global-audit` asks scope + depth. | Deep breadth-first audit before a release, or when you want every angle at once. Read-only. |
| `/canary <production_url>` | Post-deploy health check: route probes + console errors + drift vs baseline | After deploy. First run saves baseline. Schedulable via launchd for periodic monitoring. |
| `/plan-devex-review <PRD\|spec\|live-tool>` | DX review for APIs/CLIs/SDKs (NOT end-user products). 7-dim score + TTHW benchmark | Building developer-facing tool. 3 modes: EXPANSION (greenfield), POLISH (mature), TRIAGE (broken) |
| `/test [backend\|frontend\|e2e\|all]` | Run test suites (auto-detects stack from STACK.md) | Direct test runner. Used internally by /fix and /orchestrate. |

## 🟣 Auto via launchd (you don't invoke directly)

| Command | Cadence | What |
|---|---|---|
| `/report [today\|yesterday]` | Daily 23:00 (via launchd) | Daily status: what was done, in progress, blocked. Publishes to Outline `Knowledge Base / Daily Status`. |
| `/docs sync --publish` | Mon 09:00 weekly (via launchd) | Audit + sync ARCHITECTURE/API/Runbook from real code, publish to Outline `Project: <name>` |
| `/self-audit` | Fri 10:00 weekly (via launchd) | Local process improvement audit; finds workflow violations, suggests diff-ready fixes |
| `/self-audit --global` | 1st & 15th 11:00 bi-weekly (via launchd) | Cross-project process audit via Outline aggregation |
| `/canary <url>` | Optional: every 30 min business hours | Post-deploy health probes + drift detection vs baseline |

## 🟤 Internal (called by other commands; don't invoke directly)

| Command | Called by |
|---|---|
| `/todo done <id>` | After T-NNN completion |
| `/todo start <id>` | When picking up a backlog task |
| `/todo list` | When checking backlog |

---

## Knowledge Base sources (Outline)

| Looking for... | Search in... |
|---|---|
| Past failures across projects | `Knowledge Base / Fails` (auto-populated by /fix) |
| Validated patterns | `Knowledge Base / Best Practices` (auto + ask-mode) |
| Daily status timeline | `Knowledge Base / Daily Status` (auto via /report) |
| One-liners and tricks | `Knowledge Base / Tricks` (manual) |
| This project's architecture | `Project: <name> / Architecture` (auto via /docs sync) |
| This project's PRDs | `Project: <name> / PRDs` (auto via /intent) |
| This project's ADRs | `Project: <name> / Decisions` (auto via /decompose, /improve-arch) |
| This project's Epics | `Project: <name> / Epics` (auto via /decompose) |
| This project's business rules | `Project: <name> / Rules` (auto via /rule) |

Search via `mcp__outline__list_documents` (preferred) or `bin/outline.sh search` (fallback). Commands `/general`, `/fix`, `/todo`, `/orchestrate` already do read-before-start automatically.

---

## When stuck — decision tree

```
Want to know something          → /general
Found a bug                      → /fix
Is a new idea worth building?    → /market-research → /value-prop  (validate before building)
Existing product, what next?     → /diagnose
Have a goal, no spec (deep)      → /design-system → /decompose
Have a vague idea (quick)        → /intent → /decompose  (office-hours interrogation first)
Have a written spec / TZ         → /analyze-spec → /decompose
Segment + value settled          → /product-requirements → /decompose
Have requirements already        → /decompose
Have one specific task           → /todo add → /orchestrate
Want to ship something           → /orchestrate
Code feels wrong                 → /improve-arch
Need a sanity check              → /gaps            (asks: what to check)
Are the tests actually any good?  → /gaps            (pick "tests"; needs NO docs)
Numbers / reports look wrong      → /gaps            (pick "domain")
Audit whole service, every angle → /global-audit    (11 parallel lenses, FMEA-ranked)
Architectural decision stuck     → /council
Just deployed — check prod ok?   → /canary <production_url>
Building API/CLI/SDK for devs    → /plan-devex-review
Security-critical PR             → /review + /code-review ultra + /codex:review (cross-model)
Pre-deploy auth/payments         → /codex:adversarial-review
Forgot what's where              → /911 (you're here)
```

> **Interactive routing:** multi-mode commands (`/gaps`, `/global-audit`, `/docs`, `/da`) ask a
> plain-language menu when you type them bare — no need to recall modes/flags. Give the mode explicitly
> to skip the menu (`/gaps domain`, `/da spec T-042`). `/review` just reviews recent changes by default.
> Convention: `docs/rules-references/interactive-routing.md`.

---

## Claude Code built-ins worth knowing (not template commands)

| Command | What |
|---|---|
| `/code-review [level] \| ultra` | Built-in diff review; `ultra` = deep multi-agent cloud review (see On-demand above). Distinct from this template's custom `/review`. |
| `/dataviz` | Built-in: generate charts / dashboards with a consistent design system |
| `/doctor` | Built-in: diagnose the Claude Code install / config health |
| `/config <key=value>` | Built-in: read/set Claude Code settings |
| `/rewind` | Built-in: restore a native checkpoint (file edits are auto-insured) |
| `/goal <condition>` | Built-in: loop until a measurable condition holds (see workflow.md). Required for /orchestrate. |

> The Workflow tool (multi-agent orchestration) opts in via the keyword **`ultracode`** in your prompt, not «workflow». Build scripts with the `workflow-planner` skill.

---

## Hard rules to remember (live in workflow.md)

1. **Persistence**: «записал/added to TODO» BANNED without tool call. Claim = action.
2. **Business logic**: numerical answers MUST cite R-NNN from `docs/RULES.md` or refuse.
3. **TDD**: every code change has a failing test first. Static analysis after green.
4. **E2E for frontend**: Playwright `.spec.ts` mandatory; chrome-MCP is for debug only.
5. **Checkpoints**: file edits are insured by native checkpoints (`/rewind`); `[BACKUP]` commit only before ops they don't cover (migrations, mass script edits, rm, deploy).
6. **Commit prefix**: `[BACKUP|CHANGE|META|HANDOFF|PROCESS|RULES|SEC|FIX]` — hook blocks otherwise.
7. **Outline read-before-start**: /fix /todo /orchestrate check KB before working. Reuse, don't re-derive.
