# /loop schedules — v3 default routines

> Register these once per machine after `/setup` confirms MCP is connected.
> The `/loop` skill provides the cron-style registration mechanism.

## Why these schedules

| Schedule | Mode | Why this cadence |
|---|---|---|
| Daily 18:00 — `/report` | active | End-of-day status. Empty days produce no output (STEP 2 short-circuits) |
| Mon 09:00 — `/docs audit` | active | Weekly drift check. Audit only — does not auto-edit. User reviews and runs `/docs sync` if drift found |
| Fri 10:00 — `/self-audit` | active | Weekly process review. Diff-ready remediation file written, not auto-applied |
| 1st & 15th 11:00 — `/self-audit --global` | active | Bi-weekly cross-project pattern detection via Outline. Catches systemic issues |

## Registration (one-time per machine)

After `/setup` succeeds, run the `/loop` skill four times:

```
/loop "0 18 * * *" /report
/loop "0 9 * * 1" /docs audit
/loop "0 10 * * 5" /self-audit
/loop "0 11 1,15 * *" /self-audit --global
```

If `/loop` is not available in your environment — skip. The commands still work manually.

## Customization

These are defaults. Adjust per project needs:
- `/report` daily not enough? → run on session-end manually instead.
- `/docs audit` weekly too aggressive for fast-moving projects → bi-weekly.
- `/self-audit --global` requires Outline KB with ≥3 projects. Skip for sole-project setups.

Schedule changes go here for documentation; the actual schedules live in your `/loop` configuration.

## Disabling

To stop a routine: see `/loop` skill help (`/loop list`, `/loop remove <id>`).

## Conflicts with /compact

If a scheduled task fires during a long session that's been compacted, the loop runs in
a fresh context — no cross-task pollution. This is by design (see `/loop` skill semantics).
