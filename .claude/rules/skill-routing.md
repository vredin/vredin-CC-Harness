# Skill Routing — v3

Before non-trivial task: check this. Most asks → slash command. Routing only when free-form ask doesn't fit a command.

**Load skill** = read `.claude/skills/<name>/SKILL.md`, apply.
**Load sub-skill** = read `.claude/skills/<parent>/<sub>.md`.
**Invoke agent** = `Agent(subagent_type=..., prompt=..., model=...)` with def from `.claude/agents/<name>.md`.

---

## Interactive routing (bare command asks, never guesses)

Multi-mode commands (`/gaps`, `/global-audit`, `/review`, `/da`, `/ui`, `/docs`) follow one rule: if the
invocation doesn't supply the mode/scope needed to act, the command opens with an `AskUserQuestion`
menu (plain-language options, recommended first) and routes on the pick — never silently defaults, never
dumps help text. One memorable entry point per job, self-clarifying: this is why the command list stays
small. Full convention: `docs/rules-references/interactive-routing.md`.

## Quick Map: free-form intent → slash command

If intent maps here, USE COMMAND. Don't load skills directly.

| Free-form ask | Command | Notes |
|---|---|---|
| "fix bug X" | `/fix <bug>` | Failing-test-first + Diablo + STACK.md |
| "add feature X" | `/todo add <description>` | grill-me + spec + Diablo before backlog |
| "is this idea worth building" / "size the market" / "which segment" | `/market-research <idea>` | GO/NARROW/PIVOT verdict. Front door for a NEW idea (product-method, Jobs-To-Be-Done). |
| "strongest value prop" / "what to test first" | `/value-prop <segment>` | Value hypothesis + RICE + Riskiest-Assumption-Test cards. |
| "diagnose my product" / "what should I do next" / "a metric dropped" | `/diagnose` | Front door for a LIVE product with users. |
| "хочу систему X" (idea, no spec → vetted design) | `/design-system <goal>` | Deep: goal → system-design report + build-vs-buy. **Rigorous alternative to `/intent`.** Full chain: docs/rules-references/greenfield-pipeline.md |
| "analyze this TZ / spec" | `/analyze-spec <file\|paste>` | Normalized spec + gaps + decision matrices + verification + report (`--pdf`). |
| "review my changes" | `/review [scope]` | This template's custom pipeline: run_static.sh static pre-pass + code-reviewer + Rex + impeccable detector + Diablo + blind verification. Shadows the newer built-in `/review` (GitHub-PR review). |
| "deep/cloud review of my diff" | `/code-review [level]` / `/code-review ultra` | Claude Code **built-in**: current-diff review (low→max); `ultra` = deep multi-agent cloud review. Cross-check for the template `/review`, or for security-critical branches. |
| "audit the whole service from every angle" / "run all the lenses" / "global audit" / "parallel multi-lens audit" | `/global-audit [scope]` | Breadth-first: fans out 11 independent read-only domain LENSES in parallel (layers, security/IDOR, state-sync, errors/empty/offline, data-lifecycle, navigation, invariants/trust-fields, performance, concurrency/races, **correctness-vs-RULES**, **robustness/HAZOP-adversarial**) via the Workflow tool → dedup → FMEA-score (S·O·D=RPN, Detection axis) → blind-verify CRITICAL/HIGH → Diablo gate → one report. Folds in `/gaps domain`'s correctness+robustness as lenses 10–11. Distinct from `/review` (depth-first on a diff) and `/gaps` (focused/sequential). Read-only, never fixes. `--quick` = core 6 lenses. |
| "explain why X" / "investigate" | `/general <question>` | Evidence-first, no speculation, Outline KB |
| "give me daily report" | `/report [period]` | → Outline `Knowledge Base / Daily Status` |
| "how could this be better" / "what should we build next" / "propose improvements" / "what do competitors do" / "business + logic improvements" | `/gaps improve` | OFFENSIVE audit — proposes improvements (business moves, new features, logic improvements) + studies competitors/similar-services by-Job, RICE-ranked. Fronts `/diagnose` (product growth) + `/market-research` (competitors) + the `improve` skill (code/roadmap) — no new commands. Proposes only; routes to `/intent` / `/todo add`. Read-only. |
| "are my tests any good" / "do the tests actually catch bugs" / "test quality" / "are tests just mirroring the code" / "mutation testing" | `/gaps tests` | Test-quality audit — works with NO docs (code+tests only). Five layers: static test-smell scan (assertion-free / vacuous / tautology / mock-the-unit / happy-path-only), anti-regression probe, opt-in **mutation testing** (mutmut/stryker → surviving mutants = shippable bugs), real-integration/contract check, coverage-as-floor. FMEA-scored (Detection axis = test effectiveness). Findings → `/fix` / `test-writer`. Read-only on source. Ref: `docs/rules-references/test-quality-audit.md`. |
| "is this number/report right" / "the numbers look off" / "check my money/metrics/funnel logic" / "audit business-logic correctness" / "what if bad input / retry / cancel / abuse this feature" | `/gaps domain` | Two-lens business oracle. **Correctness:** cross-checks money/date/metric/funnel computations against `docs/RULES.md` + real domain traps (USD-as-UAH, `created_at` vs `date_start`, `<=` vs `<`, score-scale) → RULE-CONFLICTS (→`/fix`), UNVERIFIABLE (→`/rule`), oracle-coverage ratio. **Robustness:** walks the BA+QA-hacker catalog (`docs/rules-references/adversarial-interrogation.md`, classes A–K: bad/empty/wrong-type params, retry-idempotency, mid-flow cancel, token/link expiry, no-rate-limit flooding, races) → 🔴 GAP / 🟡 VERIFY / ✅ HANDLED + robustness score. Closes the #1 empirical blind spot (~70 real fails) + lifecycle/expiry gaps. Read-only. Build-time half lives in `/todo` grill-me. |
| "what should I work on" / "find pending work" / "morning triage" / "what's broken or queued" | `/triage` | Discovery loop: CI failures + open issues + recent commits + TODO/FIXME + stale/blocked → seeds `.claude/session-inbox.md` as `IDEA-N`. Read-only, never implements. Distinct from `/gaps` (deep quality-vs-ideal audit); `/triage` = live operational signals. Schedulable `/loop "0 9 * * 1-5" /triage`. |
| "audit docs / find drift" | `/docs audit` | Read-only |
| "improve architecture" | `/improve-arch [path]` | improve-codebase-architecture skill |
| "should I X or Y" (architecture) | `/council <question>` | Opus + Sonnet parallel |
| "attack this plan" | `/da <mode> <target>` | Direct Diablo |
| "ship to prod" / "deploy" | `/deploy` | Full pipeline + verify-live + E2E + auto-rollback (v3.1+) |
| ANY UI/design ask — "explore/build/redesign/polish/critique/audit a UI", "make it distinctive/pro", "fix spacing/colors/typography", "remove AI look", "why can't the user find X", "what should read first" | **`/ui <plain words>`** | **Single front door.** Classifies intent → routes to the right engine (explore / build / polish / critique / reason / reference). User never needs to recall `impeccable`, `/ui-explore`, or sub-ops. Those still work directly, but `/ui` fronts them. |
| "audit CLAUDE.md" / "is CLAUDE.md outdated" | claude-md-improver skill | Auto-invoked; or `/revise-claude-md` to capture session learnings (v3.1+) |
| "show me token usage" / "session cost stats" | session-report skill | Generates HTML report from `~/.claude/projects/` (v3.1+) |
| "keep working until X" / "don't stop until Y" / non-trivial task with explicit done-state | `/goal <measurable condition>` | Built-in (v2.1.139+). Loops until evaluator confirms condition holds in transcript. Required for MEDIUM/LARGE — see workflow.md § Definition of Done Discipline. |
| "plan a task" / "atomic plan" / "parallelize this" / "do we need a workflow here" / "break into parallel branches" | `workflow-planner` skill | Decides workflow-vs-linear (applicability gate), writes plan + ready-to-run JS for the Workflow tool. One-off orchestration, NOT reusable agents. Opt-in run only. |

