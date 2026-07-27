---
name: plan-devex-review
description: 'Developer Experience review for APIs, CLIs, SDKs, internal tools. Interactive — explores devs personas, benchmarks competitors, traces friction step-by-step. Run BEFORE coding (on PRD/spec) AND AFTER shipping. Three modes: DX_EXPANSION (greenfield), DX_POLISH (mature), DX_TRIAGE (broken).'
argument-hint: <PRD-NNN | docs/specs/T-NNN | live URL/CLI to audit> [--mode expansion|polish|triage]
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion, WebFetch, WebSearch, Glob, Grep
model: opus
---

> **Style:** Load `caveman-distillate` skill — terse, evidence-first.

# /plan-devex-review — Developer Experience review

Inputs:
- `<target>` — PRD-NNN file, T-NNN spec, OR live URL / CLI binary path to audit (post-ship mode)
- `--mode expansion|polish|triage` — auto-detected if absent

Use this when target audience = **other developers** (API, CLI, SDK, internal tool, library, framework). NOT for end-user products (use `/plan-design-review` or `/design-review` for those).

---

## STEP 0 — Detect mode

If `--mode` provided → use that. Otherwise auto-detect:

| Signal | Mode |
|---|---|
| Greenfield (PRD draft, no implementation, no public docs) | **DX_EXPANSION** — design the magical first experience |
| Implementation exists, has docs, has users, want to improve | **DX_POLISH** — measure baseline, find friction |
| Live tool with users complaining about onboarding/setup time | **DX_TRIAGE** — fast triage, fix top 3 issues |

Confirm with user via `AskUserQuestion`:
> "Detected mode: <X>. Continue or override? [expansion / polish / triage]"

## STEP 1 — Persona extraction (мind-shift to USER's perspective)

If target = PRD or spec → extract intended user from PRD §2 or spec section 1.
If target = live tool → ask: "Who's the primary developer using this? Junior backend / Senior frontend / DevOps SRE / Data scientist? Pick one."

For chosen persona, capture:
- **Skill level**: какой baseline они умеют?
- **Time budget**: сколько у них есть на твой tool — 5 минут exploration, 1 час setup, или day-long deep dive?
- **Stack context**: что у них уже стоит? Python+FastAPI, Node+Next.js, etc?
- **Failure mode**: что они сделают если столкнутся с rough edge — открыть issue, написать workaround, или забросить?

This persona drives ALL subsequent questions.

## STEP 2 — Competitor benchmark (if applicable)

If target competes with existing tools — pick 2-3 closest competitors:
- Run their getting-started flow (or read their docs).
- Time each step.
- Capture: «Time to Hello World» (TTHW) — sec from `npm install` / `pip install` / `git clone` to first observable output.

| Competitor | TTHW | Friction points |
|---|---|---|
| <name 1> | 30s | Requires API key signup |
| <name 2> | 4 min | Docker pull + config edit |
| <name 3> | 90s | Just `npx <thing>` |

Your tool must beat or tie best-in-class TTHW unless explicit reason otherwise.

If no competitors — skip with note. But: «no competitors» often means «no demand» — flag.

## STEP 3 — Magical moment design (mode-specific)

### DX_EXPANSION mode

Starting from blank — design the **magical moment** when developer realizes «this works».

For each persona stage:
1. **Discovery**: how do they find the tool? (npm search, GitHub trending, blog, recommendation)
2. **First copy-paste**: what's the README block they paste first?
3. **First success**: what's the observable outcome that says «I get it»?
4. **First failure**: when does friction first surface? Is the error message helpful?

Design the **README hero** — the single code block that delivers magical moment in <60 seconds.

Forcing questions (one per AskUserQuestion):
- "What's the ONE command that gets them to first observable result?"
- "What's the most likely first error? What does the error message say?"
- "Is there a config file required before first command? Is it magical-defaults or required?"
- "What gets logged on first run? Is it noise or signal?"

### DX_POLISH mode

Implementation exists. Audit existing onboarding for friction:

1. Open the README. Read it as if you've never seen the tool.
2. Try to follow it exactly. Time each step. Note where you got stuck.
3. Check the error messages — are they actionable («Cannot find DATABASE_URL — add to .env (template at .env.example)») or cryptic («ConnectionError»)?
4. Read 5 most recent open issues. Pattern-spot: same friction repeated?

Forcing questions:
- "What do new users hit first that wasn't in plan?"
- "Where do experienced users complain on issue tracker?"
- "What docs are stale relative to current behavior?"
- "What error message has 0 actionable info?"

### DX_TRIAGE mode

Live tool, users complaining. 3-issue triage:

