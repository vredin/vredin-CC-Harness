# [PROJECT_NAME] — Stack & Commands

> Filled by `/init-project`. All commands resolved from here, no hardcoded `npx`/`uv` in agents.

## Stack

| Layer | Tech |
|-------|------|
| Backend | [e.g. Python 3.11 / FastAPI / SQLAlchemy / PostgreSQL] |
| Frontend | [e.g. React 18 / TypeScript / Vite] |
| Infra | [e.g. Docker Compose / Traefik / VPS] |

## Commands (used by agents)

```yaml
# Read by orchestrator, /fix, /test, /general
# RULE: only fill commands that are actually declared in pyproject.toml / package.json.
# Leave field empty ("") if tool is not configured — agents skip empty commands.
lint_cmd:        "uv run ruff check ."
typecheck_cmd:   ""   # set only if mypy/pyright declared in pyproject.toml dev deps; e.g. "uv run mypy app/ --ignore-missing-imports"
format_cmd:      "uv run ruff format ."
test_backend:    "uv run pytest tests/ -q --tb=short"
test_frontend:   "npx tsc --noEmit && npx vitest run"
test_e2e:        "npx playwright test --reporter=list"
test_all:        "<test_backend> && <test_frontend> && <test_e2e>"
```

## Production access (used by /general, /report)

```yaml
ssh_alias:       "[e.g. slugger]"
db_container:    "[e.g. slugger-db-1]"
db_user:         "[e.g. slugger]"
db_name:         "[e.g. slugger_crm]"
app_service:     "[e.g. app]"             # docker compose service name
logs_default:    "ssh <alias> 'sudo docker compose logs <app_service> --tail=50'"
```

Set in `~/.zshrc` for `bin/psql_ro.sh`:
```bash
export PROD_SSH_ALIAS=slugger
export PROD_DB_CONTAINER=slugger-db-1
export PROD_DB_USER=slugger
export PROD_DB_NAME=slugger_crm
```

## Outline knowledge base

```yaml
outline_url:           "https://your-outline.example.com"
shared_collection:     "Knowledge Base"        # Fails / Best Practices / Daily Status / Tricks
project_collection:    "Project: [PROJECT_NAME]"
```

## Source layout

```
[PROJECT_NAME]/
├── app/              # backend source
├── frontend/         # frontend source (if any)
├── tests/            # tests
├── docs/             # this directory
└── bin/              # outline.sh, psql_ro.sh, project scripts
```

## Deploy (used by /deploy)

```yaml
# Required — /deploy aborts if these are empty:
deploy_runtime:        "docker-compose"    # docker-compose | systemd | pm2 | none
deploy_path:           "/opt/[PROJECT]"    # absolute path on server, where `git pull` runs
deploy_services:       "api"               # comma-separated service names (docker compose svc / systemd unit names)

# Optional — fields trigger their step if filled, skipped if empty:
migration_cmd:         ""                  # e.g. "docker compose exec -T api python -m alembic upgrade head"
migration_downgrade:   ""                  # e.g. "docker compose exec -T api python -m alembic downgrade -1"  (S11 auto-rollback)
migration_path_grep:   ""                  # e.g. "alembic/" — if files matching grep changed in diff, migration_cmd is invoked
health_endpoint:       ""                  # e.g. "http://localhost:8000/health" — server-side curl target
health_sha_field:      ""                  # e.g. "git_sha" — JSON field in /health containing deployed commit SHA (S10 verify-live)
e2e_dir:               "tests/e2e"         # path to e2e tests; non-existent → STEP 8.5 skips silently (S12 opt-in)
e2e_cmd:               ""                  # e.g. "uv run pytest tests/e2e/ -m e2e -v"
e2e_creds_env_keys:    ""                  # space-separated env var names from server .env, e.g. "E2E_ADMIN_EMAIL E2E_ADMIN_PASSWORD"

# Backup gate (STEP 4.7 — HARD STOP before migrations; F-161):
backup_check_cmd:      ""                  # runs ON SERVER, must print age of newest backup in HOURS, e.g.
                                           #   "echo $(( ($(date +%s) - $(stat -c %Y /backups/latest.dump)) / 3600 ))"
                                           # EMPTY + migrations pending = /deploy ABORTS (unknown ≠ ok)
db_dump_cmd:           ""                  # runs ON SERVER with target path as $1, e.g. "pg_dump -Fc -U app app_db -f"
backup_max_age_hours:  "24"                # newest backup older than this → /deploy aborts before migrations
```

> **/deploy contract:** every required field must be filled. Optional fields are independently togglable — empty = skip step.
>
> **S9 secrets cleanup:** /deploy removes `.env.bak` after sed-injection. No old credentials linger.
>
> **S10 verify-live:** if `health_endpoint` + `health_sha_field` are set, /deploy compares deployed sha against `git rev-parse HEAD`. If unset, fragile grep-on-server fallback (warned in output).
>
> **S11 auto-rollback:** if `migration_cmd` succeeds but a later step fails, /deploy auto-invokes `migration_downgrade`.
>
> **S12 E2E opt-in:** if `$e2e_dir` doesn't exist on disk, /deploy skips STEP 8.5 silently. Backend-only services: leave `e2e_dir` pointing to non-existent path or set empty.
