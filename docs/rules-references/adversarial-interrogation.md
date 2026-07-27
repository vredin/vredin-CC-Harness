# Adversarial Feature Interrogation — BA + QA-hacker question catalog

> **The robustness half of the business-rules oracle.** The correctness half (`/gaps domain`
> STEP 3.45) asks *"is the number right?"* against `docs/RULES.md`. This catalog asks the other
> question: *"does the feature survive bad input, retries, cancellation, expiry, and abuse?"* —
> the way a business analyst plus a QA-hacker would interrogate it. No oracle file needed; the
> questions ARE the check.
>
> **SSOT.** This is the single source of the adversarial question set. It is wired into two points:
> - **Build time** — `/todo` grill-me asks these about a feature BEFORE it is coded (catch pre-ship).
> - **Audit time** — `/gaps domain` STEP 3.46 walks them over EXISTING features (catch what shipped).
>
> Do not copy the questions into either command — reference this file so the set stays in one place.

---

## How to run it

Pick the target: one feature / endpoint / flow / handler (build time: the spec's scope; audit time:
a route, a form, a job, a mutation). Walk EVERY class below. For each question, produce a verdict:

| Verdict | Meaning | Evidence required |
|---|---|---|
| ✅ **HANDLED** | The code/design demonstrably covers it | cite the guard: file:line, validator, rule, gate |
| 🔴 **GAP** | Nothing covers it — a concrete failure ships | describe the failure + the input/sequence that triggers it |
| 🟡 **VERIFY** | Can't tell from a static read — needs owner or runtime confirmation | say what to check (payload, log, a manual try) |

Each 🔴/🟡 finding carries an **FMEA score** (`docs/rules-references/fmea-scoring.md`): the triple
`S·O·D = RPN` (Severity × Occurrence × Detection), a **one-line consequence** in plain terms, and a
**next action** (`/fix`, `/rule`, add validation, add rate-limit, add idempotency key…). Sort findings
by RPN; any `S=5 & D≥4` is FIX-FIRST regardless of RPN. When Detection ≥4, the primary action is *build
the detector* (a failing test / alert / constraint), not just patch the bug — that is the rule-without-
audit class. Never invent a business answer — if a question needs a policy decision (how long should the
link live? is retry allowed?), it is a 🟡 that routes to the owner / `/rule`, per CLAUDE.md § Business
Logic Discipline.

Scale to the feature: a money mutation or an upload gets the whole catalog; a read-only internal
list endpoint can skip abuse/lifecycle classes with an explicit "N/A — read-only, internal".

---

## The generator — HAZOP guide words (use for novel or critical features)

The classes below (A–K) are the **pre-computed common hits** — fast, covers the frequent cases. But a
hand-written list is never complete. For a genuinely new, high-Severity, or complex feature, generate
exhaustively instead: take **each parameter and each step of the flow**, apply every guide word, and ask
"what does this mean here, and is it handled?" This is HAZOP (Hazard & Operability study) — the systematic
way to be complete rather than rely on what you remembered.

| Guide word | Applied to a parameter / step, it asks… | Maps to class |
|---|---|---|
| **NO / NONE** | absent, empty, null, missing, does nothing | A |
| **MORE** | higher value, more items, higher rate/frequency | C, H |
| **LESS** | lower value, fewer items, slower, truncated | C |
| **AS WELL AS** | extra/unexpected params or side effects alongside the intended one | A, J |
| **PART OF** | incomplete — partial data, half-finished operation | A, J |
| **REVERSE** | the opposite — undo, cancel, from/to swapped, rollback | F |
| **OTHER THAN** | a completely wrong thing — wrong type, object where a scalar was expected | B |
| **EARLY / LATE** | happens sooner/later than expected — before ready, after expiry | E, G |
| **BEFORE / AFTER** | wrong order — step 3 before step 1, webhook before the record exists | F |
| **FASTER / SLOWER** | rate the system can't sustain, or a dependency that stalls | H, J |

**How to use:** for each parameter/step × each guide word, if the meaning is real and unhandled → it is a
finding (score it FMEA). Guide words that don't apply to a given parameter are skipped explicitly. The
classes A–K are what you get when you pre-apply these words to typical inputs — start there for speed,
fall back to the full guide-word sweep when the feature is new or the Severity is high.

## The classes (walk all that apply)

### A. Input cardinality & presence
- What if **fewer** parameters than expected arrive? More? **Extra/unknown** params?
- Required field **empty / null / missing / whitespace-only**? Optional field explicitly `null`?
- **Duplicate** params? Params in the **wrong order**? Same key twice?
- *Handled looks like:* boundary validation (Pydantic/Zod), explicit required/optional, unknown-field policy.

### B. Type & shape confusion
- Expect a **number, got text** (`"abc"`, `"12abc"`)? Expect **text, got a number**?
- Expect a scalar, got an **object or array**? Expect one object, got a list?
- Number as string `"123"`? **Negative** where only positive is valid? **Zero**? **Huge** (overflow)?
  **Float** where int expected? Scientific notation? `NaN`/`Infinity`?
- Text: empty, **max-length + 1**, unicode/emoji, control chars, wrong encoding, injection payloads?
- Date: invalid, far future/past, wrong format, **timezone**, impossible (Feb 30)?
- *Handled looks like:* strict types at the boundary, coercion rules stated, length/range bounds.

