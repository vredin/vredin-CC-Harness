---
name: verify-before-done
description: 'Self-check protocol before marking work complete. Run this mentally before every "done" response.'
---

# Verification Protocol — Before Saying Done

Run this checklist before presenting any implementation as complete:

## Code Quality
- [ ] TypeScript: `npx tsc --noEmit` — zero errors?
- [ ] Python: `uv run ruff check .` — zero warnings?
- [ ] No `console.log`, `print()`, `debugger`, or `TODO` left in changed files
- [ ] No hardcoded secrets, test credentials, or debug flags

## Correctness
- [ ] Did I read the file before editing it?
- [ ] Does the change actually solve the stated problem?
- [ ] Did I handle the **error case**, not just the happy path?
- [ ] For async code: are all awaits in place? No race conditions?
- [ ] For DB code: is authorization checked before data access?

## Tests
- [ ] Is there a test that proves this works?
- [ ] Does that test actually **FAIL** without the fix?
- [ ] Does it **PASS** with the fix?
- [ ] Did I actually run it, or am I assuming?

## Impact
- [ ] Does this change break anything else? (check imports, shared state)
- [ ] Is a DB migration needed? If so, is it included?
- [ ] Does deploy require a service restart?

## Confidence Level
Rate 1–5:
- **5**: Ran all tests, type-checks clean, deployed and verified in production
- **4**: Tests pass locally, type-checks clean, not yet deployed
- **3**: Tests pass, minor type warnings remain
- **2**: Logic looks right but not tested
- **1**: Uncertain — need to investigate more

**If confidence < 4: say so explicitly to the user before marking done.**
