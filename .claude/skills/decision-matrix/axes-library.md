# Axes Library

Canonical list of evaluation axes for decision matrices. Referenced by `researcher` agent. Extend this file when a new domain appears.

## How to use

1. Start with the **8 universal axes**. Set weight per-axis based on TZ emphasis.
2. Add **domain-specific axes** matching `spec.meta.domain`.
3. For each axis you drop — explain why. Default assumption: an axis is relevant.
4. A matrix with 6–10 axes is right. More than 12 is noise; fewer than 5 is missing something.

---

## Universal axes (always consider)

### 1. Security

**What:** Risk of data exposure, privilege escalation, third-party compromise, secret mishandling. For OSS frameworks: has there been a security audit? For vendors: SOC2/ISO27001 compliance? For self-hosted: attack surface.

**How to score (heuristics for 0–100):**
- 80–100: Independent audit within last year + responsive CVE handling + minimal attack surface.
- 50–80: Active security process, no major public incidents, reasonable defaults.
- 25–50: Security "not the focus", ad-hoc patches, some known issues.
- 0–25: Known unpatched CVEs OR no auth model OR encourages anti-patterns.

**Evidence sources:** `WebFetch github.com/<org>/<repo>/security` (advisories page), CVE databases, `WebSearch` with reddit/HN filters for `"<repo> security"` or `"<repo> CVE"`.

### 2. Bus factor

**What:** How many people can maintain the project if someone leaves? Signals: contributor distribution, corporate backing, number of active committers, governance model.

**How to score:**
- 80–100: Foundation-backed (Apache, CNCF, Linux Foundation) OR 20+ active contributors across 5+ orgs.
- 50–80: Single well-funded company backs it, multi-person team, clear succession.
- 25–50: 2–4 active maintainers, one dominant.
- 0–25: Single-maintainer project, even if popular.

**Evidence sources:** `WebFetch github.com/<org>/<repo>/graphs/contributors` — compute top-1 commit percentage; top-1 >70% = fatal for bus factor axis. Cross-check with `WebFetch` on main repo page (sidebar lists top contributors with counts).

### 3. Production maturity

**What:** Has this run in production, at what scale, for how long. Proxy: release history, repo age, public case studies.

**How to score:**
- 80–100: 3+ years in prod, known case studies at scale, stable API (semver-respected).
- 50–80: 1–3 years, some case studies, occasional breaking changes.
- 25–50: Under a year, beta-labeled releases, small deployments.
- 0–25: Alpha, pre-1.0 with daily breaking changes.

**Evidence sources:** repo `created_at`, releases page (look for `-beta`, `-alpha`, `-rc` tags), company blog posts citing use.

### 4. API stability

**What:** Can you upgrade without rewriting. Different from maturity: a mature project can still churn API.

**How to score:**
- 80–100: Semver-strict, deprecation policy, v1+ for 2+ years.
- 50–80: Mostly backward compatible, deprecations announced, v1+.
- 25–50: Occasional breakage without warning, pre-1.0 but slowing.
- 0–25: Daily `beta.X` releases with breaking changes, no upgrade guides.

**Evidence sources:** releases page, CHANGELOG, `git log` of public API files.

### 5. Dev speed (time-to-first-working-system)

**What:** From empty repo to first end-to-end prototype running your use case.

**How to score:**
- 80–100: Quickstart in under 1 hour, boilerplate generators, good examples matching your use case.
- 50–80: Day or two; docs are OK but some gotchas.
- 25–50: Week+; docs gaps, requires reading source.
- 0–25: Weeks; needs deep expertise to get basics working.

**Evidence sources:** quickstart docs (WebFetch), examples directory, "getting started" tutorials.

### 6. Extensibility / modifiability

**What:** Can you add custom behavior without forking? Plugin system, hook points, composable primitives.

