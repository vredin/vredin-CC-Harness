<!-- VENDORED from Nutlope/hallmark (https://github.com/Nutlope/hallmark), MIT License.
     Anti-AI-slop design skill. Fetched 2026-07-17. Load-on-demand reference for UI generation.
     Upstream is maintained; re-pull to update. Do not edit in place — edits will be lost on re-pull. -->

# Component cookbook

Fifty component archetypes you can compose into any macrostructure. Every entry: a *shape*, a one-line "use when", a one-line "don't confuse with", and a short structural sketch (DOM + minimal CSS). Pick from this file when you're building a section and don't know which shape to reach for.

The same macrostructure (e.g., Bento Grid) can be built from many different combinations of these archetypes. The macrostructure picks the *page shape*; this file picks the *components inside it*.

**Diversification rule:** within a single page, no two sections should use the same archetype. A Bento Grid might pair *Bento feature block* with *Inline form CTA* with *Logo wall (hairline)*. The next page Hallmark builds should pick different archetypes from the same categories.

---


---

## Archetype index — load ONLY the picks you need

**Pick your archetype names here, then read ONLY those individual files** from `references/components/`. Do not load the whole cookbook. A typical build needs 5–7 files: 1 hero + 1 section head + 1–2 features + 1 CTA + 1 footer + 1 nav.

### Heroes

- **H1 · Marquee** — A single statement fills the fold. No subhead, no CTA in view. [`components/h1-marquee.md`](components/h1-marquee.md)
- **H2 · Split diptych** — Headline + lede on one side, image or product capture on the other. 6/6 or 7/5 columns. [`components/h2-split-diptych.md`](components/h2-split-diptych.md)
- **H3 · Quote led** — A pull-quote with attribution is the hero. Your headline is borrowed credibility. [`components/h3-quote-led.md`](components/h3-quote-led.md)
- **H4 · Stat led** — A giant number or metric is the hero. A small qualifier line below. [`components/h4-stat-led.md`](components/h4-stat-led.md)
- **H5 · Letter hero** — First-person opening — "Dear reader,". No buttons in fold. Reads as personal correspondence. [`components/h5-letter-hero.md`](components/h5-letter-hero.md)
- **H6 · Photographic fold** — Single full-bleed image fills the viewport. Caption sits in a corner. [`components/h6-photographic-fold.md`](components/h6-photographic-fold.md)
- **H7 · Demo video clipped by viewport edge** — Display headline left, demo video right, the rightmost ~10–20 % extending past the viewport so it's intentionally cut off. The clip *is* the design — implies "there's more product  [`components/h7-demo-video-clipped-by-viewport-edge.md`](components/h7-demo-video-clipped-by-viewport-edge.md)
- **H8 · Mockup split browser framed** — Headline left, browser-frame mockup right, the mockup tilted 1–3° for life. Frame can be browser chrome, macOS toolbar, minimal hairline, or floating no-frame. [`components/h8-mockup-split-browser-framed.md`](components/h8-mockup-split-browser-framed.md)
- **H9 · Custom illustration centerpiece** — A single hand-built SVG (Tier B in the enrichment hierarchy — or pure CSS at Tier A for simpler shapes) sitting on the hero as one illustrative element. The bakery loaf, the studio [`components/h9-custom-illustration-centerpiece.md`](components/h9-custom-illustration-centerpiece.md)

### Section heads

- **S1 · Left margin numbered** — A narrow left column holds `01 — LABEL.`; the wide right column holds the heading and content. [`components/s1-left-margin-numbered.md`](components/s1-left-margin-numbered.md)
- **S2 · Hanging** — Heading floats above the section in negative space; no border, no rule. [`components/s2-hanging.md`](components/s2-hanging.md)
- **S3 · Sticky pinned** — Heading remains in viewport while content scrolls beneath. Orientation aid. [`components/s3-sticky-pinned.md`](components/s3-sticky-pinned.md)
- **S4 · Inline no break** — The heading is a small caps phrase that emerges *inside* the body flow; no spatial break. [`components/s4-inline-no-break.md`](components/s4-inline-no-break.md)
- **S5 · Bottom anchored** — The label or heading sits *below* the section's content. Inverts hierarchy. [`components/s5-bottom-anchored.md`](components/s5-bottom-anchored.md)

### Feature blocks

- **F1 · Bento grid** — Asymmetric grid of 8–15 tiles in mixed spans (1×1, 2×1, 1×2, 2×2). Visual rhythm via size. [`components/f1-bento-grid.md`](components/f1-bento-grid.md)
- **F2 · Sticky scroll stack** — Sticky left pane, scrolling right pane that cycles through related screenshots. [`components/f2-sticky-scroll-stack.md`](components/f2-sticky-scroll-stack.md)
- **F3 · Tabular spec sheet** — Each row is a feature; columns hold name, value, footnote. Hairline rules between rows. Tabular numerics. [`components/f3-tabular-spec-sheet.md`](components/f3-tabular-spec-sheet.md)
- **F4 · Step sequence** — Numbered stages (`1.0 → 2.0 → 3.0`) flow vertically. Each stage has a heading, a paragraph, sometimes a small visual. [`components/f4-step-sequence.md`](components/f4-step-sequence.md)
- **F5 · Annotated screenshot** — A product capture sits centre-stage with arrows or short labels pointing to UI details. [`components/f5-annotated-screenshot.md`](components/f5-annotated-screenshot.md)
- **F6 · Product card grid** — Each card is a product, not a feature. Image · name · price · one micro-action. Reads like a shop floor, not a marketing site. [`components/f6-product-card-grid.md`](components/f6-product-card-grid.md)

### CTAs / signups

- **C1 · Outlined chip** — A bordered, transparent button with a typographic verb ("Save changes"). [`components/c1-outlined-chip.md`](components/c1-outlined-chip.md)
- **C2 · Inline form as cta** — The CTA *is* the form — a single email input with a "Submit →" beside it. No separate landing for sign-up. [`components/c2-inline-form-as-cta.md`](components/c2-inline-form-as-cta.md)
- **C3 · Typographic link** — Just a word, an arrow, and a 1-px underline. No box, no fill. [`components/c3-typographic-link.md`](components/c3-typographic-link.md)
- **C4 · Sticky bottom bar** — A horizontal bar pinned to the viewport bottom, holding a CTA + a brief reassurance line. [`components/c4-sticky-bottom-bar.md`](components/c4-sticky-bottom-bar.md)

### Testimonials / proof

- **T1 · Pull quote with marginalia** — A quote sits in the wide column; the attribution and source link float in the narrow margin column. [`components/t1-pull-quote-with-marginalia.md`](components/t1-pull-quote-with-marginalia.md)
- **T2 · Logo wall hairline** — A row of customer logos, monochromatic, separated by hairline rules. No card boxes, no shadows. [`components/t2-logo-wall-hairline.md`](components/t2-logo-wall-hairline.md)
- **T3 · Single huge quote** — One quote, set big, centered, taking a whole section. No supporting text, no attribution boxes — attribution is a small caps line beneath. [`components/t3-single-huge-quote.md`](components/t3-single-huge-quote.md)
- **T4 · Numbered stat strip** — A horizontal strip of 3–5 stats (count + qualifier) running across one row. Tabular nums. [`components/t4-numbered-stat-strip.md`](components/t4-numbered-stat-strip.md)

### Footers

- **Ft1 · Mast headed** — A wordmark and tagline anchor a single horizontal band. Two or three small links beside, address or licence below. [`components/ft1-mast-headed.md`](components/ft1-mast-headed.md)
- **Ft2 · Inline rule single line** — A single horizontal line of credits, address, copyright. Hairline rule above. No columns. [`components/ft2-inline-rule-single-line.md`](components/ft2-inline-rule-single-line.md)
- **Ft3 · Index style category list** — Three or four short columns, each headed by a category in small caps, holding 4–6 links each. [`components/ft3-index-style-category-list.md`](components/ft3-index-style-category-list.md)
- **Ft4 · Dense typographic** — One large block of text — credits, references, licence, address — in a small monospace font, fully justified or ragged-right. Editorial colophon energy. [`components/ft4-dense-typographic.md`](components/ft4-dense-typographic.md)
- **Ft5 · Statement** — One large display sentence dominates the footer — a closing line, not a sitemap. Wordmark, minimal links, copyright sit beneath in muted small type. Stripe (older), Mailchimp pre-r [`components/ft5-statement.md`](components/ft5-statement.md)
- **Ft6 · Letter close** — Closes the page like a letter — `Yours, the team. 2026.` Optional postscript line beneath. Sets the page as a piece of writing rather than a product. [`components/ft6-letter-close.md`](components/ft6-letter-close.md)
- **Ft7 · Newsletter first** — The form (label + input + submit) is the *primary* element of the footer; everything else (wordmark, links, copyright) is set in 12 px muted type beneath. Stratechery, Substack-sha [`components/ft7-newsletter-first.md`](components/ft7-newsletter-first.md)
- **Ft8 · Marquee scroll** — A horizontal infinite-scroll line of repeating tagline + dot separator: `STUDIO · 2026 · STUDIO · 2026 · STUDIO · 2026 ·`. Sport-genre sites, fashion lookbooks, brand-forward agenc [`components/ft8-marquee-scroll.md`](components/ft8-marquee-scroll.md)

### Navigation

- **N1 (N1a) · Wordmark 2 links** — Top-of-page bar: wordmark on the left, two text links on the right ("Pricing" / "Sign in"). No logo image, no menu icon. The *minimal* variant — for the dense canonical SaaS bar use **N1b**. [`components/n1-wordmark-2-links.md`](components/n1-wordmark-2-links.md)
- **N2 · Floating chip** — A small fixed chip in a corner — wordmark + a single action ("Try it"). Doesn't sit in document flow. [`components/n2-floating-chip.md`](components/n2-floating-chip.md)
- **N3 · Side rail** — A thin vertical strip on the left edge — wordmark rotated, plus 2–3 dot-indicators for sections. Editorial / portfolio energy. [`components/n3-side-rail.md`](components/n3-side-rail.md)
- **N4 · Hidden behind k** — No visible nav. The user opens a command palette via `⌘K` to get anywhere. Designed for keyboard-first audiences. [`components/n4-hidden-behind-k.md`](components/n4-hidden-behind-k.md)
- **N5 · Floating pill** — A rounded full-pill nav, *visibly detached* from the page edges, sitting ~`var(--space-md)` from the top, soft blur backdrop, soft shadow. Reads as contemporary modern-minimal — Ve [`components/n5-floating-pill.md`](components/n5-floating-pill.md)
- **N6 · Newspaper masthead** — Full-width header, large centred wordmark on the top row, thin issue/date line above or below in serif small caps, optional inline link row beneath, double-rule below the whole thi [`components/n6-newspaper-masthead.md`](components/n6-newspaper-masthead.md)
- **N7 · Brutal slab** — A heavy, full-width nav with a 2 px solid border-bottom, all-caps wordmark and tracked uppercase link row, dense rhythm, no shadow, no rounded corners. Reads as Pentagram project p [`components/n7-brutal-slab.md`](components/n7-brutal-slab.md)
- **N8 · Terminal command** — A nav formatted as a CLI prompt: `> studio --catalog --voice --get▮`. The "links" are command flags. The blinking cursor (`▮`) is allowed *only here* (it has purpose — signals "you [`components/n8-terminal-command.md`](components/n8-terminal-command.md)
- **N9 · Edge aligned minimal** — Wordmark hard-left, single CTA hard-right, vast empty space between, no link row at all. The *absence* is the design — Apple product pages, Carl Hauser, luxury sites. [`components/n9-edge-aligned-minimal.md`](components/n9-edge-aligned-minimal.md)
- **N10 · Floating on scroll morph** — A sticky bar at the top that **morphs into a floating pill** as the user scrolls past a threshold. Two visual modes share one DOM — `.nav` (outer) owns the bar look, `.nav__inner`  [`components/n10-floating-on-scroll-morph.md`](components/n10-floating-on-scroll-morph.md)
- **N1b · Canonical SaaS three-section** — Wordmark-left · centred 4–6-link cluster (some with hover dropdowns) · sign-in + filled CTA right. The dominant modern marketing nav; frosts on scroll. N1/N1a is the *minimal* two-link variant; this is the dense, balanced one. [`components/n1b-saas-three-section.md`](components/n1b-saas-three-section.md)
- **N11 · Mega-menu panel** — Top bar whose triggers open a full-width multi-column panel (icon · title · description per item, grouped, + a feature card); page dims behind a scrim. For platforms/hubs with many grouped destinations. [`components/n11-mega-menu.md`](components/n11-mega-menu.md)
- **N12 · Announcement banner + retracting nav** — A coloured promo banner stacked above one real nav; banner retracts on scroll-down, returns on scroll-up, dismisses via ×. Banner ≠ second nav (colour contrast keeps them distinct). [`components/n12-banner-retract.md`](components/n12-banner-retract.md)
- **N13 · Inline ⌘K search pill** — A visible search pill in the bar (placeholder + `⌘K` hint) opening a spotlight modal with grouped, keyboard-navigable results. The *visible* opposite of N4. For search/docs-heavy products. [`components/n13-inline-cmdk-pill.md`](components/n13-inline-cmdk-pill.md)

---

## Within-archetype variation knobs

Picking an archetype is the first axis of variety. The second is *how you build it*. Two pages built with the same archetype should not be identical — each archetype below has 2–3 *variation knobs*. Pick one value per knob per output. This prevents "every Bento I build looks like the same Bento."

When you pick an archetype, **state the knob values you chose** in the macrostructure stamp comment, e.g.:

```css
/* Hallmark · macrostructure: Bento Grid · F1 Bento knobs: tiles=6, spans=irregular, accent=corner-only · ... */
```

| Archetype | Knob A | Knob B | Knob C |
| --- | --- | --- | --- |
| **H1 Marquee** | Display size: `xxl` (clamp 4–12rem) · `xl` (clamp 3–8rem) | Alignment: left-bias · centred · right-bias | Underlay: none · single rule above · single rule below |
| **H2 Split Diptych** | Ratio: 7/5 · 6/6 · 5/7 | Right side: photo · proof column · pull-quote | Divider: hairline · negative space · vertical rule |
| **H3 Quote-Led** | Quote weight: italic display · roman display · roman body large | Attribution position: under quote · margin-aligned · right-flush | Length: ≤80 chars · 80–160 chars |
| **H4 Stat-Led** | Number style: tabular display · italic display · monospace | Qualifier position: below · inline-right · stacked-above | Secondary stats: none · two below · row of four |
| **H5 Letter** | Salutation: greeting · "Dear X," · time-stamp | Body length: 1 paragraph · 2 paragraphs · 3 paragraphs | Signoff: typed name · drawn signature SVG · initials |
| **H6 Photographic** | Image area: full-bleed · 16/7 · 4/3 · 1/1 square | Caption position: lower-left · upper-right · margin | Text below or overlaid |
| **H7 Demo Video Clipped-Edge** | Clip side: right · left · both | Aspect ratio: 16/10 · 16/9 · 4/3 | Frame: hairline · browser chrome · none |
| **H8 Mockup Split** | Frame style: browser chrome · macOS toolbar · minimal hairline · floating no-frame | Tilt: 0° · 1.5° · 3° | Screenshot count: 1 · stack-of-3 · orbit-of-3 |
| **H9 Custom Illustration** | Build method: Tier-A pure-CSS · Tier-B hand-SVG · Tier-C generated · Tier-D library | Animation: none · loop · scroll-linked | Scale: small accent · dominant |
| **F1 Bento (feature)** | Tiles: 4 · 6 · 7 · 9 | Spans: regular · irregular · mosaic | Border: hairline all · accent corners · none |
| **F2 Sticky-scroll stack** | Pinned side: left · right | Right pane content: code · screenshot · diagram | Pin steps: 3 · 4 · 5 |
| **F3 Tabular spec sheet** | Columns: 2 (key/val) · 3 (key/val/unit) · 4 (with footnote) | Rule density: every row · groups of 3 · headers only | Numbers: tabular · proportional |
| **F4 Step sequence** | Numbering: I/II/III · 01/02/03 · 1.0/2.0/3.0 | Layout: vertical stack · horizontal flow · diagonal | Connector: line · arrow · none |
| **F5 Annotated screenshot** | Callouts: numbered pins · margin labels · inline arrows | Frame: device · plain · floating | Anchor: image-led or text-led |
| **F6 Product card grid** | Card ratio: 3/4 portrait · 1/1 square · 4/3 landscape | Density: 3-up · 4-up · 5-up | Micro-action: Add · Save · View → · none |
| **C1 Outlined chip** | Shape: rectangular · pill (only allowed for tactile/playful tones) · slab | Density: spacious · compact | Adornment: arrow · plus · none |
| **C2 Inline form-as-CTA** | Field count: 1 · 2 · 3 | Submit position: end-of-row · separate line · embedded button | Helper: above · below · none |
| **C3 Typographic link CTA** | Underline: solid · dashed · double · none | Hover behaviour: thicken · slide · colour shift | Arrow: → · ↗ · none |
| **C4 Sticky bottom bar** | Reveal: always · scroll-up · after fold | Anchored: viewport bottom · viewport top · inline at bottom | Shadow: hairline · none · subtle |
| **T1 Pull quote w/ marginalia** | Quote treatment: italic display · roman large · serif italic | Attribution: signed · stamped · timestamped | Marginalia: none · timeline · 1 footnote |
| **T2 Logo wall (hairline)** | Layout: single row · 2 rows · grid 3×N | Logo treatment: monochrome ink · brand colour · ghosted | Divider: hairline cells · none |
| **T3 Single huge quote** | Quote face: serif italic · roman display · italic mono | Width: full-bleed · 60ch · 40ch | Attribution position: same line · separate band |
| **T4 Numbered stat strip** | Layout: 3-up · 4-up · 5-up · 6-up | Number weight: display · body large | Qualifier position: under · inline · above |
| **Ft1 Mast-headed** | Wordmark size: display 3xl · display 2xl · xl | Tagline: italic serif · roman body · none | Links row: inline · 2-line stack |
| **Ft2 Inline single line** | Order: wordmark/links/credit · credit/wordmark/links | Separator: middot · pipe · em-dash · vertical rule | Density: dense · spaced |
| **Ft3 Index columns** | Columns: 3 · 4 · 5 | Heading style: small caps · italic · monospace | Bullet: hairline · none |
| **Ft4 Dense colophon** | Family: monospace · serif · sans | Layout: single block · paragraphs · log-style | Includes: build hash · date · attribution |
| **N1 Wordmark + 2 links** | Position: left/right split · centred · right-flush | Links: text · text+icon · pill | Sticky: yes · no |
| **N2 Floating chip** | Anchor: top · bottom · top-right · bottom-left | Content: theme picker · search · navigation | Backdrop: blur · solid · none |
| **N3 Side-rail** | Side: left · right | Width: 12ch · 16ch · 20ch | Indicator: filled bar · text-only · numbered |
| **N4 Hidden behind ⌘K** | Trigger: button · keyboard only · both | Surface: modal · sheet · spotlight | Recents: shown · hidden |
| **N5 Floating pill** | Width: content-sized · max ~720 px · max ~560 px | Backdrop: blur+saturate · solid · subtle gradient | Anchor: top-centred · top-right · top-left |
| **N6 Newspaper masthead** | Issue line: above wordmark · below wordmark · none | Wordmark size: 3xl · 2xl · xl | Rule: double · single · none |
| **N7 Brutal slab** | Border weight: 2 px · 3 px · 4 px | Letter-spacing: tracked uppercase · normal | CTA: filled slab · outline block · text-only |
| **N8 Terminal command** | Prompt: `>` · `$` · `~/$` | Cursor: in-line at end · after final flag · none | Width: full bleed · content · ~80 ch |
| **N9 Edge-aligned minimal** | CTA shape: outlined · filled pill · text+arrow | Wordmark: serif italic · sans · monospace | Padding-block: tight · default · spacious |
| **N1b SaaS three-section** | Centre links: 3 · 4 · 5–6 | Dropdowns: none · 1 · 2 | Scroll: frost-on-scroll · always-solid · transparent-fixed |
| **N11 Mega-menu** | Columns: 2 · 3 · 4 | Feature cell: none · promo card · code sample | Scrim: dim+blur · dim only · none |
| **N12 Banner + retract** | Banner fill: solid · gradient · tint+ink | Dismiss: yes · none | Bar scroll: sticky · also-frosts |
| **N13 Inline ⌘K-pill** | Pill placement: centred · right-of-brand | Result groups: flat · grouped | Footer hints: shown · hidden |
| **Ft5 Statement** | Sentence width: 28 ch · 38 ch · 50 ch | Wordmark position: under sentence · top-right · none | Rule above meta: hairline · double · none |
| **Ft6 Letter close** | Signoff: italic · roman · monogram | Postscript: yes · no | Width: 40 ch · 60 ch · 80 ch |
| **Ft7 Newsletter-first** | Layout: stacked · inline · split (form left · meta right) | Submit style: filled · outline · arrow link | Privacy line: yes · no |
| **Ft8 Marquee scroll** | Speed: 24 s · 32 s · 48 s | Direction: left · right · alternate (rare) | Glyph: middot · em-dash · slash |

**Anti-pattern:** picking the same knob values across two different outputs is the same kind of templating as picking the same archetype. If your last Bento was `tiles=6, spans=irregular, accent=corner-only`, the next one must change at least one knob.

---


## Routing — which footer fits which genre

| Genre | Default | Also OK |
| --- | --- | --- |
| editorial | **Ft1 Mast-headed** | Ft2, Ft4, Ft6, Ft7 |
| modern-minimal | **Ft2 Inline single line** | Ft1, Ft5 |
| atmospheric | **Ft5 Statement** | Ft1, Ft2 |
| playful | **Ft8 Marquee scroll** | Ft5, Ft3 |
| terminal | **Ft4 Dense colophon** | Ft2 |
| docs / reference | **Ft3 Index columns** | Ft1 |

**Diversification.** Same rule as nav — across consecutive Hallmark runs in the same session, no two outputs should share the same footer archetype.

**Default away from Ft3.** The 4-column index footer is the AI fingerprint when used reflexively (Product · Company · Resources · Legal + social row + tiny copyright). Reach for Ft3 only when the page is a hub or docs-root with a genuine sitemap; default to Ft1, Ft2, Ft4, Ft5, Ft6, Ft7, or Ft8 otherwise.

---


## Routing — which nav fits which genre / theme

| Genre / cluster | Default nav | Acceptable also |
| --- | --- | --- |
| editorial (Newsprint · Garden · Atelier · Carnival · …) | **N6 Masthead** | N1a, N9, N12 |
| modern-minimal (Coral · Cobalt) | **N1b SaaS three-section** | N5, N11, N13, N9 |
| atmospheric (Bloom · Aurora · Midnight · Lumen) | **N5 Floating pill** (blur backdrop sells the mood) | N9, N4, N13, N1b |
| playful (Hum) | **N1b SaaS three-section** | N5, N11, N12, N13, N7 (rounded) |
| terminal / CLI (Terminal) | **N8 Terminal command** | N4 ⌘K-only, N13 |
| docs / reference (Almanac) | **N3 Side-rail** | N13, N1a, N4 |
| commerce / product launch | **N12 Banner + retract** | N1b, N11, N9 |

**Diversification — state it out loud, every build.** Across consecutive Hallmark runs in the same project session (and across multiple test builds of the *same theme*), no two outputs may share the same nav archetype. Before writing nav markup, write one line: *"Previous nav: <X>. This build: <Y>, because <reason>."* This is the same accountability step as the macrostructure rotation. **A theme with 4 test builds should show 4 different navs** — e.g. Hum across Curio/Sprout/Tally/Mixtape uses N5 → N1b → N12 → N13. Reaching for the genre *default* on every build is exactly the failure this rule exists to prevent; rotate through the "Acceptable also" column deliberately.

**Default away from N1a.** The most-recognised AI fingerprint is N1a (wordmark + inline link row + button-right) used reflexively. For a real product nav reach for **N1b** (the dense, balanced canonical bar) or N5/N11/N13 first; reach for N1a only when the page genuinely has 2 destinations.

---


## Picking from this file

When building a section:

1. Identify the section's role (hero / section-head / feature / CTA / testimonial / footer / navigation).
2. Glance at the archetypes in that category.
3. Pick the one whose "Use when" fits the brief.
4. Make sure no two sections in the same page use the same archetype.
5. If the macrostructure suggests a default (e.g., Bento Grid → F1 Bento), use it; if it doesn't suggest, vary deliberately.

The goal is composed variety — within a page, sections feel different from each other; across pages Hallmark builds, sections feel different from the last.

---


## Mobile collapse — per archetype

Every archetype has a defined collapse behaviour at narrow viewports. The two breakpoints to know:

- **60 rem (~960 px)** — the *layout* breakpoint. Multi-column grids collapse to single column. Tilts and clip effects drop. Sticky panes unstick.
- **40 rem (~640 px)** — the *typography* breakpoint. Display sizes shrink one step. Side-margin labels move inline. Annotations consolidate.

Below 60 rem the archetype must still feel like itself — same hierarchy, same tone, same rhythm — but in a stacked single-column form. Below 40 rem the page is a phone; treat space like a luxury.

| Archetype | Below 60 rem | Below 40 rem |
| --- | --- | --- |
| **H1 Marquee** | unchanged (typography-only; centres / left-biases naturally) | display size step down (`xl` → `lg`); reduce side padding |
| **H2 Split Diptych** | grid `1fr` (text top, proof column below); divider becomes hairline-rule between | proof column collapses to a 2-column compact grid for items |
| **H3 Quote-Led** | quote stays full width; attribution wraps to its own line | quote size step down; attribution font-size step down |
| **H4 Stat-Led** | number stays full width, text stacks below; secondary stats become 2-up grid | number size step down (`clamp` floor lifts); qualifier text wraps |
| **H5 Letter** | unchanged single column; aside (if present) moves below body, divider becomes top border | salutation size step down; signoff tightens |
| **H6 Photographic** | image stays full-bleed; caption moves from absolute corner to inline below image | caption font-size step down; corner caption never overlaps text on phones |
| **H7 Demo Video Clipped-Edge** | **drops the clip**; goes `1fr` stacked, full-width media; tilt removed (clipping at 375 px reads as broken) | media reduces to 16/9; poster image used (auto-playing on cellular is hostile) |
| **H8 Mockup Split** | drops the tilt; grid `1fr`; mockup goes full-width below text | annotation pins consolidate; numbered legend moves below mockup |
| **H9 Custom Illustration** | grid `1fr`; illustration moves below text (or above — pick by tone) | illustration scales to ≤ 40 % viewport width; never dominates |
| **F1 Bento** | grid drops from 6/4-col to 2-col; large tiles span 2; small tiles span 1 | drops to 1-col; tile order respects information priority |
| **F2 Sticky-scroll stack** | sticky pane unsticks; content becomes linear sequence of paired text+visual blocks | the visuals shrink to 16/9 inline; no sticky behaviour at all |
| **F3 Tabular spec sheet** | columns reduce: 4-col → 2 (key + value), drop unit + footnote | spec list goes vertical; each row is `dt` above `dd` |
| **F4 Step sequence** | numbering moves from left margin to inline-with-step | step containers tighten; connector lines drop |
| **F5 Annotated screenshot** | screenshot full-width; annotations restack as a numbered list below | screenshot 16/9; annotations consolidate into a legend |
| **F6 Product card grid** | grid 3-up → 2-up | grid 2-up → 1-up; card height becomes flexible |
| **C1 Outlined chip** | unchanged (chips wrap onto multiple lines if needed) | full-width single chip ; min-height 44 px hit target |
| **C2 Inline form-as-CTA** | input + button stack vertically; full-width | label moves above input; button is full-width below |
| **C3 Typographic link** | unchanged (links wrap naturally) | unchanged |
| **C4 Sticky bottom bar** | unchanged (already designed for narrow); ensure 44 px min-height | label truncates if needed; CTA stays right-aligned |
| **T1 Pull quote w/ marginalia** | marginalia move below quote; divider becomes hairline | marginalia consolidate into a single line |
| **T2 Logo wall** | grid 6-up → 3-up | grid 3-up → 2-up; logo height step down (32 px → 24 px) |
| **T3 Single huge quote** | quote remains full width; attribution wraps below | quote size step down by 1.4× |
| **T4 Numbered stat strip** | strip 4-up → 2-up | strip becomes vertical; 1 stat per row |
| **Ft1 Mast-headed** | links wrap to two lines; tagline below wordmark | wordmark size step down; tagline italicises in if not already |
| **Ft2 Inline single line** | links wrap to multiple lines; separator becomes a soft return | becomes a vertical list |
| **Ft3 Index columns** | grid 4-col → 2-col | grid 2-col → 1-col; column heads remain |
| **Ft4 Dense colophon** | unchanged (mono/wraps naturally); reduce padding | font-size step down |
| **Ft5 Statement** | sentence stays full width; meta row stacks | sentence size step down (clamp floor lifts); meta wraps |
| **Ft6 Letter close** | unchanged single column; postscript wraps | signoff size step down; postscript italicises if not already |
| **Ft7 Newsletter-first** | input + button stack vertically; full-width | label moves above input; button is full-width below |
| **Ft8 Marquee scroll** | unchanged (already designed for narrow); slow speed by ~25 % | speed slows further; track height step down |
| **N1 Wordmark + 2 links** | unchanged | links wrap to second line if long; wordmark stays |
| **N2 Floating chip** | chip remains floating; reduce padding | chip widens to support 44 px hit target; never below 280 px |
| **N3 Side-rail** | rail unsticks and becomes a hamburger trigger above | hamburger becomes the only nav |
| **N4 ⌘K-only** | hamburger appears for users who don't know ⌘K | unchanged (⌘K equivalent is on-screen tap) |
| **N5 Floating pill** | pill drops link list, keeps wordmark + CTA; stays detached | becomes a top-anchored corner chip — wordmark left, hamburger right |
| **N6 Newspaper masthead** | issue line stacks above wordmark; nav links wrap to a second row | wordmark size step down; nav row collapses behind a "menu" disclosure |
| **N7 Brutal slab** | links wrap to second line; CTA stays right-aligned | links collapse to hamburger; wordmark + hamburger only |
| **N8 Terminal command** | flags wrap to a second `>` line if needed; cursor stays at the end | becomes a single hamburger labelled `> menu`; cursor visible at line end |
| **N9 Edge-aligned minimal** | unchanged (already designed for breathing room) | wordmark + CTA stay edge-aligned; CTA pads to 44 px hit target |

**Cross-cutting rules:**

- All hit targets ≥ 44 × 44 px below 40 rem (WCAG AA). Never below.
- Padding-inline ≥ `clamp(1rem, 4vw, 1.5rem)` on the page container so content doesn't kiss the screen edge.
- Disable any scroll-linked animation below 40 rem (mobile scroll has its own physics; layered animations fight it).
- Image `loading="lazy"` always below the fold; **never on the LCP element regardless of viewport.**
- Auto-play video respects `data-saver` (`navigator.connection.saveData`) — replaces with poster when set.




---

# ===== FULL RECIPES (vendored from references/components/) =====


<!-- c1-outlined-chip.md -->

### C1 · Outlined chip
A bordered, transparent button with a typographic verb ("Save changes").
*Use when:* the page has one primary action; you want it visible but quiet.
*Don't confuse with:* C2 Oversized solid (which is statement-loud).

```html
<a class="cta-outline">Open your studio →</a>
```
```css
.cta-outline { display: inline-flex; align-items: center; gap: 0.4em; padding: 0.7rem 1.2rem; border: 1px solid var(--color-ink); min-height: 44px; }
```


<!-- c2-inline-form-as-cta.md -->
### C2 · Inline form-as-CTA
The CTA *is* the form — a single email input with a "Submit →" beside it. No separate landing for sign-up.
*Use when:* the action is collecting an email.
*Don't confuse with:* C1 Outlined chip (which navigates, not submits).

```html
<form class="cta-form">
  <label for="email" class="visually-hidden">Email</label>
  <input id="email" type="email" placeholder="you@example.com" />
  <button type="submit">Send →</button>
</form>
```
```css
.cta-form { display: grid; grid-template-columns: 1fr auto; border-bottom: 1px solid var(--color-ink); }
.cta-form input { background: none; border: 0; padding: 0.7rem 0; min-height: 44px; }
```


<!-- c3-typographic-link.md -->
### C3 · Typographic link
Just a word, an arrow, and a 1-px underline. No box, no fill.
*Use when:* the page is editorial / Long Document; CTAs should not shout.
*Don't confuse with:* C1 Outlined chip (which is bordered).

```html
<a class="link">Read the case study →</a>
```


<!-- c4-sticky-bottom-bar.md -->
### C4 · Sticky bottom bar
A horizontal bar pinned to the viewport bottom, holding a CTA + a brief reassurance line.
*Use when:* the page is long and the CTA needs to be reachable always.
*Don't confuse with:* anything in the fold; this is a *persistent* element, not a hero CTA.

```html
<aside class="cta-sticky">
  <span>Try it free for 14 days.</span>
  <a class="cta-outline">Start →</a>
</aside>
```
```css
.cta-sticky { position: fixed; left: 0; right: 0; bottom: 0; padding: var(--space-sm) var(--space-md); background: var(--color-paper); border-top: 1px solid var(--color-rule); display: flex; justify-content: space-between; align-items: center; }
```

---


<!-- f1-bento-grid.md -->

### F1 · Bento grid
Asymmetric grid of 8–15 tiles in mixed spans (1×1, 2×1, 1×2, 2×2). Visual rhythm via size.
*Use when:* multiple equally-valid entry points; SaaS feature page.
*Don't confuse with:* F2 Sticky-scroll (which stacks vertically with sticky pacing).

```html
<section class="bento">
  <article class="cell span-2x2">…</article>
  <article class="cell span-1x1">…</article>
  <article class="cell span-2x1">…</article>
</section>
```
```css
.bento { display: grid; grid-template-columns: repeat(4, 1fr); grid-auto-rows: 12rem; gap: var(--space-md); }
.span-2x2 { grid-column: span 2; grid-row: span 2; }
.span-2x1 { grid-column: span 2; }
.span-1x2 { grid-row: span 2; }
@media (max-width: 56rem) { .bento { grid-template-columns: repeat(2, 1fr); } }
```


<!-- f2-sticky-scroll-stack.md -->
### F2 · Sticky-scroll stack
Sticky left pane, scrolling right pane that cycles through related screenshots.
*Use when:* feature has multiple sub-states worth showing in sequence.
*Don't confuse with:* F4 Step sequence (which is linearly numbered, not synced).

```html
<section class="sticky-stack">
  <div class="pane-sticky"><h3>…</h3><p>…</p></div>
  <div class="pane-scroll">
    <figure>1</figure><figure>2</figure><figure>3</figure>
  </div>
</section>
```
```css
.sticky-stack { display: grid; grid-template-columns: 1fr 1fr; gap: var(--space-2xl); }
/* `calc(--banner-height + --space-xl)` so the sticky pane docks below the
   nav with breathing room. Falls back to --space-xl alone when no sticky
   nav is on the page (slop-test gate 56). */
.pane-sticky { position: sticky; top: calc(var(--banner-height, 0px) + var(--space-xl)); align-self: start; z-index: var(--z-sticky); }
```


<!-- f3-tabular-spec-sheet.md -->
### F3 · Tabular spec sheet
Each row is a feature; columns hold name, value, footnote. Hairline rules between rows. Tabular numerics.
*Use when:* features compare quantitatively.
*Don't confuse with:* F1 Bento (which is non-tabular and visually rhythmic).

```html
<table class="spec-sheet tnum">
  <tr><th>Latency</th><td>p99 &lt; 50 ms</td><td class="muted">measured externally</td></tr>
  <tr>…</tr>
</table>
```


<!-- f4-step-sequence.md -->
### F4 · Step sequence
Numbered stages (`1.0 → 2.0 → 3.0`) flow vertically. Each stage has a heading, a paragraph, sometimes a small visual.
*Use when:* the product is a workflow, not a single moment.
*Don't confuse with:* F2 Sticky-scroll (which doesn't number stages).

```html
<ol class="steps">
  <li><span class="stage">1.0</span><h3>Intake.</h3><p>…</p></li>
  <li><span class="stage">2.0</span><h3>Plan.</h3><p>…</p></li>
</ol>
```


<!-- f5-annotated-screenshot.md -->
### F5 · Annotated screenshot
A product capture sits centre-stage with arrows or short labels pointing to UI details.
*Use when:* the product UI itself is the explanation.
*Don't confuse with:* F2 Sticky-scroll (which uses multiple screenshots in sequence).

```html
<figure class="annotated">
  <img src="" />
  <span class="callout" style="--x:60%; --y:30%;">→ assigns automatically.</span>
</figure>
```


<!-- f6-product-card-grid.md -->
### F6 · Product card grid
Each card is a product, not a feature. Image · name · price · one micro-action. Reads like a shop floor, not a marketing site.
*Use when:* the brief is commerce, catalogue, lookbook, marketplace — anything where the page sells *things*, not *features*.
*Don't confuse with:* F1 Bento (which sells *features*; tiles vary in size and span). Product cards are uniform on purpose — the rhythm comes from the products, not the layout.

**Variation knobs:** card ratio (3/4 portrait · 1/1 square · 4/3 landscape) · density (3-up · 4-up · 5-up) · price treatment (under name · over image · hover-reveal) · micro-action (Add · Save · View → · none).

```html
<section class="product-grid">
  <article class="product">
    <a class="product__media" href=""><img src="" alt="" loading="lazy" /></a>
    <div class="product__meta">
      <h3 class="product__name">Linen Apron · Indigo</h3>
      <p class="product__price tabular-nums">¥ 6,400</p>
    </div>
    <button class="product__add" aria-label="Add Linen Apron to bag">+</button>
  </article>
  <!-- ... more products, uniform shape ... -->
</section>
```
```css
.product-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: var(--space-xl) var(--space-lg); }
@media (max-width: 60rem) { .product-grid { grid-template-columns: repeat(2, 1fr); } }
.product { display: grid; gap: var(--space-sm); position: relative; }
.product__media { display: block; aspect-ratio: 3 / 4; background: var(--color-paper-2); overflow: hidden; }
.product__media img { width: 100%; height: 100%; object-fit: cover; transition: transform var(--dur-long) var(--ease-out); }
.product__media:hover img { transform: scale(1.02); }
.product__name { font-family: var(--font-body); font-size: var(--text-md); margin: 0; }
.product__price { font-family: var(--font-mono); font-size: var(--text-sm); color: var(--color-ink-2); }
.product__add { position: absolute; top: var(--space-sm); right: var(--space-sm); width: 32px; height: 32px; background: var(--color-paper); border: var(--rule-hair) solid var(--color-rule-2); cursor: pointer; opacity: 0; transition: opacity var(--dur-short) var(--ease-out); }
.product:hover .product__add, .product:focus-within .product__add { opacity: 1; }
@media (pointer: coarse) { .product__add { opacity: 1; } }
```

**Anti-patterns to avoid in product grids:**
- Don't borrow Bento's irregular spans — products want uniform rhythm.
- Don't put feature-style two-line descriptions under product names. The price *is* the description.
- Don't auto-scale the image on idle — only on hover, and only by 1.02× max.
- Don't use cards with shadow + radius + border + tile + ribbon. Pick one container signal.

---


<!-- ft1-mast-headed.md -->

### Ft1 · Mast-headed
A wordmark and tagline anchor a single horizontal band. Two or three small links beside, address or licence below.
*Use when:* the page has heavy content; the footer should be quiet and singular.
*Don't confuse with:* Ft2 Inline-rule (which is even more reduced).

```html
<footer class="foot-mast">
  <p class="wordmark">Studio Name</p>
  <p class="tagline muted">Designs that don't look generated.</p>
  <p class="links muted">Imprint · Privacy · Contact</p>
</footer>
```


<!-- ft2-inline-rule-single-line.md -->
### Ft2 · Inline-rule single line
A single horizontal line of credits, address, copyright. Hairline rule above. No columns.
*Use when:* the page is editorial and the footer is afterthought.
*Don't confuse with:* Ft4 Dense typographic (which packs more in).

```html
<footer class="foot-line">
  <p>© 2026 · 137 Marlow Street · MIT licensed</p>
</footer>
```


<!-- ft3-index-style-category-list.md -->
### Ft3 · Index-style category list
Three or four short columns, each headed by a category in small caps, holding 4–6 links each.
*Use when:* the page is a hub or a documentation root.
*Don't confuse with:* Ft4 Dense typographic (which is one big block, not columns).

```html
<footer class="foot-index">
  <div><p class="caps">Product</p><ul>…</ul></div>
  <div><p class="caps">Company</p><ul>…</ul></div>
  <div><p class="caps">Resources</p><ul>…</ul></div>
</footer>
```


<!-- ft4-dense-typographic.md -->
### Ft4 · Dense typographic
One large block of text — credits, references, licence, address — in a small monospace font, fully justified or ragged-right. Editorial colophon energy.
*Use when:* the brand is editorial and a colophon-style sign-off fits.
*Don't confuse with:* Ft3 Index (which navigates).

```html
<footer class="foot-dense mono">
  <p>Hallmark v0.2.0. Built with The Future, Fraunces, IBM Plex Mono. MIT licensed. Powered by Together AI. 137 Marlow Street, 2026.</p>
</footer>
```


<!-- ft5-statement.md -->
### Ft5 · Statement
One large display sentence dominates the footer — a closing line, not a sitemap. Wordmark, minimal links, copyright sit beneath in muted small type. Stripe (older), Mailchimp pre-rebrand, agency portfolio closers.
*Use when:* the page wants a *closing line* — editorial, manifesto, atmospheric. The sentence pairs with the page's argument.
*Don't confuse with:* Ft1 Mast-headed (which leads with the wordmark, not a sentence).

```html
<footer class="foot-stmt">
  <p class="foot-stmt__line">Build something they'll remember.</p>
  <div class="foot-stmt__meta">
    <span class="wordmark">Studio</span>
    <span class="muted">© 2026 · MIT</span>
  </div>
</footer>
```
```css
.foot-stmt { padding: var(--space-2xl) var(--page-gutter) var(--space-xl); display: grid; gap: var(--space-lg); }
.foot-stmt__line { font-family: var(--font-display); font-size: clamp(1.75rem, 5vw, 3.25rem); line-height: 1.0; letter-spacing: -0.02em; max-width: 28ch; margin: 0; }
.foot-stmt__meta { display: flex; justify-content: space-between; align-items: baseline; padding-block-start: var(--space-sm); border-top: var(--rule-hair) solid var(--color-rule); }
```

*Anti-pattern:* using a Statement footer on a docs root or hub. The sentence reads as marketing fluff there; default Ft3 instead.


<!-- ft6-letter-close.md -->
### Ft6 · Letter close
Closes the page like a letter — `Yours, the team. 2026.` Optional postscript line beneath. Sets the page as a piece of writing rather than a product.
*Use when:* the page voice is warm, hand-written, editorial-quiet — Garden, Atelier, personal sites.
*Don't confuse with:* Ft1 Mast-headed (which is a wordmark anchor, not a signoff).

```html
<footer class="foot-letter">
  <p class="foot-letter__close">Yours,<br><span class="foot-letter__sign">— Studio</span></p>
  <p class="foot-letter__ps muted">P.S. — letters back welcome at <a href="mailto:hello@studio">hello@studio</a>.</p>
</footer>
```
```css
.foot-letter { padding: var(--space-2xl) var(--page-gutter); max-width: 60ch; }
.foot-letter__close { font-family: var(--font-display); font-style: italic; font-size: var(--text-lg); line-height: 1.4; }
.foot-letter__sign { font-style: normal; font-weight: 600; }
.foot-letter__ps { font-size: var(--text-sm); margin-top: var(--space-md); }
```

*Anti-pattern:* using Ft6 on a stat-led / B2B product page — voice mismatch reads as twee. Reserve for genuinely letter-shaped pages.


<!-- ft7-newsletter-first.md -->
### Ft7 · Newsletter-first
The form (label + input + submit) is the *primary* element of the footer; everything else (wordmark, links, copyright) is set in 12 px muted type beneath. Stratechery, Substack-shaped sites, indie magazines.
*Use when:* the brand legitimately publishes — and the page above the fold has *already* offered a subscription. The footer is a final invitation, not an ambush.
*Don't confuse with:* Ft1 (which doesn't ask for anything).

