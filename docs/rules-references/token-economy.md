# Token Economy — Detailed Rules

> Referenced from `workflow.md` § Token Economy Rules.
> Read this when optimizing token usage or starting a cost-sensitive session.

---

## Pre-Implementation Confidence Gate

Before writing ANY code for a non-trivial task:
- Rate your confidence 0–100% that you understand what to build
- **<70%** — switch to Plan Mode, outline approach, ask clarifying questions
- **70–94%** — describe your plan in 3-5 bullets, get user confirmation, then code
- **95%+** — proceed to code
- NEVER write code while uncertain — redo costs 10x more tokens than asking one question

---

## Proactive Compaction

- At **~60% context capacity**: write `docs/handoff.md` FIRST, then run `/compact`
- NEVER wait for auto-compact (triggers at ~95% — quality already degraded by then)
- After **3-4 compactions** in same session: quality degrades regardless — write handoff, `/clear`, start fresh
- When switching to **unrelated task**: `/clear` instead of continuing (carries zero baggage)

---

## Terminal Output Hygiene

Every byte of shell output enters context permanently and is re-read every turn.
- `git log`: always `--oneline -20` or less, never unbounded
- Test runs: use `-q` / `--quiet` flags; pipe verbose output through `| tail -n 50`
- Build/install logs: redirect to file, read only summary or errors
- Read tool: always use `limit` + `offset` when you know which part of file you need — never read 2000 lines for a 20-line function
- Grep: always set `head_limit` — default 250 is often too much

---

## MCP Hygiene

- At session start: review connected MCP servers (`/mcp`)
- Disconnect servers not needed for current task type
- Each MCP server adds ~17K tokens to EVERY message (tool definitions)
- Prefer CLI tools (bash) over MCP servers where functionally equivalent — CLIs don't inflate context

---

## Surgical File Reading

- Use `limit` + `offset` when you know which part of file you need
- For exploration of 3+ files: use subagent (Explore type) — its reads don't enter main context
- Prefer targeted Grep with `head_limit` over reading entire files
- One precise read > three exploratory reads

---

## Model Selection

Current lineup (2026): **Fable 5** — main session model; **Opus 4.8** — adversarial critique / security / deep planning; **Sonnet 5** — subagent workhorse; **Haiku 4.5** — mechanical-only.

- **Subagents inherit the session model by default** — that is the correct default; don't override without a reason.
- **Downgrade tier deliberately**, only for mechanical subtasks (bulk rename, lint sweep, structured extraction) — never to "save" on real analysis or coding.
- **Upgrade (Opus) only for adversarial critique and security** (Diablo, Rex, /council) — decisions with lasting impact.
- Subagent workflows cost 7-10x more tokens than inline work — use intentionally

### Haiku — avoid by default

**Default: do NOT use Haiku — including Haiku 4.5, until proven reliable on the specific task class.** Sonnet-tier is the minimum for all tasks.

Haiku is allowed ONLY when ALL conditions are met:
1. Task is purely mechanical (lint fix, rename, structured extraction with exact schema)
2. Zero project context needed — everything is in the prompt
3. Single file, <3 tool calls, no decision-making
4. User explicitly opts in

**Why avoid:** Haiku degrades fast under context. It forgets project config, makes assumptions without verifying, asks the user for things it could find itself, mixes analysis with instructions in unstructured output. Not a capability gap on trivial tasks — a reliability gap on anything real.

**Real failures (2026-04):**
1. Asked user for creds that exist in `.env`/`conftest.py` — didn't search configs
2. Wrote "ask developers to make UI dumps" instead of running `adb shell uiautomator dump` via Bash
3. Mixed own TODOs, developer requests, unverified hypotheses in one document — no structure
4. Concluded `LIST_CAMERAS = actionAddCamera` without checking actual UI
5. Assumed resource ID changes with language — ID was stable 2 years

---

## Prompt Cache Awareness

- Claude Code caches unchanged context for **5 minutes**
- After 5+ min break: next message re-processes everything from scratch at full cost
- Before stepping away >5 min: consider `/compact` to shrink what gets re-processed on return
- Rapid focused work sessions are inherently cheaper than scattered interactions
