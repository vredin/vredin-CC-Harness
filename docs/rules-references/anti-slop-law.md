# Anti-Slop Design Law

> **Load-on-demand reference for UI *generation*** (not review). Read this BEFORE
> generating any interface, and re-check against it BEFORE you ship.
>
> **Division of labour — do not duplicate:**
> - The **measurable** slop layer (purple/blue-purple gradients, gradient text, low
>   contrast, cramped padding, glowy pills, bounce easing, small touch targets) is
>   caught deterministically by the **impeccable detector**
>   (`npx impeccable detect --json`, wired into `/review`, `/fix`, `/ui-explore`).
>   See `frontend-impeccable.md`. **This file does NOT restate those** — it owns the
>   layer a linter cannot judge: taste, composition, signature, and the positive spec.
> - Ready-made non-generic section shapes: `hallmark-cookbook.md`.
> - Colour system + real-asset sourcing: `hallmark-color-assets.md`.
>
> Distilled from the anti-slop design law (`hallmark` by Nutlope, MIT). The user's
> word overrides every default here: if they ask for a colour, layout or effect this
> file warns against, do exactly that — their direction wins 100%. Absent a specific
> instruction, this file is law.

---

## 0. How to use (the ritual)

1. **Read this file before you start.** It is easy to forget and easy to violate.
2. **Decide the signature FIRST** (§5) — one idea the whole page is built around —
   before composing a single section.
3. **Re-check every point before you call it done.** Walk the file top to bottom,
   find and fix each UI error, then hand over.
4. Run the impeccable detector on the output for the measurable layer.
5. Test every interactive control with a real click (§3) before reporting done.

---

## 1. The deeper tell — dodging the checklist is still slop

The real failure is **making no creative decision**. You can avoid every mechanical
tell and still ship slop, because the output reads as generated when nothing was
actually invented. A checklist produces a clean *miss*, not a design.

- **Incoherence is failure #1.** A page of individually-fine parts (a font here, a
  colour there, a nice image) that do not belong to each other — "every small good
  part, made into the ugliest thing." Pick ONE world; make every element serve it.
- **No signature artifact → nothing rescues it** (§5.1). Clean spacing cannot save a
  page with no point of view.
- **Avoiding the list is not design.** Swapping one trendy font for another,
  recolouring the same layout, ruling instead of bordering, deleting icons to be
  "safe" — each dodges an item while inventing nothing. Design is a point of view
  applied with conviction. **Clean is the FLOOR, never the achievement.**
- **Dead-looking is a fail on its own.** "Boring / static / no motion" is a real
  rejection even when nothing is slop. Calm is allowed; dead is not (§4, §5).

---

## 2. Composition-level slop (the detector cannot see this — it reads styles, not skeletons)

A **recoloured layout is still slop**. These are section *compositions* reused across
sites with only the palette changed. Each is a tell on its own. Ask: *have I used
this layout before? If yes, change it.*

**Whole-page meta-skeleton — be most suspicious of this one:**
- **The SaaS product-page template** (the Stripe/Linear/Vercel clone): two-column
  hero (headline+subtext+buttons left, product panel in a shadowed rounded box
  right) → three feature cards each with an icon in a tinted tile → tabbed
  "for X / for Y" switch → two-three pricing cards → FAQ accordion → full-width CTA
  slab → multi-column footer split by rule lines. Assembled in this order it is the
  default template with the serial numbers filed off. Recolouring it changes nothing.

**Section skeletons that are each a tell:**
- **Hero stack with a panel on the right** — eyebrow → huge headline → paragraph →
  two buttons, with an image/card/product panel floating right. Most over-shipped
  hero on the internet. It does not matter what sits in the panel.
- **The default hero stack** — eyebrow → headline → subline → primary button + a
  secondary text link, centred and stacked down the middle.
- **Filled-button-next-to-outlined-button pair** — the fill-primary + ghost-secondary
  couplet is a preset regardless of colour/radius/label. Arrow/underline flourishes
  make it louder.