---

## Routing Table (only when no command fits)

### Greenfield: new product / idea → build (vendored: product-method + requirements-analyzer)
Three stages; skip to whichever matches the user's starting point.
- **Stage 0 — validate the idea** (product-method, Jobs-To-Be-Done):
  - New idea, unsure if worth building → `/market-research` (GO/NARROW/PIVOT + segments + market size).
  - Have a segment, need the pitch → `/value-prop` (RICE + RAT).
  - Live product with users → `/diagnose` (weak links + growth moves). Router/teacher → `/advisor`.
  - Generate raw ideas → `/ce-ideate`. Mine interviews → `/analyze-interviews`. Launch copy → `/go-to-market`.
- **Stage 1 — analyze into a vetted spec** (requirements-analyzer, ISO/IEC/IEEE 29148, evidence-required, Diablo×2):
  - Only a goal, no spec → `/design-system <goal>` (system-design + build-vs-buy). Deep alternative to `/intent`.
  - Have a TZ/spec doc → `/analyze-spec <file|paste>` (gaps + decision matrices + verification + report, `--pdf`).
  - Segment+value known → `/product-requirements` (build-ready PRD, ~90% edge cases).
- **Stage 2 — decompose & build** (template): `/decompose` → ADRs + epics + tasks → `/orchestrate`.
- Canonical chain: `/market-research → /value-prop → /design-system → /decompose → /orchestrate`.
- Optional external (NOT vendored): **Trends-MCP** (trend signals, needs key), **ideafactory** (local web idea-engine). Full contract: `docs/rules-references/greenfield-pipeline.md`.
- `/intent` is the compact in-template shortcut when the idea is already clear; for depth it routes to `/design-system`.

