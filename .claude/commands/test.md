---
name: test
description: 'Run the full test suite or a targeted subset. Usage: /test [backend|frontend|e2e|all|<pattern>]'
---

> **Style:** Load `caveman-distillate` skill — terse responses, no filler, fragments OK.

Run tests. Arguments: $ARGUMENTS

## How to Find Project Roots

Auto-detect — do NOT use hardcoded paths:
- **Python backend**: directory containing `pyproject.toml` or `setup.py`
- **Node backend**: directory containing `package.json` with no `src/App` or `src/main.tsx`
- **Frontend**: directory containing `tsconfig.json` or `vite.config.ts`
- **Monorepo**: check for `pnpm-workspace.yaml`, `turbo.json`, or root `package.json` with `workspaces`

```bash
GIT_ROOT=$(git rev-parse --show-toplevel)
```

## Test Suites

### `/test backend`
```bash
# Python:
cd "$GIT_ROOT" && uv run pytest tests/ -q --tb=short 2>&1

# Node.js alternative:
cd "$GIT_ROOT" && npm test 2>&1
```

### `/test frontend`
```bash
cd "$GIT_ROOT" && npx tsc --noEmit && npx eslint src/ --max-warnings=0 2>&1
```

### `/test e2e`
```bash
cd "$GIT_ROOT" && npx playwright test --reporter=list 2>&1
```

### `/test all`
Run backend → frontend → e2e in sequence. Report pass/fail for each.

### `/test <pattern>`
```bash
# pytest pattern:
cd "$GIT_ROOT" && uv run pytest tests/ -k "$ARGUMENTS" -v --tb=short 2>&1

# vitest pattern:
cd "$GIT_ROOT" && npx vitest run --reporter=verbose "$ARGUMENTS" 2>&1
```

## After Running Tests

Always report:
```
Backend:  X passed / Y failed
Frontend: tsc clean / N errors
E2E:      X passed / Y failed
```

If any tests fail:
1. Show the full error output for failed tests
2. Identify whether failure is in test code or implementation
3. Ask: "Shall I investigate and fix? [y/n]"

## Quality Gate
Before any deploy, all suites must be green.
If they aren't, block deploy and ask user to confirm overriding.
