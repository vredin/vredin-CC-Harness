# Rex Checklists — Red Team + Blue Team

> Moved out of `.claude/agents/rex.md` 2026-07-03 (agent-prompt slimming). Rex loads
> this during the JUDGE/REPORT phases as the enumeration corpus. Nothing here was
> deleted — the two checklists live here verbatim so the agent prompt stays lean.

---

## Red Team Checklist

### Injection
- [ ] SQL injection in search, filter, sort params
- [ ] NoSQL injection (`$where`, `$regex`, operator injection)
- [ ] SSTI in template engines (Jinja2, Handlebars, Twig)
- [ ] Command injection in any shell execution
- [ ] LDAP/XPath injection in directory queries
- [ ] GraphQL injection (introspection, batching abuse, depth attacks)
- [ ] XXE in XML parsers

### Authentication & Session
- [ ] Brute force: no rate limit on login endpoint
- [ ] 2FA bypass: can you skip MFA step?
- [ ] Password reset: predictable tokens, no expiry, user enumeration
- [ ] JWT: algorithm confusion (RS256→HS256), `alg: none`, weak secret
- [ ] Session fixation, session not invalidated on logout
- [ ] Remember-me token: predictable, never expires, reusable after logout

### Authorization
- [ ] IDOR: change resource ID in request, access other user's data
- [ ] BFLA: call admin-only functions as regular user
- [ ] Mass assignment: send extra fields in POST/PUT body
- [ ] Path traversal to access files outside allowed directory
- [ ] Privilege escalation: modify `role` field in profile update

### Injection (XSS/CSRF)
- [ ] Reflected XSS in error messages, search results, URL params
- [ ] Stored XSS in user-generated content rendered without escaping
- [ ] DOM-based XSS in `innerHTML`, `document.write`, `eval`
- [ ] CSRF on state-changing POST/PUT/DELETE without token

### File Security
- [ ] Upload bypass: change extension, MIME type, magic bytes
- [ ] Path traversal in filename: `../../etc/passwd`
- [ ] Stored files accessible without auth
- [ ] Archive extraction: zip slip, tarball path traversal
- [ ] SVG upload → XSS via embedded script

### API & Business Logic
- [ ] Rate limiting: can you enumerate users, reset passwords at scale?
- [ ] Object enumeration: sequential IDs, predictable slugs
- [ ] Price/balance manipulation: negative quantities, integer overflow
- [ ] Race condition: double-spend, double-click exploit
- [ ] SSRF: user-controlled URL in `fetch`/`requests.get`
- [ ] Webhook abuse: attacker-controlled callback URL

### Infrastructure
- [ ] Secrets in environment variables, git history, container layers
- [ ] Debug mode enabled in production
- [ ] CORS: `allow_origins=["*"]` or reflecting Origin header blindly
- [ ] Security headers missing: CSP, HSTS, X-Frame-Options
- [ ] Database accessible from public network
- [ ] Default credentials in services (Redis, Postgres, Mongo)

### Supply Chain
- [ ] Dependency confusion: internal package names shadowed in public registry (npm/pypi)
- [ ] Typosquatting: `reqeusts`, `djago`, `lodahs`, `colorama-fix` in dependencies
- [ ] Pinned hashes vs floating versions (`pip install`/`npm install` should use lock files)
- [ ] GitHub Actions: third-party actions pinned to `@<sha>`, NOT `@main` or `@v1`
- [ ] Dockerfile: `COPY .env*` or `COPY . .` without proper `.dockerignore` → secrets baked into image
- [ ] `npm audit` / `pip-audit` / `uv run safety check` clean of CRITICAL CVEs
- [ ] No abandoned/unmaintained packages in deps (last release > 2 years, no maintainer activity)

---

## Blue Team Checklist

### Auth & Access
- [ ] Authentication middleware applied to ALL protected routes
- [ ] Authorization check verifies OWNERSHIP (not just auth)
- [ ] JWT: proper algorithm (RS256/ES256, never `none`/HS256-with-shared-secret), expiry enforced, signing key rotatable

### Injection & Input
- [ ] Parameterized queries used everywhere (no raw SQL with user input)
- [ ] File uploads: MIME + magic bytes validated, stored outside webroot

### Cryptography
- [ ] Passwords hashed with **bcrypt / argon2 / scrypt** — NOT md5/sha1/sha256/plain
- [ ] Sensitive DB fields encrypted at rest (column-level encryption, not just full-disk)
- [ ] TLS 1.2+ enforced on inbound HTTPS; TLS 1.0/1.1 disabled at load balancer / Traefik
- [ ] Private keys NOT in repo, NOT in container layers, NOT in logs
- [ ] Random token/ID generation uses `secrets` module (Python) / `crypto.randomBytes` (Node) — never `random`/`Math.random`
- [ ] Session cookies: `Secure`, `HttpOnly`, `SameSite=Strict` or `Lax`

### Rate limiting & abuse
- [ ] Rate limiting on: login, register, password-reset, upload, OTP

### Network & headers
- [ ] CORS locked to specific origins in production
- [ ] Security headers present: CSP, HSTS, X-Frame-Options, X-Content-Type-Options, Referrer-Policy
- [ ] Docker: no `0.0.0.0` DB exposure, no debug ports in production

### Secrets discipline
- [ ] Secrets in `.env` only, `.gitignore` covers all secret files
- [ ] `git log --all -S "SECRET\|KEY\|PASSWORD\|TOKEN"` — no secrets in history (also check for `gitleaks`/`trufflehog` clean)
- [ ] No secrets in container image layers (`docker history` review)

### Supply chain
- [ ] Dependencies: `npm audit` / `pip-audit` / `uv run safety check` — no CRITICAL CVEs
- [ ] Lockfile committed and respected in CI

### Observability
- [ ] Error messages: no stack traces / internal paths to end users
- [ ] Logging: auth events, failed attempts, privilege changes logged
- [ ] Logs do NOT contain PII, tokens, or password values
