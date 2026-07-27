---
name: general
description: 'Answer any question with mandatory fact-checking — evidence first, confidence after, no speculation. Reads code, prod DB (read-only), Outline knowledge base.'
argument-hint: <question or topic>
allowed-tools: Read, Grep, Glob, Bash
model: sonnet
---

> **Style:** Load `caveman-distillate` skill — terse responses.

# /general — Verified answers only

Question: **$ARGUMENTS**

---

## PROJECT_CONTEXT

Resolved at runtime from `docs/STACK.md`:
- **Stack**: read `docs/STACK.md`
- **Tests**: `<test_backend>` from STACK.md
- **DB (prod)**: `bin/psql_ro.sh "<query>"` (read-only, 5s timeout, write keywords blocked)
- **Logs (prod)**: `<logs_default>` from STACK.md
- **Knowledge Base**: shared cross-project (Fails, Best Practices, Daily Status, Tricks). Backend
  resolved from `.claude/.setup.json` → `outline.mode` per `docs/OUTLINE-CONTRACT.md` § Backend —
  cloud (`mcp__outline__list_documents` / `bin/outline.sh` fallback), github (`bin/github-kb.sh search`), or local vault.
- **Project KB**: `docs/KNOWLEDGE.md`, `docs/adr/`, `docs/RULES.md` — always local, backend-independent.
- **Local docs**: `docs/KNOWLEDGE.md`, `docs/CONVENTIONS.md`, `docs/RUNBOOK.md`, `docs/TASK.md`

---

## STEP 0 — Question quality gate

If `$ARGUMENTS` lacks a concrete subject (e.g. "почему оно не работает", "что-то сломалось", "is X done") → output:

```
STATUS: INSUFFICIENT — question needs concrete subject.
Examples:
  /general почему клиент 1234 не получил кампанию 78
  /general почему упал тест test_segment_filter
```

Stop. Do not proceed.

## STEP 0.5 — Intent triage (route non-questions away)

If the request is actually:
- "Fix X" / "сломано X" → STOP. Reply: "Use /fix instead — it has the full failing-test-first protocol."
- "Add X" / "сделай X" → STOP. FIRST register the idea: append `- [ ] IDEA-N: <тема>` to `.claude/session-inbox.md` (create file / dated section if missing; N = next number in the current section). THEN reply: "Зарегистрировано как IDEA-N (для регистрации задачи — /todo add)."
- "Run tests" / "deploy" → STOP. Reply: "Use /test or follow docs/RUNBOOK.md."

Continue only for **question/analysis/design** intent.

---

## STEP 1 — Gather evidence FIRST (mandatory, no exceptions)

Classify the question and execute the matching checklist. Do not write a single word of answer before completing it.

If the question matches multiple buckets — execute all matching checklists. Mark which bucket gave **load-bearing** evidence; others contribute context only.

### "Why did entity X get / not get a thing"
→ format: ANALYSIS
1. Read project schema for the relevant entity. If column referenced does not exist in actual schema → STOP. Output `Schema mismatch: column <name> not found in <table>. Run \\d <table>.` Do NOT guess column names.
2. `bin/psql_ro.sh "SELECT ... WHERE id=<id> ORDER BY created_at DESC LIMIT 10"` — concrete row.
3. Read the code path that produced/should-have-produced the row.
4. Cross-reference: does data match logic?

### "Why was X sent / not sent / sent at wrong time"
→ format: ANALYSIS
1. Query the relevant outbox/queue table (project-specific).
2. Read scheduler/launcher code in `app/`.
3. Check job/worker logs: `<logs_default>` filtered by entity ID.

