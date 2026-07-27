---
description: 'Full quality-gate pipeline + automated production deploy. Reads server config from docs/STACK.md (deploy_* fields). HARD STOP on any failure. Auto-rollback on post-migration failure (S11). Skips E2E if not configured (S12).'
allowed-tools: Bash, Read
model: sonnet
---

> **Style:** Load `caveman-distillate` skill — terse, step-by-step.

# /deploy — production deploy pipeline (v3.1+)

You are executing the production deploy pipeline for **[reads project name from CLAUDE.md]**. Follow ALL steps in order.

**HARD RULE: If any Bash command exits with a nonzero code, OR if the output contains `ABORT:`, stop immediately. Print the failure output. Print the recovery hint. DO NOT proceed to the next step.**

**HARD RULE: If a step AFTER migrations (STEP 5) fails AND `migration_cmd` ran successfully — auto-invoke `migration_downgrade` before stopping. This is the S11 rollback guarantee.**

Read `docs/DEPLOY.md` first (server access, secrets protocol). Read `docs/STACK.md` deploy section second (commands + fields).

---

## STEP 0 — Load config from STACK.md

```bash
STACK="docs/STACK.md"
[ -f "$STACK" ] || { echo "ABORT: docs/STACK.md missing. Run /init-project or /setup first."; exit 1; }

# Helper: extract value of yaml key from a code block
_yaml() {
  grep -E "^${1}:" "$STACK" | sed -E "s/^${1}:[[:space:]]*\"?//;s/\"?[[:space:]]*(#.*)?$//" | head -1
}

# Required fields
SSH_ALIAS=$(_yaml ssh_alias)
DEPLOY_RUNTIME=$(_yaml deploy_runtime)
DEPLOY_PATH=$(_yaml deploy_path)
DEPLOY_SERVICES=$(_yaml deploy_services)

# Optional with default
DEPLOY_BRANCH=$(_yaml deploy_branch)
[ -z "$DEPLOY_BRANCH" ] && DEPLOY_BRANCH="main"

# Optional fields
LINT_CMD=$(_yaml lint_cmd)
TYPECHECK_CMD=$(_yaml typecheck_cmd)
TEST_BACKEND=$(_yaml test_backend)
MIGRATION_CMD=$(_yaml migration_cmd)
MIGRATION_DOWNGRADE=$(_yaml migration_downgrade)
MIGRATION_PATH_GREP=$(_yaml migration_path_grep)
HEALTH_ENDPOINT=$(_yaml health_endpoint)
HEALTH_SHA_FIELD=$(_yaml health_sha_field)
E2E_DIR=$(_yaml e2e_dir)
E2E_CMD=$(_yaml e2e_cmd)
E2E_CREDS_KEYS=$(_yaml e2e_creds_env_keys)
BACKUP_CHECK_CMD=$(_yaml backup_check_cmd)
DB_DUMP_CMD=$(_yaml db_dump_cmd)
BACKUP_MAX_AGE_HOURS=$(_yaml backup_max_age_hours)

# Validate required
for k in SSH_ALIAS DEPLOY_RUNTIME DEPLOY_PATH DEPLOY_SERVICES; do
  v=$(eval "echo \$$k")
  if [ -z "$v" ] || [[ "$v" == *"[e.g."* ]] || [[ "$v" == *"[PROJECT"* ]]; then
    echo "ABORT: STACK.md field $(echo $k | tr '[:upper:]' '[:lower:]') not configured. Fill it in docs/STACK.md."
    exit 1
  fi
done

echo "Deploy config:"
echo "  ssh_alias:       $SSH_ALIAS"
echo "  deploy_runtime:  $DEPLOY_RUNTIME"
echo "  deploy_path:     $DEPLOY_PATH"
echo "  deploy_services: $DEPLOY_SERVICES"
echo "  deploy_branch:   $DEPLOY_BRANCH"
echo "  migration:       ${MIGRATION_CMD:-skip}"
echo "  health_endpoint: ${HEALTH_ENDPOINT:-skip}"
echo "  e2e_dir:         ${E2E_DIR:-skip}"
```

---

