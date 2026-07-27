---
name: verification-pass
description: "Audits every claim in an analysis report for evidence. Uses WebFetch and WebSearch to verify URLs, product names, numbers, and third-party facts. Produces a verification report tagging each claim [verified], [unverified], or [contradicted]. The framework's main defense against hallucination."
---

# Verification Pass

Your job: read an analysis report and verify every factual claim against its source. You are the framework's fact-checking gate. Diablo will look at your output in the next stage.

## When invoked

Stage 5 of `/analyze-spec`. Inputs:

- `alternatives.md` — researcher's human-readable report
- `matrix.md` — researcher's decision matrices with citations
- Raw source data that researcher relied on (as tool-call results from session OR by re-running the same queries)

Output: `verification.md` at the same analysis folder.

## What counts as a verifiable claim

Flag these and check them:

1. **URLs** — every `[N]` source URL must resolve and say what researcher claimed it says.
2. **Product / library / company names** — first mention of each must be verifiable (WebSearch returns relevant results, or WebFetch to official site / GitHub page succeeds).
3. **Numeric facts** — stars, forks, prices, percentages, dates, RPS, latencies, memory figures.
4. **Quoted facts** — "X supports Y", "Z costs $W/mo", "W had N outages in 2026".
5. **Temporal claims** — "released in 2024", "last updated 2 weeks ago", "deprecated".
6. **Superlatives** — "most popular", "fastest", "only solution that does X".

**What NOT to verify:**
- Researcher's own opinion / recommendation (e.g., "reconsider this choice") — verify the evidence supporting it, not the opinion.
- Weight justifications tied to TZ quotes — if researcher quoted the TZ, check the TZ text.
- Anything that's already an open question in `spec.yaml`.

## Verification tactics per claim type

### URL claims (format `[N] github.com/org/repo`)

For GitHub repos:
```
WebFetch https://github.com/<org>/<repo>
  prompt: "Report: (1) does the repo exist (not 404)? (2) is there an 'archived' banner? (3) exact star count shown. (4) exact fork count. (5) last commit timestamp. (6) license. Be literal — don't paraphrase numbers."
```

If the repo is archived and researcher didn't note it → `[contradicted]`.
If the `stars` number researcher cited is off by >20% from what the page shows → `[contradicted]` (likely fabricated or very stale).

For non-GitHub URLs:
```
WebFetch <url> with prompt: "Extract: the claim '<verbatim researcher claim>' — is it stated on this page? Quote the exact sentence that supports or contradicts it."
```

### Product name verification (first mention)

```
WebSearch: "<product name> github OR official site"
```

If zero relevant results OR all results are lookalikes/unrelated → `[existence unverified]` — flag as FATAL for Diablo.
If researcher cited `github.com/org/repo` but WebFetch on that URL returns 404 or different project → `[name mismatch]`.

### Numeric facts

Compare researcher's number to the primary source.

- Stars: `WebFetch github.com/<org>/<repo>` → read exact count from page. Tolerance ±5% (stars update between fetches).
- Prices: `WebFetch` pricing page → exact number. Prices change — note retrieval date.
- Dates: `WebFetch github.com/<org>/<repo>/releases` → exact date of most recent release.
- Benchmarks: if researcher cites `p99 of X ms`, source must be a benchmark page / blog / paper. If source is a reddit comment → downgrade confidence to `low`.

### "Most popular" / superlatives

Require comparative evidence. Researcher must have cited at least 2 alternatives' metrics for a valid superlative claim. If not → `[unsupported superlative]`.

### Dates / recency claims

`WebFetch github.com/<org>/<repo>` → read "last commit" timestamp from page. Researcher's claim "X was updated last week" must match within ±7 days.

## Output format

Write `verification.md`:

```markdown
# Verification Report

Checked: `alternatives.md`, `matrix.md`
Claims audited: <total count>
Results: <X verified> / <Y unverified> / <Z contradicted> / <W skipped>
Verify pass: <date>
Claude model / cutoff: <note>

---

## FATAL (must fix before report ships)

### V-001: [existence unverified] <claim>
- Location: matrix.md § "<matrix name>", cell [axis × alternative]
- Claim: "<verbatim>"
- Checked via: `WebSearch "..."`, `WebFetch "..."`
- Result: 0 relevant results. Possible fabrication.
- Action for researcher: remove row OR provide source.

---

## CONTRADICTED (researcher's claim disagrees with source)

### V-002: [contradicted] <claim>
- Location: alternatives.md § "<alt>"
- Claim: "<verbatim researcher text>"
- Source [<N>] says: "<verbatim from source>"
- Delta: <describe mismatch — e.g., "researcher: 8k stars; actual: 363k">
- Action: update or remove.

---

## UNVERIFIED (no source exists for this claim)

### V-003: [unverified] <claim>
- Location: matrix.md § "..."
- Claim: "<verbatim>"
- Why unverified: <one sentence — what I searched, why nothing turned up>
- Researcher stated confidence: <low/med/high>
- Recommendation: downgrade confidence to `low` OR replace with `?` OR add source.

---

## VERIFIED (spot check passed)

### V-004: [verified] <claim>
- Location: matrix.md § "..."
- Source confirmed: [<N>] <url>
- Match: exact / within tolerance.

(List only a representative sample here — 5–10 items. Main signal is the counts at top.)

---

## ADDITIONAL FINDINGS

### Missing cross-checks
<List: claims where only one source was cited but a second would strengthen confidence.>

### Stale sources
<List: cited sources older than 12 months where freshness matters — pricing, repo activity.>

### Superlatives without comparison
<List: "most popular", "fastest", "only one that" — without comparative metrics.>

### Round-number clusters
<Count how many cells in matrices end in 0 or 5. If >30% of numeric cells → note for Diablo.>

---

## Summary counts

- Total claims identified: N
- Verified: V
- Unverified: U
- Contradicted: C
- FATAL (existence-unverified / contradicted product names): F
- Claim coverage ratio (V / N): X%

Target: coverage ≥90%, FATAL = 0, contradicted ≤2.
If coverage <70% OR any FATAL → verification PASS = BLOCKED.
```

## Verification budget

A full verification pass may take 20–50 tool calls depending on report size. That's OK — this is the critical gate.

Priority order if running short:

1. All FATAL candidates (product name existence) — never skip.
2. All `contradicted`-candidates (cited numbers vs actual via `WebFetch`).
3. Superlatives.
4. Spot-check of 20–30% of regular numeric claims.
5. Skip regular URLs that are well-known (github.com domain itself, anthropic.com, etc.) — assume exists, verify content.

## Explicit do-NOTs

- Do NOT re-research — you're auditing researcher's work, not redoing it. If researcher missed an alternative, that's Diablo's job to flag.
- Do NOT fix the report — only flag. Downstream Diablo + report-writer handle corrections.
- Do NOT verify claims based on Claude's own parametric knowledge unless researcher explicitly marked `[parametric]`. Those get `[unverified, parametric]` tag.
- Do NOT trust `WebFetch` summaries alone — WebFetch uses a small model that can hallucinate. If a claim is important, check a second route: WebSearch for the same claim, or WebFetch a different URL (e.g., docs page + changelog page + README) that each independently mention it.

## Sign-off line

End `verification.md` with:

```
---
Verification pass complete: <date>.
Budget used: <N> WebSearch / <M> WebFetch calls.
Confidence in verification itself: <note on tool limitations, e.g., "WebFetch compression may have missed nuance in long threads">.
```