```html
<footer class="foot-news">
  <form class="foot-news__form" action="/subscribe" method="post">
    <label for="foot-email">Letters from the studio · monthly</label>
    <div class="foot-news__row">
      <input id="foot-email" name="email" type="email" required placeholder="you@domain">
      <button type="submit" class="cta-fill">Subscribe</button>
    </div>
  </form>
  <p class="foot-news__meta muted">Studio · © 2026 · <a href="/imprint">Imprint</a></p>
</footer>
```
```css
.foot-news { padding: var(--space-2xl) var(--page-gutter); display: grid; gap: var(--space-lg); max-width: 56ch; }
.foot-news__form label { display: block; font-size: var(--text-sm); margin-block-end: var(--space-2xs); }
.foot-news__row { display: flex; gap: var(--space-2xs); }
.foot-news__row input { flex: 1; min-height: 44px; padding-inline: var(--space-sm); border: var(--rule-hair) solid var(--color-rule); border-radius: var(--radius-input); background: var(--color-paper); }
.foot-news__row input:focus-visible { outline: 2px solid var(--color-focus); outline-offset: 1px; }
.foot-news__meta { font-size: var(--text-xs); }
```

*Anti-pattern:* Ft7 when the page never said "subscribe" above the fold. The footer is an honest *conclusion*; if you didn't ask, don't ambush. Drop to Ft2 instead.


