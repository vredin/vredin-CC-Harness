---
name: product-requirements
description: >-
  Turns a chosen customer segment and its Core Jobs into a build-ready product
  requirements document — full functionality plus roughly 90% of the edge cases.
  It consumes upstream work (segments from /market-research, value direction from
  /value-prop) and never re-derives them; when there is no prior research it either
  routes you upstream first or accepts a segment and value you describe by hand for a
  fast pass. Before any requirement is written it runs a "challenge the build" gate —
  looking for a cheaper or more effective way to hit the same business goal, and if one
  wins, the PRD is written for that instead. The deliverable is a single document mapping
  each piece of functionality from Core Job to Aspiration Job to the value mechanic it
  uses to its success criteria to its Aha Moment, laid out along the Delivery Chain, with
  an edge-case table covering about 90% of real-world variation. Two modes: Quick (default,
  offline, one pass) and Deep (subagents plus a web parity check). Plain language, defaults
  to English. Reach for it when someone says "write the PRD" or "turn this segment and value
  into a build spec."
user-invocable: true
---

# Product Requirements (PRD) — English / US edition

## New here? Start with the right door

Unsure whether this is the right skill? Sketch your situation for `/advisor` and let it route you. A quick orientation:

- A fresh idea with nothing built yet → `/market-research`
- Something already shipped, or a metric that shifted → `/diagnose`
- Customer interviews already in hand → `/analyze-interviews`
- The who and the what are settled and you want to spec the build → `/product-requirements` (this one)
- You want positioning and then a launch → `/value-prop`, followed by `/go-to-market`

## In one breath

This skill **takes in** a segment plus a value direction; it neither rediscovers nor reinvents them, and it conducts no research itself. Show up with nothing upstream and it will either point you back to the appropriate earlier skill or accept a segment and value you each describe in a single sentence and run a fast pass. No requirement gets written until a **challenge the build** gate has run. What comes out is one PRD, lean by default: a one-page summary at the top, and underneath it the complete functional requirements plus an edge-case table spanning roughly 90% of real variation. The reading flow stays free of methodology jargon, no internal rule numbers surface in the output, and the canon is pulled in one stage at a time instead of all at once.

What falls outside this skill: landing pages, ad copy, and go-to-market messaging (those live in `/go-to-market`), an analytics plan, and a freestanding unit-economics model. Unit economics persists only as a filter on the reasoning — it informs the challenge and the ranking; it is never a deliverable.

## Shared producer behaviours (see `../PRODUCER-CONTRACT.md`)

In common with every producer skill, this one honors six shared behaviours:

1. Lay out the whole run from a helicopter view before the first question lands.
2. Ask at the outset whether you want Markdown or HTML for the result.
3. Hold each handover as a hypothesis instead of established fact, and surface a block that names the risks you spot in what you were handed.
4. Print the validation debt, and for any go-style verdict write `GO (to validation)` rather than a bare `GO`.
5. Honor a custom output path.
6. In Deep mode, keep an evidence floor enforced, run a self-critic loop, and fall back to a web-research MCP whenever the native fetch fails or comes back too thin on a source you need.

Since the PRD is the artifact nearest to actually shipping something, the contract's "validate before you build" clause matters more here than anywhere else in the method.

## Where this skill sits in the chain

```
/market-research      →   /value-prop          →   /product-requirements   →   /go-to-market
(segment + Jobs +         (value hypothesis +      (THIS — the build spec)     (landing + ad +
 wedge + competitors)      implementation spec)                                 GTM comms)
```

This is the **build step**. It receives a chosen segment, its Core Jobs, and a value direction; it asks whether building is even the right move at all; and it yields requirements engineers and designers can build against. It does no re-segmenting, it reinvents no value, and it drafts no customer-facing copy. The governing rule: never regenerate what an upstream artifact already holds — read it in and grow from there.

## What this skill produces

What comes out is one file — the PRD itself. By default a one-page summary sits on top, the full build spec underneath. Three reading depths are linked head to foot, so a reader can drop from any headline straight into its complete reasoning:

- **Layer 1 — What we're building** (about a page, free of methodology vocabulary, shown by default): plainly states what the thing is, who it's for, the single moment proving the value lands, the one riskiest item to check before building, and what ships first. Each line drills into its own reasoning, and the whole is brief enough to forward to a co-founder.
- **Layer 2 — The Reasoning** (everyday language, 2–4 pages): the argument for this build over the alternatives — what the challenge gate concluded, which core capabilities matter and why, the failure modes worth caring about, and the riskiest assumption next to its cheapest probe. Each claim links down into the full spec.
- **Layer 3 — The Full Work** (the build spec): the challenge gate, the complete functional requirements, the ~90% edge-case table, who the users are, competitive parity, success metrics, how risk is handled, and a stated out-of-scope. Every requirement keeps its methodology trail in a fenced "trace" line parked outside the reading flow — Core Job → Aspiration Job → value mechanic → success criteria → Aha Moment, set along the Delivery Chain.

Not produced: landing, ad, or GTM copy (→ `/go-to-market`); an analytics plan (out of scope); a freestanding unit-economics model (out of scope — unit economics is a filter only).

Two modes:

- **Quick** (default): roughly 5–10 minutes, one agent, fully offline, no subagents.
- **Deep** (opt-in): subagents plus web access — re-checks competitor parity against live sites and pressure-tests the edge cases against real user reviews.

## Methodology — the source of truth

Everything the reasoning rests on comes from the **product-method canon**, read at runtime via the relative paths below. Don't load all of it up front. Read the eager core on every run ahead of analysis, then read each staged file only once the run actually arrives at the stage that needs it.

**Public-skill rule:** ground only in the public canon (the whitelisted public set). Never read or quote any canon file beyond the read sets listed here, even when the skill happens to run somewhere private files also sit.

### Eager core — read on every run, ahead of analysis

| File | What it powers | ~tokens |
|---|---|---|
| `product-method/canon/jobs/delivery-chain.md` | The chain functionality is built on; its break sites feed the edge cases (§5, §7); this is the PRD's spine. | ~5k |
| `product-method/canon/jobs/job-structure.md` | The eight Job elements; context → criteria (§3); criteria → metrics (§8); fidelity levels. | ~5k |

