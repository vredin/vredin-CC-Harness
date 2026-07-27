#!/usr/bin/env bash
# run_static.sh — deterministic static pre-pass BEFORE expensive LLM review.
# Catches the mechanical layer (lint, types, security lint, dead code,
# complexity, secrets) so LLM reviewers never burn tokens on it.
#
# Usage:   bin/run_static.sh [--gate] [file ...]
#          No files → default scope: git diff --name-only HEAD + staged.
# Tools:   all files file-length (wc), jscpd copy-paste (if installed)
#          .py       ruff check, mypy --ignore-missing-imports, bandit -q,
#                    vulture --min-confidence 90, radon cc -n C,
#                    ruff-shape (forced complexity/branches/statements/nesting/
#                    params via ruff's pylint-derived rules, --isolated),
#                    complexipy (cognitive complexity, if installed)
#          .ts/.tsx/.js/.jsx  tsc --noEmit (if tsconfig), eslint (if config),
#                    eslint-shape (forced complexity/length/nesting/params rules
#                    via the project's @typescript-eslint parser, if installed)
#          all files detect-secrets scan, else gitleaks per file
# Thresholds (env override): MAX_FILE_LINES=400, MAX_FUNC_LINES=50, MAX_NESTING=4,
#          MAX_PARAMS=6, PY_MAX_COMPLEXITY=10, PY_MAX_BRANCHES=12,
#          PY_MAX_STATEMENTS=50, PY_MAX_COGNITIVE=15, JS_MAX_COMPLEXITY=10,
#          JS_MAX_STATEMENTS=30, DUP_MIN_LINES=10, DUP_MIN_TOKENS=70.
# Missing/unconfigured tool → one-line SKIP, never an error.
# Output:  per-tool sections, findings only. Summary line at the end.
# Exit:    always 0; with --gate → 1 when findings exist (for CI).
# Reads:   listed files + tool configs. Writes: stdout only (jscpd uses a
#          mktemp dir, removed before exit). Network: none.

set -u

GATE=0
FILES=()
for a in "$@"; do
  case "$a" in
    --gate) GATE=1 ;;
    *) FILES+=("$a") ;;
  esac
done

if [ ${#FILES[@]} -eq 0 ]; then
  while IFS= read -r f; do
    [ -n "$f" ] && FILES+=("$f")
  done < <({ git diff --name-only HEAD 2>/dev/null; git diff --name-only --cached 2>/dev/null; } | sort -u)
fi

PY=(); TS=()
EXISTING=()
for f in "${FILES[@]:-}"; do
  [ -f "$f" ] || continue
  EXISTING+=("$f")
  case "$f" in
    *.py) PY+=("$f") ;;
    *.ts|*.tsx|*.js|*.jsx) TS+=("$f") ;;
  esac
done

