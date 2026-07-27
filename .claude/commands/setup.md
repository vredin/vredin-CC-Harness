---
name: setup
description: 'Template setup wizard — fresh install, MCP reconfigure, health check, or v2→v3 migration. Idempotent. Run from template root or initialized project.'
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
---

> **Style:** Load `caveman-distillate` skill — terse responses.

# Setup Wizard

Single entry point for template configuration. Detects state and routes.

---

## STEP 1 — Detect current state

```bash
# Marker file written on first successful setup
test -f .claude/.setup.json && SETUP_DONE=1 || SETUP_DONE=0

# Check MCP
claude mcp list 2>/dev/null | grep -q outline && MCP_OK=1 || MCP_OK=0

# Check stack docs (three states: filled / placeholder / missing)
if [ ! -f docs/STACK.md ]; then
  STACK_STATE="missing"
elif grep -q '\[PROJECT_NAME\]' docs/STACK.md; then
  STACK_STATE="placeholder"
else
  STACK_STATE="filled"
fi

# Detect if running in template repo or in a derived project
test -f README.md && grep -q "claude-project-template" README.md 2>/dev/null && IS_TEMPLATE=1 || IS_TEMPLATE=0
```

Report state to user:
```
Template setup state:
- Setup marker: [yes/no]
- MCP outline: [connected/not connected]
- STACK.md: [filled/placeholder/missing]
- Running in: [template repo/project copy]
```

---

## STEP 1.5 — Legacy key migration (silent, idempotent)

Before any mode runs, normalize `.claude/.setup.json` so downstream commands find canonical key names. Hand-scaffolded files and older bootstrap scripts may have written legacy variants.

```python
import json, os
path = '.claude/.setup.json'
if not os.path.exists(path):
    pass  # no setup file yet, skip
else:
    with open(path) as f:
        d = json.load(f)
    o = d.get('outline', {})
    renamed = []
    # Rename FROM (legacy)        TO (canonical)
    legacy_map = {
        'shared_kb_collection_id': 'shared_kb_id',
    }
    for legacy, canonical in legacy_map.items():
        if legacy in o and canonical not in o:
            o[canonical] = o.pop(legacy)
            renamed.append(f'{legacy} -> {canonical}')
    if renamed:
        with open(path, 'w') as f:
            json.dump(d, f, indent=2)
            f.write('\n')
        print('[MIGRATED] outline keys:', ', '.join(renamed))
```

If renames happened — print one-line notice to user. If none — silent.

This protects against:
- Hand-scaffolded `.setup.json` with wrong key names (introduced 2026-05-09 during v2→v3 migration of SLUGGER_CRM)
- Future legacy keys (extend `legacy_map` as needed)

---

## STEP 2 — Pick mode (interactive)

Use `AskUserQuestion`:

| Mode | When |
|------|------|
| **Fresh install** | First time on this machine; SETUP_DONE=0 |
| **Reconfigure MCP** | After token rotation; MCP_OK=0 or user says so |
| **Verify health** | Periodic check; everything should be 1 |
| **Bootstrap project collection** | MCP connected but project collection missing in Outline |
| **Setup launchd schedules** | macOS, want any subset of default schedules (/report, /docs sync, /self-audit, /self-audit --global). PRIMARY scheduler — works when Claude session is closed. Linux: see `docs/SCHEDULING.md` (systemd timers). |
| **Communication style** | Toggle plain-language mode (no jargon / no transliterated terms) on an already-set-up project. Runs step 0.2 standalone: ask, write `communication.plain_language`, add/remove the `PLAIN-LANGUAGE-MODE` block in `CLAUDE.md`. |
| **Migrate v2→v3** | Existing project with old template version |

> **Note:** "Register loops" mode was REMOVED in v3.x. `/loop` is session-bound (stops when you `/exit`) and useless for daily/weekly cadence. If user explicitly asks for `/loop` setup — clarify it's for short intra-session work only (e.g., `/loop 5m /babysit-prs`), then route to Setup launchd schedules for persistent schedules.

---

## STEP 3 — Execute

### Fresh install

#### 0. Language preference (FIRST step before anything else)

Use `AskUserQuestion`:
> "Default response language for Claude in this template?"
- "English"
- "Bulgarian (Български)"
- "Ukrainian (Українська)"