### C. Boundaries & scale
- **Off-by-one at every limit:** min−1 / min / min+1 / max−1 / max / max+1.
- **Empty** collection? **Exactly one** item? **Huge** collection (does it paginate / stream / OOM)?
- *Handled looks like:* explicit bounds, pagination, streaming for large sets.

### D. Idempotency & retry  *(the "internet seemed to drop, I retried" case)*
- Same operation submitted **twice**? **Double-click**? Retry after a client timeout?
- Does replay **double-charge / double-send / create a duplicate row**?
- Is there an **idempotency key**? Does a replayed request return the same result, not a second effect?
- *Handled looks like:* idempotency key on unsafe POST/PUT, dedup window, unique constraint.
- *Real fail:* the concurrency lens covers some of this — but "did WE add the key" is the question.

### E. Concurrency & race
- **Two users** act on the same object at once? **Same user in two tabs**? Same request twice in parallel?
- **Read-modify-write** lost update? TOCTOU between a check and the action?
- *Handled looks like:* row locks, optimistic-version column, atomic update, transaction scope.

### F. Lifecycle & "what if they change their mind"
- Person **cancels mid-flow** — is there a rollback / compensating action, or is state left half-written?
- Operation on an **already-completed / cancelled / deleted / expired** object?
- Steps run **out of order** (step 3 before step 1)? A webhook arrives before the record exists?
- *Handled looks like:* explicit state machine, guarded transitions, compensating transaction / saga.
- *Blind-spot match:* this is gap #5 from the harness gap-audit (lifecycle/cancellation) — thinly covered.

### G. Time & expiry  *(the "won't the link expire?" case)*
- A **link / token / session** used **after its TTL**? Used **exactly at** the expiry boundary?
- **Clock skew** between services? A long operation crossing a **day / month / DST** boundary?
- A rate/quota window that resets — behavior right at the reset?
- *Handled looks like:* explicit TTL + a stated policy for expired use, single-use tokens, UTC everywhere.
- *Blind-spot match:* time/expiry — a named harness blind spot (no clock in static readers).

### H. Availability & abuse  *(QA-hacker / DoS — the "rate per second, monitoring" case)*
- **No rate limit → flood**: what happens at 100 req/s from one caller?
- Can **one caller exhaust a shared resource** — DB pool, memory, a **third-party quota we pay for**?
- An **expensive** operation (report, export, LLM call) triggered repeatedly with no throttle?
- An **unbounded query** behind this? **No monitoring** → does a silent failure here go unnoticed?
- A technically-authorized flow **abused in aggregate** (bulk scrape, scalping, promo farming)?
- *Handled looks like:* per-caller rate limit, quota, timeout, bounded query, an alert on failure.
- *Blind-spot match:* load/capacity + business-logic abuse — named blind spots.

### I. Authorization & trust  *(BA + security)*
- Does the client supply a field it **shouldn't control** — price, role, `user_id`, quantity, discount?
- Can it reach **someone else's object** by changing an id (IDOR)?
- Can it **skip a step / deep-link past a gate**? Is every entry point guarded, not just the main one?
- *Handled looks like:* server-derived trust fields, ownership checks, a gate on every entry point.
- *Covered:* the invariants + security lenses hit this — the question here is per-feature confirmation.

### J. Failure & partial completion
- An **external dependency is down / slow / returns garbage** — what does the user see, what state remains?
- A transaction **crashes at step N of M** — is the leftover state consistent, or an orphan / half-charge?
- A background job **dies silently** — does anyone find out?
- *Handled looks like:* timeouts + fallback, atomic transactions, dead-letter/retry, alert on job failure.

### K. Business intent  *(the pure BA question)*
- Does the feature actually serve the **real Job**, or a technically-correct-but-useless variant?
- What **real-world situation did we not model** — refund, dispute, partial fulfillment, a proxy user
  acting for someone else, a returning customer, a currency/locale we forgot?
- What does the user do the **moment after** this succeeds / fails — is that path built?
- *Handled looks like:* the flow maps to a stated Job and its realistic variations.

---

## Output format

```
## robustness interrogation — <feature/flow> — <date>

### 🔴 GAPS (concrete failure ships) — sorted by RPN, then S=5&D≥4 first
- [<class/guide-word>] <the adversarial question> → <what breaks> · S·O·D = RPN · consequence: <plain one line> · → <action; if D≥4: build the detector>

### 🟡 VERIFY (needs owner decision or a runtime check)
- [<class>] <question> → <why unknown> · S·O·D (best guess) · what to check: <payload/log/manual try> · → /rule or owner

### ✅ HANDLED (with evidence)
- [<class>] <question> → guarded by <file:line / validator / rule> (D=1–2)

### Verdict: <N gaps, N to verify> across <M classes walked>. Robustness score: <handled>/<applicable questions>. Top risk: <highest-RPN finding>.
```

The **robustness score** (handled ÷ applicable questions) is the headline: a feature that computes the
right number but scores low here is one bad input or one double-click away from an incident — green
tests will not tell you. Pair it with the correctness oracle-coverage ratio for the full picture.

---

## Seeded from real failures

The catalog is not theoretical — every class maps to shipped incidents in the cross-project vault:
duplicate submissions (D), refresh-token thundering herd (E/H), tests/flows on already-deleted objects
(F), tokens/caches used past their lifetime (G), no-rate-limit bans and third-party 429 floods (H),
client-supplied trust fields (I), external-API garbage crashing a handler (J). Keep it current: when a
new fail lands that a class would have caught, note the F-NNN beside that class.