<!-- ft8-marquee-scroll.md -->
### Ft8 · Marquee scroll
A horizontal infinite-scroll line of repeating tagline + dot separator: `STUDIO · 2026 · STUDIO · 2026 · STUDIO · 2026 ·`. Sport-genre sites, fashion lookbooks, brand-forward agencies.
*Use when:* the brand voice is loud, kinetic, sport-or-manifesto.
*Don't confuse with:* Ft4 Dense colophon (which is static text).

```html
<footer class="foot-marquee" aria-label="Footer">
  <div class="foot-marquee__track" aria-hidden="true">
    <span>STUDIO · 2026 · STUDIO · 2026 · STUDIO · 2026 · STUDIO · 2026 ·</span>
    <span>STUDIO · 2026 · STUDIO · 2026 · STUDIO · 2026 · STUDIO · 2026 ·</span>
  </div>
  <p class="visually-hidden">Studio · 2026 · MIT licensed</p>
</footer>
```
```css
.foot-marquee { overflow: hidden; border-top: 2px solid var(--color-ink); }
.foot-marquee__track { display: flex; gap: var(--space-2xl); white-space: nowrap; padding-block: var(--space-md); animation: foot-marquee 32s linear infinite; }
.foot-marquee__track span { font-family: var(--font-display); font-weight: 700; letter-spacing: 0.08em; font-size: clamp(1rem, 2.5vw, 1.5rem); }
@keyframes foot-marquee { from { transform: translateX(0); } to { transform: translateX(-50%); } }
@media (prefers-reduced-motion: reduce) { .foot-marquee__track { animation: none; } }
```