### New feature / module
Load: `planning` (sub: brainstorming → idea-atomizer → writing-plans). Architecture trade-offs/ADR format = built-in model knowledge. Agents: `Diablo`.
- Brainstorm requirement → spec in `docs/specs/T-NNN-slug.md` → DA spec attack before backlog
- Or just `/todo add` (encapsulates this)

### Bug fix
Load: `systematic-debugging` · `anti-best-practice`. Agents: `Diablo`.
- Check `docs/FAILS.md` AND Outline `Knowledge Base / Fails` for past failures FIRST
- Root cause before fix. Failing test → confirm fail → fix.
- Non-obvious fix → F-NNN to Outline KB.
- Or use `/fix`.

### Code review / pre-commit
Load: `anti-best-practice` (clean-code standards = built-in model knowledge). Agents: `Diablo` · `code-reviewer` · `Rex` (security). Design/a11y → impeccable detector (auto in /review); perf → built-in review engine.
- Or use `/review`.
- For security-critical code: also `/codex:review` (cross-model second opinion).
- For pre-deploy on auth/payments: also `/codex:adversarial-review`.

### DX review (API / CLI / SDK / library — for OTHER developers)
Use `/plan-devex-review` (interactive, scores 7 DX dimensions: install/TTHW/errors/docs/reversibility/composability/recovery).
- Modes: DX_EXPANSION (greenfield), DX_POLISH (mature), DX_TRIAGE (broken).
- Outputs requirements to PRD §13 OR friction list to docs/dx-audit/<date>.md.

### Post-deploy health check
Use `/canary <production_url>` — probe critical routes, catch JS errors, response time regressions, console errors.
- First run saves baseline. Subsequent runs compare drift.
- Schedulable via launchd for periodic monitoring.

### Refactor (architecture-level)
Load: `improve-codebase-architecture` (sub: DEEPENING.md, INTERFACE-DESIGN.md, LANGUAGE.md).
- LANGUAGE.md glossary exact: module/interface/depth/seam/adapter
- No relitigating `docs/adr/` ADRs
- Adapter threshold: 1=hypothetical seam (skip), 2=real
- Or use `/improve-arch`.

### Refactor (small, behavior-preserving)
Load: `planning` (sub: writing-plans). Clean-code standards = built-in model knowledge.
- Plan first. BACKUP before. No behavior change.

### Writing tests
Load: `tdd` (refs: testing-anti-patterns.md, jest-patterns.md, verify-before-done.md). Agents: `test-writer`. Deep QA/adversarial scenarios → `Rex`.
- Red → Green → Refactor
- Anti-Regression: `git revert` impl → test must fail

### Debug test failure / flaky
Load: `systematic-debugging` · `anti-best-practice`.
- Check Outline KB + `docs/FAILS.md` for exact symptom. Root cause before fix.

### Stress-test plan / adversarial design
Load: `grill-me` (questions in batches of up to 3; second batch only if answers opened new ground).
- Recommended answer per question. Defer to codebase exploration when possible.
- Or as part of `/todo add` STEP 1.

