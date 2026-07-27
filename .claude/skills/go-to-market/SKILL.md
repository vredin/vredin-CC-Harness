---
name: go-to-market
description: Writes the customer-facing go-to-market communication for one chosen segment — publish-ready landing copy, ad and creative copy built on Job-language formulas, and a growth plan (channel hypotheses, lead magnets, viral loops, plus cross-sell, upsell and retention messaging). Takes any of these inputs, best to most manual: a /value-prop result, a /product-requirements PRD, a /market-research result, or a plain-English description of the segment and its Jobs. Speaks through the bigger outcome the customer is after (the Aspiration Job), states value as concrete success criteria rather than adjectives, and uses features only as proof. Two modes — Quick (default, offline) and Deep (subagents plus web). Plain language, English by default.
user-invocable: true
---

# Craft Go-To-Market communication

You have a segment, a value hypothesis, and (usually) a build. This skill turns that into the words a customer actually reads — the landing page, the ads, and the growth plan that brings those customers in.

**Where you probably are in the chain.** This is the last station. If you are somewhere else, hop to the sibling that fits:

- **A brand-new idea, no segment yet** → `/market-research`
- **A live product and a metric that moved (the wrong way)** → `/diagnose`
- **A pile of customer interviews to make sense of** → `/analyze-interviews`
- **A validated value prop, ready to build** → `/product-requirements`
- **Positioning and launch copy** → `/value-prop`, then `/go-to-market`

**In one breath.** This skill takes value you have already built and dresses it in language that pulls customers toward you. It never invents the segment, never invents the value, never re-specs the build. Everything it says is routed through the larger result the customer wants — the Aspiration Job, because that is where motivation actually lives — and it states that result as measurable success criteria, with features showing up only as evidence. Copy carries value; it cannot manufacture value. If the value underneath is still a guess, this skill says so plainly and gives you demand-test copy only — words designed to find out whether anyone wants it, not words that pretend it already works.

**Producer contract.** This skill follows `../PRODUCER-CONTRACT.md`. Six behaviours cut across the whole run:

1. Print a helicopter-view of the run before asking the first question.
2. Ask whether you want the output as Markdown or HTML.
3. Treat every input as a hypothesis, never a fact, and surface a "risks in what you gave me" block.
4. Print the validation debt and frame everything as "test this messaging," never "this will work." Go-to-market has no GO verdict to give — it inherits the validation debt of the value it is selling.
5. Accept a custom output path.
6. In Deep mode, enforce an evidence floor, run a self-critic loop, and offer a web-research fallback.

---

## Where this skill sits in the chain

```
/market-research      →   /value-prop        →   /product-requirements   →   /go-to-market
(segment + Jobs)          (value hypothesis)     (build spec)                (THIS — copy that sells the value)
```

A plain-English description of your product, customer and offer is a **first-class input here**, not a last resort. When an upstream artifact exists, use it — and each carries something different:

- **A `/value-prop` result** is the richest. It already holds a positioning headline, the dominant success criteria, the Aha Moment, the differentiation angle, and the proof.
- **A `/product-requirements` PRD** brings the actual functionality, the step-by-step route the customer travels (the Delivery Chain), and the point inside it where the Aha Moment lands.
- **A `/market-research` result** carries the segment, the Aspiration and Core Jobs, the competitive field, and the underserved angle.

Whatever the input, this skill **packages**. It does not re-derive segments, re-invent value, or re-write the build spec. It translates what is already decided into customer-facing language.

---

## What this skill produces

**One file.** A go-to-market communication pack, laid out at three linked depths of reading: a founder's skim, a marketer's "why is the copy shaped this way," and a methodology audit. Because the copy itself is the deliverable, it stays plain and shippable and never gets buried under reasoning — every methodology citation is pulled out of the copy and parked elsewhere.

**Layer 1 — "GTM in one breath"** (about a page, zero methodology words, safe to forward). The one-liner; the single message everything routes through; who it is for; the first channel to try; the one thing to test before you scale. Each line that someone might doubt drills down to its reasoning.

**Layer 2 — "The Plan and why it is shaped this way"** (one to two pages, plain English, each term glossed once). Why this is the message (what the buyer has to believe); the landing-page logic; the ad angles worth testing; a channel-plan summary; what to test first. Each point links down to the asset it describes.

**Layer 3 — "The Full Pack"** (the substance — only the assets you ordered):

- **Part 1 — Landing copy.** Full, publish-ready, no placeholders.
- **Part 2 — Ad and creative copy.** Seven ad angles, each one a Job-language formula carrying its own batch of test variants; a visuals brief depicting the destination you want the customer to picture (State B); and the single line you repeat across every surface.
- **Part 3 — GTM / growth plan.** A set of channel ideas, each carrying the Choice Activators; lead magnets that intercept the customer at whatever they do immediately before your product (the Previous Job); content and referral loops; plus messaging for cross-sell toward the Next Job, upsell toward the Aspiration Job, and retention (a steady drip of Aha Moments, the right rhythm, and riding routines the customer already keeps).
- **Appendix — the job each asset performs.** For every asset, which one of the five Choice Activators it carries, and the behaviour-change force it leans on.

**Two modes.** *Quick* (default, roughly 10–15 minutes, one model, no internet) writes from the loaded artifacts and reasoning. *Deep* (opt-in, longer) sends out subagents to mine the words real customers use in reviews and to ground the competitor-firing in real, documented Problems.

---

## Methodology — the source of truth