- **Small-label-over-big-heading section head** (the kicker-plus-H2) — tiny uppercase
  kicker above a big heading, opening nearly every section. Slop in ANY typeface.
- **Three-tier pricing block** — Free/Pro/Enterprise, middle card "highlighted" with
  a glow border + "MOST POPULAR" pill.
- **Testimonial/quote card** — big quote-mark glyph, centred quote, avatar + name +
  impressive fake metric ("velocity jumped 32%").
- **Pre-footer CTA banner** — wide gradient slab, centred headline, "no credit card
  required" byline, one-two buttons.
- **Big serif statement block** — a kicker plus one large serif sentence with a single
  italic-accent word, as the "philosophy" beat.
- **Inset "enquire island" with a form** — rounded panel floated with margin on all
  sides, kicker + serif headline + one-line lead + form. Was premium once; now the
  default closing section.
- **Email-pill + button form** — long pill input beside a pill button. The single
  most repeated component.
- **Numbered steps beside a vertical rule** (01/02/03 on a rail) — a preset; worse with
  a square-capped line.
- **Multi-line headline** — a display line broken onto 3-4 stacked rows reads as slop;
  worse when the two-tone accent word lands stranded alone at the bottom.

**The compounding rule:** any one of these might be argued in isolation. Stacked in a
single page they multiply into something unmistakably generated. **A page is not the
sum of individually acceptable blocks.** When a block matches an entry here, that is
not a green light because "the pieces are fine" — it means change it.

**Recycling your own house style** is the deepest version: reusing your own recurring
kit (kicker-H2 + serif statement + image cards + inset island + serif-plus-sans +
oversized footer wordmark) across briefs with a new palette. If the last site and
this one share the same five section shapes, you reskinned a theme — you did not
design. → For non-generic shapes to reach for instead, use `hallmark-cookbook.md`
(diversification rule: no two sections share an archetype).

**The three 2026 default looks (fresh calibration).** Current AI-generated design
clusters around three whole-page looks that read as machine defaults the moment they
appear regardless of subject:
1. **Warm cream** (near `#F4F1EA`) + high-contrast serif display + terracotta accent —
   the "tasteful editorial" autopilot (see also § cream/beige background).
2. **Near-black** + ONE bright acid accent (acid-green or vermilion) — the "serious
   dark product" autopilot in its newest costume.
3. **Broadsheet** — newspaper-dense columns, hairline rules everywhere, zero
   border-radius — the "editorial credibility" autopilot.
All three are legitimate for SOME briefs; the tell is that they show up for ANY brief.
If the user asked for one of them — do it (their word wins). If the brief left the axis
free, do not spend that freedom on one of these three. Test: would this exact look fit
the neighbouring project too? Then it's a default, not a choice.

---

## 3. Functional bugs → HARD blockers (checkable, not taste)

These are correctness failures, not aesthetics. Treat as merge blockers in `/review`
and `/fix` when the diff touches frontend.

- **The invisible-content trap — the single most damaging motion mistake.** Content
  that starts at `opacity: 0` (or a translated-away state) and relies on JS / a scroll
  timeline / a Framer `initial={{opacity:0}}` to reveal it. When the reveal does not
  fire — backgrounded tab, unsupported timeline, throttled engine, hydration hiccup,
  screenshot pass — the content is simply GONE and the section renders as an empty
  void. **Rule (absolute): CONTENT IS VISIBLE BY DEFAULT.** Never gate the existence of
  text or a control on an animation completing. Animate things already on screen
  (hover, marquee, counting numbers, scroll-linked parallax on visible elements). An
  entrance reveal is acceptable ONLY if the no-JS fallback still shows the content
  fully.
- **Dead controls / fake interactivity.** A tab, accordion, slider, toggle or button
  that looks interactive but does nothing (or visibly fails) when clicked is broken.
  If a control is on the page it must work in the browser, confirmed by a real click.
  A static prop (faux search bar, mock tab strip) must not be dressed as a live
  control.
