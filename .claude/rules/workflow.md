# Development Workflow Rules

> HARD RULES on Persistence / Business Logic / E2E Test / Targeted Test Discipline live in `CLAUDE.md` (primary attention slot). This file owns process protocols.

---

## Project file overwrite discipline (HARD RULE)

> Bug 2026-05-08: blanket `cp -f $TPL/CLAUDE.md $PROJ/CLAUDE.md` overwrote project values (`Investment Assistant` / `Russian` reverted to `[PROJECT_NAME]` / placeholder).

**`cp -f` is BANNED on these files** (project-customized after `/init-project`):

| File | Project-specific content |
|---|---|
| `CLAUDE.md` | Project name, language, stack customizations |
| `.claude/rules/project.md` | Stack, deploy, secrets per project |
| `.claude/settings.json` | User permissions, hooks customizations |
| `.claude/.setup.json` | Outline collection IDs, loops, language |
| `docs/STACK.md` | Real lint/test/db/ssh values |
| `docs/CONTEXT.md` | Filled domain glossary |
| `docs/RUNBOOK.md` | Filled SSH alias / container names |
| `docs/RULES.md` | Real R-NNN business rules |
| `docs/KNOWLEDGE.md` | Project-specific architectural decisions |
| `docs/FAILS.md` | Project-specific F-NNN entries |
| `docs/PATTERNS.md` | Project-specific patterns |
| `docs/TASK.md` | Active backlog |
| `docs/DEPLOY.md` | Real server config |

**Allowed approaches** (preferred order):

1. **`Edit` tool surgical** — only changes what needs changing
2. **`cp -n`** (no-clobber) — safe for new projects, no-op for existing
3. **Conditional `cp` with grep** — `grep -q '\[PROJECT_NAME\]' file && cp -f tpl file`
4. **`cp -f`** — ONLY for template-defined files (commands, agents, skills, hooks, references)

When in doubt — assume project-customized, use Edit.

---

## Process Step Discipline (HARD RULE — applies to /todo, /fix, /orchestrate, /intent, /decompose, /review)

User feedback during a structured workflow applies to the CURRENT step. It does NOT bypass the step.

To skip a step, user types the literal token `/skip <step-name> <reason>`. Sonnet NEVER decides to skip on user's behalf. Sonnet rationalizing «user explained X», «task is trivial», «user seems annoyed» is the failure mode being prevented.

If user pushes back without `/skip`:
1. Acknowledge their input — apply it to current step
2. Ask: "I'm at STEP X (<step-name>). Continue with your input applied? Or `/skip <step> <reason>` to skip explicitly, or `/abort` to switch to /quick-plan?"
3. NEVER silently skip; NEVER proceed past current step until its done condition is met

For trivial work (typo, rename, ≤10 lines) — use `/quick-plan` from the start. `/todo` does not have skip semantics; choosing `/todo` commits to all steps unless explicit `/skip`.

Banned mental patterns (replaced by literal-token discipline):
- «user explained X → don't ask Y»
- «small task → skip prior-knowledge check»
- «spec is fine → don't run Diablo»
- «user seems annoyed → skip grill-me»

If user EXPLICITLY uses `/skip <step> <reason>` — acknowledge, log in spec frontmatter `workflow_progress.<step>: skipped:<reason>`, proceed. The reason becomes part of the spec record so Diablo can flag rationalization patterns retroactively.

---

## Definition of Done Discipline (HARD RULE — applies to MEDIUM/LARGE work)

> AI без explicit completion condition не знает когда закончить. Модель будет «улучшать», «дополнять», «на всякий случай добавлять» — пока ты не остановишь руками. На MEDIUM/LARGE задачах это съедает 30-60% времени впустую.

**Solution: built-in `/goal` command** (Claude Code v2.1.139+).

Set explicit measurable completion condition BEFORE starting non-trivial work. Claude loops until condition holds — a small evaluator model checks transcript after each turn. Goal auto-clears when met.

**When to use `/goal`:**

| Task size (from STEP 0 triage) | Use /goal? |
|---|---|
| TRIVIAL | No — overkill |
| SMALL | Optional — usually one-shot |
| MEDIUM | **Recommended** — prevents «one more refactor while I'm here» drift |
| LARGE | **Mandatory** — without it, model loops on aesthetics |
| `/orchestrate` (any spec) | **Mandatory** — condition = spec's Success Criteria |
| `/fix` for non-obvious bug | **Recommended** — condition = failing test now passes + no regressions |

**What makes a GOOD condition:**

