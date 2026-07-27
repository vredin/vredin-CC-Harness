---
name: fix
description: 'Fix a bug using the full disciplined process: git backup → root cause analysis → write failing test → confirm failure → fix → deploy → confirm on server → update docs → notify.'
---

> **Style:** Load `caveman-distillate` skill — terse responses, no filler, fragments OK.

You are fixing a bug. Follow ALL steps in order. Do NOT skip any step except where STEP 0 (size triage) explicitly authorizes a skip. Do NOT fix anything before step 5.

Arguments: $ARGUMENTS

---

## STEP 0 — Size triage (MANDATORY — drives every downstream step)

Before any context fetch or knowledge search, classify the bug fix by expected change size. The full ceremony (failing-test-first + Diablo + F-NNN entry) costs ~20-30 min. For typo-level bugs it is pure waste. For real bugs it prevents regressions. The judgment happens HERE.

<output_format type="fix_size_triage">
📐 Size triage for fix: <one-line bug description>

Best estimate (pick exactly one):
  □ TRIVIAL  (typo/rename, ≤10-line fix, root cause is obvious from error message or stack trace)
  □ SMALL    (≤50 lines, single function, root cause clear after reading 1-2 files)
  □ MEDIUM   (≤200 lines, multi-file, root cause requires investigation)
  □ LARGE    (refactor-while-fixing, scope creep, architectural change)

Selected: <TRIVIAL | SMALL | MEDIUM | LARGE>
Reasoning: <one line — what makes it that size>

Routing:
  TRIVIAL  → LIGHT PATH (formal, complete — nothing else from this file applies):
              1. Reproduce: observe the broken behavior once (run the command / open the page / read the error).
              2. Fix: apply the ≤10-line change.
              3. Verify: check by hand OR one targeted existing test on the affected file — no new test required.
              4. FAILS.md: ONE index line in docs/FAILS.md ONLY if the cause was non-obvious. Obvious typo → nothing.
              5. Commit: "[FIX] <desc> (trivial — no test, no Diablo, no F-NNN)".
              6. Deploy: same rules as STEP 7.5 — automatic if deploy config exists; never end with "запусти /deploy".
              NO Diablo, NO Rex, NO spec, NO failing-test-first ceremony.
              Reason: failing-test-first for a typo blocks 10-15 min, prevents zero real risk.
  SMALL    → Standard flow with: STEP 0.5 reduced to ONE grep of docs/FAILS.md (no Outline, no GlitchTip),
              minimal failing test (assertion-level, not full scenario), Diablo skipped.
              Test scope: affected file + 1 level of imports.
  MEDIUM   → Standard /fix flow as written. All STEPs.
              Test scope: affected module + integration tests.
              RECOMMENDED: set `/goal <failing-test-name passes AND no regressions in module>` before STEP 5 (fix).
                See workflow.md § Definition of Done Discipline for condition format.
  LARGE    → STOP. /fix is the wrong tool for refactor-while-fixing.
              Action: promote to a new /todo (`/todo add Refactor + fix <bug>`). Do not continue /fix.
</output_format>

**Anti-rules for STEP 0:**
- Never escalate TRIVIAL → SMALL during execution to "be safe" — pick SMALL upfront if doubt exists.
- Never combine fix + refactor in single /fix flow — that is LARGE and belongs in /todo.
- Diablo can ALWAYS be invoked separately via `/da impl <files>` if user wants extra scrutiny on a SMALL/TRIVIAL fix.

If TRIVIAL — run the 5-point LIGHT PATH above (reproduce → fix → verify → optional FAILS.md line → [FIX] commit with trivial mark) and STOP. Do not enter STEPs 0.5-8.
If SMALL — proceed standard flow, but minimize test scope as noted.
If MEDIUM — proceed standard.
If LARGE — STOP. Tell user: "This is a refactor-with-fix. /fix doesn't cover scope creep. Suggest: /todo add <slug>." Wait for direction.

---

## STEP 0.1 — Fetch context (if GitHub issue)

If arguments contain a GitHub issue number (e.g. `#123` or just `123`):
```bash
gh issue view $ISSUE_NUMBER
```
Read the issue title, body, labels, and comments. Use this as the bug description for all subsequent steps.

If arguments are plain text — use them directly as the bug description.

---

