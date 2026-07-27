# Orthogonal Edit Detection — scope-drift check for `/da impl`

> Moved out of `.claude/agents/diablo.md` 2026-07-03 (agent-prompt slimming). Diablo runs
> this at `/da impl` mode for T-NNN tasks to catch «while I was here» drive-by edits that
> BACKUP commits + tests can't prevent — only catch after the fact.

When attacking implementation that maps to a T-NNN spec, compare files-changed against the
spec's Deliverables (section 6) and Technical Approach (section 5).

```bash
# Get spec
SPEC=$(ls docs/specs/T-NNN-*.md 2>/dev/null | head -1)
[ -z "$SPEC" ] && skip orthogonal check  # no spec = no scope = skip this check

# Files in diff
CHANGED=$(git diff --name-only HEAD~1 2>/dev/null || git diff --name-only --cached)

# Files declared in spec section 6 (Deliverables) and section 5 (Technical Approach)
DECLARED=$(awk '/^## 5\./,/^## 6\./' "$SPEC" | grep -oE 'app/[a-z_/]+\.py|src/[a-z_/]+\.[tj]sx?|tests?/[a-z_/]+\.py' | sort -u)
DECLARED_DIR=$(awk '/^## 6\./,/^## 7\./' "$SPEC" | grep -oE '`[^`]+\.[a-z]+`|`[^`]+/[^`]+`' | tr -d '`' | sort -u)
```

For each file in CHANGED:

- **Whitelisted (always OK without flag)**:
  - `tests/**` files (test files for any change are legitimate)
  - `docs/specs/T-NNN-*.md` (the spec itself)
  - `docs/FAILS.md`, `docs/PATTERNS.md` (auto-publish writes)
  - `docs/handoff.md`, `docs/TASK.md` (status tracking)
  - `__init__.py` files in same dir as a declared file (export surface)

- **Same-directory expansion (SUSPICIOUS, not FATAL)**:
  - File in same directory as a declared file. Likely related but possibly scope creep.
  - Verify: does this change support the declared deliverable? Or is it «while I was here» drive-by?

- **Cross-module (FATAL [CORRECTNESS])**:
  - File in entirely different module/package than any declared file.
  - Example: spec says deliver `app/services/altegio_client.py`, diff includes `app/services/recommender.py` and `app/services/payments.py`. recommender.py and payments.py are FATAL orthogonal.
  - Action: «File `<path>` is not in spec section 6 Deliverables nor section 5 Technical Approach. Remove from this commit OR add explicit justification to spec (with re-run of /da spec) OR open a separate T-NNN for it.»

If user explicitly notes in spec section 11 (Red Flags) that this T-NNN intentionally has
cross-cutting changes — accept with SUSPICIOUS warning, not FATAL block.
