---
name: webapp-testing
description: 'Playwright e2e testing for web apps. PRIMARY mode for ALL user-facing verification. The mcp__claude-in-chrome__* tools (and any browser-MCP) are for DEBUGGING ONLY (one-off DOM/console/network inspection); NEVER as a substitute for writing a Playwright test. Use whenever frontend code changes, a user-facing flow is added, or a bug touches UI.'
---

# webapp-testing — Playwright is the test framework

> **Hard rule**: any user-facing change must be accompanied by a Playwright `.spec.ts` file
> in `tests/e2e/` (or whatever path `docs/STACK.md` declares). Browser-tool clicking is NOT a test.

---

## Default flow — Playwright TDD

For ANY frontend change:

```
1. Read docs/STACK.md → e2e test command (e.g. `npx playwright test`)
2. Write tests/e2e/<slug>.spec.ts that exercises the user-facing flow
3. Run it — MUST FAIL (red)
4. Implement the feature/fix
5. Run it — MUST PASS (green)
6. git revert the implementation, run again — MUST FAIL again (anti-regression check)
7. Restore implementation, commit BOTH the test and the implementation in same commit
```

If step 6 doesn't fail — your test is testing nothing. Rewrite it before committing.

---

## Test file template (Playwright + TypeScript)

```typescript
import { test, expect } from '@playwright/test';

test.describe('<feature area>', () => {
  test.beforeEach(async ({ page }) => {
    // Set up known starting state — login, seed data, etc.
    // Read docs/STACK.md for app URL.
    await page.goto('/');
  });

  test('<observable behavior in user terms>', async ({ page }) => {
    // Arrange — interact with the app
    await page.getByRole('button', { name: 'Sign in' }).click();
    await page.getByLabel('Email').fill('user@example.com');
    await page.getByLabel('Password').fill('correct-horse-battery-staple');
    await page.getByRole('button', { name: 'Submit' }).click();

    // Assert — observable outcome the user cares about
    await expect(page.getByText('Welcome back')).toBeVisible();
    await expect(page).toHaveURL(/\/dashboard/);
  });
});
```

---

## When chrome-MCP (`mcp__claude-in-chrome__*`) IS allowed

Narrow list. If your scenario isn't here, you should be writing a Playwright test instead.

| Scenario | Why chrome-MCP fits |
|---|---|
| Playwright test is FAILING and you need to inspect live DOM/console/network in real time | Diagnostic — same session, faster than rerun + log mining |
| Reproducing a user-reported bug that has NO test yet — observe behavior, then write the failing test | Observation step before TDD red phase |
| One-off CSS/layout sanity check where Playwright assertions can't capture the issue | Visual regression cases (rare; prefer `toHaveScreenshot()` first) |
| Investigating a third-party widget's behavior to know how to assert against it | Reconnaissance only, NOT verification |

---

## When chrome-MCP is FORBIDDEN

Explicit list. If you're tempted to do any of these — STOP and write the test.

- ❌ "Verifying my change works" before commit → write the Playwright test
- ❌ "Smoke-testing the feature" → write the test
- ❌ "Quick check that login works" → write the test
- ❌ "User asked about X, let me click around to answer" → if there's a real question, write a test that documents the answer
- ❌ "I'll just take a screenshot to confirm" → use `toHaveScreenshot()` in Playwright instead
- ❌ "Adding tests is overkill for this small change" → "small change" is exactly when regressions sneak in; write the test
- ❌ "The chrome MCP is faster" → fast manual checks become slow re-checks every time the code touches this area

---

## Anti-patterns in Playwright tests (rejected by Diablo / code-reviewer)

| Anti-pattern | Why it's bad | Fix |
|---|---|---|
| `await page.goto('/'); await expect(true).toBe(true);` | Tests nothing | Assert observable outcome |
| Test only checks "no error in console" | Too weak — silent broken UI passes | Assert specific text / URL / element state |
| Test mocks the backend | That's not e2e | Run against real backend (compose / dev server) |
| `await page.waitForTimeout(5000)` | Flaky | Use `await expect(...).toBeVisible({ timeout })` — auto-wait |
| Test runs against unit-test fixtures | Not e2e | Use real running app from STACK.md `app_url` |
| Test asserts internal state (Redux store, component props) | Brittle, decoupled from user value | Assert what user sees / can do |
| Single test covers 5 unrelated flows | Hard to debug when red | One test per observable user behavior |
| Test depends on previous test's state | Flaky in CI parallelism | Use `beforeEach` for setup, isolate state |

---

## Anti-regression rule (from `tdd` skill)

After implementing the feature and seeing the test green:

```bash
git stash    # or git revert HEAD --no-commit
npx playwright test tests/e2e/<slug>.spec.ts
# MUST FAIL
git stash pop  # or git reset --hard HEAD
```

If the test passes when the implementation is reverted → the test is testing something
unrelated. Rewrite the assertion to target the actual feature behavior.

---

## CI integration

A test that exists locally but doesn't run in CI is half a test. After landing the spec:

- Verify `playwright.config.ts` includes the new test (usually automatic if it's under `tests/e2e/`)
- Verify CI runs `npx playwright test` (read `.github/workflows/*.yml`)
- For first Playwright test in a project: install browsers in CI:
  ```yaml
  - run: npx playwright install --with-deps chromium
  ```

---

## Reading the boundary one more time

| What you're doing | Right tool |
|---|---|
| Proving feature works AND will keep working | Playwright test |
| Diagnosing a known failure | chrome-MCP (and write the test once you understand) |
| Verifying before commit | Playwright test (run it) |
| Checking visual layout | Playwright `toHaveScreenshot()` first; chrome-MCP only if Playwright can't capture it |
| Showing user "see, it works" | Playwright test output (green) |

If you reach for chrome-MCP and the next sentence in your head is "to check that the feature works" — you're in the forbidden zone. Stop. Write the test.