Save selection in `.claude/.setup.json`:
```json
{
  "language": "english" | "bulgarian" | "ukrainian"
}
```

Update `CLAUDE.md` line:
```markdown
## Language
Respond in: **<chosen>**
```

This is the default. Per-session override available via prompt («ответь по-английски»). Per-project override: edit `CLAUDE.md` directly.

#### 0.2. Communication style — plain language or standard?

Use `AskUserQuestion`:
> "How should Claude talk to you?"
- "Plain language — no IT jargon, no transliterated English terms, no invented words (for non-technical product owners)" (Recommended)
- "Standard — technical terms OK"

Save selection in `.claude/.setup.json`:
```json
{
  "communication": { "plain_language": true | false }
}
```

**Apply to CLAUDE.md** (this is what actually enforces it — the flag alone does nothing):
- The template `CLAUDE.md` ships with a `PLAIN-LANGUAGE-MODE` block inside `## Communication Style`, marked by `<!-- PLAIN-LANGUAGE-MODE:ON ... -->` … `<!-- /PLAIN-LANGUAGE-MODE -->`.
- **If "Plain language" chosen** → ensure the block is present and the marker says `:ON`. If the block is missing (older project), insert it (copy from template `CLAUDE.md`).
- **If "Standard" chosen** → delete the whole block (from the opening marker to the closing marker) so standard technical wording is allowed.

What the block enforces when ON: no English terms spelled in Cyrillic («фан-аут», «коммит»), no made-up words, unavoidable technical terms get a one-line plain explanation in parentheses. It does NOT add verbosity — caveman terseness still applies.

#### 0.5. External knowledge base — Outline, GitHub, or local-only?

Use `AskUserQuestion`:
> "Where should Claude store shared knowledge (fails, patterns, best practices)?"
- "Outline (cloud) — I have your-outline.example.com or my own Outline instance"
- "GitHub — a dedicated repo, read/write via plain git (no separate service, no MCP)"
- "Local only — use vault at ~/PycharmProjects/Obsidian/ (no cloud, no MCP)"

**If "GitHub" selected:**

1. Ask (plain text, not AskUserQuestion — needs a name): "Repo for the shared knowledge base
   — `owner/name`? (I'll create it via `gh repo create` if it doesn't exist yet.)" Suggest a
   default: `<gh api user --jq .login>/claude-knowledge-base`.
2. Check reachability:
   ```bash
   gh repo view "<owner/name>" >/dev/null 2>&1 && echo "EXISTS" || echo "MISSING"
   ```
   - `EXISTS` → confirm with user this is the right repo, continue.
   - `MISSING` → ask visibility (private/internal recommended — this holds fails/patterns
     that may reference internal specifics), then:
     ```bash
     gh repo create "<owner/name>" --private --description "Shared Claude Code knowledge base (Fails/Best Practices/Tricks/Daily Status) — see docs/OUTLINE-CONTRACT.md § Backend"
     ```
3. Clone into the cache dir (default `~/.claude/kb-github-cache`, ask if user wants a
   different path):
   ```bash
   bash bin/github-kb.sh sync   # env GITHUB_KB_REPO / GITHUB_KB_CACHE_DIR set from step 1-3 answers
   ```
   Confirm it worked: `OK: <cache dir> synced with <repo>`. If it fails — check `gh auth status`, retry.
4. Write `.claude/.setup.json`:
   ```json
   {
     "outline": {
       "enabled": true,
       "mode": "github",
       "github_repo": "<owner/name>",
       "github_cache_dir": "~/.claude/kb-github-cache",
       "auto_publish": {
         "fix_to_kb_fails": true,
         "rule_to_project_rules": true,
         "improve_arch_to_decisions": true,
         "improve_arch_patterns_to_kb": true,
         "report_daily_to_kb": true,
         "docs_sync_to_project": true,
         "general_final_save": "ask",
         "council_verdict_to_kb": "ask"
       }
     }
   }
   ```
   (`rule_to_project_rules` / `improve_arch_to_decisions` / `docs_sync_to_project` are no-ops
   in github mode per `docs/OUTLINE-CONTRACT.md` § Backend — flags stay for schema parity
   with cloud mode, harmless to leave `true`.)