### Staged — load each one only as its stage arrives

| File | Load when | Used by | ~tokens |
|---|---|---|---|
| `product-method/canon/the-algorithm.md` | At the challenge gate (S3) | Step 1 challenge (5 Whys, local-vs-global gate) | ~6k |
| `product-method/canon/subtraction.md` | At the challenge gate (S3) | Subtraction-first question + the no-interaction-ideal asymptote | ~4k |
| `product-method/canon/local-vs-global.md` | At the challenge gate (S3) | Additive local-optimum vs. global-optimum check | ~4k |
| `product-method/canon/jobs/value-creation.md` | At the functional-requirements stage (S4 §3) | The value formula (§3); success criteria (§9); the criteria-to-mechanics mapping (§11); the Aha Moment (§12); the pair of dominant mechanics (§14); value arising outside the Core Jobs (§17) | ~7k |
| `product-method/canon/jobs/value-mechanics.md` | At the challenge gate (S3) + functional-requirements stage (S4 §3) | The mechanics catalog (challenge menu + feature → mechanic mapping) | ~4.9k |
| `product-method/canon/jobs/job-types.md` | At the edge-case stage (S4 §4) | Chore / Orientation / Emotional / Viral Jobs as edge-case and functionality sources | ~5k |
| `product-method/canon/riskiest-assumption-test.md` | At the challenge gate (S3) + risk stage (S4 §7) | Risk handling; the drop-it exercise; MVP as a probe | ~6.5k |

### As-needed — pull in only when the triggering condition occurs