1. **One measurable end state** — test exit code, build status, file count, queue empty, specific output present
2. **Stated check method** — HOW Claude proves it (the command/check that produces evidence)
3. **Constraints** — what must NOT change on the way (e.g. «no other test file modified»)
4. **Demonstrable from transcript** — evaluator only sees Claude's output, can't run commands itself

**Examples — good conditions:**

```
/goal pytest tests/test_auth.py exits 0 AND pytest tests/test_session.py exits 0 AND no new lint errors from `uv run ruff check .`. No files outside app/auth/ or tests/ are modified.

/goal All 5 deliverables from docs/specs/T-042 Section 6 (Deliverables) exist on disk AND test_payment_flow.py:test_idempotent passes AND grep -c "TODO" in changed files is 0.

/goal git diff --stat shows changes only in app/services/email.py and tests/test_email.py AND pytest tests/test_email.py shows "passed" AND ruff check . exits 0.
```

**Examples — BAD conditions (anti-patterns):**

```
/goal Make the code better.
  → Not measurable. Evaluator can't judge "better".

/goal Refactor done correctly.
  → Subjective. No verification method stated.

/goal Tests pass.
  → Which tests? How verified? Evaluator may accept "tests probably pass" from model output.

/goal Production-ready.
  → Vague. Could loop forever.
```

**Anti-rules:**

- **Never set `/goal` without measurable end state.** Vague conditions cause the loop to run until token budget exhausted or you intervene.
- **Never make the condition depend on data the evaluator can't see.** Evaluator reads transcript only — if condition is «database has no errors», Claude must have run a query and shown the result.
- **Never combine `/goal` with `/skip <step>` on the same task** — they signal opposite intents (more rigor vs less rigor).
- **Always state constraints**, not just end state. «Tests pass» without «no other tests broken» allows regression to slip through.

**Cost awareness:** `/goal` loop consumes tokens per turn until condition met. On unbounded conditions (the bad-example category), you can burn through hours of compute. Stop manually with `Ctrl+C` or `/goal clear` if loop diverges.

---

## Branch Switch Discipline (HARD RULE — protect `.claude/` across `.gitignore` divergence)

> Incident 2026-05-28: OSINT_project lost 117 `.claude/` files when switching from `clean-main` (which tracked `.claude/`) to `main` (which ignores `.claude/`). Standard git behavior — silent file removal during checkout. Project recovery took 1 hour.

Before `git checkout <branch>` or `git switch <branch>` between branches with potentially differing `.gitignore`:

1. **Diff the `.claude/` line in `.gitignore`:**
   ```bash
   git show HEAD:.gitignore 2>/dev/null | grep -E "^\.claude" || echo "current: no .claude/ ignore"
   git show <target>:.gitignore 2>/dev/null | grep -E "^\.claude" || echo "target: no .claude/ ignore"
   ```

2. **If outputs differ** — git checkout will delete files silently. Snapshot first:
   ```bash
   cp -R .claude/ /tmp/claude-snapshot-$(date +%s)/
   ```

3. **After switch** — verify file counts match. Restore from snapshot if anything vanished:
   ```bash
   ls .claude/commands/ | wc -l  # should match pre-switch
   ls .claude/skills/ | wc -l
   ls .claude/agents/ | wc -l
   ```

**Banned:** `git checkout <branch>` across `.gitignore` divergence without snapshot. The PreToolUse destructive-shell hook blocks `git checkout --` and `git clean -fd*`, but cannot detect cross-branch `.gitignore` differences. This is a user-discipline rule.

---

## Post-Compact Red Flag (HARD RULE — destructive ops after `/compact`)

> Incident 2026-05-14 → 2026-05-15: Claude ran `git rm --cached .claude/` (rationale: «not part of project»). After `/compact` lost memory of that decision. On 2026-05-15, ran the same `git rm` again. Two consecutive rationalizations of the same destructive choice across a single compaction boundary.

After `/compact` (or in any session resuming via `docs/handoff.md`), before running ANY of:
- `git rm`, `git rm --cached`
- `git reset --hard`, `git clean -fd*`
- `rm -rf <directory>`
- `DROP TABLE`, `DELETE FROM <table>` without WHERE
- Bulk-delete via Bash globs

**MUST first:** read the last 20 git commits (`git log --oneline -20`). If a similar destructive operation appears in history — your pre-compact self already debated this. Read that commit's message for context before re-executing.

**Banned mental pattern:** «I'll do X. Surely there's no reason not to» — when the reason was discussed pre-compact but lost. Look at history first, decide second.

---

## Tool Failure Discipline (HARD RULE — per-tool semantics)

