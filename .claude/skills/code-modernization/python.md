# Python modernization (Python 3.11+, FastAPI, SQLAlchemy, pytest)

## Type hints

| Modern | Outdated | Why |
|---|---|---|
| `list[str]`, `dict[str, int]`, `set[X]` | `List[str]`, `Dict[str, int]`, `Set[X]` | PEP 585 (Python 3.9+); cleaner, no `typing` import |
| `X \| None` | `Optional[X]`, `Union[X, None]` | PEP 604 (Python 3.10+) |
| `from __future__ import annotations` at top | bare hints in older code | postpones evaluation, faster module load |
| `Protocol` for structural typing | ABCs / inheritance for "duck typing" | better composition |
| `Self` return type | `"ClassName"` string | PEP 673 (3.11+) |

Source: PEP 585, PEP 604, PEP 673.

## SQLAlchemy 2.0+

| Modern (2.0) | Outdated (1.x) |
|---|---|
| `session.execute(select(User).where(User.id == 42)).scalar_one()` | `session.query(User).filter(User.id == 42).first()` |
| `Mapped[int]` typed columns | untyped columns |
| `selectinload`, `joinedload` for eager loading | implicit lazy loading |
| `with session.begin():` blocks | `try/except/commit/rollback` |

Source: SQLAlchemy 2.0 docs. The `query()` API is deprecated and slated for removal.

## FastAPI

| Modern | Outdated |
|---|---|
| Pydantic v2: `model_validate`, `model_dump`, `Field(default=...)` | Pydantic v1: `parse_obj`, `dict()`, `Field(...)` |
| `Annotated[X, Depends(...)]` | bare `Depends(...)` in default value |
| `httpx.AsyncClient` for outbound HTTP in async handlers | `requests` (sync, blocks event loop) |
| `BackgroundTasks` for fire-and-forget | manual asyncio in handlers |
| Lifespan context manager for startup/shutdown | `@app.on_event("startup")` (deprecated) |

Source: FastAPI changelog, Pydantic v2 migration guide.

## Async correctness

- `async def` is **only** justified when the function actually awaits I/O. Decorating sync code as `async` is cargo culting.
- Never `time.sleep()` in async code — use `await asyncio.sleep()`.
- Never call sync DB drivers (`psycopg2`, sync SQLAlchemy session) in `async def` — use `asyncpg` / async SQLAlchemy session, or run sync via `asyncio.to_thread()`.
- `asyncio.gather()` for parallel awaits, NOT `await x; await y` if independent.

## Tooling

| Modern | Outdated | Why |
|---|---|---|
| `uv` | `pip` + `pip-tools` + `virtualenv` | fast, single tool, lockfile built-in |
| `ruff` (lint+format) | `black` + `flake8` + `isort` | one tool, 100× faster |
| `mypy` strict OR `pyright` strict (one) | both | redundant; pick one |
| `pytest -n auto` (pytest-xdist) | sequential tests | parallel by default for >50 tests |
| Coverage: `coverage[toml]` config in pyproject.toml | `.coveragerc` | one config file |

## Patterns rejected as cargo cult

- **Always-async-everywhere**: forces sync code to be async-shaped without I/O justification → adds overhead
- **Type-everything-at-runtime** (e.g., beartype on every function in a FastAPI app): Pydantic already validates at boundaries; runtime type checks elsewhere are overhead without payoff
- **Pure functional Python**: Python isn't optimized for it; immutability discipline + small mutable state is fine

## Useful patterns underused

- `match` statement (PEP 634, 3.10+) for state machines and parsing
- `dataclasses` over class-with-init when no methods needed
- `contextlib.contextmanager` for setup/teardown patterns
- `enum.StrEnum` (3.11+) for string enums that JSON-serialize cleanly
- `tomllib` (3.11+, stdlib) instead of `tomli`/`toml`

## Sources

- python.org "What's New in Python" (3.10, 3.11, 3.12, 3.13)
- FastAPI changelog: https://fastapi.tiangolo.com/release-notes/
- SQLAlchemy 2.0 migration guide
- ruff documentation
- uv documentation