*Anti-pattern:* using Ft8 on editorial / quiet contexts — the motion reads as loud. Pair only with playful / sport / manifesto voices, and always honour `prefers-reduced-motion: reduce`.

---


<!-- h1-marquee.md -->

### H1 · Marquee
A single statement fills the fold. No subhead, no CTA in view.
*Use when:* the brand or person *is* the message.
*Don't confuse with:* H4 Stat-Led (which is a number, not a statement).

```html
<section class="hero-marquee">
  <h1 class="display-xxl">A statement.</h1>
</section>
```
```css
.hero-marquee { min-height: 80dvh; display: grid; align-content: end; padding: 0 var(--page-gutter) var(--space-2xl); }
.display-xxl { font-size: clamp(4rem, 12vw, 12rem); line-height: 0.92; }
```


<!-- h2-split-diptych.md -->
### H2 · Split Diptych
Headline + lede on one side, image or product capture on the other. 6/6 or 7/5 columns.
*Use when:* you can pair every claim with a visual proof.
*Don't confuse with:* H6 Photographic (which puts the image full-bleed, not paired).

```html
<section class="hero-split">
  <div><h1>…</h1><p>…</p><a class="cta-outline">…</a></div>
  <figure><img src="" /></figure>
</section>
```
```css
.hero-split { display: grid; grid-template-columns: 7fr 5fr; gap: var(--space-2xl); align-items: center; }
@media (max-width: 56rem) { .hero-split { grid-template-columns: 1fr; } }
```