**How to score:**
- 80–100: First-class plugin API, many third-party extensions exist.
- 50–80: Plugin API exists but limited; most customization via code.
- 25–50: Monolithic; extensions require patching.
- 0–25: Closed architecture; customization requires fork.

**Evidence sources:** docs "extending" or "plugins" sections, awesome-X lists showing plugin ecosystem size.

### 7. Cost (TCO, not license)

**What:** Total cost of ownership over 12 months: license + infra + ops + learning.

**How to score:**
- 80–100: Free OSS + runs on existing infra + team already knows the stack.
- 50–80: Free license but non-trivial infra OR paid license but zero ops.
- 25–50: Monthly costs stack up (infra + seats + add-ons), or hidden ops burden.
- 0–25: High license + infra + dedicated operator needed.

**Evidence sources:** pricing pages (WebFetch), infra calculators, similar-size case studies.

### 8. Ops burden

**What:** Human attention required to keep it running. Upgrades, monitoring, incidents, debugging.

**How to score:**
- 80–100: Managed service; you don't touch infra. OR battle-tested daemon that runs for months untouched.
- 50–80: Weekly attention; standard monitoring covers it.
- 25–50: Daily attention; custom monitoring needed; non-obvious failure modes.
- 0–25: Full-time operator needed; frequent incidents; poor observability.

**Evidence sources:** incident postmortems, HN "I run X in prod" threads, docs section on operations.

---

## Domain-specific axes

Pick these based on `spec.meta.domain`. A matrix can use universal + 2–4 domain axes.

### Domain: multi-agent / agentic systems

- **Agent isolation** — sessions / memory / tool calls don't bleed between agents. Critical for multi-tenant scenarios.
- **LLM-provider lock-in** — can you swap OpenAI → Anthropic → local without rewriting?
- **Tool integration surface** — how many built-in tools / MCP support / custom tool ease?
- **Observability of agent reasoning** — traces, replay, step-by-step debug.
- **Cost per agent-run** — measurable and predictable, or surprise bills?
- **Orchestration determinism** — does the framework route tasks programmatically (same input → same path) or does it rely on LLM decisions at each branch (variable output between runs)? Critical when the TZ requires consistent behaviour across many entities / 24-7 uptime / reproducible debugging. LLM-driven orchestration scores low on this axis.
- **State persistence model** — in-memory only, Redis/DB-pluggable, or required external store. In-memory is disqualifying for long-running stateful workflows.
- **Replayability from checkpoint** — can a failed workflow be resumed from last successful step, or only restarted from scratch?
- **LLM token consumption at scale** — for LLM-driven products, estimate $/month at TZ's stated scale (entities × hours × decisions/hour × tokens/decision × current API price). Score reflects whether this is sub-$100/mo (fine), $100-$5k/mo (manageable), $5k-$50k/mo (large), or >$50k/mo (likely infeasible). Note any need for separate API billing accounts (e.g., OpenRouter for cheaper models, or direct provider when Pro subscription rate-limits are hit).
- **Configuration complexity** — count of config keys, number of files, presence of single-page setup guide. Used as proxy for time-to-first-working-state and for ongoing maintenance overhead.
- **Hardware fit** — does the candidate actually run on the hardware the TZ specifies? CUDA-required products on Apple Silicon = mismatch. Heavy memory footprint on integrated 8 GB devices = mismatch. For mismatches, the recommendation must include a hybrid path with external compute cost estimate (e.g., RunPod GPU rental).

### Domain: content-generation pipelines (image/video/audio)

- **Model provider flexibility** — single-vendor lock-in or can swap Stable Diffusion / Flux / Imagen / Midjourney?
- **Consistency controls** — LoRA / IP-Adapter / ControlNet support; how strong character/style anchoring?
- **Generation cost predictability** — subscription gotchas (rate limits, "fair use"), vs pay-per-generation with linear pricing.
- **Browser automation resilience** (if using subscription services via browser) — fragile selectors vs AI-native (Stagehand, browser-use) vs official API.
- **Content moderation / NSFW handling** — automatic filters, false-positive rates, override controls.

