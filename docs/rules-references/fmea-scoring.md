# FMEA scoring — the prioritization engine for findings

> **What it is.** Failure Mode and Effects Analysis, the reliability-engineering standard for ranking
> risks. Every finding (a way something can fail) is scored on three axes and multiplied into one
> number, so "fix this first" is a defensible calculation, not a gut call.
>
> **Why it's here.** The harness gap-audit (2026-07-18) found that its deadliest blind spots were not
> unknown failures — they were **known failures with no detective control** ("rule-without-audit": a
> backup that's never restore-tested, an alerter that died silently). FMEA's third axis, **Detection**,
> is exactly that dimension. Scoring it forces the question every other method skips: *if this fails,
> would anything catch it before it hurts?*
>
> **SSOT.** Single source of the scoring rubric. Referenced by `/gaps` (all modes), the adversarial
> interrogation catalog (`adversarial-interrogation.md`), and Diablo. Do not restate the scales
> elsewhere — link here.

---

## The three axes (each 1–5)

### Severity (S) — how bad is the effect if it happens
| S | Meaning |
|---|---|
| 5 | Irreversible — data loss, wrong money moved, security breach, prod down. No undo. |
| 4 | Serious — user-visible wrong result, corrupted state, needs manual repair. |
| 3 | Moderate — degraded/annoying, a workaround exists. |
| 2 | Minor — cosmetic, rare-path glitch. |
| 1 | Negligible. |

### Occurrence (O) — how often the trigger actually arises
| O | Meaning |
|---|---|
| 5 | Constant — every request / normal happy path hits it. |
| 4 | Common — daily, ordinary usage. |
| 3 | Occasional — specific but realistic inputs/sequences. |
| 2 | Rare — edge input or unusual sequence. |
| 1 | Very rare — near-impossible combination. |

### Detection (D) — chance it ships UNCAUGHT before it causes harm  *(high = bad — this is the axis nothing else scores)*
| D | Meaning |
|---|---|
| 5 | **Invisible** — no test, no alert, no log, no rule, no constraint. Fails silently. *(the rule-without-audit class)* |
| 4 | Caught only after the damage, by a human happening to notice. |
| 3 | Caught by an existing test/type-check **only if someone runs it** (not in CI). |
| 2 | Caught by an automated gate that runs (CI test, boundary validation, alert) — but not guaranteed on every path. |
| 1 | Caught immediately and automatically, every time — a hard gate: DB constraint, blocking alert, type system, deploy stop. |

---

## RPN and priority bands

**RPN = S × O × D** (range 1–125).

| Band | Action |
|---|---|
| **RPN ≥ 45, OR S=5 with D≥4** | **FIX-FIRST.** The `S=5 & D≥4` corner (severe + undetectable) is top priority *regardless of RPN* — F-161 lived here (S5·O2·D5). |
| 20–44 | Fix this sprint. |
| < 20 | Opportunity — schedule or accept explicitly. |

Always show the triple, not just the product: `S4·O3·D5 = RPN 60`. The triple tells you *which lever
to pull* — the product alone hides it.

---

## The Detection rule (the point of adopting this)

> **A high-Severity finding with Detection ≥ 4 is the "rule-without-audit" class. Its fix is usually
> NOT fixing the bug — it is building the detector.**

When D≥4, the recommended next action changes shape:
- D=5 (invisible) → **build a detective control**: a failing test, an alert, a DB constraint, a
  scheduled drill, a dead-man's-switch. The bug is secondary; the blindness is the risk.
- Lowering D (adding detection) is often cheaper and higher-leverage than lowering O (preventing the
  trigger) — and it catches the *next* instance of the same class too.

This is why the harness scores Detection at all: a green test suite says nothing about D. A feature can
be S1·O1 on everything it tests and S5·D5 on the one path it doesn't — and only the D axis surfaces it.

---

## Worked examples (from real fails)

| Finding | S | O | D | RPN | Read |
|---|---|---|---|---|---|
| F-161 — test teardown dropped prod schema; backups dead 8 weeks | 5 | 2 | 5 | 50 | **FIX-FIRST** by the S5·D5 rule, not the RPN. The story is D=5: invisible for 8 weeks. Fix = the detector (restore drill, independent watchdog), not just the env var. |
| USD income counted as UAH, 44× too small (Mono F-011) | 4 | 4 | 5 | 80 | Wrong-but-well-formed number, no test would fail (D5). Fix = a golden-value test seeded from the FX rule → drops D to 2. |
| Double-submit on retry → double charge | 5 | 3 | 4 | 60 | Fix = idempotency key (lowers O) **and** a uniqueness constraint (lowers D to 1). |
| Reset link never expires | 3 | 2 | 5 | 30 | Needs an owner TTL policy (→ `/rule`) before it's even scoreable; D5 until a check exists. |

---

## How to apply

1. For each surviving finding (after `/gaps` STEP 3.5 applicability gate — don't score things that don't
   apply), assign S, O, D from the tables. Uncertain on an axis → pick the worse number and mark it a
   VERIFY.
2. Compute RPN; sort findings by RPN within their human-facing tier.
3. For every D≥4 finding, state the **detective control to build** as the primary action — this is the
   rule-without-audit fix and the whole reason Detection is scored.
4. Show the triple in the report next to each finding: `S·O·D = RPN`.
