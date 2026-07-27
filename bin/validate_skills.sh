#!/usr/bin/env bash
# bin/validate_skills.sh — validate .claude/skills/*/SKILL.md frontmatter
#
# What it reads:  every .claude/skills/*/SKILL.md in the project
# What it writes: stdout only (no files modified)
# Network access: no
# Runtime class:  seconds (<2s for ~30 skills)
# Secrets risk:   none — only reads SKILL.md frontmatter
#
# Exit codes:
#   0  — all skills valid
#   1  — one or more skills failed validation
#   2  — usage error (no .claude/skills/ found)
#
# Checks per SKILL.md:
#   - File exists and is readable
#   - Has YAML frontmatter (--- ... ---)
#   - Frontmatter contains `name:` field
#   - Frontmatter contains `description:` field
#   - Optional: warns if SKILL.md is very long (>500 lines)
#   - Optional: warns if description is suspiciously short (<20 chars) or long (>500 chars)
#
# Usage:
#   bin/validate_skills.sh                       # validate all skills in cwd
#   bin/validate_skills.sh /path/to/project     # validate skills in given project root
#   bin/validate_skills.sh --quiet              # only report failures

set -euo pipefail

PROJECT_ROOT="."
QUIET=0
for arg in "$@"; do
  case "$arg" in
    --quiet|-q) QUIET=1 ;;
    --help|-h)
      sed -n '2,30p' "$0"
      exit 0
      ;;
    *) PROJECT_ROOT="$arg" ;;
  esac
done

SKILLS_DIR="$PROJECT_ROOT/.claude/skills"

if [ ! -d "$SKILLS_DIR" ]; then
  echo "ERROR: no .claude/skills/ directory at $PROJECT_ROOT" >&2
  exit 2
fi

total=0
passed=0
failed=0
warnings=0

# Iterate top-level skill directories only
while IFS= read -r -d '' skill_dir; do
  skill_name=$(basename "$skill_dir")
  skill_md="$skill_dir/SKILL.md"
  total=$((total + 1))

  # 1. SKILL.md must exist
  if [ ! -f "$skill_md" ]; then
    echo "FAIL: $skill_name — missing SKILL.md"
    failed=$((failed + 1))
    continue
  fi

  # 2. Read frontmatter (between first two `---` lines)
  # Extract lines between the two `---` markers (only if file starts with `---`)
  first_line=$(head -1 "$skill_md")
  if [ "$first_line" != "---" ]; then
    echo "FAIL: $skill_name — SKILL.md has no YAML frontmatter (must start with ---)"
    failed=$((failed + 1))
    continue
  fi

  # Extract frontmatter block
  frontmatter=$(awk '/^---$/{c++; next} c==1' "$skill_md")

  if [ -z "$frontmatter" ]; then
    echo "FAIL: $skill_name — empty or unterminated frontmatter"
    failed=$((failed + 1))
    continue
  fi

  # 3. name field
  name_line=$(printf '%s\n' "$frontmatter" | grep -E "^name:" | head -1)
  if [ -z "$name_line" ]; then
    echo "FAIL: $skill_name — frontmatter missing 'name:' field"
    failed=$((failed + 1))
    continue
  fi

  # 4. description field (can be inline or multi-line YAML)
  desc_line=$(printf '%s\n' "$frontmatter" | grep -E "^description:" | head -1)
  if [ -z "$desc_line" ]; then
    echo "FAIL: $skill_name — frontmatter missing 'description:' field"
    failed=$((failed + 1))
    continue
  fi

  # 5. Soft warnings
  skill_warns=0

  # Line count warning
  lines=$(wc -l < "$skill_md" | tr -d ' ')
  if [ "$lines" -gt 500 ]; then
    if [ "$QUIET" -eq 0 ]; then
      echo "WARN: $skill_name — SKILL.md is $lines lines (consider splitting refs to references/)"
    fi
    skill_warns=$((skill_warns + 1))
  fi

  # Description length sanity
  # Strip "description:" prefix and surrounding > | block markers; estimate length
  desc_value=$(printf '%s\n' "$desc_line" | sed -E 's/^description:[[:space:]]*[>|]?[[:space:]]*//')
  # If inline description is suspiciously short, check if there's a multi-line value
  if [ "${#desc_value}" -lt 20 ]; then
    # Try to gather multi-line description
    multi_desc=$(printf '%s\n' "$frontmatter" | awk '/^description:/{flag=1; next} /^[a-z_]+:/{flag=0} flag' | tr '\n' ' ')
    desc_value="$desc_value $multi_desc"
  fi
  desc_len=${#desc_value}

  if [ "$desc_len" -lt 20 ]; then
    if [ "$QUIET" -eq 0 ]; then
      echo "WARN: $skill_name — description is short ($desc_len chars). Add trigger context for the agent."
    fi
    skill_warns=$((skill_warns + 1))
  elif [ "$desc_len" -gt 500 ]; then
    if [ "$QUIET" -eq 0 ]; then
      echo "WARN: $skill_name — description is long ($desc_len chars). Consider moving detail into the body."
    fi
    skill_warns=$((skill_warns + 1))
  fi

  warnings=$((warnings + skill_warns))
  passed=$((passed + 1))
  [ "$QUIET" -eq 0 ] && echo "PASS: $skill_name ($lines lines, description ${desc_len}c, warnings $skill_warns)"
done < <(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d -print0)

# Final summary
echo ""
echo "=== Summary ==="
echo "Total skills: $total"
echo "Passed:       $passed"
echo "Failed:       $failed"
echo "Warnings:     $warnings"

if [ "$failed" -gt 0 ]; then
  exit 1
fi
exit 0
