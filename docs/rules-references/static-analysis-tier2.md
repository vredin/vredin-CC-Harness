# Static Analysis Tier 2 — vulture + pylint duplicate-code

> Referenced from `/review` STEP 4.8. Tier 2 = pre-merge depth, not every-commit speed.

---

## Why Tier 2 exists

ruff + mypy (Tier 1, every commit) catch:
- Unused imports (F401), unused locals (F841)
- Type errors
- Style violations (E/W codes)
- ~50 pylint rules (PL ruleset)

ruff + mypy DON'T catch:
- **Cross-file dead code** — unused functions/classes used nowhere
- **Unreachable code** — after `return`/`raise`/`break`
- **Duplicate code blocks** — copy-paste across files

vulture covers the first two. pylint's `duplicate-code` (R0801) covers the third.

---

## Tools

| Tool | What | Speed | False positive rate |
|---|---|---|---|
| vulture | dead code (functions, classes, imports cross-file) | fast (AST-based) | medium without whitelist, low with |
| pylint --enable=duplicate-code | similarity detection | slow (10-50× ruff) | low (token-based, deterministic) |

Tier 2 = run these on `/review`, NOT on every `[CHANGE]` commit.

---

## Install

```bash
uv add --dev vulture pylint
```

---

## Why NOT in /fix or /orchestrate

Per Diablo PROCEED CAUTION verdict: false-positive triage is too costly for fast iteration cycles.

- /fix is fast loop (red → green → commit). False-positive blocks user → user starts skipping /fix.
- /review is pre-merge ceremony. User has time to triage. Whitelist tunes false-positive rate.

If a finding is genuinely critical and recurs — user manually adds the rule to `/fix` for THAT specific case (after triage proves it's not noise).

---

## Whitelist for user's stack

FastAPI + SQLAlchemy + Pydantic + pytest produces false positives without configuration:

- `@app.get("/")` route handlers — vulture sees no caller
- `class User(Base)` SQLAlchemy models — used via ORM registry
- `class UserCreate(BaseModel)` Pydantic — used via FastAPI type hints
- `@pytest.fixture` fixtures — used via test injection
- `def test_login()` test functions — invoked by pytest collector

### Recommended `pyproject.toml` block

```toml
[tool.vulture]
min_confidence = 80
exclude = ["tests/", "migrations/", "alembic/", ".venv/"]
ignore_names = [
    # FastAPI
    "app", "router",
    # SQLAlchemy
    "*Base*", "metadata", "__tablename__", "__table_args__",
    # Pydantic
    "Config", "model_config", "*Schema*",
    # pytest
    "test_*", "fixture_*", "conftest",
    # Common framework hooks
    "lifespan", "startup", "shutdown",
]
ignore_decorators = [
    "@app.*",
    "@router.*",
    "@pytest.*",
    "@*.fixture",
    "@event.listens_for",
]
```

### Alternative: `.vulture_whitelist.py`

Some teams prefer a Python file mimicking usage:
```python
# .vulture_whitelist.py — silences known-good "unused"
_.app
_.router
_.Base
_.metadata
_.test_login  # example test
```

Then run: `uv run vulture src/ .vulture_whitelist.py --min-confidence 80`

---

## pylint duplicate-code config

```toml
[tool.pylint."MESSAGES CONTROL"]
disable = "all"
enable = "duplicate-code"

[tool.pylint."SIMILARITIES"]
min-similarity-lines = 6  # default 4 is too sensitive
ignore-comments = true
ignore-docstrings = true
ignore-imports = true
```

Tune `min-similarity-lines` per project. 4 = noisy. 6-8 = signal.

---

## Workflow integration

```bash
# /review STEP 4.8
uv run vulture src/ --min-confidence 80 --exclude tests/,migrations/,alembic/
uv run pylint --disable=all --enable=duplicate-code src/
```

Findings categorized in /review report:
- vulture confidence=100 → MUST FIX (dead code, no judgment call)
- vulture confidence=80-99 → SHOULD FIX (triage: real dead, or framework-implicit?)
- pylint duplicate-code → SHOULD FIX (extract function/class, or accept if intentional)

---

## When NOT to use

- TypeScript/JavaScript projects → use eslint with `no-unused-vars`, `no-unreachable`, `jscpd` for duplication. Skip Python tools.
- Mixed stack repo → run vulture only on `src/` Python paths, exclude TS dirs.
- New repo (<200 LOC) → tools find nothing useful, skip until codebase grows.
