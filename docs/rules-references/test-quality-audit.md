# Test-quality audit — do the tests hunt bugs, or rubber-stamp the code?

> **The question.** A green suite proves the code does what the tests check. It says NOTHING about
> whether the tests check the right things, or anything at all. This audit answers the real question:
> *would these tests actually FAIL if the behavior broke?* — separating tests that hunt for problems
> from tests that merely mirror the current implementation.
>
> **Why it fits doc-less projects.** Unlike the correctness oracle (needs `docs/RULES.md`) or `vs-prd`
> (needs a PRD), Layers 1–3 and 5 below work on **code + tests alone** — zero documentation required.
> This is the right audit for a project past MVP with no docs.
>
> **SSOT.** Referenced by `/gaps tests` and (optionally) a `/global-audit` lens. Grounded in the real
> false-confidence fails from the cross-project vault (CV F-013/F-014, TelegramFactory F-005,
> Tanchiki F-002, the F-030/F-130 "test asserts the bug" pair).

---

## The layers (cheapest → strongest — run in order, stop when budget runs out)

### Layer 1 — Static test-smell scan (read-only, fast, no execution)
Scan `tests/` for the patterns that mark a rubber-stamp test. Each hit is a finding with file:line:

- **Assertion-free test** — a test function with zero `assert`/`expect`. It runs code and checks
  nothing; passes as long as no exception is thrown. `grep` for test funcs whose body has no assert.
- **Vacuous / weak assertion** — only `assertTrue(x)`, `assert x is not None`, `assert result`
  (truthiness), or `assert resp.status_code == 200` with no check on the body or the side effect.
  Proves "it ran", not "it's right". *(CV F-014: 11 PDF tests green, every download 500s — they never
  asserted the response body.)*
- **Tautology / self-referential** — the expected value was copy-pasted from the code's current output;
  an auto-blessed snapshot (`toMatchSnapshot` accepted without reading); `assert f() == f()`. The test
  pins *what the code does*, so it can never catch a wrong-but-stable result. *(F-030/F-130: tests that
  assert the bug.)*
- **Happy-path-only** — no test exercises empty / null / wrong-type / boundary / error / concurrent /
  expiry. Cross-reference the adversarial classes A–K (`adversarial-interrogation.md`): which are tested?
- **Mock-the-unit-under-test** — the test mocks the very function/service it claims to verify, so it
  exercises the mock, not the code. *(CV F-013: service-layer test passes while the endpoint is 100%
  broken.)*
- **Assertion roulette** — many asserts, no messages → on failure you can't tell which broke; masks weak
  spots.
- **Conditional logic in tests** — `if`/`for`/`try` in a test body → branches that may never run; the
  test can silently no-op and still pass.
- **Implementation-coupled** — asserts private methods, internal call counts, or call order (over-mocking)
  instead of observable behavior → passes on broken behavior, breaks on harmless refactor.
- **Sleepy / order-dependent / shared-state** — `sleep()`, wall-clock, or tests that pass only in a
  given order. Flaky signal = no signal.

### Layer 2 — Anti-regression probe (audit the template's own rule)
The TDD discipline already requires: revert the implementation → the test must fail. This layer *verifies*
it instead of trusting it. For a sample of the most critical tests: mentally (or actually) revert/break
the code under test and ask "would this test now fail?" If it stays green → the test targets the
implementation or is vacuous. Rewrite so the assertion tracks behavior, not output.

### Layer 3 — Mutation testing (strongest — opt-in, costs compute; DISCLOSE runtime before running)
The quantitative gold standard. A mutation tool injects small faults (flip `<` to `<=`, `and` to `or`,
drop a line, change a constant) and runs the suite; a fault the tests DON'T catch is a "survivor".
- Python: `mutmut run` or `cosmic-ray`. JS/TS: `npx stryker run`. Scope to the critical modules — full-repo
  mutation is slow.