## STEP 0.5 — Pre-flight (local + remote state)

```bash
# Local: no uncommitted tracked changes
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "ABORT: Uncommitted tracked changes. Commit first (or stash + redeploy)."
  exit 1
fi

# Warn on untracked files (but don't abort)
UNTRACKED=$(git ls-files --others --exclude-standard | head -5)
[ -n "$UNTRACKED" ] && echo "WARNING: Untracked files (not deployed): $UNTRACKED"

# HARD STOP if local branch != deploy_branch (catches "I'm on a feature branch" mistake during multi-project context switching)
BRANCH=$(git branch --show-current)
if [ "$BRANCH" != "$DEPLOY_BRANCH" ]; then
  echo "ABORT: local branch ($BRANCH) != deploy_branch ($DEPLOY_BRANCH). Switch first: git checkout $DEPLOY_BRANCH"
  exit 1
fi

# Remote: SSH reachability
ssh "$SSH_ALIAS" echo ok || { echo "ABORT: Cannot reach $SSH_ALIAS. Check SSH config + network."; exit 1; }

# Remote: server has no local modifications
DIRTY=$(ssh "$SSH_ALIAS" "cd $DEPLOY_PATH && git status --porcelain" 2>&1)
if [ -n "$DIRTY" ]; then
  echo "ABORT: Server has local modifications in $DEPLOY_PATH:"
  echo "$DIRTY"
  echo "Fix manually before redeploying."
  exit 1
fi
```

---

## STEP 0.6 — CVE gate (dependency vulnerabilities — HARD STOP)

New CVEs get disclosed independent of your diff — a dependency can go from clean to vulnerable
while your code sits still. This runs on **every** deploy, not only when a manifest changed
(that narrower diff-triggered version lives in `/review` STEP 2 and `/orchestrate` STEP 7.5).
See `docs/rules-references/security-toolchain.md`.

```bash
CVE_FOUND=0

if [ -f package.json ]; then
  if command -v npm >/dev/null 2>&1; then
    echo "→ npm audit"
    CRIT=$(npm audit --omit=dev --json 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin).get('metadata',{}).get('vulnerabilities',{}); print(d.get('critical',0)+d.get('high',0))" 2>/dev/null || echo 0)
    [ "${CRIT:-0}" -gt 0 ] 2>/dev/null && CVE_FOUND=1
  else
    echo "[SKIP] npm audit — npm not installed"
  fi
fi

if [ -f requirements.txt ] || [ -f pyproject.toml ]; then
  if command -v pip-audit >/dev/null 2>&1; then
    echo "→ pip-audit"
    pip-audit -f json > /tmp/deploy-pip-audit.json 2>/dev/null
    grep -q '"fix_versions"' /tmp/deploy-pip-audit.json 2>/dev/null && CVE_FOUND=1
  else
    echo "[SKIP] pip-audit — not installed"
  fi
fi

if command -v osv-scanner >/dev/null 2>&1; then
  echo "→ osv-scanner"
  osv-scanner scan -r --format json . 2>/dev/null | python3 -c "
import sys, json
d = json.load(sys.stdin)
n = sum(len(r.get('packages', [])) for r in d.get('results', []))
sys.exit(1 if n > 0 else 0)
" || CVE_FOUND=1
else
  echo "[SKIP] osv-scanner — not installed"
fi

if [ "$CVE_FOUND" = "1" ]; then
  echo "ABORT: CRITICAL/HIGH dependency vulnerability found. See docs/rules-references/security-toolchain.md."
  echo "Fix: upgrade the flagged package(s), re-run the scanner to confirm clean, then re-run /deploy."
  exit 1
fi
echo "CVE gate: clean (any [SKIP] line above = that scanner not installed — unknown, not a pass)"
```

> Unknown ≠ pass: a missing scanner binary prints `[SKIP]` for that ecosystem, it never silently
> counts as clean. Same treatment as the security scanners in `docs/rules-references/security-toolchain.md`.

---

## STEP 1 — Lint + typecheck (local)