<!-- h3-quote-led.md -->
### H3 · Quote-Led
A pull-quote with attribution is the hero. Your headline is borrowed credibility.
*Use when:* you have a real testimonial that earns the front page.
*Don't confuse with:* T3 Single huge quote (which lives mid-page, not in the hero slot).

```html
<section class="hero-quote">
  <blockquote class="display-italic">"…"</blockquote>
  <p class="attribution">— Name, Role, Company</p>
</section>
```


<!-- h4-stat-led.md -->
### H4 · Stat-Led
A giant number or metric is the hero. A small qualifier line below.
*Use when:* you have one defensible, externally-verifiable number.
*Don't confuse with:* T4 Numbered stat strip (which is several stats in a row, not one focal).

```html
<section class="hero-stat">
  <p class="figure tnum">99.97<span class="unit">%</span></p>
  <p class="qualifier">…</p>
</section>
```
```css
.figure { font-size: clamp(6rem, 18vw, 16rem); font-variant-numeric: tabular-nums; line-height: 0.85; }
```


<!-- h5-letter-hero.md -->
### H5 · Letter Hero
First-person opening — "Dear reader,". No buttons in fold. Reads as personal correspondence.
*Use when:* the founder's voice is the brand.
*Don't confuse with:* H1 Marquee (which is impersonal declaration).

```html
<section class="hero-letter">
  <p class="salutation"><em>Dear reader,</em></p>
  <p class="lede">…</p>
</section>
```


<!-- h6-photographic-fold.md -->
### H6 · Photographic Fold
Single full-bleed image fills the viewport. Caption sits in a corner.
*Use when:* you have real photography that earns full-bleed.
*Don't confuse with:* H2 Split (which pairs image with text in a grid).

```html
<section class="hero-photo">
  <img class="bleed" src="" alt="" />
  <p class="caption">Spring, 2026.</p>
</section>
```
```css
.hero-photo { position: relative; height: 80dvh; }
.hero-photo .bleed { width: 100%; height: 100%; object-fit: cover; }
.hero-photo .caption { position: absolute; bottom: var(--space-md); right: var(--space-md); }
```


<!-- h7-demo-video-clipped-by-viewport-edge.md -->
### H7 · Demo Video — Clipped-by-viewport-edge
Display headline left, demo video right, the rightmost ~10–20 % extending past the viewport so it's intentionally cut off. The clip *is* the design — implies "there's more product than fits the screen". Pioneered by Linear, refined by Vercel / Resend / Cursor.
*Use when:* the brief is SaaS / dev-tool / dashboard / platform AND you have real footage of the product (or a hand-built CSS-art mockup of it).
*Don't confuse with:* H4 Stat-Led (number-led, no video) or H8 Mockup Split (still screenshot, not video).

See [`hero-enrichment.md`](../hero-enrichment.md) for the full E1 recipe (codec chain, autoplay rules, `prefers-reduced-motion` fallback, mobile collapse). The cookbook entry below is the structural sketch.

```html
<section class="hero hero--clipped">
  <div class="hero__copy">
    <h1>Plan, build, ship.</h1>
    <p>The project tracker your engineering team won't ignore.</p>
  </div>
  <figure class="hero__media">
    <video autoplay muted loop playsinline preload="metadata"
           poster="/hero-poster.webp" fetchpriority="high">
      <source src="/hero.av1.mp4" type='video/mp4; codecs="av01.0.05M.08"'>
      <source src="/hero.h264.mp4" type="video/mp4">
    </video>
  </figure>
</section>
```
```css
.hero--clipped { display: grid; grid-template-columns: 1fr 1.4fr; gap: var(--space-2xl); overflow: visible; }
.hero__media   { width: calc(100% + 12vw); aspect-ratio: 16 / 10; border-radius: 12px; overflow: hidden; }
@media (max-width: 60rem) { .hero--clipped { grid-template-columns: 1fr; } .hero__media { width: 100%; } }
```


<!-- h8-mockup-split-browser-framed.md -->
### H8 · Mockup Split (browser-framed)
Headline left, browser-frame mockup right, the mockup tilted 1–3° for life. Frame can be browser chrome, macOS toolbar, minimal hairline, or floating no-frame.
*Use when:* you're selling a web app and you have a clean, well-lit screenshot.
*Don't confuse with:* H7 Clipped-Edge (which extends past the viewport) or H2 Split Diptych (which uses photography or proof column, not a product mockup).

