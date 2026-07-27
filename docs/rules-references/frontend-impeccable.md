# Impeccable — frontend/UI-UX design engine

> Third-party design skill (Apache 2.0, by Paul Bakaus). Vetted by Rex 2026-06-27 (3.1.0),
> re-vetted 2026-07-17 (3.2.1 diff-review) → SAFE-WITH-MITIGATIONS both times. Wired into
> `/review`, `/fix`, `/ui-explore`, `/ui` as a deterministic design-quality gate
> ("a linter for design taste"). Referenced from skill-routing.md.

---

## What it is

- **`/impeccable` skill** — installed GLOBALLY at `~/.claude/skills/impeccable/` (available in every project, not vendored per-repo). 23 design operation commands (`craft`, `shape`, `audit`, `critique`, `polish`, `bolder`, `quieter`, `distill`, `harden`, `onboard`, `animate`, `colorize`, `typeset`, `layout`, `delight`, `clarify`, `adapt`, `optimize`, `live`, …). Type `/impeccable` for the menu, `/impeccable <command> <target>` to run one.
- **Detector** — `npx impeccable detect` runs 46 deterministic anti-pattern rules over UI files (44 in 3.1.0; 3.2.x added `codex-grid-background` + `design-system-font-size`, both offline — Rex-verified). NO LLM, NO API key, NO network (file/dir mode). Catches AI "slop": side-stripe borders, gradient text, purple gradients, bounce easing, low contrast, cramped padding, small touch targets, skipped headings, etc.
- **46-rule corpus** — concrete measurable design rules (contrast ≥4.5:1, card radius ≤16px, line length 65–75ch, OKLCH color, reduced-motion required, …) baked into the skill prompt.
- **Relationship:** impeccable is the evolved successor of Anthropic `frontend-design` (retired to `docs/archive/retired-skills/`). It is a superset — prefer it for frontend design work.

## Install (one-time, done 2026-06-27)

```bash
IMPECCABLE_NO_UPDATE_CHECK=1 npx --yes impeccable@3.2.1 install --providers=claude --scope=global
```

Installed `impeccable@3.2.1`. Re-vet (Rex) before bumping the version — autorun trust is version-specific.

## Mitigations (from Rex review — MUST keep)

1. **Kill the version-check network call** — set `IMPECCABLE_NO_UPDATE_CHECK=1` in env, or `updateCheck:false` in `.impeccable/config.json`. Always pass it when invoking impeccable from our commands. (Rex 3.2.1 note: the env-var kill switch lives in the *downloaded skill bundle*, not the npm tarball — keep passing it; harmless if absent.)
2. **Pin the version** (`@3.2.1`) in every invocation; re-run Rex on upgrade.
3. **Audit-log stays in-repo** — never point `IMPECCABLE_HOOK_LOG` / config `auditLog` outside the project.
4. **Kill switch available** — `IMPECCABLE_HOOK_DISABLED=1` disables the auto-hook; the hook fails open (exits 0 on every error) so it can never break a turn.
5. **Autorun ONLY `detect`** (Rex 3.2.1): the detect path is fully offline (verified — zero network code). The only off-machine callers are `install`/`update`/`help` — never wire those into autorun. NB: `install`/`update` pull a **server-controlled bundle** that npm version-pinning does NOT pin; for deterministic installs use `IMPECCABLE_BUNDLE_PATH` with a vetted local copy.

## Runtime caveat

Package declares `node >=24`; user runs node 22. Install warns (EBADENGINE) but the **detector verified working on node 22** (2026-06-27 smoke test caught side-stripe + low-contrast + gradient-text). If a future version breaks on 22 → bump node or pin the last-working version.

## Detector contract (how our commands call it)

```bash
# JSON output for machine parsing; file or directory target; offline.
IMPECCABLE_NO_UPDATE_CHECK=1 npx --yes impeccable@3.2.1 detect --json <changed-ui-files-or-dir>
```

Output = JSON array of findings: `{ antipattern, name, description, severity, file, line, snippet }`.
Severity is `warning` (design quality) — treat as advisory unless the change is design-focused.

**Where wired:**
- `/review` STEP 4.5 (Design Review) — run detector on changed UI files, fold hits into the design-reviewer report. Confirmed slop = MUST FIX before merge.
- `/fix` STEP 6.8 (frontend E2E gate) — run detector on changed frontend files; flag new slop the fix introduced.
- `/ui-explore` STEP 3 — run detector on the generated mockups BEFORE the Diablo pass, so Diablo argues over already-slop-free variants.

**Scope discipline:** only scan the CHANGED UI files (from `git diff --name-only`), never whole-repo, unless the user asks for a full design audit (`/impeccable audit`).

## When to use which

| Want | Use |
|---|---|
| Build/redesign a UI feature | `/impeccable craft` or `/impeccable shape` |
| Quick deterministic slop check | `npx impeccable detect --json <files>` (auto in /review, /fix) |
| Full UX design review | `/impeccable critique <target>` |
| Tech a11y/perf/responsive audit | `/impeccable audit <target>` |
| Pre-ship polish | `/impeccable polish <target>` |
| Explore distinct directions first | `/ui-explore` (our command; now slop-checks mockups) |

`ui-ux-pro-max` (style/palette reference) remains; `frontend-design` (Anthropic original) retired to `docs/archive/retired-skills/`; impeccable is the primary engine + enforcement.

## Taste/composition layer (what the detector cannot judge)

The detector owns the **measurable** layer. It cannot judge taste, composition, or
whether a page has a signature. That layer lives in `docs/rules-references/anti-slop-law.md`
(distilled from Nutlope/hallmark, MIT) — load it when **generating** UI, alongside
`hallmark-cookbook.md` (non-generic section shapes) and `hallmark-color-assets.md`
(OKLCH colour + real-asset sourcing). The law also promotes three functional bugs to
hard merge-blockers (invisible-content trap, dead controls, clipped live content) —
wired into `/review` STEP 4.6 and `/fix` STEP 6.8. Do not duplicate the detector's
measurable rules there.