## STEP 0.5 — Search prior knowledge BEFORE diagnosing (mandatory)

Before formulating any hypothesis about root cause, search known failures. The same bug, or its class, may already be documented.

**Size gate (from STEP 0):** TRIVIAL never reaches this step (LIGHT PATH handles it inside STEP 0). SMALL → ONE grep of `docs/FAILS.md` / `docs/PATTERNS.md` only (the "Local fallback" command below), then continue. Outline and GlitchTip lookups are MEDIUM+ only.

> **Read-only fan-out (OPT-IN, MEDIUM bugs):** the three lookups below (Outline / local grep /
> GlitchTip) are independent read-only searches. If all 3 sources are live, you MAY offer to run
> them in parallel via the Workflow tool (read-only, no write conflict, no worktree). OFFER only —
> proceed serially unless the user opts in. See `docs/rules-references/readonly-fanout.md`
> and load `.claude/skills/workflow-planner/` to build the script. For TRIVIAL/SMALL or <3 live
> sources — run serially, skip the workflow.

### Shared Knowledge Base (primary — MEDIUM+ only)
Resolve backend per `docs/OUTLINE-CONTRACT.md` § Backend, search BOTH Fails (matching F-NNN
entries) AND Best Practices (defensive patterns that may apply) for `<3-5 keywords from $ARGUMENTS>`.

### Local fallback (SMALL always; MEDIUM+ if the shared backend is unreachable)
Local files:
```bash
grep -nE "<keyword from $ARGUMENTS>" docs/FAILS.md docs/PATTERNS.md 2>/dev/null
```

### GlitchTip runtime check (MEDIUM+ only, mandatory if `bin/glitchtip.sh` present)

If the project has `bin/glitchtip.sh` (synced from template, requires `GLITCHTIP_TOKEN` in keychain):

```bash
# 1. List recent issues (7 days) for this project. Slug from docs/STACK.md glitchtip_project_slug field.
bin/glitchtip.sh recent 2>/dev/null | head -20

# 2. Search by keyword from user's bug description
bin/glitchtip.sh search "$PROJECT_SLUG" "<keyword from $ARGUMENTS>" 2>/dev/null

# 3. If a likely match found — pull full stacktrace
bin/glitchtip.sh stacktrace <issue_id>
```

GlitchTip captures runtime errors that FAILS.md misses (silent exceptions in workers, third-party API failures). If a matching issue exists with count>1, it's a recurring problem — note in spec section 11 (Red Flags) before writing the fix.

### Decision

**If a matching F-NNN exists** (high confidence — same symptom + same area):
- Read it fully
- Inform user: "Found similar prior fix: F-NNN — <title>. Fix pattern: <one line>. Applying same approach."
- Root cause is known from F-NNN → STEP 2 becomes a one-line confirmation; keep STEP 3 (test documenting the re-occurrence) short

**If GlitchTip shows the same exception class with count>1 in last 7 days but no F-NNN exists**:
- This is the FIRST time we're consciously fixing a recurring runtime error. Higher priority — note count + first_seen + last_seen in spec.
- After fix lands, the F-NNN entry is mandatory (not optional).

**If only adjacent/loose matches**: list them, continue to STEP 1.

**If nothing relevant**: continue to STEP 1.

---

## STEP 1 — Git backup

Run `git add <tracked changed files> && git commit -m "[BACKUP] Pre-fix: $ARGUMENTS | Risks: unknown until root cause | Scope: TBD"`. Never use `git add -A` — it can stage secrets.
If nothing to commit, note it and continue.

---

## STEP 2 — Root cause analysis (diagnosis with proof)

Before writing any test or fix, investigate the code:
- Read all relevant files
- Identify the exact root cause (not just symptoms) — with evidence: quote the offending line(s)
- List 2–3 fix options with trade-offs and risks
- **Decide the correct test TYPE now**: root cause in frontend/user-facing flow → Playwright e2e (`tests/e2e/*.spec.ts`, per E2E Test Discipline); backend logic → unit/integration (pytest/vitest). Knowing the cause first removes the write-unit-then-rewrite-as-e2e churn.