| File | When | ~tokens |
|---|---|---|
| `product-method/canon/jobs/job-map.md` | When the Job Map slice calls for care — level placement, many-to-many links, directional moves. | ~6k |
| `product-method/canon/jobs/segmentation.md` | Path D, while sharpening a hand-described segment; confirm Core-Job level placement. | ~5k |
| `product-method/canon/jobs/behaviour-change.md` | Aha Moment placement, triggers, the seven behaviour-change triggers. | ~6k |
| `product-method/canon/method-overview.md` | The unit-economics filter in the challenge and the ranking (LTV > CAC, payback, target margin per unit; the segment's budget carries the math). Filter only, never output. | ~5.4k |
| `product-method/canon/jobs/b2b.md` | Loaded only when the buyer is an organization — edge cases along the role chain, plus two Job Maps in parallel. | ~6k |

**Quick mode** reads the eager core and then loads each staged file the first time the run hits its stage. **Deep mode** divides the reading across agents — the Delivery-Chain builder reads the eager core plus value-creation; the Parity agent reads only the eager core; the PRD designer reads the eager core plus value-creation plus value-mechanics; the edge-case analyst reads the eager core plus job-types (plus b2b when the buyer is a company). No agent reads beyond its slice.

### Anti-defaults — do not fall back to generic internet JTBD

Five frequent mis-defaults never to carry forward:

- A **Job** is a wanted transition: from State A (the situation you begin in) to an expected outcome (State B), taken on so as to perform a higher-level Job. It is not a hazy "struggle for progress."
- **Value** means the brain burns less energy getting a Job done than it had braced for — efficiency measured against its own forecast. The **Aha Moment** is the felt sense of value running ahead of that forecast; a **Problem** is value landing below it. Never write the PPE/NPE abbreviations — write "Aha Moment" and "Problem."
- "I want to + verb" is merely the **primary element** inside a Job that holds eight elements — not the Job entire. Read each infinitive verb as its own Job; a statement carrying several verbs gets split into the hierarchy.
- A **Problem** shows up the moment a Solution you hired for a Job lands below that Job's bar (its success criteria) — and a Problem is never a root cause.
- A **Solution** is an actual thing out in the world; inside the Job Map it names the sub-graph of Core and Sub-jobs that it installs.

### Methodological invariants — the PRD is invalid if any of these is violated

- Every feature ties a Core Job → an Aspiration Job **and** names the value mechanic it puts to work (taken from value-mechanics). A missing ladder plus a missing mechanic is feature thinking, not a requirement.
- The Aha Moment is the instant value beats prediction (a positive-prediction-error event) — never signup, never login, never a "first action" — and it sits as far toward the left of the Delivery Chain as it can be pulled.
- The Delivery Chain is built explicitly for each Core Job; both functionality and edge cases are read off it.
- Success criteria are specific — a direction plus a level — and they convert into success metrics.
- Segmentation is not rebuilt at this stage — it is taken as a given (the root being Core Jobs together with success criteria; the Aspiration Job furnishes motivation context and is not the line that divides segments).
- The challenge step occurs before any requirement, and whichever approach wins the gate is the one the PRD documents as the chosen path to the business Job — not necessarily the build first proposed.
- General output rules: every named external source is a clickable Markdown link; examples use US-context analogs and pass a recognition test; a two-part disclaimer rides the top of the result. (Express these as plain rules — never quote internal rule numbers in the output.)

## Plain-language output rule

The person reading this builds products; they are no method theorist. Write the user-facing document in the everyday language of the segment. Wherever a methodology term genuinely sharpens a point, give the plain meaning first and slot the term into parentheses the one time it first shows up. Don't open any sentence, bullet, or heading with a methodology label.

A worked illustration of the gap. Say the product helps a small bakery keep its morning pastries selling out before noon more reliably than the café across the street.

- **Jargon-led (bad):** "The value mechanic decays once competitors close the success-criterion gap, yielding value-gap decay."
- **Plain-led (good):** "Today your croissants sell out before the café over the road even gets going — but the day they match that, your sell-out edge fades and the head start you were charging for (the value mechanic) quietly stops being worth more than people expected."

Same point, yet the good version opens with the felt reality of a lead evaporating and parenthesizes the term only once.

**Who reads this:** US founders, indie hackers and vibe-coders, growth-stage PMs, senior PMs and VPs, and product marketers. The vocabulary they live in: product-market fit, burn and runway, a pivot, a niche that actually pays, shipping, the first customers who hand over money, a roadmap I can stand behind, a metric that genuinely moves, positioning, and conversion. Avoid: "blitzscale," "10x overnight," "go viral," "the one framework you'll ever need," "growth hacks," "this one weird trick," "crush it" — and any jargon used to open a line.

**Plain ↔ methodology mapping** (open with the left-hand phrase; show the term in parentheses only the first time):

| What the reader sees (lead phrase) | Term in parentheses |
|---|---|
| the bigger outcome they actually want | Aspiration Job |
| the biggest task the product handles entirely by itself, front to back, and can't yet top | Core Job |
| the step-by-step route the customer walks | Delivery Chain |
| the exact spot where they stall out | a break in that chain |
| the way the product makes value — one named play pulled from the catalog | a value mechanic |
| reaching the outcome with less stress, money, effort, or time than they had braced for | value |
| the few things they have to understand or trust before they'll switch | Choice Activators |
| a true blocker, not merely a nagging concern | a Barrier (vs. a fear) |
| the single assumption likeliest to sink this — probe it cheaply, early on | riskiest assumption (Riskiest Assumption Test, RAT) |
| the Aha moment — where the product clearly beats expectation and it clicks (open with the term) | — |
| success criteria — concrete thresholds for "good enough" (open with the term) | — |
| a problem — a tool doing a task worse than expected (open with the term) | — |
| a segment — folks doing the same core task who score success the same way (open with the term) | — |

Never tell a user "Positive/Negative Prediction Error" — write "Aha moment" or "Problem." Write RAT out in full on its first appearance.

Precision still applies in the methodology layer — within Layer 3 and inside the parentheticals, Jobs read as "I want to + verb," levels are named, and terms are capitalized.

## Readability rules

- The **default face** is the one-page summary (what / who / proof moment / single riskiest thing to validate / what to build first), and it opens the file. Below it live the full functional spec and the edge-case table (~90% coverage), with a short plain-language reasoning layer wedged in between. The whole is linked head to foot.
- **Three layers, rising depth.** State each conclusion once per layer and never twice at the same depth — a headline in Layer 1, a plain sentence in Layer 2, a full row or section in Layer 3.
- **Drill-down links are required.** Every doubtable Layer-1 line carries a `▸` link to its Layer-2 anchor, and every Layer-2 claim links down to Layer 3. Use Markdown anchors — e.g. `[text ▸](#l2-risk)` paired with `<a id="l2-risk"></a>` set just above the target.
- **Layer 1:** minimal jargon, plain words first, terms only in parentheses, never open a line with a raw term; the proof moment is in plain words; sentences stay short.
- **Layer 2:** plain first, each term glossed once in three to five words in parentheses (nested or repeated glosses are fine); link `references/glossary.md` once at the top; no large tables.
- **No internal methodology citations in Layers 1–2** — no canon paths, no rule numbers.
- **Layer 3 may carry citations**, but fenced into a `▸ methodology trace` line styled out of the reading flow (picture a small-text trace at the close of a subsection). Never drop a canon reference inline mid-sentence. Internal rule numbers appear in no layer.
- The **per-requirement methodology trail** lives in the fenced trace, not in the readable requirement. The readable requirement states only what to build plus its acceptance criteria; the trail (Core Job → Aspiration Job → mechanic → Aha) goes into the trace (the mechanic name stays, the canon path is stripped).
- **Disclaimers show once** (at the top of the file), with only a one-line pointer in Layer 1; the full block is never echoed lower down.
- **Hold onto the source links** for any external fact.

**Enforcement gate** (verify each item before you write the file; the full version sits in `../READABILITY-CONTRACT.md`):

- **Unique, resolving anchors:** every `▸` target is a unique `<a id>` that exists exactly once; no two links share a target; list them and confirm before shipping.
- **Inline-gloss opaque Layer-3 headers:** any opaque table header gets a three-to-six-word plain gloss right where it sits.
- **Clean readable requirement:** what to build plus acceptance criteria only; the mechanic mapping lives solely in the fenced trace.

## Output file

The skill writes exactly one file. Absent a custom path, it lands under the product folder at the project root (never in TMP/ or .claude/):

```
method-results/{product-slug}/product-requirements/{YYYY-MM-DD_HH-MM}_{product-slug}-product-requirements-result.{md|html}
```

The extension matches the format you picked: `.md` (default) or one self-contained `.html` file (inline CSS, working in-page anchors so every jump link and every `▸` link resolves, collapsible `<details>` blocks for Layer 3 and the traces, and source links that open in a new tab). The HTML carries identical content in a more readable shell. Never both — one file per run.

A custom path writes the one file there, using the same filename pattern.

Everything internal — the normalized input, the challenge work, the Delivery Chain for each Core Job, the alternatives that got dropped, the self-critic verdicts — stays in context rather than being saved to its own file. The timestamp keeps each run's file distinct. The disclaimers ride the top of the single file.

## The pipeline (S0 → S5)

```
S0  Intake & route         (human: language, mode, input path; no-research path → route out
                            to /market-research → /value-prop, OR take a described segment +
                            Jobs + value for a fast write)
S1  Select segment + Core Jobs   (human picks the segment, then the Core Jobs)
S2  Business context       (human: ≤4 batched questions, only the fields not already supplied)
S3  CHALLENGE THE BUILD    (human picks the build subject: the original, or a more-effective way)
S4  PRD generation         (functionality on the Delivery Chain + ~90% edge cases; no questions)
S5  Assemble + self-critic + summary   (human: optional tweaks)
```

**Question budget:** between three and five human touchpoints, and fewer the moment an upstream artifact already hands over the segment, the value, or the context. The skill runs no research itself — it either routes out at S0 or takes a hand-described segment and value. Under Quick mode, S4 wraps in one pass.

## S0 — Intake & route

### Orientation (helicopter view) — show this first, ahead of any question

Before any question lands, lay the entire run out plainly, in the language chosen:

- **What you'll get:** one PRD ready to build against — naming the thing to build, who it's for, the moment that demonstrates the value lands, the first item worth validating, and the complete spec — set across three reading depths, so you can pull up at the summary or keep descending all the way.
- **The steps:** (1) you answer a handful of questions about where you stand → (2) I lift the segment and value out of your upstream work, or out of a short description → (3) I put it through a "challenge the build" gate → (4) I write the PRD for whatever clears that gate → (5) you receive one document at three depths.
- **What's mine vs. what's yours:** producing the analysis, the challenge, and the spec is on me. Choosing the build subject and carrying out the field validation is on you — I can't run the validation for you.
- **Two modes:** Quick (offline, one pass, fast) or Deep (subagents plus a web parity check).
- **Honest caveat:** this speeds up the thinking, not the proving. A fast PRD is a hypothesis awaiting validation, not a green light.

Close with: **"Ready? First, a few questions."**

### Intake-depth question — ask this first

Ask at the outset how thorough the questioning should be. This is distinct from the Quick/Deep research mode. Two options:

- **Just the essentials** — 3–4 load-bearing questions, then I deliver (best for a quick first pass or for exploring). Under this option, ask only the load-bearing fields: starting point; the segment and value (consumed from upstream or one sentence each); and the business goal. Skip or batch the materials, the claims ledger, and the business-context fields into one short pass, and flag in the result any field you had to infer.
- **The full interview** — go through everything for the widest blind-spot coverage (best when the decision is costly). Under this option, run the complete intake: materials, the claims ledger, and every business-context field.

Either way, never ask the user to phrase a Job in canonical form — shape the grammar behind the scenes.

### Language

Default to English. Should the user write in another language, offer to carry on in it (English / their language / Other), note their choice, and produce the PRD in the language they picked. Canon files and source URLs stay untouched.

### One batched AskUserQuestion

- **Q1 — "Where are you starting from? (no prior research is fine.)"** Options map to paths:
  - "Skip research — I'll describe my segment and value" → **Path D** (the fast path, default for a first run).
  - "I have a `/value-prop` result" → **Path A** (segments and value both present).
  - "I have a `/market-research` result" → **Path B** (segments present, value not yet crafted).
  - "I haven't done research and I want to" → **Path C** (route out).
- **Q2 — "Mode? (separate from intake-depth — this one is about internet access.)"** Quick (default, no internet) / Deep (subagents plus a web parity check).
- **Q3 — "Output format?"** Markdown (default) / HTML (collapsible, in-page nav, links stay clickable).
- **Q4 — "Where should I save the result?"** Default (`method-results/{project}/product-requirements/…`) / a custom folder path (free text). Skipping means the default; one file per run.
- **Q5 (Paths A/B only) — "What's the path to the upstream result file?"** Free text, then Read it.

### Resolve the input path

**Path D — describe it yourself** (the default for a first run). Gather by description or dictation:

- A one- or two-sentence account of the product, with a URL where one exists.
- Who it serves (the segment) and what truly binds them into that group — a behaviour or trait, not demographics like age or income.
- The larger result they're after (the Aspiration Job) and the sign that would tell them it worked (success criteria).
- In a sentence each, the one to three main tasks the customer is getting done (the Core Jobs — I'll formalize these behind the scenes).
- The value: what makes it worth switching and roughly how it works (this stands in for a `/value-prop` run).
- A few alternatives you're aware of.
- The business goal.

The skill mends the grammar behind the scenes — splitting a "task" that is really two, dropping demographics that aren't causal, turning an adjective-style value claim into a concrete one. It then runs through S1 → S5. At the top, the result flags that it came from a **described** segment and value rather than one backed by research.

**Path A — reuse a `/value-prop` result** (the deepest input you can arrive with). Read it. Its implementation spec already supplies, among other things, the feature table and the product shape; the Delivery Chain together with its Aha placement; the unit-economics direction; the build cost paired with the cheapest probe; and an explicit not-for list — plus the target segment, the Aspiration Job, the competitors, the proof, and the riskiest-assumption cards. With both segments and value in hand, most of S1 and S2 are already settled. **Confirm rather than re-ask**, then move to S3.

**Path B — reuse a `/market-research` result.** Read it. Harvest each piece and regenerate none of it: the target segment(s) with their ✅ / ⚠️ marks, the principal tasks alongside their success criteria, the Aspiration Jobs, the rival landscape split into direct / indirect / turnkey, the spot where you win, and the riskiest-assumption list ordered action-first. Carry every item straight through. Since the value layer hasn't been built yet, say as much and offer a fork: run `/value-prop` first (the strong recommendation), or push on, taking the differentiation hypothesis from the market research as your value direction (and flag the lower confidence at the top of the PRD).

**Hand-off debt (Paths A/B only).** The upstream artifact carried unvalidated assumptions — about the segment, willingness to pay, value, and channel — and that debt rides down to the PRD. Ask once, before building, which of those have since been checked in the field and what came back. Re-tag the still-unvalidated ones into the §7 risk section and into this PRD's validation-debt line (Layer 1), each with its cheapest probe. Mark the confirmed ones validated and drop them from the debt count.

**Path C — route out.** Reply that the right sequence is `/market-research` → `/value-prop` → back here on Path A. Offer to open the `/market-research` input prompt, then hand off and stop. Sizing markets and finding segments aren't this skill's job. Mention that Path D is the build-now option for anyone wanting to push ahead without research.

### Materials, the claims ledger, the hypothesis gate, and direction confirmation (all paths)

**Materials.** Ask once for any files or folders — a Notion export, past research, interview notes, an existing spec, the current site. Read whatever lands and tag it `[user data]`. Never quietly fold existing positioning, copy, or a feature list into the PRD as if it were settled — confirm it should carry, because it may be exactly what the challenge ought to challenge.

**The user-claims ledger and the input-as-hypothesis gate.** Pull every strong factual claim, plus every load-bearing upstream or uploaded input, into a running ledger held in context. Every scrap of this is hypothesis rather than fact — a landing page expresses a belief about value; a stated segment-and-value may be nothing more than the team's guess at what the customer's Job is, which is the costliest error there is. Tag each item:

- **data** — measured or documented.
- **observation** — seen in interviews or sales.
- **hunch** — a belief or intuition (the default for a deck, a landing page, or an idea description).

Hunt actively for risk in each load-bearing input: is it customer-validated or only team belief? Is it a real Job or a projection? Are there internal contradictions? Are guesses being passed off as data? The findings feed the "What you gave me — and where it looks risky" block in Layer 2, with the most damaging of them lifted into Layer 1.

**Hard gate.** No PRD scope, no Core-Job selection, and no challenge verdict may lean mainly on an unvalidated user input unless the PRD says so out loud and aims a RAT row at it. If scope rests on an unconfirmed Job or value, name it in §7 as the single costliest risk, hand it the cheapest falsifying test, and lift it into Layer 1 as the "single riskiest thing to validate **before** building."

**Direction confirmation.** Before S1, play your understanding back in one short block — what we're building, for whom, the business goal, what is settled vs. what is open — and confirm with one AskUserQuestion (Confirm / Correct).

Retain that normalized input as you go.

## S1 — Select segment + Core Jobs

When a lone target segment arrives via Path A (or a clear ✅ on Path B, or — on Path D — the single segment you described), bypass the segment pick, confirm it in a single line, and move directly to choosing Core Jobs.

Otherwise, lay out the segments and ask **"Which segment do we build for?"** with options listing each segment in one line (who they are + their dominant success criteria) plus "None of these."

On **"None of these,"** don't wander off to discover a new market. Put two real options: describe a different segment now (and stay on the fast path), or run `/market-research` and circle back. Never force a segment.

Next, choose the Core Jobs — the tasks the product completes in full. Ask **"Which Core Jobs of {segment} should the PRD cover?"** with options listing each Core Job ("When… I want to… with success criteria…") plus "All of the above" and "I'll adjust."

Keep the focus narrow — one to three Core Jobs. Resist "all of everything"; focusing means subtracting the Jobs that aren't focal. Keep the chosen segment and its Core Jobs (canonical form, with success criteria) in working context.

## S2 — Business context (only the gaps)

Collect only what the upstream didn't supply, in one batch of up to four AskUserQuestion items; skip any field you already know. Fields:

- **Business goal / business Job** — why build it at all (a fresh launch / a new feature / growing a product you already run / pushing into a new segment). S3 ladders up from this anchor.
- **Constraints** — team, budget, build horizon (< 2 weeks / 1–2 months / 3–6 months / 6+ months). This decides MVP-vs-full scope and frames the cheapest probe.
- **Stage / traction** — still on paper as an idea / interviews finished / first users on board / live and taking traffic. This fixes the PMF context.
- **Product type and monetization** — marketplace / SaaS / mobile / course / service; freemium / subscription / lead-gen / one-off. (If B2B, load `b2b.md` at the edge-case stage, not earlier.)

"Don't know" is a perfectly fine answer — log it in context as a hypothesis.

## S3 — Challenge the build (the gate)

It fires **before any requirement.** Sources: the-algorithm Step 1, subtraction, local-vs-global, riskiest-assumption-test §10, and value-creation §1/§14/§17. The point is to be sure that building this is genuinely the leanest, most brain-energy-efficient route to the business Job — and here the unit of planning is the value hypothesis, not the feature.

**Interrogate the inputs you were handed.** This is where the segment, the value, and the business goal get questioned instead of accepted. Is the Job — and the segment, and the value — the customer's actual one, or merely what the team projects onto them? Building toward a Job the customer doesn't really hold is, across the entire method, the failure that costs the most. Bring that doubt to the surface now and route it into the four moves that follow.

**Four moves** (hold the results in context):

1. **Ladder the business goal up (5 Whys).** Climb three to five levels — feature → conversion → sales → margin → the strategic goal — and name the real business Job. The goal that gets handed down is frequently the wrong one, and chasing how to deliver a wrongly-set goal is the priciest waste you can incur early on.
2. **Subtraction first.** Ask what could be stripped out — from the product, the segment, the chain, or the pile of assumptions — and still land an equal or bigger effect for less spend. Keep the no-interaction ideal as your asymptote: picture hitting the outcome with no product to touch at all — what would that even look like?
3. **Local vs. global.** Is this an additive local-optimum move — polishing the current product, segment, or model, low-risk but capped in upside — when a global-optimum move (going up a level, switching the segment, switching the business model, capturing the Previous or Next Job) would pay back multiplicatively more? Name the choice out loud. Don't slide into the local move out of habit.
4. **Surface the more-effective ways.** Run the value-creation mechanics over the segment's Job Map and produce two to four alternatives to building as specified — each one a concrete route that gets the business Job done at lower energy cost. Lead with the pair of dominant mechanics (kill a Job; move up a level), then the low-cost probe forms — a partner deal, a "do nothing" baseline, capturing the Previous Job, a no-code build, a done-for-you service, a concierge run. Per alternative, spell out: the mechanic at work; what gets added or removed; build cost set against the original; a quick gut-check on the unit-economics direction (does the value actually turn into margin?); and the riskiest assumption it carries (the RAT drop-it lens — which alternative subtracts risk instead of adding it).

**Present the choice.** Ask: **"Here's the build as specified, plus {N} potentially more-effective ways to hit the business Job '{laddered business Job}'. Which one do we write the PRD for?"** Options:

- "Build it as specified" (with one line on why).
- Each "{more-effective way}" (mechanic — what it removes — cost vs. the original).
- "Blend — I'll describe it."

**Lock the winning build subject.** Should a more-effective way come out on top, the PRD gets written for it — re-anchoring both the Core Jobs and the Delivery Chain onto that approach ahead of S4. Keep in context the decision you made and the roads not taken, each with its rationale.

**The verdict coming out of the challenge always reads "validate first, then build" — and never "build now."** Settling on a subject is no green light. What comes next is a cheap test of its riskiest assumption — a round of interviews, a fake door, a concierge run — run ahead of any build time. The MVP serves as a probe. Every go-style verdict is written `GO (to validation)` rather than a bare `GO`, and glossed once: "worth building toward — but before any code, take the riskiest assumption out to the field and validate it." That framing flows into Layer 1's riskiest-thing line and its validation-debt line.

**Keep it proportionate.** A small, well-validated feature riding on a working product might need no more than a one-paragraph confirming challenge; for a product built from scratch, this becomes the highest-leverage step of the entire run. Don't conjure up alternatives just for the sake of balance — when the build as specified really is the leanest option, say as much and keep going.

## S4 — PRD generation

Produce the spec against the locked build subject, covering the selected Core Jobs. Quick mode runs one pass; Deep mode is parallelized. Construct the Delivery Chain first (held in context), draft Layer 3 next, and only then derive Layer 2 and Layer 1 **last** off the completed Layer-3 spec — threading each `▸` drill-down link to its Layer-3 anchor.

### 4.0 — The Delivery Chain per Core Job (consume from upstream; build only when it's absent)

- **Path A:** the value-prop implementation spec already holds the Delivery Chain plus its Aha placement — take it as given, don't rebuild it. Add only what the PRD additionally requires: each chain segment's shape — conditional, OR-alternative, or AND-parallel — along with its break sites (the slowest link, cycles, hand-offs, and any spot an external interruption can strike). Should S3 have shifted the build subject, re-anchor the inherited chain.
- **Paths B/D:** build the Delivery Chain from scratch for every Core Job — the Sub-job sequence that all has to complete for the Aspiration Job to land — marking the shapes, marking the break sites, and noting where the Aha Moment fires plus how far left it can move.

Whichever path applies, this chain is the substrate beneath the functionality of Layer 3 §3 as well as the edge cases of Layer 3 §4, and it gets drawn as the Delivery Chain diagram in Layer 3 §3.

### PRD structure — one file, three layers

Lay the single file out as three reading depths linked head to foot: an attribution-free header with the disclaimers (once) → a "How to read this" block (three levels, jump links) → Layer 1 → Layer 2 → Layer 3. Derive Layer 1 and Layer 2 **last**, off the finished Layer 3.

**Top of file — disclaimers, once.** An `<a id="disclaimers"></a>` anchor and a two-part disclaimer blockquote:

- (a) **Numerical disclaimer** — every numerical estimate is an LLM-generated hypothesis with a runnable verification path; validate it before any major decision.
- (b) **Hallucination disclaimer** — this was generated by an LLM and may contain hallucinations; for a costly decision, run a full research pass and don't act on this document alone.

Plus a one-line ⚠️ context flag: on Path D, say it's a reduced-confidence run from a described segment and value; on Path A/B, name the source artifact's file path; if the challenge changed the build subject, say so. No attribution top-line.

**"How to read this"** — emitted once, after the disclaimers and ahead of Layer 1, in plain words. Three bullet levels, each with a `[jump ▸]` link:

- Level 1 — What we're building (about a page, plain; most readers stop here).
- Level 2 — The Reasoning (why this and not something else).
- Level 3 — The Full Work (every requirement and its acceptance criteria, the flow, the ~90% edge-case table, the metrics, the risks).

**Layer 1 — What we're building** (about a page, light on jargon, forwardable). Template:

- `<a id="layer-1"></a>` and a heading: "{build subject} — what we're building."
- A subline: date · plain who-it's-for · stage.
- A one-line "these are hypotheses" pointer to `#disclaimers`.
- A **validation-debt callout**: this PRD stands on N unvalidated assumptions, M of them fatal; validate the fatal ones before engineering time; link to `#l2-risk`. A small-text footnote defines N (the risky assumptions in §7, including any unretired upstream debt) and M (the ones that would kill the build). Note honestly that a Quick run on a hand-described segment and value carries high debt — say so plainly.
- Then five sections, each one plain breath with its own `▸` drill link:
  - **What we're building** (→ `#l2-build`).
  - **Who it's for** (→ `#l2-users`).
  - **The single moment that shows the value landing** — the Aha put in plain words, never tagged "Aha Moment" or "positive-prediction-error" (→ `#l2-capabilities`).
  - **The one riskiest thing to validate before any build** — the assumption that would sink the whole thing, plus its cheapest check (→ `#l2-risk`).
  - **What ships first** — the shortest opening slice that delivers that moment (→ `#l3-requirements`).
- Rule: minimal jargon, plain words lead, each line links to a unique anchor, and every doubtable line closes with a `▸` link.

**Layer 2 — The Reasoning** (plain English, terms glossed once, 2–4 pages, no big tables). `<a id="layer-2"></a>`, a heading, and an intro line linking the glossary once. Subsections, each with its own `<a id>` anchor and a down-link to its Layer-3 section:

- **"What you gave me — and where it looks risky"** (`#l2-input-risks`): an intro that everything was treated as a hypothesis, then a four-column table — *What you provided or claimed* (tagged data / observation / hunch) · *How I treated it* (where it was used) · *The risk I see in it* · *How to check it fast* (the cheapest falsifying test). Omit only if there were no claims or materials at all. If any scope, Core-Job choice, or challenge verdict leans mainly on an unvalidated input, say so in one bold sentence and point to the matching §7 row (which is also Layer 1's riskiest-thing line).
- **"Is building this even the right move"** (`#l2-build`): the challenge decision in plain words — the laddered goal, what we'd remove, the bigger-move check, what we build and what we don't, and why → links to `#l3-challenge`.
- **"Who it's for, and the moment that proves it"** (`#l2-users`): why this customer, the Aspiration Job in plain words, the plain Aha, and where it sits on the path → links to `#l3-overview`.
- **"What the product must be able to do, and why"** (`#l2-capabilities`): the handful of core capabilities, with one line each on why it's load-bearing; a small table is fine → links to `#l3-requirements`.
- **"The failure cases that actually matter"** (`#l2-failures`): the few path-breaks that lose the customer, ranked by harm, noting the rest live in the full table → links to `#l3-edge`.
- **"The riskiest assumption — and the cheapest probe"** (`#l2-risk`): the single most-likely-to-kill assumption, the cheapest pre-build check, and one line on why it matters → links to `#l3-risk`.

**Layer 3 — The Full Work** (the build spec). Set an `<a id>` above each part a Layer-1 or Layer-2 link points into. Keep all citations in fenced `▸ methodology trace` lines; never put a rule number anywhere. Sections:

- `<a id="l3-challenge"></a>` **"0. The build decision (challenge gate)":** the business goal laddered up (5 Whys); what we could remove plus the local-vs-global check; and the two to four more-effective ways with which one won, in a table — *Way considered* · *What it removes/adds* · *Cost vs. original* · *Riskiest assumption* · *Won?* (✅ / —). Close with a fenced methodology-trace line for the challenge canon refs.
- `<a id="l3-overview"></a>` **"1. Overview":** the locked build subject and the business Job it serves; the target segment(s) and the selected Core Jobs (canonical form plus success criteria); the Aha moment per segment (where it fires on the Delivery Chain, how far left it shifted, never signup or login); and, if the challenge changed the approach, one line on what was **not** built and why.
- **"2. Target users (by Job, not demographics)":** per segment — the causal criteria, the Core Jobs they hire us for, the dominant success criteria (direction plus level), and the Aspiration Job(s) above them (motivation). For B2B — the business Job and the personal Job for each relevant role, plus the role chain. Fenced trace (segmentation root, B2B role-chain).
- `<a id="l3-requirements"></a>` **"3. Functional requirements (the core)":** for each selected Core Job —
  - the Delivery Chain (the Sub-job sequence from §4.0, with shape marked and break sites marked, rendered as a small diagram or ordered list);
  - requirements phrased from the user's side ("User can {Sub-job}"), each with acceptance criteria equal to its success criteria (direction plus level) — and that is all the reader sees on the requirement line;
  - the Core Job → Aspiration Job · mechanic: {name} · Aha: {how it moves toward the moment} mapping lives in the **fenced trace**, not on the requirement line (name the mechanic, no canon path);
  - **onboarding → value activation**: the shortest path to the first Aha; what to remove or simplify to shift it left; and an Aha validity check — what does the user predict, what do they actually get, is the actual better than the prediction? If nothing is surprising, it is not an Aha;
  - **no feature dilution**: every requirement either serves the target segment or moves to §7 as deferred.
  - The fenced trace holds the per-requirement mappings plus canon refs (the value formula, criteria → mechanics, Aha placement).
- `<a id="l3-edge"></a>` **"4. Edge cases — ~90% across people, contexts, and conditions":** edge cases are where the Delivery Chain breaks or hands the customer a bad surprise (a Problem) under a real variation — not a generic QA checklist. Generate them from five sources, then cover the standard technical and operational categories as they hit the path:
  - **(a) Context variations** — the same outcome in a different context produces different success criteria, which is effectively a different Job. Enumerate the real contexts: new vs. returning; B2B roles; regulatory (HIPAA, FERPA, state-by-state); locale, device, language; scale (0 / 1 / many / 10,000 items); free vs. paid tier; first-time (heavy on the Orientation Job) vs. Nth-time.
  - **(b) Break sites** — hand-offs (ownership ambiguity, latency, information loss), cycles (sent back for rework), the slowest link, and external interruptions (a higher-priority task bursts in; the bar changes mid-walk; a competitor surfaces mid-walk).
  - **(c) Forced unwanted work when a step fails (Chore Jobs)** — the extra work shoved onto the customer when something breaks; each one is a Problem and a churn or abandonment trigger.
  - **(d) Job-type branches** — researching-and-choosing for first-timers (an Orientation Job); anxiety states (Emotional Jobs); a task done for or with someone else (a Viral Job); steps that exist only for a sub-context.
  - **(e) B2B role-chain breaks** (if B2B) — breaks at the role boundaries, mostly personal-Job failures (an IT security veto, a procurement or legal stall that lands late).
  - **Standard categories, framed as chain-breaks:** empty / oversized / malformed input; no, slow, or lost network; concurrency and conflicting operations; auth and permissions; payments (cancelled / partial refund / lapsed subscription / double charge); security (injection, unauthorized access, rate limits).
  - **Render it as a table** sorted by importance-driven severity (a high-importance break → same-day churn; a medium one → silent churn; a low one → the customer simply drops the Job). Columns: # · Use-case / context · Where in the Delivery Chain · What breaks (the Problem / Chore Job) · Severity (Critical / High / Med / Low) · Requirement to handle it.
  - Critical and High edge cases **become core requirements in §3**; Med and Low live here. Aim for about 90% coverage; if you cap, say what was dropped — no silent truncation. Fenced trace (break sites, context → criteria, Chore Jobs, severity by importance).
- **"5. Competitive parity (reused from upstream — don't re-mine in Quick mode)":** the functionality that has to match competitors; the functionality competitors close poorly, which is our wedge (the underserved intersection of success criteria); Deep mode refreshes this against live sites and reviews.
- **"6. Success metrics":** per Core Job, the success criteria translated into measurable activation and value-delivery metrics (the criteria *are* the metric set); the Aha-Moment rate (the share of new users who reach it, and how far left it fires); and the North Star — the target segment performing the Core Job at criteria, repeatedly.
- `<a id="l3-risk"></a>` **"7. Risk handling and out of scope":**
  - **Risks** — the RAT carried from upstream or generated here; for each risk, how the PRD minimizes or accounts for it, plus the single riskiest assumption to validate cheaply before build (kill the product, don't launch it; the MVP is a probe — name what it tests).
  - **Out of scope** — who this is explicitly **not** for (two or three groups); the Jobs and segments deliberately subtracted to hold focus; and the features deferred to a later phase.
  - Fenced trace (RAT, drop-it exercise, MVP-as-probe).
- **"8. Non-functional requirements (only when relevant)":** performance, security, scalability, compliance — each expressed against the part of the chain where it actually bites.
- `<a id="checklist"></a>` **"Verification & checklist":** note that the disclaimers sit at the top (once, not repeated here); then a verification checklist — validate the tagged user claims the PRD leaned on; run the §7 riskiest-assumption probe before building; confirm the Aha fires where claimed; and run a source-link audit (every named external source is a live, clickable link).

## S5 — Assemble, self-critic, summarize

Pass the draft through the self-critic (Quick mode does this as a self-critique pass; Deep mode hands it to a separate critic agent), fix problems in place, and keep the verdicts in context. Write the single result file. Then drop a short chat summary covering: the challenge's decision, the scope the PRD covers, the Aha Moment, the first riskiest assumption to validate, and the path to the file. Offer the handoff: pass this PRD on to `/go-to-market` for landing, ad, and GTM copy.

**Self-critic criteria** (methodology only — the template guarantees the format):

1. **No segment re-derivation** — the segment and Core Jobs were consumed or user-described, never discovered, sized, or scored here.
2. **Challenge ran first** — the goal was laddered, subtraction-first was asked, local-vs-global was named, and the PRD was written for the winning subject.
3. **Every feature ladders Core Job → Aspiration Job and names a value mechanic** — no bare features.
4. **The Aha Moment is a genuine positive-prediction-error event**, pushed as far toward the left of the chain as it will go — never signup, never login.
5. **The Delivery Chain is explicit per Core Job**, with both its shape and its break sites flagged.
6. **Edge cases derive from Delivery-Chain breaks and range across contexts**, roughly 90% coverage, ranked by importance-driven severity — not a one-size QA checklist.
7. **Success criteria are concrete** (direction plus level) and mapped to success metrics.
8. **The out-of-scope is spelled out**, naming both the anti-segment and the subtracted Jobs — the focus is on show.
9. **Disclaimers in place; every external source is a clickable link; US-context analogs used; no PPE/NPE** (write Aha Moment / Problem).
10. **Step ledger ran** — every stage S0–S5 is ticked off by name; any stage that got skipped (say the challenge shrank to a one-line confirm) was announced rather than left silent.
11. **User claims stayed hypotheses** — each ledger item wears a data / observation / hunch tag; no requirement, and no challenge verdict, leans mainly on one unverified hunch without flagging it; nothing from existing materials was folded in as a settled decision without confirmation.

**Checklist items** (boxes to tick):

- Plain-language-led (terms only in parentheses; Layer 3 is free to keep full terminology).
- Three layers present and correctly leveled (no conclusion repeated at the same depth).
- Drill-down links resolve and are unique (every target exists exactly once; no shared targets).
- Readable requirement is clean (what to build + acceptance criteria; the mapping is in the fenced trace; opaque Layer-3 headers carry an inline gloss).
- Disclaimers appear once (the full block at the top only; a one-line pointer in Layer 1; no repeat in Layer 3).
- Citations are fenced (no canon path or rule number inline in Layers 1–2 or in Layer 3 prose; no rule numbers anywhere; the mechanic name stays, the canon path does not).
- Step ledger ran (skips declared).
- Producer contract satisfied: helicopter view ahead of the first question; format and path both asked and honored; every input plus the upstream artifact handled as a hypothesis; the "What you gave me — and where it looks risky" block present; no scope leaning mainly on an unvalidated input without saying so and aiming a RAT row at it; the validation-debt line sitting in Layer 1; every go-style verdict written `GO (to validation)` and framed "validate first, then build"; for Paths A/B, the hand-off having verified which upstream debt had been cleared and re-tagged the remainder; in Deep mode, each web leg clearing its evidence floor and passing its self-critic, with the web-MCP fallback offered whenever a fetch was blocked.

## Deep mode (subagents + web)

Same S0 → S3 with the human; S4 is parallelized and web-grounded. Spawn agents with the Agent tool, `subagent_type: "general-purpose"`, `run_in_background: true`. Each agent reads only its own canon slice, delivers what it found inside its closing message (writing no files), keeps canon paths clear of its prose (the orchestrator fences those into Layer 3), and links every external source. The orchestrator holds all the returns and writes the single file.

**Waves:**

- **Wave 1 (parallel):**
  - **[PARITY] — competitor-parity refresh.** Only if the upstream parity is stale or absent. Reads only the eager core. Confirms or extends the parity table from live sites and reviews, marking what competitors close poorly (the wedge). Up to 8 fetches. Returns the table in its message.
  - **[CHAIN] — Delivery-Chain builder.** Reads the eager core (delivery-chain + job-structure) plus value-creation. Consumes the upstream chain (the Path A spec) and extends it with shapes and break sites; builds from scratch only on Paths B/D. Returns the chain in its message.
- **Wave 2 (sequential):**
  - **PRD designer.** Reads the eager core plus value-creation plus value-mechanics. Given the input, the challenge, the chain, and the parity return, writes the Layer-3 functionality (§0–§3, §5–§8). The readable requirement is what to build plus acceptance criteria; the Core Job → Aspiration Job · mechanic · Aha mapping goes in each requirement's fenced trace. Returns the Layer-3 body in its message.
- **Wave 3 (parallel):**
  - **[EDGE] — edge-case analyst.** Reads the eager core plus job-types (plus b2b only if B2B). Given the chain, the PRD body, and the web reviews, generates the ~90% edge-case table, chain-break-driven, with severity by importance. Returns the table in its message.
  - **[CRITIC] — adversarial self-critic.** Runs the self-critic criteria, including the layer and citation checks, and returns fix_instructions (up to 2 rounds, then escalate).
- **Orchestrator:** holds the returns; assembles Layer 3 (merging §3 with the Critical and High edge cases); applies the critic's fixes; fences the citations into trace lines; computes Layer 2, then Layer 1, **last**, wiring the drill-down links; writes the single file (disclaimers once → Layer 1 → Layer 2 → Layer 3); and gives the chat summary.

**Web caps:** parity up to 8 fetches; edge-case review mining up to 8. Source links are mandatory; never invent a source or a number.

**Deep-mode QA — the evidence floor, the per-leg self-critic loop, and the web-MCP fallback:**

- **Evidence floor.** Treat each web leg's lower bound as a floor, not just a ceiling — the PARITY and EDGE legs can't return "done" until each clears a real minimum of distinct sources or explicitly reports why fewer were possible (blocked, or none exist). "Made two queries and stopped" is a failure — re-run it.
- **Self-critic loop on each leg.** Once PARITY and EDGE return, CRITIC makes a quick pass: enough distinct sources? are the load-bearing claims each backed by a source? any slip in methodology — a feature missing its Core Job → Aspiration Job ladder or its mechanic, an Aha pinned to signup or login, or edge cases that read as a generic QA list instead of Delivery-Chain breaks? any gaps? When a leg falls short, send it back through with the gap spelled out (up to 2 more rounds); never assemble on a failed leg.
- **Web-MCP fallback.** Should the native fetch come back blocked, or too thin on a source you need (review aggregators, local competitor sites), tell the user once and switch to a connected web-research MCP (mention enabling a web-research MCP such as Firecrawl or Exa as live links). If one is connected (discoverable via tool search), prefer it for the blocked sources; otherwise carry on and flag the thin coverage in the checklist.

## What this skill does NOT do

- It does not re-derive segments or size markets → `/market-research`.
- It does not invent the value proposition or choose the target segment → `/value-prop` (it consumes the implementation spec).
- It does not write landing, ad, or GTM/growth copy → `/go-to-market`.
- It does not produce an analytics plan (out of scope) or a freestanding unit-economics model (unit economics is a reasoning filter in S3 and in the ranking only).
- It runs no interviews and executes none of the RATs itself — it only names the riskiest assumption to validate; running it is your next step.
- Quick mode uses no internet and no subagents.