### Tear apart proposal
Load: `planning/idea-atomizer.md`. Agents: `Diablo`.
- Decompose to atoms. Stress-test each for hidden assumptions.

### Long session (context > 50%)
No skill load needed (context-compression retired — procedure below is the whole rule).
- Write `docs/handoff.md`. `/compact`. Next session reads handoff first.

### Security-sensitive (auth/permissions/secrets/payments/uploads)
Load: `security-scan` (refs: api-security, auth, crypto, build-time-security). Agents: `Rex`.
- Mode: FULL (Red+Blue) default. RED pre-deploy. BLUE post-fix.
- Pipeline: RECON → TAINT → JUDGE → EXPLOIT → REPORT
- CRITICAL flagged immediately, scan continues (no halt).

### Dep update / package audit
Load: `security-scan/references/build-time-security.md` + `docs/rules-references/security-toolchain.md`. Agents: `Rex` (BLUE + supply chain checklist).
- **Automatic CVE gate** — any change to a dependency manifest (`requirements*.txt`/`pyproject.toml`/`uv.lock`/`package.json`/`*-lock.*`) triggers `osv-scanner` + `pip-audit`/`npm audit` in `/review` STEP 2 and `/deploy` pre-flight; **CRITICAL/HIGH CVE BLOCKS** (fix/upgrade or accepted-risk with Diablo verdict). Binary absent → prints SKIPPED, never a silent pass.
- Lockfile committed. GitHub Actions pinned `@<sha>`, not `@main`/`@v1`. (Trivy binary itself: SHA-pin — March-2026 channel compromise.)

### API design / new endpoints
Load: `security-scan/references/build-time-security.md`. API design principles = built-in model knowledge.
- Contract-first (schema before impl). Validate at boundaries (Pydantic/Zod). Circuit breaker + retry for external.

### Docker / containerization
Built-in model knowledge (docker-expert / deploy-strategies skills retired).
- Multi-stage. Non-root. Pinned versions. Health checks. Secrets via env, never baked.

### E2E / webapp test
Load: `webapp-testing` · `tdd/references/jest-patterns.md`.
- Playwright for UI. Critical user flows end-to-end.

### Git workflow issues
Built-in model knowledge (git-advanced-workflows skill retired). Interactive rebase, cherry-pick, bisect, worktrees.

### Deploy
**Prefer `/deploy`** (v3.1+) — auto-reads `docs/STACK.md` deploy_* fields, applies S9-S12 fixes (env.bak cleanup, /health SHA verify-live, auto-rollback on post-migration fail, E2E opt-in). Then read `docs/DEPLOY.md` for context.
- Blue-green / canary patterns = built-in model knowledge (deploy-strategies skill retired)
- Zero-downtime DB migrations: expand → migrate → contract
- Invoke `Rex` RED before (see workflow.md Deploy Protocol).
- For staged rollout instead of all-at-once: `/canary` after `/deploy`.

### UI / frontend design (front door: `/ui`)
**`/ui <plain words>`** is the ONE command for all UI/design work. The user describes the goal;
`/ui` classifies intent and routes to the right engine, loading the correct layers automatically.
Users are never expected to recall the engines below. Full command: `.claude/commands/ui.md`.

