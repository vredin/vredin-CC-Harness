# Confidence Rubric — review finding scoring

> Used by `/review` (confidence scoring mode) and `/da review`. Scoring done by the **orchestrator** agent, NOT by the agent that produced the finding (avoids self-confidence bias — every author rates their own bug 95+).

## Why a rubric

Parallel review by `code-reviewer` + `qa-expert` + `Rex` + `Diablo` produces tens of findings per PR. Without scoring, every finding lands with equal weight. Result: real bugs drown in noise; humans triage anyway. Confidence scoring puts the high-value findings on top and lets the noise be hidden.

## Scoring tiers

| Tier | Score | Meaning | Examples |
|------|-------|---------|----------|
| **CRITICAL** | 90–100 | Reproducible exploit OR data loss OR correctness bug. Code reference required. Production impact certain. | SQL injection at `auth.py:42`. IDOR at `/api/users/{id}` GET. Race condition in payment.commit() — concurrent calls double-charge. Migration drops column without backup. |
| **HIGH** | 80–89 | Specific code path that **will** misbehave under realistic input. Reproduction described but not run. No exploit, but bug is unambiguous. | Off-by-one in `pagination.py:88` causes last item drop on N=offset edge. Token refresh races on concurrent requests — likely 401 storm under load. |
| **MEDIUM** | 60–79 | Symptom observed (test fail, anomaly, suspicious pattern) without confirmed root cause. Investigation needed. | "Tests flaky in CI" — no isolation done. "Logs grow unbounded" — no measurement. Unclear race condition window. |
| **LOW** | 40–59 | Code smell, style issue, hypothetical risk without concrete trigger. Improvement, not bug. | Long function. Variable named `data2`. Could maybe N+1 if collection grows. Magic number. |
| **NOISE** | <40 | Subjective preference, false positive, already-known-and-accepted trade-off. | "Why not Redux?" "Prefer underscore over camelCase here." "This `any` is okay actually." |

## Default filter for /review

```
threshold: 80
action: only CRITICAL and HIGH appear in the final report.
```

Override with `/review --threshold 60` to see MEDIUM and above (deep dive).

## Scoring procedure (orchestrator's algorithm)

For each finding from a sub-agent:

1. **Code reference present?** No → max 79 (can't verify).
2. **Reproduction provided?** (test, exploit payload, log excerpt, concurrent timing). No → max 89.
3. **Data loss or exploit?** Yes → 90+.
4. **Specific code path with input that triggers misbehavior?** Yes → 80–89.
5. **Symptom only, root cause not pinned?** → 60–79.
6. **Style/smell/hypothetical?** → 40–59.
7. **Reviewer disagreement?** If 2 of 4 reviewers raised similar finding → +5. If only one raised it → no boost.

## Evidence-bearing fields (mandatory for every finding kept in the report)

Score alone is not enough. Each kept finding MUST carry the following fields. They make uncertainty visible and prevent premature fixes.

| Field | Purpose | Example |
|---|---|---|
| `evidence_type` | What kind of evidence backs the finding | `confirmed_from_code` / `confirmed_from_telemetry` / `provider_doc_hypothesis` / `needs_validation` |
| `impact_condition` | ONE-LINE: when this actually matters. NOT "guaranteed savings". | "matters whenever an unauthenticated user POSTs /login" / "matters IF this route is hot and prefix is byte-stable" |
| `do_not_do_yet` | ONE-LINE: the premature action to avoid. Stops «just fix it» reflex when wrong fix is worse than the bug. | "do not patch with sanitization — switch to parameterized query" / "do not optimize until telemetry confirms hot path" |

These three fields are the **counterweight to confidence inflation**. A finding can be 95% confident in the *class* of bug yet still need conditional language for the *specific impact* in *this* project.

## Applicability classification (3-bucket model)

Orthogonal to severity. Every finding gets ONE of:

| Bucket | Meaning | Routes to |
|---|---|---|
| `confirmed` | Evidence from code/config/telemetry directly in scope; bug WILL trigger under normal usage | CONFIRMED section in report, feeds Diablo calibration |
| `hypothesis` | Plausible risk but needs more data (telemetry, payload sample, prod log); OR matches anti-pattern but project context is unclear | HYPOTHESES section with `needs_evidence` field |
| `not_applicable` | Generic anti-pattern ruled out by project context (e.g. SQL injection in script with no user input; cache optimization for once-a-day cron) | NOT APPLICABLE section, severity demoted regardless of original score |

Applicability is assessed AFTER scoring, BEFORE the report. It does NOT change the raw score — it changes which bucket the finding lands in.

**Rule of thumb:** if removing the finding from a future report would NOT cause real-world harm because the precondition never holds in this codebase, it is `not_applicable`. Mark it, but do not silently drop it — explicit «would matter if X, but X is not true here» is more useful than silence.

## Exclusion Rules (ложные срабатывания по умолчанию)

> Adapted from Anthropic's defending-code reference harness (triage skill, EXCLUSION RULES). A finding matching any rule is a FALSE POSITIVE by default — **even if technically accurate** — unless the verifier explicitly shows why the rule does not apply here. Blind verifiers in `/review` STEP 6 must cite the ER-N they matched.

| # | Rule |
|---|---|
| ER-1 | Volumetric DoS / missing rate-limiting — handled at infrastructure layer. ReDoS, algorithmic complexity, unbounded recursion remain VALID findings. |
| ER-2 | Test-only code, dead code, example/fixture code, or a crash with no security impact. |
| ER-3 | Behavior that is the intended design (e.g. compression middleware; a backward-compatible weak algorithm offered alongside a strong one). |
| ER-4 | Memory-safety concerns in memory-safe languages outside `unsafe` / FFI blocks. |
| ER-5 | SSRF where the attacker controls only the path, not host or protocol. |
| ER-6 | User input flowing into an AI/LLM prompt — prompt injection is not a code vulnerability in the target under review. |
| ER-7 | Path traversal in object storage (S3/GCS/MinIO) where `../` does not escape a trust boundary. |
| ER-8 | Trusted inputs used as the attack vector (env vars, CLI flags set by the operator) — unless the project explicitly marks them untrusted. |
| ER-9 | Client-side code flagged for a server-side vulnerability class. |
| ER-10 | Outdated dependency versions — managed by a separate process (dep-audit routing), not a review finding. |
| ER-11 | Weak random used for non-security purposes (jitter, shuffling, dev-only fallbacks). |
| ER-12 | Low-impact nuisance issues: log spoofing, CSRF on logout, self-XSS, tabnabbing, open redirect, regex injection. |
| ER-13 | Missing hardening / best-practice gap with no concrete exploit path (missing security headers, no audit logging, permissive config never reached by untrusted input). |
| ER-14 | XSS in a framework with default auto-escaping (React, Vue, Angular, Jinja2 autoescape=on) — unless the sink is a raw-HTML escape hatch (`dangerouslySetInnerHTML`, `v-html`, `\|safe`, `bypassSecurityTrustHtml`). |
| ER-15 | Identifiers unguessable by construction (UUIDv4, 128-bit+ random tokens) flagged as "predictable" or "needs validation". |
| ER-16 | Race conditions / TOCTOU that are theoretical only — no realistic window, or no security-relevant state change between check and use. |

Org-specific precedents ("we accept X, it's mitigated by Y") may be appended per-project below this table — same force as ER-1..16.

## Anti-rules (orchestrator must reject)

- **Inflation by author**: agent says "confidence 95" → ignore, re-score per rubric.
- **Severity ≠ confidence**: a CRITICAL bug class (SQL injection) with no actual finding gets LOW confidence. Confidence is "did the reviewer prove it", not "how bad if real".
- **Domain tag required for ≥80**: every CRITICAL/HIGH carries `[SECURITY]|[DATA_LOSS]|[CORRECTNESS]|[SCALABILITY]|[PRIVACY]|[OPERABILITY]` (matches Diablo's domain tags).
- **No score** = drop. Finding without score never reaches user.
- **Missing evidence-bearing fields** = treat as `hypothesis` / `needs_validation` regardless of score.
- **Applicability ≠ score**: a 95-score finding that doesn't apply to this project is still `not_applicable`. Do not let score override context.
- **Exclusion Rule wins by default**: a finding matching any ER-N (see § Exclusion Rules) goes to NOT APPLICABLE, unless the verifier explicitly showed why the rule does not apply in this case.

## Output format (3-bucket structure)

After scoring + applicability classification, orchestrator emits findings split into three top-level buckets, with severity nested inside each:

```
## Review Report — <PR/scope>  (threshold: 80)

## CONFIRMED (evidence in code/config/telemetry)

### CRITICAL (score 90+)
1. [SECURITY] SQL injection at auth.py:42  (score: 95, agreed: code-reviewer + Rex)
   evidence_type: confirmed_from_code
   impact_condition: matters whenever unauthenticated user POSTs /login
   do_not_do_yet: do not patch with sanitization — switch to parameterized query
   reproduction: POST /login with name=admin' OR '1'='1 → returns first user row

### HIGH (score 80-89)
1. [CORRECTNESS] Off-by-one at pagination.py:88  (score: 82, agreed: code-reviewer)
   evidence_type: confirmed_from_code
   impact_condition: matters when N == page_size on last page
   do_not_do_yet: do not change algorithm — add reproducing test first

## HYPOTHESES (plausible, needs evidence to promote)

### Open hypotheses
1. [SCALABILITY] Possible N+1 in /api/users  (score: 72, agreed: performance-analyzer)
   evidence_type: needs_validation
   impact_condition: matters IF collection grows > 100 items
   needs_evidence: production query log OR ORM lazy-load trace
   do_not_do_yet: do not refactor — add EXPLAIN ANALYZE first

## NOT APPLICABLE (ruled out by project context)

1. [SECURITY] CSRF token absent at /api/legacy  (score: 88 → demoted)
   impact_condition: would matter if endpoint accepted browser session
   ruled_out_by: route is internal service-to-service, no cookies, mTLS only (see docs/RUNBOOK.md)

## Lower-tier filtered findings (within CONFIRMED)
- MEDIUM (60-79): <count>
- LOW (40-59): <count>
- NOISE (<40): <count>
Recover via: /review --threshold 60
```

Severity tiers and threshold filtering work as before, but **applicability bucket comes first**. A score-95 finding that doesn't apply lands in NOT APPLICABLE — not CONFIRMED-CRITICAL. This is the design: «severe-if-real» findings that aren't real get visibility without false alarm.

## Calibration notes

This rubric is calibrated against the project's Diablo agent verdict tiers:
- CRITICAL → BLOCKED
- HIGH → FIX FIRST
- MEDIUM → PROCEED WITH CAUTION (document)
- LOW → ACCEPTABLE (optional cleanup)

A finding that produces a Diablo `BLOCKED` verdict MUST score ≥90. Mismatch = re-score.

---

_Authored 2026-05-19 as part of v3.1 plugin integration (T10). Tied to /review refactor in T12._
