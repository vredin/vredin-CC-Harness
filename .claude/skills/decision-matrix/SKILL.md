---
name: decision-matrix
description: "Canonical format for scoring design-choice alternatives with evidence. Used by researcher agent. Every cell is {score, confidence, source_id} — never a bare number. Weighted totals computed per-column with missing cells excluded."
---

# Decision Matrix Skill

The format every decision matrix in this framework must follow. Called by `researcher` agent. The rules below are non-negotiable — Diablo verifies compliance in verification mode.

## When invoked

You are constructing ONE matrix per design choice from the spec (e.g., "core runtime framework", "hosting platform", "vendor for image generation"). Multiple decisions → multiple independent matrices.

## Required sections in every matrix file

### 1. Header

```markdown
## Matrix: <decision text verbatim from spec.yaml design_choices>

Stated choice: <user's pick>
Decision category: <runtime | vendor | topology | ...>
Date of research: <YYYY-MM-DD>
```

### 2. Axes selection

```markdown
### Axes (<N> total: <U> universal + <D> domain-specific)

| Axis | Weight | Why this weight |
|---|---|---|
| Security | high | TZ section X.Y: "personal account access" |
| Bus factor | high | TZ: "24/7 autonomy" — single-maintainer risk kills uptime |
| Dev speed | med | TZ: internal tool, not customer-facing |
| Browser automation fit | high | TZ-specific: Execution agent needs it |
| ... | ... | ... |
```

Mandatory:
- **Every weight must cite the spec section or quote** that drove it. No weights without justification.
- **Include at least the 8 universal axes** from `axes-library.md` unless one is clearly N/A for this decision — and if so, say why.
- **Add domain-specific axes** pulled from `spec.yaml` `meta.domain` + `requirements.non_functional`.

### 3. Scores table

```markdown
### Scores

| Axis | User's choice: <X> | Alt A: <Y> | Alt B: <Z> | Alt C: <W> |
|---|---|---|---|---|
| Security | 35% [med, 1] | 70% [high, 3] | 60% [med, 4] | ? |
| Bus factor | 15% [high, 2] | 95% [high, 3] | 80% [med, 5] | 70% [low, 6] |
| Dev speed | 50% [low, 1] | 55% [med, 3] | 85% [high, 7] | 65% [med, 8] |
| ... | ... | ... | ... | ... |
| **Weighted total** | **43%** | **74%** | **71%** | **? (insufficient data)** |
```

**Cell format:** `<score> [<confidence>, <source_id>]`

- `score`: integer 0–100 with `%` OR `?` OR `N/A`
- `confidence`: `low | med | high`
  - `low` = one source or Claude parametric knowledge
  - `med` = 2 independent sources, or 1 primary (maintainer/docs) + 1 community
  - `high` = 3+ independent sources, one of which is recent production usage
- `source_id`: numeric reference `[N]`, corresponds to entry in Sources list below

**If no evidence → `?`.** Never fill a guess.

**Weighted total calculation:**
```
for each column:
  total_weight_considered = 0
  weighted_sum = 0
  for each row (axis):
    if cell has a numeric score:
      weight_numeric = {low: 1, med: 2, high: 3}[axis.weight]
      weighted_sum += score * weight_numeric
      total_weight_considered += weight_numeric
  final = weighted_sum / total_weight_considered
```

If more than 30% of cells in a column are `?`, write `? (insufficient data)` instead of a number — don't score a column you can't fairly evaluate.

### 4. Alternative summaries

Below the scores, each alternative gets a short block:

```markdown
### <Alt A>: <name>

- URL: <link>
- Snapshot (as of <date>): stars <N>, forks <M>, last commit <date>, open issues <count>, license <SPDX>, top contributor % <N%>
- Category: <OSS | commercial | managed service>
- One-line summary: <what it is>
- Pros: <3–5 bullets, each with [source]>
- Cons: <3–5 bullets, each with [source]>
- Dealbreakers for this spec: <list or "none found">
```

Mandatory: even if an alternative looks strictly worse, list 1–2 pros. No strawmen.

### 5. Sources list (at the bottom of each matrix file)

```markdown
### Sources

[1] <URL or tool invocation>, retrieved <YYYY-MM-DD>
    Note: <what was looked up — e.g., "repo metadata", "pricing page", "HN thread comments">
[2] github.com/org/repo (main page), WebFetch 2026-04-24
    Note: Stars / forks / contributors snapshot from repo main page
[3] https://reddit.com/r/<sub>/comments/<id>
    Note: Community sentiment thread, 120 comments, scanned for recurring complaints
...
```

## The "?" rule

When you want to fill a cell but don't have evidence:

- **First try:** run one more tool call (`WebSearch` or `WebFetch`). 80% of cells become fillable this way.
- **If still nothing:** write `?` with a short note below the table:
  ```
  Why `?` on [axis × alternative]: <one sentence — what you searched, what came up empty>
  ```
- **Never guess.** A matrix with 10 `?` cells is more useful than a matrix with 10 hallucinated numbers.

## Rounded-numbers rule (anti-hallucination)

If you're writing a number, avoid multiples of 5 unless you have specific evidence for that value. Guess-numbers cluster at 30, 50, 70, 80. Real measurements scatter. If the source gave `78%` use `78%`, not `80%`.

Diablo flags matrices with >30% round-number cells.

## Disagreement handling

When two sources give conflicting scores:

```
Security: 35% [med, 1,4,disputed]
  Note: [1] maintainer claims audit passed; [4] HN thread 2026-02 lists 3 CVE-candidate issues unresolved. Score reflects community view.
```

`disputed` tag in source-id list. Diablo likes this — it's evidence of multi-source check.

## Do NOT

- Do not mix two decisions in one matrix. Separate files per decision.
- Do not include alternatives you haven't researched. "I heard of it" isn't research.
- Do not omit the user's stated choice. It's always a column.
- Do not write weighted total as an exact percentage with decimals (`43.7%`) — false precision. Round to integer.
- Do not recommend a winner. Matrix informs the human; human picks.

## Sign-off line

Each matrix file ends with:

```markdown
---
Matrix constructed by `researcher` agent on <date>.
<N> axes × <M> alternatives = <N*M> cells. <K> cells `?`. Cite ratio: <verified_count>/<total_cells>.
Reader: apply your own weights. Default weights reflect the TZ as written.
```