if [ ${#EXISTING[@]} -eq 0 ]; then
  echo "run_static: no files in scope (nothing changed?)"
  echo "SUMMARY: 0 findings across 0 tools, 0 skipped"
  exit 0
fi

echo "run_static: scope = ${#EXISTING[@]} files (${#PY[@]} py, ${#TS[@]} ts/js)"

TOTAL=0; TOOLS_RAN=0; SKIPPED=0

skip()    { echo "SKIP: $1"; SKIPPED=$((SKIPPED + 1)); }
# report <tool> <findings-count> <output>
report() {
  TOOLS_RAN=$((TOOLS_RAN + 1))
  if [ "$2" -gt 0 ]; then
    TOTAL=$((TOTAL + $2))
    echo ""
    echo "== $1 — $2 finding(s) =="
    echo "$3"
  fi
}

# ---------------- File length (all languages) ----------------
MAX_FILE_LINES=${MAX_FILE_LINES:-400}
OUT=""
for f in "${EXISTING[@]}"; do
  L=$(awk 'END{print NR}' "$f" 2>/dev/null || echo 0)
  if [ "${L:-0}" -gt "$MAX_FILE_LINES" ]; then
    SEV=""; [ "$L" -gt $((MAX_FILE_LINES * 2)) ] && SEV="  <-- SEVERE (>2x limit)"
    OUT="${OUT}${f}: ${L} lines (limit ${MAX_FILE_LINES})${SEV}
"
  fi
done
OUT=$(printf '%s' "$OUT" | grep -v '^$' || true)
report "file-length (>${MAX_FILE_LINES} lines)" "$(printf '%s' "$OUT" | grep -c . || true)" "$OUT"

# ---------------- Python ----------------
if [ ${#PY[@]} -gt 0 ]; then
  if command -v ruff >/dev/null 2>&1; then
    OUT=$(ruff check --no-fix --output-format concise "${PY[@]}" 2>&1 | grep -Ev '^(Found [0-9]+|All checks passed|\[\*\]|warning:)' | grep -v '^$' || true)
    report "ruff" "$(printf '%s' "$OUT" | grep -c . || true)" "$OUT"
  else skip "ruff not installed"; fi

  if command -v mypy >/dev/null 2>&1; then
    OUT=$(mypy --ignore-missing-imports --no-error-summary "${PY[@]}" 2>&1 | grep -E ': (error|warning):' || true)
    report "mypy" "$(printf '%s' "$OUT" | grep -c . || true)" "$OUT"
  else skip "mypy not installed"; fi

  if command -v bandit >/dev/null 2>&1; then
    OUT=$(bandit -q "${PY[@]}" 2>/dev/null | awk '/^Code scanned:/{exit} /^(Run started|Test results:)/{next} {print}' || true)
    N=$(printf '%s' "$OUT" | grep -c '^>> Issue' || true)
    report "bandit" "$N" "$OUT"
  else skip "bandit not installed"; fi

  if command -v vulture >/dev/null 2>&1; then
    WL=()
    [ -f .vulture_whitelist.py ] && WL=(.vulture_whitelist.py)
    OUT=$(vulture "${PY[@]}" "${WL[@]:-}" --min-confidence 90 2>/dev/null | grep -v '^$' || true)
    report "vulture (dead code, confidence>=90)" "$(printf '%s' "$OUT" | grep -c . || true)" "$OUT"
  else skip "vulture not installed"; fi

  if command -v radon >/dev/null 2>&1; then
    OUT=$(radon cc -n C "${PY[@]}" 2>/dev/null | grep -v '^$' || true)
    N=$(printf '%s' "$OUT" | grep -cE '^\s+[MCF]' || true)
    report "radon (complexity C or worse)" "$N" "$OUT"
  else skip "radon not installed"; fi

  # code-shape: forced complexity / branches / statements / nesting / params via
  # ruff's pylint-derived rules, independent of the project's ruff config
  # (--isolated). PLR1702 (nesting) is a preview rule → --preview enables it.
  if command -v ruff >/dev/null 2>&1; then
    OUT=$(ruff check --isolated --preview --output-format concise \
      --select "C901,PLR0912,PLR0913,PLR0915,PLR1702" \
      --config "lint.mccabe.max-complexity=${PY_MAX_COMPLEXITY:-10}" \
      --config "lint.pylint.max-args=${MAX_PARAMS:-6}" \
      --config "lint.pylint.max-branches=${PY_MAX_BRANCHES:-12}" \
      --config "lint.pylint.max-statements=${PY_MAX_STATEMENTS:-50}" \
      --config "lint.pylint.max-nested-blocks=${MAX_NESTING:-4}" \
      "${PY[@]}" 2>/dev/null | grep -E 'C901|PLR[0-9]' || true)
    report "ruff-shape (complexity / branches / statements / nesting / params)" "$(printf '%s' "$OUT" | grep -c . || true)" "$OUT"
  else skip "ruff-shape (ruff not installed)"; fi

  # cognitive complexity — how hard code is to READ (penalises nesting), a
  # different signal from cyclomatic C901; catches nesting-heavy functions the
  # branch count under-rates. Reports by function name (complexipy gives no line).
  if command -v complexipy >/dev/null 2>&1; then
    CJ=$(mktemp -d)
    complexipy -i -q --output-format json --output "$CJ/c.json" "${PY[@]}" >/dev/null 2>&1 || true
    OUT=$(python3 - "$CJ/c.json" "${PY_MAX_COGNITIVE:-15}" <<'PYEOF' 2>/dev/null || true
import json, sys
try:
    d = json.load(open(sys.argv[1]))
except Exception:
    sys.exit(0)
th = int(sys.argv[2])
for f in sorted(d, key=lambda x: -x.get("complexity", 0)):
    if f.get("complexity", 0) > th:
        print("%s: %s() cognitive complexity %s (>%d)" % (
            f.get("path", "?"), f.get("function_name", "?"), f["complexity"], th))
PYEOF
)
    rm -rf "$CJ"
    report "complexipy (cognitive complexity)" "$(printf '%s' "$OUT" | grep -c . || true)" "$OUT"
  else skip "complexipy (cognitive complexity — 'pip install complexipy' to enable)"; fi
fi

# ---------------- TypeScript / JavaScript ----------------
if [ ${#TS[@]} -gt 0 ]; then
  if [ -f tsconfig.json ] && command -v npx >/dev/null 2>&1 && npx --no-install tsc --version >/dev/null 2>&1; then
    OUT=$(npx --no-install tsc --noEmit 2>&1 | grep -E 'error TS' || true)
    report "tsc --noEmit" "$(printf '%s' "$OUT" | grep -c . || true)" "$OUT"
  else skip "tsc (no tsconfig.json or tsc not installed)"; fi

  ESLINT_CFG=$(ls .eslintrc .eslintrc.* eslint.config.* 2>/dev/null | head -1 || true)
  if [ -n "$ESLINT_CFG" ] && command -v npx >/dev/null 2>&1 && npx --no-install eslint --version >/dev/null 2>&1; then
    OUT=$(npx --no-install eslint --format json "${TS[@]}" 2>/dev/null | python3 -c '
import json, os, sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
for f in d:
    for m in f.get("messages", []):
        if m.get("ruleId"):
            print("%s:%s:%s: %s [%s]" % (os.path.relpath(f["filePath"]), m.get("line","?"), m.get("column","?"), m.get("message","").rstrip("."), m["ruleId"]))
' || true)
    report "eslint" "$(printf '%s' "$OUT" | grep -c . || true)" "$OUT"
  else skip "eslint (no config or not installed)"; fi

  # code-shape: forced function-length / complexity / nesting / params, independent
  # of the project's own eslint rules. Uses the project's real @typescript-eslint
  # parser (real AST, no transpile noise) — needs eslint + @typescript-eslint/parser
  # installed in the project; SKIPs cleanly otherwise.
  SHAPE_DIR=$(cd "$(dirname "${TS[0]}")" 2>/dev/null && pwd || true)
  SP=""; SESLINT=""; d="$SHAPE_DIR"
  while [ -n "$d" ] && [ "$d" != "/" ]; do
    [ -z "$SP" ] && [ -e "$d/node_modules/@typescript-eslint/parser" ] && SP="$d"
    [ -z "$SESLINT" ] && [ -x "$d/node_modules/.bin/eslint" ] && SESLINT="$d/node_modules/.bin/eslint"
    [ -n "$SP" ] && [ -n "$SESLINT" ] && break
    d=$(dirname "$d")
  done
  if [ -n "$SP" ] && [ -n "$SESLINT" ] && command -v node >/dev/null 2>&1; then
    PMAIN=$(cd "$SP" && node -e "process.stdout.write(require.resolve('@typescript-eslint/parser'))" 2>/dev/null || true)
    if [ -n "$PMAIN" ]; then
      SHP=$(mktemp -d)
      cat > "$SHP/shape.mjs" <<EOF
import tsParser from '${PMAIN}';
export default [{
  files: ['**/*.ts','**/*.tsx','**/*.js','**/*.jsx'],
  languageOptions: { parser: tsParser, ecmaVersion: 2022, sourceType: 'module' },
  rules: {
    'complexity': ['warn', ${JS_MAX_COMPLEXITY:-10}],
    'max-depth': ['warn', ${MAX_NESTING:-4}],
    'max-params': ['warn', ${MAX_PARAMS:-6}],
    'max-lines-per-function': ['warn', { max: ${MAX_FUNC_LINES:-50}, skipBlankLines: true, skipComments: true }],
    'max-nested-callbacks': ['warn', 4],
    'max-statements': ['warn', ${JS_MAX_STATEMENTS:-30}],
  },
}];
EOF
      ABS=(); for t in "${TS[@]}"; do ABS+=("$(cd "$(dirname "$t")" && pwd)/$(basename "$t")"); done
      # run from the project dir so eslint's `files` glob matches (it resolves
      # patterns relative to cwd; abs file paths outside cwd would never match)
      OUT=$(cd "$SP" && ESLINT_USE_FLAT_CONFIG=true "$SESLINT" --no-config-lookup --config "$SHP/shape.mjs" --format json "${ABS[@]}" 2>/dev/null | python3 -c '
import json, os, sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
for f in d:
    for m in f.get("messages", []):
        if m.get("ruleId"):
            print("%s:%s: %s [%s]" % (os.path.relpath(f["filePath"]), m.get("line","?"), m.get("message","").rstrip("."), m["ruleId"]))
' || true)
      rm -rf "$SHP"
      report "eslint-shape (function length / complexity / nesting / params)" "$(printf '%s' "$OUT" | grep -c . || true)" "$OUT"
    else skip "eslint-shape (could not resolve @typescript-eslint/parser)"; fi
  else skip "eslint-shape (eslint + @typescript-eslint/parser not in project)"; fi
fi

# ---------------- Duplication / copy-paste (all languages) ----------------
if command -v npx >/dev/null 2>&1 && npx --no-install jscpd --version >/dev/null 2>&1; then
  TMPD=$(mktemp -d)
  npx --no-install jscpd --silent --absolute --reporters json --output "$TMPD" \
      --min-lines "${DUP_MIN_LINES:-10}" --min-tokens "${DUP_MIN_TOKENS:-70}" \
      "${EXISTING[@]}" >/dev/null 2>&1 || true
  OUT=$(python3 - "$TMPD/jscpd-report.json" <<'PYEOF' 2>/dev/null || true
import json, os, sys
try:
    d = json.load(open(sys.argv[1]))
except Exception:
    sys.exit(0)
def loc(f):
    return "%s:%s" % (os.path.relpath(f.get("name", "?")),
                      f.get("startLoc", {}).get("line", f.get("start", "?")))
for dup in d.get("duplicates", []):
    print("%s <-> %s (%s lines duplicated)" % (
        loc(dup.get("firstFile", {})), loc(dup.get("secondFile", {})), dup.get("lines")))
PYEOF
)
  rm -rf "$TMPD"
  report "jscpd (copy-paste blocks)" "$(printf '%s' "$OUT" | grep -c . || true)" "$OUT"
else
  skip "jscpd (copy-paste detector not installed — 'npm i -g jscpd' to enable)"
fi

# ---------------- Secrets (all files) ----------------
if command -v detect-secrets >/dev/null 2>&1; then
  OUT=$(detect-secrets scan "${EXISTING[@]}" 2>/dev/null | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)
for path, hits in sorted(data.get("results", {}).items()):
    for h in hits:
        print("%s:%s: %s" % (path, h.get("line_number", 0), h.get("type", "?")))
' || true)
  report "detect-secrets" "$(printf '%s' "$OUT" | grep -c . || true)" "$OUT"
elif command -v gitleaks >/dev/null 2>&1; then
  OUT=""
  for f in "${EXISTING[@]}"; do
    HITS=$(gitleaks detect --no-git --no-banner --source "$f" -v 2>/dev/null | grep -E '^(Finding|Secret|RuleID|File|Line):' || true)
    [ -n "$HITS" ] && OUT="${OUT}${f}:
${HITS}
"
  done
  N=$(printf '%s' "$OUT" | grep -c '^RuleID:' || true)
  report "gitleaks" "$N" "$OUT"
else
  skip "secrets scan (neither detect-secrets nor gitleaks installed)"
fi

echo ""
echo "SUMMARY: $TOTAL findings across $TOOLS_RAN tools, $SKIPPED skipped"

if [ "$GATE" -eq 1 ] && [ "$TOTAL" -gt 0 ]; then
  exit 1
fi
exit 0
