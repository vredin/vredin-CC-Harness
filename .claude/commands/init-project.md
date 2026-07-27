---
name: init-project
description: 'Initialize a new project from the claude-project-template. Interactive setup: collects project info, copies template, replaces placeholders, configures deploy.'
argument-hint: [/path/to/new-project]
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

> **Style:** Load `caveman-distillate` skill — terse responses, no filler, fragments OK.

# Init Project from Template

Set up a new project using the claude-project-template. Collect all info interactively, then configure everything in one pass.

## Variables

TARGET_PATH: $ARGUMENTS
TEMPLATE_PATH: The directory where THIS command is running from (the template repo root).

## Workflow

### STEP 1 — Collect project info

Use `AskUserQuestion` to gather the following. Ask in ONE message, not one-by-one:

```
Setting up a new project. Please provide:

1. **Project name** (e.g. "Slugger", "MyApp")
2. **Response language** (e.g. Ukrainian, English, Russian)
3. **Stack**:
   - Backend: (e.g. FastAPI + SQLAlchemy + PostgreSQL + Redis)
   - Frontend: (e.g. React 18 + TypeScript + Vite)
   - Deploy: (e.g. Docker Compose on VPS)
4. **Server access**:
   - SSH alias: (e.g. `ssh vps3`)
   - Project path on server: (e.g. `/opt/slugger`)
   - Domain(s): (e.g. `slugger.example.com`, `metabase.example.com`)
   - Reverse proxy: (e.g. Traefik / Nginx / Caddy)
5. **Deploy flow** — how code gets to production:
   - (e.g. "git push → ssh → git pull → docker compose up -d")
   - (e.g. "git push origin main → GitHub Actions deploys automatically")
```

If TARGET_PATH was not provided as argument, also ask:
```
6. **Target directory**: full path where the project should be created
```

### STEP 2 — Copy template structure

```bash
# Create target directory if needed
mkdir -p <TARGET_PATH>

# Copy core directories
cp -r <TEMPLATE_PATH>/.claude <TARGET_PATH>/
cp -r <TEMPLATE_PATH>/docs <TARGET_PATH>/
cp -r <TEMPLATE_PATH>/bin <TARGET_PATH>/
cp -r <TEMPLATE_PATH>/templates <TARGET_PATH>/

# Copy root files
cp <TEMPLATE_PATH>/CLAUDE.md <TARGET_PATH>/
cp <TEMPLATE_PATH>/.gitignore.template <TARGET_PATH>/.gitignore

# Normalize permissions — critical for shareable template
chmod -R u=rwX,go=rX <TARGET_PATH>/.claude/
chmod +x <TARGET_PATH>/bin/*.sh
```

Do NOT copy: `README.md`, `temp/`, `.git/`, `.claude/.setup.json`.

### STEP 3 — Replace placeholders

Using the info from STEP 1, edit these files (every `[PROJECT_NAME]`/`[e.g. ...]` must become a concrete value):

**`CLAUDE.md`**:
- Replace `[PROJECT_NAME]` with actual project name
- Replace `[Ukrainian / English / ...]` with chosen language

**`.claude/rules/project.md`**:
- Replace `[PROJECT_NAME]` in title
- Replace stack placeholders with actual stack
- Update Deploy section with actual deploy flow

**`docs/STACK.md`** (new in v3):
- Fill stack table from STEP 1 answers
- Fill `lint_cmd`, `typecheck_cmd`, `test_*` commands per chosen stack
- Fill `ssh_alias`, `db_container`, `db_user`, `db_name`, `app_service` for prod access

**`docs/CONTEXT.md`** (new in v3):
- Replace `[PROJECT_NAME]` in header
- Leave glossary empty — user fills as project grows

**`docs/prd/`** (new in v3.1) — empty directory with `.gitkeep`. PRDs created via `/intent`.
**`docs/epics/`** (new in v3.1) — empty directory with `.gitkeep`. Epics created via `/decompose`.

