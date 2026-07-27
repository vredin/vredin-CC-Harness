---
name: gaps
description: 'Project audit — two families. DEFENSIVE ("what is wrong"): missing (vs SaaS checklist), modern (vs 2025-26), vs-prd (promised-but-absent), domain (wrong-but-well-formed money/dates/metrics vs RULES.md + BA/QA-hacker robustness), tests (does the suite hunt bugs; no docs needed). OFFENSIVE ("what to improve"): improve — business + product + logic improvements, competitor/similar-service study, prioritized. Fronts /diagnose + /market-research + the improve skill (no new commands). Bare /gaps asks which. Read-only.'
argument-hint: [missing | modern | both | vs-prd | domain | tests | improve | <subsystem path>]
allowed-tools: Read, Grep, Glob, Bash
model: opus
---

> **Style:** Load `caveman-distillate` skill — terse, structured output.

# /gaps — Service maturity audit

Mode: `${1:-both}` (defensive: `missing`, `modern`, `both`, `vs-prd`, `domain`, `tests`; offensive: `improve`; or a subsystem path like `app/auth/`)

This is **NOT** a code review of recent changes (use `/review` for that).
This is **NOT** an architecture refactor proposal (use `/improve-arch` for that).
This is a **whole-service audit** against a maturity checklist.

---

## STEP −1 — Clarify intent (interactive routing — runs FIRST)

Parse `$ARGUMENTS`. If it already names a mode (`missing` / `modern` / `both` / `vs-prd` / `domain` /
`tests` / `improve`) or a path → skip this step, proceed. If **no argument** → do NOT default silently.
`/gaps` has TWO families, so ask in two levels (per `docs/rules-references/interactive-routing.md`):

**Q1 (single) «Что нужно от аудита?»**
> - 🚀 **Предложить улучшения** (improve) — как сделать продукт лучше: бизнес-ходы, новые фичи, улучшения логики, что делают конкуренты/похожие сервисы. Прибыльно-ориентированный аудит.
> - 🛡 **Найти проблемы** — что не так: тесты / корректность / зрелость / долги.

- Q1 = **improve** → run STEP 3.48, done (skip Q2).
- Q1 = **найти проблемы** → **Q2 (multiSelect) «Что проверяем?»**
  > - Качество тестов (tests) — реально ли тесты ищут баги; без доков *(рекомендовано)*
  > - Правильность + устойчивость (domain) — деньги/отчёты vs RULES.md + BA/QA-хакер
  > - Зрелость сервиса (both) — чего не хватает vs SaaS + что устарело
  > - Обещано в PRD, но нет (vs-prd) — только если есть PRD

Map picks to modes. «Зрелость» = `both`; `/gaps missing`/`modern` explicitly for just one. Accept a path
to scope. Never print raw usage; never proceed until chosen.

---

## STEP 0 — Cross-project knowledge scan (before everything else)

Other projects have already hit problems, fixed them, and documented the experience. This step surfaces that knowledge so the audit doesn't miss issues that are already known to exist across the codebase.

### 0.1 — Recent hot fails

```bash
cat ~/PycharmProjects/Obsidian/hot.md
```

Any F-NNN marked CRITICAL or added in the last 30 days → note as "known cross-project fail, check here too".

### 0.2 — Stack-matched vault scan

Read `docs/STACK.md` first (or infer stack from file structure). Extract technology keywords (e.g. `fastapi`, `sqlalchemy`, `docker`, `pytest`, `spring`, `appium`, `react`).

Then grep vault for each keyword:

```bash
grep -rl "<keyword>" ~/PycharmProjects/Obsidian/fails/
grep -rl "<keyword>" ~/PycharmProjects/Obsidian/patterns/
grep -rl "<keyword>" ~/PycharmProjects/Obsidian/gotchas/
```

For each matching file — read it. Extract: **what went wrong** and **was the fix applied here?**

Rule: if a vault entry describes a problem that was fixed in project X but this project uses the same technology → treat it as a **candidate gap** to verify in STEP 2/3.

### 0.3 — Previous audits of THIS project

```bash
ls docs/audits/ 2>/dev/null | sort | tail -5
```

If previous audit files exist — read the latest one. For each gap marked MISSING or PARTIAL in that audit:
- Check if it has been resolved since then (grep codebase, check git log)
- If still unresolved → carry it forward as a **confirmed recurring gap** (higher priority than a first-time finding)

### 0.4 — Build cross-project gap list

Produce a short internal list (not shown to user yet):
```
CROSS-PROJECT CANDIDATES:
- <gap name> — source: F-NNN / previous audit <date> — still unresolved: yes/no
```

This list feeds into STEP 2 and STEP 3 — each candidate gets verified against the actual codebase.

---

## STEP 1 — Load context

Read in order:
1. `docs/STACK.md` — to know what stack we're auditing (FastAPI? React? GraphQL? Celery?)
2. `docs/CONTEXT.md` — to know domain (payments? auth? data processing?)
3. `docs/CONVENTIONS.md` — to know what user already considers required
4. `docs/adr/` — decisions that the audit should NOT challenge
5. **Best practices KB** — check `outline.enabled` in `.claude/.setup.json`:
   - `enabled: true` (cloud mode) → search Outline `Knowledge Base / Best Practices` via `mcp__outline__list_documents` for `<stack>` patterns
   - `enabled: false` (local-only mode) → grep local vault:
     ```bash
     grep -rl "<stack keyword>" ~/PycharmProjects/Obsidian/patterns/
     grep -rl "<stack keyword>" ~/PycharmProjects/Obsidian/gotchas/
     ```
   - No `.setup.json` (legacy) → try Outline first; fall back to vault grep if MCP unavailable

