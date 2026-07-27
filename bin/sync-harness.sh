#!/usr/bin/env bash
# sync-harness.sh <project-path> — раскатка обвязки из шаблона в проект (план 0.6).
# Правило: template-defined файлы обновляются, project-customized НИКОГДА не затираются
# (CLAUDE.md, rules/project.md, .setup.json, docs/* — кроме link-fix и rules-references).
# Коммитит [PROCESS]-коммит только со СВОИМИ путями. Требует git-репозиторий.
set -uo pipefail

TPL="$(cd "$(dirname "$0")/.." && pwd)"
PROJ="${1:?usage: sync-harness.sh <project-path>}"
PROJ="$(cd "$PROJ" && pwd)" || { echo "FAIL: no dir $1"; exit 1; }
[ -d "$PROJ/.git" ] || { echo "SKIP: $PROJ is not a git repo"; exit 2; }
[ "$PROJ" = "$TPL" ] && { echo "SKIP: refusing to sync template onto itself"; exit 2; }

echo "=== SYNC $PROJ ==="
cd "$PROJ"
mkdir -p .claude docs

FRESH=0
[ -f ".claude/settings.json" ] || FRESH=1
# чистота project-customized файлов ДО наших правок — грязные не стейджим (не смешиваем чужую работу)
CLAUDE_MD_CLEAN=1; PROJECT_MD_CLEAN=1
[ -n "$(git status --porcelain CLAUDE.md 2>/dev/null)" ] && CLAUDE_MD_CLEAN=0
[ -n "$(git status --porcelain .claude/rules/project.md 2>/dev/null)" ] && PROJECT_MD_CLEAN=0

# --- 1. template-defined каталоги (полная синхронизация по именам шаблона) ---
mkdir -p .claude/hooks .claude/commands .claude/agents .claude/rules .claude/skills .claude/workflows bin
rsync -a "$TPL/.claude/hooks/" .claude/hooks/
rsync -a "$TPL/.claude/commands/" .claude/commands/
rsync -a "$TPL/.claude/agents/" .claude/agents/
rsync -a "$TPL/.claude/workflows/" .claude/workflows/
# never let a stale __pycache__ (present in the template's tree at sync time) get force-added below
find .claude -type d -name '__pycache__' -exec rm -rf {} + 2>/dev/null || true
cp -f "$TPL/.claude/rules/workflow.md" "$TPL/.claude/rules/skill-routing.md" .claude/rules/
# скиллы: каждый шаблонный — зеркально (с удалением устаревших файлов ВНУТРИ скилла)
for S in "$TPL/.claude/skills/"*/; do
  NAME="$(basename "$S")"
  rsync -a --delete "$S" ".claude/skills/$NAME/"
done
# symlink improve + его цель + lock
mkdir -p .agents/skills
rsync -a "$TPL/.agents/skills/improve/" .agents/skills/improve/
ln -sfn ../../.agents/skills/improve .claude/skills/improve
cp -f "$TPL/skills-lock.json" ./skills-lock.json 2>/dev/null || true

# --- 2. отставленные скиллы-учебники: убрать из активных, если остались от старой версии ---
mkdir -p docs/archive/retired-skills
for NAME in docker-expert git-advanced-workflows deploy-strategies api-design clean-code architecture context-compression frontend-design; do
  if [ -d ".claude/skills/$NAME" ]; then
    rm -rf "docs/archive/retired-skills/$NAME"
    mv ".claude/skills/$NAME" "docs/archive/retired-skills/$NAME"
    echo "  retired skill: $NAME"
  fi
done

# --- 3. rules/references -> docs/rules-references (service-secrets — проектный, сохраняем) ---
mkdir -p docs/rules-references
if [ -f ".claude/rules/references/service-secrets.md" ] && ! cmp -s ".claude/rules/references/service-secrets.md" "$TPL/docs/rules-references/service-secrets.md"; then
  cp -f ".claude/rules/references/service-secrets.md" docs/rules-references/service-secrets.md
  echo "  kept project service-secrets.md"
else
  cp -f "$TPL/docs/rules-references/service-secrets.md" docs/rules-references/
fi
for F in "$TPL/docs/rules-references/"*.md; do
  B="$(basename "$F")"; [ "$B" = "service-secrets.md" ] && continue
  cp -f "$F" "docs/rules-references/$B"
done
# template-defined docs living directly under docs/ (not project-customized — see table at top)
cp -f "$TPL/docs/OUTLINE-CONTRACT.md" docs/OUTLINE-CONTRACT.md
cp -f "$TPL/bin/github-kb.sh" bin/github-kb.sh && chmod +x bin/github-kb.sh
if [ -d ".claude/rules/references" ]; then
  mkdir -p docs/archive/old-claude-references
  rsync -a ".claude/rules/references/" docs/archive/old-claude-references/ && rm -rf ".claude/rules/references"
  echo "  moved old .claude/rules/references -> docs/archive/old-claude-references"
fi
# link-fix в project-customized файлах (только замена пути, содержимое не трогаем)
for F in CLAUDE.md .claude/rules/project.md; do
  [ -f "$F" ] && LC_ALL=C sed -i '' 's|\.claude/rules/references/|docs/rules-references/|g' "$F" 2>/dev/null || true
done

# --- 4. settings.json: заменить ТОЛЬКО ключ hooks, остальное проектное сохранить ---
if [ -f ".claude/settings.json" ]; then
  python3 - "$TPL" <<'PYEOF'
