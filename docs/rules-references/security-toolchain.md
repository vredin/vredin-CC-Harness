# Security toolchain — deterministic scanners + runtime probes (wired into the LENS, not new commands)

> Extends the security LENS (`/global-audit` lens #2, `/review` static pre-pass, Rex). No new commands —
> per the owner's "don't grow the list", all of this runs inside the existing security lens.
>
> **Pattern (same as the impeccable slop detector):** deterministic scanner produces FACTS (SARIF/JSON,
> reproducible exit code) → the LLM lens triages false positives and explains impact. Scanners give
> certainty; the LLM gives judgment. Never re-litigate a scanner's confirmed finding with the LLM.
>
> Built 2026-07-19 from a 2-agent research pass (verified names/licenses/URLs). Threat-modeling layer
> (STRIDE/LINDDUN) is deferred to a later build — noted at the bottom.

---

## (a) Deterministic scanners — offline, SARIF, run in the static pre-pass

Each SKIPs cleanly if its binary is absent (like `bin/run_static.sh`). First run may need network to pull
rules/DB; after that, offline. Merge all SARIF → feed CRITICAL/HIGH to the LLM lens for triage.

| Tool | Catches | Run (JSON/SARIF) | Install | Notes |
|---|---|---|---|---|
| **Semgrep** | SAST: injection, authz sinks, insecure config (Py+TS+React); OWASP-2025 mapped | `semgrep scan --config p/default --config p/python --config p/react --config p/owasp-top-ten --sarif -o sem.sarif` | `pip install semgrep` / `uv tool install semgrep` | curated packs only (low FP); NOT community "audit" rules |
| **Trivy** ⚠️ | container + IaC misconfig, image/fs CVEs, compose/Dockerfile, secrets, SBOM | `trivy fs --scanners vuln,misconfig,secret -f sarif -o trivy.sarif .` · `trivy config -f sarif -o cfg.sarif .` | pinned binary — see caveat | **SHA-PIN, do NOT `@latest`** |
| **gitleaks** | hardcoded secrets (tree + history) | `gitleaks detect --source . --report-format sarif --report-path leaks.sarif` | single binary (MIT) | also usable as a pre-commit gate |
| **osv-scanner** | multi-ecosystem dependency CVEs + guided fix | `osv-scanner scan -r --format sarif .` | single binary (Google) | network for OSV DB unless offline DB configured |
| **hadolint** | Dockerfile best-practice + shell bugs Trivy misses | `hadolint Dockerfile -f sarif` | single binary | complements Trivy config |
| **pip-audit** / **npm audit** | ecosystem-native dep second opinion | `pip-audit -f json` · `npm audit --json` | already in stack | cheap cross-check |

**⚠️ Trivy caveat (mandatory):** Trivy's distribution channel was supply-chain-compromised in **March 2026**
(weaponised scanner across pipelines). Adopt **only a SHA-pinned known-good version**, vendor the binary,
never `trivy@latest`, and have **Rex BLUE verify its provenance before first use**. The tool is sound; the
channel was hit. If provenance can't be verified → skip Trivy, keep the others.

**FP burden:** low on curated Semgrep packs + the single-purpose binaries. The LLM lens filters the rest.

---

## CVE-on-component-update gate (the "check when deps change" trigger the owner asked for)

**Automatic, everywhere — not a manual step.** Fires whenever a dependency manifest changes:
`requirements*.txt`, `pyproject.toml`, `uv.lock`, `poetry.lock`, `package.json`, `package-lock.json`,
`pnpm-lock.yaml`, `yarn.lock`.

Three enforcement points (already-existing surfaces — no new command):
1. **`/review`** — STEP 2 static pre-pass: if the diff touches any manifest above → run `osv-scanner` +
   `pip-audit`/`npm audit`. **CRITICAL/HIGH CVE → the review BLOCKS** (same bar as a failing test).
2. **`/deploy`** — pre-flight: same scan before shipping; CRITICAL blocks the deploy.
3. **CI** — a `dependency-audit` job on manifest change (OSINT already runs `pip-audit` here — this
   generalises it to every project + osv-scanner for cross-ecosystem coverage).

If the scanner binary is absent → the gate prints "CVE gate SKIPPED (osv-scanner/pip-audit not installed)"
rather than passing silently — an unknown is not a pass (mirrors the DB-Protection "unknown ≠ ok" rule).

---

## (b) Runtime probes — separate step, needs the app running (`docker compose up` / ASGI in-process)

Closes what static analysis STRUCTURALLY cannot: a `200 OK` with someone else's data has no static
signature; a CSP-dead control renders fine in source. Gated on the app being up — opt-in, not per-commit.

### Schemathesis — property-fuzz the FastAPI OpenAPI spec (top fit; every finance/OSINT app is FastAPI)
Generates thousands of edge-case requests straight from `/openapi.json`. Catches 500s, injection edge
cases, spec violations, and (stateful phase) sequence bugs.
```bash
# live server:
schemathesis run http://127.0.0.1:8000/openapi.json --checks all --phases examples,coverage,fuzzing,stateful
# OR in-process (no live port — best for a harness), via pytest:
#   schema = schemathesis.openapi.from_asgi("/openapi.json", app)
#   @schema.parametrize()  def test_api(case): case.call_and_validate()
```
Auth: `--header "Authorization: Bearer <token>"`. Low FP (tests the real contract). Findings → `/fix`.

### Authz-matrix test — the ONLY way to catch IDOR / BOLA (no drop-in scanner exists)
Scanners are blind to broken object-level authz. Generate a pytest that drives the live app with **≥2
identities across ≥2 tenants** and asserts cross-account **deny** on every object-bearing endpoint
(read/create/update/delete/list/export). Directly targets the real Finance finding (an accountant paying
their own approved expense) and the whole IDOR class.
```python
# skeleton — one row per (endpoint, verb); assert user_B is denied user_A's object
import pytest
@pytest.mark.parametrize("method,path_tmpl", ENDPOINTS_WITH_OBJECT_IDS)
def test_cross_user_denied(client, token_A, token_B, obj_of_A, method, path_tmpl):
    r = client.request(method, path_tmpl.format(id=obj_of_A), headers={"Authorization": f"Bearer {token_B}"})
    assert r.status_code in (403, 404), f"BOLA: user B reached A's object via {method} {path_tmpl}"
```
The endpoint×role matrix is generated from the OpenAPI spec + the role list. This is a real test file the
`test-writer` agent produces; it lives in `tests/security/` and runs in CI once seeded.

### OWASP ZAP baseline (optional) — headers, live CSP, passive XSS/DOM
```bash
docker run --rm -t zaproxy/zap-stable zap-baseline.py -t <staging-url> -J zap.json
```
Closes the OSINT client-runtime findings (CSP-dead controls, DOM-XSS). Heavier (needs a deployed target) —
post-deploy `/canary`-style pass, not per-commit.

---

## Wiring map (where each runs — all inside existing surfaces)

| Surface | Runs |
|---|---|
| `/review` STEP 2 (static pre-pass) | Semgrep + gitleaks + hadolint + Trivy(config) on changed files; CVE gate if manifests changed |
| `/global-audit` lens #2 (security) | full deterministic set + (opt-in, app up) Schemathesis + authz-matrix |
| `/deploy` pre-flight | CVE gate + Trivy image scan + Rex RED |
| Rex RED / RECON→TAINT | consumes Semgrep SARIF as the deterministic taint backbone; borrows `claude-code-security-review` (MIT) prompts for business-logic/race/XSS semantic review |
| CI | `dependency-audit` (osv + pip/npm audit) on manifest change; Semgrep+Trivy SARIF → code scanning |

---

## Deferred — Layer 3 (methodology, next build)
STRIDE threat-model lens (borrow STRIDE-GPT MIT prompts) + LINDDUN privacy lens (home-grown — no vendorable
option) + business-logic-abuse / API-inventory checklist (borrow 42Crunch's OWASP-API-Top-10, offline).
Noted here so the plan is complete; not built in this pass.

## Sources / provenance
Vendorable & verified: Semgrep (MIT), Trivy (Apache-2.0, SHA-pin), gitleaks (MIT), osv-scanner (Apache-2.0),
hadolint (GPL — invoke as external binary, don't embed), Schemathesis (MIT). `claude-code-security-review`
(MIT, anthropics) — prompt source for Rex. Built-in `/security-review` (Anthropic) — cross-check only.