If any of these are missing — proceed but flag in output.

---

## STEP 2 — Mode `missing` (gap analysis)

Audit the codebase against this checklist. For each item: **PRESENT / PARTIAL / MISSING / N/A**.

### Authentication & sessions
- [ ] Login + register endpoints with rate limiting
- [ ] Password hashing with bcrypt/argon2/scrypt (NOT md5/sha1/sha256)
- [ ] Session management: secure cookies (HttpOnly, Secure, SameSite)
- [ ] Logout invalidates session server-side
- [ ] Password reset with single-use, expiring tokens
- [ ] 2FA / MFA support (or explicit decision against)
- [ ] Account lockout / progressive delays after failed attempts

### API design
- [ ] Versioning strategy (URL or header, picked one and documented)
- [ ] Pagination on every list endpoint (cursor or offset)
- [ ] Rate limiting on every endpoint (or explicit per-endpoint exception)
- [ ] Request validation at boundary (Pydantic / Zod / similar)
- [ ] Response shapes documented (OpenAPI / GraphQL schema)
- [ ] Idempotency keys on POST/PUT for unsafe operations
- [ ] Correlation IDs across services
- [ ] CORS locked to specific origins (NOT `*` in prod)

### Data layer
- [ ] All schema changes via migrations (no manual `ALTER TABLE` in prod)
- [ ] Migration tool present and used (alembic / drizzle / etc)
- [ ] Backup strategy documented + last backup verified within 7 days
- [ ] Retention policy for PII (GDPR/CCPA awareness)
- [ ] Indexes on frequently-queried columns (verify with `EXPLAIN`)
- [ ] N+1 query guards (eager loading where appropriate)
- [ ] Connection pooling configured

### Observability
- [ ] Structured logging (JSON, not plain text)
- [ ] Log levels enforced (no `print()` in prod paths)
- [ ] Errors include request context (user_id, request_id, endpoint)
- [ ] Metrics exposed (Prometheus, StatsD, or vendor)
- [ ] Tracing for cross-service requests (OpenTelemetry)
- [ ] Health endpoint distinguishes `/livez` (process up) vs `/readyz` (deps ok)
- [ ] Critical alerts configured (5xx rate, latency p99, queue depth)
- [ ] PII NOT in logs (emails, phones, tokens)

### Security
- [ ] Security headers: CSP, HSTS, X-Frame-Options, X-Content-Type-Options, Referrer-Policy
- [ ] CSRF tokens on state-changing operations (or stateless JWT)
- [ ] Input sanitization before rendering (XSS guard)
- [ ] Secrets in env, not committed (`gitleaks` clean)
- [ ] Dependencies scanned (`npm audit` / `pip-audit`) clean of CRITICAL CVEs
- [ ] GitHub Actions pinned to `@<sha>` not `@main`/`@v1`
- [ ] Docker: non-root user, read-only filesystem where possible
- [ ] TLS 1.2+ enforced (Traefik/nginx config)

### Resilience
- [ ] Timeout on every external call (no infinite hangs)
- [ ] Retry logic bounded (max attempts, exponential backoff)
- [ ] Circuit breaker for unstable upstreams
- [ ] Graceful shutdown (SIGTERM handling, drain in-flight)
- [ ] Idempotent retry support (no double-charge / double-send)

### Testing
- [ ] Unit tests cover happy path + error paths (≥70% on critical modules)
- [ ] Integration tests against real DB (not just mocks)
- [ ] **Playwright `tests/e2e/` directory exists and has at least 1 spec per primary user flow**
- [ ] **Playwright tests run in CI (not just locally) — check `.github/workflows/*.yml` for `npx playwright test` or equivalent**
- [ ] **Playwright config (`playwright.config.ts`) targets the real running app, NOT mocks**
- [ ] **No commits with frontend changes lacking a `tests/e2e/*.spec.ts` in the same commit** (grep recent `[CHANGE]` commits — if any frontend file changed without spec accompanying, flag as gap)
- [ ] Test data realistic (Unicode, edge lengths, nulls)
- [ ] Anti-regression: tests fail when feature is reverted (`git revert` proof)
- [ ] No browser-MCP usage in commit messages or test files (those are debugging tools, not tests)

### Operations
- [ ] CI runs on every push (lint + typecheck + tests)
- [ ] Deploy is reversible (rollback documented in RUNBOOK.md)
- [ ] DB migrations are reversible OR the up-only approach is documented
- [ ] Zero-downtime deploy strategy chosen (rolling / blue-green / canary)
- [ ] Disaster recovery: RPO + RTO targets stated
- [ ] On-call: someone responds to alerts within X minutes

### User experience
- [ ] Loading states on every async UI operation
- [ ] Empty states (no data) handled visually, not "0 results"
- [ ] Error states show actionable messages (not stacktrace)
- [ ] Form validation at boundary AND on field blur
- [ ] Optimistic updates with rollback on failure
- [ ] Accessibility: WCAG 2.2 AA on critical flows