Everything this skill knows about methodology is drawn from the method's canon at run time. Never pull all of it in at once. Load the eager core before you write, and reach for an individual staged file only when the run lands on the stage that calls for it. What this skill draws on is the public-canon set; the per-task algorithms held behind a paywall are unnecessary here, since whatever they say about communication has already been merged into these public files. Do not read or quote any canon outside the sets named below.

### Eager core — read every run, before writing any copy

| File | What it powers | ~tokens |
|---|---|---|
| `product-method/canon/jobs/communication.md` | The spine of the pack: communication transmits validated value (§1); the seven purchase assumptions (§2); the three base messages — value in criteria not adjectives (§3); features-are-proof (§4); the one-liner (§5); the seven creative formulas — visuals show State B (§6); landing as a short Delivery Chain (§8, the canonical landing sequence plus the conversion diagnostic); expectation management (§9). | ~9k |
| `product-method/canon/jobs/choice-activators.md` | The five Choice Activators components; where they come from; specific stories; Class 1 vs Class 2 — used across every asset. | ~5k |

### Staged — load only when the run reaches the stage

| File | Load when | Used by | ~tokens |
|---|---|---|---|
| `product-method/canon/jobs/behaviour-change.md` | Channels / triggers stage | Part 3a — framing through the Aspiration Job (§4); the seven triggers that open a receptivity window (§8); the forces in play (§9); how Class 1 differs from Class 2 (§10) | ~7k |
| `product-method/canon/jobs/attention.md` | Landing's taste-of-Aha and the acquisition stage | Across Part 1's sixth block and into Part 3a — the funnel read as a series of attention hand-offs, with that first Aha shifted as early in the path as you can manage (§6); traversing the Delivery Chain (§7–8); using the Move-to-Previous-Job as a form of upstream acquisition (§9) | ~6k |
| `product-method/canon/jobs/choice-activators.md` (deep) + `product-method/canon/jobs/barrier-removal.md` | Fear-reduction / competitor-firing stage | Part 1's seventh and eighth blocks — genuine Barriers set against fears (§1, §3); keeping fears about the Job distinct from fears about our Solution | ~4k |
| `product-method/canon/jobs/job-types.md` | Lead-magnet / content / viral-loop stage | Part 3a — the Viral and Orientation Jobs that sit under content marketing, lead magnets, content loops, and viral loops | ~5k |
| `product-method/canon/jobs/delivery-chain.md` | Cross-sell / Next-Job stage | Part 3a/3b/3c — the Previous Job and the Next Job, plus the chain moves under acquisition, cross-sell, and retention | ~6k |
| `product-method/canon/jobs/b2b.md` | Pulled in only for a B2B input | Part 3a's deal room — both peer and institutional channels (§4); messaging aimed at the personal Job (§5–6); the deal room as such (§3) | ~5k |
| `product-method/canon/jobs/value-creation.md` | Upsell / Aha-stream stage | Part 3b/3c — the value formula that underlies the criteria claims (§3, §9); climbing a level to drive the upsell (§14); the Red Queen value-gap underneath the Aha-stream (§6); how to communicate deferred value (§19) | ~8k |
| `product-method/canon/jobs/job-structure.md` | If the headline needs fidelity levels | The headline is a Level-3 minimal Job (§15) | ~5k |

**Per-mode loading.** Under **Quick** mode, load the eager core, then bring in a staged file the moment its stage comes up. Under **Deep** mode, every writer agent sees only its own slice: Landing → core + attention + barrier-removal; Ads → core; GTM → core + behaviour-change + job-types + delivery-chain + b2b-if-B2B + value-creation. Nothing outside the slice gets loaded.

**Do not use generic JTBD from the internet or your training.** The method's Jobs framing is more precise than the popular version, and these five mis-defaults must never leak into the work:

- A **Job** is a wanted transition — going from State A toward the outcome you expect — rather than "a struggle for progress."
- **Value** is how efficiently energy is spent measured against what the brain forecast, not a vague sense of "benefit."
- The **Aha Moment** is the moment delivered value runs ahead of that forecast. Never label it a positive or negative prediction error anywhere a reader can see.
- The lead element of a Job (which has eight) is "**I want to** + verb," and since every verb is its own Job, two verbs must never be folded together.
- A **Problem** is the downstream result of a Solution that underperforms, not a cause sitting at the root.
- A **Solution** is two things at once: an actual object, and a tag for the Job Map it installs in the customer's mind.

### Methodological invariants (the copy is invalid if it breaks one)

- **Communicate through the Aspiration Job.** The motivation lives a step above the Core Job. *Exception (Class 1):* if the segment is already fluent in the Core Job, open on that Core Job and its criteria and let the Aspiration Job back it up. If the Core Job is new to them (Class 2), open on the Aspiration Job and then fill in the Core Job behind it.
- **State value as concrete success criteria, never adjectives.** Push every vague word through "as in?" until it lands on a measurable bar. *Example:* "a smoother handoff to the client" fails the test. "As in?" → "the client signs without a single revision round, because the scope was locked up front." That is the version that ships.
- **Features are proof, not the message.** A feature becomes communicable only after it is attached to a Job and a criterion. Lead with the Job, the value, and the fear you remove — then the feature shows up as evidence.
- **Never promise an Aspiration Job the product only half-delivers.** Over-promising inflates the prediction and manufactures a Problem at the worst possible moment — right after purchase. The promise has to match what the Delivery Chain actually delivers.
- **Load all five Choice Activators components:** a new Job Map exists; the value delta stated by criteria; the named product and an entry path; the specific fears reduced; the competing Job Map fired.
- **Communication transmits validated value.** If the value is unproven — no sales yet, no Aha yet — flag it. Do not scale copy on a hypothesis.
- **Specific stories beat abstractions, and visuals show State B,** the after, not the process of getting there.

