#!/usr/bin/env bash
# memory-lint.sh — read-only consistency check for the file-per-lesson memory system
# (docs/fails/F-NNN-*.md + docs/FAILS.md index; docs/patterns/P-NNN-*.md + docs/PATTERNS.md index).
#
# Usage:  bin/memory-lint.sh [project_root]     (default: current directory)
# Checks: duplicate IDs, placeholder IDs (F-XXX/P-XXX/TBD), orphan files / orphan index lines,
#         legacy single-file format (pre-migration projects), stale TASK.md / handoff.md (WARN only).
# Exit:   0 = OK (warnings allowed), 1 = violations found. Read-only — never modifies anything. CI-safe.

set -u

ROOT="${1:-.}"
FAILURES=0
WARNINGS=0

violation() { echo "VIOLATION: $*"; FAILURES=$((FAILURES + 1)); }
warn()      { echo "WARN: $*";      WARNINGS=$((WARNINGS + 1)); }

# file mtime, portable (macOS/BSD then GNU)
mtime_of() { stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null; }

# ---------------------------------------------------------------------------
# Legacy mode: no lesson dir, but old single-file format exists.
# Args: <id_regex_prefix> <index_path> <label>
# ---------------------------------------------------------------------------
legacy_check() {
  local idre="$1" ipath="$2" label="$3"
  echo "INFO: $label — legacy single-file format detected (no lesson dir); running legacy checks"

  # Duplicate IDs among entry headings (## / ### lines)
  local dups
  dups=$(grep -E '^#{1,6} ' "$ipath" 2>/dev/null | grep -oE "${idre}-[0-9]+" | sort | uniq -d)
  local id
  for id in $dups; do
    violation "$label (legacy): duplicate entry ID $id in $ipath"
  done

  # Placeholder junk
  local hits
  hits=$(grep -nE "${idre}-XXX|TBD" "$ipath" 2>/dev/null)
  if [ -n "$hits" ]; then
    while IFS= read -r line; do
      violation "$label (legacy): placeholder in $ipath -> $line"
    done <<EOF
$hits
EOF
  fi
}

# ---------------------------------------------------------------------------
# New-format namespace check.
# Args: <prefix (F|P)> <legacy_id_regex> <lesson_dir> <index_rel> <label>
# ---------------------------------------------------------------------------
check_namespace() {
  local prefix="$1" legacyre="$2" dir="$3" index="$4" label="$5"
  local dpath="$ROOT/$dir" ipath="$ROOT/$index"

  if [ ! -d "$dpath" ]; then
    if [ -f "$ipath" ]; then
      legacy_check "$legacyre" "$ipath" "$label"
    else
      echo "INFO: $label — neither $dir/ nor $index present; skipping"
    fi
    return
  fi

  if [ ! -f "$ipath" ]; then
    violation "$label: lesson dir $dir/ exists but index $index is missing"
    return
  fi

  # --- collect IDs ---
  local file_ids index_ids
  file_ids=$(ls "$dpath" 2>/dev/null | grep -oE "^${prefix}-[0-9]+" | sort)
  index_ids=$(grep -oE "^- \[${prefix}-[0-9]+\]" "$ipath" 2>/dev/null | grep -oE "${prefix}-[0-9]+" | sort)

  local id

  # 1. Duplicate IDs across lesson files
  for id in $(printf '%s\n' "$file_ids" | uniq -d); do
    violation "$label: ID $id used by more than one file in $dir/"
  done

  # 2. Duplicate index lines for one ID
  for id in $(printf '%s\n' "$index_ids" | uniq -d); do
    violation "$label: ID $id listed more than once in $index"
  done

  # 3. Placeholders (F-XXX/P-XXX/TBD) in index and in lesson files
  local hits
  hits=$( { grep -nHE "${prefix}-XXX|TBD" "$ipath"; grep -nHE "${prefix}-XXX|TBD" "$dpath"/*.md 2>/dev/null; } 2>/dev/null )
  if [ -n "$hits" ]; then
    while IFS= read -r line; do
      violation "$label: placeholder -> $line"
    done <<EOF
$hits
EOF
  fi

  # 4. Orphans: file without index line / index line without file
  local uf ui
  uf=$(printf '%s\n' "$file_ids" | sort -u | grep . || true)
  ui=$(printf '%s\n' "$index_ids" | sort -u | grep . || true)
  for id in $(comm -23 <(printf '%s\n' "$uf") <(printf '%s\n' "$ui")); do
    violation "$label: lesson file for $id exists in $dir/ but has no line in $index"
  done
  for id in $(comm -13 <(printf '%s\n' "$uf") <(printf '%s\n' "$ui")); do
    violation "$label: index line for $id in $index but no matching file in $dir/"
  done
}

# ---------------------------------------------------------------------------
# Run checks
# ---------------------------------------------------------------------------
check_namespace "F" "F"       "docs/fails"    "docs/FAILS.md"    "FAILS"
check_namespace "P" "P(AT)?"  "docs/patterns" "docs/PATTERNS.md" "PATTERNS"

# 5. Staleness (WARN only): TASK.md / handoff.md older than 14 days vs last repo commit
LAST_COMMIT=$(git -C "$ROOT" log -1 --format=%ct 2>/dev/null || true)
if [ -n "$LAST_COMMIT" ]; then
  for f in docs/TASK.md docs/handoff.md; do
    if [ -f "$ROOT/$f" ]; then
      FM=$(mtime_of "$ROOT/$f")
      if [ -n "$FM" ] && [ $((LAST_COMMIT - FM)) -gt $((14 * 86400)) ]; then
        warn "$f is >14 days older than the last commit — likely stale, review/refresh it"
      fi
    fi
  done
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo "---"
echo "memory-lint: $FAILURES violation(s), $WARNINGS warning(s)"
if [ "$FAILURES" -gt 0 ]; then
  echo "RESULT: FAIL"
  exit 1
fi
echo "RESULT: OK"
exit 0