1. **Top issue** — what's blocking the most users RIGHT NOW? Fix #1 priority.
2. **Frequent friction** — what wastes 5+ minutes per user every onboarding?
3. **Confidence killer** — what makes new users abandon and not return?

Forcing questions:
- "If we could fix ONE thing this week, which is highest leverage?"
- "If user got past current friction, would they reach magical moment? Or is there 2nd wall?"
- "What's reversible (easy fix) vs structural (architecture)?"

## STEP 4 — Friction trace (line-by-line)

For each step a developer takes:
- Time it (or estimate).
- Note **decision points** (where they have to choose without context).
- Note **failure modes** (where they hit error).
- Note **assumed knowledge** (what user must know that's NOT in docs).

Output table:

| Step | Action | Time | Decision/Friction |
|---|---|---|---|
| 1 | `npm install` | 8s | None |
| 2 | Read README hero block | 90s | Has to read 6 paragraphs to find it |
| 3 | Copy-paste hero block | 5s | None |
| 4 | Edit `config.yaml` | 5 min | Decision: which database driver? Docs don't recommend. |
| 5 | Run `mytool init` | 3s | Cryptic error: «Connection refused» (no hint about DATABASE_URL) |

Aggregate: **Time to Hello World = X seconds/minutes**. Compare to STEP 2 benchmark.

## STEP 5 — Score per dimension (0-10 with what 10 looks like)

For DX, 7 dimensions:

| Dimension | Question | Score 0-10 | What 10 looks like |
|---|---|---|---|
| Install simplicity | How many commands to install? | | Single `npx` / `pip install` |
| Time to Hello World | Sec to first observable result | | < 30s for non-interactive tool |
| Error message quality | Actionable per error | | Every error: what + why + fix command |
| Documentation depth | Hero example + edge cases | | Hero + 3 example use cases + API ref |
| Reversibility | Can dev uninstall cleanly? | | `<tool> uninstall` reverses everything |
| Composability | Works with existing stacks? | | Plays nice with Python+venv, Node+npm, Docker |
| Recovery from misuse | Bad config = clear path forward | | Validation + suggestion at command time |

User confirms each score → for each dimension below 7, generate edit list to reach 10.

## STEP 6 — Action plan (write to PRD/spec)

If target = PRD/spec → edit it directly. Add section **«13. DX requirements»**:

```markdown
## 13. DX requirements (from /plan-devex-review)

**Persona**: <chosen>
**Time to Hello World target**: <Xs>
**Magical moment**: <one-line description>

### Required for V1
- F-DX-01: README hero block delivers magical moment in <30s
- F-DX-02: Every error message includes (a) what failed, (b) why, (c) command to fix
- F-DX-03: First-run validation surfaces missing config with .env.example reference
- F-DX-04: Single install command (no multi-step setup)

### Nice to have V2
- F-DX-05: ...
```

If target = live tool → write to `docs/dx-audit/<DATE>.md` with all findings + score table + edit list.

## STEP 7 — Diablo gate

Invoke `/da spec docs/dx-audit/<date>.md` (or PRD if updated).

Diablo attacks:
- Are DX requirements measurable? («good DX» banned)
- Time-to-Hello-World target realistic vs current state?
- Error message rule actionable or wishful?
- Persona is real (concrete dev type) or strawman?

If `BLOCKED` → revise DX requirements.

## STEP 8 — Auto-publish

If MCP outline available:
```
ToolSearch select:mcp__outline__create_document

mcp__outline__create_document
  title: "DX Audit <date>: <target>"
  collectionId: <project_collection_id>
  parentDocumentId: <Knowledge sub-page>
  text: <full audit + recommendations>
```

## STEP 9 — Confirm

```
✓ /plan-devex-review complete
Mode: <X>
Persona: <chosen>
TTHW (current): <Xs / not measurable>
TTHW (target): <Ys>
DX dimensions scored: 7
Below 7: <list>
Action items added to: <PRD/spec/dx-audit file>
Outline: <url or skipped>
Diablo: <verdict>
```

---

## Hard rules

- NEVER score «good DX» without 7-dimension breakdown
- Persona must be ONE concrete role with skill level — not «developers in general»
- TTHW must be measurable in seconds — not «pretty fast»
- Error message standard: «what + why + fix» — generic «error: invalid input» = SERIOUS finding
- DX_EXPANSION outputs requirements (forward-looking). DX_POLISH outputs friction list (current state). DX_TRIAGE outputs top-3 fix list (urgent). Don't conflate modes.
- If used on PRD that already has §13 DX requirements — re-audit, mark «v2» on each requirement that changes; never silently overwrite v1 commitments