### Documentation
- [ ] README has 5-line "what is this + how to run locally"
- [ ] STACK.md fills in real values (no `[PROJECT_NAME]` placeholders)
- [ ] RUNBOOK.md has at least 3 known failure scenarios
- [ ] ADR for every non-obvious architecture decision
- [ ] API documented (OpenAPI / GraphQL introspection / handwritten)

---

## STEP 3 — Mode `modern` (modernization audit)

For each technology in `docs/STACK.md`, audit code against modern (2025-26) idioms.

### Python (if FastAPI / SQLAlchemy / pytest)
- [ ] `from __future__ import annotations` at top of every module
- [ ] Modern type syntax: `list[str]`, `dict[str, int]`, `X | None` (NOT `List`, `Dict`, `Optional`)
- [ ] `match` statement used where it fits (not always cascading `if/elif`)
- [ ] `async def` only when actual I/O present (not just for fashion)
- [ ] `httpx.AsyncClient` (not `requests` in async context)
- [ ] Pydantic v2 (not v1 — `model_validate` not `parse_obj`)
- [ ] SQLAlchemy 2.0 style (`session.execute(select(...))`, not `query()`)
- [ ] `pathlib.Path` (not `os.path.join`)
- [ ] Walrus operator (`:=`) where it actually helps readability
- [ ] No `pkg_resources` (use `importlib.metadata`)
- [ ] uv for deps (NOT pip directly), uv lock committed
- [ ] ruff for lint+format (NOT black + flake8 + isort separately)

### TypeScript / React (if applicable)
- [ ] React Server Components used where they fit (Next.js / Remix apps)
- [ ] Suspense for async boundaries
- [ ] `use(promise)` pattern (React 19+) where appropriate
- [ ] No class components in new code (functional only)
- [ ] No `useEffect` for derived state — use `useMemo` or `useSyncExternalStore`
- [ ] No `any` — use `unknown` with narrowing
- [ ] TanStack Query (or SWR) for server state, not raw fetch + useState
- [ ] Zod or Valibot for runtime validation (not type assertions alone)
- [ ] Vitest (not Jest) for new projects on Vite
- [ ] CSS-in-JS dying — Tailwind, vanilla-extract, or plain CSS modules preferred

### Docker / Infra
- [ ] Multi-stage builds (build stage + runtime stage)
- [ ] Distroless or alpine for runtime
- [ ] Health checks in Dockerfile / compose
- [ ] BuildKit features (`--mount=cache`) for fast rebuilds
- [ ] No `latest` tags — pinned to digest where possible
- [ ] Compose v2 syntax (`services:` not `version: '3'`)

### Database
- [ ] Connection pool sizing matches concurrency (not default)
- [ ] Indexes use `CONCURRENTLY` for prod migrations (Postgres)
- [ ] JSONB used over JSON in Postgres for queryable data
- [ ] Logical replication / CDC for read replicas (where applicable)

### General
- [ ] No CHANGELOG manual maintenance — release-please / conventional commits
- [ ] Dependabot / Renovate for dep updates
- [ ] OpenTelemetry for observability (not vendor-specific by default)

---

## STEP 3.4 — Mode `vs-prd` (promised-but-absent audit)

> The report the owner otherwise produces by hand, by using the product and rediscovering
> their own PRD requirements as "feedback". Runs INSTEAD of missing/modern when invoked as
> `/gaps vs-prd`.

1. Locate `docs/prd/PRD-*.md` + its `docs/prd/PRD-*-trace.md` (matrix from /decompose STEP 5.5).
   - No PRD → abort: "no PRD to audit against".
   - PRD exists but no trace matrix → build a provisional one NOW (atomic split of PRD
     requirements, map to existing T-NNN specs by grep) and flag: "matrix was missing —
     decompose predates traceability; provisional matrix saved".
2. For every matrix row with Status `mapped`, verify the promise IS in the live build —
   evidence required, not archive claims:
   - grep the codebase for the feature's implementation surface (routes, components, handlers)
   - check `tests/e2e/` for a spec exercising it
   - archived-as-done + zero code hits (Tanchiki leaderboard: server endpoint, no client UI) →
     **PROMISED-BUT-ABSENT**
3. For `post-MVP` / `dropped` rows — confirm the decision ref still exists (ADR/decision
   note); orphaned decisions get flagged as UNRATIFIED CUT.
4. Cross-check the PRD's MVP section (§10 or equivalent) line-by-line against the matrix —
   any MVP item missing from the matrix entirely = DECOMPOSE LEAK (worst class; it means the
   matrix itself has a hole).
5. Report, worst-first:

```
## vs-PRD — <date>
### DECOMPOSE LEAKS (in PRD, absent from matrix)
### PROMISED-BUT-ABSENT (mapped/«done», no evidence in build)
### UNRATIFIED CUTS (post-MVP/dropped without a live decision ref)
### STALE PRD (build contradicts PRD text — pivot never patched back; workflow.md § PRD Traceability #3)
Each finding: PRD § + human label + where it got lost + next action (/todo add | patch PRD | restore).
```

6. STEP 5.5 (convert to tasks) applies — offer `/todo add` per finding.

Run before releases, and whenever the owner feels «на выходе не то, что заказывал».

## STEP 3.45 — Mode `domain` (wrong-but-well-formed computation audit)

