# Docker / infrastructure modernization (2025-26)

## Dockerfile

| Modern | Outdated |
|---|---|
| Multi-stage builds (build + runtime separate) | single-stage with build deps in final image |
| Distroless or `alpine` runtime | `ubuntu` / `debian` for trivial services |
| Non-root user (`USER appuser`) | running as root |
| Pinned base images (`python:3.11-slim-bookworm@sha256:...`) | `python:latest` |
| `--mount=type=cache` for package install caching (BuildKit) | every build downloads everything |
| `COPY --link` for fast layer copies | regular `COPY` |
| `.dockerignore` excludes `.env`, `.git`, `node_modules`, secrets | nothing excluded |

## docker-compose

| Modern | Outdated |
|---|---|
| Compose v2 spec (`services:` no `version:` line) | `version: '3.8'` (deprecated) |
| `depends_on:` with `condition: service_healthy` | bare `depends_on:` |
| `healthcheck:` block on every service | hope-based startup |
| Named volumes with explicit `driver:` | bind mounts to host paths |
| Profiles for dev/prod/test variations | separate compose files duplicating config |

## Traefik (since user uses it)

| Modern (Traefik v3) | Outdated (v2) |
|---|---|
| YAML labels with v3 syntax | v2 syntax (still works but transition) |
| HTTP/3 enabled | HTTP/2 only |
| ECS / Kubernetes provider for dynamic config | static file provider |
| `tls.options` references TLS 1.2+ profile | default (allows TLS 1.0/1.1) |
| Plugins via Traefik Plugin Catalog | none |

## Deployment

| Modern | Outdated |
|---|---|
| Reversible deploy with explicit rollback in RUNBOOK | "we'll figure it out" |
| Zero-downtime: rolling / blue-green / canary chosen explicitly | restart and pray |
| DB migrations in expand/contract (decoupled from app deploy) | migrations + app in same step |
| Secrets via env or vault, never in image | secrets baked in |
| Image scanning (Trivy, Grype) in CI | nothing scans the image |

## CI/CD (GitHub Actions)

| Modern | Outdated |
|---|---|
| Third-party actions pinned to `@<sha256>` | `@main` / `@v1` (mutable refs) |
| `permissions:` declared per-job (least privilege) | default permissive token |
| Reusable workflows + composite actions | copy-paste across jobs |
| `actions/cache@v4` with proper key strategy | no caching → slow builds |
| OIDC for cloud auth (no long-lived secrets) | `AWS_SECRET_ACCESS_KEY` in repo secrets |

## Observability

| Modern | Outdated |
|---|---|
| OpenTelemetry (vendor-neutral) for traces + metrics + logs | vendor-specific SDKs |
| Loki / Tempo / Grafana stack OR vendor (Datadog, etc.) | "we tail logs via SSH" |
| Prometheus exposition format | bespoke metrics format |
| Structured logs (JSON) with `request_id` correlation | plain text grep |
| Sentry / Highlight for error tracking | hope users report |

## Patterns rejected as cargo cult

- **Kubernetes for 1-service deployments** — Compose + Traefik is fine until you outgrow it
- **Service mesh for 3 services** — Istio / Linkerd add complexity rarely justified
- **"Just use lambda"** — for steady-state workloads, containers are cheaper and simpler

## Sources

- Docker official best-practices doc
- Traefik v3 release notes
- GitHub Actions security hardening guide
- OpenTelemetry semantic conventions