**`docs/RUNBOOK.md`** (new in v3):
- Replace `[alias]`, `[app]`, `[project_path]` with actual values from STEP 1

**`docs/DEPLOY.md`**:
- Fill in SSH command, project path, domain(s), reverse proxy
- Fill in deploy flow steps with actual commands
- Fill in Services table with actual services and URLs
- Remove placeholder brackets — everything should be concrete values

### STEP 4 — Create .env.example

Create `<TARGET_PATH>/.env.example` with common variables for the chosen stack:

```bash
# [PROJECT_NAME] Environment Variables
# Copy to .env for local dev, .env.production for production secrets

# App
APP_NAME=[project_name]
APP_ENV=development
APP_PORT=8000

# Database (adapt to stack)
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# Add stack-specific variables below
```

### STEP 5 — Initialize git (MANDATORY — must succeed)

```bash
cd <TARGET_PATH>
git init
git add -A
git commit -m "[BACKUP] Initial project setup from claude-project-template v3"
```

**Hard verification — DO NOT proceed past this step if any check fails:**

```bash
# Verify git was actually initialized
cd <TARGET_PATH>
git rev-parse --git-dir 2>/dev/null || { echo "FATAL: git init failed" >&2; exit 1; }

# Verify there's at least one commit
git log --oneline -1 2>/dev/null | grep -q . || { echo "FATAL: no initial commit" >&2; exit 1; }

# Verify [BACKUP] marker is in history
git log --pretty="%s" -1 | grep -q "^\[BACKUP\]" || { echo "FATAL: initial commit missing [BACKUP] marker" >&2; exit 1; }
```

If any check fails — STOP. Do NOT continue to STEP 5.5 or 6. Report failure to user with exact command output. The PreToolUse Edit hook will refuse all edits without `[BACKUP]` history, so if init failed silently the project is broken in a non-obvious way.

### STEP 5.5 — Create Outline project collection

If MCP outline is connected:
1. `mcp__outline__create_collection` with name `Project: <project_name>`. Capture returned ID.
2. Create initial sub-page `Overview` in that collection with project's STACK.md content.
3. Save collection ID to `<TARGET_PATH>/.claude/.setup.json`:
   ```json
   {
     "version": 3,
     "project_name": "<name>",
     "outline_project_collection_id": "<id>",
     "outline_shared_collection_id": "<from_~/.claude/.setup.json or asked>"
   }
   ```

If MCP outline NOT connected:
- Print instruction: "Run `/setup` first to configure Outline MCP, then `/setup` will create the project collection retroactively."
- Continue without Outline integration; project still works locally.

### STEP 6 — Verify and report

Check that all placeholder strings are gone:
```bash
grep -rn "\[PROJECT_NAME\]\|\[e\.g\.\|/PATH/TO/" <TARGET_PATH>/.claude/ <TARGET_PATH>/docs/ <TARGET_PATH>/CLAUDE.md 2>/dev/null
```

If any remain — fix them.

Then report:

```
✅ Project initialized: <name>

Directory: <TARGET_PATH>
Stack: <backend> + <frontend>
Deploy: <ssh alias> → <server path>

Files created:
- .claude/ (agents, commands, rules, skills, settings)
- docs/ (KNOWLEDGE, FAILS, PATTERNS, TASK, DEPLOY)
- CLAUDE.md
- .env.example
- .gitignore

Next steps:
1. Open the project: cd <TARGET_PATH>
2. Fill in API keys: cp .env.example .env.production
3. Start working: claude
```

## Rules

- Ask ALL questions in ONE message — don't drip-feed questions one by one
- Never leave placeholder brackets in output files — every `[...]` must be replaced
- If user skips a field (e.g. no frontend) — remove that section entirely, don't leave empty placeholders
- The init-project command is PLANNING ONLY — never write application code
- If target directory already has `.claude/` — warn and ask before overwriting