- **Clear the cut.** Whenever you add a `clip-path`, notch, `overflow: hidden`, or a
  fixed height, prove the content sits fully inside the visible region: pad it clear
  by more than the cut removes, then zoom into that exact edge and check pixel-for-
  pixel. Also applies where one section overlaps another — never let a section edge
  guillotine live content beneath it.
- **Ragged parallel columns.** Items compared side by side (pricing, plans, feature
  columns) must line up on a shared grid: title, price, body, list top, and above all
  the button. Give cards equal height, anchor the CTA to the bottom, reserve equal
  space for variable copy. Alignment must NOT depend on content length.
- **Unreadable text — contrast.** Every piece of text must clear its background by a
  real value gap. On a filled button, a label that does not stand clear of the fill is
  unforgivable. (The impeccable detector also flags this; here it is a hard rule.)

---

## 4. What premium actually looks like (the positive spec — aim for these)

Most "slop" techniques are the lazy default version of a real tool. Glass, accent
edges, glow, borders and motion all appear in genuinely premium work. The difference
is **craft, restraint, and uniqueness** — the same element is slop when it is the
obvious preset and premium when clearly made on purpose for this one screen.

- **Real translucency (liquid glass)** — a material over a backdrop worth showing
  through, that refracts it, with edge dispersion, a bright top-lip highlight, light
  frost, tuned inner+drop shadows. The slop version is a frosted box with a blue glow
  that ignores its background. (Concrete parameter recipe kept in §8.)
- **Self-coloured borders + tonal elevation** — define a container without a drawn
  line: shift its surface value slightly from the background, add a 1px stroke in the
  surface's OWN colour at low opacity, a soft top-edge inner highlight. Depth from
  light and tone, not a hard contrasting outline.
- **Bespoke geometry beats default shapes** — uniqueness is the single biggest premium
  signal. A plain accent bar is a preset; an invented silhouette (a diagonal marker, a
  chamfer, a notch, a receipt-torn edge) reads as drawn on purpose. Invent the
  geometry of dividers, corners, connectors, edges, underlines.
- **Bare icons, no container** — strip every icon to the mark itself. No tile, chip,
  or coloured rounded square behind it (true for logos too).
- **Custom, in-house iconography** — icons drawn as designed objects in one house
  style, consistent in stroke/corner/grid. The answer to "no icons" is not zero icons,
  it is *your own* icons. If an icon could sit on any other product unchanged, it is
  slop.
- **Authored micro-interactions** — bespoke motion, not the default fade-and-translate.
  A line that travels and fills with a tuned "popped" cap; a state change written for
  this one element. Restraint plus specificity. Never the hover "boop" (a button that
  lifts/scales) or the growing-underline trick.
- **Considered light, not the default glow** — make the colour, direction and falloff
  specific and chosen (a warm volumetric wash, a single directional ray), never the
  reflexive symmetric bloom behind an object.
- **Premium noise / grainy gradients** — a fine low-opacity grain on the substrate
  removes banding and adds tactility (feel it, not see it). Any large colour transition
  should carry grain; a clean banded gradient reads cheap. Keep grain BEHIND content,
  never over text.
- **Scroll-authored motion** — content that settles/shifts as it enters, quiet
  parallax between layers. Subtle, fast, always gated behind `prefers-reduced-motion`,
  and never gating content existence (§3).
- **Say less** — few words, short lines. Cut every line that is not load-bearing.
  Confidence is shown by what you leave out.

→ Colour discipline (OKLCH, one accent ≤3% of viewport, tinted neutrals, no pure
`#000`/`#fff`) lives in `hallmark-color-assets.md`. Real imagery/icon/font sourcing
(never fake CSS illustrations or invented logos) lives there too.

---

## 5. The signature — how uniqueness is actually made

"Clean" is the floor. Reference sites that look nothing alike make uniqueness the
same way. Decide the signature FIRST, then build the rest around it.

### The formula
> **uniqueness = one signature artifact + atmosphere + layered depth + a character
> display face + one bespoke silhouette + a treated nav + real specifics**