### Domain: web applications

- **Accessibility support** — WCAG 2.1 AA by default.
- **SSR / SSG / CSR trade-offs** — does the framework let you pick per-route?
- **Bundle size budget** — default kb of JS shipped.
- **SEO friendliness** — semantic HTML, meta tags, sitemap generation.

### Domain: ML / data

- **GPU support** — CUDA versions, TPU, Apple Silicon (Metal).
- **Reproducibility** — seed control, deterministic mode.
- **Data versioning** — integration with DVC, lakeFS, or similar.
- **Training pipeline resumability** — checkpoint reload from arbitrary step.

### Domain: infra / orchestration

- **Scheduling granularity** — cron-style vs event-driven vs continuous.
- **Retry / backoff semantics** — configurable per-step?
- **DLQ / poison-pill handling** — built-in or DIY?
- **Multi-region / multi-cloud** — supported or lock-in?

### Domain: data storage

- **ACID guarantees** — strict / eventual / tunable.
- **Scaling model** — vertical / horizontal / sharded / replicated.
- **Backup / PITR** — built-in or operator burden?
- **Ecosystem of migrations / schema tools** — mature or DIY?

### Domain: 24/7 in-house tooling (very relevant to this framework's first use case)

- **Crash recovery** — auto-restart, state persistence, no data loss on kill -9.
- **Thermal / resource envelope** — will your hardware survive continuous load?
- **Concurrency ceiling** — max parallel tasks before degradation.
- **Self-healing** — detects and repairs common issues without operator.
- **Zero-touch upgrades** — can you update without downtime?

---

## Anti-axes (do NOT score these as axes)

These sound like axes but aren't — they're outcomes or derived properties:

- "Popularity" — use `Bus factor` + stars signal. "Popular" alone is meaningless.
- "Good docs" — covered by `Dev speed`. If docs are bad, it shows up there.
- "Modern" — meaningless. Say what you mean: recent first release, uses X language feature, etc.
- "Future-proof" — unknowable. Instead score `API stability` and `Bus factor`.
- "Enterprise-ready" — vague marketing phrase. Break into Security + Maturity + Ops burden.

If you find yourself about to add one of these — decompose it into concrete axes above.

---

## Weight calibration

Weights are `low` / `med` / `high`. Numeric equivalents: 1 / 2 / 3.

**Defaults if TZ is silent on an axis:** set to `med`. But mark in `Why this weight` column: "TZ silent — defaulted med".

**High-weight triggers (set `high` when TZ contains language like):**
- "critical" / "mandatory" / "non-negotiable"
- explicit metric / threshold
- regulatory requirement
- mentions of production / 24/7 / uptime / SLA

**Low-weight triggers:**
- "nice-to-have"
- "future iteration"
- "for v2"

---

## Example weight selection dialogue

TZ snippet: "System works 24/7 or on-demand. Scalability: new models can be added without rebuilding. No dedicated ops team."

| Axis | Weight | Why |
|---|---|---|
| Bus factor | high | "24/7" + no ops team = cannot afford single-maintainer failure |
| Ops burden | high | Same reason + "on-demand" implies no operator monitoring |
| Extensibility | high | "add models without rebuilding" is literal extensibility |
| API stability | high | 24/7 tool can't absorb weekly breaking upgrades |
| Production maturity | high | 24/7 claim requires proven uptime |
| Security | med | TZ silent on data sensitivity — defaulted |
| Dev speed | low | Internal tool, no ship-date mentioned |
| Cost | low | TZ doesn't specify budget; OSS preferred implicit. NB: hardware status (e.g., "Mac Mini in the office") is NOT confirmation of ownership — flag as assumption per CLAUDE.md Invariant 0 / spec-normalizer rule 2a |