5. Report:
   ```
   ✅ GitHub knowledge-base mode configured.

   Shared KB repo:  <owner/name>
   Local cache:     ~/.claude/kb-github-cache
   /fix, /report, /improve-arch (reusable patterns) will read/write there via bin/github-kb.sh.
   Project-level docs (Rules, ADRs, Architecture) publish nowhere extra — this project's own
   docs/*.md IS the publication once you push it.

   No Outline MCP needed.
   ```
6. **Skip steps 1–5 of the Outline branch below entirely.** Jump to step 6 (Register
   persistent schedules) and then step 7 (Write .setup.json — merge, don't overwrite what
   step 4 above already wrote).

**If "Local only" selected:**

Write `.claude/.setup.json`:
```json
{
  "outline": {
    "enabled": false,
    "mode": "local",
    "local_vault_path": "~/PycharmProjects/Obsidian",
    "auto_publish": {
      "fix_to_kb_fails": false,
      "rule_to_project_rules": false,
      "improve_arch_to_decisions": false,
      "improve_arch_patterns_to_kb": false,
      "report_daily_to_kb": false,
      "docs_sync_to_project": false,
      "general_final_save": false,
      "council_verdict_to_kb": false
    }
  }
}
```

Report to user:
```
✅ Local-only mode configured.

Knowledge stored in:
  ~/PycharmProjects/Obsidian/fails/     ← /fix writes F-NNN here
  ~/PycharmProjects/Obsidian/patterns/  ← /review, /improve-arch write here
  ~/PycharmProjects/Obsidian/gotchas/   ← /general writes here
  docs/RULES.md                         ← /rule always writes here
  docs/adr/                             ← /improve-arch always writes here

Outline MCP is NOT required.
/gaps will search the local vault instead of Outline KB.
```

**Skip steps 1–5 below entirely.** Jump to step 6 (Register persistent schedules) and then step 7 (Write .setup.json).

---

**If "Outline" selected — continue with steps 1–5:**

#### 1. Outline MCP setup — display this exactly to the user, then wait:
   ```
   Open your terminal and run (DO NOT paste your token here in chat):
   
   claude mcp add outline --transport http https://your-outline.example.com/mcp \
     --header "Authorization: Bearer <YOUR_OUTLINE_TOKEN>"
   
   Get/rotate the token at:
   https://your-outline.example.com/settings/api-keys
   
   Reply 'done' when complete.
   ```

2. After user says done — verify:
   ```bash
   claude mcp list | grep -q outline || echo "FAIL: outline not in mcp list"
   ```
   If failed → ask user to check the command output, retry.

3. **Verify Outline reachability** by attempting a tool call:
   - Try `mcp__outline__list_collections` (if available) or `mcp__outline__list_documents` with an empty query.
   - If returns data → `MCP_OUTLINE: ok`
   - If error → instruct user to check token validity and Outline URL; do not proceed.

4. **Confirm shared collection structure** in Outline:
   - Tell user to ensure these collections exist in `your-outline.example.com`:
     - `Knowledge Base` (shared, with sub-pages: Fails, Best Practices, Daily Status, Tricks)
     - `Project: <name>` (one per project; `/init-project` creates one for each new project)
   - Capture the collection IDs (user will run a one-liner via MCP and paste IDs)
   - Save IDs to `.claude/.setup.json`

5. **Write outline config to .setup.json** (Outline mode):
   ```json
   {
     "outline": {
       "enabled": true,
       "mode": "cloud",
       "url": "<outline URL>",
       "shared_kb_id": "<id>",
       "project_collection_id": "<id>",
       "auto_publish": {
         "fix_to_kb_fails": true,
         "rule_to_project_rules": true,
         "improve_arch_to_decisions": true,
         "improve_arch_patterns_to_kb": false,
         "report_daily_to_kb": true,
         "docs_sync_to_project": true,
         "general_final_save": "ask",
         "council_verdict_to_kb": "ask"
       }
     }
   }
   ```

6. **Register persistent schedules** (recommended):
   - Use mode **Setup launchd schedules** (macOS) — see section below.
   - This creates launchd plists in `~/Library/LaunchAgents/` that fire even when Claude session is closed.
   - Do NOT use `/loop` for daily/weekly cadence — `/loop` only fires while a Claude session is open.
   - For Linux: systemd timers (manual setup, see `docs/SCHEDULING.md`). For Windows: Task Scheduler.
   - Skip this step now if you want to set up scheduling later — commands work manually too.

