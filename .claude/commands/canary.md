---
name: canary
description: 'Post-deploy health check — probe critical URLs, catch JS errors / slow loads / failed routes. Run AFTER deploy completes. Compares to baseline if exists.'
argument-hint: <production_url> [--baseline <date>] [--routes <comma-separated>]
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion, WebFetch
model: sonnet
---

> **Style:** Load `caveman-distillate` skill — terse, evidence-first.

# /canary — Post-deploy health monitoring

Inputs:
- `<production_url>` — base URL to probe (e.g., `https://your-app.example.com`)
- `--baseline <date>` — compare against `docs/canary/<date>.md` snapshot. Optional.
- `--routes <a,b,c>` — explicit route list. Optional. If absent, uses `docs/canary/routes.txt` if exists, else minimal default.

Goal: detect production breakage **earlier than user reports it**. Not a load test — a smoke test on critical paths.

---

## STEP 1 — Resolve route list

Priority order:
1. `--routes a,b,c` from args
2. `docs/canary/routes.txt` (one route per line, comments with `#`)
3. Minimal default: `/`, `/health`, `/login`, `/api/health`

Each route is **relative**: combine with base URL.

If no `routes.txt` exists and user didn't pass `--routes` → ask:
> "No `docs/canary/routes.txt` found. Probe defaults (`/`, `/health`, `/login`, `/api/health`)? Or give me a list now via comma-separated?"

After first run on a project — write the resolved list to `docs/canary/routes.txt` so future runs don't ask again.

## STEP 2 — Probe each route

For each route:
```bash
curl -sw "\n@@@HTTP=%{http_code} TIME=%{time_total}s SIZE=%{size_download}b\n" \
     -L --max-time 30 \
     "$BASE$ROUTE" -o /tmp/canary-body.html

# Capture JS-side errors if it's a frontend route (HTML response)
# Use Playwright via webapp-testing skill if installed:
# npx playwright test --grep "canary-$ROUTE" if test exists
```

Capture per route:
- HTTP status (expect 200 or expected redirect)
- Response time (warning >2s, critical >5s)
- Response size (sanity check — 0 bytes = something broken)
- Content-Type (warns if HTML when JSON expected)
- For HTML routes: extract `<title>` (regression check)

For SPA routes that need JS rendering — use Playwright via `webapp-testing` skill if available. Otherwise mark «JS-rendered, basic curl probe only» in report.

## STEP 3 — Console error capture (frontend only)

If `webapp-testing` skill is loaded AND target has frontend (`*.tsx`/`*.html`/`SPA` in STACK.md):

```bash
# Spawn headless browser, capture console.error during page load
node -e "
const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  const errors = [];
  page.on('console', msg => { if (msg.type() === 'error') errors.push(msg.text()); });
  page.on('pageerror', err => errors.push(err.message));
  await page.goto('$BASE$ROUTE', { waitUntil: 'networkidle', timeout: 30000 });
  console.log(JSON.stringify(errors));
  await browser.close();
})();
"
```

Each console error → SERIOUS finding (or CRITICAL if it's `Uncaught Error: ...`).

## STEP 4 — Detect drift vs baseline

If baseline file exists at `docs/canary/<date>.md`:
- Compare current results to baseline
- New routes failing → SERIOUS
- Routes that worked but now fail → CRITICAL
- Response time regression > 2× baseline → SERIOUS
- HTML title changed unexpectedly → INFO (could be intentional; flag for review)

If no baseline → save current as baseline for next run.

## STEP 5 — Write report

Create `docs/canary/<YYYY-MM-DD-HHMM>.md`:

```markdown
# Canary — <BASE_URL> — <TIMESTAMP>

## Summary
- Routes probed: N
- CRITICAL: K
- SERIOUS: M
- OK: P

## Baseline
<path to baseline file if compared, or "first run, saved as baseline">

## Findings

### CRITICAL
| Route | Status | Time | Issue |
|-------|--------|------|-------|
| /api/users | 500 | 0.3s | Internal Server Error (was 200 in baseline) |

### SERIOUS
| Route | Issue |
|-------|-------|
| /dashboard | Console error: "Cannot read property 'id' of undefined" |
| /admin | Response time 8.2s (baseline 1.1s) |

### Verified OK
| Route | Time |
|-------|------|
| / | 0.4s |
| /login | 0.6s |

## Per-route details
<for each route: full response headers, timing breakdown, body excerpt if non-200>
```

## STEP 6 — Auto-publish to Outline (no prompt)

Read `.claude/.setup.json` → `outline.auto_publish.canary_to_kb`. Default `true`.

If MCP outline available:
```
ToolSearch select:mcp__outline__create_document

mcp__outline__create_document
  title: "Canary <date>: <BASE_URL>"
  collectionId: <shared_kb_id>
  parentDocumentId: <Knowledge Base / Daily Status sub-page id>  # piggyback on Daily Status
  text: <report content>
  publish: true
```

If MCP unavailable → log skip, continue.

## STEP 7 — Alert on CRITICAL/SERIOUS (optional)

If `.setup.json.canary.alert_command` is set (e.g., a curl to Telegram bot, Slack webhook, email script) and findings ≥ SERIOUS:

```bash
$ALERT_COMMAND --title "Canary CRITICAL on $BASE_URL" --body "$(cat docs/canary/<date>.md | head -50)"
```

Default: no alert command set, just write to file.

## STEP 8 — Confirm

```
✓ Canary complete on <BASE_URL>
Routes probed: N (K CRITICAL, M SERIOUS, P OK)
Report: docs/canary/<date>.md
Outline: <url or "skipped">
Alert: <triggered/disabled/no findings>
```

---

## Hard rules

- NEVER probe production without explicit URL — argument is mandatory
- NEVER write data (POST/PUT/DELETE) — only GET / HEAD probes. Canary is observational, not test-creation.
- NEVER probe internal endpoints requiring auth without provided session/token
- If routes.txt is absent — first run asks user, subsequent runs use saved list
- If MCP outline auto-publish enabled but Outline down → save locally, mark «Outline pub failed, retry» in report

---

## Designed for launchd schedule

Add to `.claude/.setup.json` launchd schedules:
```json
{
  "label": "com.yourname.<project>-canary",
  "plist_path": "~/Library/LaunchAgents/com.yourname.<project>-canary.plist",
  "wrapper_path": "bin/launchd-runner.sh",
  "prompt": "/canary https://<production_url>",
  "cadence": "every 30 minutes during business hours"
}
```

Run via `/setup → Setup launchd schedules`. Cron: `*/30 9-22 * * *` for 9am-10pm probes.