```html
<section class="hero-mock">
  <div>
    <h1>The studio's new mute button.</h1>
    <p>Press <kbd>⌘ M</kbd> from anywhere.</p>
  </div>
  <figure class="mock">
    <header class="mock__chrome"><span></span><span></span><span></span></header>
    <div class="mock__body"><!-- screenshot or CSS-art mockup --></div>
  </figure>
</section>
```
```css
.hero-mock  { display: grid; grid-template-columns: 1fr 1.2fr; gap: var(--space-2xl); align-items: center; }
.mock       { transform: rotate(1.5deg); border-radius: 12px; overflow: hidden; box-shadow: 0 24px 60px -20px oklch(20% 0.02 60 / 0.18); }
.mock__chrome { display: flex; gap: 6px; padding: 10px 12px; background: var(--color-paper-2); border-block-end: var(--rule-hair) solid var(--color-rule); }
.mock__chrome span { width: 10px; height: 10px; border-radius: 50%; background: var(--color-rule-2); }
```


<!-- h9-custom-illustration-centerpiece.md -->
### H9 · Custom Illustration Centerpiece
A single hand-built SVG (Tier B in the enrichment hierarchy — or pure CSS at Tier A for simpler shapes) sitting on the hero as one illustrative element. The bakery loaf, the studio's mascot, the workflow diagram.
*Use when:* the brand has a *thing* that benefits from being drawn — a craft, a character, a process.
*Don't confuse with:* H6 Photographic (real photography) or H8 Mockup (a product screenshot, not artwork).

The illustration itself is *built*, not picked from Storyset / Humaaans / unDraw / Lottie. See [`custom-craft.md`](../custom-craft.md) for full recipes (CSS art, hand-built SVG, declarative animation). The cookbook entry below is the page-level structural sketch.

```html
<section class="hero-art">
  <div>
    <p class="eyebrow">Maple Street Bread · est. 2026</p>
    <h1>Sourdough, every morning.</h1>
    <p>Slow-fermented overnight, baked on stone, before you wake.</p>
  </div>
  <svg viewBox="0 0 200 100" class="loaf" aria-label="A loaf of bread">
    <path class="loaf__body" d="M 20 70 Q 100 10 180 70 L 180 90 L 20 90 Z" />
    <path class="loaf__score" d="M 60 50 L 90 30 M 100 45 L 130 25 M 140 50 L 165 35" />
  </svg>
</section>
```
```css
.hero-art   { display: grid; grid-template-columns: 1fr 1fr; gap: var(--space-2xl); align-items: center; }
.loaf__body { fill: oklch(72% 0.14 50); }
.loaf__score{ stroke: oklch(38% 0.10 35); stroke-width: 2; fill: none; stroke-linecap: round; }
```

---


<!-- n1-wordmark-2-links.md -->

### N1 · Wordmark + 2 links
Top-of-page bar: wordmark on the left, two text links on the right ("Pricing" / "Sign in"). No logo image, no menu icon.
*Use when:* the page has very few destinations.
*Don't confuse with:* N3 Side-rail (which is vertical).

```html
<nav class="nav-min">
  <a class="wordmark">Studio</a>
  <ul><li><a>Pricing</a></li><li><a>Sign in</a></li></ul>
</nav>
```


<!-- n10-floating-on-scroll-morph.md -->
### N10 · Floating-on-scroll morph
A sticky bar at the top that **morphs into a floating pill** as the user scrolls past a threshold. Two visual modes share one DOM — `.nav` (outer) owns the bar look, `.nav__inner` (inner) owns the pill look. Cross-faded on a single class toggle (`.is-floating`) with one timing curve. Active layer feels seamless; AI defaults always botch this.
*Use when:* atmospheric / modern-minimal pages where the kinetic micro-moment earns its place. Adds a single tasteful surprise; resists novelty.
*Don't confuse with:* N5 Floating pill (always-on, no scroll behaviour). N10 is N5 plus a default-bar state that morphs *into* it.

```html
<header class="nav">
  <div class="nav__inner">
    <a class="wordmark">Hallmark</a>
    <ul class="nav__links">…</ul>
  </div>
</header>
```

The full recipe — the four laws (height-constant, transform-for-offset, cross-fade-everything, single-curve), the property-morph table, the scroll-handler script, and the eight anti-patterns Hallmark refuses — lives in [`floating-nav.md`](../floating-nav.md). Reach for that file *before* building this archetype. Skipping the four laws is what makes 90% of attempts read as broken.

*Anti-pattern (one of eight in floating-nav.md):* swapping two `<header>` elements via opacity instead of cross-fading one DOM. Doubles markup, fights focus order, desyncs content.

---


<!-- n11-mega-menu.md -->
### N11 · Mega-menu panel
A standard top bar whose triggers open a **full-width multi-column panel** — icon · title · description per item, grouped under column headers, often with a promoted feature card on one side. The page dims behind a scrim. Vercel "Products", Figma "Products", Notion "Resources".
*Use when:* the brand has many destinations that need grouping + explanation (a platform with 6+ products, or docs/resources hubs). The payload is the design problem, not the bar.
*Don't confuse with:* N1b (small single-column dropdowns); N1a (no dropdowns at all).

```html
<header class="nav">
  <div class="nav__inner">
    <a class="nav__brand">Northwind</a>
    <nav class="nav__center">
      <div class="mega" data-mega="products"><button class="nav__link" aria-controls="mega-products" aria-expanded="false">Products <span class="nav__caret"></span></button></div>
    </nav>
    <div class="nav__right"><a class="btn btn--accent">Get started</a></div>
  </div>
  <div class="mega-panel" id="mega-products" data-panel="products">
    <div class="mega-panel__inner">
      <div class="mega-col"><p class="mega-col__head">Move money</p><a class="mega-link"><span class="mega-link__ico"></span><span><b>Payments</b><i>cards, ACH, wires</i></span></a></div>
      <a class="mega-feature"><p class="mega-feature__title">Vault</p><p class="mega-feature__desc">stablecoin settlement</p></a>
    </div>
  </div>
</header>
<div class="nav-scrim" id="scrim"></div>
```
```css
.mega-panel { position: absolute; top: 100%; left: 0; right: 0; opacity: 0; visibility: hidden; transform: translateY(-10px);
  background: color-mix(in oklch, var(--color-paper) 96%, transparent); backdrop-filter: blur(20px) saturate(160%);
  border-bottom: 1px solid var(--color-rule); box-shadow: 0 30px 60px -28px oklch(0% 0 0 / 0.35);
  transition: opacity 240ms, transform 280ms var(--ease-spring), visibility 240ms; }
.mega-panel.is-open { opacity: 1; visibility: visible; transform: none; }
.mega-panel__inner { max-width: var(--page-max); margin: 0 auto; padding: 2rem var(--page-gutter);
  display: grid; grid-template-columns: repeat(3, 1fr) 1.1fr; gap: 2rem; }
.nav-scrim { position: fixed; inset: 0; z-index: 400; background: oklch(18% 0.01 250 / 0.28); backdrop-filter: blur(2px);
  opacity: 0; visibility: hidden; transition: opacity 260ms, visibility 260ms; }
.nav-scrim.is-active { opacity: 1; visibility: visible; }
```
*JS:* hover opens (with a ~140ms close-grace timer so the pointer can travel into the panel), click toggles, Esc closes, only one panel open at a time, scrim + `aria-expanded` follow state.

**Knobs** — *Columns:* 2 · 3 · 4 · *Feature cell:* none · promo card · code sample · *Scrim:* dim+blur (default) · dim only · none · *Open on:* hover+click (default) · click only.
*Anti-pattern:* never more than ~4 columns; never a panel taller than ~60vh; never open on hover with no close-grace timer (the menu flickers when the pointer crosses the gap). Items must carry a one-line description — a bare link grid is just N1b in disguise.
*Mobile:* collapse the whole thing to a drawer; the columns stack as accordion groups.


<!-- n12-banner-retract.md -->
### N12 · Announcement banner + retracting nav
A coloured promo **banner** stacked above one real nav. On scroll-down the banner slides up and retracts, leaving a single clean nav docked to the top; on scroll-up it slides back. A dismiss × removes the banner for good (its height zeroes so no gap is left). Apple-style coupled bars, but the top tier is a *banner*, not a second nav — the colour contrast is what stops it reading as "two navs".
*Use when:* there's a genuine, time-bound announcement (a launch, a sale, free shipping) worth a persistent strip, over a product/marketing page. Great for stat-led or commerce pages.
*Don't confuse with:* a static announcement bar that never moves (fine, but not N12); N1b (single bar, no banner).

```html
<header class="nav" id="nav">
  <div class="nav__banner" id="banner">
    <p class="nav__banner-text"><span class="nav__banner-spark"></span> New — <b>shared habits</b>. <a class="nav__banner-link">Try it →</a></p>
    <button class="nav__banner-x" id="banner-x" aria-label="Dismiss"><span></span></button>
  </div>
  <div class="nav__bar"><div class="nav__bar-inner">
    <a class="nav__brand">Tally</a>
    <nav class="nav__links">…</nav>
    <a class="btn btn--accent">Start</a>
  </div></div>
</header>
```
```css
:root { --banner-h: 42px; --bar-h: 64px; }
.nav { position: fixed; inset: 0 0 auto; z-index: 500; transform: translateY(0); transition: transform 320ms var(--ease-out); }
.nav.is-compact   { transform: translateY(calc(var(--banner-h) * -1)); }  /* banner hides, bar docks to top */
.nav.is-dismissed { transform: none; }
.nav.is-dismissed .nav__banner { display: none; }
.nav__banner { height: var(--banner-h); display: flex; align-items: center; justify-content: center;
  background: linear-gradient(100deg, var(--color-accent), var(--color-accent-deep)); color: var(--color-paper); }
/* content clears both at rest; zero --banner-h on dismiss so calc() reflows with no gap */
.demo-hero { padding-top: calc(var(--banner-h) + var(--bar-h) + 4rem); }
```
*JS:* track scroll direction — past ~48px going down → `.is-compact`; going up → remove it; near top → always show. Dismiss × sets `--banner-h: 0px` (via `documentElement.style`) and adds `.is-dismissed`.

**Knobs** — *Banner fill:* solid accent · gradient (default) · tint+ink · *Dismiss:* yes (default) · none · *Bar scroll:* sticky (default) · also-frosts · *Banner content:* promo · status · countdown.
*Anti-pattern:* never make the top tier a second set of nav links — that's the "two nav bars" smell the banner exists to avoid. Keep the banner one line, one link, one dismiss. Don't animate banner height directly (janky); translate the whole `.nav` and zero the height only on dismiss.
*Mobile:* banner text truncates / drops the leading glyph; nav links collapse; the Buy/primary CTA stays.