> **Read-only fan-out (OPT-IN, MEDIUM bugs only):** if the bug reaches through 3+ INDEPENDENT
> call-paths, each analyzable standalone, you MAY offer to fan out the path-by-path reading via
> the Workflow tool (`parallel` → compare findings; read-only, no worktree). OFFER only. A single
> coherent root-cause that needs all files in one context is LINEAR — keep it serial, do not fan
> out. See `docs/rules-references/readonly-fanout.md`.

Present the analysis. Proceed automatically with the recommended fix option.

---

## STEP 3 — Write a failing test

Knowing the root cause and test type from STEP 2, before touching any implementation code:
- Write a minimal test of the STEP 2 type that reproduces the exact problem via the diagnosed cause
- The test MUST fail before the fix is applied
- Save the test to the appropriate file

Proceed immediately to STEP 4.

---

## STEP 4 — Run the test locally, confirm failure

Run the test. Show the output.
- If the test **PASSES** unexpectedly: the test does not capture the diagnosed cause — fix the test, or return to STEP 2 and re-diagnose. Do not proceed on a green test.
- If the test **FAILS** as expected: confirm "✓ Test fails — problem reproduced" and continue

---

## STEP 5 — Fix the problem + static checks

Apply the fix. Then run static checks per `docs/STACK.md` — skip empty commands (empty = tool not configured):
```bash
LINT=$(grep '^lint_cmd:' docs/STACK.md | awk '{$1=""; print substr($0,2)}' | tr -d '"' | xargs)
TYPE=$(grep '^typecheck_cmd:' docs/STACK.md | awk '{$1=""; print substr($0,2)}' | tr -d '"' | xargs)
[ -n "$LINT" ] && eval "$LINT"
[ -n "$TYPE" ] && eval "$TYPE"
```
Fix any static errors before proceeding.

---

## STEP 6 — Run the test again, confirm it passes locally

Run the same test from STEP 3 against local environment.
- If it **FAILS**: go back to STEP 5
- If it **PASSES**: confirm "✓ Test passes locally — fix is verified"

> Deploy happens AUTOMATICALLY at STEP 7.5 — never end this command with "run `/deploy`" (banned phrase; the owner launched /fix, that IS the consent to ship the fix).

---

## STEP 6.5 — Same bug elsewhere?

Search the codebase for the same pattern that caused this bug:
```bash
grep -rn "<pattern that caused the bug>" --include="*.py" --include="*.ts" --include="*.tsx" --include="*.js" | grep -v node_modules | grep -v __pycache__
```
If found in other files — fix ALL occurrences now. Do not leave known broken code for later.

---

## STEP 6.6 — Migration-Test Staleness Check (if fix touches a migration)

> Root cause class from OSINT_project (2026-07): an existing test literally asserted the behavior
> of migration `0096` as correct — after that migration was reverted. Nothing caught the resulting
> regression because the test itself had gone stale: it kept validating the OLD, now-wrong
> behavior. This is a cheap, mechanical check — run it every time, not just when hunting a bug.

Detect if this fix's diff touched a migration file — **added, modified, or deleted** (deleted/
reverted is the dangerous case: a test can still assert the now-gone behavior as correct):

```bash
MIG_GREP=$(grep '^migration_path_grep:' docs/STACK.md | awk '{$1=""; print substr($0,2)}' | tr -d '"' | xargs)
CHANGED_MIGS=$(git diff HEAD --name-only --diff-filter=AMD | grep -E "${MIG_GREP:-migrations/|alembic/versions/}")
```

If `CHANGED_MIGS` is non-empty, for EACH touched migration file grep the test suite for its
filename stem (works regardless of framework — Alembic/Django/Rails all encode the migration
identity in the filename):

```bash
for f in $CHANGED_MIGS; do
  STEM=$(basename "$f" | sed -E 's/\.(py|sql|ts|rb)$//')
  grep -rln "$STEM" tests/ 2>/dev/null
done
```

Any hit → open that test NOW, don't just log it:
- Assertion still matches CURRENT schema/behavior → leave it, note "migration-test cross-check: verified current" in the commit.
- Assertion encodes the OLD (now-reverted/changed) behavior as correct → **fix the assertion to match current behavior, in this same change.** This is exactly the stale-oracle class — do not defer it, do not just flag it for later.

If `migration_path_grep` is empty in `docs/STACK.md` → skip, one line: "Migration-test staleness check: n/a (migration_path_grep not set)."

---

## STEP 6.7 — Security Impact Check

