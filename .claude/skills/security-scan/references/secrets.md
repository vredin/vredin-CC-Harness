# Secrets & Sensitive Data Exposure — Reference

## Hardcoded Secrets Detection

### Grep Patterns
```bash
# High-signal patterns — almost always a real secret
grep -rn \
  -e "sk-[a-zA-Z0-9]\{20,\}" \
  -e "pk_live_[a-zA-Z0-9]\{20,\}" \
  -e "sk_live_[a-zA-Z0-9]\{20,\}" \
  -e "AKIA[0-9A-Z]\{16\}" \
  -e "ghp_[a-zA-Z0-9]\{36\}" \
  -e "ghs_[a-zA-Z0-9]\{36\}" \
  -e "xoxb-[0-9]" \
  -e "xoxp-[0-9]" \
  --include="*.py" --include="*.ts" --include="*.js" --include="*.go" \
  --include="*.yml" --include="*.yaml" --include="*.json" --include="*.env" \
  . | grep -v node_modules | grep -v __pycache__ | grep -v ".git"

# Medium-signal patterns — check context
grep -rni \
  -e "password\s*=\s*['\"][^'\"]\{4,\}" \
  -e "secret\s*=\s*['\"][^'\"]\{8,\}" \
  -e "api_key\s*=\s*['\"][^'\"]\{8,\}" \
  -e "token\s*=\s*['\"][^'\"]\{8,\}" \
  -e "private_key\s*=\s*['\"]" \
  --include="*.py" --include="*.ts" --include="*.js" \
  . | grep -v node_modules | grep -v "os\.getenv\|process\.env\|os\.environ" | grep -v test
```

### Secret Patterns by Type
```
OpenAI:       sk-[a-zA-Z0-9]{48}
Anthropic:    sk-ant-[a-zA-Z0-9-]{95}
Stripe live:  sk_live_[a-zA-Z0-9]{24}
Stripe test:  sk_test_[a-zA-Z0-9]{24}  (lower risk, still track)
AWS Access:   AKIA[A-Z0-9]{16}
AWS Secret:   [a-zA-Z0-9/+]{40}
GitHub PAT:   ghp_[a-zA-Z0-9]{36} or github_pat_...
Slack token:  xoxb-[0-9]{12}-[0-9]{12}-[a-zA-Z0-9]{24}
Twilio:       SK[a-zA-Z0-9]{32}
SendGrid:     SG.[a-zA-Z0-9._-]{66}
JWT secret:   if longer than 32 chars and hardcoded → flag
```

---

## Git History Scanning

### Check If Secrets Were Ever Committed
```bash
# Search entire git history for secret patterns
git log --all --full-history -p -- "*.env" "*.py" "*.ts" "*.js" "*.yml" \
  | grep -E "^\+" | grep -iE "secret|password|api_key|token|private_key" \
  | grep -v "os\.getenv\|process\.env\|placeholder\|example\|changeme"

# Search for specific high-value patterns in history
git log --all -S "AKIA" --oneline
git log --all -S "sk-" --oneline
git log --all -S "password" --oneline --diff-filter=A  # added lines only

# Check if .env was ever committed
git log --all --full-history -- ".env"
git log --all --full-history -- "*.env"
```

**If a secret appears in git history — it is COMPROMISED, even if deleted in later commit.**
The correct action: rotate the secret immediately, then clean history (see incident response).

---

## Environment Variable Security

### .gitignore Coverage Check
```bash
# Verify sensitive files are gitignored
cat .gitignore | grep -E "\.env|\.secret|\.key|credentials"

# Check for any .env files already tracked
git ls-files | grep -E "\.env$|\.env\."

# .env files that SHOULD be in .gitignore:
# .env, .env.local, .env.production, .env.staging, .env.*.local
```

### .env File Permissions
```bash
# .env should not be world-readable
ls -la .env* 2>/dev/null
# Should be -rw------- (600) or -rw-r----- (640)
# If -rw-r--r-- (644) → world-readable → flag
```