### Cross-cutting output rules

Every named external source is a clickable Markdown link. A two-part disclaimer sits at the top of the result. Use US-context analogs and a recognition test — only reach for a brand name the reader will instantly know, and if it is not obviously known, add a one-clause bridge.

---

## Plain-language output rule

Your reader is a product person, not a methodologist. Write the plan, the rationale, and the annotations in the everyday language of the segment. When a methodology term genuinely sharpens the point, lead with the plain meaning and drop the term in parentheses on first use. Never open a sentence, bullet, or heading with a methodology label.

*Before (jargon-first):* "The Aspiration Job here is being seen as a pro who never drops the ball, so the headline routes through it." *After (plain-led):* "What this buyer is really chasing is being the freelancer who never gets caught scrambling (their Aspiration Job) — so the headline speaks to that, not to the template gallery."

**Who reads this.** US-based founders, indie hackers and vibe-coders, PMs at growth-stage companies, senior PMs and VPs, and product marketers. Words that feel native to them: finding fit, watching the burn, extending runway, a disciplined pivot, a paying niche, getting it out the door instead of buffing it, closing the first paying logos, a defensible roadmap, a number that truly moves instead of vanity stats, crisp positioning, durable conversion. Phrases that make them cringe: "scale fast," "10x your growth," "hockey-stick curve," "battle-tested framework," "growth hacks," "funnel hacks," "5 hacks to…" — along with any line that opens on jargon.

**Plain ↔ methodology mapping** (open with the everyday phrase on the left; only fold in the term on the right, in parentheses, when it actually adds something):

- the result they are after → *the Job / Aspiration Job*
- the largest task the product handles start-to-finish by itself and still can't be topped at → *Core Job*
- the route, step by step, that the customer travels → *Delivery Chain*
- the precise spot where they stall → *a Delivery Chain break*
- the instant it lands and beats their expectation → *Aha Moment*
- the let-down when a tool comes in under what they expected → *a problem*
- arriving at the outcome at a lower cost in time, effort, money or stress than they braced for → *value*
- the short list of things they have to grasp or accept before making the switch → *Choice Activators*
- a true blocker as opposed to a mere worry → *Barrier vs fear*
- the assumption most able to sink this, tested on the cheap first → *riskiest assumption / RAT*

Never write "Positive Prediction Error" or "Negative Prediction Error" in anything the user reads. Say "Aha Moment" or "problem."

Job-grammar discipline still governs the internal reasoning, any debug notes, and the methodology appendix (Jobs as "I want to + verb," levels named, terms capitalized). The lead the user sees stays plain. Link `references/glossary.md` once at the top of the pack, right after the disclaimers.

---

## Readability rules

A single file carries three reading depths, threaded together top to bottom. Layer 1 serves a founder skimming fast. In Layer 2 a marketer picks up why the copy is built the way it is. The methodology audit lives further down, in Layer 3.

- **Three escalating layers.** Let any one conclusion show up a single time per layer and not twice at the same depth: L1 as a headline, L2 as a plain sentence, L3 as the full asset.
- **Drill-down links are mandatory.** Every doubtable L1 line carries a `▸` link to its L2 anchor; every L2 claim links down to its L3 part. Use Markdown anchors: a link like `[label ▸](#l2-message)` and an `<a id="l2-message"></a>` placed above the target. The L3 parts carry the anchors `l3-landing`, `l3-ads`, `l3-channels`, and `l3-dealroom`.
- **L1** uses minimal jargon. Plain words lead; a term appears only in parentheses as a gloss, never opening a line.
- **L2** is plain first, with each term glossed in three to five words in parentheses on first use. Nested glosses are fine. The glossary is linked once at the top. Gloss the sneaky terms (State A/B, Previous/Next/Orientation/Viral Job) once, or do not use them.
- **L3 landing and ad copy are already plain — keep them clean and shippable.** Do not abstract, gloss, or wrap them. The copy is the deliverable. But every claim and every number in shippable copy keeps a `[VERIFY — source]` guardrail until it is proven, because a reader may ship it straight to production.
- **Citation fencing** (the important fix). Strip every inline canon citation out of the copy *and* the prose around it. Landing blocks and ad lines read as clean, shippable copy with no citations inside. Where a canon reference matters to the marketer, move it into a small, fenced "▸ methodology trace" line at the *end* of the part, styled out of the reading flow (think a small or subscript line set apart from the copy). Never break a copy line — or any pack sentence — with an inline citation. Project rule numbers never appear in any layer.
- **Disclaimers once, answer first.** Up top, and only there, sits the two-part disclaimer, stated a single time. The validation flag goes *under* the L1 answer, held to two lines; a one-line pointer within L1 does the job; never repeat the block in L3. Across the whole file the disclaimer wording should turn up twice at most.
- **Keep source links** for external facts and proof.

**Enforcement gate** (check each before writing the file; the full version lives in `../READABILITY-CONTRACT.md`):

- **Unique resolving anchors** — every `▸` target is a unique `<a id>` that exists exactly once; no shared targets. List them and confirm before shipping.
- **`[VERIFY]` survives into the copy** — every number and claim in the landing and ad copy keeps its inline `[VERIFY — source]` until proven.
- **Validation flag below the answer,** two lines or fewer.