Tools fail in different ways. Apply the right rule for the tool class:

### Issue trackers (`gh issue create`, `linear`, `jira`)
- Output containing `"skipped"` / `"already exists"` AND no resulting URL → STOP
- Capture stderr + exit code + stdout into spec section 11 (Red Flags)
- Investigate: re-run without `--skip-existing`/duplicate-suppression flags. Check if issue exists. Ask user if blocked.

### Lint / type-check / test runners (`ruff`, `mypy`, `pytest`, `eslint`, `tsc`)
- Reported failure count > 0 → STOP. Do NOT commit.
- Paste full output (or relevant lines) into spec section 11 verbatim
- Fix all reported issues OR document in spec why intentional (with Diablo verdict on the rationalization)

### Other commands (`grep -q`, `git diff --quiet`, `comm -23`, `test`)
- Exit nonzero is often the SUCCESS case (no match found, no diff, sets equal). Do NOT auto-treat as failure.
- For unfamiliar tools — record exit code in spec, decide per case based on tool's documented exit-code semantics
- Default: nonzero exit alone is NOT a STOP signal; investigate the tool's documented semantics first

Banned: «tool returned skipped → continue silently», «5 lint errors → commit anyway», «test 1 failed → mark task done», «gh skipped → log and proceed».

---

## TDD Discipline (HARD RULE — applies to ALL code-touching work)

> Test before code. Period. Commands `/fix`, `/orchestrate`, `/improve-arch` enforce. Direct edits without these commands violate.

**Cycle (5 steps):**
1. Write failing test FIRST — captures expected behavior
2. Run test → MUST FAIL (red) — proof test is real
3. Implement / fix — minimum code to pass
4. Run test → MUST PASS (green)
5. Static analysis from `docs/STACK.md` (`lint_cmd`, `typecheck_cmd`) — zero tolerance

**Anti-regression check** (separates real tests from theatre):
After step 4, mentally `git revert` impl. Test must FAIL again. If not — test targets implementation, not behavior. Rewrite assertions.

**Where enforced:**
| Command | TDD step location |
|---|---|
| `/fix` | STEP 2/3 (test+red), STEP 5/6 (fix+green) |
| `/orchestrate` | STEP 4 (test-writer agent), STEP 7 (green) |
| `/improve-arch` | refactor spec → /todo → /orchestrate |
| `/review` | quality gates verify tests for changes |

Direct edits without these commands: not enforced — native checkpoints (`/rewind`) still cover rollback, but TDD = self-discipline.

> E2E Test Discipline and Targeted Test Discipline (both HARD rules) live in `CLAUDE.md` — not restated here.

---

## Output style routing

> Full details: `docs/rules-references/output-styles.md`

- **caveman-distillate** = always active (token economy, applied to everything)
- **humanizer** = final pass on human-facing reports (`/report`, `/docs sync`, `/self-audit`, `/gaps`, `/intent`, `/decompose`)
- They compose: caveman at generation, humanizer at finalization

---

## No Deferral Policy

If you CAN solve a problem — solve it. Do not defer.

**Resolve yourself:** missing dep → install. missing config → create. failing test → fix. needed env var → add to `.env.example`. file needed on server → `ssh`/`scp`. migration needed → generate+run. lint/type errors → fix.

**Ask user ONLY if:** missing creds (not in `.env.production`); business decision (scope/priority/UX); destructive action on shared resources (drop DB, force push, delete prod data).

**Banned:** "you can configure later" / "you may want to add" / "consider adding tests" / "don't forget to". Do it now.

---

## Script Transparency Rule (HARD RULE — applies to every script run by Claude)

Before running ANY script — template-shipped (`bin/`, `.claude/hooks/`, `.claude/skills/*/scripts/`) OR generated for the user OR fetched from a third-party skill — state in plain language:

1. **What it reads** — files, directories, env vars, stdin. Be specific: «scans `.claude/skills/*/SKILL.md`», not «scans the project».
2. **What it writes** — files created/modified, stdout, stderr destinations. If it writes outside the repo (e.g. `~/.claude/`, `/tmp/`) — flag that.
3. **Network access** — yes/no. If yes — to where, why, what data is sent. Network access is a separate explicit action, never bundled.
4. **Expected runtime class** — seconds, tens of seconds, or minutes. Used to decide whether to run sync or in background.
5. **Secrets/PII risk** — does it touch `.env*`, `~/.ssh`, prod database, billing data, customer PII? Flag explicitly and ask before running, even if user authorized the script category.