```bash
[ -n "$LINT_CMD" ] && { echo "→ $LINT_CMD"; eval "$LINT_CMD" || { echo "ABORT: lint failed."; exit 1; }; }
[ -n "$TYPECHECK_CMD" ] && { echo "→ $TYPECHECK_CMD"; eval "$TYPECHECK_CMD" || { echo "ABORT: typecheck failed."; exit 1; }; }
```

---

## STEP 2 — Push to remote

```bash
git push origin "$BRANCH"
```

→ Must succeed before server pull. If rejected: STOP, do not proceed.

---

## STEP 3 — Deliver secrets (only if .env.production changed)

```bash
SECRETS_CHANGED=$(git diff HEAD~1 HEAD --name-only 2>/dev/null | grep -q '.env.production' && echo yes || echo no)
echo "Secrets changed in last commit: $SECRETS_CHANGED"
```

**If SECRETS_CHANGED=yes** — key-by-key update on server (NEVER full overwrite):

```bash
while IFS='=' read -r key value; do
  [[ "$key" =~ ^# ]] && continue
  [[ -z "$key" ]] && continue
  # Note: server path is $DEPLOY_PATH/.env (active prod env, NOT .env.production)
  ssh "$SSH_ALIAS" "sed -i.bak \"s|^${key}=.*|${key}=${value}|\" $DEPLOY_PATH/.env || echo \"${key}=${value}\" >> $DEPLOY_PATH/.env"
done < .env.production

# S9 FIX: clean up .env.bak left by sed -i.bak (contained pre-rotation secrets)
ssh "$SSH_ALIAS" "rm -f $DEPLOY_PATH/.env.bak"
echo "Secrets delivered. .env.bak cleaned up."
```

> ⚠️ Key-by-key, NOT full `scp` overwrite — prevents reverting other secrets already on server.
> ✅ S9 mitigation: `.env.bak` removed after sed completes.

---

## STEP 4 — Pull + rebuild on server

```bash
SVC_LIST=$(echo "$DEPLOY_SERVICES" | tr ',' ' ')

case "$DEPLOY_RUNTIME" in
  docker-compose)
    ssh "$SSH_ALIAS" "cd $DEPLOY_PATH && git pull origin $DEPLOY_BRANCH && sudo docker compose up -d --build $SVC_LIST"
    ;;
  systemd)
    ssh "$SSH_ALIAS" "cd $DEPLOY_PATH && git pull origin $DEPLOY_BRANCH"
    for svc in $SVC_LIST; do
      ssh "$SSH_ALIAS" "sudo systemctl restart $svc"
    done
    ;;
  pm2)
    ssh "$SSH_ALIAS" "cd $DEPLOY_PATH && git pull origin $DEPLOY_BRANCH && pm2 reload $SVC_LIST"
    ;;
  none)
    ssh "$SSH_ALIAS" "cd $DEPLOY_PATH && git pull origin $DEPLOY_BRANCH"
    echo "WARNING: deploy_runtime=none — code pulled, NO service restart. Manual restart required if needed."
    ;;
  *)
    echo "ABORT: Unknown deploy_runtime '$DEPLOY_RUNTIME'. Use: docker-compose | systemd | pm2 | none."
    exit 1
    ;;
esac
```

→ Confirm pull shows commits, not "Already up to date". If "Already up to date" — STOP, push may have failed silently.

> **Migration tracking starts here:** if STEP 5 succeeds and any subsequent step fails, we auto-rollback.

```bash
MIGRATION_APPLIED=0   # tracks for S11 auto-rollback
```

---

## STEP 4.7 — Backup gate (HARD STOP — runs whenever migrations will run)

> F-161 (OSINT 2026-07-16): prod schema wiped; daily backups had been silently dead for
> 8 weeks; restore lost a week of data. Migrations NEVER run against a DB whose backup
> story is unverified. Reads `backup_check_cmd` / `db_dump_cmd` / `backup_max_age_hours`
> from `docs/STACK.md`.

