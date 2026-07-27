# [PROJECT_NAME] — Business Rules

> **Source of truth for ALL business logic with numerical values, formulas, and policies.**
>
> CLAUDE: never answer rate/price/limit/policy questions without citing a row from this file.
> If the rule isn't here — STOP and ask. Do NOT invent values from conversation memory.
>
> Each row has an immutable ID (R-NNN). When a rule changes, mark the old row `superseded` (don't delete) and add a new row.

---

## Format

| Field | Required | Description |
|---|---|---|
| `ID` | yes | `R-NNN` — never reused |
| `Category` | yes | rates / fees / limits / formulas / policies / SLAs / discounts |
| `Subject` | yes | what the rule applies to (e.g. "senior coach", "VIP user", "bulk order >100 items") |
| `Rule` | yes | exact statement, with numbers in unambiguous units (UAH / USD / EUR, %, days) |
| `Formula` | if calc | mathematical expression if rule is a calculation |
| `Source` | yes | who decided + when (e.g. `owner@2026-03`, `contract:Slugger-LLC#5`) |
| `Effective` | yes | `active` / `superseded by R-NNN` / `archived` |
| `Notes` | optional | edge cases, exceptions, prior context |

---

## Rates

| ID | Subject | Rule | Source | Effective |
|---|---|---|---|---|
| <!-- R-001 | Example coach senior | 1500 UAH per training session, paid weekly | owner@2026-01 | active --> | | | | |

---

## Fees & commissions

| ID | Subject | Rule | Source | Effective |
|---|---|---|---|---|

---

## Limits & quotas

| ID | Subject | Rule | Source | Effective |
|---|---|---|---|---|
| <!-- R-010 | Free tier upload | 100 MB per user per month | terms-of-service:v3 | active --> | | | | |

---

## Formulas

| ID | Subject | Formula | Source | Effective |
|---|---|---|---|---|
| <!-- R-020 | Coach payment | sessions_count × base_rate + (sessions_count ≥ 6 ? 200 : 0) | owner@2026-02 | active --> | | | | |

---

## Policies

| ID | Subject | Rule | Source | Effective |
|---|---|---|---|---|
| <!-- R-030 | Substitution | If a senior replaces another senior, paid at SENIOR rate (R-001), not own rank | owner@2025-11 | active --> | | | | |

---

## SLAs / deadlines

| ID | Subject | Rule | Source | Effective |
|---|---|---|---|---|

---

## Discounts

| ID | Subject | Rule | Source | Effective |
|---|---|---|---|---|

---

## Archived / superseded

| ID | Reason | Replaced by |
|---|---|---|

---

## Maintenance

- Add via `/rule` command (interactive — ensures Source and Subject are filled).
- Never delete rows; mark `archived` or `superseded by R-NNN` to preserve history.
- When file exceeds 200 lines, move `archived` rows to `docs/archive/RULES_ARCHIVE.md`.
- Optionally publish to Outline `Project: [PROJECT_NAME] / Rules` for cross-machine access (NOT shared collection — rules are project-specific, not reusable).