### Correct Pattern for Secrets in Code
```python
# VULNERABLE
DATABASE_URL = "postgresql://admin:password123@db:5432/mydb"
OPENAI_API_KEY = "sk-abc123..."

# SAFE
import os
DATABASE_URL = os.environ["DATABASE_URL"]  # KeyError if missing = fail fast
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")  # None if missing
```

```typescript
// SAFE
const apiKey = process.env.OPENAI_API_KEY;
if (!apiKey) throw new Error("OPENAI_API_KEY not set");
```

---

## Frontend Secret Exposure

### What Should NEVER Be in Frontend Code
```
- API secret keys (even if "backend" service)
- Database connection strings
- Server-side tokens or signing keys
- Admin credentials
- Private keys (RSA, EC)
```

### What CAN Be in Frontend Code (public)
```
- Public Stripe key (pk_live_xxx) — designed to be public
- Google Analytics ID
- Public API keys labeled as "publishable" by the service
- Firebase public config object
```

### Detection
```bash
# Check frontend bundles and source for server-side secrets
grep -rn "sk-\|AKIA\|private_key\|database_url" \
  --include="*.tsx" --include="*.ts" --include="*.js" \
  src/ app/ pages/ components/ | grep -v node_modules

# Check .env files in frontend projects
ls .env* frontend/.env* 2>/dev/null
# Frontend .env should only have NEXT_PUBLIC_* or VITE_* vars for truly public values
```

---

## Docker & Container Secrets

### Common Mistakes
```yaml
# VULNERABLE docker-compose.yml
services:
  db:
    image: postgres
    environment:
      POSTGRES_PASSWORD: supersecret123  # hardcoded!

  app:
    build: .
    environment:
      SECRET_KEY: my-super-secret-key  # hardcoded!
```

```yaml
# SAFE — use env_file or secrets
services:
  db:
    image: postgres
    env_file: .env  # .env is in .gitignore
  app:
    build: .
    env_file: .env
```

```bash
# Check for hardcoded secrets in docker files
grep -rn "PASSWORD\|SECRET\|API_KEY\|TOKEN" \
  --include="docker-compose*.yml" --include="Dockerfile*" \
  . | grep -v "=\${" | grep -v "=\$(" | grep -v "_FILE\|_ENV\|env_file"
```

### Build-time Secrets in Layers
```dockerfile
# VULNERABLE — secret in intermediate layer stays in image history
RUN pip install -r requirements.txt --extra-index-url https://token:${NPM_TOKEN}@registry.npmjs.org

# SAFE — use BuildKit secrets
# syntax=docker/dockerfile:1
RUN --mount=type=secret,id=npm_token \
    NPM_TOKEN=$(cat /run/secrets/npm_token) pip install ...
```

---

## Incident Response — Leaked Secret (9 Steps)

1. **Rotate immediately** — invalidate compromised secret at the provider
2. **Check exposure window** — `git log` to find when it was committed
3. **Check access logs** — was the secret used by anyone besides your app?
4. **Revoke all sessions** — if auth token leaked, invalidate all user sessions
5. **Remove from current code** — replace with `os.environ[...]`
6. **Remove from git history**:
   ```bash
   git filter-branch --force --index-filter \
     'git rm --cached --ignore-unmatch path/to/file' \
     --prune-empty --tag-name-filter cat -- --all
   git push --force --all
   ```
7. **Force-expire all forks/clones** — notify collaborators to re-clone
8. **Audit all actions** — review what was done with the leaked credentials
9. **Add to monitoring** — configure secret scanning in CI (GitHub Advanced Security, truffleHog, gitleaks)

---

## CI/CD Secret Scanning
```bash
# Install gitleaks for pre-commit scanning
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks

# Run manually
gitleaks detect --source . --verbose
```

---

## CWE References
- CWE-798: Use of Hard-coded Credentials
- CWE-312: Cleartext Storage of Sensitive Information
- CWE-200: Exposure of Sensitive Information
- CWE-522: Insufficiently Protected Credentials