<!-- n13-inline-cmdk-pill.md -->
### N13 · Inline ⌘K search pill
A **visible** search pill sits inline in the bar — placeholder text plus a `⌘K` kbd hint — alongside (not replacing) the links. Click it, or press ⌘K / Ctrl K, to open a spotlight modal with grouped, keyboard-navigable results. The opposite of N4 (which *hides* nav behind the shortcut): here the affordance is on the surface for newcomers, with the shortcut for power users. Tailwind, Linear, Raycast, docs sites.
*Use when:* the product is search-heavy or docs-heavy and search is a primary action (dev tools, music/library apps, large content sites).
*Don't confuse with:* N4 (no visible nav, ⌘K only); a plain search icon that just focuses an input in place.

```html
<header class="nav" id="nav"><div class="nav__inner">
  <a class="nav__brand">Crank</a>
  <button class="searchpill" id="searchpill" aria-label="Search (⌘K)">
    <span class="searchpill__ico"></span><span class="searchpill__text">Search docs…</span>
    <span class="searchpill__kbd"><kbd>⌘</kbd><kbd>K</kbd></span>
  </button>
  <nav class="nav__right"><a class="nav__link">Docs</a><a class="btn btn--accent">Start</a></nav>
</div></header>
<div class="cmdk" id="cmdk" aria-hidden="true">
  <div class="cmdk__backdrop" data-close></div>
  <div class="cmdk__panel" role="dialog" aria-modal="true">
    <div class="cmdk__field"><span class="cmdk__field-ico"></span><input id="cmdk-input" placeholder="Search docs…"><kbd>esc</kbd></div>
    <div class="cmdk__results"><p class="cmdk__group">Suggested</p><button class="cmdk__item is-active">…</button></div>
    <div class="cmdk__foot"><span><kbd>↑</kbd><kbd>↓</kbd> navigate</span><span><kbd>↵</kbd> open</span><span><kbd>esc</kbd> close</span></div>
  </div>
</div>
```
```css
.searchpill { display: flex; align-items: center; gap: 0.6rem; height: 40px; padding: 0 0.55rem 0 0.85rem;
  background: var(--color-paper-2); border: 1px solid var(--color-rule); border-radius: 999px; color: var(--color-muted);
  transition: border-color 200ms, box-shadow 200ms; }
.searchpill:hover { border-color: var(--color-rule-2); box-shadow: 0 4px 16px -10px oklch(0% 0 0 / 0.3); }
.cmdk { position: fixed; inset: 0; z-index: 700; opacity: 0; visibility: hidden; transition: opacity 200ms, visibility 200ms; }
.cmdk.is-open { opacity: 1; visibility: visible; }
.cmdk__panel { position: absolute; top: 14vh; left: 50%; transform: translateX(-50%) translateY(-8px) scale(0.98);
  width: min(560px, calc(100vw - 2rem)); transition: transform 240ms var(--ease-spring); }
.cmdk.is-open .cmdk__panel { transform: translateX(-50%) translateY(0) scale(1); }
```
*JS:* ⌘K / Ctrl K toggles, Esc closes, backdrop-click closes, ↑/↓ move the active item, Enter selects, focus the input on open and lock body scroll.