`/ui` routes to these engines (invokable directly too, but you don't have to remember them):
- **`impeccable`** (global skill, Apache 2.0, Rex-vetted) — build/redesign/polish/critique/audit (23 ops) + a 44-rule deterministic offline slop detector. Contract: `docs/rules-references/frontend-impeccable.md`. The detector (`npx impeccable detect --json <files>`, offline) is auto-wired into `/review` STEP 4.5, `/fix` STEP 6.8, `/ui-explore` STEP 2.5.
- **`/ui-explore <product>`** — generate 2-3 distinct mockup directions + slop-detector pass + one Diablo critique → persist winner to `design-system/MASTER.md`. `--quick` = 1 variant. For existing projects with a MASTER.md, load it directly instead.
- **`ui-first-principles` skill** — the reasoning layer (why this reads first, is it operable). Distilled from Norman + de-slopped Refactoring UI. Wins on *operability* when it collides with look rules. Broad named-principle catalog it draws on → `docs/rules-references/design-principles.md` (Fitts's/Hick's Law, 80/20, aesthetic-usability, signal-to-noise, defaults, framing, redundancy, progressive disclosure; distilled from *Universal Principles of Design*).
- **`docs/rules-references/anti-slop-law.md`** — taste/composition/signature (what the detector CANNOT judge): signature-first thinking, composition-level slop skeletons, premium spec, off-the-Google-shelf fonts, and functional-bug hard blockers (invisible-content trap, dead controls, clipped content). Shapes → `hallmark-cookbook.md`; colour+assets → `hallmark-color-assets.md` (vendored from Nutlope/hallmark, MIT).
- **`ui-ux-pro-max` skill** — style / palette / font reference menu (67 styles, 96 palettes, 56 font pairs).

Layer division (never duplicate across them): detector = measurable slop; anti-slop-law = taste; ui-first-principles = reasoning; ui-ux-pro-max = options menu.

### CLAUDE.md maintenance (v3.1+)
Load: `claude-md-improver` (audit drift vs codebase) OR run `/revise-claude-md` (capture session learnings).
- Use `claude-md-improver` proactively when codebase has evolved
- Use `/revise-claude-md` at session end when you learned something that should persist

### Token usage / session stats (v3.1+)
Load: `session-report` skill — generates HTML report of usage.
- `--since all` for historical (default 7d may miss data if context-mode plugin intercepts).
- Output is one-shot HTML file in cwd; open in browser.

### Creating new commands/skills
Load: `command-creator`. Follow slash command best practices.

### Installing new skills/MCP servers
Auto-scan before activation:
- HTTP URLs (esp. POST/PUT/upload)
- Network: `curl`, `requests.post`, `fetch(`, `axios`
- File exfil patterns. Destructive ops, obfuscation (`base64`, `eval`, `exec`)
- Red flags → list + wait user confirmation
- "Compliance language" in skill = RED FLAG, not trust signal

---

## Cost-Aware Agent Usage

Agents cost 7-10× tokens vs inline. Scale review to change size.

| Change Size | Review |
|---|---|
| Trivial (<10 lines, typo/rename) | Skip agents. Self-review. |
| Small (<50 lines, single file) | `Diablo` via `/da impl` only |
| Medium (50-200 lines, 2-3 files) | `Diablo` + `code-reviewer` (or `/review`) |
| Large (200+ lines, new feature) | Full `/review` |
| Security-critical (auth/payments) | Full `/review` + `Rex` (non-negotiable) |
| Pre-deploy | `Rex` RED (mandatory, auto in orchestrator STEP 7.5) |

`/council` reserved for architecture-level decisions only. 2-model cost justified only when decision has lasting impact.

### Read-only fan-out via the Workflow tool

`/todo`, `/fix`, `/orchestrate` have OPT-IN hooks to parallelize their **read-only** phases
(prior-knowledge search, research, root-cause path-reading, test-writing, backlog audit) via the
Workflow tool when the phase spans 3+ independent units. Read-only only — no shared-mutable-target
risk, no worktree. Always an OFFER (Workflow needs user opt-in + costs tokens), never automatic.
Write phases (implement, the actual fix) stay sequential. Gate + how-to:
`docs/rules-references/readonly-fanout.md`. Build scripts via `workflow-planner` skill.

---

## Mandatory Every Task (no routing)

| When | Action |
|---|---|
| Every response | `caveman-distillate` — fragments OK, no filler, answer first |
| Before migrations / mass script edits / rm / deploy | `[BACKUP]` commit first — ordinary file edits are insured by native checkpoints (`/rewind`); see workflow.md § Pre-Change Protocol |
| After non-obvious fix | F-NNN to Outline `Knowledge Base / Fails` (+ local `docs/FAILS.md`) |
| Before any `[CHANGE]` commit | DA impl attack via `/da impl` (auto in `/orchestrate` STEP 7.5) |
| Recurring pattern emerges | Outline `Knowledge Base / Best Practices` (+ local `docs/PATTERNS.md`) |
| Session start | Read `docs/TASK.md` + `docs/handoff.md` (if exists). Other docs on demand. |
| Before deploy | Read `docs/DEPLOY.md` + `docs/RUNBOOK.md` |
| Before deploy | Invoke `Rex` RED — CRITICAL blocks deploy |
| After security fix | Invoke `Rex` BLUE — verify mitigation |