7. **Write .setup.json** (merge with existing):
   ```json
   {
     "version": 3,
     "ts": "<ISO timestamp>",
     "next_steps": [
       "Run /init-project to create a project from this template, OR",
       "Configure docs/STACK.md if working in this repo directly"
     ]
   }
   ```

8. **Report**:
   ```
   ✅ Setup complete (v3)
   Outline MCP: connected
   Next: /init-project <path>  to scaffold a new project
   ```

### Reconfigure MCP

1. Tell user to run in their terminal:
   ```
   claude mcp remove outline
   claude mcp add outline --transport http <OUTLINE_URL>/mcp \
     --header "Authorization: Bearer <NEW_TOKEN>"
   ```
2. Wait for "done", then verify with `claude mcp list | grep outline`.
3. Update `.claude/.setup.json` timestamp.

### Communication style

Run **step 0.2** (above) standalone:
1. Ask the plain-language question via `AskUserQuestion`.
2. Write `communication.plain_language` to `.claude/.setup.json`.
3. Add the `PLAIN-LANGUAGE-MODE` block to `CLAUDE.md` (plain) or delete it (standard) — see step 0.2.
4. Report: `✅ Communication style: plain-language ON | standard`.

### Verify health

First read `.claude/.setup.json` to determine knowledge base mode:
```python
import json
d = json.load(open('.claude/.setup.json')) if os.path.exists('.claude/.setup.json') else {}
outline_enabled = d.get('outline', {}).get('enabled', True)  # default True for legacy configs
outline_mode = d.get('outline', {}).get('mode', 'cloud')
```

Run all checks, report status table:

```
Component                   Status
──────────────────────────────────────
.claude/.setup.json         [ok/missing]
Knowledge base mode         [cloud (Outline) / local-only (vault)]
MCP outline                 [connected / not connected / disabled (local-only mode)]
Outline shared_kb_id        [set / missing / N/A (local-only)]
Outline project collection  [set / missing / N/A (local-only)]
Local vault                 [~/PycharmProjects/Obsidian/ — ok/missing]
docs/STACK.md               [filled/placeholder/missing]
docs/CONTEXT.md             [present/missing]
docs/adr/                   [present/missing]
bin/outline.sh              [executable/missing]
bin/psql_ro.sh              [executable/missing]
jscpd (copy-paste, /review) [installed / missing (npm i -g jscpd)]
complexipy (cognitive, /review) [installed / missing (pip install complexipy)]
.claude/agents/             [N agents]
.claude/commands/           [N commands]
.claude/skills/             [N skills]
.claude/hooks/              [N hooks]
launchd schedules registered  [N plists found / 0 / not macOS]
```

**Outline status rules:**
- `outline.enabled = false` → show as `disabled (local-only mode)` — NOT an error, do NOT suggest connecting
- `outline.enabled = true` (or missing — legacy) AND MCP disconnected → show as `not connected` — IS an error, suggest fix
- Local vault: always check `~/PycharmProjects/Obsidian/` exists regardless of mode