---

## Output file

This skill writes **exactly one file**. By default it lands under the product folder in the project root (never in a temp folder or `.claude/`), following the path convention:

```
method-results/{product-slug}/go-to-market/{YYYY-MM-DD_HH-MM}_{product-slug}-go-to-market-result.{md|html}
```

The extension follows the format you pick: `.md` as the default, or a single standalone `.html` — styles embedded, on-page anchors that fire for both the section jumps and each `▸` link, fold-out sections for L3 and the methodology traces, and source links set to open in a fresh tab. The HTML carries the same content; the copy stays plain and ready to ship with `[VERIFY — source]` untouched. Never emit both — one file to a run.

If the user names a path of their own, drop that one file there under the identical filename pattern.

Anything that stays behind the scenes — the normalized input, the variants you cut, the notes from review mining, the self-critic's verdicts — rides along in context and never gets spilled out into its own file. Since each run carries a unique timestamp, re-running it won't overwrite an earlier file. The disclaimers sit at the top of that single file.

---

## S0 — Intake and route

**Orientation (helicopter view).** Print this before the first question, in plain words, in the user's language:

- **What you'll get:** one pack — landing copy, ad and creative copy, and a GTM/growth plan covering channels, lead magnets, viral loops, and cross-sell/upsell/retention.
- **The steps:** (1) a handful of questions and a pass over any upstream artifact, (2) landing copy, (3) ad and creative copy, (4) the channel and growth plan, (5) a single pack stacked at three reading depths.
- **My part vs your part:** I supply the copy and the channel hypotheses. What ships, and the live validation that goes with it — A/B tests, actual spend, actual conversions — that part is yours. All I can do is flag which thing earns the first test.
- **Two modes:** Quick (offline, ~10–15 minutes, reasoning only) or Deep (opt-in subagents that mine real review language and ground the competitor-firing, longer, best on a top model with a web MCP).
- **Honest caveat:** this packages value into copy. It does not prove the value, the message, or the channel. Better copy on top of unvalidated value only gets you to disappointment faster. All of it is hypothesis until you test it.

**Intake depth — ask this FIRST, separately from the Quick/Deep mode choice.** It sets how many intake questions you ask:

- **"Just the essentials"** — 3–4 key questions, a fast first pass.
- **"The full interview"** — covers most blind spots, highest confidence, worth it for an expensive decision.

On **Essentials**, ask only three things: the input-route question, which assets the user wants, and the one or two unknowns that hold up the copy (who the customer is · the outcome they get · what tool they lean on now and where that tool falls short). Everything else you infer or postpone, flagging anything inferred at the top of the result. On **Full**, run the complete intake: the claims ledger, the hand-off debt, the materials sweep, and the full normalize.

**Language.** Default to English. If the user writes in another language, offer it and hold the choice; the copy is written in the chosen language; canon files and source URLs stay as they are.

**One batched question set** (AskUserQuestion):

- **Q1 — input route** (four options): describe the product and customer in plain English → **Path D** (standalone, first-class); a `/value-prop` result → **Path A** (richest); a `/product-requirements` PRD → **Path B**; a `/market-research` result → **Path C**.
- **Q2 — mode:** Quick (default, offline) / Deep (subagents + web: real review language plus competitor firing).
- **Q3 (Paths A/B/C):** the path to the result or PRD file → free text; then Read it.
- **Q4 — which GTM assets** (multi-select): Landing copy / Ad and creative copy / GTM growth-communication plan / All.
- **Q5 — output format:** Markdown (default) / HTML (collapsible, in-page nav, links stay clickable).
- **Q6 — where to save:** the default `method-results/{project}/go-to-market/…` or a custom folder path; one file per run either way.

**Normalize the input** (held in context — extract what is there, ask only for what is genuinely missing):

- **Target segment + causal criteria** (behaviour or characteristic, not demographics).
- **Aspiration Job(s) + success criteria** (the motivation surface). For B2B, the personal Aspiration Job too.
- **Core Jobs + dominant success criteria** (with direction and level). **Which class — 1 or 2?** — is the Core Job something the segment already recognizes? The answer sets whether the copy opens on the Aspiration Job or on the Core Job.
- **The Aha Moment** (for the landing taste block and the activation/retention angle).
- **The competitive set** — direct (Core Job), indirect (Aspiration Job), and turnkey — with what each one closes poorly (the wedge you fire on).
- **Current-Solution Problems and specific fears** (for fear reduction and competitor firing).
- **Proof** — cases, guarantees, logos, comparable results, each with a source link.
- **Validation status** — is the value proven by sales or usage, or still a hypothesis? This gates scale-the-copy vs demand-test-the-copy.

**Path D specifically:** take the plain-English write-up and do the methodology shaping behind the scenes — never make the user produce formal Job grammar. Gather it in plain terms (who · the outcome they get · what tool they lean on now and where it falls short · proof), then check it against the invariants (split bundled verbs, convert demographics into behaviour, drive adjective-value down to measurable bars) before you write. Flag at the top of the result that this run rests on a description and not on a validated artifact.

**User materials, claims ledger, hand-off debt, and direction confirmation** (across all paths):