### "How does feature X work" / "Why does Y return Z"
→ format: ANALYSIS
1. `COUNT=$(grep -rc "<term>" app/ 2>/dev/null | awk -F: '{s+=$2} END {print s}')` — gauge noise.
2. If COUNT > 50 → refine path: `grep -rn "<term>" app/<specific_module>/`
3. Then read full file/function (don't excerpt — small reads cause confabulation).
4. Trace execution from entry point to result.

### "Is there a known issue with X"
→ format: ANALYSIS
1. Resolve backend per `docs/OUTLINE-CONTRACT.md` § Backend, search Knowledge Base (Fails + Best Practices + Tricks) for `<keyword>`.
2. Read each matching doc fully.
3. **Stale check**: if doc `updatedAt` > 60 days old → flag in answer: `Evidence age: <date>. Verify still applies.`
4. Local fallback: `grep -rn "<keyword>" docs/ 2>/dev/null`.
5. **Runtime check** (if `bin/glitchtip.sh` present): `bin/glitchtip.sh search "$PROJECT_SLUG" "<keyword>"` — surfaces production exceptions that never made it into FAILS.md. If matches found, pull stacktrace via `bin/glitchtip.sh stacktrace <id>` and include in answer.

### "Why is X failing in production" / "What's the error in <feature>"
→ format: ANALYSIS
1. `bin/glitchtip.sh recent 2>/dev/null | head -20` — list recent issues for this project. Slug auto-detected from docs/STACK.md `glitchtip_project_slug` field.
2. If user named a specific feature/module: `bin/glitchtip.sh search "$PROJECT_SLUG" "<feature>"` to filter.
3. For most-relevant issue: `bin/glitchtip.sh stacktrace <id>` — last 10 frames of latest event.
4. Cross-reference stacktrace with code (read the named file at the named line).
5. If GlitchTip empty / no token → state explicitly «GlitchTip read access not configured for this project — answering from code/logs only».

### "What's the best approach for X" / "How should we design X"
→ format: BRAINSTORM
1. Resolve backend per `docs/OUTLINE-CONTRACT.md` § Backend, search Best Practices for `<keyword>`.
2. Read `docs/KNOWLEDGE.md` (project decisions) + `docs/CONTEXT.md` (glossary).
3. Read `docs/CONVENTIONS.md` (constraints).
4. Optional: `/council <question>` for cross-model perspective on architecture-level decisions.

### "What's happening in production right now"
→ format: ANALYSIS
1. `<logs_default>` — recent app logs.
2. `bin/psql_ro.sh "SELECT now(), <relevant state query>"`.
3. If multi-service: query each service's logs separately.

### "When/who/what changed about X"
→ format: ANALYSIS
1. `git log -S "<term>" --oneline -20`
2. `git log --grep="<keyword>" --oneline -20`
3. `git blame -L <range> app/<file>` for specific lines.

### "Why is test X failing"
→ format: ANALYSIS
1. `<test_backend with -k pattern>` (resolve from STACK.md) — capture full traceback.
2. Read full test code + system under test.
3. `git log -p -- <test_file> | head -200` (recent test changes).
4. If integration: `<logs_default>` during test run.

### Default
→ format: SIMPLE or ANALYSIS depending on complexity
1. `grep -rn "<key term>" app/ | grep -v __pycache__ | head -20`
2. Read the relevant file/function in full.
3. If question involves external behavior — also `docs/KNOWLEDGE.md` and Outline KB.

---

## STEP 2 — Assess confidence AFTER gathering evidence

**For ANALYSIS:**
```
CAN_VERIFY = did I get: 
  (a) the actual file/query result I needed, AND 
  (b) a clear answer in it that I can quote literally?

Both (a) and (b) → HIGH — answer fully
(a) yes, (b) — I can NAME and QUOTE the missing piece → MEDIUM (with explicit gap)
(a) no — file missing / no DB access / ambiguous structure → LOW → STOP
```

**Hard test for MEDIUM**: must be able to quote the specific contradictory or missing fragment. If you can't quote what's missing — it's LOW, not MEDIUM.

## STEP 2.5 — Freshness Gate (mandatory for any external-fact claim)

Provider/library/API/framework facts are volatile. A confident answer based on a stale memory is worse than «I don't know».

**Triggers — apply this gate whenever the answer would state:**
- Library API surface (function signatures, method names, supported params)
- Provider behavior (rate limits, pricing, response fields, model availability)
- Framework patterns (FastAPI/React/SQLAlchemy idioms, recommended approaches)
- Standards / spec details (HTTP semantics, JSON Schema features, OAuth flows)
- Anything that ends with «according to the docs» / «as of <date>»

**Rule:**

1. Before stating any external fact, recall WHEN you last verified it. If you can't pin a date, treat it as stale.
2. **Stale (>30 days) OR can't-pin-date → must verify before claim.** Run ONE of:
   - `mcp__context7__resolve-library-id` then `mcp__context7__get-library-docs` for libs/frameworks
   - WebSearch for provider docs / standards / pricing
   - Read actual code/changelog in the dependency's installed source
3. **Fresh (≤30 days, manually verified this session) → ok to claim with freshness marker.**
4. If verification source contradicts your memory → trust the source, note the contradiction.

**Output format for any external-fact claim:**

<output_format type="external_fact_claim">
```
<claim>  [verified: <YYYY-MM-DD> via <source>]
```
</output_format>

<output_schema>
{
  "claim_line_pattern": "^<claim>  \\[verified: <YYYY-MM-DD> via <source>\\]$",
  "required_fields": ["claim", "verified_date", "source"],
  "date_format": "YYYY-MM-DD (ISO 8601, no time component)",
  "source_must_be": "concrete URL OR tool invocation (e.g. 'context7 fastapi docs', 'platform.openai.com/docs/api-reference'). Banned: 'training data', 'my knowledge', 'recently'.",
  "freshness_window": "verified_date must be within 30 days of today, else re-verify before using"
}
</output_schema>

Examples:
- `FastAPI lifespan replaces on_event since 0.93. [verified: 2026-05-21 via context7 fastapi docs]`
- `OpenAI prompt_cache_key works on inputs ≥1024 tokens. [verified: 2026-05-21 via platform.openai.com/docs/api-reference]`
- `Redis SETEX takes TTL in seconds, not ms. [verified: 2026-05-21 via redis.io/docs/commands]`

**Anti-rules:**
- «I believe X is the case» without a freshness marker — banned. Either verify or say «not verified».
- «Per my training data» — banned. Training cutoff ≠ provider state today.
- Vague timing «recently» / «in newer versions» — replace with a date or skip.

**For BRAINSTORM:** skip CAN_VERIFY. Use confidence tier `DESIGN`. Recommendation must reference at least one concrete pattern (from Outline or `docs/`) OR explicitly state `"No prior pattern found — fresh judgment."`

**If LOW — output ONLY this, then stop:**

```
STATUS: LOW CONFIDENCE — need clarification before answering.

Could not find: <what was missing>
To answer, I need:
1. <specific question>
2. <specific question>
```

Re-run format: `/general <original question> | clarification: <user answer>`

**If this is the second LOW in a row on the same question:**

```
ESCALATE: Cannot answer confidently after clarification.
Likely cause: <missing data / ambiguous schema / no prod access>
Recommended: share the relevant DB query result or log directly.
```

---

## STEP 3 — Answer

Choose format from STEP 1's `→ format:` annotation.

### SIMPLE

<output_format type="general_simple_answer">
```
<answer> [source: <file>:<line> or <DB query>]
```
</output_format>

### ANALYSIS

<output_format type="general_analysis_answer">
```
CONFIDENCE: HIGH | MEDIUM

VERIFIED [source: app/services/segments.py:142]:
  Predicate excludes unsubscribed clients.
  Quote: "if client.status == 'unsubscribed': return False"

NOT VERIFIED (reason: <file missing | no prod access | out of scope>):
  <hypothesis in conditional form: "if X, then Y">
  Recommend checking: <specific query or file>

GAPS:
  <what I couldn't check and why>
```
</output_format>

<output_schema>
{
  "required_sections": ["CONFIDENCE", "VERIFIED", "GAPS"],
  "optional_sections": ["NOT VERIFIED"],
  "confidence_enum": ["HIGH", "MEDIUM"],
  "verified_section": {
    "required_fields": ["source", "claim", "Quote"],
    "source_format": "<file>:<line> OR <DB query> — never 'from memory' or 'training data'",
    "quote_constraint": "MUST be literal (verbatim ≤2 lines) from source. If you cannot quote — the claim is NOT VERIFIED.",
    "anti_rule": "VERIFIED without Quote auto-downgrades to NOT VERIFIED"
  },
  "not_verified_section": {
    "required_fields": ["reason", "hypothesis", "Recommend checking"],
    "hypothesis_format": "conditional ('if X, then Y') — never asserted as fact"
  }
}
</output_schema>

**Hard rule**: every VERIFIED claim MUST include a literal quote (≤2 lines) from the source. Without a quote, the claim auto-downgrades to NOT VERIFIED.

### BRAINSTORM
```
CONFIDENCE: DESIGN (judgment-based, not fully verifiable)

Evidence gathered:
  - <doc / file / pattern read>
  - <pattern: "<title>" from Outline Knowledge Base / Best Practices>  (or: "No prior pattern found.")

Options:
1. <option> — trade-off: <pro vs con>
2. <option> — trade-off: <pro vs con>

Recommendation: <one option with reason>
```
**IDEA capture (auto):** if the recommendation implies changing the project → append `- [ ] IDEA-N: <тема>` to `.claude/session-inbox.md` (same rules as STEP 0.5) and note in the answer: "зарегистрировано как IDEA-N (для регистрации задачи — /todo add)".
Then ask for user direction before proposing a task.

---

## STEP 4 — Optional: save verified facts to the shared Knowledge Base

**IDEA capture first (auto, no prompt):** if the answer contains a recommendation to change the project → append `- [ ] IDEA-N: <тема>` to `.claude/session-inbox.md` (create file / dated section if missing; N = next number in the current section) and add to the answer: "зарегистрировано как IDEA-N (для регистрации задачи — /todo add)".

After answering an ANALYSIS question with HIGH confidence and useful new knowledge:

Ask:
```
Save as F-NNN to shared Knowledge Base / Fails (or Best Practices / Tricks)?
[y/n]
```

If y:
1. Determine target category (fails / best-practices / tricks).
2. Resolve backend per `docs/OUTLINE-CONTRACT.md` § Backend, publish with title/slug `F-NNN-<slug>`, body = condensed verified findings.
3. Confirm with returned URL (cloud) or `bin/github-kb.sh` OK line (github).

---

## STEP 5 — PII masking (always-on for DB output)

When showing DB rows, mask PII by default:
- email → `e***@d***.com`
- phone → `+***-***-NNNN` (last 4 digits only)
- full_name → first letter + last initial: `J. D.`

Show full PII only if user explicitly asks: "show real email" / "show actual phone".

---

## Hard rules

- `probably`, `likely`, `should be`, `I think` are banned everywhere — in VERIFIED and in NOT VERIFIED
- Every VERIFIED claim has exactly one source citation AND a literal quote
- NOT VERIFIED assumptions must use conditional form ("if X, then Y") and always include a "Recommend checking:" item
- NOT VERIFIED requires a reason — no reason means the assumption is dropped entirely
- Never explain "why entity X was selected" without first reading the actual selection code AND querying the entity row
- Never explain code behavior without first reading that code (no skim — full read)
- Schema mismatch → STOP, do not invent column names
- Multi-bucket questions: execute all matching checklists, but mark which bucket provided load-bearing evidence
- Do NOT trigger interactive dialogs in scripts (psql -c only, no \dt without limit)
