---
name: code-modernization
description: 'Reference for modern (2025-26) idioms in user stack: Python/FastAPI/SQLAlchemy, TypeScript/React, Docker, PostgreSQL. Loaded by /gaps modern. Update as ecosystem evolves.'
---

# Code Modernization — 2025-26 idioms

> Maintained reference. When the ecosystem shifts (e.g., Pydantic v3, React 20, etc.), update this file rather than scattering version notes across commands.

## Routing

| Stack area | Sub-file |
|---|---|
| Python (FastAPI / SQLAlchemy / pytest) | `python.md` |
| TypeScript / React | `typescript.md` |
| Docker / infrastructure | `infra.md` |
| PostgreSQL | `postgres.md` |

Each sub-file: a checklist of modern-vs-outdated patterns + reasoning + migration notes.

## Maintenance discipline

- Add an item only if you can cite a source (PEP, framework changelog, official docs).
- Remove an item once it's "common knowledge for >2 years" (saves checklist bloat).
- When user disagrees with an item — they document in `docs/adr/` and the item moves to `disputed.md` (per-project, not per-template).

## Source of truth

This skill is opinionated. If user's project has explicit ADR overriding an item — ADR wins.