- **Materials:** make a one-time request for any files or folders (a Notion export, earlier research, interview notes, current copy, the live site). Read them and label whatever they hold `[user data]`. Treat existing copy as source material to rework — get a confirm before you carry any line over word-for-word.
- **Input-as-hypothesis gate:** treat every input — an upstream artifact, a deck, a landing page, a free-text assertion, "our customers say X" — as a hypothesis, not a fact. Go looking, deliberately, for the risks buried in each load-bearing input: is it backed by customers or just team conviction? Is it a genuine Job or the team's projection (the most expensive mistake of the lot)? Any internal contradictions, or guesses passed off as data? Keep what you find; it feeds the L2 "What you gave me — and the risks in it" block, with the sharpest items raised up into L1. GTM copy is the most public thing you ship — assured copy on top of unvalidated value mints a Problem at scale. No copy claim leans on unvalidated input unless it carries a `[VERIFY — source]` tag and shows up in the validation flag.
- **User-claims ledger:** label every strong factual claim as data, observation, or hunch. Any copy claim built on an unverified hunch gets flagged — a hard number or a comparison must trace back to data or ship as a to-verify placeholder, and is never made up.
- **Hand-off debt:** as you take on an upstream artifact — that is, on any of Paths A, B or C — ask which slices of that artifact's validation debt have since been confirmed in the field (sales, interviews, fake-door tests). Re-label what stays unvalidated and pass it forward. Where the value prop never got validated, the landing copy takes on that debt — call it out in the validation flag.
- **Direction confirmation:** before S1, replay your understanding in one short block (the segment, the value being communicated, the validation status and what is still unvalidated from the hand-off, which assets) and confirm via one AskUserQuestion (Confirm / Correct).

---

## S1 — Write the GTM communication pack

**Build order.** Write Layer 3 (the full pack) **first**, working through the parts in order — each part pulls from one shared Job record, which keeps the one-liner and the Aspiration Job aligned. **Then** work out Layer 2. **Then** Layer 1 **last**, threading the drill-down links into the L3 anchors. Write the file in its final order: top disclaimers (once) → glossary link → "How to read this" (the three levels plus jump links) → L1 → L2 → L3. Quick mode does this in one pass; Deep mode parallelizes the L3 parts.

**The file opens** with an H1 "Go-To-Market Communication — {product/segment}", a `disclaimers` anchor, and the two-part disclaimer:

- **Numerical:** every numeric estimate here is an LLM hypothesis with a verification path — validate before you decide on it.
- **Hallucination:** this is LLM-generated and may hallucinate. Run real research before any expensive decision.

Then a one-line glossary pointer.

**"How to read this"** is emitted once, after the disclaimers and glossary, before L1. Plain words, three bullets:

- **Level 1** — the one-breath version, about a page (jump link).
- **Level 2** — the plan plus why it is shaped this way (jump link).
- **Level 3** — the full pack (jump link).

### Layer 1 — GTM in one breath (computed LAST)

Minimal jargon, plain words lead, safe to forward. Each doubtable line drills down to its own unique L2 anchor.

- `layer-1` anchor + heading + a one-line "forward this" note linking to the disclaimer.
- **The one-liner** — a single sentence: what it is, what it does, the value in plain words.
- **The one message everything routes through** — the single thing the buyer must believe (link to L2 message).
- **Who it's for** — the segment in one plain sentence (link to L2 buyer).
- **The channel to try first** — one channel plus the moment to catch them (link to L2 channels).
- **The one thing to test before scaling** — the single make-or-break (link to L2 test).

**Validation-debt line:** state that the pack stands on **N** unvalidated assumptions, **M** of them fatal (the value is real, the message lands, the top channel actually reaches them); the fatal ones get tested first; link to the L2 input risks. Add a small sub-note defining **N** (the assumptions the copy rests on: the value claim, the message, each channel and lead-magnet hypothesis, plus anything inherited unvalidated from upstream) and **M** (the ones that kill it if they are wrong).

**Validation flag** (two lines or fewer, sitting *below* the answer, not above it): this pack has no GO or build verdict — it always reads "test this messaging/channel," never "this will work." If the value is validated by sales or usage, these are scale-ready creatives. If the value is still a hypothesis (including debt inherited from an unvalidated upstream artifact), these are demand-test creatives. On Path D, flag reduced confidence; otherwise name the source artifact and its still-open debt.

### Layer 2 — The Plan and why (computed after L3, before L1)

Plain English, one gloss per term, no big copy blocks. Each subsection carries the `<a id>` that L1 links to and links down to its L3 part.

- `layer-2` anchor + heading + a plain-reasoning note.
- <a id="l2-input-risks"></a>**`l2-input-risks` — "What you gave me — and the risks in it."** Note that everything provided was treated as a hypothesis, that the copy is the most public thing you produce, and that over-promising creates disappointment at scale. Omit this block only if the user gave no claims or materials. Render a table:

  | What you provided/claimed (tagged data / observation / hunch) | How I treated it (hypothesis, where used) | The risk I see | How to check it fast (cheapest falsifying test) |
  |---|---|---|---|

  Then, if the message, the headline, or the validation flag rests mostly on unvalidated input, add one bold sentence tying it to the matching `[VERIFY — source]` tag.