```bash
RUN_MIGRATIONS=no
if [ -n "$MIGRATION_CMD" ] && [ -n "$MIGRATION_PATH_GREP" ]; then
  git diff HEAD~1 HEAD --name-only | grep -q "$MIGRATION_PATH_GREP" && RUN_MIGRATIONS=yes
fi

if [ "$RUN_MIGRATIONS" = "yes" ]; then
  # 1. Backup freshness — backup_check_cmd must print the age of the newest backup
  #    in hours (integer). Empty backup_check_cmd → HARD STOP (unknown ≠ ok).
  if [ -z "$BACKUP_CHECK_CMD" ]; then
    echo "ABORT: migrations pending but backup_check_cmd is empty in STACK.md."
    echo "No verified backup story → no migrations. Fill backup_check_cmd first."
    exit 1
  fi
  AGE_H=$(ssh "$SSH_ALIAS" "$BACKUP_CHECK_CMD" 2>/dev/null | tr -dc '0-9')
  MAX_AGE=${BACKUP_MAX_AGE_HOURS:-24}
  if [ -z "$AGE_H" ] || [ "$AGE_H" -gt "$MAX_AGE" ]; then
    echo "ABORT: newest backup is ${AGE_H:-UNKNOWN}h old (limit ${MAX_AGE}h)."
    echo "Fix the backup first (this exact gap cost a week of data in F-161)."
    exit 1
  fi
  echo "Backup freshness OK: ${AGE_H}h ≤ ${MAX_AGE}h"

  # 2. Pre-migration dump with size sanity — non-empty and not shrunk >30% vs previous.
  if [ -n "$DB_DUMP_CMD" ]; then
    STAMP=$(date +%Y%m%d-%H%M%S)
    ssh "$SSH_ALIAS" "$DB_DUMP_CMD /tmp/premig-$STAMP.dump" || { echo "ABORT: pre-migration dump failed."; exit 1; }
    SIZE=$(ssh "$SSH_ALIAS" "stat -c%s /tmp/premig-$STAMP.dump 2>/dev/null || stat -f%z /tmp/premig-$STAMP.dump")
    PREV=$(ssh "$SSH_ALIAS" "ls -t /tmp/premig-*.dump 2>/dev/null | sed -n 2p | xargs -r stat -c%s 2>/dev/null" || true)
    [ -z "$SIZE" ] || [ "$SIZE" -lt 1024 ] && { echo "ABORT: dump is empty/tiny ($SIZE bytes) — backup theatre, not a backup."; exit 1; }
    if [ -n "$PREV" ] && [ "$SIZE" -lt $((PREV * 70 / 100)) ]; then
      echo "ABORT: dump shrank >30% vs previous ($SIZE vs $PREV bytes) — investigate before migrating."
      exit 1
    fi
    echo "Pre-migration dump OK: /tmp/premig-$STAMP.dump ($SIZE bytes)"
  else
    echo "WARN: db_dump_cmd empty — no pre-migration dump. Freshness gate passed; strongly recommend filling db_dump_cmd."
  fi
fi
```

---

## STEP 5 — Run DB migrations (if migration_cmd set AND migration files changed)

```bash
if [ "$RUN_MIGRATIONS" = "yes" ]; then
  echo "→ Running migrations: $MIGRATION_CMD"
  ssh "$SSH_ALIAS" "cd $DEPLOY_PATH && $MIGRATION_CMD"
  if [ $? -ne 0 ]; then
    echo "ABORT: Migration failed. NOT applied. Safe to retry — schema unchanged."
    exit 1
  fi
  MIGRATION_APPLIED=1
  echo "Migrations applied."
fi
```

> **S11 invariant:** From this point, if anything fails, we run `migration_downgrade` before exiting.

---

## STEP 6 — Verify services up

```bash
case "$DEPLOY_RUNTIME" in
  docker-compose)
    STATUS=$(ssh "$SSH_ALIAS" "cd $DEPLOY_PATH && sudo docker compose ps --format \"table {{.Name}}\t{{.Status}}\"")
    echo "$STATUS"
    # Every requested service must be Up
    for svc in $(echo "$DEPLOY_SERVICES" | tr ',' ' '); do
      echo "$STATUS" | grep -E "$svc.*Up" >/dev/null || {
        echo "ABORT: Service '$svc' not Up."
        _rollback_if_needed
        exit 1
      }
    done
    ;;
  systemd)
    for svc in $(echo "$DEPLOY_SERVICES" | tr ',' ' '); do
      ssh "$SSH_ALIAS" "sudo systemctl is-active $svc" | grep -q '^active$' || {
        echo "ABORT: systemd service '$svc' not active."
        _rollback_if_needed
        exit 1
      }
    done
    ;;
  pm2)
    ssh "$SSH_ALIAS" "pm2 list" | grep -E 'online' >/dev/null || {
      echo "ABORT: pm2 services not online."
      _rollback_if_needed
      exit 1
    }
    ;;
esac
```

