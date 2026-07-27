---
name: self-audit
description: 'Analyze recent sessions for recurring failure patterns and propose diff-ready improvements to template rules/commands. Run weekly via /loop.'
argument-hint: [--global | --since YYYY-MM-DD]
allowed-tools: Read, Write, Bash, Grep, Glob
model: opus
---

> **Style:** Load `caveman-distillate` skill.

# /self-audit — Process improvement loop

Mode:
- (no args) — local: analyze this project's sessions only
- `--global` — aggregate across all projects via Outline
- `--since YYYY-MM-DD` — explicit period

---

## Why this command exists

`docs/FAILS.md` and Outline `Knowledge Base / Fails` log WHAT broke. They don't change WHY it kept breaking.

Self-audit reads the failure log, finds patterns, and proposes **diff-ready** changes to:
- `.claude/rules/workflow.md`
- `.claude/rules/skill-routing.md`
- `.claude/commands/*.md`
- agents

Output is a remediation file the user can apply or reject. Each suggestion has exact file path, exact old text, exact new text.

---

## STEP 0 — Close the loop on the previous audit (mandatory, before gathering)

An audit whose findings evaporate is theatre. Establish the fate of EVERY past finding first.

```bash
# Latest previous report (actual naming pattern used by STEP 3):
PREV=$(ls -1 docs/SELF-AUDIT-*.md 2>/dev/null | sort | tail -1)
```

If `$PREV` exists — for each finding in it, determine fate:
1. Marked `APPLIED: <sha>` / `REJECTED: <reason>` / `DEFERRED: <until>` → take as recorded (DEFERRED past its date = unapplied).
2. Unmarked → verify yourself: does the finding's `New text:` now exist at its file path (grep), or does `git log --oneline --since=<prev date>` show a commit applying it? Yes → APPLIED, record the proof (commit SHA or `file:line`). No → NOT APPLIED.

Results:
- The new report MUST open with: `Closed X of Y findings from <PREV>` + a per-finding fate table (finding / fate / proof).
- Each NOT APPLIED finding (and not REJECTED) is re-raised in this audit as category `unapplied-remediation` — it counts as evidence on its own, no ≥3 threshold.

If no previous report — state `First audit — no previous findings to close` and continue.

---

## STEP 1 — Gather data

### Local mode (default)
```bash
# Sessions covered
SINCE="${SINCE:-$(date -v-7d +%Y-%m-%d)}"

# 1. Recent fails: lesson files (file-per-lesson format; date: line in each) + shared KB
grep -H "^date:" docs/fails/F-*.md 2>/dev/null | awk -v s="$SINCE" '$2 >= s' || true
# legacy projects (pre-migration single file):
[ -d docs/fails ] || grep -A 5 "## F-" docs/FAILS.md 2>/dev/null | grep -B 1 "$SINCE" || true
# shared KB: resolve backend per docs/OUTLINE-CONTRACT.md § Backend, search Fails for "<project_name>"

# 2. Stuck Protocol triggers (from handoffs)
grep -r "Stuck Protocol\|3rd attempt" docs/reports/ docs/handoff.md 2>/dev/null

# 3. Workflow rules ignored (transcript heuristic)
# - BACKUP commits skipped before edits → check git log for [BACKUP] before [CHANGE]
git log --pretty="%H %s" --since="$SINCE" | \
  awk '/\[CHANGE\]/{change=$0; getline prev; if (prev !~ /\[BACKUP\]/) print "MISSING_BACKUP:", change}'

# 4. /todo skipped (changes without spec)
git log --pretty="%s" --since="$SINCE" | grep -E "T-[0-9]+" | sort -u > /tmp/changes_with_T
ls docs/specs/T-*.md 2>/dev/null | sed 's|.*T-||;s|-.*||' > /tmp/specs
comm -23 <(sort /tmp/changes_with_T) <(sort /tmp/specs) || true
```

