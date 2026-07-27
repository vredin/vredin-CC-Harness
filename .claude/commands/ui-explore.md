---
description: Design exploration — generate 2-3 HTML mockup variants in distinct styles, run single Diablo critique pass, persist winner as design-system MASTER.md before implementation
allowed-tools: Bash, Write, Read, Edit, Glob, Task
argument-hint: <product description> [--quick] [--variants N]
---

> **Style:** Load `caveman-distillate` skill — terse, step-by-step.

# /ui-explore

Generates **distinct** UI mockups before any production code is written. Avoids the default generic-AI-aesthetic trap (bg-gray-50, blue primary, Inter, rounded-lg cards) by forcing aesthetic choice upfront, then validating with adversarial review.

## When to use

- Starting a new feature with UI
- "Make it look good" requests
- User dissatisfied with prior generic-feeling output
- Before committing to a design system for the project

## When NOT to use

- Implementation already underway (this is exploration, not refactor)
- Brand/design system already defined in `design-system/MASTER.md` — use that directly
- Backend-only work

## Arguments

| Arg | Default | Meaning |
|-----|---------|---------|
| `<product description>` | required | e.g. "fintech crypto trading dashboard" — same vocabulary as `ui-ux-pro-max` search |
| `--quick` | off | Generate only 1 mockup with top design system candidate. Skip Diablo critique. ~10k tokens (vs ~30-60k for 3-variant). Use for low-stakes UI. |
| `--variants N` | 3 | Number of mockups to generate (2 or 3 only). |

## Token cost

- Default (3 variants + Diablo + blind jury): **~45-80k tokens** per invocation. Mostly mockup HTML, one Diablo pass, 6 short blind-judge calls (2 per variant).
- `--quick`: **~10k tokens** (skips both Diablo and blind jury).

## Workflow

### STEP 0 — Pre-flight

```bash
# Check ui-ux-pro-max is available
[ -f .claude/skills/ui-ux-pro-max/scripts/search.py ] || { echo "ABORT: ui-ux-pro-max skill missing"; exit 1; }

# Check python3
python3 --version || { echo "ABORT: python3 required"; exit 1; }

# If design-system/MASTER.md already exists, ASK user before proceeding
if [ -f design-system/MASTER.md ]; then
  echo "WARNING: design-system/MASTER.md already exists. Run with --force to overwrite, or use the existing system instead."
fi
```

### STEP 1 — Design system discovery

Parse user query into product/style/industry keywords. Run search:

```bash
python3 .claude/skills/ui-ux-pro-max/scripts/search.py "<user_query>" --design-system -f markdown
```

This returns **one** design system recommendation. To force 3 distinct candidates with deliberately different aesthetics, run search with style overrides:

```bash
# Get base recommendation (variant A)
python3 .claude/skills/ui-ux-pro-max/scripts/search.py "<query>" --design-system -f markdown

# Force variant B — opposite of variant A's style
python3 .claude/skills/ui-ux-pro-max/scripts/search.py "<query> brutalist editorial monospace" --domain style -n 1
python3 .claude/skills/ui-ux-pro-max/scripts/search.py "<query>" --domain color -n 1

# Force variant C — third distinct direction
python3 .claude/skills/ui-ux-pro-max/scripts/search.py "<query> playful vibrant motion" --domain style -n 1
```

**Output:** 3 design system briefs (with `--quick`: 1 brief).

### STEP 1.5 — Load the anti-slop law (BEFORE generating)

Read `docs/rules-references/anti-slop-law.md` now — the taste/composition layer the
detector cannot judge. Then, while composing each variant:
- **Decide the signature FIRST** (law §5) — one focal artifact per variant, not a flat
  fill. Variants must differ in signature, not just palette (a recoloured layout is
  still slop, law §2).
- **Pull section shapes** from `docs/rules-references/hallmark-cookbook.md` — no two
  sections share an archetype, and the three variants pick different archetypes.
- **Apply colour + real-asset rules** from `docs/rules-references/hallmark-color-assets.md`
  (OKLCH, one accent ≤3% of viewport, tinted neutrals, no pure `#000`/`#fff`).
- Avoid the composition skeletons in law §2 and the Google-shelf fonts in law §6.

### STEP 2 — Mockup generation