Check if the fix touches security-sensitive files:
```bash
git diff HEAD --name-only | grep -iE "auth|session|payment|permission|upload|middleware|password|token|secret|crypto|hash|jwt|oauth"
```

**Rex only for MEDIUM+ (from STEP 0).** SMALL with a match → note the match in the commit message, skip Rex (run `/da impl` or `/review` on demand if worried). (TRIVIAL never reaches this step.)

If MEDIUM+ AND (matches found **OR** the bug itself is security-related — auth bypass, data leak, injection, IDOR, etc.) →
**Invoke `Rex` agent** in BLUE mode, passing:
- List of changed files
- Bug description: `$ARGUMENTS`

> "Verify that the fix for '$ARGUMENTS' in [changed files] is complete and does not introduce new vulnerabilities. Check: was the root cause a security pattern that requires broader remediation?"

Verdicts:
- **CLEAN** → proceed to STEP 7
- **New vulnerability introduced** → return to STEP 5, fix the new issue, loop back from STEP 6
- **Root cause is a security pattern with broader impact** → after STEP 7, record it as a lesson file `docs/fails/F-NNN-<slug>.md` + index line in `docs/FAILS.md` (summary tagged `[SEC]`) documenting the vulnerability class, root cause, fix pattern, and detection method
- **Fix is incomplete** (same vulnerability reachable via different path) → fix all paths before proceeding

If no security-sensitive files changed AND bug is not security-related → skip this step.

---

## STEP 6.8 — E2E Test Gate (if fix touches frontend)

Detect if the fix touched frontend:
```bash
FRONT_CHANGED=$(git diff HEAD --name-only | \
  grep -E '\.(tsx|jsx|vue|svelte|html|css|scss)$|^app/routes/|^src/routes/' | head)
```

If non-empty:
- **Design slop check (impeccable detector):** run the deterministic 44-rule detector on the changed frontend files to catch AI-slop the fix may have introduced (offline, no LLM):
  ```bash
  IMPECCABLE_NO_UPDATE_CHECK=1 npx --yes impeccable@3.2.1 detect --json $FRONT_CHANGED
  ```
  New confirmed slop (side-stripe borders, gradient text, low contrast, etc.) → fix it in the same change. See `docs/rules-references/frontend-impeccable.md`. If node/npx fails, note and continue.
