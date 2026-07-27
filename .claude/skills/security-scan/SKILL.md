---
name: security-scan
description: Source-to-sink taint analysis with adversarial mindset for finding real, exploitable vulnerabilities — not theoretical ones. Use before production deploys, when editing auth/session/payment/permission/upload/middleware code, on-demand security audits, or CI/CD pre-merge checks. Pairs with Rex agent for Red/Blue team execution.
---

# Security Scan Skill

## Purpose

Source-to-sink taint analysis with adversarial mindset. Finds real, exploitable vulnerabilities — not theoretical ones.

## When to Load

- Before any production deploy
- When editing: auth*, session*, payment*, permission*, upload*, middleware*
- On-demand security audit
- CI/CD pre-merge check

## Activation

```
Load skill: security-scan
Then: invoke Rex agent
```

## Quick Scan (< 5 min)

For rapid pre-commit check — focus only on changed files:

```bash
# Get changed files
git diff --name-only HEAD~1

# Run targeted checks on changed files only
# See Rex.md STEP 1 for full commands
```

Load only relevant reference files based on what changed:
- auth/session files → `references/auth.md`
- DB queries → `references/injection.md`
- file handling → `references/file-security.md`
- API endpoints → `references/api-security.md`
- config/env → `references/secrets.md`

## Full Scan (comprehensive)

Run Rex agent full pipeline:
1. RECON → 2. TAINT → 3. JUDGE → 4. EXPLOIT → 5. REPORT

Load ALL reference files before starting.

## False Positive Protocol

Before reporting any finding — check `false-positives.md`.
Finding matches a rule → DROP it silently.

## Severity → Action Mapping

| Severity | Action |
|----------|--------|
| CRITICAL | Block deploy immediately. Fix before anything else. |
| HIGH | Fix before next sprint release. |
| MEDIUM | Add to backlog, fix within 2 weeks. |
| INFO | Document, fix when refactoring that area. |

## Reference Files

| File | Covers |
|------|--------|
| `references/injection.md` | SQL, NoSQL, RCE, SSTI, XXE, GraphQL |
| `references/auth.md` | AuthN, AuthZ, JWT, 2FA, session |
| `references/access-control.md` | IDOR, BFLA, privilege escalation |
| `references/secrets.md` | Keys, tokens, git history, env |
| `references/xss-csrf.md` | XSS (reflected/stored/DOM), CSRF |
| `references/file-security.md` | Upload bypass, path traversal, zip slip |
| `references/api-security.md` | Rate limiting, enumeration, SSRF, mass assignment |
| `references/crypto.md` | Weak algo, timing attacks, key management |
| `references/infra.md` | Docker, CORS, headers, dependencies |
| `references/business-logic.md` | Race conditions, price manipulation, logic flaws |
| `references/owasp-2025.md` | OWASP Top 10:2025, supply chain security (A03), auth/API/data checklists |
| `false-positives.md` | Rules for eliminating noise |