**Knobs** — *Pill placement:* centred (default) · right-of-brand · *Result groups:* flat · grouped (default) · *Footer hints:* shown (default) · hidden · *Open trigger:* pill+⌘K (default) · ⌘K only (→ that's N4, not N13).
*Anti-pattern:* don't fake the modal with a `<div>` that traps no focus and ignores Esc — if you ship the pill you ship the keyboard model. The pill must look like search (icon + placeholder), not a generic button.
*Mobile:* the pill collapses to a search icon; the modal goes full-height sheet.


<!-- n1b-saas-three-section.md -->
### N1b · Canonical SaaS three-section
Wordmark hard-left · a centred cluster of 4–6 links (some opening hover dropdowns) · a sign-in text link + filled CTA hard-right. The dominant marketing-nav of 2024–26 (Stripe, Linear, Vercel, Figma, Notion, PostHog). The structural opposite of N1's *minimal* two-link variant — this one is dense and balanced.
*Use when:* a SaaS / product / dev-tool page with several real destinations and a clear primary action. The default reach for modern-minimal and (Hum-styled) playful product pages.
*Don't confuse with:* N1a (wordmark + 2 links, no centre cluster); N5 (detached pill); N11 (mega-menu panels, not small dropdowns).

```html
<header class="nav"><div class="nav__inner">
  <a class="nav__brand">Conduit</a>
  <nav class="nav__center">
    <div class="nav__item nav__item--menu">
      <button class="nav__link" aria-expanded="false">Product <span class="nav__caret"></span></button>
      <div class="nav__dropdown"><a class="nav__dropitem"><b>Gateway</b><i>one endpoint</i></a></div>
    </div>
    <a class="nav__link">Docs</a><a class="nav__link">Pricing</a>
  </nav>
  <div class="nav__right"><a class="btn btn--text">Sign in</a><a class="btn btn--accent">Start</a></div>
</div></header>
```
```css
.nav { position: fixed; inset: 0 0 auto; z-index: 500; background: transparent; border-bottom: 1px solid transparent;
  transition: background 240ms, border-color 240ms, box-shadow 240ms; }
.nav.is-scrolled { background: color-mix(in oklch, var(--color-paper) 72%, transparent);
  backdrop-filter: blur(18px) saturate(160%); border-bottom-color: var(--color-rule); box-shadow: 0 8px 28px -18px oklch(0% 0 0 / 0.4); }
.nav__inner { max-width: var(--page-max); margin: 0 auto; padding-inline: var(--page-gutter); height: 64px;
  display: grid; grid-template-columns: 1fr auto 1fr; align-items: center; }
.nav__brand { justify-self: start; } .nav__center { justify-self: center; display: flex; gap: 0.35rem; } .nav__right { justify-self: end; }
.nav__dropdown { position: absolute; opacity: 0; visibility: hidden; transform: translateY(-6px) scale(0.98);
  transition: opacity 200ms, transform 220ms var(--ease-spring), visibility 200ms; }
.nav__item--menu:hover .nav__dropdown, .nav__item--menu:focus-within .nav__dropdown { opacity: 1; visibility: visible; transform: none; }
```

**Knobs** — *Centre links:* 3 · 4 · 5–6 · *Dropdowns:* none · 1 · 2 · *Scroll state:* frost-on-scroll (default) · always-solid · transparent-fixed · *CTA pair:* sign-in + fill · fill only.
*Scroll behaviour (default):* transparent at rest over the hero, frosts (blur backdrop + hairline border + soft shadow) past ~24px, and tightens height ~8px. Always rAF-throttle the scroll handler.
*Anti-pattern:* don't let the centre cluster collide with brand/CTA — if it can't sit centred with breathing room, drop to 3 links or route to N1a. Never ship a dropdown that opens on click only with no hover/focus affordance.
*Mobile:* hide `.nav__center` below ~900px; brand + CTA (or hamburger) remain.


<!-- n2-floating-chip.md -->
### N2 · Floating chip
A small fixed chip in a corner — wordmark + a single action ("Try it"). Doesn't sit in document flow.
*Use when:* the page is fold-heavy and traditional nav would fight the content.
*Don't confuse with:* C4 Sticky bottom bar (which is full-width).

```html
<aside class="nav-chip">
  <a class="wordmark">Studio</a>
  <a class="cta-outline">Try →</a>
</aside>
```
```css
.nav-chip { position: fixed; top: var(--space-md); right: var(--space-md); display: inline-flex; gap: var(--space-md); padding: 0.5rem 0.75rem; background: var(--color-paper); border: 1px solid var(--color-rule); }
```


<!-- n3-side-rail.md -->
### N3 · Side-rail
A thin vertical strip on the left edge — wordmark rotated, plus 2–3 dot-indicators for sections. Editorial / portfolio energy.
*Use when:* the page is long and section-numbered.
*Don't confuse with:* N1 Top wordmark (which is horizontal).

```html
<nav class="nav-rail">
  <p class="wordmark vertical">Studio</p>
  <ul class="dots"><li></li><li></li><li></li></ul>
</nav>
```
```css
.nav-rail { position: fixed; left: 0; top: 0; bottom: 0; width: 3rem; padding: var(--space-md); writing-mode: vertical-rl; }
```


<!-- n4-hidden-behind-k.md -->
### N4 · Hidden behind ⌘K
No visible nav. The user opens a command palette via `⌘K` to get anywhere. Designed for keyboard-first audiences.
*Use when:* the page is for technical users who expect this affordance.
*Don't confuse with:* N2 Floating chip (which is visible always).

```html
<button class="kbd-hint">⌘ K</button>
<dialog class="palette">…</dialog>
```


<!-- n5-floating-pill.md -->
### N5 · Floating pill
A rounded full-pill nav, *visibly detached* from the page edges, sitting ~`var(--space-md)` from the top, soft blur backdrop, soft shadow. Reads as contemporary modern-minimal — Vercel, Linear, Framer, Raycast.
*Use when:* the page is modern-minimal / atmospheric and the hero has a distinct surface or imagery beneath the pill that the blur can sit over.
*Don't confuse with:* N1 Wordmark + 2 links (which is full-width); N2 Floating chip (which is corner-anchored).

```html
<nav class="nav-pill" aria-label="Primary">
  <a class="wordmark">Studio</a>
  <ul class="nav-pill__links"><li><a>Catalog</a></li><li><a>Voice</a></li></ul>
  <a class="cta-fill">Get →</a>
</nav>
```
```css
.nav-pill {
  position: fixed; inset: var(--space-md) auto auto 50%;
  transform: translateX(-50%);
  display: inline-flex; align-items: center; gap: var(--space-md);
  padding: 0.5rem 0.875rem;
  background: color-mix(in oklch, var(--color-paper) 78%, transparent);
  backdrop-filter: blur(14px) saturate(120%);
  border: var(--rule-hair) solid var(--color-rule);
  border-radius: 999px;
  box-shadow: 0 8px 24px -12px oklch(0% 0 0 / 0.18);
  z-index: 20;
}
```

*Anti-pattern:* a "pill" that's ~95 % viewport-wide is just a full-width nav with rounded ends — defeats the point. The pill must be visibly detached and content-sized; if your link list pushes it past ~720 px, drop a link or switch to N1.


<!-- n6-newspaper-masthead.md -->
### N6 · Newspaper masthead
Full-width header, large centred wordmark on the top row, thin issue/date line above or below in serif small caps, optional inline link row beneath, double-rule below the whole thing. Reads as editorial, broadsheet — NYT, FT, Vogue.
*Use when:* the page is editorial, magazine-shaped, or framed as an issue / edition.
*Don't confuse with:* N1 Wordmark + 2 links (which is asymmetric and small).

```html
<header class="nav-mast">
  <p class="mast-line muted">No 22 · Spring 2026 · Studio</p>
  <h1 class="mast-name">STUDIO</h1>
  <nav class="mast-nav" aria-label="Primary">
    <ul><li><a>Catalog</a></li><li><a>Voice</a></li><li><a>Letters</a></li></ul>
  </nav>
  <hr class="mast-rule double" aria-hidden="true">
</header>
```
```css
.nav-mast { display: grid; gap: var(--space-2xs); padding: var(--space-md) var(--page-gutter) 0; text-align: center; }
.mast-name { font-family: var(--font-display); font-size: clamp(2.25rem, 5vw, 3.75rem); letter-spacing: -0.01em; line-height: 0.95; margin: 0; }
.mast-line { font-variant: small-caps; letter-spacing: 0.08em; font-size: var(--text-xs); }
.mast-nav ul { display: inline-flex; gap: var(--space-md); list-style: none; padding: 0; margin: var(--space-2xs) 0 0; }
.mast-rule.double { border: 0; border-top: var(--rule-hair) solid var(--color-rule); border-bottom: var(--rule-hair) solid var(--color-rule); height: 4px; margin: var(--space-sm) 0 0; }
```

*Anti-pattern:* using N6 on a SaaS dashboard or a developer-tool product page. The masthead vocabulary belongs to long-form / editorial sites; on a B2B product, it reads as costume.


<!-- n7-brutal-slab.md -->
### N7 · Brutal slab
A heavy, full-width nav with a 2 px solid border-bottom, all-caps wordmark and tracked uppercase link row, dense rhythm, no shadow, no rounded corners. Reads as Pentagram project pages, Liquid Death, brutalist-leaning agencies.
*Use when:* the genre is playful (Brutal, Manifesto, Sport) or the brand voice is heavy / declarative.
*Don't confuse with:* N1 Wordmark + 2 links (which is small and quiet).

```html
<header class="nav-slab">
  <a class="slab-mark">STUDIO</a>
  <nav class="slab-nav" aria-label="Primary">
    <ul><li><a>CATALOG</a></li><li><a>VOICE</a></li><li><a>WORK</a></li></ul>
  </nav>
  <a class="cta-fill cta-fill--slab">GET</a>
</header>
```
```css
.nav-slab { display: flex; align-items: center; gap: var(--space-md); padding: var(--space-sm) var(--page-gutter); border-bottom: 2px solid var(--color-ink); background: var(--color-paper); }
.slab-mark { font-family: var(--font-display); font-weight: 800; letter-spacing: 0.04em; }
.slab-nav ul { display: flex; gap: var(--space-md); list-style: none; padding: 0; margin: 0 0 0 auto; }
.slab-nav a { text-transform: uppercase; letter-spacing: 0.08em; font-size: var(--text-sm); font-weight: 600; }
```

*Anti-pattern:* combining N7 with rounded corners, soft shadows, or backdrop-blur — those vocabularies fight. If you reach for blur, drop to N5; if you reach for round, drop to N1.


<!-- n8-terminal-command.md -->
### N8 · Terminal command
A nav formatted as a CLI prompt: `> studio --catalog --voice --get▮`. The "links" are command flags. The blinking cursor (`▮`) is allowed *only here* (it has purpose — signals "you'd type next"); never standalone elsewhere on the page. Reads as Vercel CLI docs landing, Charm, Mitchell Hashimoto's site.
*Use when:* the page is a CLI tool, dev-tool docs, or carries the Terminal theme.
*Don't confuse with:* N4 ⌘K-only (which is a palette, not a visible bar).

```html
<header class="nav-term">
  <pre class="nav-term__line"><span class="prompt">&gt;</span> studio <a href="#catalog">--catalog</a> <a href="#voice">--voice</a> <a href="#get">--get</a><span class="caret" aria-hidden="true">▮</span></pre>
</header>
```
```css
.nav-term { padding: var(--space-sm) var(--page-gutter); border-bottom: var(--rule-hair) solid var(--color-rule); }
.nav-term__line { font-family: var(--font-outlier, ui-monospace, "JetBrains Mono", monospace); font-size: var(--text-sm); margin: 0; }
.nav-term__line .prompt { color: var(--color-accent); padding-right: 0.4ch; }
.nav-term__line a { color: var(--color-ink); text-decoration: underline; text-underline-offset: 2px; }
.caret { display: inline-block; width: 1ch; animation: blink 1.05s steps(2) infinite; color: var(--color-accent); }
@keyframes blink { 50% { opacity: 0; } }
@media (prefers-reduced-motion: reduce) { .caret { animation: none; opacity: 1; } }
```

*Anti-pattern:* using `>` prompt vocabulary on a non-developer site (a wedding photographer's portfolio with a `> view --gallery` nav reads as set decoration). N8 belongs to genuine terminal / CLI brands only.


<!-- n9-edge-aligned-minimal.md -->
### N9 · Edge-aligned minimal
Wordmark hard-left, single CTA hard-right, vast empty space between, no link row at all. The *absence* is the design — Apple product pages, Carl Hauser, luxury sites.
*Use when:* the page is luxury / quiet / Atelier / Garden and the brand earns the silence.
*Don't confuse with:* N1 Wordmark + 2 links (which fills the middle).

```html
<header class="nav-edge">
  <a class="wordmark">Studio</a>
  <a class="cta-outline">Get →</a>
</header>
```
```css
.nav-edge { display: flex; justify-content: space-between; align-items: center; padding: var(--space-md) var(--page-gutter); }
.nav-edge .wordmark { font-family: var(--font-display); font-size: var(--text-md); }
```

*Anti-pattern:* adding 4 inline links between the wordmark and CTA "to fill the space". The space *is* the design; if you fill it, you've made N1 with extra steps.


<!-- s1-left-margin-numbered.md -->

### S1 · Left-margin numbered
A narrow left column holds `01 — LABEL.`; the wide right column holds the heading and content.
*Use when:* the page is editorial / specimen.
*Don't confuse with:* S5 Bottom-anchored (which puts the label *under* the section).

```html
<header class="head-margin">
  <p class="num-label">01 — Foundations</p>
  <h2>…</h2>
</header>
```
```css
.head-margin { display: grid; grid-template-columns: 10rem 1fr; gap: var(--space-xl); align-items: baseline; }
```


<!-- s2-hanging.md -->
### S2 · Hanging
Heading floats above the section in negative space; no border, no rule.
*Use when:* the content has a quiet, room-to-breathe energy.
*Don't confuse with:* S3 Sticky-pinned (which moves with scroll).

```html
<header class="head-hang">
  <h2>…</h2>
</header>
```
```css
.head-hang { padding-block: var(--space-3xl) var(--space-xl); }
```


<!-- s3-sticky-pinned.md -->
### S3 · Sticky pinned
Heading remains in viewport while content scrolls beneath. Orientation aid.
*Use when:* the section is dense and the user benefits from always seeing where they are.
*Don't confuse with:* S1 Left-margin (which doesn't move).

```html
<header class="head-sticky">
  <p class="num-label">02</p>
  <h2>…</h2>
</header>
```
```css
/* If the page has a sticky top nav, offset by its height so the sticky
   head docks BENEATH it instead of bleeding over (slop-test gate 56).
   Use --z-sticky (in-page) so the nav's --z-sticky-nav out-paints it. */
.head-sticky { position: sticky; top: var(--banner-height, 0px); background: var(--color-paper); padding-block: var(--space-sm); border-bottom: 1px solid var(--color-ink); z-index: var(--z-sticky); }
```

**Sticky pairing rule:** if the page emits a sticky `<header>` / `<nav>` / `.banner` (anything with `position: sticky; top: 0`), you MUST also declare `--banner-height` (a px value matching the nav's height) and `--z-sticky-nav` (≥ 1 above `--z-sticky`) in `tokens.css`. The S3 recipe above pulls both. Without those tokens the section head paints over the nav during scroll — see slop-test gate 56.


<!-- s4-inline-no-break.md -->
### S4 · Inline (no break)
The heading is a small caps phrase that emerges *inside* the body flow; no spatial break.
*Use when:* the page is prose-led; reading should be continuous.
*Don't confuse with:* S2 Hanging (which separates with negative space).

```html
<p>… <span class="head-inline">A small heading.</span> …</p>
```
```css
.head-inline { font-variant-caps: all-small-caps; letter-spacing: 0.06em; font-weight: 500; }
```


<!-- s5-bottom-anchored.md -->
### S5 · Bottom-anchored
The label or heading sits *below* the section's content. Inverts hierarchy.
*Use when:* the content is the primary act and the label is a footer to it.
*Don't confuse with:* S1 Left-margin (which leads with the label).

```html
<section>
  <div class="content">…</div>
  <p class="num-label">— end of 02</p>
</section>
```

---


<!-- t1-pull-quote-with-marginalia.md -->

### T1 · Pull-quote with marginalia
A quote sits in the wide column; the attribution and source link float in the narrow margin column.
*Use when:* the page already has a marginalia rhythm (Tufte-leaning, editorial).
*Don't confuse with:* T3 Single huge quote (which is centered and dominates).

```html
<aside class="proof-margin">
  <blockquote class="serif-italic">"…"</blockquote>
  <p class="attribution muted">— Name<br />Role, Company</p>
</aside>
```


<!-- t2-logo-wall-hairline.md -->
### T2 · Logo wall (hairline)
A row of customer logos, monochromatic, separated by hairline rules. No card boxes, no shadows.
*Use when:* you have recognisable customers and want to surface them quietly.
*Don't confuse with:* the AI-default 6-logo box grid; this version refuses card boxes.

```html
<section class="logo-wall">
  <ul>
    <li><img src="" /></li>
    <li><img src="" /></li>
    <li><img src="" /></li>
  </ul>
</section>
```
```css
.logo-wall ul { display: grid; grid-template-columns: repeat(auto-fit, minmax(8rem, 1fr)); gap: 0; }
.logo-wall li { padding: var(--space-md); border-right: 1px solid var(--color-rule); display: grid; place-items: center; }
.logo-wall img { filter: grayscale(1); opacity: 0.7; }
```


<!-- t3-single-huge-quote.md -->
### T3 · Single huge quote
One quote, set big, centered, taking a whole section. No supporting text, no attribution boxes — attribution is a small caps line beneath.
*Use when:* one quote is so good it earns the room.
*Don't confuse with:* T1 Margin pull-quote (which is the *side* mate, not the *room*).

```html
<section class="proof-room">
  <blockquote class="display-italic">"…"</blockquote>
  <p class="attribution"><span class="caps">— Name, Company</span></p>
</section>
```


<!-- t4-numbered-stat-strip.md -->
### T4 · Numbered stat strip
A horizontal strip of 3–5 stats (count + qualifier) running across one row. Tabular nums.
*Use when:* you have multiple complementary metrics that work together.
*Don't confuse with:* H4 Stat-led hero (which is one focal number, not several).

```html
<section class="stat-strip tnum">
  <div><b>2.4M</b><span>users</span></div>
  <div><b>99.97%</b><span>uptime</span></div>
  <div><b>14</b><span>regions</span></div>
</section>
```

---