- <a id="l2-message"></a>**`l2-message` — Why this is the message.** What the buyer has to believe before they switch (the bigger result they are genuinely chasing = the Aspiration Job; the short set of things they have to accept or learn = the Choice Activators); why you open here rather than on features; link to the L3 appendix CA map.
- <a id="l2-buyer"></a>**`l2-buyer` — Who it's for, and whether the value is proven yet** (validated by sales/usage → scale; still a hypothesis → demand-test).
- **The landing logic in plain terms** — why the page is ordered the way it is: recognize the situation → show value in concrete terms → prove it → handle fears → take a first small step. Link to L3 landing.
- **The ad angles to test** — the handful worth testing first and why. Link to L3 ads.
- <a id="l2-channels"></a>**`l2-channels` — The channel plan.** The top channels, the moment to reach the buyer, and the lead-magnet, content and referral moves. Link to L3 channels.
- <a id="l2-test"></a>**`l2-test` — What to test first.** The single cheapest, highest-leverage thing to prove before you scale.

### Layer 3 — The Full Pack

`layer-3` anchor + heading. All canon citations are fenced into "▸ methodology trace" lines at the end of each part — never inline.

#### Part 0 — The one-liner (used everywhere)

Formula: **[what it is] + [the Core Job(s) it performs] + [the value by criteria]**. One sentence in the customer's plain words. The test: a stranger can repeat back what it is, the Core Job, and the value.

*Fresh example (illustration only — do not copy):* "It's a proposal builder for freelance designers that turns a rough scope into a signed contract in one sitting instead of three rounds of email, with no unpaid revision creep."

#### Part 1 — Landing copy

<a id="l3-landing"></a>

A landing page guides each visitor through a short run of steps they have to clear (a compact Delivery Chain), ending with enough conviction and enough drive to take that first step. Write every block as finished, shippable copy with nothing cited inside. The ten blocks:

