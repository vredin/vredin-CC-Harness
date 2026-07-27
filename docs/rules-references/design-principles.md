# Design Principles — the broad catalog (load-on-demand)

> Reasoning breadth beyond hierarchy + operability. Load when a UI decision needs a named
> principle the focused reasoning layer doesn't carry. Pulled by the `ui-first-principles`
> skill and `/ui` (REASON/CRITIQUE routes) — you don't invoke this file directly.
>
> **No duplication.** These are ALREADY in `ui-first-principles` and are NOT restated here:
> affordance/signifier, feedback, mapping, conceptual model, the two Gulfs, slips-vs-mistakes,
> constraints, visual hierarchy method, proximity/similarity/alignment, cognitive-load budget,
> recognition-over-recall, consistency. This file adds the principles those don't cover.
>
> Distilled — principles as actionable if/then rules, in our own words (copyright-safe).
> Source framework: Lidwell, Holden & Butler, *Universal Principles of Design*.

Each rule is a decision you can defend. Cite the principle name when you apply it.

---

## 1. Speed & effort of use

- **Fitts's Law** — time to hit a target grows with distance and shrinks with target size.
  Rule: **primary/frequent controls are big and close to where the cursor/thumb already is**;
  tiny far-apart buttons are a bug. Put destructive actions far from frequent ones so a slip
  can't hit them.
- **Hick's Law** — decision time grows with the number/complexity of choices. Rule: **fewer
  visible options = faster action.** Collapse rare choices behind progressive disclosure; don't
  show 12 buttons when 2 + a "more" will do.
- **80/20 rule (Pareto)** — ~80% of use comes from ~20% of features. Rule: **design the screen
  around that 20%**; make the vital few obvious and the trivial many quiet or tucked away.
- **Flexibility–usability tradeoff** — the more things a UI can do, the harder each is to do.
  Rule: **don't add a mode/option without paying the usability cost**; prefer opinionated
  defaults over a wall of settings.
- **Performance load** — every bit of thinking (cognitive) and moving/clicking (kinesthetic)
  the user must do is a tax. Rule: **cut steps, clicks, and things-to-figure-out**; a shorter
  path beats a cleverer one.

## 2. Attention & perception

- **Aesthetic–usability effect** — people perceive good-looking interfaces as easier to use and
  **forgive their minor problems**. Rule: **visual craft is not decoration — it buys tolerance**;
  a polished screen earns patience a rough one never gets. (This is *why* anti-slop work pays off
  functionally, not just cosmetically.)
- **Signal-to-noise ratio** — maximize information (signal), minimize everything else (noise).
  Rule: **every non-load-bearing line, border, gradient, or word lowers the ratio — remove it.**
- **Von Restorff / isolation effect** — the item that differs is the one remembered. Rule: **make
  the ONE thing you want noticed visually distinct**; if everything is emphasized, nothing is.
- **Serial position effect** — first and last items are remembered best, the middle sags. Rule:
  **put the most important items at the start or end** of a list/nav/menu, not buried mid-list.
- **Highlighting** — emphasis works only in small doses. Rule: **highlight <~10% of a view**; bold
  everything and emphasis dies (ties to Von Restorff and signal-to-noise).
- **Closure & continuation (Gestalt beyond proximity)** — the eye completes shapes and follows
  lines. Rule: **you can imply grouping/flow with partial forms and alignment lines** instead of
  drawing full boxes (pairs with "prefer space to boxes" in ui-first-principles).
- **Iconic representation** — a good icon speeds recognition; a decorative one adds noise. Rule:
  **use an icon only where it aids recognition, always paired with a label** unless universally
  understood; never icon-per-noun (that's slop — see anti-slop-law).

## 3. Memory & behaviour

- **Defaults** — most users never change them. Rule: **choose the default as the choice most
  users should make**; a lazy default (blank, "select…", the riskiest option) is a design failure.
- **Framing** — the same choice presented differently yields different decisions. Rule: **frame
  toward the outcome you honestly want** (e.g. "keep changes" vs "discard") — but never to
  manipulate; dark-pattern framing is banned.
- **Zeigarnik effect** — unfinished tasks stay in the mind and pull attention. Rule: **show
  progress and what's left** (step N of M, checklists, completion meters) for multi-step flows;
  it both motivates and reduces abandonment.
- **Chunking** — working memory holds only a few units. Rule: **group long strings/lists into
  chunks** (phone/card numbers, nav into sections of ~5–7); never present a flat list of 20.

## 4. Structure & robustness

- **Redundancy (for critical info)** — never carry essential meaning on a single channel. Rule:
  **critical state uses ≥2 cues** (colour + icon + text), so a colour-blind user or a greyscale
  render still gets it. "Red = error" alone fails.
- **Layering** — manage complexity by organizing into layers revealed as needed. Rule: **show the
  overview first, detail on demand** (summary → expand, map → zoom); don't dump every layer at once.
- **Form follows function** — the look should express what the thing does. Rule: **a control's
  appearance must match its behaviour** (a button that looks like a tab, a link styled as a button,
  is a lie — ties to conceptual model).
- **Progressive disclosure** — reveal only what's relevant to the current step. Rule: **advanced/
  rare options stay hidden until asked for**; front-loading everything violates Hick + cognitive load.

## 5. Composition (light touch — defer look to anti-slop-law)

- **Rule of thirds / off-centre balance** — placing focal elements off the dead centre reads as
  more dynamic and considered. Rule: **compose to a deliberate balance point**, not reflexive
  centring (but see anti-slop-law: default-asymmetry-to-the-edges is *also* slop — balance, don't
  scatter).
- **Golden ratio / consistent ratios** — pleasing proportion comes from a consistent ratio, not
  random sizes. Rule: **size relationships come from one scale** (ties to "systematize every scale"
  in ui-first-principles).

---

## How to use
- For a specific decision, name the principle and apply its rule (e.g. "Fitts's Law → enlarge the
  primary CTA and pull it in from the corner").
- **Layer division:** operability + hierarchy reasoning = `ui-first-principles`; taste/composition/
  signature = `anti-slop-law.md`; measurable slop = impeccable detector; style/palette/font options
  = `ui-ux-pro-max`. This file = the broad *named-principle catalog* the reasoning layer draws on.
- When a principle here and a look rule collide, operability/legibility wins on function; the look
  layer wins on aesthetics (same collision rule as `ui-first-principles`).
