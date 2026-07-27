# Migration: v2 → v3

> Applied by `/setup` mode `Migrate v2→v3` against an existing project that was initialized from the v2 template.
> This file is the source of truth for the changeset. Each step is idempotent.

## Detection

A project is v2 if:
- `.claude/skills/` contains directories `api-fuzzing-bug-bounty/`, `api-security-best-practices/`, `testing-patterns/`, `brainstorming/`, `idea-atomizer/`, or `writing-plans/` (any of these = v2 layout)
- `.claude/skills/verify-before-done.md` exists as a top-level file
- `.claude/.setup.json` is absent OR `version != 3`
- `bin/` directory does not exist
- `docs/STACK.md` does not exist

If ALL of the above are false → already v3, skip migration.

## Steps (apply in order)

### 1. Cleanup
```bash
chmod -R u=rwX,go=rX .claude/skills/
find . -name ".DS_Store" -not -path "./.git/*" -delete
rm -f .claude/skills/systematic-debugging/test-pressure-{1,2,3}.md \
      .claude/skills/systematic-debugging/test-academic.md \
      .claude/skills/systematic-debugging/CREATION-LOG.md
rm -rf .claude/skills/api-fuzzing-bug-bounty/
```

### 2. Skill mergers
Security:
```bash
if [ -f .claude/skills/api-security-best-practices/SKILL.md ]; then
  awk 'BEGIN{fm=0} /^---$/{fm++; next} fm<2{next} {print}' \
    .claude/skills/api-security-best-practices/SKILL.md \
    > .claude/skills/security-scan/references/build-time-security.md
  rm -rf .claude/skills/api-security-best-practices/
fi
```

Testing:
```bash
mkdir -p .claude/skills/tdd/references
if [ -f .claude/skills/testing-patterns/SKILL.md ]; then
  awk 'BEGIN{fm=0} /^---$/{fm++; next} fm<2{next} {print}' \
    .claude/skills/testing-patterns/SKILL.md \
    > .claude/skills/tdd/references/jest-patterns.md
  rm -rf .claude/skills/testing-patterns/
fi
[ -f .claude/skills/verify-before-done.md ] && \
  mv .claude/skills/verify-before-done.md .claude/skills/tdd/references/verify-before-done.md
[ -f .claude/skills/tdd/testing-anti-patterns.md ] && \
  mv .claude/skills/tdd/testing-anti-patterns.md .claude/skills/tdd/references/testing-anti-patterns.md
```

Planning:
```bash
mkdir -p .claude/skills/planning
for src in brainstorming idea-atomizer writing-plans; do
  if [ -d ".claude/skills/$src" ]; then
    awk 'BEGIN{fm=0} /^---$/{fm++; next} fm<2{next} {print}' \
      ".claude/skills/$src/SKILL.md" \
      > ".claude/skills/planning/$src.md"
    rm -rf ".claude/skills/$src/"
  fi
done
```

`planning/SKILL.md` must be created — copy from template.

### 3. External skill imports

```bash
mkdir -p .claude/skills/grill-me .claude/skills/improve-codebase-architecture
curl -sf https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md \
  -o .claude/skills/grill-me/SKILL.md

for f in SKILL.md DEEPENING.md INTERFACE-DESIGN.md LANGUAGE.md; do
  curl -sf "https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/improve-codebase-architecture/$f" \
    -o ".claude/skills/improve-codebase-architecture/$f"
done
```

### 4. Infra: bin/ scripts
Copy from template:
- `bin/outline.sh` (Outline API CLI fallback)
- `bin/psql_ro.sh` (read-only psql wrapper)

```bash
chmod +x bin/*.sh
```

### 5. Doc stubs
Create if missing (do NOT overwrite existing):
- `docs/STACK.md`
- `docs/CONTEXT.md`
- `docs/RUNBOOK.md`
- `docs/adr/0001-template.md`
- `docs/reports/` (directory)

### 6. Hooks
- Add `.claude/hooks/session-start-mcp-check.sh`
- Add `.claude/hooks/session-end-audit.sh`
- `chmod +x .claude/hooks/*.sh`
- Update `.claude/settings.json`:
  - Add `SessionStart` hooks block (calls `session-start-mcp-check.sh`)
  - Add to `Stop` hooks block (calls `session-end-audit.sh`)

### 7. Commands
New commands to add (copy from template):
- `setup.md`
- `general.md`
- `report.md`
- `docs.md`
- `self-audit.md`
- `council.md`
- `da.md`
- `improve-arch.md`

Updated commands (copy from template, replacing old):
- `init-project.md` (now copies bin/, chmod, fills v3 stubs)
- `todo.md` (grill-me instead of ConfidenceChecker)
- `review.md` (Diablo step added)
- `fix.md` (Diablo step added, STACK.md commands)

### 8. Agents (replace from template)
- `diablo.md` — domain tags, Action lines, Next step, doctrine
- `rex.md` — app_type, supply chain, crypto, regression tracking
- `orchestrator.md` — git tag for backups, STACK.md commands, code-reviewer + perf gates
- `test-writer.md` — `model: sonnet`, qa-expert FINDING fallback

### 9. Rules
- `skill-routing.md` — full v3 rewrite
- `workflow.md` — update Outline references
- `project.md` template (NEW project copies it untouched)

### 10. CLAUDE.md
Replace v2 CLAUDE.md with v3 (re-fill placeholders for project name + language).

### 11. .gitignore
Add (if missing):
- `.claude/.setup.json`
- `.claude/cache/`
- `.claude/session-log.jsonl`
- `.rex-findings.json`

### 12. Outline migration (manual user step)
- User decides whether existing local `docs/FAILS.md` and `docs/PATTERNS.md` should be uploaded to Outline `Knowledge Base` shared collections.
- If yes: `/docs publish` after Outline MCP is configured.
- Old data is NOT auto-deleted from local docs.

### 13. Mark migration complete
```bash
cat > .claude/.setup.json <<EOF
{
  "version": 3,
  "ts": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "migrated_from": 2,
  "mcp_outline": "<verify with claude mcp list>",
  "next_steps": [
    "Run /setup to verify and configure MCP if not yet done",
    "Optional: /docs publish to mirror docs/ → Outline Project: <name> collection",
    "Optional: register /loop schedules per .claude/loop-schedules.md"
  ]
}
EOF
```

## After migration

1. `/setup` mode `Verify health` — confirm everything wired up.
2. `/docs audit` — find drift accumulated during v2.
3. Optional: `/self-audit --since <last-v2-date>` — bring process improvements forward.