- **Mutation score = killed / total mutants.** Below ~60% on a critical module = the tests are decorative.
- Each **surviving mutant is concrete**: a code change the tests can't detect = a real bug that could ship
  today. Report the top survivors with file:line — they are the highest-value test-gap findings anywhere.
- This is a runtime action (runs the suite many times). State expected runtime (minutes) and get the OK.

### Layer 4 — Real-integration & contract check (read-only)
- Is there ≥1 test that exercises the REAL external dependency (or a contract test with recorded real
  payloads), or is the whole flow mocked end to end? Mock-only "done" is a lie: *(TelegramFactory F-005 —
  44 tasks done, 516 tests green, the system never once ran against the real Telegram/OpenAI APIs.)* The
  entire external-API-contract failure class ships because mocks return what the code expects.
- Do integration tests hit a real (test) DB, not just mocks?

### Layer 5 — Coverage as a floor, never a ceiling
Coverage measures *execution*, not *verification*. Read it correctly:
- Low coverage → definite gaps (real signal).
- High coverage + Layer-1 weak assertions → **false confidence** (the dangerous case): every line runs,
  nothing is checked. Never report a coverage % as a quality metric on its own — always pair it with the
  Layer-1 assertion-strength read and, where run, the mutation score.

---

## Scoring — FMEA, where Detection = test effectiveness

Per critical module/feature, score with `docs/rules-references/fmea-scoring.md`. The insight: **the
Detection axis literally IS test quality.** A module whose failure is Severe (S high) but whose tests
wouldn't catch a regression (weak tests → D=4–5) is the FIX-FIRST corner — the fix is *make the test
real* (a failing-without-the-behavior test), which drops D. Report:
- **Test-effectiveness read** per critical module: mutation score (if run) + assertion-strength ratio
  (strong asserts / total tests) + adversarial-class coverage (A–K classes tested / applicable).
- FMEA triple `S·O·D=RPN` per weak-test finding; D is high precisely because the test won't catch the break.

---

## Output format

```
## test-quality audit — <scope> — <date>

### 🔴 RUBBER-STAMP TESTS (green but wouldn't catch a break) — worst first by RPN
- <file:line> · <smell: vacuous / tautology / mock-the-unit / assertion-free> · S·O·D=RPN · what it
  fails to check · what a real assertion would verify · → /fix or test-writer

### 🔴 MOCK-ONLY FLOWS (no test touches reality)
- <flow> · everything mocked, no real-integration/contract test · → add one real/contract test

### 🟡 HAPPY-PATH-ONLY (untested adversarial classes)
- <feature> · tested: <classes> · missing: <A–K classes> · → adversarial-interrogation + test-writer

### 🔴 MUTATION SURVIVORS (if Layer 3 run) — each is a shippable bug
- <file:line> · mutant: <what changed> · survived → tests can't detect this fault

### Scores
- Mutation score (if run): <killed/total> on <modules>
- Assertion strength: <strong asserts>/<tests>
- Coverage (floor only): <%> — paired with the above, NOT a standalone quality claim

### Verdict: <N rubber-stamp, N mock-only, N survivors>. Weakest critical module: <name>.
```

Route: rubber-stamp / survivor findings → `/fix` (rewrite the test so it FAILS without the behavior — the
anti-regression proof) or the `test-writer` agent; happy-path gaps → the adversarial catalog + test-writer.
This audit is read-only on source (Layer 3 runs the suite but changes no committed code); never rewrites
tests itself.

---

## Anti-rules

- **Never treat "tests pass" or a coverage % as evidence of quality.** Both are satisfied by rubber-stamp
  tests. Only Layers 1–3 speak to whether tests hunt bugs.
- **Never green-light a mutation survivor as "acceptable" without a written reason.** A survivor on a
  critical path is a bug the suite is blind to.
- **Never rewrite the tests inside this audit.** It reports; `/fix` and `test-writer` change tests, so the
  new test goes through red→green proof.
