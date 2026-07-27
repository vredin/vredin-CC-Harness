# CONVENTIONS — Code Standards & Project Conventions

> Single source of truth for all coding conventions.
> Read at every session start. Follow without exception.
> Update when team agrees on a new convention.

---

## General Principles

| Principle | Rule |
|-----------|------|
| **SRP** | Each function/class does ONE thing |
| **DRY** | Extract duplicates — if writing same logic a second time, stop and extract |
| **KISS** | Simplest solution that works. No premature abstraction |
| **YAGNI** | Don't build features nobody asked for |
| **No Deferral** | If you can fix/create/configure it — do it now, don't leave TODOs |

---

## Naming

| Element | Convention | Example |
|---------|------------|---------|
| Variables | Reveal intent | `userCount` not `n` |
| Functions | Verb + noun | `getUserById()` not `user()` |
| Booleans | Question form | `isActive`, `hasPermission`, `canEdit` |
| Constants | SCREAMING_SNAKE | `MAX_RETRY_COUNT` |
| Files (components) | PascalCase | `UserProfile.tsx` |
| Files (modules) | kebab-case | `user-service.py` |
| CSS classes | kebab-case | `user-profile-card` |

> If you need a comment to explain a name — rename it.

---

## Functions

| Rule | Limit |
|------|-------|
| Max length | 30 lines (ideally 5-15) |
| Max arguments | 3 (prefer 0-2, use object for more) |
| Max nesting | 2 levels (use guard clauses for early returns) |
| Abstraction | One level per function |
| Side effects | Don't mutate inputs unexpectedly |

---

## Files

| Rule | Limit |
|------|-------|
| Max file length | 300 lines (split if larger) |
| One concept per file | One component, one service, one model |
| Related code | Keep close (colocation > separation by type) |

---

## Error Handling

| Rule | Description |
|------|-------------|
| Never bare `except`/`catch` | Always specify the exception type |
| Never `except: pass` | At minimum log the error |
| Handle at the right level | Catch where you can meaningfully recover |
| Fail fast | Validate inputs early, return/throw immediately |
| Structured errors | Use error codes/types, not just strings |

---

## Database

| Rule | Description |
|------|-------------|
| All queries via ORM | Raw SQL only with explicit review and parameterized queries |
| Always scope by user | Every data query must include ownership/tenant check |
| Migrations included | If schema changes — migration file is part of the same commit |
| Transactions for writes | Multi-step writes wrapped in transaction |
| No N+1 | Never query DB inside a loop — use joins or batch queries |

---

## Testing

| Rule | Description |
|------|-------------|
| Test behavior, not implementation | Assert what it does, not how |
| Real DB for integration tests | Never mock the database |
| Mock only external services | Email, S3, payment — mock. DB, own services — real |
| Deterministic | No random, no sleep, no network in unit tests |
| Red → Green → Refactor | Write failing test FIRST |
| File naming | `test_<feature>.py` or `<feature>.spec.ts` |

---

## Git

| Rule | Description |
|------|-------------|
| BACKUP before change | `[BACKUP]` commit before editing any file |
| CHANGE after done | `[CHANGE]` commit (amends BACKUP) with DA verdict |
| Atomic commits | One logical change per commit |
| No debug artifacts | No `console.log`, `print()`, `debugger`, `TODO`, `FIXME` in commits |
| No secrets | Never commit `.env`, credentials, API keys |

---

## Code Style

| Pattern | Apply |
|---------|-------|
| Guard clauses | Early returns for edge cases — flat > nested |
| Composition | Small functions composed together |
| Explicit > implicit | Named params, explicit types, clear returns |
| Delete dead code | Don't comment out — delete. Git has history |
| No magic numbers | Use named constants |

---

## Anti-Patterns (NEVER do)

| Don't | Do Instead |
|-------|------------|
| Comment every line | Let code self-document |
| Helper for one-liner | Inline the code |
| Factory for 2 objects | Direct instantiation |
| `utils.ts` with 1 function | Put code where it's used |
| Deep nesting (3+ levels) | Guard clauses + extract function |
| 100+ line functions | Split by responsibility |
| Copy-paste code | Extract shared helper |
| `any` type (TypeScript) | `unknown` with type narrowing |
| Bare `except`/`catch` | Specify exception type |

---

## Before Editing Any File (THINK FIRST)

| Question | Why |
|----------|-----|
| What imports this file? | Dependents might break |
| What does this file import? | Interface changes cascade |
| What tests cover this? | Tests might need updating |
| Is this shared code? | Multiple consumers affected |

> Edit the file + all dependent files in the SAME task. Never leave broken imports.

---

## Stack-Specific Rules

> Fill in per project. Delete sections that don't apply.

### Python (selective from coderroleggg/python.md, adapted for FastAPI + SQLAlchemy)

**Environment**:
- Use `uv` for dependency management. Never `pip install` directly into the project.
- Virtual env in `.venv/`. Always run `uv sync` before executing code.

**Type safety** (modern syntax mandatory):
- All public functions have complete type annotations (params + return)
- `from __future__ import annotations` at the top of every module
- `list[str]` / `dict[str, int]` — NOT `List[str]` / `Dict[str, int]`
- `X | None` — NOT `Optional[X]`
- No `Any` unless documented why with a comment

**Type checker**: mypy (one tool, strict mode). pyright is NOT used in this project — pick one or the other, never both.

**Lint + format**: ruff (replaces black, flake8, isort).
```toml
# pyproject.toml
[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "B", "UP", "ASYNC", "S", "C4"]
```

**Runtime checks**: NOT using `beartype`. FastAPI/Pydantic already validate at API boundaries; runtime decoration on all public functions is unnecessary overhead.

**FastAPI specifics**:
- Async routes must not block event loop (no sync I/O — `requests.get` is forbidden, use `httpx.AsyncClient`)
- Use `Depends()` for injection — never instantiate auth/db manually inside handlers
- Pydantic models for request/response — never raw dicts

**SQLAlchemy specifics**:
- Sync sessions: explicit `with session.begin():` blocks for transactions
- Never `session.commit()` followed by another query without scoping
- Avoid lazy loading in API responses (N+1 risk) — eager-load with `selectinload`/`joinedload`

### TypeScript/React
- Never use `any` — use `unknown` with narrowing
- `useEffect` dependencies must be complete
- No `console.log` in production code

### Docker
- No `latest` tags — pin versions
- No secrets in Dockerfile or docker-compose
- Multi-stage builds for production images

---

## Documentation & Context Management

| Rule | Description |
|------|-------------|
| Progressive disclosure | Rule/skill files stay lean (<100 lines). Deep reference material goes in `references/` subdirectory and is loaded on demand |
| No wall of text | Break long docs into sections with headers. Reader should find what they need in 10 seconds |
| Single source of truth | Each fact lives in ONE file. Cross-reference, don't duplicate |
| Context budget | Claude reads 6+ docs at session start. Keep each under 100 lines. If growing — split |

### File Size Limits

| File type | Max lines | If exceeded |
|-----------|-----------|-------------|
| `.claude/rules/*.md` | 100 | Extract details to `references/` |
| `.claude/skills/*/SKILL.md` | 100 | Move deep content to `references/` in skill dir |
| `docs/*.md` | 200 | Split by topic |
| Spec files | No limit | But use sections with clear headers |

---

## Adding New Conventions

When team agrees on a new convention:
1. Add it to the appropriate section above
2. If it came from a failure — cross-reference `docs/FAILS.md`
3. Apply to new code immediately; refactor existing code opportunistically
