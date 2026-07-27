---
name: value-prop
description: Builds the strongest testable value proposition for one chosen customer segment. Feed it a /market-research result file or a plain description of a segment and its main Jobs. It pulls out the success criteria the segment cares about most, lays down a Job Map plus Delivery Chain to reason over, generates value hypotheses by sweeping a catalog of value mechanics over that map, screens each one for buildability, cost, working unit economics and competitive win, then orders the survivors with RICE and puts forward a lead proposition alongside a fallback — each carrying the three highest-priority Riskiest Assumption Test cards plus a PRD-ready implementation spec that feeds /product-requirements. Two modes: Quick (default, offline) and Deep (subagents plus web competitor mining). Plain language, English by default.
user-invocable: true
---

# Value Proposition Builder

Generate the strongest, fastest, cheapest way to create real value for one segment — and the cheapest tests that tell you whether the bet holds. Local build, v1.

## New here? Pick the right door

- Brand-new idea, no segment chosen yet → `/market-research`
- A product is already live and a metric just moved → `/diagnose`
- You ran customer conversations and have transcripts → `/analyze-interviews`
- You know the value prop and want to build → `/product-requirements`
- You have the prop and need launch copy / positioning → this skill, then `/go-to-market`
- Not sure where you are → `/advisor`

This skill sits in the middle of the chain:

```
/market-research  →  /value-prop  →  /product-requirements  →  /go-to-market
   segment +          value             buildable PRD            landing page,
   Jobs +             hypothesis +                               ads, GTM copy
   why-win +          implementation
   competitors        spec
```

What each stage hands the next:

```
[market-research] segment + Jobs + why-we-win + competitor set
        │
        ▼
[value-prop]      value hypothesis + implementation spec  ◀── you are here
        │
        ▼
[product-requirements]   a PRD an engineer can build from
        │
        ▼
[go-to-market]    landing page / ad / launch copy
```

**The core gift here is invention, not validation.** Most tools help you check whether an idea is good. This one helps you *generate* the best idea in the first place — systematically searching for the strongest, fastest, and cheapest way to create value for the segment you chose. The Riskiest Assumption Test cards at the end are a genuine deliverable, but they are not what makes this skill different. The generation engine is.

**Output is a single file.** By default you see a short, plain one-page value proposition. Two deeper layers sit below it, collapsed, and open only if you want them.

## The three-layer output

Every run produces one document built in three depths. You read top-down and stop wherever you have what you need.

- **Layer 1 — the value proposition.** About one page. No methodology words at all. It states the nature of the thing, the customer it serves, the reason they would move to it, the single assumption that must hold, and the one next action to take. Each line carries a drill-down link into the reasoning that produced it. You can forward this to someone who has never heard of any of this and they will get it.
- **Layer 2 — the reasoning.** Opt-in. Plain English. For each claim in Layer 1 it explains how we got there: what this customer wants most, why you win, the before-and-after, the Aha Moment in everyday words, and the riskiest bet. Each piece links down to the work that produced it.
- **Layer 3 — the full work.** Opt-in and collapsed by default. Holds the value-move tables, the before-and-after comparison, the competitor matrix, the RAT cards, the PRD-ready implementation spec, and a methodology appendix.

## Producer behaviors (binding)

This skill follows the shared producer contract at `../PRODUCER-CONTRACT.md`. Six behaviors apply across the whole run:

1. Print a helicopter view of what is about to happen **before** the first question.
2. Ask whether the output should be Markdown or HTML.
3. Treat every piece of user input as a hypothesis, not a fact, and surface a "here are the risks I see in what you gave me" block.
4. Report the validation debt honestly. A green light is always phrased as `GO (to validation)`; the skill never tells anyone to "build it now" outright.
5. Allow the user to supply their own output path.
6. When running Deep mode, keep an evidence floor, loop a self-critic over the work, and switch to a web-research MCP if the built-in fetch is unavailable.

## The methodological spine

The only source of truth is the canon under `product-method/canon/`, read at runtime. Do **not** substitute generic internet or model-memory Jobs To Be Done — the definitions there are specific and the whole engine depends on them.

Five defaults the wider world gets wrong, and which this skill never repeats:

- **A Job is a desired transition.** It moves the customer from a starting state (State A) to an expected outcome (State B), *in order to* perform a higher-level Job. It is not "a struggle toward progress."
- **Value is brain energy-efficiency in performing a Job**, measured against what the brain predicted. The Aha Moment is the experience of value coming in *above* prediction; a Problem is value landing *below* it. Always write "Aha Moment" and "Problem" — never the two-letter abbreviations.
- **"I want to + verb" is one element of an eight-element Job, not the whole Job.** Each separate infinitive is its own Job.
- **A Problem is a consequence**, not a root cause — it is what happens when a Solution hired for a Job falls short of its success criteria.
- **A Solution is two things at once**: a real-world thing, and — inside the Job Map — a label for the sub-graph of Core and Sub-jobs it installs.

Invariants the skill **must** enforce. If any is violated, the output is invalid:

- Value follows `Probability of the Outcome × Outcome − Cost`. Three levers move it: raise the probability (guarantees, proof), raise the outcome (move up a level), or lower the cost (money, time, effort, cognitive load, negative emotion, Chore Jobs). Every hypothesis names which lever it pulls.
- Mechanics operate over a Job Map, never over a Core Job in isolation.
- What grounds a segment is a *shared set of Core Jobs and matching success criteria ranked in roughly the same order*. It is that ranking of the criteria that marks out one segment from another. Treat the Aspiration Job only as motivational backdrop — it is not the lead axis you segment on, and demographic traits matter even less.
- A habit will not yield to a frontal attack. Your only options are to ride it or to bypass it with an Aha Moment backed by loaded Choice Activators.
- An Aha Moment is one specific positive-prediction-error event. Signing up, logging in, or first touching a feature do not qualify. Put it as early in the Delivery Chain — as far to the left — as you can manage.
- Every switch runs through the Aspiration Job, so the value prop must be expressible through an Aspiration-Job criterion.
- The anti-segment must be nameable. If everyone wants this, the prop is too universal to be sharp.
- Treat unit economics as a screen. If the value can't be turned into margin — LTV failing to clear CAC, or a Job budget too small to cover what it costs to serve — then there is no product there.
- Risks compound. A prop resting on five or more unvalidated assumptions gets flagged.

Three house rules, stated plainly (no internal rule numbers ever appear in the output):

- Every named external source is a clickable Markdown link, `[Name](https://...)`.
- The numerical and hallucination disclaimers sit at the very top of the result file.
- Output is written for a US product audience, using US-context analogs.

## Plain-language output policy

The reader is a product person, not a methodologist. Write in the segment's everyday language. Where a methodology term truly sharpens the point, open with the everyday meaning and tuck the term into parentheses on its first appearance. No sentence, bullet, or heading should ever begin with a methodology label.

A quick illustration of the difference:

- Weak (jargon-first): "The Core Job's dominant success criterion is latency, so we apply a take-off mechanic across the Delivery Chain."
- Strong (plain-first): "These buyers care most about getting paid fast, so we cut three steps out of the part where they wait (the slowest stretch of the work)."

Lean on language like: product-market fit, cash runway, knowing when to pivot, a paying niche, get it shipped, the first customers who pay, a roadmap you can defend, moving one real metric, sharper positioning, turning visitors into buyers. Steer clear of: blitzscale, 10x, up-and-to-the-right, battle-tested framework, growth hacking, funnel tricks, listicle "hacks," and any line that opens on jargon.

Plain ↔ term gloss (lead with the plain phrase, term in parentheses once):

- the bigger result they are really after (Aspiration Job)
- the biggest end-to-end task the product handles on its own and can't currently beat (Core Job)
- the ordered run of steps that all have to go right (Delivery Chain)
- the step where they get stuck (a break in that chain)
- the first moment it works better than they expected (Aha Moment)
- getting the result for less time, effort, money, or stress than they braced for (value)
- the few things sitting in a buyer's head right before they switch (Choice Activators)
- a real blocker versus just a worry (Barrier vs fear)
- the assumption most likely to sink this, tested cheap and first (Riskiest Assumption Test, RAT)

Never write "Positive Prediction Error" or "Negative Prediction Error" — write Aha Moment and Problem. Never write "wedge" in the reader-facing text — write "why we win" or "the underserved criteria only you cover."

The full Job grammar still governs the internal reasoning and the methodology appendix in Layer 3. Only the surface the reader meets stays plain. Link `references/glossary.md` once, at the top of Layer 2.

## Readability rules

This skill follows the readability contract at `../READABILITY-CONTRACT.md`.

- Three escalating depths live in one file. State each conclusion once per layer and never twice at the same depth: a headline in Layer 1, a plain sentence in Layer 2, the full RAT card in Layer 3.
- Drill-down links are mandatory. Every doubtable Layer 1 claim carries a `▸` link to its Layer 2 anchor, and every Layer 2 claim links down to the Layer 3 part that derived it. Use Markdown anchors — `[text ▸](#l2-bet)` — with `<a id="l2-bet"></a>` placed directly above the target.
- Layer 1: minimal jargon, plain words lead, term only in parentheses as a gloss, never open a sentence with a raw term, short sentences. Translate sneaky business-speak too — "wedge" becomes "the one thing only we do," "bet" becomes "the one thing that has to be proven first."
- Layer 2: plain first, gloss each term in three to five words in parentheses on first use; nested glosses are fine.
- No internal methodology citations — no canon paths, no rule numbers — anywhere in Layers 1 or 2.
- Layer 3 may carry citations, but **fenced, never inline.** Each canon reference goes inside a collapsed "▸ methodology trace" sub-line that sits out of the reading flow. Do not break report prose with an inline "(canon §X)." The methodology appendix may keep one consolidated reference list; the body prose stays clean. Project-internal rule numbers appear in no layer.
- The disclaimers show up a single time, up top; Layer 1 only carries a one-line pointer back to them, and the full block is never restated down in Layer 3.
- Keep source links for any external fact.

**Enforcement gate — run before writing the file:**

- Unique resolving anchors. Every `▸` target must point to its own `<a id>` that exists exactly once. No two links share a target. (The known failure mode: two Layer 1 links aimed at the same anchor, or several Layer 3 anchors stacked on a single heading.) List every `▸` target and confirm each resolves to exactly one place.
- Opaque Layer 3 table headers get an inline three-to-six-word plain gloss right there in the header — do not make the reader open the glossary file.

## Where the methodology lives, and when to read it

The only source is the canon under `product-method/canon/`, read at runtime through relative paths. Do not load it all up front — read the eager core first, then pull each staged file only when the run actually reaches the stage that needs it. Ground only in the canon files listed below; never read or quote anything outside these sets.

**Eager core — read on every run, before any analysis:**

| File | What it powers | ~tokens |
|---|---|---|
| `product-method/canon/jobs/value-creation.md` | value formula (§3), the six cost dimensions (§8), success criteria (§9), the eight criteria-priority orders (§10), criteria→mechanics map (§11), Aha Moment (§12), move-up / kill-a-Job (§14), the no-interaction-ideal North Star (§20) — fixes the dominant criteria and primes the mechanic pool | ~8k |
| `product-method/canon/jobs/value-mechanics.md` | the roughly 26 foundational mechanics that make up the catalog S3 sweeps through | ~4.9k |

**Staged files — load only at the stage that needs them:**