---

## STEP 7 — Verify deployed code is live (S10 verify-live)

**Mode A — robust (recommended):** if `health_endpoint` + `health_sha_field` set, hit /health and check the SHA matches.

```bash
LOCAL_SHA=$(git rev-parse HEAD)

if [ -n "$HEALTH_ENDPOINT" ] && [ -n "$HEALTH_SHA_FIELD" ]; then
  # Wait up to 30s for health endpoint to respond after restart
  WAIT=0
  until ssh "$SSH_ALIAS" "curl -sf '$HEALTH_ENDPOINT' >/dev/null 2>&1"; do
    WAIT=$((WAIT+3))
    [ $WAIT -gt 30 ] && { echo "ABORT: health endpoint not responding after 30s"; _rollback_if_needed; exit 1; }
    sleep 3
  done

  DEPLOYED_SHA=$(ssh "$SSH_ALIAS" "curl -s '$HEALTH_ENDPOINT'" | python3 -c "import sys,json; print(json.load(sys.stdin).get('$HEALTH_SHA_FIELD',''))" 2>/dev/null)
  if [ "$DEPLOYED_SHA" = "${LOCAL_SHA:0:${#DEPLOYED_SHA}}" ] || [ "${DEPLOYED_SHA:0:7}" = "${LOCAL_SHA:0:7}" ]; then
    echo "✓ Verify-live: deployed SHA matches ($DEPLOYED_SHA)"
  else
    echo "ABORT: SHA mismatch — local=$LOCAL_SHA deployed=$DEPLOYED_SHA. New code is NOT running."
    _rollback_if_needed
    exit 1
  fi

# Mode B — fragile fallback (grep a changed line on the server):
else
  echo "WARNING: health_endpoint/health_sha_field not configured — using fragile grep fallback. Add fields to STACK.md for robust verify-live."
  CHANGED_FILE=$(git diff HEAD~1 HEAD --name-only | grep -vE '(alembic|migration)/' | head -1)
  [ -z "$CHANGED_FILE" ] && { echo "No diff to verify against. Skipping."; }
  if [ -n "$CHANGED_FILE" ]; then
    KEYWORD=$(git diff HEAD~1 HEAD -- "$CHANGED_FILE" | grep '^+' | grep -v '^+++' | head -1 | sed 's/^+//' | tr -d ' ' | cut -c1-30)
    ssh "$SSH_ALIAS" "grep -rn '$KEYWORD' $DEPLOY_PATH/$CHANGED_FILE 2>/dev/null | head -3" || echo "WARNING: Could not verify change on server — check manually"
  fi
fi
```

> ⚠️ "Up" containers ≠ "new code running". Always verify the SHA or grep the file.

---

## STEP 8 — Run tests on server (if test_backend set)

```bash
if [ -n "$TEST_BACKEND" ]; then
  echo "→ $TEST_BACKEND"
  ssh "$SSH_ALIAS" "cd $DEPLOY_PATH && $TEST_BACKEND" || {
    echo "ABORT: Server-side tests failed."
    _rollback_if_needed
    exit 1
  }
fi
```

---

## STEP 8.5 — E2E tests against production (S12 opt-in)