> The #1 empirical blind spot (harness-gap-audit 2026-07-18): ~70 real fails across projects
> were computations that RAN FINE and returned a WELL-FORMED number that was **business-wrong** —
> USD income counted as UAH (44× too small), a report filtering `created_at` instead of
> `date_start`, a funnel using `<=` where the rule says `<`, a sanctions score threshold of 60
> against a real 0–1 scale that dropped every match. No static lens catches these: the code has
> no structural defect. Only an **oracle** — the business rule — can say the number is wrong.
> Runs INSTEAD of missing/modern when invoked as `/gaps domain`. Read-only; findings route to
> `/fix` (bugs) and `/rule` (missing rules). Accepts a path arg to scope (`/gaps domain app/reports/`).

**The oracle is `docs/RULES.md`. No rule = the number is unauditable, not "assumed correct".**
This mirrors CLAUDE.md § Business Logic Discipline: never invent a value; a computation with no
governing rule is a finding, not a pass.

### 1 — Load the oracle
- Read `docs/RULES.md` (all R-NNN). This is the only source of truth for correct values/formulas.
- Read `docs/CONTEXT.md` (domain glossary) — to map code terms to business terms.
- RULES.md thin/empty → say so up front: "oracle is nearly empty; this run will mostly surface
  UNVERIFIABLE computations + trap-hits, not rule-conflicts. Add rules via `/rule` to make future
  runs sharper."

### 2 — Enumerate computation points (the claims code makes about the domain)
Grep the scope for every place code produces a business number. Cast wide:
```bash
# money / currency
grep -rniE "amount|price|rate|fee|commission|balance|minor_units|kopey|cents|currency|usd|eur|uah|convert" <scope>
# aggregation / metrics / funnels
grep -rniE "sum\(|count\(|avg\(|group by|having|percent|ratio|conversion|funnel|rate\b|total|subtotal" <scope>
# date boundaries
grep -rniE "created_at|date_start|date_end|completed_at|activated|<=|>=|between|interval|now\(\)|utcnow|date\(" <scope>
# detection / classification predicates
grep -rniE "if .*(comment|label|status|type|tag|contains|startswith|in \[)" <scope>
```
Each hit that computes/filters a business quantity = one **computation point**. List them (file:line + one-line what it computes).

### 3 — Cross-check each point (three outcomes + a trap sweep)
For every computation point, first run it against the **known domain-trap checklist** (these ARE the
real past bugs — highest hit rate), then classify vs the oracle.

**Domain-trap checklist (seeded from real fails — check every point against all that apply):**
- **Currency/money:** amount used without FX conversion; stored minor-units (cents/kopiykas) treated
  as major units or vice-versa; missing/stale rate; a second currency (EUR/USD) column blank or
  defaulted to the base currency. *(Mono F-011: USD FOP income 44× too small.)*
- **Date boundary:** `<=` vs `<` wrongly including/excluding the same day; filtering on the wrong
  timestamp (`created` vs `activated`/`date_start`/`completed`); rows with a NULL date silently
  dropped from a report; timezone-naive `now()`/`utcnow()` in a container whose TZ ≠ the users'.
  *(F-016, F-036, F-042.)*
- **Segment/filter completeness:** an aggregation silently omits a state (cancelled, refunded,
  back-in-stock, first-visit, future-dated) that the rule includes — or counts everyone when the
  rule wants a segment; a from/to swap defeats a clamp. *(F-020, F-034, F-050.)*
- **Fragile detection/classification:** matching on comment text / substring / a hardcoded label to
  classify a record — misses most real cases. *(F-044: multisport detection by comment missed 95%.)*
- **Partial aggregation:** last-pair-only / most-recent-only undercount; average-of-averages. *(F-040.)*
- **Unit/scale mismatch:** a threshold compared against the wrong scale (score 60 vs real 0–1 floats);
  percent divided by 100 twice; per-unit vs total. *(OSINT F-131: dropped every sanctions match.)*

**Then classify vs `docs/RULES.md`:**
- **RULE-CONFLICT** — a rule exists and the code contradicts it (or a trap-hit contradicts the rule).
  → CONFIRMED bug. Cite the R-NNN + the exact file:line + the divergence. Routes to `/fix`.
- **TRAP-HIT (no rule either way)** — matches a known trap but no R-NNN governs it. → SUSPECTED bug,
  needs owner confirmation. State the trap + the value it would produce vs the value the trap implies
  is intended. Routes to `/rule` (write the rule) then `/fix` if confirmed wrong.
- **UNVERIFIABLE (rule-missing)** — a real business computation with NO governing rule and no trap
  match. → Cannot be judged; the number is unauditable. Routes to `/rule`. This is a finding, per
  Business Logic Discipline — silence here is the exact failure mode that let ~70 wrong numbers ship.
- **RULE-MATCH** — a rule exists and the code provably matches it. → Verified. Recommend pinning it
  with a **golden-value test** (see 4).

### 4 — Golden-value test recommendation (anti-tautology — critical)
For each RULE-CONFLICT (after `/fix`) and each RULE-MATCH, recommend a test that pins the exact
expected number for a known input fixture. **The expected value MUST be derived from the business
rule (R-NNN), computed independently — NEVER read from running the current code.** A test that asserts
"what the code currently outputs" is the anti-regression trap (workflow.md § TDD, F-030/F-130 in the
backtest — tests that assert the bug). State each recommended test as: `input fixture → expected value
(from R-NNN) → the computation under test`. These tests are the forward-looking half: the audit finds
today's wrong numbers, the golden tests stop tomorrow's. Generation happens via `/fix` (conflicts) or
the `test-writer` agent (matches) — this command only recommends, stays read-only.

