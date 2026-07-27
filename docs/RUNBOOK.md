# [PROJECT_NAME] — Runbook

> What to do when prod breaks. Append entries when an incident teaches something.
> Keep entries short — the runbook is a quick-reference, not a textbook.

## Healthchecks

| Check | Command |
|-------|---------|
| App alive | `ssh [alias] 'sudo docker compose ps'` |
| App logs (last 50) | `ssh [alias] 'sudo docker compose logs [app] --tail=50'` |
| DB queries | `bin/psql_ro.sh "SELECT now();"` |
| Disk | `ssh [alias] 'df -h \| head -5'` |

## Common failures

<!-- Append entries here. Format:
### F-NNN: <symptom>
**Detect**: how to confirm it's this
**Fix**: exact commands
**Prevention**: link to FAILS.md or Outline Knowledge Base entry
-->

## Deploy emergency rollback

```bash
ssh [alias] 'cd [project_path] && git log --oneline -5'
ssh [alias] 'cd [project_path] && git reset --hard <previous_sha> && docker compose up -d --build'
```

## Escalation

- DB locked / disk full → manual intervention required, document in F-NNN
- Auth provider outage → check provider status page, switch to bypass mode if defined
- Unknown unknown after 30min → write Daily Status to Outline, request human
