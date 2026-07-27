# False Positive Rules

## Drop Finding Immediately If Any Rule Matches

### Secrets / Keys
- Pattern matches `SECRET|KEY|PASSWORD` but is in `*.example`, `*.template`, `*.sample` file
- Value is a placeholder: `your-secret-here`, `changeme`, `<YOUR_KEY>`, `xxx`, `TODO`
- Variable name contains secret keyword but value is read from env: `os.getenv(`, `process.env.`
- In `.env.example` — these are intentionally public placeholders
- In `*.test.*`, `*.spec.*`, `*_test.go` — test fixtures are not production secrets
- In `docs/` — documentation examples

### SQL / Injection
- SQL string in ORM model definition (column names, table names) — not user input
- SQL in migration files — parameterized by framework
- SQL in `*.sql` fixture/seed files — controlled data, not user input
- `execute()` call where argument is a string literal (no variable interpolation)
- `text()` in SQLAlchemy where `.bindparams()` is used immediately after

### XSS
- `dangerouslySetInnerHTML` in component receiving ONLY developer-controlled content (hardcoded strings, i18n keys)
- `innerHTML` setting in test files
- Template strings in `*.stories.*` (Storybook)
- `v-html` with content sourced from i18n translation files (not user input)

### Cryptography
- MD5/SHA1 used for: file checksums, cache keys, non-security hashing, content-addressable storage
- MD5/SHA1 in `requirements.txt` / `package-lock.json` hash verification — this is correct use
- Weak random only for: UUID generation using uuid4(), non-security nonces, color generation

### Path Traversal
- `Path(` / `os.path.join(` where input comes only from `settings.*`, `config.*`, or constants
- File paths in migration scripts — controlled by developers
- `__file__` based paths — developer-controlled

### CORS / Headers
- `allow_origins=["*"]` in files named `*.test.*`, `*local*`, `*dev*`
- CORS wildcard where project is a public read-only API (documented intent)

### Shell Commands
- `subprocess` calls where ALL arguments are hardcoded strings or come from config
- `os.system()` in scripts run only by CI/CD with controlled input
- Shell commands in Makefile, docker-entrypoint.sh with no user input path

### Authentication
- Route without auth check that returns only public data (health checks, static assets, public APIs)
- `@app.get("/health")` — always public by design
- Login/register endpoints — intentionally unauthenticated
- Webhook receivers — check for HMAC signature instead of session auth

### Serialization
- `pickle.loads()` where data source is local filesystem written by same process
- `yaml.load()` where file is from a controlled path (config directory, not user upload)

### Rate Limiting
- Endpoint missing rate limit but requires authentication (auth itself limits surface)
- Admin-only endpoints — not exposed to public attackers

### Docker / Infrastructure
- `0.0.0.0` in `docker-compose.override.yml` or `docker-compose.dev.yml` — dev only
- Debug ports in `*dev*`, `*local*`, `*development*` compose files
- Default DB passwords in `*test*` compose files — test environment

---

## Judge Questions (run for every non-obvious finding)

1. Is the data source actually attacker-controlled in this context?
2. Does the code path from source to sink actually execute at runtime?
3. Is there sanitization/validation/parameterization I missed?
4. If I wrote a PoC right now, would it actually work?

If any answer weakens the case → downgrade or drop the finding.