### 5 — Report (worst-first)
```
## domain audit — <service> — <date>   (oracle: docs/RULES.md, <N> rules)

### RULE-CONFLICTS (code contradicts a written rule — CONFIRMED bugs)
<R-NNN · file:line · human label · what the rule says vs what the code does · wrong value it yields · → /fix>

### TRAP-HITS (matches a known domain trap, no rule governs it — SUSPECTED)
<trap name · file:line · human label · value produced vs value the trap implies intended · → /rule then confirm>

### UNVERIFIABLE (real computation, no governing rule — unauditable)
<file:line · human label of what it computes · why it can't be judged · → /rule to add the oracle>

### VERIFIED (matches a rule — recommend pinning)
<R-NNN · file:line · golden-test recommendation: input → expected(from rule) → computation>

### Verdict: <N conflicts, N suspected, N unverifiable>. Oracle coverage: <verified+conflict>/<total points> computations governed by a rule.
```
The **oracle-coverage ratio** is the headline health metric: how many of the service's business
computations are actually governed by a written rule. Low ratio = most numbers are unauditable =
the service is flying blind on correctness regardless of how green the tests are.

### 6 — Route findings (mandatory offer)
- RULE-CONFLICTS → offer `/fix "<R-NNN> — <label>: code computes X, rule R-NNN says Y"` per conflict
  (failing-test-first writes the golden test for free).
- TRAP-HITS + UNVERIFIABLE → offer `/rule "<the business fact this computation needs>"` per finding,
  so the next run can judge it. Never invent the rule's value — ask the owner (per Business Logic Discipline).
- Do NOT write fixes or rules inline. This command audits; `/fix` and `/rule` change things.

Run before releases, monthly via /loop, and whenever a report/number "feels off". humanizer pass
(STEP 4.5) applies to the report prose.

## STEP 3.46 — Robustness interrogation (the second half of `domain`)

> Correctness (3.45) asks "is the number right?". Robustness asks "does the feature survive bad
> input, retries, cancellation, expiry, and abuse?" — the BA + QA-hacker questions. Runs as part of
> `/gaps domain`, right after the correctness pass. No oracle file needed; the questions are the check.

1. **Load the catalog:** read `docs/rules-references/adversarial-interrogation.md`. It is the SSOT for
   the question set (classes A–K) and the verdict format. Do NOT restate the questions here — walk them
   from that file.
2. **Pick targets:** each feature/endpoint/flow/mutation in scope (or the path arg). For a whole-service
   run, prioritise: money mutations, uploads, auth flows, anything with a token/link, background jobs,
   and any report/export (expensive ops).
3. **Walk every applicable class (A–K) per target.** For each question produce a verdict:
   ✅ HANDLED (cite the guard: file:line / validator / rule) · 🔴 GAP (the input/sequence that breaks it)
   · 🟡 VERIFY (needs an owner decision or a runtime check). Read-only skip is allowed with an explicit
   "N/A — read-only internal" per class, never silent.
4. **Never invent a policy answer.** "How long should the reset link live?", "is a repeat allowed?" —
   these are owner decisions → 🟡 routing to `/rule`, per Business Logic Discipline.
5. **Report** in the catalog's output format (🔴 GAPS / 🟡 VERIFY / ✅ HANDLED + a **robustness score** =
   handled ÷ applicable questions). Fold it into the same `domain` report under a "Robustness" heading,
   after the correctness sections.
6. **Route:** 🔴 GAPS → `/fix` (failing-test-first pins the edge case) · 🟡 VERIFY → owner question or
   `/rule` for the missing policy. Do not fix inline — this command audits.

The two headline metrics of a `/gaps domain` run: **oracle-coverage** (correctness — how many computations
a rule governs) and **robustness score** (how many adversarial questions the feature survives). Green tests
tell you neither.

## STEP 3.47 — Mode `tests` (test-quality audit — do the tests hunt bugs?)

> The right audit for a project past MVP **with no docs** — it works on code + tests alone, no `RULES.md`,
> no PRD. Answers: *would these tests actually FAIL if the behavior broke, or do they just mirror the
> current implementation?* Runs INSTEAD of missing/modern when invoked as `/gaps tests`. Read-only on
> source (a mutation pass runs the suite but changes no committed code).

1. **Load the methodology:** read `docs/rules-references/test-quality-audit.md` — the SSOT for the five
   layers and the output format. Do NOT restate them here; walk them from that file.
2. **Scope:** the test suite for the target (or the path arg). Prioritise tests for money/auth/mutation
   paths and anything on the critical flow.
3. **Layer 1 — static test-smell scan (always):** find assertion-free / vacuous / tautology /
   mock-the-unit / happy-path-only / implementation-coupled / conditional-logic tests. Each = a finding
   with file:line + why it wouldn't catch a break + what a real assertion would check.
4. **Layer 2 — anti-regression probe (always):** for a sample of critical tests, would the test fail if
   the code were reverted/broken? If not → it targets implementation, not behavior.
