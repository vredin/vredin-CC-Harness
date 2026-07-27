---
name: rule
description: 'Capture a business rule (rate / fee / limit / formula / policy / SLA / discount) into docs/RULES.md with structured fields. Prevents conversation-memory hallucination of business values.'
argument-hint: <rule statement, e.g. "senior coach 1500 UAH per training">
allowed-tools: Read, Write, Edit, AskUserQuestion, Bash
model: sonnet
---

> **Style:** Load `caveman-distillate` skill — terse output.

# /rule — Capture business rule

Statement: **$ARGUMENTS**

This command writes a business rule to `docs/RULES.md` with **mandatory** structured fields. It is the ONLY sanctioned way to record numerical/policy values that Claude is allowed to cite.

---

## STEP 1 — Read existing RULES.md

```bash
cat docs/RULES.md 2>/dev/null || echo "RULES.md missing"
```

If missing → create from `.claude/skills/...` template OR ask user to run `/docs init` first.

---

## STEP 2 — Detect duplicates / contradictions

Search RULES.md for any existing row touching the same `Subject` (substring match, lowercase).

**If existing rule found**:
1. Show it to user.
2. Ask: "An existing rule covers this subject:
   - **R-NNN**: <existing rule>
   What do you want to do?
   - (a) Add new rule — old keeps `active`, both apply (different conditions)
   - (b) Supersede old — old becomes `superseded by R-<new>`, new becomes `active`
   - (c) Cancel — don't add anything"
3. Wait for answer.

**If no existing rule** → proceed.

---

## STEP 3 — Extract or ask for required fields

Try to parse `$ARGUMENTS` for:
- **Subject** (e.g. "senior coach")
- **Rule** (the statement itself)
- **Category** — guess from keywords:
  - "rate" / "UAH" / "USD" / "EUR" / "per hour" / "per session" → `rates`
  - "fee" / "commission" / "%" → `fees`
  - "limit" / "max" / "min" / "quota" → `limits`
  - "if X then Y" / "= ... × ..." → `formulas`
  - "allowed" / "must" / "cannot" / "when ... do" → `policies`
  - "deadline" / "within N days" / "response time" → `SLAs`
  - "discount" / "promo" → `discounts`

If ambiguous (>2 categories match or none) → use `AskUserQuestion`:
> "Which category fits this rule?
> - rates / fees / limits / formulas / policies / SLAs / discounts"

---

## STEP 4 — Mandatory grilling (3 questions max, one at a time per grill-me skill)

Ask via `AskUserQuestion` (one question per call, recommended answer included):

**Q1: Source**
> Who decided this rule and when?
> - owner@<YYYY-MM> (the simplest)
> - contract:<name>#<section>
> - terms-of-service:v<version>
> - email-from-<who>@<date>
> - regulation:<law/article>
> - **(Other)** for free-text

This field is REQUIRED. If user can't answer — refuse to record. Anonymous rules cause future disputes.

**Q2: Effective until / scope (only if not obvious)**
> Is this permanent or time-limited?
> - active (no expiry known)
> - until <YYYY-MM-DD>
> - while <condition>

Default `active`.

**Q3: Edge cases worth noting (skip if obvious)**
> Any exceptions, edge cases, or "but if X" the rule should mention?
> - none
> - <free-text>

Goes into `Notes` column.

---

## STEP 5 — Determine next R-NNN

```bash
NEXT=$(grep -oE "R-[0-9]+" docs/RULES.md | sort -u | tail -1 | sed 's/R-//' | awk '{printf "R-%03d", $1+1}')
[ -z "$NEXT" ] && NEXT="R-001"
```

---

## STEP 6 — Insert row into the right table section

Open `docs/RULES.md`, find the section header matching the chosen category (e.g. `## Rates`), append a new row to that section's table (before the next `---` separator).

**Format:**
```markdown
| R-NNN | <Subject> | <Rule> | <Source> | active |
```

For formulas, also fill the `Formula` column.

If supersede mode (Q1 path b): also EDIT the old row to mark `Effective` as `superseded by R-NNN`.

---

## STEP 7 — Diablo attack on the new rule

Invoke `/da spec` mode against the new rule.

Diablo checks:
- Does this contradict any other R-NNN? (re-grep)
- Are units unambiguous? (UAH vs USD vs EUR vs %, "per session" vs "per hour")
- Is "active" period really open-ended or should it have an expiry?
- Are exceptions sufficiently spelled out?
- Is Source verifiable (a contract section / email / decision log)?

If FATAL findings → revert the addition, report to user, ask to revise.
If SERIOUS only → warn but commit.

---

## STEP 8 — Commit

```bash
git add docs/RULES.md && git commit -m "[RULES] Add R-NNN: <subject> — <one-line rule>

Source: <source>
Category: <category>
Diablo verdict: <verdict>"
```

---

## STEP 9 — Publish (mode-dependent, no prompt)

Read `.claude/.setup.json` → `outline.auto_publish.rules_to_project` and `outline.mode`.

**`mode = "cloud"`** and flag `true` (default):
1. Read `outline.project_collection_id` from `.setup.json`. If missing → log `[OUTLINE] skipped: no project_collection_id (run /setup → Bootstrap)` and continue.
2. `mcp__outline__create_document`:
   ```
   title: "R-NNN: <subject>"
   collectionId: <project_collection_id>
   parentDocumentId: <Rules sub-page ID>
   text: |
     **Category**: <category>
     **Subject**: <subject>
     **Rule**: <full rule text>
     **Formula**: <if applicable>
     **Source**: <source>
     **Effective**: active
     **Notes**: <if any>
     
     ---
     Recorded by /rule on <ISO timestamp>. See docs/RULES.md row R-NNN.
   publish: true
   ```
3. Capture returned URL.

**`mode = "github"` or `"local"`** → no-op per `docs/OUTLINE-CONTRACT.md` § Backend —
`docs/RULES.md` committed to this project's own repo IS the publication. Log `[KB] n/a in <mode> mode — docs/RULES.md is the publication`.

NOT published to the shared Knowledge Base regardless of mode — business rules are
project-specific, not reusable.

If cloud mode but MCP disconnected, or `auto_publish.rules_to_project = false`:
- Skip silently — local RULES.md is source of truth.
- Log: `[OUTLINE] auto-publish skipped`.

---

## STEP 10 — Confirm

```
✓ Rule recorded
ID: R-NNN
Subject: <subject>
Source: <source>
File: docs/RULES.md
Diablo: <verdict>
KB: <url, or "n/a in github/local mode", or "skipped">
```

---

## Hard rules

- NEVER skip Source field (Q1). No anonymous rules.
- NEVER overwrite an existing R-NNN. Always supersede or add new.
- NEVER record a rule without Diablo passing.
- If user describes a "rule" that's actually code logic (e.g. "the function does X") — REJECT, suggest `/improve-arch` or ADR instead. RULES.md is for business decisions, not implementation.
- If user describes a rule with vague subject ("usually we charge a bit more") — REJECT, demand precision.