**Default scope discipline:**
- Targeted scan when the user asked a narrow question (specific file/path).
- Whole-repo scan only when explicitly broad ("audit the project") or when the script's purpose requires it.
- If unsure — ask before going whole-repo.

**Banned mental patterns:**
- «Just running the script to see what it does» — explain first, then run.
- «It's a read-only script, no warning needed» — readers of secrets are still risky. Always disclose what's being read.
- «User authorized this tool earlier» — authorization in one context doesn't extend to next. If scope changed, re-disclose.

**Example disclosure (good):**

```
About to run bin/validate_skills.sh:
  Reads: every .claude/skills/*/SKILL.md (26 files)
  Writes: stdout only (no files modified)
  Network: no
  Runtime: <2 seconds
  Secrets: none touched
```

**Example disclosure (bad):**

```
Running validation...   ← no info, opaque
```

This rule exists because LLM agents have escalated permissions during a session — disclosure is the user's only defense against silent side effects.

---

## Output Locality Discipline (HARD RULE — durable output lives inside the project folder)

> The user works across many parallel projects from the file system, session to session, without
> holding tech state in memory. If a result isn't sitting inside the project folder, it does not
> exist for them next time — they will never think to check `/private/tmp/...` or a claude.ai URL
> from three sessions ago.

**Rule:** every durable output — report, spec, audit result, exported data, generated doc — is
written under the project's own directory tree (`docs/`, `docs/reports/`, `docs/specs/`, etc.),
never left ONLY in a system scratch path or an external hosted link.

**Scratchpad (`/private/tmp/claude-.../scratchpad` or similar) is for true intermediates only** —
working files inside one turn/task that get thrown away (a temp script, an intermediate diff, a
one-off backup copy). The moment the output is something the user might want to read after this
session ends, write it into the project folder before finishing. Never let scratchpad hold the
ONLY copy of a result.

**Artifact tool (published claude.ai links) — opt-in only, never a default.** Publishing creates a
URL outside the project, outside git, outside anything `grep`/`ls` can find later. Use it ONLY
when the user explicitly asks for a shareable/visual page. Default format for reports/analysis is
a file written into `docs/` — found the same way as everything else: inside the folder.

**Banned patterns:**
- Writing a report/analysis ONLY to `/tmp` or `/private/tmp/...` with no project-folder copy
- Calling the Artifact tool "to make it look nice" when the user didn't ask for a shareable link
- Leaving a generated file's only copy in a path the user would never think to `cd` into

---

## Git Push Hygiene (HARD RULE — what never goes into a commit)