5. **Layer 3 — mutation testing (OPT-IN — costs compute):** OFFER it, disclose the runtime (minutes), run
   only on OK. `mutmut`/`cosmic-ray` (Py) or `stryker` (JS/TS) on critical modules → mutation score + top
   surviving mutants (each survivor = a shippable bug the tests can't catch). Per Script Transparency:
   state it runs the suite many times, changes no committed code.
6. **Layer 4 — real-integration/contract check (always):** is any test exercising the REAL external dep
   (or a recorded-payload contract test), or is the flow mocked end-to-end? Flag mock-only "done".
7. **Layer 5 — coverage as a floor only:** low coverage = gaps; high coverage + weak asserts = false
   confidence. Never report % as a standalone quality metric.
8. **Score (FMEA):** the Detection axis IS test effectiveness — a Severe module with weak tests (D≥4) is
   FIX-FIRST, and the fix is *make the test real*, not patch code. Show `S·O·D=RPN` per weak-test finding.
9. **Report** in the methodology's output format (rubber-stamp tests / mock-only flows / happy-path gaps /
   mutation survivors / scores). **Route:** weak tests + survivors → `/fix` or `test-writer` (the new test
   must fail without the behavior); happy-path gaps → the adversarial catalog + `test-writer`. Never
   rewrite tests inside this audit.

Headline metric: how many critical modules have tests that would actually catch a regression — not how
many tests are green.

## STEP 3.48 — Mode `improve` (OFFENSIVE — what to make BETTER, not what's wrong)

> The other `/gaps` modes are defensive ("where does the service fall short of an ideal"). `improve` is
> offensive: **how could this product/service be better** — business moves, new features, logic
> improvements, and what competitors / similar services do that this one doesn't. Runs INSTEAD of the
> defensive modes when invoked as `/gaps improve`. Read-only; findings route to `/todo add` / `/intent`.
>
> **Fronts existing engines — does NOT reinvent them** (per "don't grow commands", same as `/ui`):
> the business layer is `/diagnose`, competitors are `/market-research`, the code/roadmap layer is the
> `improve` skill. This mode orchestrates the three into one prioritized "improvements" report.

1. **Load context:** `docs/CONTEXT.md` (domain), `docs/prd/` + `docs/RULES.md` if present, and skim the
   codebase entry points to know what the product actually IS and who it serves.
2. **Business / product layer — invoke the `diagnose` skill's reasoning** (it is the front door for a
   live product): climb the customer's Job Map to a higher-leverage place to act; find the weak links on
   the chain that ends in profit (each traced to its upstream cause); surface growth moves — kill a chore
   the customer hates, capture the task right before/after this one, climb a level, serve a nearby segment,
   or nail a success measure the market underserves; and run a Riskiest-Assumption pass on the bets the
   product is already making. Plain product language.
3. **Competitor / similar-service study.** Identify 3-5 real competitors or adjacent services **by the Job
   they do** (not by category). For each: what they offer that THIS product doesn't (features, flows,
   pricing, onboarding, a success-measure they nail). Use the `market-research` skill's Deep mode
   (WebSearch/WebFetch) when online; offline → reason from known players + mark `[unverified]`. Extract
   **borrowable moves**, not a feature-copy list — tie each to a Job this product's segment actually has.
4. **Logic / code / tech layer — invoke the `improve` skill** (senior-advisor codebase survey, read-only):
   prioritized opportunities — features worth adding, logic/flow improvements, refactors that unlock
   product moves, DX, and "where to take the project next" (roadmap direction). Self-contained proposals.
