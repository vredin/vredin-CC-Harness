# Outline Contract — what writes where, when, and in what mode

> Single source of truth for shared-knowledge integration. When in doubt about whether
> something auto-publishes or not, this file is authoritative. Despite the filename, this
> now covers THREE backends — see § Backend below. "Outline" stayed the filename because
> most cross-references in the harness already point at it; don't rename, just read past
> the name.

## Backend — cloud (Outline), local, or github

`.claude/.setup.json` → `outline.mode` picks the backend for BOTH directions (read + write).
The trigger table and read-flow table further down are backend-agnostic — only the
mechanics of "how" differ:

| `outline.mode` | What it is | How reads/writes happen |
|---|---|---|
| `"cloud"` (default) | An Outline instance | `mcp__outline__*` tools, `bin/outline.sh` if MCP unavailable |
| `"local"` | Local Obsidian-style vault, no cloud | Direct grep/write in `outline.local_vault_path` |
| `"github"` | A dedicated shared GitHub repo | Plain git (clone/pull/commit/push) via `bin/github-kb.sh` — NOT the GitHub API, no rate limits, same git already used everywhere else in this harness |

**Resolution procedure — every read/write call site starts here:**
```bash
MODE=$(python3 -c "import json;print(json.load(open('.claude/.setup.json')).get('outline',{}).get('mode','cloud'))" 2>/dev/null || echo cloud)
```
- `cloud` → proceed as documented in the rest of this file (`mcp__outline__*` / `bin/outline.sh`)
- `local` → grep/write directly under `outline.local_vault_path` (unchanged from existing local-only mode)
- `github`:
  ```bash
  REPO=$(python3 -c "import json;print(json.load(open('.claude/.setup.json'))['outline']['github_repo'])")
  CACHE=$(python3 -c "import json;print(json.load(open('.claude/.setup.json')).get('outline',{}).get('github_cache_dir','~/.claude/kb-github-cache'))")
  export GITHUB_KB_REPO="$REPO" GITHUB_KB_CACHE_DIR="$CACHE"
  bin/github-kb.sh search "<query>" [project] [category]            # read
  bin/github-kb.sh publish <project> <category> <slug> < body.md    # write
  ```
  `project` = current project's directory/repo name (from CLAUDE.md or `basename` of the repo root). `category` ∈ `fails | best-practices | tricks | daily-status`.

**Per-project collection (Architecture/API/Runbook/Decisions/Rules) has NO github-mode
equivalent, and needs none.** The project's own `docs/*.md`, once committed and pushed to
ITS OWN GitHub repo, already IS the publication — that's the whole point of the project
already living on GitHub. Every "AUTO → Project: <name> / X" row in the trigger table below
is a **no-op in github mode**: the command just confirms the local file is committed, prints
that, and moves on. Only the SHARED rows (Fails, Best Practices, Tricks, Daily Status) do
real work in github mode.

## Layout

**Cloud (Outline):**
```
Knowledge Base                              ← shared, cross-project
├── Fails              F-NNN entries from any project
├── Best Practices     Reusable patterns (proven >1× across projects)
├── Tricks             One-liners, heuristics
└── Daily Status       Daily reports — title format: "<project> — YYYY-MM-DD"

Project: <name>                             ← per-project, not reusable
├── PRDs                PRD-NNN entries (from /intent) — product requirements
├── Epics               EPIC-NNN entries (from /decompose) — work groups
├── Architecture       Mirror of docs/ARCHITECTURE.md
├── API Reference      Mirror of docs/API.md
├── Runbook            Mirror of docs/RUNBOOK.md
├── Knowledge          Mirror of docs/KNOWLEDGE.md (this project's decisions)
├── Decisions          ADR-NNN — one page per ADR (mirror of docs/adr/)
└── Rules              R-NNN business rules (mirror of docs/RULES.md)
```

**GitHub mode** (`<github_repo>` root — grouped by originating project first, then category,
mirroring the Knowledge Base sub-pages one level deeper):
```
<repo root>
└── <project-name>/
    ├── fails/              F-NNN entries — same file-per-lesson format as docs/fails/
    ├── best-practices/     P-NNN reusable patterns
    ├── tricks/             one-liners, heuristics
    └── daily-status/       <YYYY-MM-DD>.md daily reports
```
Cross-project search = `bin/github-kb.sh search "<query>"` (no project filter) greps the
whole cache at once. Single-project search passes `project` as the third arg. PRDs/Epics
(per-project, not shared) have no github-mode home — they stay project-local only, same
disposition as the "What is NOT published" list further down.

## Triggers — what publishes, where, in what mode