> Cross-project audit (2026-07-24): a 130MB `commercial-backend-master.zip` (a foreign
> company's entire codebase, copied in for reference) sat committed in one repo; an
> uncompressed copy of the same thing — complete with its own `secrets/` folder — sat
> UNCOMMITTED but present in another repo's working tree, one careless broad `git add`
> away from landing in history forever. Several repos also had `.claude/session-log/`
> (session transcripts) and `.claude/worktrees/` (agent scratch state) committed despite
> `.gitignore` already listing them — because `.gitignore` only stops NEW files, it does
> nothing for files already tracked (needs `git rm --cached`, checked separately).

**Never commit:**
- **Build output / dependency dirs** — `node_modules/`, `dist/`, `build/`, `.next/`,
  `__pycache__/`, `.venv/` — regenerable, and `.gitignore` already covers the common ones.
  If a new build tool isn't covered, add its output dir to `.gitignore` before the first
  build, not after the first commit.
- **Log files** — `*.log`, debug dumps, test-run output. If a log has diagnostic value
  worth keeping, summarize the finding into `docs/FAILS.md`, don't commit the raw log.
- **Ad-hoc screenshots** — a screenshot taken to show the user something, or to compare
  before/after, is scratch material. It belongs in the scratchpad / a gitignored local
  folder, not loose in the repo root or `docs/`. If a screenshot is genuinely a durable
  asset (a docs illustration, a design reference), it goes through the normal review path
  like any other asset, not a silent drop-in.
- **Vendored / foreign full-repo copies** — a zip, tarball, or extracted source tree of
  someone else's entire codebase, copied in "for reference." This is exactly how a
  third party's `secrets/` folder ends up inside YOUR repo. If external reference material
  is genuinely needed: keep it OUTSIDE the project directory entirely, or as a proper git
  submodule with its own access boundary — never a flat copy inside the tree you commit from.

**Before adding a new file type to a project — ask: does this regenerate, or is it a
one-time human-facing artifact?** Regenerable → gitignore it, never commit. Durable and
meant to be read by others → commit deliberately, don't let it arrive as a side effect of
`git add -A` (already banned by hook R7 — this rule explains WHY, not just that it's blocked).

---

## Session Scoping (context window discipline)

### Context Budget

Track via `/context`:
- **~60%**: write `docs/handoff.md`, run `/compact`
- **~80%**: finish current task only, then `/clear`
- **Never** wait for auto-compact at 95% (quality already degraded)

**Activity counters** (secondary):
| Metric | Warning | Hard limit |
|---|---|---|
| Tasks completed | 3-4 | 5 |
| File reads | 10 | 12 |
| Tool calls | 25 | 30 |

At warning: do NOT start new task. Finish, commit, handoff.
At hard limit: save state, compact.
Mid-task: `[WIP]` commit, handoff, compact, continue.

### Surviving compaction
1. Write `docs/handoff.md` BEFORE context critical
2. `/compact`
3. Next turn reads handoff (it's in Session Start), resumes
4. Delete `handoff.md` after pickup

`.claude/hooks/pre-compact-snapshot.sh` dumps transcript to `.claude/session-log/compact-*.jsonl` as fallback. Async — not a substitute for writing handoff yourself.

### Session Start (and after compaction)
1. Read-list (handoff FIRST → TASK.md → RULES.md → `/mcp` review) + load-on-demand docs: canon in `CLAUDE.md` § Session Memory — follow it, don't re-derive.
2. **Post-compaction sanity check**: verify summary captured user's last message. If question NOT answered in summary — STOP, tell user "Твоє останнє запитання не потрапило в summary. Повтори, будь ласка." Don't proceed until answered.
3. Announce: "Session scope: T-NNN, T-NNN, T-NNN (X tasks)"

### Exit Signals (trigger Handoff)
"на сьогодні все" / "на сегодня все" / "done for today" / "закриваю" / "стоп" / "stop" / "хватит"

### Session-End Learning Review (before handoff)
Non-obvious fix → `docs/FAILS.md`. Reusable pattern → `docs/PATTERNS.md`. Architecture decision → `docs/KNOWLEDGE.md`.

### Handoff template
Write to `docs/handoff.md`:
- Completed: `- T-NNN: <title> — done, committed`
- In Progress: `- T-NNN: <title> — <state>` + uncommitted files list
- Next Session Should: 3 numbered items
- Context That Would Be Lost: non-obvious decisions, gotchas, blockers
- User's Last Unanswered Question: exact quote (CRITICAL for post-compact resume)
- Open Questions for User

Commit: `git commit -m "[HANDOFF] Session end: <summary>"`. Report: "Session done. X tasks. Handoff in `docs/handoff.md`."

---

## Research Protocol

When unsure about implementation/API/library/best-practice:
1. Search Outline KB first — `mcp__outline__list_documents` (Fails + Best Practices); then local `docs/KNOWLEDGE.md`, `docs/PATTERNS.md`, `docs/FAILS.md` (offline fallback)
2. Context7 MCP (`mcp__context7__*`) for lib/framework docs
3. Tavily / WebSearch for broader (API changes, known issues)

Never guess when official docs exist.

---

## Stuck Protocol (2+ failed attempts)

After 2 fails on same problem — STOP brute-forcing.

1. Stop and analyze: write what you tried + why it failed
2. Search Outline KB (`mcp__outline__list_documents`) + `docs/FAILS.md` for similar pattern
3. Research via Context7 / WebSearch
4. Try fundamentally different strategy, not variation
5. Still stuck after 3rd attempt: tell user honestly — what you tried (3 approaches), root cause hypothesis, suggested next step (manual debug, dep upgrade, different lib). Ask guidance.

**NEVER:** retry same approach hoping different result; silently modify unrelated code; "it should work now" without verifying.

---

## Pre-Change Protocol

### Step 1 — Insurance: native checkpoints; [BACKUP] only where they don't reach

**Ordinary file edits (Edit/Write) are insured by Claude Code native checkpoints** — automatic on every prompt, restorable via `/rewind`, retained 30 days. No [BACKUP] commit is required before editing files; the old hook gate (R1) is removed.

**A `[BACKUP]` commit IS mandatory ONLY before operations checkpoints do NOT cover:**
- DB migrations (schema or data)
- mass bash edits / scripts rewriting many files (`sed -i`, codemods, generators)
- `rm` / file deletion or moves
- deploy scripts / anything mutating servers

```bash
git add <specific files> && git commit -m "[BACKUP] Pre-change: <description> | Risks: <list> | Scope: <files>"
```
**Never `git add -A`** — can stage `.env.production` or unrelated. List specific files.

`[CHANGE]` commits and the commit taxonomy below are UNCHANGED.

### Step 2 — Implement
Make changes per rules.

### Step 3 — Quality Gate (every commit, Tier 1)
Adapt to stack:
- Python: `uv run ruff check . && mypy src/ --ignore-missing-imports`
- TS: `npx tsc --noEmit && npx eslint src/`
- Tests: `pytest tests/ -q` or `npm test`
- Debug artifacts: `grep -rn "console\.log\|debugger\|TODO\|FIXME\|print(" src/`

Tier 2 (deeper, pre-merge only): vulture + pylint duplicate-code. See `/review` STEP 4.8 + `docs/rules-references/static-analysis-tier2.md`. Don't run on every commit (false-positive triage cost).

### Step 4 — DA Review
Invoke `Diablo` agent. Verdict goes in CHANGE commit message.

### Step 5 — CHANGE Commit
```
[CHANGE] T-NNN: <imperative description>

What changed: <bullets>
Why: <requirement from spec AC>
Risk mitigation: <how risk addressed>
DA verdict: <verdict — canon enum + Next-step semantics: .claude/agents/diablo.md>
Tested by: <command>
```

Any [BACKUP] commit stays in history. Do NOT use `--amend` (Claude Code prohibits).

---

## Commit message taxonomy (HARD RULE)

Every commit MUST start with one of:

| Prefix | When | Example |
|---|---|---|
| `[BACKUP]` | Pre-change checkpoint | `[BACKUP] Pre-change: T-005 \| Risks: ... \| Scope: app/bot/` |
| `[CHANGE]` | Implementation paired with prior `[BACKUP]` | `[CHANGE] T-005: Telegram bot bridge` |
| `[FIX]` | Bug fix via `/fix` (failing-test-first) | `[FIX] F-007: bcrypt corruption from env_file mount` |
| `[SEC]` | Security fix verified by Rex | `[SEC] xlsx zip-bomb size cap + magic bytes` |
| `[META]` | TASK.md, archive, planning (no code) | `[META] T-018 archived` |
| `[PROCESS]` | Workflow/hooks/settings/template | `[PROCESS] Add commit-msg validation hook` |
| `[HANDOFF]` | Session-end handoff doc | `[HANDOFF] Session end — 3 tasks done` |
| `[RULES]` | Business rule via `/rule` | `[RULES] Add R-014: senior coach 1500 UAH/training` |

PreToolUse hook on `Bash` matcher blocks `git commit -m` when message lacks valid prefix.

---

## Bug fix triggers (HARD RULE — Claude must invoke `/fix`, not edit directly)

> Bypassing `/fix` causes: no failing test, no FAILS.md entry, no anti-regression, no Diablo on diagnosis.

User message contains (case-insensitive): "fix" / "bug" / "broken" / "doesn't work" / "сломано" / "не работает" / "падает" / "ошибка" / "regression" / "broke after" / "почему X не Y" / direct error reports (traceback, stack trace, exception class).

Claude MUST:
1. STOP. No code edits.
2. Reply: "This looks like a bug fix. Use `/fix` for failing-test-first + Diablo + FAILS.md. Run `/fix <bug>` to start. Skip protocol only for trivial typo if you say so explicitly."
3. Wait for direction.

Override (rare): "skip /fix, just fix typo on line N" → proceed inline.

---

## Bug Fix Protocol (mandatory)

1. Search Outline `Knowledge Base / Fails` FIRST — `mcp__outline__list_documents` (query = bug keywords, `collectionId` = `outline.shared_kb_id`). `docs/FAILS.md` = offline fallback if MCP unavailable
2. `[BACKUP]` commit
3. Write failing test FIRST — don't touch impl until test exists
4. Run test → red phase
5. Root cause analysis — exact cause, list 2-3 options
6. Fix + quality gate
7. Run test → green phase
8. **Same bug elsewhere?** — search codebase for same pattern. Fix ALL occurrences now.
9. DA review
10. `[CHANGE]` commit
11. If non-obvious fix → add lesson file `docs/fails/F-NNN-<slug>.md` + index line in `docs/FAILS.md` (grep index first — update existing lesson instead of duplicating; see § Memory System)
12. If deploying — follow `docs/DEPLOY.md`, verify services after

---

## Deploy Protocol

Before deploy — read `docs/DEPLOY.md`. All server config there.

**Rules:**
1. SSH: use ALIAS from `docs/DEPLOY.md` (e.g. `ssh vps3`). Never raw IP.
2. Secrets: `scp .env.production <alias>:<path>/.env`. Never ask user to manually edit on server.
3. API keys: provided once → in `.env.production`. Never ask again. Missing → tell user which key, ask to add to local `.env.production`.
4. Flow: follow exact steps in `docs/DEPLOY.md`. Don't improvise.
5. Verify: check services running after deploy.
6. Never edit code on server. Local edit → commit → push → server pull. Runtime config (`.env`) excepted.

**Secrets:** live in local `.env.production` (gitignored). Never commit. Never print/log values. Never store in `docs/` or memory files. Missing `.env.production` → create from `.env.example`, ask user to fill values ONCE.

---

## Database Protection Protocol (HARD RULE — universal, every project)

> F-161 (OSINT, 2026-07-16): integration tests run from the prod image inherited a prod DB
> URL; the test teardown dropped prod's entire schema. Daily backups had been silently dead
> for 8 weeks (the staleness alert lived in the same dead worker), the restore drill had
> been blocked since May, and a 🔴 backup task sat 7 days while features shipped. Week of
> data lost. Every rule below exists because one of those layers failed.

1. **Tests never touch prod.** Integration/e2e tests run ONLY against a DB whose name
   contains `test`. Any test invocation inside a container must pass an explicit
   `TEST_*_URL=…test…` in the same command — containers inherit the image's PROD env.
   Enforced client-side by hooks R11/R12 (dispatch.py); string-matching is best-effort,
   so ALSO enforce server-side: a dedicated test DB role with NO CONNECT grant on the
   prod database (the only wall that cannot be bypassed by a forgotten env var).

2. **No migration without a verified backup.** `/deploy` STEP 4.7 (HARD STOP): newest
   backup must be fresher than `backup_max_age_hours` (default 24) AND a pre-migration
   dump is taken with a size sanity check (non-empty, not shrunk >30% vs previous).
   `backup_check_cmd` empty while migrations pending = ABORT — unknown is not ok.

3. **The watchdog lives OUTSIDE the monitored runtime.** A backup-staleness alert must
   run from an independent scheduler (host cron, launchd, healthchecks.io dead-man ping) —
   NEVER as a task inside the same worker/beat that runs the backups. In F-161 the alerter
   died with the thing it monitored and stayed silent for 8 weeks.

4. **A backup that was never restored is a hypothesis, not a backup.** Restore drill on a
   schedule (e.g. monthly via /loop, per RUNBOOK). "Drill blocked" (quota, tier limit,
   missing access) is an INCIDENT-severity finding that must surface in /report and
   /triage — not a RUNBOOK footnote. Include the bandwidth/RTO math: caps × WAL volume
   decide whether restore takes hours or days.

5. **🔴 OPS tasks about backup/restore block feature work.** /orchestrate must pick a red
   backup/restore task FIRST and refuse new feature tasks while it is open. In F-161 the
   "daily backup dead, RPO violated" task idled 7 days; had it been fixed, recovery would
   have lost hours, not a week.

6. **Volume destruction is gated.** `docker compose down -v` / `docker volume rm|prune`
   erase databases with zero SQL in the command — blocked by hook R12 locally and inside
   ssh payloads. Bypass only with explicit user approval (`CLAUDE_ALLOW_DESTRUCTIVE=1`).

---

## Memory System

- Architecture decisions: `docs/KNOWLEDGE.md`
- Active tasks: `docs/TASK.md`
- Failure patterns: one file per lesson in `docs/fails/F-NNN-<slug>.md` + one index line in `docs/FAILS.md` (after non-obvious fix)
- Established solutions: one file per pattern in `docs/patterns/P-NNN-<slug>.md` + one index line in `docs/PATTERNS.md` (on recurring solved)
- Deploy config: `docs/DEPLOY.md`
- Never duplicate info already in git history or code comments

**File-per-lesson format (HARD RULE):**
- Lesson file starts with `# F-NNN: <one-line summary — symptom → cause>` then `date: YYYY-MM-DD` then the body (symptom / root cause / fix / detection). Index line: `- [F-NNN](fails/F-NNN-slug.md) — <same one-line summary>`. Same scheme for `P-NNN` patterns.
- **Grep the index FIRST.** Before creating a new lesson: grep `docs/FAILS.md` / `docs/PATTERNS.md` for the same cause/problem. Similar lesson exists → UPDATE its file (and its index summary if it changed), do NOT create a duplicate. Next free NNN = max across lesson-dir file names AND index lines.
- **Disproven lesson = delete.** A lesson proven wrong is removed — file AND index line together. Wrong memory is worse than no memory. (No archive step needed: files are small; just keep the index sorted by number.)
- Consistency enforced by `bin/memory-lint.sh` (read-only: duplicate IDs, placeholders, orphan files/index lines; legacy single-file format also checked pre-migration). Run it after touching memory files; CI-safe (exit 1 on violations).

---

## PRD Traceability Protocol (HARD RULE — universal; the answer to «после PRD и декомпозиции на выходе непонятно что»)

> Tanchiki lesson (2026-07): PRD reviewed repeatedly, yet sound/mouse/lives/leaderboard-UI all
> evaporated — each at a different stage, invisibly, because reviews re-read the document
> instead of diffing document-vs-build. Three rules close the three leaks:

1. **Trace matrix is mandatory** (`docs/prd/PRD-NNN-trace.md`, built by /decompose STEP 5.5 at
   ATOMIC granularity — composite PRD lines split). Every requirement is `mapped` / `post-MVP`
   / `dropped:<reason>`. No blank rows. A "PRD review" that doesn't walk this matrix against
   the live build is banned — re-reading prose finds nothing.

2. **Deferral escrow.** A task may NOT be marked done/archived while its spec, §11 notes, or
   archive entry contains a deferral («скоро», «потом», "deferred", "not wired", "placeholder",
   "promote via /todo add") WITHOUT a registered follow-up `T-NNN` written next to it. An
   honest note about a cut is not enough — the note dies in the archive; only a registered
   task survives. /orchestrate STEP 9 enforces; self-audit flags violations.

3. **Scope pivots patch the PRD.** When the owner changes course (feature reverted, scope
   genericized), the SAME change must: bump PRD version + add a changelog line (or stamp the
   section `superseded by ADR-NNNN`) + update the trace-matrix row. Otherwise every future
   review audits fiction. An owner decision recorded only in a task archive is a lost decision.

Audit loop: `/gaps vs-prd` — walks the matrix against the live build, reports «promised but
absent». Run before releases and whenever the owner feels «на выходе не то, что заказывал».

---

## Task Completion (mandatory)

When marking task done:
1. **Deferral escrow check (PRD Traceability Protocol #2):** grep the spec + your archive note
   for deferral language; each hit must carry a registered follow-up T-NNN. No T-NNN → the
   task is NOT done: register the follow-up first (or get an explicit owner post-MVP/dropped
   decision into the trace matrix).
2. Remove from TASK.md Backlog/In Progress
3. Append to `docs/archive/TASK_ARCHIVE.md` with commit hash
4. If the task maps to a PRD requirement — update its row in `docs/prd/PRD-NNN-trace.md`
5. Close GitHub issue: `gh issue close <number> --comment "Done in <commit>"` (find via `gh issue list --search "T-NNN" --state open`)

### UI Task Completion Gate (ADDITIONAL — frontend tasks only)

Before marking a frontend task done, verify ALL of the following:

**Field coverage check** — open the spec's `## 13. UI Coverage Matrix` and confirm:
- Every "In scope" row is visibly present in the rendered UI
- Every "Deferred" row has a real T-NNN that exists in TASK.md
- No row is blank or marked "TBD"

**Missing states** — for every `useQuery` or data-fetch in the task scope:
- [ ] Loading state renders (spinner/skeleton — not blank)
- [ ] Empty state renders (message + action — not blank)
- [ ] Error state renders (user-readable, not "undefined")

**PRD flow check** — read the relevant PRD user flow (§10 or similar):
- [ ] Count the clicks from page load to main action complete
- [ ] Must be ≤ stated AC (default: ≤ 5 clicks)

**Playwright spec** — `tests/e2e/<feature>.spec.ts` must exist and pass.

If ANY checkbox is unchecked → task is NOT done. Create follow-up T-NNN tasks for unimplemented fields before archiving the parent.

**Anti-pattern this prevents:** "T-023 Plan creation form UI ✓ done" when the form is missing countries, content sliders, and events entry — those are separate unreported gaps, not implicit deferrals.

---

## Confidence Check

Before finishing non-trivial implementation: code compiles/type-checks? test passes? edge cases considered? debug code left? If any NO — fix before presenting.

---

## Token Economy Rules

> Canon: `docs/rules-references/token-economy.md` — confidence gate (<70% Plan Mode / 95%+ code), proactive compaction, terminal-output hygiene, MCP hygiene (~17K tokens/server/message), model selection (tier up/down rules, Haiku ban, subagents 7-10×), prompt-cache awareness.
> Hard digest lives in `CLAUDE.md` § Token Economy. Do not restate the rules here — read the canon.