5. **Prioritize (RICE-ish).** Score each proposal Reach × Impact × Confidence ÷ Effort so the list is
   ranked, not a brain-dump. Flag the ONE highest-leverage move first (diagnose discipline: name the
   single next move, don't list twenty).
6. **Report** — plain product language (apply `humanizer`):
   ```
   ## improvements — <product> — <date>
   ### 🎯 Do first (highest leverage) — <one move + why + how to validate (RAT)>
   ### Business / product moves — <ranked; each: the Job it serves, the move, RICE, → /intent or /todo add>
   ### From competitors / similar services — <borrowable move · who does it · the Job · why it fits (or [unverified])>
   ### Logic / code improvements — <from the improve skill; ranked; → /todo add>
   ### Shaky assumptions (RAT) — <bets the product makes that aren't yet tested>
   ```
7. **Route:** business/product moves → `/intent` (idea → PRD) or `/todo add`; code improvements →
   `/todo add`. This mode PROPOSES; it never implements. Never invent market numbers — cite or mark
   `[unverified]` (Business Logic Discipline applies to competitor claims too).

Not a defensive audit — pair it with `/gaps tests`/`domain` before a release, and `/gaps improve` when
asking "what should we build next / how do we beat similar services."

## STEP 3.5 — Applicability Gate (mandatory — runs BEFORE assigning severity)

Before promoting any finding from STEP 2 / STEP 3 to a severity tier, classify it into one of three applicability buckets. This kills generic «add X» recommendations that don't apply to THIS service.

For each candidate finding, walk these 5 checks:

1. **Hot path check** — does the missing/outdated thing live on a code path that runs frequently in normal usage? Grep for entry points (route handlers, agent loops, scheduled jobs). Find at least one caller, or it's not hot.
2. **Repeat cadence check** — does the gap matter on every request, or only edge-case once? Once-a-day cron with no SLA = not worth blocking on.
3. **Cost shape check** — does the affected cost actually dominate this service? Cache miss matters only when input-token cost dominates. Async job lateness matters only if user is waiting. If the cost is negligible — not worth the audit.
4. **Stability check** — is the precondition for the gap stable across requests? Generic «no rate limit» doesn't apply if the route is invoked once per day by one internal client.
5. **Project-applicability check** — does THIS service use the affected pattern? «Add CSRF» is N/A for mTLS-only internal API. «Add pagination» is N/A for an endpoint that returns ≤5 items by design.

Classification:
- ALL 5 pass → `applicability = confirmed` → moves to severity tier (Критичні / Значні / Можливості)
- 3-4 pass OR depends on telemetry not yet seen → `applicability = hypothesis` → goes to «Гіпотези — потрібні дані» section in output
- ≤2 pass OR precondition explicitly ruled out by project context → `applicability = not_applicable` → goes to «Не застосовується» section with `ruled_out_by` reason

**Rule of thumb:** if removing the finding from the report would NOT cause real-world harm because the precondition never holds in this service, mark as `not_applicable`. Show it explicitly («would matter if X, but X is not true here»). Do NOT silently drop — explicit ruled-out is more useful than silence.

For each kept finding, also write:
- **`impact_condition`** (ONE LINE): when does this actually matter? «matters IF this service handles auth flows» — not «security best practice».
- **`do_not_do_yet`** (ONE LINE): what naively-applied fix would be worse than the gap? «do not add JWT validation library without rotating signing keys first».

---

## STEP 3.6 — FMEA score (mandatory for every kept finding — the prioritization engine)

The applicability gate (3.5) decides IF a finding applies. FMEA decides HOW BAD and — the axis nothing
else scores — WHETHER ANYTHING WOULD CATCH IT. Load `docs/rules-references/fmea-scoring.md` and score
each `confirmed` finding on three axes (1–5):

- **Severity (S)** — how bad the effect (5 = irreversible: data loss / wrong money / breach / prod down).
- **Occurrence (O)** — how often the trigger arises (5 = every request; 1 = near-impossible).
- **Detection (D)** — chance it ships UNCAUGHT (5 = invisible: no test/alert/log/rule/constraint; 1 =
  caught automatically every time). **High D = bad.** This is the rule-without-audit axis.

**RPN = S × O × D.** Sort findings by RPN within each human-facing tier. Show the triple next to every
finding: `S·O·D = RPN`.

**The Detection rule (why this step exists):** any finding with **S=5 & D≥4** is FIX-FIRST regardless of
RPN — that is the F-161 corner (severe + undetectable). For every **D≥4** finding, the primary
recommended action is **build the detective control** (a failing test, an alert, a DB constraint, a
scheduled drill) — not merely patch the code. A green test suite says nothing about D: a service can pass
every test it has and still be S5·D5 on the path it never checks. Surfacing D is the whole point.

Map RPN → the existing tiers as a sanity check (Критичні ≈ RPN≥45 or S5&D≥4; Значні ≈ 20–44; Можливості ≈
<20) — but the applicability gate and owner judgment still rule; RPN orders, it does not auto-assign.

---

## STEP 4 — Output format

Each gap is rendered as a **card** — no tables, no jargon. Write as if explaining to a non-technical stakeholder who needs to decide priorities.

```
# /gaps audit — <service> — <DATE>
Mode: <missing | modern | both>

## Summary
- Критичних: <count>
- Значних: <count>
- Можливостей для покращення: <count>
- Не застосовується (N/A): <count>

---

## Критичні проблеми (блокують production-готовність)

### 1. <Назва проблеми — зрозуміла людині без технічного бекграунду>
**Статус:** ВІДСУТНЄ / ЧАСТКОВЕ

**Що це означає:** <Одним реченням: що саме зараз не працює або відсутнє. Без абревіатур і назв технологій — тільки суть.>

**Чим загрожує:** <Конкретні наслідки якщо не виправити: що може статися з користувачами, даними, бізнесом або репутацією.>

**Складність:** Низька / Середня / Висока

**Ризик поломки:** Низький / Середній / Високий — <одне речення: що може зламатися в поточній роботі системи при виправленні.>

---

### 2. <Назва>
...

---

## Значні проблеми (виправити протягом 1 спринту)

### 1. <Назва>
**Статус:** ВІДСУТНЄ / ЧАСТКОВЕ

**Що це означає:** ...

**Чим загрожує:** ...

**Складність:** ...

**Ризик поломки:** ...

---

## Можливості для покращення (низький ризик)

### 1. <Назва>
**Що це означає:** ...

**Чим загрожує:** <або: Чому варто покращити:> ...

**Складність:** ...

**Ризик поломки:** ...

---

## Гіпотези — потрібні дані (з STEP 3.5 applicability = hypothesis)

### 1. <Назва — можлива проблема, потребує підтвердження>
**Що це означає:** <одним реченням>

**Коли це матиме значення:** <impact_condition: «matters IF X holds»>

**Що потрібно для підтвердження:** <які дані / лог / payload / трасування промотять у Критичні чи Значні>

**Чого НЕ робити поки що:** <do_not_do_yet — який передчасний фікс гірший за саму проблему>

---

## Не застосовується для цього сервісу (з STEP 3.5 applicability = not_applicable)
- **<Назва>** — мало б значення якщо <impact_condition>, але <ruled_out_by: контекст проекту, що нейтралізує проблему>. Не робити: <do_not_do_yet>.
- <пункт> — <причина або ADR-NNN>

## Не перевірялося / Неможливо оцінити
- <пункт> — <причина: «немає доступу до X»>

## Примітки щодо покриття
- <що не вдалося перевірити і чому>
```

**Поля `impact_condition` і `do_not_do_yet` для кожної знахідки в Критичні / Значні / Можливості:**

Додай у кожну картку додаткові рядки:

```
**Коли це справді важливо:** <ONE LINE: «matters IF this service handles auth flows» — не «це security best practice»>

**Чого НЕ робити поки що:** <ONE LINE: який наївний фікс гірший за gap. Напр.: «не додавати JWT-валідацію без ротації ключів — інакше всі токени відкличуться разом»>

**Пріоритет (FMEA):** S·O·D = RPN <напр. «серйозність 5 · частота 2 · виявлюваність 5 = 50»> — <людський підпис, напр. «рідко, але якщо станеться — незворотно і НІХТО не помітить»>

**Що будувати (якщо виявлюваність ≥4):** <детектор, а не лише фікс: падаючий тест / алерт / обмеження в БД / регулярна перевірка. Порожньо якщо виявлюваність ≤3.>
```

---

## STEP 4.5 — humanizer pass on report (mandatory)

The audit report is **read by humans** — including non-technical stakeholders.

Apply `humanizer` skill with these additional constraints:
- **Без технічного жаргону**: не використовувати назви бібліотек, протоколів, патернів у полях «Що це означає» і «Чим загрожує». Замість «відсутній bcrypt» → «паролі зберігаються у форматі який легко зламати». Замість «немає rate limiting» → «система не обмежує кількість спроб входу».
- **Конкретні наслідки**: у «Чим загрожує» — реальні сценарії (зламаний акаунт, витік даних, збій сервісу, штраф регулятора), не абстрактні «security issues».
- **Чесна складність**: Низька = кілька рядків коду або конфіг; Середня = кілька днів роботи; Висока = архітектурна зміна або тижні.
- **Чесний ризик поломки**: що саме може перестати працювати при виправленні — конкретно, не «можливі проблеми».

Назви gap-ів у заголовках карток — теж без жаргону.
Технічні деталі (файл:рядок, команда для виправлення) допустимі тільки в полі «Дія» якщо воно є — не в основних секціях.

This prevents the «AI-slop audit report» pattern.

---

## STEP 5 — Optional: persist findings

After audit completes, ask:
```
Save audit findings to docs/audits/<DATE>.md? [y/n]
Save key gaps to Outline `Knowledge Base / Best Practices` for cross-project reuse? [y/n]
```

If yes:
- Write `docs/audits/<DATE>.md` with full output
- For each gap that's a generalizable pattern (e.g. "always rate-limit auth endpoints"), publish to Outline `Best Practices` if not already there

---

## STEP 5.5 — Convert gaps to tasks via /todo (mandatory offer)

After saving, present the Critical + Significant gaps as a numbered list and ask:

```
Found N actionable gaps. Which to convert to tasks?
Enter numbers (e.g. "1,3,5"), "critical" (all critical), "all", or "none":
```

**For each selected gap:**
1. Invoke `/todo add "<gap title> — <one-line description from audit>"` — this triggers the full spec pipeline:
   - grill-me skill → clarifying questions about scope/approach
   - Diablo gate → DA review before spec is finalized
   - Output: `docs/specs/T-NNN-<slug>.md` + row in `docs/TASK.md` backlog
2. Do NOT add raw rows directly to `docs/TASK.md` — every task must go through `/todo add` to get a spec and DA verdict.

**If "none" selected:** print:
```
To create tasks later: /todo add "<gap description>"
Each gap must go through /todo to get a spec + Diablo review before entering backlog.
```

**Hard rule:** Never write directly to `docs/TASK.md` from gaps audit. Task rows without T-NNN spec files are forbidden.

---

## Hard rules

- READ-ONLY. NEVER modifies source files. NEVER suggests fixes inline — fixes go in audit doc only.
- Items marked `N/A` MUST cite an ADR or `docs/CONVENTIONS.md` clause that explicitly excludes them.
- "Best practice" claims (mode `modern`) MUST cite a real source where possible: PEP, Anthropic guidance, framework docs, OWASP, NIST.
- "Suggested action" is one line. NOT a refactor plan. Refactor plans = `/improve-arch`.
- If user disagrees with a gap classification — they can mark it `IGNORED: <reason>` in the audit doc; future runs respect that file.
- Scope-aware: if user passes a path argument (`/gaps app/auth/`), audit only that subsystem; don't run whole-service checklist.

---

## Designed for /loop

Periodic service-level audits — but NOT too frequent (gaps don't appear daily):

```bash
# Monthly: full audit
/loop "0 8 1 * *" /gaps both

# Every 2 weeks: just modernization sweep (faster, less noise)
/loop "0 8 1,15 * *" /gaps modern
```

Use `/gaps missing` ad-hoc when you suspect something's missing.
Use `/gaps modern` when you're considering a refactor and want to know what's outdated first.
Use `/gaps both` for new project onboarding or pre-launch readiness.
Use `/gaps domain` when a report/number "feels off", before a release that touches money/metrics,
or monthly to track the oracle-coverage ratio: `/loop "0 8 1 * *" /gaps domain`.
Use `/gaps vs-prd` when the delivered build "isn't what you ordered".
