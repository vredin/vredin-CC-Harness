# PostgreSQL modernization (PG 15+)

## Indexing

| Modern | Outdated |
|---|---|
| `CREATE INDEX CONCURRENTLY` for prod migrations | regular `CREATE INDEX` (locks table) |
| Partial indexes for "where status = 'active'" hot paths | full index that's mostly unused |
| Covering indexes via `INCLUDE (col1, col2)` | composite index forcing extra heap reads |
| BRIN for huge append-only tables (logs, time-series) | btree for everything |
| GIN on JSONB / arrays / full-text | LIKE '%foo%' on text |

## JSON

| Modern | Outdated |
|---|---|
| `JSONB` | `JSON` (text storage, no indexing) |
| `jsonb_path_query` / `jsonb_path_exists` | `->`, `->>` chains for complex queries |
| Indexed expression: `CREATE INDEX ON tbl ((data->>'field'))` | full table scan |

## Migrations

| Modern | Outdated |
|---|---|
| Expand → migrate data → contract | one-step alter |
| Reversible migrations or up-only with explicit policy | `down()` empty + hope |
| `ALTER TABLE ADD COLUMN` with default — Postgres 11+ doesn't rewrite | rewrite-the-table panic |
| Lock-aware: `SET lock_timeout = '5s'` in migration scripts | indefinite lock waits |

## Concurrency

| Modern | Outdated |
|---|---|
| `SELECT ... FOR UPDATE SKIP LOCKED` for queue patterns | `FOR UPDATE` blocking |
| Advisory locks (`pg_advisory_lock`) for app-level mutex | external Redis lock |
| `SERIALIZABLE` isolation only when truly needed | always default `READ COMMITTED` |

## Replication / scaling

| Modern | Outdated |
|---|---|
| Logical replication / pgcdc for read-replicas + ETL | physical replicas only |
| Connection pooling via PgBouncer (transaction mode) | direct connections from each app instance |
| `pg_stat_statements` enabled for query-perf debugging | flying blind |

## Patterns rejected as cargo cult

- **NOSQL because relational is "old"** — PG handles JSON, time-series, full-text, vectors well
- **Sharding before vertical scale** — PG scales vertically a long way; shard only when proven needed
- **"Just use ORM, don't write SQL"** — knowing how `EXPLAIN` works is non-negotiable

## Useful features underused

- `RETURNING` clause on INSERT/UPDATE/DELETE
- `WITH RECURSIVE` for tree queries
- Window functions (`ROW_NUMBER()`, `LAG()`, `LEAD()`)
- `pg_trgm` for fuzzy text search
- `pgvector` for embeddings (modern relevant for AI apps)
- Generated columns (`GENERATED ALWAYS AS ... STORED`)

## Sources

- PostgreSQL release notes (15, 16, 17)
- Use The Index, Luke (markus winand)
- pgexperts blog
