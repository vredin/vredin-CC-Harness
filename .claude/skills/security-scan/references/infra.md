# Infrastructure Security — Reference

## Docker & Container Security

### Network Exposure
```yaml
# VULNERABLE — database exposed on ALL interfaces (including public)
services:
  db:
    image: postgres
    ports:
      - "5432:5432"   # 0.0.0.0:5432 — accessible from internet!

# VULNERABLE — explicit 0.0.0.0 binding
  redis:
    image: redis
    ports:
      - "0.0.0.0:6379:6379"

# SAFE — bind only to localhost or omit ports entirely
  db:
    image: postgres
    # No ports: → only accessible from Docker network
    # OR
    ports:
      - "127.0.0.1:5432:5432"  # localhost only

  app:
    # Only the app container needs to reach DB via Docker network
    depends_on:
      - db
```

### Default Credentials
```yaml
# VULNERABLE — hardcoded weak passwords
  db:
    environment:
      POSTGRES_PASSWORD: postgres  # default/weak
      POSTGRES_USER: postgres

# SAFE — use env_file (which is gitignored)
  db:
    env_file: .env.production
```

### Debug Mode in Production
```yaml
# VULNERABLE — debug mode exposes interactive debugger
  app:
    environment:
      DEBUG: "true"          # Flask/Django debug mode
      FLASK_DEBUG: 1         # shows stack traces, enables debugger
      NODE_ENV: development  # enables verbose errors

# SAFE
  app:
    environment:
      DEBUG: "false"
      NODE_ENV: production
```

### Container Runs as Root
```dockerfile
# VULNERABLE — default is root
FROM python:3.11-slim
COPY . /app
CMD ["python", "-m", "uvicorn", "main:app"]

# SAFE — create non-root user
FROM python:3.11-slim
RUN adduser --disabled-password --gecos '' appuser
COPY . /app
RUN chown -R appuser:appuser /app
USER appuser
CMD ["python", "-m", "uvicorn", "main:app"]
```

### Detection
```bash
# Exposed services
grep -rn "ports:" --include="*.yml" --include="*.yaml" . | grep -v node_modules
grep -A2 "ports:" docker-compose*.yml 2>/dev/null | grep -v "127\.0\.0\.1"

# Debug mode
grep -rn "DEBUG.*true\|DEBUG.*1\|FLASK_DEBUG\|NODE_ENV.*development" \
  --include="*.yml" --include="*.yaml" --include="*.env" . | grep -v ".example"

# Default/weak passwords
grep -rn "POSTGRES_PASSWORD\|MYSQL_ROOT_PASSWORD\|MONGO_INITDB" \
  --include="*.yml" --include="*.yaml" . | grep -v "=\${" | grep -v "env_file"
```

---

## CORS Configuration

### Vulnerable Configurations
```python
# VULNERABLE — wildcard allows any origin
from fastapi.middleware.cors import CORSMiddleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],       # any website can make requests
    allow_credentials=True,    # with cookies!
    # This combination is CRITICAL — allows any site to make auth'd requests
)

# VULNERABLE — reflecting Origin header
allow_origins = [request.headers.get("origin")]  # reflects whatever attacker sends

# SAFE — explicit whitelist
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://myapp.com",
        "https://www.myapp.com",
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["Authorization", "Content-Type"],
)
```

### The Dangerous Combination
`allow_origins=["*"]` + `allow_credentials=True` = browsers reject this, but:
- Some apps use custom CORS that allows this
- Impact: any website can make authenticated API calls using victim's cookies

### Detection
```bash
grep -rn "allow_origins\|CORS\|Access-Control-Allow-Origin" \
  --include="*.py" --include="*.ts" --include="*.js" --include="*.conf" \
  . | grep -v node_modules | grep -v test
# → Flag if value is "*" or dynamic/reflected
```

---

## Security Headers

### Complete Headers Checklist
```python
# FastAPI middleware to add security headers
from starlette.middleware.base import BaseHTTPMiddleware

class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request, call_next):
        response = await call_next(request)
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
        response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
        response.headers["Permissions-Policy"] = "camera=(), microphone=(), geolocation=()"
        response.headers["Content-Security-Policy"] = "default-src 'self'"
        return response
```

### Detection
```bash
grep -rn "X-Frame-Options\|X-Content-Type-Options\|Strict-Transport\|Referrer-Policy\|Permissions-Policy\|Content-Security-Policy" \
  --include="*.py" --include="*.ts" --include="*.conf" . | grep -v node_modules | grep -v test
# If none found → ALL security headers missing → HIGH finding
```

---

## Dependency Vulnerabilities

### Scanning Commands
```bash
# Python
pip-audit                          # checks PyPI advisory database
uv run pip-audit                   # if using uv
safety check                       # alternative

# Node.js
npm audit                          # built-in
npm audit --audit-level=high       # only high+ severity

# Go
govulncheck ./...

# Check for outdated packages with known CVEs
pip list --outdated
npm outdated
```

### CI Integration
```yaml
# .github/workflows/security.yml
- name: Security audit
  run: |
    pip-audit --fail-on-vuln
    # OR
    npm audit --audit-level=moderate
```

### What Counts as a Finding
- CRITICAL CVE in direct dependency → block deploy
- HIGH CVE in direct dependency → fix within sprint
- CRITICAL/HIGH in transitive dependency → investigate, assess impact

---

## Logging & Monitoring

### What Must Be Logged
```python
# Authentication events
logger.info("LOGIN_SUCCESS", extra={"user_id": user.id, "ip": request.client.host})
logger.warning("LOGIN_FAILED", extra={"email": email, "ip": request.client.host})
logger.warning("LOGIN_LOCKED", extra={"email": email, "attempts": count})

# Authorization events
logger.warning("AUTHZ_DENIED", extra={"user_id": user.id, "resource": resource_id, "action": action})

# Sensitive operations
logger.info("PASSWORD_CHANGED", extra={"user_id": user.id})
logger.info("ROLE_CHANGED", extra={"user_id": user.id, "old_role": old, "new_role": new})
logger.info("MFA_DISABLED", extra={"user_id": user.id})
```

### What Must NEVER Be Logged
```python
# NEVER log secrets, PII in production logs
logger.info(f"Login attempt: {email} / {password}")    # logs password!
logger.debug(f"API key: {api_key}")                    # logs secret!
logger.info(f"User data: {user.__dict__}")             # may log PII
```

### Detection
```bash
# Find potential sensitive data in log calls
grep -rn "logger\.\|logging\.\|console\." --include="*.py" --include="*.ts" \
  . | grep -iE "password|secret|token|api_key|credit_card|ssn" \
  | grep -v test | grep -v node_modules
```

---

## CWE References
- CWE-732: Incorrect Permission Assignment (container as root, world-readable .env)
- CWE-16: Configuration (debug mode, CORS, missing headers)
- CWE-1104: Use of Unmaintained Third Party Components
- CWE-778: Insufficient Logging
- CWE-532: Insertion of Sensitive Information into Log File
