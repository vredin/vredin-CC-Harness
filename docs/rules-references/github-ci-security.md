# GitHub / CI security sub-lens — repo + Actions hygiene (borrowed from Prowler's GitHub provider)

> Prowler itself is a CLOUD scanner (AWS/Azure/GCP) — not for a VPS/Docker/Postgres stack, so we do NOT
> vendor it. But its **GitHub provider** (24 repo/Actions checks) maps a real surface this stack HAS:
> GitHub repos, Actions, secrets, cross-repo mirrors. This sub-lens borrows that checklist, implemented
> proportionally — a static pass over workflow files + an opt-in live pass via `gh`. No Prowler dependency.
>
> Runs inside the **security lens** (`/global-audit` #2) and `/review` STEP 2 when `.github/` is in scope.
> Same pattern as the rest: deterministic facts → LLM triages/explains → FMEA-scored → route to fix.

---

## (a) Static checks — offline, parse `.github/workflows/*.yml` (no network, no auth)

Run whenever the repo has workflows / a `.github/` change is in the diff. Deterministic:

| Check | Flag when | Fix |
|---|---|---|
| **Action SHA-pinning** | `uses: owner/action@v4` / `@main` (a tag/branch, not a 40-char SHA) | pin to a full commit SHA (a tag can be moved by an attacker) |
| **Least-privilege token** | no top-level `permissions:` block, or `permissions: write-all` | add explicit minimal `permissions:` (default read, grant per-job) |
| **`pull_request_target` + untrusted checkout** | a `pull_request_target` workflow that checks out `github.event.pull_request.head` and runs its code/scripts | never run untrusted PR code with the elevated token — the classic fork-PR RCE / secret-exfil vector |
| **Plaintext secrets in workflow** | a literal token/key/password in the yml (not `${{ secrets.* }}`) | move to `secrets.*`; rotate the leaked value |
| **Secret echoed to logs** | `echo`/`run` that prints a `${{ secrets.* }}` or `env` secret | remove; GitHub masks known secrets but derived values leak |
| **Cross-repo / mirror push has credentials** | a step that `git push`es to ANOTHER repo (mirror) without a PAT/deploy-key in the URL or env | supply a scoped token — **this is the live OSINT failure** (`could not read Username`, the Mirror workflow red on every push) |
| **Self-hosted runner on public repo** | `runs-on: self-hosted` on a public repository | untrusted PRs can run on your infra — restrict to private / trusted |

Emit findings with `file:line`; feed CRITICAL/HIGH to the LLM lens (do not re-litigate the deterministic hits).

---

## (b) Live checks — opt-in, via `gh` CLI (needs network + `gh auth`; read-only settings queries)

The settings that are NOT in the repo files. Skip with a printed "SKIPPED — no gh auth" if unavailable
(unknown ≠ pass). `OWNER/REPO` from `gh repo view --json nameWithOwner`.

| Check | Query | Flag when |
|---|---|---|
| **Branch protection on default branch** | `gh api repos/OWNER/REPO/branches/main/protection` | 404 / no required review / force-push allowed |
| **Secret scanning + push protection** | `gh api repos/OWNER/REPO --jq '.security_and_analysis'` | `secret_scanning` / `secret_scanning_push_protection` not `enabled` |
| **Dependabot / vuln alerts** | `gh api repos/OWNER/REPO/vulnerability-alerts` (204=on) | not enabled |
| **Org 2FA required** | `gh api orgs/ORG --jq '.two_factor_requirement_enabled'` | false (if org-owned) |
| **Actions default token perms** | `gh api repos/OWNER/REPO/actions/permissions/workflow --jq '.default_workflow_permissions'` | `write` (should be `read`) |
| **Deploy keys / PAT scope for mirrors** | `gh api repos/OWNER/REPO/keys` + review the mirror target's access | mirror token has broader scope than push-to-one-repo |

Read-only — never changes settings. Findings → the owner (settings changes are owner actions) or a `[SEC]`
follow-up.

---

## Scoring & routing
FMEA per finding (`fmea-scoring.md`) — e.g. an unpinned action that runs with `write-all` on a public repo
is S4·O2·D4; a mirror push with no token is O5 (every push) but low S (mirror only) — the RED-CI annoyance,
not a breach. Route: workflow-file fixes → `/fix` / `[SEC]` commit; GitHub settings → owner action.

## Wiring
- `/global-audit` security lens (#2): runs static (a) always + live (b) when `gh` is available.
- `/review` STEP 2: static (a) when the diff touches `.github/`.
- Explains real CI failures at a glance (OSINT: Mirror token missing, harness-ci gates) — see the CI
  triage in the security lens output.

## Honest scope
GitHub repo + Actions hygiene ONLY. NOT cloud posture (that's Prowler's job — adopt it only if/when the
stack moves to AWS/Azure/GCP; then its GDPR/SOC2/CIS mappings become directly useful too).