1. **One signature artifact** — ONE custom, high-effort focal object that could not be
   pasted onto any other site (a crafted SVG scene, a detailed real product UI, a
   pre-generated image). Decide this first; everything supports it. **Miss this and no
   amount of clean spacing rescues the page.**
2. **Atmosphere, not a flat fill** — the background is a composed environment (scene,
   render, texture, painted gradient with grain), not one flat colour. Flat dark or
   flat cream behind boxes is the boring failure mode.
3. **Layered depth on the z-axis** — foreground copy, a midground focal object,
   a background scene; at least one element crosses a layer boundary (overlap/bleed).
4. **The product as a real, populated artifact** — when a product is shown, it is a
   detailed, fully-populated UI (real copy, real data, working controls), floated with
   depth, usually clipped at an edge. Empty placeholder boxes are the opposite.
   *But only show a product UI when there IS one* — a fake dashboard for a thing that
   is just a file reads as a copied template. Design from what the thing actually is.
5. **Character in the display type** — the headline face has personality and is set
   large. Body can be neutral; the signature line cannot.
6. **One bespoke silhouette** — a single custom-cut shape signs the page. One
   unmistakable geometry beats ten default rectangles.
7. **The nav is treated, not defaulted** — contain it, centre it, make it big, thread
   real marks into it. Not a flush row of links bolted on top.
8. **Real specificity** — real recognisable logos (only ones you can honestly claim),
   real names/data/copy. Generics read as a stock template.

**Cohesion is the whole game** (from field notes, wins every time): one palette held
with discipline; one type voice (never two display faces arguing); one signature
artifact decided first; compose sections from that world, never a recoloured stack of
blocks.

---

## 6. Fonts — off the Google shelf is a tell

Nearly every free Google font reads as slop **the moment it CARRIES the brand**.
Rejected as signature faces (non-exhaustive): Inter, Space Grotesk, Sora, Syne,
Archivo, Onest, Figtree, Gabarito, Quicksand; Fraunces, Cormorant, Bodoni/Didones,
Young Serif; JetBrains Mono, IBM Plex Mono, Fragment Mono. Even the "tasteful" swap
(Big Shoulders, Newsreader, Instrument Serif, Bricolage) is still slop — picking type
by reputation instead of by the brief is the issue, not the family.

Two hard rules:
1. **The signature line cannot rest on anything off the Google shelf.** A plain neutral
   font may sit quietly in body text (`system-ui` is genuinely neutral and safe), but
   the identity face must be genuinely distinctive — usually licensed or self-hosted.
2. **Never reuse a font (or the same serif-headline-plus-clean-sans pairing) you used
   on another site here.** A recognisable house pairing repeated across briefs is
   itself a tell. Each site gets its own type decision.

**Practical free path:** Fontshare (Clash Display, General Sans, Satoshi, Switzer,
Cabinet Grotesk; reach further for character: Pally, Gambarino, Sentient, Tanker) and
Velvetyne faces — licensed-quality, NOT the Google rotation. Download woff2 and
self-host (`next/font/local`). View candidates rendered before picking.
*(Even Clash/General Sans now read generic to some briefs — reach for real character.)*

---

## 7. Component / library toolkit (reach for these instead of hand-rolling)

Hand-rolling generic UI reproduces the slop defaults (sun-moon toggle, fill+outline
pair, underline hover). Take accessible, tested primitives and art-direct hard on top
of them for the brand. All free:

- **Motion** (`npm i motion`, `motion/react`) — the animation engine; needs no
  Tailwind, works in any project. Springs, gestures, scroll-linked transforms
  (`useScroll`/`useTransform`), animated numbers, marquees, layout animation.
- **shadcn/ui** — React + Radix + Tailwind copy-paste primitives (accessible foundation).
- **tailark** — Tailwind + shadcn marketing blocks and full pages.
- **motion-primitives** — Motion + Tailwind animated components.
- **kokonut UI** — Tailwind v4 + Motion, 100+ components incl. AI-specific ones.

In a **non-Tailwind** project: install Motion for the animation, and *adapt the
structure* of the others into the project's own styling — never bolt global Tailwind
onto a large non-Tailwind codebase for one block.

