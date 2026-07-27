# Scheduling /report — decision matrix

`/report` writes daily status to Outline `Knowledge Base / Daily Status` and to local `docs/reports/<date>.md`. Multiple ways to schedule it; pick one that matches your environment.

## Decision matrix

| Mechanism | Best when | Pros | Cons |
|---|---|---|---|
| **launchd** (macOS) | macOS user, Mac is on at scheduled time | Uses real local Claude setup (MCP, memory, project files). Free, no cloud cost. | Requires Mac awake at trigger time. macOS only. |
| **systemd timer** (Linux) | Linux dev box, always-on | Same advantages as launchd | Linux only. Service-level config required. |
| **Cloud `/schedule`** | GitHub repo connected AND Outline accessible from Anthropic cloud | Survives Mac off / sleep. Doesn't need local machine. | Currently blocked: Outline isn't in the Anthropic cloud connector catalog. Requires GitHub connector. |
| **`/loop` (in-session)** | Short-cadence within an active Claude Code session | Simple, no setup | Stops when session closes |
| **Manual** | Ad-hoc reports | Full control | Forgetful — defeats the point of automation |

## Recommended: launchd (macOS)

For most users on this template — daily/weekly/bi-weekly automation with full local context.

**Pattern**: ONE generic wrapper `bin/launchd-runner.sh` (takes prompt as argument), MULTIPLE plists each invoking it with a different prompt at a different time. One file in `bin/`, N files in `~/Library/LaunchAgents/`.

### Default schedule set (4 routines)

| Routine | Cadence | Prompt | Label |
|---|---|---|---|
| daily report | every day at 23:00 local | `/report` | `com.<user>.<project>-report` |
| weekly docs sync | Mon at 09:00 | `/docs sync --publish` | `com.<user>.<project>-docs-sync` |
| weekly self-audit | Fri at 10:00 | `/self-audit` | `com.<user>.<project>-self-audit` |
| bi-weekly global audit | 1st & 15th at 11:00 | `/self-audit --global` | `com.<user>.<project>-self-audit-global` |

### Setup via /setup wizard

`/setup` → mode **"Setup launchd schedules"**:
- Detects existing launchd jobs for this project (won't recreate)
- AskUserQuestion with `multiSelect: true` — pick which routines to register
- For each chosen — asks time (with sensible defaults)
- Renders generic `bin/launchd-runner.sh` (once, idempotent — replaces template placeholders with concrete CLAUDE_BIN and PROJECT_PATH)
- Renders one plist per chosen routine into `~/Library/LaunchAgents/`
- Validates all plists with `plutil -lint`
- Prints exact `launchctl bootstrap` commands for you to run
- Records all registered routines in `.claude/.setup.json` under `launchd.schedules` (array)

### Manual setup (if /setup wizard unavailable)

For each schedule you want:

1. **Render the runner ONCE** (single file, reused by all schedules):
   ```bash
   sed -e "s|{{CLAUDE_BIN}}|$(which claude)|g" \
       -e "s|{{PROJECT_PATH}}|$PWD|g" \
       bin/launchd-runner.sh.template > bin/launchd-runner.sh
   chmod +x bin/launchd-runner.sh
   ```

2. **Render the plist** for one routine. Replace placeholders in `templates/launchd-task.plist.template`:
   - `{{LAUNCHD_LABEL}}` — e.g. `com.alice.myproject-report`
   - `{{PROJECT_PATH}}` — absolute project path
   - `{{HOME}}` — `$HOME`
   - `{{PROMPT}}` — exact /command (e.g. `/report`, `/docs sync --publish`)
   - `{{CALENDAR_INTERVAL}}` — XML block, depending on schedule type:

   **Daily** (e.g. `/report` every day at 23:00):
   ```xml
   <key>StartCalendarInterval</key>
   <dict>
       <key>Hour</key><integer>23</integer>
       <key>Minute</key><integer>0</integer>
   </dict>
   ```

   **Weekly** (e.g. `/docs sync --publish` every Monday at 09:00; Weekday: Sun=0, Mon=1, ..., Sat=6):
   ```xml
   <key>StartCalendarInterval</key>
   <dict>
       <key>Weekday</key><integer>1</integer>
       <key>Hour</key><integer>9</integer>
       <key>Minute</key><integer>0</integer>
   </dict>
   ```

   **Bi-weekly** (e.g. `/self-audit --global` on 1st & 15th at 11:00):
   ```xml
   <key>StartCalendarInterval</key>
   <array>
       <dict><key>Day</key><integer>1</integer><key>Hour</key><integer>11</integer><key>Minute</key><integer>0</integer></dict>
       <dict><key>Day</key><integer>15</integer><key>Hour</key><integer>11</integer><key>Minute</key><integer>0</integer></dict>
   </array>
   ```

3. **Validate** the plist:
   ```bash
   plutil -lint ~/Library/LaunchAgents/<label>.plist
   ```

4. **Load**:
   ```bash
   launchctl bootstrap gui/$UID ~/Library/LaunchAgents/<label>.plist
   ```

5. **Verify**:
   ```bash
   launchctl list | grep <label>
   ```

6. **Test any schedule manually** (runs immediately):
   ```bash
   bin/launchd-runner.sh "/report"
   bin/launchd-runner.sh "/docs sync --publish"
   ```

## When launchd isn't enough

Switch to **Cloud `/schedule`** as soon as both prerequisites are met:
1. GitHub connector connected via `/web-setup` (so cloud agent can clone repo)
2. Outline appears in Anthropic cloud connectors catalog (currently not — only Google Drive, etc.)

When that day comes:
```
/schedule "0 23 * * *" /report
```
And disable the launchd job: `launchctl bootout gui/$UID ~/Library/LaunchAgents/<label>.plist`

## Disabling a single schedule

```bash
launchctl bootout gui/$UID ~/Library/LaunchAgents/<label>.plist
rm ~/Library/LaunchAgents/<label>.plist
```

`bin/launchd-runner.sh` stays — it's used by other schedules and for manual runs.

Then update `.claude/.setup.json`: remove the matching entry from `launchd.schedules` array.

## Disabling ALL schedules for a project

```bash
for plist in ~/Library/LaunchAgents/com.$(whoami).$(basename $(pwd))-*.plist; do
  launchctl bootout gui/$UID "$plist"
  rm "$plist"
done
```

Optionally remove the runner if nothing else uses it: `rm bin/launchd-runner.sh`.

## Logs

`~/Library/Logs/<label>.log` — all stdout + stderr from the wrapper and Claude.

```bash
tail -f ~/Library/Logs/com.yourname.investments-report.log
```

If launchd fires but nothing happens, check the log for:
- `claude binary not found` → wrong CLAUDE_BIN path in wrapper
- `project dir not found` → wrong PROJECT_PATH
- `MCP outline disconnected` → claude can't reach Outline; `/report` falls back to local-only
- `No activity for <project> on <date>` → report deliberately skipped (no commits, no task changes)

## Related

- `docs/OUTLINE-CONTRACT.md` — what `/report` writes to Outline
- `.claude/commands/report.md` — the command itself