### Global mode (`--global`)
1. Resolve backend per `docs/OUTLINE-CONTRACT.md` § Backend, search all Fails across projects
   (cloud: query `F-` in shared_kb_id; github: `bin/github-kb.sh search F- "" fails` — no project filter greps every project's `fails/`).
2. Group by tag/title prefix (project name).
3. Identify failures appearing in ≥3 projects → template-level issue.

---

## STEP 2 — Pattern detection

Cluster gathered evidence by category:

| Category | Signal | Threshold |
|---|---|---|
| Recurring fail class | Same root cause appears in N fails | N ≥ 3 (local), ≥ 3 projects (global) |
| Workflow violations | Step skipped repeatedly | ≥ 5 occurrences in period |
| Skill not loaded when needed | task type matches skill, but not loaded | ≥ 3 occurrences |
| Command missing | shell commands run that should be a slash command | same shell pattern ≥ 5 times |
| Time wasted in rabbit holes | Stuck Protocol triggered | every occurrence is a finding |
| **Banned `cp -f` on project files** | `cp -f` invocation on any file in the project-customized list (see workflow.md → "Project file overwrite discipline") | every occurrence is a finding (HIGH severity) |

### Rule: ceremony bypass = process finding, not enforcement finding (revfactory principle)

If the user/model regularly bypasses a ceremony — edits landing outside `/fix`, back-to-back empty `[BACKUP]` commits, the same `/skip <step>` repeating across sessions — that is a **process-level finding**: the ceremony's cost exceeds its value for that case. Remediation = fix the process (lighter path, softer gate, better trigger), NOT stronger enforcement of the existing one. Proposing «add a blocking hook» for a repeatedly-bypassed step is itself an anti-pattern.

### Specific detection: TASK.md write without Diablo verdict (HIGH severity)

For each T-NNN currently in `docs/TASK.md`, verify spec has `step_5_diablo` frontmatter set to ACCEPTABLE, PROCEED_CAUTION, or `skipped:<reason>` (size-triage SMALL/MEDIUM path). Catches both:
- Tasks added BEFORE the PreToolUse hook was activated
- Tasks added by Sonnet rationalizing «trivial, skip Diablo»

```bash
for tid in $(grep -oE 'T-[0-9]{3,4}' docs/TASK.md 2>/dev/null | sort -u); do
  spec=$(ls docs/specs/${tid}-*.md 2>/dev/null | head -1)
  if [ -z "$spec" ]; then
    echo "MISSING_SPEC: $tid (in TASK.md but no spec in docs/specs/)"
    continue
  fi
  # Check frontmatter for step_5_diablo
  verdict=$(awk '/^---[[:space:]]*$/{fm=!fm;next} fm && /^[[:space:]]*step_5_diablo:/{sub(/^[^:]*:[[:space:]]*/,"");sub(/[[:space:]]*$/,"");gsub(/"/,"");print;exit}' "$spec")
  case "$verdict" in
    ACCEPTABLE|PROCEED_CAUTION|"PROCEED CAUTION") ;;
    skipped:*) ;;  # size-triage SMALL/MEDIUM skip — valid per todo.md STEP 5
    BLOCKED|FIX_FIRST|"FIX FIRST") echo "DIABLO_BLOCKED_BUT_IN_BACKLOG: $tid (verdict: $verdict)" ;;
    "") echo "DIABLO_VERDICT_MISSING: $tid (no step_5_diablo in spec frontmatter)" ;;
    *) echo "DIABLO_VERDICT_UNKNOWN: $tid (value: $verdict)" ;;
  esac
done
```

For each match → finding HIGH severity:
- File path: `docs/specs/<spec>.md` and `docs/TASK.md`
- Suggest fix: «Retroactively run `/da spec $tid`. If FIX FIRST/BLOCKED — move task back to spec phase via `/todo` flow + fix issues. Update spec frontmatter `step_5_diablo` with verdict.»
- Reference: workflow.md § Process Step Discipline + .claude/commands/todo.md STEP 5

### Specific detection: `cp -f` on customized files

```bash
# Search recent shell commands and commit messages for the violation pattern
PROTECTED_FILES="CLAUDE.md|project\.md|settings\.json|\.setup\.json|STACK\.md|CONTEXT\.md|RUNBOOK\.md|RULES\.md|KNOWLEDGE\.md|FAILS\.md|PATTERNS\.md|TASK\.md|DEPLOY\.md"

# In commit messages and shell history (if accessible):
git log --since="$SINCE" --pretty="%B" | grep -E "cp -f.*($PROTECTED_FILES)" | head -10

# In session-log if available:
grep -E "cp -f.*($PROTECTED_FILES)" .claude/session-log.jsonl 2>/dev/null | head -10
```

For each match → finding HIGH severity:
- File path violated (full match)
- Suggest fix: «Replace with Edit tool surgical change OR `cp -n` (no-clobber)»
- Reference: workflow.md → "Project file overwrite discipline"

For each category, generate finding:
```
PATTERN [<category>] (×<count>): <one-line description>

Evidence:
  - <fail/event 1, with link>
  - <fail/event 2>
  - ...

Root cause: <what process gap allows this>

Suggested fix:
  File: <exact path>
  Old text: <quote, ≤3 lines>
  New text: <proposed replacement, ≤5 lines>
  Rationale: <why this fix prevents future occurrences>

Task: <the exact line added to docs/TASK.md backlog>
      OR "no action needed because <concrete reason: already fixed in <sha> / superseded by <what> / one-off, cause removed>"
```

**Findings without a task are banned.** Every finding MUST either add a backlog line to `docs/TASK.md` (format: `- [ ] (self-audit <DATE>, finding K) <one-line action> — promote via /todo add`; do NOT mint a T-NNN — that requires the /todo spec flow) or carry an explicit justified "no action needed because …". Actually write the TASK.md line in the same run — a promise is not a task.

---

## STEP 3 — Output remediation file

Write to `docs/SELF-AUDIT-<DATE>.md`:

```markdown
# Self-Audit — <PROJECT or GLOBAL> — <DATE>
Period: <SINCE> to <today>

## Previous audit loop closure
Closed X of Y findings from <PREV report path> (from STEP 0):
| Finding | Fate | Proof |
|---|---|---|
| <one-line> | APPLIED / REJECTED / DEFERRED / NOT APPLIED (re-raised below) | <sha / file:line / reason> |

## Summary
- Patterns found: N
- Suggested file changes: M
- Tasks created in docs/TASK.md: K (rest justified "no action needed")
- Severity: <high if any pattern with ≥5 occurrences, medium if ≥3, low otherwise>

## Findings
<one block per pattern, format from STEP 2>

## Apply
For each finding, user reviews and either:
- Accepts → user runs the suggested edit (manually or via "apply finding K")
- Rejects → mark `REJECTED: <reason>` in this file (audit memory for next run)
- Defers → mark `DEFERRED: <until>`

## Audit memory
Previous audits and their outcomes:
- <DATE>: N findings, K accepted, M rejected, J deferred
```

---

## STEP 3.5 — humanizer pass on remediation file (mandatory)

The remediation file (`docs/SELF-AUDIT-<DATE>.md`) is **read by humans** — you decide which findings to apply. Apply `humanizer` skill to:
- Pattern descriptions
- Root cause prose
- Rationale lines

Diff blocks (file path, old text, new text) pass through unchanged — those are exact citations.

---

## STEP 4 — Apply (optional)

If user says `apply finding K` after reading the audit:
1. Read finding K from `docs/SELF-AUDIT-<DATE>.md`.
2. Verify the `Old text:` exists at the named file path.
3. Use Edit tool to replace.
4. Mark finding as `APPLIED: <commit_sha>` in audit file.
5. Commit with message: `[PROCESS] Apply self-audit finding: <one-line>`.

---

## STEP 5 — Global aggregation (only `--global`)

After local report:
1. Resolve backend per `docs/OUTLINE-CONTRACT.md` § Backend, publish the audit summary to
   Best Practices as `process-audit-<DATE>` (github: category `best-practices`, slug `process-audit-<DATE>`).
2. If a pattern affects ≥3 projects → propose a **template-level** change (path = `~/PycharmProjects/1claude-project-template-*/.claude/...`), not a per-project change.

---

## Hard rules

- Output format MUST include exact file path + exact old text + exact new text. No "consider adding...", "you might want to...".
- "Be more careful" / "pay attention to X" — banned outputs. Auto-rejected.
- Findings without ≥3 supporting evidence items are filtered out (signal vs noise). Exception: `unapplied-remediation` findings from STEP 0 pass with 1 evidence item.
- Every kept finding MUST carry a `Task:` field — a line actually written to `docs/TASK.md` in this run, or an explicit "no action needed because <reason>". Findings that vanish without either are banned.
- STEP 0 is not skippable: a report without the "Closed X of Y" opening block is invalid.
- Audit memory: if a finding is REJECTED, do not propose the same fix in subsequent audits unless new evidence emerges.

---

## Designed for /loop

```bash
# Local weekly Friday 10:00
/loop "0 10 * * 5" /self-audit

# Global bi-weekly 1st and 15th 11:00
/loop "0 11 1,15 * *" /self-audit --global
```