`github?` column: ✅ = real write via `bin/github-kb.sh`; **n/a** = no-op in github mode (the
project's own `docs/*.md` is already the publication once committed — see § Backend above).

| Source | Outline destination | Mode | github? |
|---|---|---|---|
| `/fix` STEP 7 — F-NNN with non-obvious root cause | Knowledge Base / Fails | **AUTO** (no prompt) | ✅ |
| `/rule` STEP 9 — R-NNN created | Project: <name> / Rules | **AUTO** | n/a |
| `/improve-arch` — ADR created | Project: <name> / Decisions | **AUTO** | n/a |
| `/intent` — PRD finalized | Project: <name> / PRDs | **AUTO** | n/a |
| `/decompose` — ADR/EPIC created | Project: <name> / Decisions, Epics | **AUTO** (tasks remain local) | n/a |
| `/improve-arch` — pattern flagged `reusable: true` | Knowledge Base / Best Practices | **AUTO** | ✅ |
| `/improve-arch` — pattern not flagged reusable | local docs/PATTERNS.md only | not published | — |
| `/council` — verdict accepted by user | Knowledge Base / Best Practices | **ASK** (judgment) | ✅ |
| `/general` — verified fact, useful for later | Knowledge Base / Fails or Tricks | **ASK** (subjective) | ✅ |
| `/report` (daily, via /loop) | Knowledge Base / Daily Status | **AUTO** if has activity | ✅ |
| `/docs sync --publish` (weekly, via /loop) | Project: <name> / Architecture, API, Runbook, Knowledge | **AUTO** gated by drift-check | n/a |
| `/self-audit --global` (bi-weekly, via /loop) | Knowledge Base / Best Practices (process audit) | **AUTO** | ✅ |
| `/self-audit` (weekly, via /loop) | local docs/SELF-AUDIT-<date>.md | not published | — |

## Control flags — `.claude/.setup.json`

**Cloud mode:**
```json
{
  "version": 3,
  "outline": {
    "mode": "cloud",
    "shared_kb_id": "<UUID of Knowledge Base collection>",
    "project_collection_id": "<UUID of Project: <name> collection>",
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

**GitHub mode** — same `auto_publish` shape (the n/a rows from the trigger table just become
inert no-ops), plus two new fields instead of the collection UUIDs:
```json
{
  "version": 3,
  "outline": {
    "mode": "github",
    "github_repo": "<owner>/<repo>",
    "github_cache_dir": "~/.claude/kb-github-cache",
    "auto_publish": { "...": "same keys as cloud mode" }
  }
}
```

Flip a flag to `false` to disable that auto-publish. Defaults are all `true`.

## Read flow — commands check Outline BEFORE work

Auto-publish is one direction. The other direction (read prior knowledge before starting) is equally important — without it, every new task risks duplicating or contradicting prior work.

| Command | Reads from | When |
|---|---|---|
| `/fix` STEP 0.5 | `Knowledge Base / Fails` (matching F-NNN), `Knowledge Base / Best Practices` (defensive patterns) | Before diagnosing — recurring bugs surfaced |
| `/todo add` STEP 2.5 | `Knowledge Base / Best Practices`, `Knowledge Base / Fails`, `Project: <name> / Decisions` (ADRs), `Project: <name> / Rules` | Before researching — task constraints surfaced |
| `orchestrator` STEP 2.5 | `Knowledge Base / Fails` (newer than spec), `Project: <name> / Decisions`, `Knowledge Base / Daily Status` (recent adjacent work) | After reading spec, before writing tests — refresh context |
| `/general` (per bucket) | `Knowledge Base / Fails`, `Knowledge Base / Best Practices`, `Project: <name> / *` | Always when relevant to the question type |

`Project: <name>` rows above are always local-first regardless of backend (`docs/adr/`,
`docs/RULES.md`) — only the `Knowledge Base` rows route through § Backend resolution.

**Decision shape** (same for all read points):
- Match found, applicable → reuse the prior pattern, link from new artifact
- Match found, contradicts → flag, ask user to reconcile (often means ADR override)
- Nothing relevant → proceed, document the search in artifact

This is the feedback loop: writes from one task become reads for the next.

## Why this design

- **Objective → AUTO**. Failures, rules, ADRs are facts; asking permission per-publish is friction without value.
- **Subjective → ASK**. Patterns/Best Practices are judgment calls — a one-off solution shouldn't claim "best practice" status.
- **Cross-project knowledge → Shared**. Failure patterns from Project A often save time in Project B.
- **Project-specific → Project collection**. Business rules / architecture / runbook are not transferable.
- **Daily status → Shared**, not Project. Single timeline of "what got done today across everything" is more useful than 5 separate timelines.

## What is NOT published

These stay local only:
- `docs/TASK.md` — transient backlog
- `docs/specs/T-NNN-*.md` — transient spec files
- `docs/handoff/*.md` — checkpoint artifacts
- `docs/reports/<date>.md` — local mirror of Daily Status (for offline access)
- `docs/archive/*` — completed task history
- `docs/SELF-AUDIT-<date>.md` — process improvement findings

If you want any of these published, do it manually via `mcp__outline__create_document`.

## Manual publish — when needed

For one-off shares (e.g. wanting to publish PATTERNS.md content to KB):

```
mcp__outline__create_document
  collectionId: <shared_kb_id>
  title: "<descriptive title>"
  text: "<markdown content>"
  publish: true
```

Or via `bin/outline.sh create <collection_id> "<title>" < content.md`.

**GitHub mode equivalent:**
```bash
bin/github-kb.sh publish <project> <category> <slug> < content.md
```

## Rate limits & failure handling

- Outline API doesn't enforce strict rate limits, but commands batch publishes when possible
- If MCP outline is disconnected — auto-publish silently fails locally (logged, but doesn't block command)
- GitHub mode: a push conflict (two projects/sessions publishing at once) gets one automatic
  pull-rebase retry (`bin/github-kb.sh`); a second failure logs and skips, same fail-soft
  treatment as an unreachable Outline
- Local files (FAILS.md, RULES.md, etc.) ALWAYS get written first; Outline/GitHub is a mirror, not the primary
- This means: if Outline is down, you don't lose work — local is source of truth, Outline is replication

## Migration / replay

If a project missed publishes (Outline was down, MCP not connected, etc.):

```
/docs publish --since <date>
```

(NOT IMPLEMENTED YET — placeholder for future. For now use manual `bin/outline.sh create` per missed entry.)
