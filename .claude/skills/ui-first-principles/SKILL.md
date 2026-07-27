---
name: ui-first-principles
description: >
  The design DECISION and JUSTIFICATION layer. Load when you must decide or defend a
  UI choice from first principles rather than pick a style — visual hierarchy (what the
  eye reads first and why), whether a screen is actually operable (affordances, signifiers,
  feedback, mapping, error prevention), grouping and cognitive load, and the reasoning
  behind spacing/type/emphasis. Answers "why this over that", "is this usable", "why can't
  the user find X", "what should read first", "how do I reduce confusion", "justify this
  layout". Also owns UX copy as design material: button labels, error messages, empty
  states, naming consistency. Distilled reasoning from Norman's usability cognition and
  Refactoring UI's hierarchy method — NOT a style catalog and NOT a slop detector. Pairs
  with impeccable (detect/fix slop), anti-slop-law (taste/signature), ui-ux-pro-max
  (style/palette menu).
---

# UI First Principles — the "why" behind a UI decision

This skill makes a coding agent **reason** about an interface and **defend** its choices.
It does not tell you what looks trendy (that's `ui-ux-pro-max`), it does not catch AI-slop
tells (that's `impeccable`), and it does not carry taste/signature direction (that's
`anti-slop-law`, `docs/rules-references/anti-slop-law.md`). It supplies the timeless
perceptual + cognitive rules that make one decision correct and another wrong — and lets
you state the reason out loud.

Use it BEFORE generating (to decide hierarchy/operability) and DURING critique (to explain
*why* something fails, beyond "it looks off").

## ⚠️ De-slop override (read first)
The classic books this is distilled from also taught the aesthetic that is now AI-slop.
**Keep the reasoning, reject these defaults:**
- Refactoring UI's example look — soft drop-shadow cards, gray-on-white, one generic sans,
  rounded-2xl everything, three evenly-spaced feature cards — is today's slop. Use its
  *hierarchy method*, not its *visual output*. Look/feel decisions defer to `anti-slop-law`
  + `impeccable`.
- "Safe, clean, tidy" is not the goal. **Operable + legible + intentional** is. A design can
  be clean and still be slop (generic) or unusable (no signifiers).
- When a first-principles rule and a signature/composition rule collide, first-principles
  wins on *operability* (can the user do the task), signature wins on *look* (does it feel
  generic).

---

## Part 1 — Is it OPERABLE? (usability cognition)

An interface fails here before it ever fails on looks. Check every interactive screen:

1. **Signifier over affordance.** An element *can* be clicked (affordance); a **signifier**
   is the perceivable cue that says so. Buttons must *look* pressable, links must *look*
   clickable, drop-targets must *show* they accept a drop. Rule: **no interactive element
   without a visible signifier** (never rely on hover to first reveal that a thing is
   interactive on touch/primary view).
2. **Discoverability.** A user must be able to answer, by looking: What can I do here? Where
   do I do it? What state am I in? If a core action requires prior knowledge to find, it's
   broken. Rule: **the primary action of a screen is visible without scrolling, hovering, or
   a menu.**
3. **Feedback — always, immediately, proportionally.** Every action gets a perceivable
   response within ~100ms (press state), and long operations show progress. Rule: **no action
   leaves the user wondering "did that work?"** Success, pending, and failure each have a
   distinct visible state.
4. **Mapping.** Controls should spatially/behaviorally mirror what they affect (up = more,
   left nav = left content, the toggle nearest a row controls that row). Rule: **arbitrary
   control→effect relationships are bugs**; make the mapping natural or label it.
5. **Conceptual model.** The UI must imply one coherent story of how the system works. Rule:
   **the same concept looks and behaves the same everywhere**; two names for one thing, or one
   control doing two unrelated things, breaks the model.
6. **Close the two Gulfs.**
   - *Gulf of Execution* (user knows the goal but not how to act): fix with visible actions +
     signifiers + sane defaults.
   - *Gulf of Evaluation* (user acted but can't tell what happened): fix with feedback +
     visible system state.
   Rule: for each user goal, name how the UI bridges *both* gulfs.
7. **Error strategy — prevent, then forgive.** Distinguish **slips** (right intent, wrong
   action — fix with constraints, confirmation on destructive ops, generous hit-targets, undo)
   from **mistakes** (wrong intent/model — fix with clearer model, better labels, guidance).
   Rule: **destructive/irreversible actions require a constraint or an undo**; validation
   explains *how to fix*, never just "invalid".
8. **Constraints do the work.** Prefer making the wrong action impossible (disable, gray,
   hide, input masks) over warning about it after. Rule: **design out the error before you
   message it.**

If any screen fails 1–3, stop — no amount of visual polish rescues an inoperable screen.

---

## Part 2 — What reads FIRST? (visual hierarchy method)

Hierarchy is a decision, not decoration. Method (de-slopped from Refactoring UI):

1. **Rank before you style.** List every element on the screen and assign a tier: **Primary**
   (the one thing this screen is for), **Secondary** (supporting), **Tertiary**
   (metadata/labels). A screen with two primaries has none. Rule: **exactly one primary per
   screen.**
2. **Design in grayscale first.** Establish the full hierarchy using only size, weight, and
   spacing — no color. If it doesn't read in gray, color is hiding a broken hierarchy. Add
   color *last*, and only to carry meaning (state, brand accent, one call-to-action).
3. **Emphasize by de-emphasizing, not by enlarging.** To make something stand out, mute its
   neighbors (lower contrast, lighter weight, smaller) rather than inflating the hero. Rule:
   **when everything shouts, nothing is heard — lower the secondary before raising the
   primary.**
4. **Weight and color carry hierarchy better than size.** Prefer font-weight and text-color
   contrast for rank; reserve large size jumps for true headings.
5. **Semantic ≠ visual hierarchy.** An `h2` in the source need not be visually second; style
   by the *visual* rank you decided in step 1, keep the *semantic* order correct for a11y.
   Rule: **never let markup level dictate visual emphasis, or vice versa.**
6. **Separate with space before you separate with lines/boxes.** Reach for whitespace and
   grouping first; borders/dividers/cards second; shadows last (shadows are a slop magnet —
   defer to impeccable). Rule: **if space groups it, don't add a box.**
7. **Systematize every scale.** Type sizes, spacing, and color steps come from a fixed scale
   (a modular type scale, a spacing ramp), never ad-hoc pixel values. Rule: **any size not on
   the scale is a bug**; a hand-typed `13px`/`7px` is a smell.
8. **Start with too much whitespace, then remove.** Dense-by-default reads as cheap. Give
   generous breathing room, then tighten only where grouping demands it.
9. **Limit choices.** Fewer type sizes, weights, accent colors, button styles → more
   coherence. Rule: **each new visual variable must earn its place; default to reuse.**

---

## Part 3 — How does the eye GROUP it? (Gestalt + cognitive load)

- **Proximity beats every other grouping cue.** Related things sit close; unrelated things
  get space. Most "cluttered" screens are a proximity failure, not a color failure. Rule:
  **inspect gaps — is spacing *within* a group tighter than *between* groups?** If not, fix
  that first.
- **Similarity groups; difference separates.** Same role → same visual treatment; different
  role → visibly different.
- **Common region & alignment.** A shared container or a shared alignment edge groups items
  without extra chrome. Rule: **prefer alignment to boxes.**
- **Cognitive load budget.** Working memory is tiny. Chunk long content; reveal complexity
  progressively (disclosure, steps, defaults) instead of front-loading it. Rule: **if a
  screen makes the user hold >~4 things in mind to act, split or sequence it.**
- **Recognition over recall.** Show options; don't force the user to remember them (visible
  nav, autocomplete, recently-used, inline hints). Rule: **never require memory the UI could
  hold.**
- **Consistency = external (platform conventions) + internal (your own patterns).** Break a
  convention only for a deliberate, explained reason.

---

## Part 4 — Words are signifiers (UX writing)

Copy is design material, not decoration: its one job is making the interface easier to
understand and operate. Bring the same intent to words as to spacing.

- **Name things by what the user controls, not how the system is built.** A person
  manages "notifications", not "webhook config". System vocabulary in the UI is a
  conceptual-model break (Part 1.5).
- **A control says exactly what it does.** "Save changes", not "Submit"; "Delete
  project", not "OK". A verb-true label IS the signifier for what happens (Part 1.1).
- **One action = one name through the whole flow.** The button "Publish" produces the
  toast "Published". Interface vocabulary is signposting; synonyms break the map.
- **Errors direct, never apologize, never go vague.** Say what went wrong AND how to fix
  it, in the product's voice. "Something went wrong" is an unclosed Gulf of Evaluation.
- **An empty screen is an invitation to act** — state what belongs here and give the
  action, not a blank void or a sad illustration.
- **Active voice, sentence case, plain verbs, zero filler.** Specific beats clever.
  Each element does exactly one job: a label labels, an example demonstrates.

---

## Cheatsheet — decision rules (the differentiated layer)

Apply these as if/then; each is a decision you can defend.

| Situation (tell) | Decision | Why |
|---|---|---|
| Two elements both feel "most important" | Demote one to Secondary | One primary per screen or hierarchy collapses |
| Screen looks busy / cluttered | Fix proximity + whitespace before color/borders | Clutter is usually a grouping failure |
| Hero doesn't pop | Mute the neighbors, don't enlarge the hero | Emphasis is relative |
| Design only works once color is added | Rebuild hierarchy in grayscale | Color was hiding a broken structure |
| User "can't find" an action | Add a signifier + move it above the fold | Discoverability, not aesthetics |
| User unsure an action worked | Add immediate + state feedback | Close the Gulf of Evaluation |
| Destructive action one click away | Add constraint / confirm / undo | Slip prevention |
| Validation says only "invalid" | Say what's wrong AND how to fix | Errors must be recoverable |
| Ad-hoc pixel value (13px, 7px) | Snap to the scale | Systematized scales prevent drift |
| Many button/type/accent variants | Cut to the minimum set | Limit choices → coherence |
| Same concept styled two ways | Unify them | Protect the conceptual model |
| Long/complex form | Chunk, sequence, add defaults | Cognitive-load budget |
| Button says "Submit"/"OK" | Rename to the actual action | Verb-true label = the signifier |
| Error says "invalid"/"went wrong" | State the cause + the fix | Errors direct, never apologize |
| Same action named two ways | Unify the vocabulary | One action = one name across the flow |

**Tells & smells (fast triage):**
- Everything is bold / everything is a card → no hierarchy.
- Interactivity only revealed on hover → discoverability + touch failure.
- Spacing inside a group ≥ spacing between groups → proximity broken.
- A primary action below the fold → operability failure.
- Color doing the whole hierarchy → grayscale test will fail.
- Destructive action with no undo/confirm → slip waiting to happen.

---

## Scope & limits
Reasoning layer only. It decides *what should read first* and *whether the user can operate
it* — not *what it should look like*. For the actual look (fonts, palette, composition,
signature) use `anti-slop-law` + `ui-ux-pro-max`; to catch AI-slop tells deterministically
run `impeccable detect`; to build/critique the full UI use `/ui` (which routes to impeccable).
When those and this collide, this skill wins on operability, they win on look.

**Broader principle catalog:** this skill carries the focused core (hierarchy + operability +
grouping). For a named principle it doesn't cover — Fitts's/Hick's Law, 80/20, aesthetic-
usability effect, signal-to-noise, Von Restorff, serial position, defaults, framing, redundancy,
progressive disclosure, layering — load `docs/rules-references/design-principles.md` (distilled
from *Universal Principles of Design*). It's the wide catalog; this skill is the deep core.

**Distilled — principles/frameworks only, no verbatim book text (copyright-safe):**
Norman, *The Design of Everyday Things* (affordances, signifiers, mapping, feedback,
conceptual models, slips vs mistakes, the two Gulfs); the *reasoning method* of Wathan &
Schoger, *Refactoring UI* (hierarchy by weight/color/space, grayscale-first, de-emphasize,
systematic scales, limit choices) — its dated visual defaults deliberately discarded as slop.