```bash
# S12: skip silently if e2e_dir doesn't exist or e2e_cmd not set
if [ -z "$E2E_CMD" ] || [ -z "$E2E_DIR" ] || [ ! -d "$E2E_DIR" ]; then
  echo "[SKIP] E2E step — no $E2E_DIR or e2e_cmd unset. (Backend-only services: this is normal.)"
else
  # Pull credentials from server .env (if e2e_creds_env_keys set)
  if [ -n "$E2E_CREDS_KEYS" ]; then
    for key in $E2E_CREDS_KEYS; do
      val=$(ssh "$SSH_ALIAS" "grep '^${key}=' $DEPLOY_PATH/.env | cut -d= -f2-")
      [ -z "$val" ] && { echo "ABORT: E2E cred $key not in server .env"; _rollback_if_needed; exit 1; }
      export "$key=$val"
    done
  fi

  echo "→ $E2E_CMD"
  eval "$E2E_CMD" || {
    echo "ABORT: E2E tests failed against production. Login / critical UI is broken."
    _rollback_if_needed
    exit 1
  }
fi
```

> curl /health only verifies a 200 status code. Playwright verifies actual UI behavior. Both required for serious projects.

---

## STEP 9 — Notify user

```
✅ Deployed: $(grep -m1 '^# ' CLAUDE.md | sed 's/^# //') → $SSH_ALIAS:$DEPLOY_PATH
Commit: $(git log -1 --format="%h %s")
Services: <list>
Verify-live: ✓ (SHA $LOCAL_SHA matches)
Tests: ✓
E2E: ✓ (or [skipped])
```

---

## Rollback helper (S11 auto-rollback)

```bash
_rollback_if_needed() {
  if [ "$MIGRATION_APPLIED" = "1" ] && [ -n "$MIGRATION_DOWNGRADE" ]; then
    echo ""
    echo "=== S11 AUTO-ROLLBACK: migration was applied, rolling back schema ==="
    ssh "$SSH_ALIAS" "cd $DEPLOY_PATH && $MIGRATION_DOWNGRADE"
    if [ $? -eq 0 ]; then
      echo "Migration rolled back to previous version."
      echo "NEXT: investigate the failure, fix, redeploy. Schema is back to pre-deploy state."
    else
      echo "!!! ROLLBACK FAILED !!!"
      echo "Schema may be in inconsistent state. MANUAL INTERVENTION REQUIRED."
      echo "On server: $ ssh $SSH_ALIAS"
      echo "Then: cd $DEPLOY_PATH && <run downgrade manually or restore from DB backup>"
    fi
  elif [ "$MIGRATION_APPLIED" = "1" ] && [ -z "$MIGRATION_DOWNGRADE" ]; then
    echo ""
    echo "=== WARNING: migration was applied but migration_downgrade is unset in STACK.md ==="
    echo "Schema is at NEW version but new code may not be running."
    echo "Manual rollback required. See docs/DEPLOY.md and docs/RUNBOOK.md."
  fi
}
```

> Call `_rollback_if_needed` immediately before every ABORT exit after STEP 5. Already inserted in STEPs 6, 7, 8, 8.5 above.

---

## Manual rollback (if /deploy aborted with no migration to revert, or you just want a previous commit)

```bash
ssh "$SSH_ALIAS" "cd $DEPLOY_PATH && git log --oneline -5"
# Pick safe commit hash from output
ssh "$SSH_ALIAS" "cd $DEPLOY_PATH && git checkout <hash>"
# Restart per deploy_runtime (docker compose up -d --build / systemctl / pm2 reload)
```

---

## Rules

- **NEVER** ask user to edit `.env` on server manually (S9 protocol)
- **NEVER** use `git push --force` to fix push rejection — fix the diverge locally
- **NEVER** skip STEP 7 verify-live — "Up" containers can run stale code (caching, build error masked)
- **ALWAYS** run STEP 8.5 if `e2e_dir` exists — Playwright catches what curl /health misses
- **ALWAYS** /rollback if STEP 6+ fails AND migration was applied (S11 auto-rollback handles this)
- Re-run `/deploy` after fixing a failure — pipeline is idempotent

---

## Related

- `docs/DEPLOY.md` — server access, secrets protocol (read first)
- `docs/STACK.md` — deploy_* config fields (filled per project)
- `docs/RUNBOOK.md` — what to do when prod misbehaves
- `.claude/skills/webapp-testing/` — E2E test patterns
- `/canary` — alternative for staged rollout (vs all-at-once /deploy)
