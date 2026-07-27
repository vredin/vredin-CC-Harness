# Deploy Configuration

> **Claude reads this file before every deploy action.**
> Fill in once per project. Never ask the user for this info — it's here.

---

## Server Access

| Parameter | Value |
|-----------|-------|
| SSH command | `ssh vps3` |
| Project path on server | `/opt/[PROJECT_NAME]` |
| Reverse proxy | Traefik (configured, running) |
| Web URL | `https://[domain]` |

> **IMPORTANT**: Always use the SSH alias above. Never use raw IP or alternative SSH commands.

---

## Environment Files

| File | Location | Purpose |
|------|----------|---------|
| `.env` | project root (local) | Local development |
| `.env.production` | project root (local, in `.gitignore`) | Production secrets — delivered to server automatically |
| `.env` on server | `[project_path]/.env` | Active production env (managed by deploy script) |

### Secrets Delivery Protocol

1. All production secrets live in **local** `.env.production`
2. On deploy, copy to server: `scp .env.production vps3:[project_path]/.env`
3. **NEVER** ask the user to manually edit `.env` on the server
4. **NEVER** ask the user to re-enter API keys — if they were provided once, they're in `.env.production`
5. If a key is missing from `.env.production` — tell the user which key is missing and ask them to add it locally, then redeploy

---

## Deploy Flow

```bash
# 1. Deliver secrets
scp .env.production vps3:[project_path]/.env

# 2. Pull latest code and restart
ssh vps3 'cd [project_path] && git pull origin main && docker compose up -d --build'

# 3. Verify
ssh vps3 'cd [project_path] && docker compose ps'
# Check that all services are "Up"
```

---

## Services

| Service | URL | Health check |
|---------|-----|-------------|
| [app name] | `https://[domain]` | `curl -s -o /dev/null -w "%{http_code}" https://[domain]/health` |
| [metabase, etc.] | `https://[subdomain]` | — |

---

## Rollback

```bash
ssh vps3 'cd [project_path] && git log --oneline -5'
# Pick the safe commit hash
ssh vps3 'cd [project_path] && git checkout <hash> && docker compose up -d --build'
```

---

## Notes

- Traefik handles SSL and routing — no need to configure nginx/certbot
- Docker Compose is the orchestrator — no k8s, no swarm
- Add project-specific notes below this line:

