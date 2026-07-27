---
name: ui
description: 'Single front door for ALL UI/design work. Say what you want in plain words; it classifies intent and routes to the right engine (explore / build / polish / critique / reason / reference). You never need to remember impeccable, ui-explore, or the sub-operations.'
argument-hint: <what you want, in plain words — e.g. "сделай лендинг", "поправь отступы", "почему кнопку не видно", "покритикуй экран", "какие шрифты взять">
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Skill, Task
model: sonnet
---

> **Style:** Load `caveman-distillate` skill — terse, answer-first.

# /ui — the only UI command you need

You describe the goal in plain language. This command figures out which engine fits and runs
it, loading the right design layers automatically. The underlying engines (`impeccable`,
`/ui-explore`, the reference files) still exist, but you never have to remember them or their
sub-operations.

**The layers it orchestrates (you don't call these directly):**
- `impeccable` skill — build/redesign/polish/critique + the offline 44-rule slop detector.
- `/ui-explore` — generate several distinct mockup directions before committing.
- `ui-first-principles` skill — the "why": hierarchy + operability reasoning.
- `docs/rules-references/anti-slop-law.md` — taste / composition / signature (+ vendored
  `hallmark-cookbook.md` shapes, `hallmark-color-assets.md` colour+assets).
- `ui-ux-pro-max` skill — style / palette / font menu.

---

## STEP 1 — Classify intent from `$ARGUMENTS`

Read the request and pick ONE primary route (a request may chain routes — do them in order).
If `$ARGUMENTS` is empty → print the tiny menu (bottom of this file) and stop.

| If the user is asking to… (examples, any language) | Route |
|---|---|
| explore / brainstorm / "show me directions" / "make it distinctive" / new screen with no chosen look | **EXPLORE** |
| build / create / redesign / implement a screen or component | **BUILD** |
| polish / fix spacing / colours / typography / "remove the AI look" / tighten | **POLISH** |
| critique / review / audit / "why does this look bad/cheap/generic" | **CRITIQUE** |
| reason / justify / "why this over that" / "is this usable" / "why can't the user find X" / "what should read first" | **REASON** |
| pick a style / palette / font / "what should this look like" | **REFERENCE** |

Ambiguous between two routes → ask ONE short question. Otherwise proceed, and state which
route you chose in one line ("Route: POLISH — running impeccable polish on <target>").

---

## STEP 2 — Dispatch

### EXPLORE
Run the `/ui-explore` flow (invoke Skill `ui-explore` with the product description). That flow
already loads `anti-slop-law.md` (signature-first), pulls shapes from `hallmark-cookbook.md`,
palette from `hallmark-color-assets.md`, and runs the slop detector + one Diablo pass. Output:
distinct mockup variants → user picks → persisted to `design-system/MASTER.md`.

### BUILD
1. Load `docs/rules-references/anti-slop-law.md` (decide the signature FIRST) and the
   `ui-first-principles` skill (rank hierarchy, guarantee operability).
2. If `design-system/MASTER.md` exists → follow it; else offer EXPLORE first for a new look.
3. **Two-pass token plan (before any code).** Pass 1 — draft a compact plan: palette as
   4–6 NAMED hex values, type roles (characterful display used with restraint +
   complementary body + optional utility face), a one-sentence layout concept (ASCII
   wireframe if comparing), and THE signature element. Pass 2 — the generic-default
   self-test: mentally run a *similar* brief; if you'd arrive at the same plan (or at one
   of the three 2026 default looks — anti-slop-law §2), that part is a default, not a
   choice — revise it and say what changed. Only then write code, deriving every colour
   and type decision from the revised plan.
4. Invoke Skill `impeccable` with `craft` (new) or `shape` (restructure existing) on the target.
   While coding, watch CSS selector specificity — type-level and class-level rules that
   cancel each other (esp. section paddings/margins) are a frequent silent breakage.
5. Before done: run the detector — `IMPECCABLE_NO_UPDATE_CHECK=1 npx --yes impeccable@3.2.1
   detect --json <changed files>` — and fix confirmed slop. Frontend change ⇒ E2E gate applies
   (see `/review` STEP 4.6 / `.claude/rules/workflow.md` § E2E Test Discipline).

### POLISH
Invoke Skill `impeccable` with the matching operation from the request:
`polish` (general), `colorize` (colour), `typeset` (type), `layout` (spacing/alignment),
`quieter`/`bolder` (intensity), `animate` (motion), `harden` (a11y/robustness). Then run the
detector on changed files and fix confirmed slop. Keep changes surgical; don't redesign under
"polish".

### CRITIQUE
1. Run the detector for the measurable layer:
   `IMPECCABLE_NO_UPDATE_CHECK=1 npx --yes impeccable@3.2.1 detect --json <target>`.
2. Invoke Skill `impeccable` `critique` (UX) or `audit` (a11y/perf/responsive) for depth.
3. Load `ui-first-principles` to explain the *why* behind structural findings (hierarchy,
   grouping, discoverability) and `anti-slop-law.md` for taste/composition/signature gaps.
4. **Focus & accent map (MANDATORY — one per screen/section in scope).** This is the "what does the
   eye land on, and is that the right thing" audit. Load `ui-first-principles` (visual hierarchy) +
   `docs/rules-references/design-principles.md` (Von Restorff/isolation, Fitts's Law for target size,
   signal-to-noise, aesthetic-usability). For EACH screen produce:
   - **Intended primary** — the ONE action/message the business wants this screen to drive (the CTA,
     the key number, the decision). If unclear from the screen, ask the owner one line — do not guess.
   - **Actual reading order** — do the squint test: what reads 1st / 2nd / 3rd by visual weight (size,
     contrast, accent colour, position, isolation/whitespace, motion). State it explicitly.
   - **Accent spend** — where the attention colour + emphasis actually go. Flag accent LEAKED onto
     secondary/decorative elements, or the real primary left under-weighted.
   - **Verdict:** ALIGNED (emphasis leads to the intended primary) / MISALIGNED (two things compete for
     first; accent on the wrong thing; focal point is decorative not functional; primary CTA weaker than
     a neighbour). Cite the principle. Each MISALIGNED names the concrete fix (what to up-weight /
     down-weight / recolour / move).
5. **UI test coverage (MANDATORY).** The "is this UI actually tested" audit — ties to `.claude/rules/
   workflow.md` § E2E Test Discipline + CLAUDE.md § UI Task Completion Gate. For each screen/flow in scope:
   - **E2E spec** — is there a `tests/e2e/*.spec.ts` (Playwright) exercising this flow? `grep` the specs.
     Frontend surface with NO spec → finding.
   - **States tested** — for every data-fetch: are loading / empty / error states rendered AND asserted
     (not just the success path)? Missing state = finding (this is the silent-UI-failure class).
   - **Flow length** — count clicks from load to the screen's primary action; flag if over the PRD/AC
     budget (default ≤5).
   - Report as covered / gaps; route gaps to `test-writer` (write the spec) or `/todo add`.
6. Report worst-first: measurable slop (fix without discussion) → **focus/accent MISALIGNMENTS**
   (per-screen, with the intended-primary vs actual-reading-order) → structural (with the first-principles
   reason) → **test-coverage gaps** → taste/signature. Each finding names the fix. Lead the summary with,
   per screen: "primary = X; eye lands on = Y; ALIGNED/MISALIGNED" so the accent verdict is scannable.

### REASON
Load the `ui-first-principles` skill and answer from it: hierarchy (what reads first + why),
operability (affordances/feedback/gulfs), grouping/cognitive-load. For a named principle it
doesn't carry (Fitts's/Hick's Law, 80/20, aesthetic-usability, signal-to-noise, defaults,
framing, redundancy, progressive disclosure…), also load
`docs/rules-references/design-principles.md`. State the rule you're applying so the decision is
defensible. No styling output here — this is the "why".

### REFERENCE
Invoke the `ui-ux-pro-max` skill (style / palette / font search) for options; cross-check
picks against `anti-slop-law.md` § fonts (off-the-Google-shelf rule) so a "safe" pick isn't
slop. Return a small ranked shortlist with reasons, not one default.

---

## Tiny menu (shown when `/ui` is called with no arguments)

```
/ui <what you want, plain words>. Examples:
  /ui придумай дизайн лендинга для <продукт>      → explore distinct directions
  /ui сделай экран настроек                        → build it (signature + hierarchy + no-slop)
  /ui поправь отступы и цвета на этой странице     → polish
  /ui покритикуй этот экран / почему выглядит дёшево → critique (with the why)
  /ui почему пользователь не находит кнопку          → reason (usability)
  /ui какие шрифт и палитру взять для <вайб>         → reference
One command. It routes to the right engine — you don't need to remember impeccable/ui-explore.
```

## Rules
- ONE front door: users are never expected to recall `impeccable`, `/ui-explore`, or any
  sub-operation. If a user does type those directly, they still work — `/ui` does not replace
  them, it fronts them.
- Always load the taste layer (`anti-slop-law.md`) for BUILD/POLISH/CRITIQUE and the reasoning
  layer (`ui-first-principles`) for BUILD/CRITIQUE/REASON. The detector owns the measurable
  layer — never re-litigate its findings with the LLM.
- Frontend changes follow E2E Test Discipline (Playwright spec in the same change) — see
  `.claude/rules/workflow.md`. `/ui` BUILD/POLISH are subject to the same gate as any frontend edit.
- State the chosen route in one line before acting; ask only when genuinely ambiguous.