import json, sys
tpl = sys.argv[1]
with open(tpl + "/.claude/settings.json") as f: t = json.load(f)
with open(".claude/settings.json") as f: p = json.load(f)
p["hooks"] = t["hooks"]
with open(".claude/settings.json", "w") as f: json.dump(p, f, indent=2, ensure_ascii=False); f.write("\n")
print("  settings.json: hooks section replaced, project keys preserved")
PYEOF
else
  cp "$TPL/.claude/settings.json" .claude/settings.json
  echo "  settings.json: installed fresh"
fi

# --- 5. bin утилиты ---
for B in test-hooks.sh memory-lint.sh harness-metrics.sh run_static.sh wrap-untrusted.py launchd-runner.sh.template; do
  cp -f "$TPL/bin/$B" bin/ && chmod +x "bin/$B"
done
# re-render рендеренного runner'а с новым alert-блоком (сохранив конкретные значения)
if [ -f "bin/launchd-runner.sh" ]; then
  OLD_BIN=$(grep -oE 'CLAUDE_BIN:-[^}]*' bin/launchd-runner.sh | head -1 | sed 's/CLAUDE_BIN:-//')
  sed -e "s|{{CLAUDE_BIN}}|${OLD_BIN:-claude}|" -e "s|{{PROJECT_PATH}}|$PROJ|" "$TPL/bin/launchd-runner.sh.template" > bin/launchd-runner.sh
  chmod +x bin/launchd-runner.sh
  echo "  launchd-runner.sh re-rendered (alerting added)"
fi

# --- 6. CI workflows ---
mkdir -p .github/workflows
cp -f "$TPL/.github/workflows/harness-ci.yml" "$TPL/.github/workflows/claude-review.yml" .github/workflows/

# --- 7. fresh-install: скелеты (только если файла нет — cp -n) ---
if [ "$FRESH" = "1" ]; then
  [ -f CLAUDE.md ] || cp "$TPL/CLAUDE.md" CLAUDE.md
  [ -f .claude/rules/project.md ] || cp "$TPL/.claude/rules/project.md" .claude/rules/project.md
  for D in TASK.md RULES.md FAILS.md PATTERNS.md KNOWLEDGE.md CONVENTIONS.md CONTEXT.md; do
    [ -f "docs/$D" ] || { [ -f "$TPL/docs/$D" ] && cp "$TPL/docs/$D" "docs/$D"; }
  done
  echo "  fresh install: skeletons copied (run /setup in project to customize)"
fi

# --- 8. .gitignore: вернуть .claude под git (план 1.7), но игнорить рабочий мусор ---
touch .gitignore
if grep -qE '^\s*\.claude/?\s*$' .gitignore; then
  LC_ALL=C sed -i '' -E 's|^\s*\.claude/?\s*$|# .claude re-tracked by harness rollout (plan 1.7)|' .gitignore
  echo "  .gitignore: .claude re-tracked"
fi
for IGN in ".claude/session-log/" ".claude/settings.local.json" ".claude/session-inbox.md" ".claude/session-log.jsonl" ".claude/worktrees/" "*.log" "dist/" "build/"; do
  grep -qxF "$IGN" .gitignore || echo "$IGN" >> .gitignore
done

# --- 9. проверки ---
echo "--- verify ---"
python3 -m py_compile .claude/hooks/dispatch.py && echo "  dispatch.py: compiles"
bash bin/test-hooks.sh >/tmp/sync-verify-tests.log 2>&1 && tail -1 /tmp/sync-verify-tests.log || { echo "  TEST FAIL:"; tail -5 /tmp/sync-verify-tests.log; exit 1; }
grep -q "dispatch.py" .claude/settings.json && echo "  settings.json: dispatcher registered"
bash bin/memory-lint.sh . 2>&1 | tail -2

# --- 10. коммит только своих путей ---
git add -f .claude/hooks .claude/commands .claude/agents .claude/workflows .claude/rules/workflow.md .claude/rules/skill-routing.md .claude/skills .agents 2>/dev/null
git add .gitignore bin/test-hooks.sh bin/memory-lint.sh bin/harness-metrics.sh bin/run_static.sh bin/wrap-untrusted.py bin/launchd-runner.sh.template bin/github-kb.sh docs/rules-references docs/OUTLINE-CONTRACT.md .github/workflows/harness-ci.yml .github/workflows/claude-review.yml skills-lock.json 2>/dev/null
git add -f .claude/settings.json 2>/dev/null
[ -f bin/launchd-runner.sh ] && git add bin/launchd-runner.sh
[ -d docs/archive ] && git add docs/archive
[ "$FRESH" = "1" ] && git add CLAUDE.md .claude/rules/project.md docs/*.md 2>/dev/null
[ "$CLAUDE_MD_CLEAN" = "1" ] && git add CLAUDE.md 2>/dev/null
[ "$PROJECT_MD_CLEAN" = "1" ] && git add .claude/rules/project.md 2>/dev/null
if git diff --cached --quiet; then
  echo "  nothing to commit (already up to date)"
else
  git commit -q -m "[PROCESS] Harness v3.2 rollout: live stdin-hooks dispatcher (prefix/secrets/size gates), memory tooling (file-per-lesson lint), review v4, security cycle (improve skill), rules dedup, references relocated" && echo "  committed: $(git log --oneline -1)"
fi
echo "=== DONE $PROJ ==="