1. **Hero** — the one-liner plus a subtitle of one or two sentences; spell out the Aspiration Job this page speaks to (matching the PRD or value-prop); the CTA copy and what the click delivers.
2. **Focus Jobs** — the Core Jobs paired with the Aspiration Job they feed.
3. **Context and trigger** — the visitor should react with "this is exactly me" (the segment's lived situation paired with the Trigger).
4. **Value by concrete criteria** — the degree to which the Jobs are done with less energy; put in numbers and thresholds, never in adjectives.
5. **How it works** — the steps serving as the proof layer (features bound to Jobs and criteria), and not as the lead message.
6. **A taste of it working** — hand over a sliver of genuine value on the page itself (the Aha Moment, pulled as early as you can manage).
7. **What's wrong with the current way** — why their present approach keeps letting them down (this is what fires the competing option).
8. **Fear reduction** — name each specific "what if…" worry, then show how it is prevented, absorbed, reversible, insured, or made irrelevant; hold true blockers apart from mere worries, and keep task-level worries separate from worries about the product itself.
9. **The after** — the look and feel of their world once that larger outcome is theirs (State B plus the feeling).
10. **The first step + CTA** — name the product and give one concrete, low-effort first step (these are the Choice Activators); keep a CTA on every screen.

End-of-part fenced lines:

- *"Diagnostic, not decoration"* — when motivated traffic still fails to convert, isolate which transition broke: the context wasn't recognized / the value never turned concrete / the proof didn't connect / a real blocker stayed in place / a fear was left running / the competing option went unfired / the CTA asked for too much before the first Aha.
- *▸ methodology trace* (a small subscript line) citing the relevant canon: the landing sequence as a short Delivery Chain whose State B is enough belief; value-in-criteria; features-as-proof; the taste-of-Aha as far left as possible; Problems and fear-reduction firing the competing Job Map and loading Choice Activators components 4–5 — `communication.md`, `attention.md`, `choice-activators.md`, `barrier-removal.md`.

#### Part 2 — Ad and creative copy

<a id="l3-ads"></a>

Each ad angle is one evidence-picked way to package the message (a Job-language formula). For each main entry context, generate copy across the seven angles and mark which to test first. Render a table:

| # | The angle (what it does) | Example ad line |
|---|---|---|

The seven angles, with the formula in parentheses, and a fresh example line each:

1. **Outcome angle** (Core Job for the Aspiration Job) — "Send the proposal today, start the project Monday — stop bleeding weeks to back-and-forth." `[VERIFY — source]`
2. **Concrete-value angle** (Core Job + value in criteria) — "Build a priced, scoped proposal in fifteen minutes." `[VERIFY — source]`
3. **Right-moment / urgency angle** (Trigger → Core Job) — "Just got a 'can you send me a quote?' Reply with a signable proposal before they cool off."
4. **Help-them-decide angle** (Orientation Job) — "Hourly, fixed-fee, or value-based? See which one wins you the project."
5. **Life-after angle** (the Aspiration Job lived — State B) — "Booked through next quarter, every project scoped before it starts."
6. **One-feature angle** (Sub-job) — "Lock the scope so 'just one more tweak' becomes a paid change order."
7. **Fix-what's-broken angle** (Problem with the current Solution → Core Job) — "Tired of clients treating your estimate as the ceiling? Send a proposal that holds."

Blend angles wherever that sharpens the pitch. Internal check (never shown to the user): every clause ties to a real task at a named level that carries a measurable bar; whenever a line packs two tasks together, break it in two. **Specificity rule:** before anything ships, send each adjective through "as in?". **Visuals brief:** depict the destination (State B) and name the feeling — not the work of getting there. Produce enough variants to test: a strong opening set for each context, with a note on what to A/B.

*▸ methodology trace* (subscript): the seven creative formulas and visuals-show-State-B in `communication.md §6`; every clause maps to a named Job level and a criterion.

#### Part 3 — GTM / growth communication

<a id="l3-channels"></a>

Three sub-parts, each of them run through Jobs.

**3a. Channels to try** — for every channel × segment combination, packed with the Choice Activators. Render a table:

| Channel | The window when you can reach them | The pitch (what tips them toward you) | First step (CTA) | Success metric |
|---|---|---|---|---|

Plus the moves:

- **Catch them while the door to switching is open** — right after the current way just failed, a life event hit, or a rival let them down — and never in the middle of a habit (the receptivity windows).
- **Get to them one stop earlier** — hand over a free tool or a piece of content tied to whatever task comes before yours (a calculator, an estimator, an aggregator, a guide). You arrive sooner and shape the options they weigh. That preceding task is the Previous Job.
- **Content that does their comparison work** — strong content takes on the research-and-compare for them and pulls them upstream (the Orientation Job). Build a loop where using the product spits out content that helps the next buyer compare; what powers it is the Aha Moment.
- **Lead magnet** — trade an oversized chunk of free value for a contact (a checklist, a template, a calculator). People over-rate anything labeled "free."
- **Things people do with or in view of others** — when the product surfaces in front of an audience (decks, docs, boards, screen recordings), make being seen using it feel good, and favor segments where that happens often (the Viral Jobs).
- **B2B (only when the input is B2B)** — work through peer stories, case studies the customer published, customer conference talks, analyst reports, and tips from colleagues they trust, instead of consumer channels. Hand the internal champion a deal room. Address what the buyer personally stands to gain (the personal Jobs).

<a id="l3-dealroom"></a>**The B2B deal room** — give the champion a side-by-side against named rivals, objection answers built per stakeholder, references drawn from inside their industry, and a business-case template they can drop straight into a deck of their own.

**3b. Cross-sell / upsell messaging.** *Cross-sell* = whatever the customer does naturally the moment the job wraps (the Next Job), framed as a seamless continuation. *Upsell* = connect it to the bigger outcome (the Aspiration Job), step up-market, or sell a bundle.

**3c. Retention messaging.** Keep supplying new moments that outrun expectations (a stream of Aha Moments — and because the bar rises over time, land the first as early as you can). Lean on the habits they already keep and ride the rituals they already run, instead of demanding new ones. Trade on frequency and the Next Job — the more jobs they complete with you over time, the further net revenue rises above 100%. Add ecosystem lock-in anywhere it applies.

*▸ methodology trace* (subscript), with the new canon paths: the receptivity windows and the forces in `behaviour-change.md §8–9`; Previous-Job channels plus upstream attention across `delivery-chain.md §9.1` and `attention.md §9`; the Viral and Orientation Jobs in `job-types.md`; B2B channels, personal-Job messaging, and the deal room in `b2b.md §3–6`; cross-sell framed as the Next Job in `delivery-chain.md §9.2`; the upsell as a step up a level, together with the Red Queen value-gap underneath the Aha-stream, in `value-creation.md §14, §6`.

#### Appendix — what each asset is doing

<a id="l3-camap"></a>

A table mapping each landing block, ad, and channel asset to which of the five Choice Activators it carries:

| Asset | There's a better route | Beats the rest on what they truly value | The product, with a first step | The fear in question is dealt with | The way they work now genuinely fails them |
|---|---|---|---|---|---|

Then: the behaviour-change forces as they play out for this segment — calling out which pull each asset taps and which blocker it clears. Verify that you are reusing or working around a habit they already have, and never squaring off against one directly.

*▸ methodology trace* (subscript): the five Choice Activators components in `choice-activators.md §1`; the behaviour-change forces in `behaviour-change.md §9`.

---

## S2 — Self-critic and summary

Run the self-critic over the whole draft (Quick: a self-review; Deep: a separate critic agent), fix what it finds on the spot, and keep its verdicts in context. Then, in chat, reprint Layer 1 word-for-word next to a 3–4-line wrap-up (the one-liner, the Aspiration Job everything runs through, the validation status, the front-runner channel hypothesis) and the file path.

**Self-critic criteria (methodology):**

1. The copy moves through the Aspiration Job — or, when a Class-1 segment already knows the Core Job, opens on that Core Job — instead of laying out Core-Job steps on their own.
2. Every value claim lands on a concrete criterion (direction + level); no adjective gets past "as in?".
3. Features show up only as proof, fastened to a Job and a criterion — never as the headline.
4. The product is never promised an Aspiration Job it only half-delivers; the promise lines up with the Delivery Chain.
5. All five Choice Activators components are present; the competing option is fired on a real Problem; the fears called out are specific.
6. The Aha Moment points to an actual event (not a signup or a login), gets tasted on the landing page, and powers both retention and word-of-mouth.
7. The validation status is told straight — value still at the hypothesis stage is flagged as demand-test creative rather than scaled as though it were fact.
8. Specific stories are in play; visuals are State B; the recognition test holds (familiar brands or a bridge); US-context analogs are used; no prediction-error jargon; disclaimers and clickable source links are there.
9. The step ledger ran — S0 → L3 (Part 1 → 2 → 3 → Appendix) → L2 → L1, calling out each as it gets ticked off (skipping an unordered part is fine as long as you say so); nothing vanishes without a flag.
10. User claims stayed hypotheses — in customer-facing copy, every number and comparison either points back to tagged data or goes out flagged for verification; no fact in the copy is spun up from a hunch.

**Checkbox gate items (readability / contract):**

- **Plain-language-led** — the plan and annotations lead in the reader's words; terms only in parentheses; the methodology appendix and debug notes may stay in full terms.
- **Three layers present and correctly leveled** — L1 minimal jargon and forwardable; L2 a plain plan plus why, terms glossed, no big copy blocks; L3 the full pack with copy intact; no conclusion repeated at the same depth.
- **Drill-down links resolve and are unique** — every L1 line → a real L2 anchor; every L2 claim → a real L3 anchor; every `#l2-…` / `#l3-…` target exists exactly once; no shared targets.
- **`[VERIFY]` survives into the copy** — across the landing and ad copy, each number and claim holds onto its inline `[VERIFY — source]` until it's proven; any cryptic table header earns a plain inline gloss right beside it.
- **Disclaimers once; answer first** — only the file's top carries the two-part disclaimer; the validation flag sits beneath the L1 answer (≤2 lines); L1 carries a one-line pointer; the block doesn't recur in L3.
- **Citations fenced** — landing and ad copy carry no citations; no canon path or rule number appears inline in any copy, in L1–2, or in L3 prose; each canon reference lands in a "▸ methodology trace" line closing a part; landing and ad lines read as clean shippable copy.
- **Producer contract satisfied** (`../PRODUCER-CONTRACT.md`): the helicopter view ran ahead of the first question (§1); intake captured both the output format (§2) and the output path (§5); any HTML run yielded one self-contained `.html` whose anchors and collapsibles work; the input-as-hypothesis gate held and the "What you gave me — and the risks in it" block is present (§3); L1 carries the validation-debt line and the entire pack reads as "test this messaging/channel," never as "this will work" (§4); on a hand-off, the run checked which upstream debt has since been validated and carried the rest forward (§4c); in Deep mode the evidence floor was cleared, the self-critic loop ran, and the web-MCP fallback was offered (§6).

---

## Deep mode (subagents + web)

S0 runs identically, with the human. S1 gets parallelized and anchored in the actual words customers use. The workers are general-purpose subagents running in the background; each one loads only its own canon slice (the eager core together with whatever staged files its part calls for), hands its result back in its closing message (no files), cites its sources, and keeps canon citations clear of the copy. The orchestrator keeps every return in context and writes the one output file.

**Wave structure:**

- **Wave 0 (background from the start) — REVIEWS.** Review-language mining: fetch reviews of competitors and alternatives (G2, Reddit, Product Hunt, Trustpilot, Capterra, the App Store); extract the words customers actually use, their specific Problems with the current Solution, and 5–10 quotable lines per competitor *with source URLs*; return in-message. It has to clear the evidence floor (a true minimum of distinct sources, or a note on why fewer). If the built-in fetch is blocked, fall back to a web-MCP.
- **Wave 1 (parallel, consuming the reviews return)** — LAND → Part 1; ADS → Part 2; GTM → Part 3 — each returns in-message.
- **Wave 2 — CRITIC.** An adversarial self-critic over the full criteria, including the layer and citation-fencing checks; it returns fix instructions; ≤2 rounds, then escalate.
- **Orchestrator:** hold the returns; assemble L3 from the part returns; strip any inline canon citations the writers left in the copy and fold them into per-part "▸ methodology trace" lines; compute L2, then L1 last, wiring the drill-down links; write the single file (disclaimers once → glossary link → L1 → L2 → L3); apply the critic fixes; print the chat summary.

**Per-agent slices** (restated): Landing → core + attention + barrier-removal; Ads → core; GTM → core + behaviour-change + job-types + delivery-chain + b2b-if-B2B + value-creation. Each returns its part with no inline canon citations.

**Web caps:** review mining tops out at ≤12 fetches across roughly 10 minutes. Source links are required. Figures, sources, and reviews are never fabricated.

**Deep-mode QA** (the evidence floor, the per-leg self-critic loop, and the web-MCP fallback, `../PRODUCER-CONTRACT.md §6`):

- **An evidence floor, not only a ceiling.** The cap sets an upper bound; the lower bound is a floor in its own right. Review-mining cannot call itself "done" before it has gathered a genuine minimum of distinct sources (spread across competitors, with quotable lines and URLs) *or* spelled out why there are fewer (blocked, or none exist). "Ran two queries and quit" counts as a failure, not as finished.
- **A self-critic loop on each leg.** Once a research or writer leg returns, do a quick critic pass: are there enough distinct review sources? Does every customer-language claim trace to a fetched source rather than being invented? Any methodology slip — Aspiration Job mistaken for the segment, features ahead of criteria, adjectives that flunk "as in?", an Aspiration Job promised that the product only half-delivers? Any holes? On a failure, re-run with the gap spelled out, up to two more rounds. A leg that flunks its own critic does not ship.
- **A web-MCP fallback.** Whenever the built-in fetch is blocked or comes up thin on a review source you need, say so to the user once and turn to a web-research MCP if one is on hand. Give a short user-facing note: you can switch on a web-research MCP (Firecrawl or Exa both ship MCP servers); lacking one, coverage can run thin and the copy ends up leaning more on reasoning and less on the actual words customers use. If one of those MCPs is wired up (located via tool search), use it for the blocked sources; otherwise carry on and flag the thin coverage.

---

## What this skill does NOT do

- It does not pick the segment or size the market → `/market-research`.
- It does not invent the value proposition → `/value-prop`.
- It does not write the product requirements or build spec → `/product-requirements`.
- It does not validate value — it transmits already-validated value; if the value is unproven, it produces demand-test creatives and says so.
- It does not run ad accounts, build the funnel, or buy media — it produces copy and channel hypotheses to test.
- In Quick mode there is no internet and there are no subagents.