**De-slop the prebuilt pieces, always.** A free block is a head start, not a free
pass — the libraries still ship blue-purple gradients, glowy pills, the fill+outline
pair, sun-moon toggles by default. The instant you spot a slop element in anything
pulled from them, replace/delete/rewrite it. Run every prebuilt block through this
whole file exactly like your own work before it ships.

---

## 8. Concrete recipes

**Liquid-glass button** (reference parameter values, over a real photographic backdrop
so the refraction has something to bend):
- Fill `#2575FF` (thick variant drops fill to 50% opacity so the backdrop reads
  through; thin keeps it solid). Label/icon `#FFFFFF`. Padding 20h / 14v.
- Two hairline strokes at 20% opacity in near-surface colours (one cyan `#22BBFD`,
  one white) — self-coloured edges, not a contrasting outline.
- Inner shadow (top highlight): `#FFFFFF` 20%, offset-Y 1, blur 32.
- Drop shadow tinted to the FILL colour `#2575FF` (not black), 6%, offset-Y 3, blur 3
  — tight and colour-matched is the premium move; a soft black bloom is the slop one.
- CSS approximation (no native refraction): `backdrop-filter: blur()` + `saturate()`/
  `contrast()`; inset white box-shadow for the top highlight; the two low-opacity
  strokes via layered border/box-shadow; a tight colour-matched drop shadow; fake
  dispersion with a 1px cyan/magenta edge offset. Always over real content.

**Feathered image seam** (kill the hard horizontal line where a full-bleed image meets
a flat section — all four together or it still bands):
1. Mask the IMAGE's own pixels, not a colour overlay: `mask-image: linear-gradient(to
   bottom, transparent 0%, … #000 31%, #000 65%, … transparent 100%)`.
2. Long AND finely eased — the fade runs ~30% of the section at each end with 10+ stops.
3. Tall section (~116vh) so a full-opacity middle strip survives between the feathers.
4. Continuous page colour above and below, so the masked edges reveal one surface.
   Any text-contrast scrim must sit only behind the text and fade to transparent
   before both edges (carry the rest on a strong text-shadow), or it becomes its own
   band.

---

## 9. Field notes (these sit on top of everything; when in doubt, they win)

- **Cohesion is the whole game** — the loudest failure was incoherence, not tells.
  One palette, one type voice, one signature artifact decided first, sections composed
  from one world.
- **"Creative" is not "realistic"** — for a creative/maximal brief, literal stock
  realism reads as the *opposite* of creative. Reach for an authored treatment in ONE
  consistent medium (cyanotype, a single illustration style, pixel art, riso, painted
  sky). A limited-palette medium also makes every image auto-cohere (its own colour
  becomes the page's colour → zero seams).
- **The product-as-artifact is a signature, not the slop window** — a faux app window
  is slop only when empty/generic. A detailed, real, working product UI floated with
  depth and clipped at an edge is one of the strongest signatures — but only when
  there IS a product to show.
- **Take the LANGUAGE from references, never the content** — lift palette mood, type
  energy, motion, the kind of hero/footer; then design ORIGINAL copy, layout and
  artifact for THIS product. Reference = direction, not a stencil.
- **Professional does not mean lifeless** — a correct, sparse, well-typed page with
  zero authored creative moments is unfinished work wearing restraint as an alibi. If
  there is no wow, no signature that could only belong to this brand, the restraint is
  just an excuse for having no point of view.

---

## Where this is wired

- **`/ui-explore`** — read this file before generating variants; pull section shapes
  from `hallmark-cookbook.md`; apply `hallmark-color-assets.md` for palette + assets.
- **`/impeccable craft` / `shape`** (global skill) — this file is the taste/composition
  layer alongside impeccable's operations; the impeccable detector remains the
  measurable gate.
- **`/review` STEP 4.6 + `/fix` frontend gate** — §3 functional bugs are hard blockers
  on frontend diffs (invisible-content trap, dead controls, clipped content).
- See `.claude/rules/skill-routing.md` § UI / frontend design for routing.