| File | Load when | Used by | ~tokens |
|---|---|---|---|
| `product-method/canon/jobs/segmentation.md` | intake / S1 | what roots a segment; telling a sub-segment apart from a new one | ~5k |
| `product-method/canon/jobs/job-structure.md` | while assembling the S1 success-criteria list | eight Job elements, success criteria (direction + level), three fidelity levels | ~4k |
| `product-method/canon/jobs/delivery-chain.md` | building the graph substrate (S2 Aha placement) | Delivery Chain, breaks / cycles / hand-offs, Aha placement, Previous / Next Job | ~5k |
| `product-method/canon/jobs/behaviour-change.md` | forces / Aha stage (S3) | forces of behaviour change, Choice Activators, Class 1 / 2, habit reuse | ~6k |
| `product-method/canon/method-overview.md` | the S4 unit-economics screen | §4 on profit along the chain (LTV > CAC, payback, the margin you need per unit) and §5 (the segment's budget has to cover cost-to-serve) | ~5.4k |
| `product-method/canon/riskiest-assumption-test.md` | RAT-cards stage (S5) | RAT chain, RAT formula, custom risks | ~6.5k |
| `product-method/canon/the-algorithm.md` | strategic-spine framing (S0 routing / S6) | market → segment → value → de-risk spine | ~4k |
| `product-method/canon/jobs/communication.md` | synthesis (S6, one-liner) | one-liner formula, value-prop language | ~3k |
| `product-method/canon/jobs/job-map.md` | S2, whenever the graph substrate needs extra attention | levels, many-to-many relations, directional moves | ~5k |
| `product-method/canon/jobs/choice-activators.md` | Aspiration-Job communication / fear reduction depth (S3, S6) | Choice Activators, fear reduction | ~4k |

In **Quick mode** (one model): read the eager core at the start, then read each staged file the first time its stage comes up.

In **Deep mode**: each agent reads only its slice — `[S1]` gets eager core + segmentation + job-structure; `[S2]` gets delivery-chain (and job-map if needed); `[G*]` gets eager core + behaviour-change; `[F]` gets method-overview; `[RAT]` gets riskiest-assumption-test; `[SYN]` gets communication. No agent loads outside its slice.

## The pipeline: S0 → S6

```
S0  Intake & route        (human: input path, mode, target segment)
      │
S1  Dominant success criteria + anchors
      │  ── GATE-1
S2  Job-Map substrate     (Sub-jobs + Delivery Chain)
      │  ── GATE-2
S3  Value-hypothesis GENERATION   (diverge: strongest / fastest / cheapest)
      │  ── GATE-3
S4  Feasibility · cost · competitiveness FILTER + unit-econ + RICE  → top 1–2
      │  ── GATE-4
S5  De-risk               (RAT cards)
      │  ── GATE-5
      │  human picks PRIMARY vs SUPPLEMENTARY
S6  Synthesize the artifact
      │  ── GATE-6 (panel)
      ▼  human ships
```

Deep-mode parallelism: at S3, mechanic-family agents run in parallel alongside a reviews-mining agent; at S4, the competitor matrix is web-grounded.

This is the value-creation algorithm (the §11–§14 mechanics inside the the-algorithm.md spine) with method-overview §4 acting as the unit-economics filter and the Riskiest Assumption Test canon doing the de-risking. Structurally it is a chain of prompts, each meaningful stage closed by an evaluate-then-improve gate — not a free-roaming agent left to its own devices.

### How every GATE works

Every GATE works as a hostile pass/fail reviewer that must cite evidence and stays anchored in the canon. Quick mode runs it as self-critique; Deep mode hands it to a dedicated critic agent.

The verdict rule: the reviewer's job is to *refute* the output. For each criterion, find the strongest reason it **fails** before letting it pass. Default to REJECT whenever there is uncertainty. Pass only when there is a cited evidence span. The critic judges and instructs — it does not rewrite.

Per-criterion result: `{verdict: pass | fail, evidence: exact span, critique: specific and actionable}`. Overall result: `{overall: pass | fail, blocking: [...], fix_instructions: ordered changes}`. Binary only — no 1-to-5 scores.

Some checks are deterministic and code-style, not left to a model's judgment:

- Job grammar is exactly one "I want to + infinitive."
- Every external number carries a clickable link.
- Every hypothesis reads as `mechanic × Core Job × criterion × alternative` — never a bare feature.

Loop control: generate → judge → on pass it ships; on fail the `fix_instructions` feed back in. Maximum two rounds, then escalate to the user. If a round repeats a critique that the previous round already raised and left unresolved, escalate immediately. GATE verdicts stay in context; they never land in the user's file.

## The output file

The skill writes exactly one file. Default path (unless a custom path was given at intake, per contract §5), grouped under the product folder and never under a temp or `.claude` directory:

```
method-results/{product-slug}/value-prop/{YYYY-MM-DD_HH-MM}_{product-slug}-value-prop-result.{md|html}
```

The extension tracks the format you pick: `.md` as the default, or one stand-alone `.html` file (CSS inlined; in-page anchors that actually work for the how-to-read jumps and for every `▸` link; external links opening in a new tab). Either way the file leads with Layer 1 and keeps Layer 2 and Layer 3 collapsed inside `<details>` blocks — collapsed `<details>` still renders on the GitHub Markdown mirror. The HTML version also uses `<details>` for the methodology traces. Content is identical across formats; you never write both.

When a custom path is supplied, drop the single file there, still following the filename convention above.

All the rest — the cleaned-up input, the criteria ranking, the Job Map, the raw hypotheses, the scored shortlist, the RAT inventory, the hypotheses you discarded, and each GATE verdict — lives only in context. None of it becomes a separate file. The timestamp keeps each run unique. The disclaimers sit at the top of this file.

## Quick mode (default, ~10–15 min, offline)

One model. No internet, no subagents. The full S0 → S6 runs inline. Each GATE is a self-critique pass using the adversarial prompt. Feasibility and competitiveness are reasoning-grade.

Canon loading: pull the eager core up front and each staged file the first time it is needed. Order of construction: finish the Layer 3 work first (S0 → S6), derive Layer 2 from that, and only then derive Layer 1 from the completed Layer 3, threading the `▸` links onto the Layer 3 anchors. Lay the file out as: disclaimers once at the top → Layer 1 → Layer 2 → Layer 3.

### S0 — Intake & route

Print the helicopter view **before** any question (contract §1), in plain words. Cover, in your own framing:

- What you will get: one document holding the value proposition, the top three things worth testing, and a PRD-ready spec that feeds `/product-requirements`.
- The steps: a few questions → pull out what the customer wants most → generate options and filter them on feasibility, cost, unit economics, and competitiveness → rank, then surface a primary prop plus a back-up with test cards → one document in three depths.
- Where the skill does the work versus where you decide: the skill does the analysis, the invention, and the hypotheses; you pick the primary and you run the field validation.
- The two modes: Quick is offline, reasoning-only, about 10–15 minutes; Deep is opt-in, uses subagents and the web, takes longer, brings back real competitor and review data, and works best on a top model with a web-research MCP connected.
- The honest caveat: this speeds up the *thinking*, not the *proving*. Every prop is a hypothesis until you check it in the field.

**Ask the intake-depth question first** (via AskUserQuestion), independent of the research mode:

- "Just the essentials" — three to four load-bearing questions: input path · segment plus one to three main Jobs · business goal. Infer or defer the rest, and note anything skipped in the result.
- "The full interview" — the complete intake covering supplied materials, a claims ledger, any carried-over hand-off debt, and a direction check.

Regardless of which path is chosen, the engine assembles the complete eight-element Job structure under the hood.

**Language:** English unless told otherwise. Should the user write in some other language, offer that language through AskUserQuestion and return the report in it; the canon files and the source URLs are left untouched.

**Determine the input path.** Lead with the standalone path as a first-class option, not a fallback. Q1 via AskUserQuestion — "How do you want to start?":

- (a) describe the segment myself → path C, standalone manual
- (b) I have a `/market-research` result file → path A, load and parse
- (c) I want to run `/market-research` first → path B, hand off then return

**Path A:** ask for the result file path, Read it, parse the segment list. Q2 — which target segment(s): list the parsed segments and have the user pick one (recommended) or at most two; push back on three or more. Q3 — the active business goal: launch new / reposition existing / expand into a new segment / other.

Hand-off debt (contract §4c): the `/market-research` result arrived carrying validation debt in its RAT section. Ask once which of those assumptions have since been field-checked and what was learned. Confirmed ones become evidence (cite how they were checked); still-unchecked ones stay tagged unvalidated and flow into the S5 RAT cards. The debt travels down the chain — it is never quietly dropped.

**Path B:** if the market still feels fuzzy, encourage running `/market-research` first. Hand off, and offer to open its input prompt. Do not push it on someone who would rather just describe their segment — path C is fully supported.

**Path C (first-class):** gather everything in ordinary language. **Never** make the user phrase a Job in formal notation. Keep your questions plain-text and construct the eight-element Job structure yourself, behind the scenes. Required inputs:

- a one-to-two-sentence product description, plus a URL if there is one
- who it is for, described by what they do and how they are set up and what triggers their search — not by age or job title
- the one to three main things this customer is trying to get done, and how they would know it worked (plain words — you turn these into Core Jobs)
- the bigger result they are really chasing (Aspiration Job); for B2B, also the personal win for the decision-maker
- at least three known alternatives, with URLs
- the active business goal

Working from those plain answers, assemble the eight Job elements yourself — the context, the negative emotions, the Consideration Set, the trigger, the expected outcome, the success criteria, the positive emotions, and the higher-level Job — then test that structure against the invariants, all without ever exposing the formal grammar to the user. If something is missing or off, re-ask in plain words. For example, instead of "what is the success criterion's level on the latency axis?" ask "fast enough compared to what — what would count as too slow for them?" Flag reduced confidence at the top of the result: this prop was generated from a manual segment description, not a full `/market-research` run.

**Run options and output** — one batched AskUserQuestion so the common case stays frictionless:

- Mode: Quick (default) / Deep
- Output format: Markdown (default) / HTML
- Where to save: default `method-results/{project}/value-prop/…`, or a custom folder path; skipping keeps the default; one file per run.

**User materials, claims ledger, direction confirmation (all paths):**

- *Materials.* Ask once for any files or folders — a Notion export, past research, interview notes, a strategy doc, the current site, a deck, the codebase. Read what you are given and tag everything drawn from it `[user data]` in context. "Nothing" is a fine answer.
- *Input-as-hypothesis gate (contract §3).* Treat **all** input — the `/market-research` result, free-text claims, every deck, landing page, codebase, and past research doc — as hypothesis, never fact. A landing page is the team's *belief* about its value. A Job stated in a deck may be the team's *projection* of the customer, which is the most expensive error you can inherit. Actively hunt the risk inside each load-bearing input: is this customer-validated or a team belief? Does the stated Job or segment look like the real one? Are there internal contradictions, or guesses dressed up as data? What has to be true here, and is it actually checked? Keep what you find — it populates the Layer 2 block titled "What you provided, and where it might be wrong," and the single worst item gets promoted up into Layer 1. Do not quietly fold an unchecked input into the why-we-win or into the proposition.
- *User-claims ledger.* Pull together the firm factual claims and label each as **data**, **observation**, or **hunch** (default anything taken from a deck, a landing page, or an idea stream to hunch). Every claim arrives as a hypothesis. For GATE-4 competitiveness, an unverified claim counts as unsupported. Flag a lead proposition that leans mostly on a user hunch and aim a RAT card directly at it.
- *Hard gate.* Neither a value prop nor a why-we-win may lean primarily on an unvalidated user input unless the document admits it plainly and points a RAT card at it. When the why-we-win rests on a Job lifted from the user's own materials with no customer evidence behind it, call that out as the costliest risk of all.
- *Direction confirmation.* Ahead of S1, restate your understanding in one compact block — `{segment, Core Jobs, business goal, out-of-scope}` — and lock it down with a single AskUserQuestion: Confirm / Correct.

S0 output held in context: target segment plus causal criteria · Core Jobs (canonical, written with "in order to," not "so that") · Aspiration Jobs (plus the personal Aspiration Job for B2B) · known alternatives (direct · indirect · turnkey) · the `/market-research` why-we-win line plus the first mechanic guess (path A) · the captured materials and the claims ledger · the run mode · the chosen language · the business goal.

### S1 — Dominant success criteria + anchors → GATE-1

**Objective:** extract *every* success criterion from the segment's Core Jobs, sort each one across the six cost dimensions as well as the eight criteria-priority orders, narrow to the one-to-three dominant criteria that genuinely mark the segment out, and draw the §11 lead-mechanic shortlist.

Procedure:

1. Write out each success criterion found across the chosen Core Jobs. Give every one a direction (its axis — price, latency, comfort, privacy, and the like) and a level (the threshold beyond which value registers). Turn vague adjectives into concrete criteria. For example, "the payroll run should be reliable" becomes "every employee is paid the correct net amount on the scheduled day, with zero manual corrections after submission."
2. Label every criterion against a cost dimension (money / time / effort / cognitive load / negative emotion / Chore Jobs) and pin down which priority order the segment runs on — one of: price-first, speed-first, control-first, reliability-first, done-for-me-first, privacy-first, status-first, no-stress-first, or some blend of two or three of these.
3. Rank down to the dominant one to three and say **why** they dominate — drawn from the persona's causal criteria — not merely that they do.
4. Map them to lead mechanics via value-creation §11. For example, a reliability-first plus no-stress-first order tends to point at a guarantee-plus-done-for-you mechanic before it points at raw feature work. The shortlist seeds S3; it does not cap it.
5. Anchors: record the Aspiration-Job ladder (every dominant criterion climbs to an Aspiration-Job criterion), the set of alternatives, and the triggers that set this segment off.

Held in context out of S1: the ranked dominant criteria (direction + level) · the priority-order label · each criterion's cost dimension · the lead-mechanic shortlist · the Aspiration-Job ladder · the alternatives.

**GATE-1** (pass/fail, with cited evidence): the criteria are concrete — direction plus level — rather than adjectives; the dominant one-to-three are pinned with a causal reason instead of merely listed; every dominant criterion climbs to a named Aspiration-Job criterion; and the lead mechanics trace back to the §11 map matched to this priority order. Hard checks: each Core Job reduces to exactly one "I want to + infinitive," and every external figure is a clickable link.

### S2 — Job-Map substrate → GATE-2

**Objective:** lay down the surface that the mechanics act on — the Job Map sitting one level beneath the top one or two Core Jobs (the Sub-jobs done *in order to* carry out the Core Job), together with the Delivery Chain (that same graph laid along a time axis) with its break-points flagged. A mechanic always acts on a graph, never on an isolated Job.

For each of the top one to two Core Jobs (ranked by importance × frequency), generate the lower-level graph. Per the Jobs To Be Done methodology, lay out the Job Map one level below the Core Job, for `{segment + causal criteria}` and `{product + URL}`, given the Core Job in canonical When / I want to / in order to form with its success criteria. For every Job one level below, output: when `{context · trigger · loaded Choice Activators · negative emotions at State A}`, I want to `{expected outcome: verb + noun}`, with success criteria `{concrete, direction + level}`, in order to `{how it serves the Core Job above}`, plus any Problem(s) and a strength on a 1–10 scale. Produce five to ten lower-level Jobs as a sequence (or as parallel branches), then project them onto the Delivery Chain and mark: breaks · cycles · role hand-offs · time-gaps · Chore Jobs.

Output held in context: five to ten Sub-jobs per Core Job plus the Delivery Chain with its break-points flagged.

**GATE-2:** the nodes are real Jobs (verb form), anchored to something the customer has actually done before — not future-tense fantasy and no Fake Jobs; the Delivery Chain marks at least the break, cycle, and hand-off points; the levels carry names and are stated relative to the product; and at each node the question "for what? / in order to do what?" has a clear answer.

### S3 — Value-hypothesis GENERATION → GATE-3

This stage is the heart of the skill. Sweep the entire value-mechanics catalog across `(dominant criteria × Job Map × competitor weaknesses)`. In Quick mode, use the foundational mechanics; in Deep mode, go exhaustive — every mechanic against every applicable node. For each applicable mechanic, ask where on the graph it creates the most value against the dominant criteria, and what the strongest, fastest, cheapest way to deliver it is.

Generate the *way value is created*, concretely — name the delivery format (app, feature, done-for-you service, offline space, field service, guarantee, bundle, marketplace, concierge, content) rather than an abstract mechanic.

Lead with the two strongest mechanics — **move up a level** and **kill a Job** (value-creation §14) — and keep the no-interaction-ideal North Star (§20) in view: what would reaching the outcome with *no product to interact with at all* look like?

Drive toward the fastest, cheapest version. For every strong hypothesis, point to the least expensive way to deliver it that still triggers the Aha Moment — think concierge, no-code, or a thin slice of the value. For example, before building an automated reconciliation engine, a hypothesis might first prove its value as a single bookkeeper closing one client's books overnight on a shared sheet — same outcome, no software written yet.

Generate broadly — aim for twelve to twenty raw hypotheses. Drop the mechanics that do not apply and note them in context.

Each hypothesis takes a canonical form. Fill these fields: For `{segment}` performing `{Core Job + dominant criterion}`, we close it more efficiently by `{mechanic(s)}` applied to `{specific graph node}`, delivered as `{concrete product / service shape}`, which displaces `{alternative}` because `{its specific weakness}`. Lever: `{raise probability / raise outcome / lower cost}`. Aha Moment: `{the specific positive-prediction-error event}`.

Output held: twelve to twenty hypotheses in canonical form, each tagged with its mechanic family and value lever.

**GATE-3:** every hypothesis must read as `mechanic × Core Job × criterion × alternative`, not as "ship feature X"; its Aha Moment must be statable and must not be signup or login; it must work at Core-Job level or higher (the one exception being when fine polish itself is what wins this segment); habit must be reused or routed around rather than confronted; and the value must travel through an Aspiration-Job criterion. Hard check: no naked features — each must cite a mechanic plus the specific alternative it pushes out.

### S4 — Feasibility · cost · competitiveness filter + RICE → GATE-4

Take every hypothesis that survived and judge it on three fronts before ranking.

1. **Build feasibility and cost-to-implement.** What it actually takes to build. The cheapest viable path (concierge, no-code, vibe-coding, a partner) plus the cheapest probe that proves the value *before* the build. Flag any genuine uncertainty about whether it can be built at all — impossible versus merely hard.
2. **Unit-economics fit** (method-overview §4 used as a screen). Will the value actually turn into margin? Set cost-to-serve beside the segment's Job budget and its willingness-to-pay, and gut-check that LTV runs ahead of CAC. A delightful hypothesis that this segment can never be served profitably gets cut — or marked as a play for some *other* segment.
3. **Competitiveness.** Does it genuinely win against the field on the dominant criteria? Build out or extend the criteria × competitor matrix spanning direct (Core-Job), indirect (Aspiration-Job), and turnkey (Aspiration-Job-level) rivals. What you win on is an *under-served intersection of criteria*, not any one criterion alone. Quick mode reasons it through; Deep mode grounds it in real reviews pulled from the web.

**RICE-rank the survivors:**

- R (Reach) — the share of the target segment it applies to
- I (Impact) — the subjective value to one customer
- C (Confidence) — grounded in `/market-research` or canon evidence
- E (Effort) — what it costs to stand up the probe or MVP (less is better)
- a +1 strategic bonus when the mechanic happens to be move-up-a-level or kill-a-Job
- a +1 defensibility bonus when it steps out of head-to-head competition (Previous / Next Job, a graph shift, or value only you can offer)

Bring forward the leading two: a primary candidate and a supplementary one. That supplementary has to come at the problem from a real different angle — another mechanic family, another sub-segment, another spot on the chain, or a hedge against a different alternative — and it must **never** be just a sub-mechanic of the primary.

Held in context: the criteria × competitor matrix · for each hypothesis, its cheapest probe alongside the cost-to-build, the feasibility call, and the unit-econ read · the RICE table with its bonuses · the leading two, each with a one-line rationale.

**GATE-4:** the competitive claim must rest on real evidence about rivals — in Quick mode, the competitors are named along with the criteria each one handles badly; in Deep mode, reviews are cited — never bald assertion; cost-to-implement is estimated, and the cheapest probe is spelled out for the leading two; the unit-econ read holds up (the Job budget covers cost-to-serve and LTV > CAC is stated); the ranking arithmetic is laid out; the winner clears the alternatives on a *dominant* criterion rather than a side one; and the supplementary stands genuinely apart from the primary.

### S5 — De-risk (RAT cards) → GATE-5

Working from the Riskiest Assumption Test canon: take the chosen primary and catalog every assumption running along the RAT chain — Market / Segment+Jobs / Value / Unit-economics / Channels — together with the bespoke, product-specific risks (the places products really die). On path A, begin from the action-first RAT in the `/market-research` result's RAT section: bring those assumptions along, refresh them for the chosen value prop, and tack on the risks specific to this proposition. Do not stand up a rival inventory that contradicts it. On paths B and C, where there is no upstream RAT, build the inventory fresh.

Phrase each assumption as its evil twin, score them with `(P(wrong) × cost-if-wrong) / cost-to-validate`, and bring the top three forward in a tight five-line layout.

RAT card fields:

- a heading — "Risky assumption #N: {title}"
- **Bet** — what we are assuming, stated positively, one sentence, bound to a segment, price, and channel
- **Risk if wrong** — the evil twin, one sentence, in dollar terms
- **Probability × cost** — H/M/L × ~$X, with a one-line reason
- **Validate by** — the cheapest falsifying action and its timeline; the signal that confirms; the signal that kills

Hold the whole inventory plus the scoring arithmetic in context. Those three brought-forward cards land as §10 in the finished file.

**GATE-5:** assumptions are positive, falsifiable, and concrete (bound to segment, price, and channel — not slogans); at least one is a custom, product-specific risk; each is paired with the cheapest falsifying test (often cheaper than a probe); they are ranked cheapest-and-deadliest first; the Segment+Jobs or Value assumption sits near the top.

**Human gate** — pick primary versus supplementary via AskUserQuestion: A primary / B supplementary; B primary / A supplementary; keep only A; keep only B; neither (free-text → re-run S3–S4 on the new angle).

### S6 — Synthesize the artifact → GATE-6 → human ships

Put the single file together so the brief value proposition is what a reader sees first, with the deeper layers tucked below it as opt-in. Order in the file: the attribution-free disclaimers once at the top → a "How to read this" guide (the three levels plus jump links) → Layer 1, shown by default → Layer 2 → Layer 3.

Keep the lower layers behind a click: put each of Layer 2 and Layer 3 inside a collapsible `<details>` carrying a plain `<summary>`. A collapsed block still renders on the GitHub Markdown mirror and in HTML. The implementation spec — the PRD hand-off — remains complete inside Layer 3: collapse it, never trim it.

Derive Layers 1 and 2 **only after** Layer 3 is done, working back from it. Layer 3 carries the full substance — renamed and anchored — with each inline citation sealed into a methodology trace.

**Template (write fresh prose — do not copy any boilerplate):**

**Top of file, once, above Layer 1** — the two-part disclaimer block under an `<a id="disclaimers">` anchor:

- *Numerical disclaimer.* Every number here is a model-generated estimate, a hypothesis with a verification path attached, not a measurement. Validate before any major decision.
- *Hallucination disclaimer.* This was generated by a language model and may contain hallucinations. For expensive decisions, run a full research pass. Do not act on this document alone.

No attribution line.

**"How to read this"** — once, after the disclaimers, before Layer 1, in plain words. Three bullets:

- Level 1 — The value proposition (one page, plain). Jump: `#layer-1`.
- Level 2 — The reasoning (plain English). Jump: `#layer-2`.
- Level 3 — The full work (audit trail and build spec). Jump: `#layer-3`.

**Layer 1 — the value proposition (default view)**, under `<a id="layer-1">`:

- Heading: "{Product} — the value proposition." Subtitle: "{date} · {plain one-phrase segment} · {launch / reposition / expand}."
- A one-line "these are hypotheses, not facts" pointer linking to `#disclaimers`.
- A validation-debt line (contract §4): "Stands on {N} unvalidated assumptions, {M} of them fatal. The fatal ones are the first things to test before building." Link to `#l3-bet`. A subnote defines N and M and notes honestly that a thin Quick run carries high debt — say so.
- Sections, each a plain statement of fifteen words or fewer plus a `▸` drill-down link to its own unique Layer 2 anchor:
  - "What this actually is" → `#l2-value`
  - "Who it serves" → `#l2-segment`
  - "Why they'd move to it" → `#l2-wedge`
  - "The single bet that must hold" → `#l2-bet`
  - "Do this next" — one concrete next action, usually running the cheapest test of the bet; the skill never emits a "build it now" — the next step is always validate-first → `#l3-bet`
- Layer 1 reminder: minimal jargon, plain words lead, term only in parentheses; each line links to its own unique anchor (the bet and the next-action are *different* links); every doubtable line ends with a `▸` link.

**Layer 2 — The Reasoning**, under `<a id="layer-2">`: plain English, one gloss per term, glossary linked once at the top, no big tables (prose plus at most one small table), each subsection carrying an `<a id="l2-…">` anchor that Layer 1 links to and a link down to its Layer 3 part. No canon paths or rule numbers here. Subsections:

- `l2-input-risks` — "What you provided, and where it might be wrong." Note that all input is treated as hypothesis (contract §3). A table with columns: **What you provided / claimed** (tagged data / observation / hunch) | **How I treated it** | **The risk I see in it** | **How to check it fast**. If the why-we-win or the value prop rests primarily on an unvalidated input, say so in one bold sentence and point to the matching RAT card. Omit the block only if no claims or materials were given.
- `l2-value` — "What this segment actually wants most." The one to three dominant success criteria in plain words, plus why. Link to `#l3-value`.
- `l2-segment` — "Who they are — and how we know it's them." The causal criteria that pick this customer out (not demographics); why a demographic lookalike is a different customer. Link to `#l3-segment`.
- `l2-wedge` — "Why we win — what every alternative makes them give up." What each option (including doing nothing or DIY) forces them to sacrifice, and why ours does not (the underserved criteria only you cover); the before-and-after in one or two sentences; the Aha Moment in plain terms. Link to `#l3-wedge`.
- `l2-bet` — "The riskiest bet — and the cheapest way to find out." The single most-likely-to-kill assumption in one plain sentence; the cheapest confirming or killing test; what each result means; a note that the other bets are in the full list. Link to `#l3-bet`.

**Layer 3 — The Full Work**, under `<a id="layer-3">`: the full §0–§12 substance below the plain layers. Add HTML anchors above each linked part: `l3-value` (segment + dominant criteria, §1–§3), `l3-segment` (segment + Job statements, §1–§2), `l3-wedge` (differentiation + before/after + Aha, §4–§7), `l3-bet` (value hypothesis + RAT cards, §8–§10), `l3-spec` (implementation spec, §11), `checklist` (above the appendix / checklist). Keep citations out of the prose — fence them into `▸ methodology trace` lines. A confidence note at the top: on path C, the reduced-confidence flag; on path A, the name of the source `/market-research` file path. Sections:

- **§0 — Headline value statement.** A single line of fifteen words at most: [what it is] + [Core Jobs performed] + [value by criteria]. Alongside it, a fill-in-the-blanks sentence or two: For {segment} who {need}, {Product} is the {category} delivering {benefit}; where {alternative} falls short, it {differentiator}.
- **§1 — Target segment.** Who cares most — causal criteria, specific, not demographics. One short paragraph plus three to five causal-criterion bullets. Methodology-trace subline: the root of a segment is similar Core Jobs plus similar success criteria in a priority order (segmentation §2); demographics are second-order.
- **§2 — The job in the customer's own words.** Cast it as a Job story: "When {context + trigger}, I want to {expected outcome}, judged by {dominant criteria}, in order to {Aspiration Job}." That sentence is the Core Job.
- **§3 — Pains and Gains.** Pains, prioritized — the Problems and Chore Jobs the current Job Map produces, top three to five. Gains, prioritized — what beating the dominant criteria delivers, top three to five. Methodology-trace subline: dominant criteria, cost dimensions, priority order (value-creation §8–§11).
- **§4 — Before → After.** A table whose columns are: (row label) | **Current Job Map (alternative)** | **Our Job Map**. The rows: which Core Jobs get performed / what work the customer is still left doing (and what we kill, lift off, or collapse) / the outcome on the dominant criteria.
- **§5 — Our value: benefit themes.** Between three and five themes, each one a grouping of value-move applications spread over the graph. Every theme = a customer outcome paired with its "so what?". Name the value moves in plain language; the complete table sits in the §12 appendix.
- **§6 — Differentiation vs the competitive alternatives.** In the order positioning practice recommends: list the competitive alternatives, including "do nothing" and DIY; "Unlike {alternative + URL}, {Product} {differentiator on a dominant criterion}"; a table with columns **Dominant success criterion | Direct competitor | Indirect / Aspiration-Job | Turnkey | Us**, using coverage marks (✅ / ⚠️ / ❌); a "Why we win" line = the underserved intersection of criteria only we cover.
- **§7 — Proof and the Aha Moment.** The Aha Moment is the exact instant value first overshoots expectation — note where it lands on the Delivery Chain and how far left it has been pulled; it is **not** signup or login. For proof — how we make it true — give evidence, link to comparable cases, or name the cheapest probe. Methodology-trace subline: mechanics over the Job Map (value-creation §11); the strongest mechanics are move-up and kill-a-Job (§14); the Aha is a positive-prediction-error placed far left on the Delivery Chain (§12 + delivery-chain.md); every switch runs through the Aspiration Job (behaviour-change §4).

  *(divider — above this line is the proposition; below it is the bet and the build.)*

- **§8 — Value hypothesis (the riskiest bet, falsifiable).** Phrased as a claim that can be proven false: "Our bet is that {segment}, while performing {Core Job}, will {measurable outcome}, because {reason}." Then the what / who / how: what gets built, who is desperate for it, and how it reaches them.
- **§9 — Success metric and threshold.** Metric / Confirm at {threshold} / Kill below {threshold}.
- **§10 — The three bets most likely to kill this, and the cheapest tests.** The three compact RAT cards from S5. Methodology-trace subline: risks across Market / Segment+Jobs / Value / Unit-economics / Channels plus custom risks; ranked by (P(wrong) × cost-if-wrong) ÷ cost-to-validate (riskiest-assumption-test.md); risks compound (§1).
- **§11 — Implementation spec → /product-requirements** (under `l3-spec`). Note up front that this is the canonical input for `/product-requirements`. Bullets:
  - Product shape — what it IS: name + components + delivery format (app / service / offline / hybrid)
  - A Feature table with columns **Core Job / criterion | Mechanic | What we ship | Aha-Moment link**
  - Delivery Chain and Aha placement — the path the customer travels, the point at which the Aha goes off, and what you would strip out to pull it further left
  - Cost-to-build and the cheapest probe
  - Unit-economics direction — Job budget vs cost-to-serve; the pricing hypothesis; the LTV > CAC direction
  - Who this is NOT for — out of scope: two to three groups; the non-focal Jobs deferred
  - Methodology-trace subline: unit economics is a filter — value that does not convert to margin is not a product (method-overview §4); the budget covers cost-to-serve (§5)
- **§12 — Methodology appendix.** Mechanics applied (the combination) — a full table of Job × mechanic(s) × how the product performs it, typically five to twelve applications. The mapping from dominant criteria to the mechanics you used. The behaviour-change forces behind the primary: Added Value {lever} · Problems surfaced {how} · Fears {reduction lever} · Habit {reused or routed around, not fought}. **Canon references (consolidated)** — the single allowed flat list: value-creation.md (§3 formula, §11 map, §14 dominant mechanics), value-mechanics.md, the-algorithm.md, behaviour-change.md, delivery-chain.md, riskiest-assumption-test.md, method-overview.md §4.
- **Verification and checklist block** (under `checklist`). Note that the disclaimers at the top apply and are not repeated here. Include the self-validation checklist (the consolidated orchestrator checklist below).
- **"What this enables next":** (1) `/product-requirements` — feed the §11 implementation spec straight in; (2) `/go-to-market` — once the PRD exists, feed it plus this value prop to write the landing, ad, and GTM copy; (3) run RAT card #1 — do not build until #1 is validated or killed.

**GATE-6 (the final ship gate, run as a small k-of-N panel):** every methodology invariant must hold (the value formula; mechanics acting on the graph; the segmentation root; habit not confronted; the Aha being a real event; the value reaching through an Aspiration-Job criterion; a named anti-segment; the unit-econ screen applied); all three layers must be present and pitched at the right depth, with no conclusion restated at the same level; the drill-down links must all resolve (each `#l...` and `#disclaimers` target exists); the disclaimers must appear exactly once; citations must be fenced (no canon path or rule number sitting inline in Layers 1–2 or in Layer 3 prose; the consolidated §12 list is the sole flat list; no project rule numbers turn up anywhere); the phrasing must read US-native; Layer 1 must survive both the "so what?" check and the five-second check; the §11 spec must be truly PRD-ready and line up with `/product-requirements` inputs; every external source must be a clickable link with US-context analogs; and the human signs off and ships.

## Deep mode (~30–45 min, with internet)

The same S0 → S6 chain, with the substantive stages parallelized and web-grounded. Agents are spawned with the Agent tool, `subagent_type: "general-purpose"`, `run_in_background: true`. Each hands back its complete result inside its closing message — none of them write their own files. The orchestrator keeps those returns in context and produces the one file once everything is in. Each external source is rendered as a clickable link.

**Shared agent preamble** (put it in your own words): operate by the Jobs To Be Done methodology; draw ONLY on the canon files this prompt assigns to your wave (the eager core being `product-method/canon/jobs/value-creation.md` plus `…/value-mechanics.md`, the rest per agent); never lean on generic JTBD or prior training; never read past your slice; spell out "Aha Moment" and "Problem" rather than the two-letter abbreviations; keep methodology citations and canon paths out of the report prose, holding them in context so the orchestrator can fence them into `▸ methodology trace` lines down in Layer 3; turn every external source into a clickable Markdown link; and deliver your whole result in your closing message without writing any files.

**Deep-mode QA (contract §6):**

- *Evidence floor.* The web legs ([R], [F], [RAT]) have fetch caps, but the lower bound is also a *floor*: reviews and competitors → at least four competitors with real review sources; feasibility → a matrix grounded on cited reviews; or an explicit report of why fewer was possible. "Two queries and stop" counts as failure.
- *Self-critic loop per leg.* After each research leg, run a short critic: enough distinct sources? are the load-bearing claims verified against a source? any methodology error — segmenting by demographics, treating an Aspiration Job as the segment, putting features before criteria, ignoring unit economics? any gaps? Re-run with the gap named, up to two extra rounds, then escalate. Do not ship a leg that fails its own critic.
- *Web-MCP fallback.* If the built-in fetch is being blocked, or comes back thin, on a source you need — a reviews site, a comparison directory, a local-market site — say so once to the user and move over to a connected web-research MCP (Firecrawl or Exa, say, found through tool search). With none available, carry on and note the thin coverage in the checklist.

**Waves:**

```
Wave 0 (background from the start)
   [R] reviews-mining — independent, feeds S3 + S4

Wave 1 (sequential)
   [S1] dominant criteria  →  [S2] job-map substrate

Wave 2 (parallel sectioning)
   [G1..Gk] mechanic-family generators over the graph (consume R)

Wave 3 (sequential)
   [F] feasibility · cost · competitiveness + RICE (web-grounded matrix; consumes G* + R)

Wave 4 (parallel)
   [C] critic gates (GATE-1..GATE-5)   ·   [RAT] RAT-card generator
   → human picks primary vs supplementary

Wave 5 (sequential)
   [SYN] synthesis  →  GATE-6 panel  →  human ships
```

**Agent prompts** (objective · input · output · boundaries · effort budget; each returns in-message):

- **[R] reviews-mining.** With the segment and the alternatives in hand, pull reviews (G2, Reddit, Product Hunt, Trustpilot, Capterra). Hand back RAW signals only, no synthesized hypotheses: the concrete Problems-with-current, the dominant criteria each rival handles poorly, and five to ten quotable lines per competitor with their source URLs. Cap at 12 fetches / roughly 10 minutes. Evidence floor: at least 4 competitors, or a note on why fewer was possible. If a source blocks the built-in fetch, flag it and move to the web-research MCP.
- **[S1] dominant criteria.** Read eager core + segmentation.md + job-structure.md. Given the normalized input, return the ranked dominant criteria, the lead mechanics, and the Aspiration-Job ladder per S1. No web.
- **[S2] job-map.** Read delivery-chain.md (and job-map.md only if the substrate needs care). Given the input plus the S1 result, return the Job Map and Delivery Chain per S2. No web.
- **[G1..Gk] mechanic-family generators (sectioning).** Read eager core + behaviour-change.md. Every generator takes charge of one mechanic family — for instance: move-up / kill / subtract; chain-repair / done-for-you / take-off; need / expectation / emotion; cognitive / cost / price; link-to-Aspiration-Job / Next / Previous. Fed the Job Map, the dominant criteria, and the reviews signal, it returns that family's strongest / fastest / cheapest hypotheses in canonical form for the orchestrator to merge. Three to six hypotheses per family.
- **[F] feasibility · cost · competitiveness.** Read method-overview.md. Handed the merged hypotheses and the reviews signal, return a criteria × competitor matrix grounded on the web, a per-hypothesis read on feasibility, cost-to-build, and unit economics, and the bonus-adjusted RICE ranking together with the leading two. Cap at 6 fetches.
- **[C] critic gates.** Handed a stage's output, the acceptance criteria for it, and that stage's canon anchors, apply the hostile pass/fail critic defined for the GATE and hand back the verdict plus `fix_instructions`. At most 2 rounds, then escalate.
- **[RAT] RAT-card generator.** Read riskiest-assumption-test.md. With the chosen primary in hand, return the top three RAT cards, each carrying a web-checked estimate of what validation would cost. At most 3 fetches.
- **[SYN] synthesis.** Read communication.md. Taking every stage return, build the one file as the three layers (disclaimers once → Layer 1 → Layer 2 → Layer 3 = the §0–§12 work). Fold in the Layer 2 input-risks block and the Layer 1 validation-debt line (contract §3, §4). Place the Layer 3 anchors, then derive Layer 2 and after it Layer 1 — both LAST — threading the `▸` links. Seal each citation inside a `▸ methodology trace` line. Produce a self-contained `.html` when that format was picked (contract §2). Run GATE-6 as a panel.

As each wave finishes, report progress right there in the chat rather than into any log file.

## Methodology violations — auto-warnings

When the run trips one of these, emit a visible "⚠️ Methodology violation" warning — never swallow it silently. Use a table with columns **Violation | Detection | Skill response**:

| Violation | Detection | Skill response |
|---|---|---|
| Value prop is a feature | a phrasing like "we build {X feature}" carrying no mechanic and no alternative | What you have is a feature. A value prop reads as mechanic × Core Job × criterion × alternative — offer to recast it. |
| Mechanic not over the graph | a mechanic pinned to a Core Job on its own, with no graph node | A mechanic has to act on the Job Map; point to the graph node it lands on. |
| Aspiration Job as the segmentation root | a segment pinned to an Aspiration Job or to "customers who want X" | An Aspiration Job sets motivation, not the root. Segment instead on Core Jobs plus their ranked success criteria. |
| Fights habit head-on | neither a habit-reuse lever nor an Aha-Moment-plus-Choice-Activators plan is present | You can't take a habit on directly. Either reuse it or skirt it with an Aha Moment backed by loaded Choice Activators. |
| No anti-segment | you can't say who this is not for | There is an anti-segment for every value prop. Tighten the dominant criterion until one shows up. |
| Aha Moment = signup / login | pattern match | Signing up isn't an Aha Moment. Identify the first in-product event where the value runs ahead of expectation. |
| No feasibility / cost check | a surfaced prop lacking any cost-to-build and any unit-econ read | Bring in the cost-to-build plus the check of Job budget against cost-to-serve. |
| Competitiveness asserted, not grounded | a bare "we're better" with no criteria × competitor matrix behind it | Anchor it on the dominant criteria against named rivals (in Deep mode, cited reviews). |
| Stacks five or more assumptions | five or more unvalidated assumptions piled together | Risk multiplies. Five assumptions each 80% likely leave the whole stack roughly a one-in-three shot — drop one. |
| Two-letter prediction-error abbreviations | pattern match | Write "Aha Moment" and "Problem," never the abbreviations. |

## What this skill does not do

- It does **not** pick the target segment on path A — that is `/market-research`.
- It does **not** size the market → `/market-research`.
- Writing the PRD is not its job → `/product-requirements` (it passes along the §11 implementation spec); neither is writing landing, ad, or GTM copy → `/go-to-market`.
- It runs no customer interviews and executes none of the RATs — it produces the cards, and running RAT #1 is your next move.
- It does **not** generate the full multi-level Job Map above the Core Jobs — it builds one level *below* the Core Jobs, as the mechanics substrate.

## Execution checklist (orchestrator) — before writing the result file

- GATE-1 to GATE-5 each ran with verdicts kept in context, and the GATE-6 panel cleared.
- The dominant success criteria were pulled out and ranked (S1).
- A Job Map and Delivery Chain substrate exist, break-points flagged (S2).
- Somewhere between twelve and twenty raw hypotheses were produced by sweeping the mechanics across the graph (S3).
- The feasibility, cost-to-build, unit-econ, and competitiveness matrix is complete and RICE-ranked (S4).
- Primary and supplementary surfaced and distinct; the user picked the primary.
- Top-three RAT cards with confirm and kill signals (S5).
- All three layers are present and pitched at the right depth, no conclusion restated at the same level, with Layer 2 and then Layer 1 both derived LAST off the completed Layer 3.
- Drill-down links resolve (every `#l...` and `#disclaimers` target exists).
- Disclaimers once; every external source a clickable link; US-context analogs.
- Citations fenced (no canon path or rule label inline in Layers 1–2 or in Layer 3 prose; the §12 list is the only flat list).
- The §11 implementation spec is PRD-ready.
- No methodology invariant violated; the anti-segment is named; the Aha is a real event; habit is reused or sidestepped.
- Plain-language-led (Layers 1–2 and the Layer 3 prose lead in the reader's words; terms only in parentheses; §12 may stay in full terms).
- If path C: the reduced-confidence flag sits at the top of the result.
- Step ledger: each stage S0–S6 is ticked off by name, and any stage or gate that got skipped is stated to the user rather than passed over silently.
- User claims remained hypotheses: ledger entries carry a data / observation / hunch tag, and the primary prop never leans mainly on one unverified user hunch unless that is admitted outright.
- The producer contract is met (`../PRODUCER-CONTRACT.md`): a helicopter view ahead of intake; the output format and path both asked for; for HTML, a single self-contained `.html` whose anchors resolve and that uses `<details>`; the input-risks block included unless nothing was supplied; the validation-debt line sitting in Layer 1; the next step cast as validate-first rather than build, with no naked "build it now"; on a `/market-research` hand-off, the question of which validation debt has been cleared was asked and anything still open was re-tagged; and in Deep mode the evidence floor and self-critic loop were met (or thin coverage was flagged and the web MCP offered).