For each variant, generate a **single page** HTML mockup (hero + 2-3 sections) at `design-explorations/v<N>.html`:

```bash
mkdir -p design-explorations
```

Requirements per mockup:
- **Standalone HTML**: inline `<style>`, no external assets except Google Fonts CDN and `cdn.tailwindcss.com` (if Tailwind). Must open in browser by double-click.
- **Distinct typography**: each variant uses different Google Fonts pair (per ui-ux-pro-max recommendation).
- **Distinct color palette**: each variant pulls from a different color CSV row.
- **Single viewport**: 1440×900 desktop. Mobile responsive is out of scope at this stage.
- **No icons-as-emoji**: SVG (Heroicons inline) or none.
- **Production-quality hero**: actual product copy, not "Lorem ipsum".

Write each mockup with the `Write` tool. Filename format: `design-explorations/v1-<style-tag>.html`, e.g. `design-explorations/v1-glassmorphism.html`.

### STEP 2.5 — Deterministic slop detector (impeccable)

Before spending Diablo tokens, run the offline 44-rule design detector over the generated mockups so Diablo argues over already-slop-free variants:
```bash
IMPECCABLE_NO_UPDATE_CHECK=1 npx --yes impeccable@3.2.1 detect --json design-explorations/
```
Fix any confirmed AI-slop (gradient text, side-stripe borders, low contrast, identical card grids, etc.) in the mockups first. These are deterministic tells, not taste. See `docs/rules-references/frontend-impeccable.md`. If node/npx fails, note and proceed to Diablo.

### STEP 3 — Single Diablo critique pass

> **Token-aware design (S4 mitigation):** ONE Diablo invocation across all 3 mockups, not one per mockup.

Spawn `Diablo` agent with **all 3 mockup paths** in a single invocation:

```
Task: design critique
Input: paths to v1, v2, v3 HTML files + the design system briefs that produced each
Mode: spec attack — attack the design choices before implementation
Focus:
  - Does this variant actually achieve its declared aesthetic, or does it drift to generic-AI defaults?
  - What's the strongest distinctive element? Will it survive contact with real content?
  - Are anti-patterns present (emoji icons, layout shift on hover, low contrast in light mode, fixed navbar overlap)?
  - Will this scale to 5 more pages without breaking? (i.e., is the design language coherent or single-page hack?)
  - What's the laziest copy-paste each variant?
  - For each variant: VERDICT (READY / FIX FIRST / REJECT)
```

**Single Diablo call**, returns ranked critique with verdict per variant.

### STEP 3.5 — Blind jury score (2 judges per variant, no brief shown)

> Diablo (STEP 3) knows the intended style/brief — good for "does this hit what it aimed
> for." This step checks the opposite: does the page communicate its price tier, audience,
> and one action to someone with ZERO context, same test a real first-time visitor faces.
> Mirrors `/global-audit`'s blind-verifier pattern (skeptics get only the claim, never the
> reasoning) — here the judges get only the rendered mockup, never the brief/style-tag/keywords.

For EACH variant, spawn 2 independent judges in parallel (`Agent`, general-purpose). Each
gets ONLY the mockup file path — no product description, no style tag, no design-system brief:

```
You are a first-time visitor landing on this page with zero prior context. Score 0-10 on each:
1. Within 10 seconds, can you tell what's being offered?
2. Can you tell who it's for?
3. Does it signal a price/quality tier (budget / mid / premium)?
4. Is there one clear next action?
5. Typography hierarchy — obvious what to read first?
6. Color/contrast quality?
7. Does it feel like a distinct product, or a generic template?
8. Overall polish (0-10).
State your GUESS of: intended audience, price tier, emotion the page aims for. Then total score /80.
```

Compare each judge's guessed audience/tier/emotion against the ACTUAL brief (known to you,
never shown to the judge). A mismatch — judges guess "budget tool" when the brief said
"premium enterprise" — is a real signal independent of Diablo's structural critique: the
design isn't communicating intent without you explaining it first.

Fold both judges' scores + any audience/tier mismatch into the STEP 4 comparison per
variant. Don't auto-loop fixes on a low score (token-aware — same discipline as the single
Diablo pass above) — surface it, let the user's STEP 4 pick account for it.

### STEP 4 — Present comparison to user

Output to user:

```
## UI Exploration — <query>

### Variant 1: <style-tag>
  Design system: <font pair, palette, anti-patterns avoided>
  Mockup: design-explorations/v1-<tag>.html
  Diablo verdict: <READY|FIX FIRST|REJECT>
  Blind jury: <avg score>/80 — guessed audience/tier: <judge guess> (<matches brief | MISMATCH: brief said <X>>)
  Strongest element: <one-liner>
  Weakest element: <one-liner>

### Variant 2: <style-tag>
  ...

### Variant 3: <style-tag>
  ...

### Diablo overall:
  <comparative critique paragraph>

Pick one (or "none, generate new variants"):
  1 — proceed with v1
  2 — proceed with v2
  3 — proceed with v3
  none — re-run with different keywords
```

**STOP here.** Wait for user pick.

### STEP 5 — Persist winner

On user pick of variant N:

```bash
# Re-run ui-ux-pro-max with --persist for the winning style
python3 .claude/skills/ui-ux-pro-max/scripts/search.py "<query for winner>" --design-system --persist -p "<project name>"
```

This creates `design-system/MASTER.md` with the chosen design system. From this point, all UI work loads MASTER.md as the source of truth.

Append to `design-system/MASTER.md`:
```markdown
## Exploration History

- Selected variant: v<N> (<style-tag>) on <YYYY-MM-DD>
- Diablo verdict: <verdict>
- Rejected: v<X> (<reason>), v<Y> (<reason>)
- Mockup preserved at: design-explorations/v<N>-<tag>.html (DO NOT DELETE — reference for implementation)
```

Cleanup rejected mockups (keep only the chosen one):
```bash
# Move losers to design-explorations/.archive/ instead of deleting
mkdir -p design-explorations/.archive
mv design-explorations/v<rejected>-*.html design-explorations/.archive/
```

### STEP 6 — Add to .gitignore

If `.gitignore` doesn't already exclude `design-explorations/`, add it (we don't want exploration mockups in main history — only the chosen MASTER.md and the winning mockup matter):

```bash
grep -q "^design-explorations/$" .gitignore 2>/dev/null || echo "design-explorations/" >> .gitignore
```

> Exception: if your team uses `design-explorations/v*.html` for stakeholder review, override by removing the gitignore entry. Default is to keep main branch clean.

### STEP 7 — Notify user + next steps

```
✅ Design system locked in: design-system/MASTER.md
   Winner: v<N> (<style-tag>)
   Mockup preserved at: design-explorations/v<N>-<tag>.html

Next steps:
  - All future UI work must load MASTER.md first
  - For page-specific overrides: ui-ux-pro-max --persist --page "<page name>"
  - Run /review on first real implementation page to catch drift from MASTER.md
```

---

## --quick mode (single variant, no Diablo)

When `--quick` is passed:

1. STEP 1: ONE search call (top recommendation only)
2. STEP 2: ONE mockup at `design-explorations/v1-<tag>.html`
3. SKIP STEP 3 (no Diablo) and STEP 3.5 (no blind jury)
4. STEP 4: Show user the single mockup path + design system summary
5. STEP 5: On confirmation → persist

Use when: prototyping, internal admin pages, low-stakes UI.
**Don't use** when: public-facing marketing, premium product surfaces, design-critical features.

---

## Rules

- **NEVER** generate variants with identical color palettes or font pairs (defeats the purpose)
- **NEVER** skip Diablo on default (3-variant) mode — that's the point of /ui-explore vs running ui-ux-pro-max directly
- **NEVER** delete rejected mockups outright — archive to `.archive/` (debugging / change-of-mind value)
- **ALWAYS** persist winner before declaring done. Without MASTER.md, future sessions re-explore from scratch.
- **ALWAYS** check existing MASTER.md first — exploration is for new projects/sections, not for re-litigating existing decisions

---

## Related

- `.claude/skills/ui-ux-pro-max/SKILL.md` — search and design system base
- `.claude/agents/diablo.md` — critique agent
- impeccable detector critique (`npx impeccable detect`, auto in /review STEP 4.5) — runs after first real page implementation (design-reviewer agent retired 2026-07-03)
- `.claude/rules/skill-routing.md` — see "New feature with UI" routing