For each missing/broken — print fix command:
- MCP outline disconnected (cloud mode only) → `claude mcp add outline --transport http <URL>/mcp ...`
- Local vault missing (local-only mode) → `mkdir -p ~/PycharmProjects/Obsidian/{fails,patterns,gotchas}`
- Project collection missing (cloud mode only) → "Run `/setup` → Bootstrap project collection"
- launchd schedules absent (macOS) → "Run `/setup` → Setup launchd schedules"
- bin/*.sh not executable → `chmod +x bin/*.sh`
- jscpd missing → `npm i -g jscpd` (enables copy-paste detection in `/review` STEP 2; without it that check silently SKIPs). Detect: `command -v jscpd >/dev/null || npx --no-install jscpd --version >/dev/null 2>&1 || echo "JSCPD_MISSING"`. Non-fatal — `/review` still runs, just without duplication findings.
- complexipy missing → `pip install complexipy` (enables cognitive-complexity detection for Python in `/review` STEP 2). Detect: `command -v complexipy >/dev/null || echo "COMPLEXIPY_MISSING"`. Non-fatal — `/review` still runs, just without cognitive-complexity findings.

### Auto-offer to fix detected issues (mandatory after report)

After printing the status table, if ANY actionable issue is detected, **immediately** call `AskUserQuestion` to offer fixing now without re-running /setup. Don't ask "do you want to fix?" — ask "which fix?":

(Legacy key migration runs automatically in STEP 1.5 before this step — no need to repeat here.)

Build the options list dynamically from detected issues:

| Detected issue | Option label | Action when picked |
|---|---|---|
| `launchd schedules: 0` on macOS | "Setup launchd schedules now" | Jump to Setup launchd schedules section, execute steps 1-11 inline |
| `Project collection: missing` | "Bootstrap project collection now" | Jump to Bootstrap project collection section |
| `bin/*.sh not executable` | "Fix bin permissions" | Run `chmod +x bin/*.sh` |
| `JSCPD_MISSING` | "Install jscpd (copy-paste detector)" | Run `npm i -g jscpd` (network: pulls from npm). Enables `/review` duplication check. |
| `COMPLEXIPY_MISSING` | "Install complexipy (cognitive complexity)" | Run `pip install complexipy` (network: pulls from PyPI). Enables `/review` Python cognitive-complexity check. |
| `docs/STACK.md missing` | "Create docs/STACK.md stub" | Create from template with placeholders for stack/lint_cmd/typecheck_cmd/test_cmd |
| `docs/CONTEXT.md missing` | "Create docs/CONTEXT.md stub" | Create domain glossary stub |
| `docs/adr/ missing` | "Create docs/adr/ directory" | `mkdir docs/adr` |
| `todo-diablo-gate.sh hook NOT registered` | "Register todo-diablo-gate PreToolUse hook" | Edit `.claude/settings.json` to add hook block (see template below) |
| All checks pass | (skip AskUserQuestion, exit clean) | — |

#### Detection: todo-diablo-gate hook registration

```bash
# Hook script must exist and be executable
test -x .claude/hooks/todo-diablo-gate.sh || echo "HOOK_SCRIPT_MISSING"

# Hook must be registered in settings.json hooks.PreToolUse array
grep -q "todo-diablo-gate" .claude/settings.json 2>/dev/null || echo "HOOK_NOT_REGISTERED"
```

If `HOOK_NOT_REGISTERED` — propose adding to `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null); [ -n \"$GIT_ROOT\" ] && bash \"$GIT_ROOT/.claude/hooks/todo-diablo-gate.sh\" || exit 0'"
          }
        ]
      }
    ]
  }
}
```

> **CRITICAL — use git-toplevel-based path, NOT relative `.claude/hooks/...`.** Claude Code runs hooks from cwd at tool invocation time. If Sonnet `cd`'s into a subdirectory (e.g., `frontend/` or `app/`), relative path fails with "No such file or directory". The `GIT_ROOT` resolution finds the script regardless of cwd. Same pattern for ALL hooks (PreCompact, PostToolUse, etc.).

Use `Edit` tool with surgical merge (settings.json is project-customized — never `cp -f`). Read existing settings.json first; if `hooks.PreToolUse` array exists, append to it; if not, create the structure.

Always include "Skip — just report" option as last.

If multiple issues detected, allow `multiSelect: true` so user can fix several at once. Order picks by impact: launchd > collection > docs.

After fix executes — re-run the status table to show resolved state. If still issues remain → offer again. Loop until user picks "Skip — just report" or all green.

**Critical:** This auto-offer is the difference between "/setup told me what's wrong" and "/setup fixed what's wrong". Verify health without auto-offer is a wasted interaction.

### Bootstrap project collection

Use this mode when MCP outline is connected but the project's Outline collection
doesn't yet exist (typical for projects migrated to v3 — `/init-project` creates
collection automatically, migrations don't).

> **CRITICAL — MCP tools are deferred in Claude Code.** Before calling ANY `mcp__outline__*` tool, you MUST first load its schema via `ToolSearch`. Otherwise calls return `InputValidationError: deferred tool`. This applies to ALL MCP tools — outline, context7, etc. The naming `mcp__<server>__<tool>` is the deferred-tool form.
>
> **First step always:**
> ```
> ToolSearch select:mcp__outline__list_collections,mcp__outline__create_collection,mcp__outline__create_document,mcp__outline__update_document,mcp__outline__list_documents
> ```
>
> **Do NOT** interpret `InputValidationError: deferred tool` as «MCP server not registered, restart needed». The server IS registered (verify via `claude mcp list`); the tool just isn't loaded into the active context yet. ToolSearch loads it.
>
> **Do NOT** fall back to `bin/outline.sh` until you've tried ToolSearch loading first. The shell fallback requires `OUTLINE_TOKEN` env var which user typically hasn't exported.

1. Check `.claude/.setup.json` for `outline.project_collection_id`. If present
   and the collection exists in Outline (verify via `mcp__outline__list_collections`
   — load via ToolSearch first per warning above) → already bootstrapped, exit.

2. Read project name (from current directory basename, or `CLAUDE.md` first heading).

3. Read `.claude/.setup.json` for `outline.shared_kb_id`. If missing, ask user
   for the Knowledge Base collection ID (one-time, since shared across all projects).

4. Create the project collection:
   ```
   mcp__outline__create_collection
     name: "Project: <project_name>"
     description: "Project-specific knowledge: architecture, ADRs, business rules, API."
   ```
   Capture returned `id`.

5. Create initial sub-pages (empty stubs):
   - "Architecture" — placeholder for docs/ARCHITECTURE.md mirror
   - "API Reference" — placeholder for docs/API.md mirror
   - "Runbook" — placeholder for docs/RUNBOOK.md mirror
   - "Knowledge" — placeholder for docs/KNOWLEDGE.md mirror
   - "Decisions" — placeholder for ADR-NNN entries
   - "Rules" — placeholder for R-NNN entries
   - "PRDs" — placeholder for PRD-NNN entries (from /intent)
   - "Epics" — placeholder for EPIC-NNN entries (from /decompose)

6. Save IDs to `.claude/.setup.json`:
   ```json
   {
     "outline": {
       "shared_kb_id": "<id>",
       "project_collection_id": "<new id>",
       "auto_publish": {
         "fails_to_shared": true,
         "rules_to_project": true,
         "adrs_to_project": true,
         "reusable_patterns_to_shared": true,
         "daily_status_to_shared": true,
         "docs_sync_to_project": true
       }
     }
   }
   ```
   Default all auto_publish flags to `true`. User can flip individual ones off later.

7. Optionally run `/docs publish` immediately to mirror existing local docs into the
   freshly-created collection.

<!-- "Register loops" mode was removed in v3.x. /loop is session-bound. For daily/weekly cadence use Setup launchd schedules section below. -->



### Setup launchd schedules

Use this mode on macOS when you want any subset of default schedules to run
automatically without relying on Anthropic cloud `/schedule`. Pattern: ONE
generic wrapper `bin/launchd-runner.sh`, multiple plists each invoking it
with a different prompt at a different time.

For full decision matrix see `docs/SCHEDULING.md`.

#### 1. Check OS
If `uname` ≠ Darwin, abort:
```
launchd is macOS-only. For Linux: use systemd timers. For Windows: Task Scheduler.
See docs/SCHEDULING.md alternatives.
```

#### 2. Detect prerequisites
- `which claude` → must return path; abort if not found
- Project root → current pwd or read from `.setup.json`
- User home → `$HOME`
- Templates: `bin/launchd-runner.sh.template`, `templates/launchd-task.plist.template`

#### 3. Render the generic runner (idempotent)
If `bin/launchd-runner.sh` doesn't exist OR contains template placeholders:
- Render `bin/launchd-runner.sh.template` → `bin/launchd-runner.sh`
  - `{{CLAUDE_BIN}}` → resolved claude path
  - `{{PROJECT_PATH}}` → absolute project dir
- `chmod +x bin/launchd-runner.sh`

If runner already exists with concrete values → skip render, reuse.

#### 4. Discover existing schedules
```bash
launchctl list | grep "com.$(whoami).$(basename $(pwd))-" || echo "  none registered"
```
Show user which schedules are already loaded; don't recreate them.

#### 5. Ask user which schedules to register
Use `AskUserQuestion` with `multiSelect: true`:

> Which schedules to register for this project?

Options (each labeled with default time):
1. `/report` daily — default 23:00
2. `/docs sync --publish` weekly Monday — default 09:00
3. `/self-audit` weekly Friday — default 10:00
4. `/self-audit --global` 1st & 15th — default 11:00
5. `/improve security` monthly 1st — default 12:00 (Stage-4 security cycle; requires `improve` skill installed)
6. `/improve deep` quarterly Jan/Apr/Jul/Oct 1st — default 12:30 (expensive, ≤8 subagents — quarterly only)

For each chosen → ask follow-up `AskUserQuestion`:
> Time for `/report`?
- "Default (23:00)"
- "21:00"
- "22:00"
- "Other (specify)"

(Skip follow-up for `/self-audit --global` — bi-weekly time is rarely customized.)

#### 6. For each chosen schedule, render its plist
- Compute label: `com.<whoami>.<project>-<task>` (lowercase, sanitized)
  - `<task>` = `report` / `docs-sync` / `self-audit` / `self-audit-global` / `improve-security` / `improve-deep`
- Build `<CALENDAR_INTERVAL>` XML based on schedule type:
  - **Daily** (e.g. /report): single `<dict>` with `Hour`/`Minute`
  - **Weekly** (e.g. /docs sync Mon, /self-audit Fri): single `<dict>` with `Weekday`/`Hour`/`Minute`
    - Weekday values: Sun=0, Mon=1, Tue=2, Wed=3, Thu=4, Fri=5, Sat=6
  - **Bi-weekly** (e.g. /self-audit --global on 1st & 15th): `<array>` of two `<dict>` entries with `Day`/`Hour`/`Minute`
  - **Monthly** (e.g. /improve security): single `<dict>` with `Day=1`/`Hour`/`Minute`
  - **Quarterly** (e.g. /improve deep): `<array>` of four `<dict>` entries with `Month` 1/4/7/10 + `Day=1`/`Hour`/`Minute`
- Render `templates/launchd-task.plist.template` → `~/Library/LaunchAgents/<label>.plist`
  - `{{LAUNCHD_LABEL}}` → label
  - `{{PROJECT_PATH}}` → absolute project path
  - `{{HOME}}` → `$HOME`
  - `{{PROMPT}}` → exact /command (e.g. `/report`, `/docs sync --publish`)
  - `{{CALENDAR_INTERVAL}}` → constructed XML block from above

#### 7. Validate every rendered plist
```bash
for plist in <list of rendered plists>; do
  plutil -lint "$plist" || abort "FAIL: $plist invalid"
done
```

#### 8. Ensure logs dir
```bash
mkdir -p ~/Library/Logs
```

#### 9. Update `.claude/.setup.json`
```json
{
  "launchd": {
    "schedules": [
      {
        "label": "com.<user>.<project>-report",
        "plist_path": "~/Library/LaunchAgents/com.<user>.<project>-report.plist",
        "wrapper_path": "bin/launchd-runner.sh",
        "prompt": "/report",
        "cadence": "daily 23:00 local",
        "ts": "<ISO>"
      },
      ...
    ]
  }
}
```
(Replace existing `launchd.schedules` array entirely with current registrations
— ensures stale entries don't accumulate.)

#### 10. Print user instructions
```
✓ Files created for N schedules. In your TERMINAL (not in chat):

# Load each schedule:
launchctl bootstrap gui/$UID ~/Library/LaunchAgents/<label-1>.plist
launchctl bootstrap gui/$UID ~/Library/LaunchAgents/<label-2>.plist
...

# Verify loaded:
launchctl list | grep com.<user>.<project>-

# Test any schedule manually (runs immediately):
bin/launchd-runner.sh "/report"
bin/launchd-runner.sh "/docs sync --publish"

# Watch logs:
tail -f ~/Library/Logs/<label>.log

# Disable any single schedule:
launchctl bootout gui/$UID ~/Library/LaunchAgents/<label>.plist
```

#### 11. Commit `bin/launchd-runner.sh` to project git
(Don't commit any plists — they live in `~/Library/LaunchAgents/`, machine-specific.)

### Migrate v2→v3

1. Read `.claude/migrations/v2-to-v3.md` (full changeset).
2. Confirm with user: "Apply v2→v3 migration? This deletes some skills, renames others, adds new commands. [y/N]"
3. If yes — execute the steps in the migration doc, report each.
4. After: write/update `.setup.json` with `"version": 3, "migrated_from": 2`.

---

## Rules

- NEVER ask the user to paste their Outline token in chat. Always direct them to their terminal.
- NEVER write the token to any file in the repo. MCP config is stored by Claude Code internally.
- `.claude/.setup.json` is gitignored — local marker only.
- Idempotent: running `/setup` twice in same state should be a no-op except for "Verify health".
- If MCP verification fails, do NOT mark setup as complete.
