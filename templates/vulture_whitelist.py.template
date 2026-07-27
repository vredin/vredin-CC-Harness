# Vulture whitelist — ad-hoc symbol names that don't fit pyproject.toml patterns.
#
# CRITICAL: vulture's `_.X` syntax matches LITERAL symbol names, NOT patterns.
# `_.BaseModel` says "name BaseModel is referenced" — useful only if your code
# defines a symbol named exactly "BaseModel". Pydantic SUBCLASSES (UserCreate,
# PortfolioOut, etc.) are matched via `[tool.vulture] ignore_names = ["*Create",
# "*Out", ...]` in pyproject.toml — see /review STEP 4.8 bootstrap which injects
# that block automatically.
#
# This file is a SUPPLEMENT to pyproject.toml [tool.vulture]:
# - pyproject.toml = patterns, decorator-based ignores, project-wide config
# - this file     = literal names that don't fit patterns

# ============================================================
# FastAPI — instance names
# ============================================================
_.app
_.router

# ============================================================
# SQLAlchemy — base class + attributes referenced via metadata
# ============================================================
_.Base
_.metadata
_.__tablename__
_.__table_args__

# ============================================================
# Common framework lifecycle hooks (FastAPI / Starlette)
# ============================================================
_.lifespan
_.startup
_.shutdown

# ============================================================
# Project-specific — add literal names below as you discover them
# ============================================================
# Example for Investments (uncomment if Phase stub params surface):
# _.html_path
# _.channel_name
# _.context_chunks