- **Anti-slop functional-bug check** (`docs/rules-references/anti-slop-law.md` §3 — the bug class the detector can't see): if the fix introduced any of these, fix in the same change — (a) **invisible-content trap** (`opacity:0`/translated initial state gated on JS with no static fallback — content must be visible by default), (b) **dead controls** (interactive-looking element with no handler/href), (c) **clipped live content** (`overflow:hidden`/`clip-path` cropping real text). `grep -inE 'opacity:\s*0|initial=\{\{[^}]*opacity:\s*0|animation-timeline|IntersectionObserver' $FRONT_CHANGED`.
- The failing test from STEP 3 should ALREADY be a Playwright `.spec.ts` — STEP 2 chose the test type from the root cause, so this gate should be a no-op. Confirm it asserts observable behavior, then proceed.
- If STEP 3 wrote a unit test anyway (STEP 2 mis-typed the bug) — return to STEP 3, rewrite as `tests/e2e/<bug-slug>.spec.ts` reproducing the bug via real user interaction (per E2E Test Discipline, `.claude/rules/workflow.md`), re-run STEP 4 red → STEP 6 green.

If no frontend changes → skip.

---

## STEP 6.9 — Diablo (mandatory)

Invoke `/da impl <fix_scope>`. Diablo attacks the fix:
- Is this really the root cause, or just a symptom?
- Could the fix introduce a new bug?
- Is the test catching the right thing? (anti-regression check)
- Are there other call paths that hit the same bug?

Verdicts (enum + generic semantics: `.claude/agents/diablo.md`) → fix-specific routing:
- BLOCKED → return to STEP 2 (root cause analysis)
- FIX FIRST → address FATAL findings, loop back from STEP 5
- PROCEED CAUTION / ACCEPTABLE → continue

---

## STEP 7 — Update documentation + auto-publish to Outline

### 7.1 — Local docs
- Update README or inline comments if the fix changes expected behavior
- If root cause is non-obvious — record the lesson (file-per-lesson format, see workflow.md § Memory System):
  1. **Dedup first**: grep `docs/FAILS.md` (index) for the same root cause. Match found → UPDATE the existing `docs/fails/F-NNN-*.md` file (and its index summary if changed). Do NOT create a duplicate. A lesson the fix disproved → delete its file + index line.
  2. No match → pick next free NNN = max F-NNN across `docs/fails/` file names AND `docs/FAILS.md` index lines, +1.
  3. Create `docs/fails/F-NNN-<slug>.md`. Strict format — all 4 fields mandatory, no omissions, no extra fields:
  4. Add index line to `docs/FAILS.md`: `- [F-NNN](fails/F-NNN-<slug>.md) — <one-line summary>` — keep the index sorted by number.
  5. Verify: `bin/memory-lint.sh` → RESULT: OK.

<output_format type="fails_entry">
```
# F-NNN: <one-line summary — symptom → cause>
date: YYYY-MM-DD

**Symptom**: <one-line user-visible behavior>
**Root cause**: <technical cause>
**Fix pattern**: <what to apply when this recurs>
**Detection**: <how to spot in other code: grep pattern, file pattern>
```
</output_format>

<output_schema>
{
  "type": "object",
  "required": ["id", "slug", "Symptom", "Root cause", "Fix pattern", "Detection"],
  "properties": {
    "id": {"type": "string", "pattern": "^F-[0-9]{3,4}$"},
    "slug": {"type": "string", "description": "kebab-case, ≤60 chars"},
    "Symptom": {"type": "string", "maxLength": 120, "description": "ONE line, user-visible behavior — NOT internal stacktrace"},
    "Root cause": {"type": "string", "description": "technical cause; if unknown, write 'Unknown — see ticket' and do NOT speculate"},
    "Fix pattern": {"type": "string", "description": "WHAT to apply on recurrence — not why; if 'just be careful' is the only fix, do not create the entry"},
    "Detection": {"type": "string", "description": "concrete grep/file pattern; vague 'review carefully' is banned"}
  },
  "anti_rules": [
    "no F-NNN without Detection — if you can't spot recurrence, the entry is useless",
    "Fix pattern must be IMPERATIVE action, not narrative ('use parameterized query' not 'we should use parameterized queries')"
  ]
}
</output_schema>

### 7.2 — Auto-publish to the shared Knowledge Base (no prompt)

Read `.claude/.setup.json` → `outline.auto_publish.fix_to_kb_fails`. If `true` (default),
resolve backend per `docs/OUTLINE-CONTRACT.md` § Backend, publish to Fails (github: category
`fails`, slug `F-NNN-<slug>`) with body:
```
## Project
<project name> (from CLAUDE.md or directory)

## Symptom
<copy from docs/fails/F-NNN-<slug>.md>

## Root cause
<copy>

## Fix pattern
<copy>

## Detection
<copy>

## Commit
<SHA of the [CHANGE] commit fixing this>
```

If the backend is unreachable, or `auto_publish.fix_to_kb_fails = false`:
- Skip silently — local FAILS.md is source of truth, the shared KB is replication
- Log: `[KB] auto-publish skipped (backend unavailable or disabled)`

If user wants to suppress for this specific F-NNN — add `[NOPUB]` tag in the
`docs/fails/F-NNN-*.md` lesson file; auto-publish detects and skips.

---

## STEP 7.5 — Deploy (automatic)

Ship the fix without asking — launching /fix is the consent:
- Deploy config exists (`docs/DEPLOY.md` or `docs/STACK.md` deploy_* fields) → run the `/deploy` pipeline now (pre-flight → push → verify services → verify-live). Several fixes in one session → deploy once after the last one.
- No deploy config (local-only project) → skip with one line: "Deploy: n/a (no deploy target)".
- User passed `--no-deploy` → skip with "Deploy: skipped by flag".
- Deploy fails → auto-rollback per /deploy pipeline, report the failure in STEP 8 — do NOT leave it half-shipped silently.

Banned ending: "Готово к деплою — запусти /deploy". The fix is DONE only when it runs on the server (or deploy is explicitly n/a).

---

## STEP 8 — Notify user

Present a concise summary:
```
✅ Fixed: <one line description>
Root cause: <one line>
Test: <test file and test name> — ✓ passes on server
Files changed: <list>
Deploy: <commit deployed>
```
