---
name: market-research
description: >-
  Researches a product or feature idea through the product method's Jobs To Be
  Done lens and returns a decision. Produces a one-page verdict (GO (to
  validation) / NARROW / PIVOT) backed by a deeper report: market sizing, the
  customer segments scored on a four-question go/no-go screen, competitors
  defined by the Jobs they perform, a differentiation hypothesis, an
  action-first risk plan, and a ranked set of strategic options that includes
  alternative markets the idea could pivot into. Fires whenever someone wants to
  size a market, surface or evaluate segments and the Jobs behind them, weigh up
  competitors, decide whether an idea is worth pursuing, or scout a pivot. Runs
  in two modes — Quick (default, no internet) and Deep (subagents plus web).
  Speaks plain language with method terms only in parentheses; defaults to
  English and follows the user's language.
user-invocable: true
---

> **In one breath.** Intake comes first and exists to close the gaps that would otherwise wreck the analysis. What you get back is a decision, not a brief: a one-page GO (to validation) / NARROW / PIVOT verdict, the candidate segments each scored on the same four go/no-go questions (the selection screen), the single make-or-break risk paired with the cheapest test that would falsify it, and a ranked list of strategic options — including other markets this exact idea could serve. Quick mode sizes the market once, with every assumption named out loud; the three-method averaging only happens in Deep mode.

> **Cross-cutting behaviours.** This skill follows `../PRODUCER-CONTRACT.md`. In short, that contract requires the skill to: (1) print a helicopter view of the whole run before it asks anything; (2) ask up front whether you want the result as Markdown or HTML; (3) treat every input you give as a hypothesis, not a fact, and hand back a "risks I see in what you gave me" block; (4) state the validation debt explicitly and always write `GO (to validation)`, never a bare `GO`; (5) accept a custom output path; (6) in Deep mode, meet an evidence floor, run a self-critic loop, and fall back to a web research MCP when the built-in fetch is blocked or thin.

> **Where to go next.** Brand-new idea you want to size and pressure-test → you're in the right place (`/market-research`). Live product whose metric just moved → `/diagnose`. You already have interview transcripts → `/analyze-interviews`. Decision made, ready to spec the build → `/product-requirements`. Need positioning or launch copy → `/value-prop`, then `/go-to-market`. Not sure which of these fits → `/advisor`.

---

## What this skill produces

One file. Three depths of reading inside it, wired together with links so you can drop down a level whenever you doubt a claim. The short answer leads; the deeper layers are opt-in.

- **Layer 1 — The Answer (~1 page, no method vocabulary, and on its own the complete answer).** The verdict, who to sell to first, why they'd buy, the one risk that decides everything, the next concrete move, and how big the prize is. Reads in about a minute. Forwardable to anyone. Every line carries a link down to where it's justified.
- **Layer 2 — The Reasoning (opt-in, two to four pages, plain English).** For each claim in Layer 1, how we arrived at it. Links keep going down to the full work.
- **Layer 3 — The Full Work (opt-in, the detailed report plus an appendix).** Market snapshot, the complete Segment Map, the differentiation hypothesis, the strategic recommendation with alternative Aspiration-Job markets for your assets, the action-first risk plan, and a sizing appendix you can re-check yourself.

On top of the file, the run ends with a short chat summary, Layer 1 reprinted inline, and concrete suggestions to rerun the skill on alternative markets.

Two ways to run it:

- **Quick (default, ~3–5 min).** No internet, no subagents. A single model fills the templates straight from reasoning.
- **Deep (opt-in).** Several web-enabled subagents populate those very templates, this time from live evidence.

---

## Methodology — the single source of truth

The only place the method comes from is the canon, read at runtime. The canon is loaded progressively: the core pages are read on every run; the rest are pulled in exactly when the run reaches the stage that needs them.

**Eager core — read on every run:**

| File | What it powers | ~tokens |
| --- | --- | --- |
| `product-method/canon/jobs/overview.md` | Jobs, the Job Map, value and the Aha Moment, segmentation, Choice Activators, the published value mechanics | ~13k |
| `product-method/canon/jobs/segmentation.md` | The deep segmentation method — the heart of this skill | ~5k |

**Staged — pulled in at the stage that uses them:**

| File | Load when | Used by | ~tokens |
| --- | --- | --- | --- |
| `product-method/canon/riskiest-assumption-test.md` | At the verdict + risk stage (Sections 4–5) | The RAT chain, verdict logic, pivot logic | ~6.5k |
| `product-method/canon/method-overview.md` | Once Section 4 reaches pivots and strategic options | How profit is reached along the chain, the local-versus-global optimum, the logic for choosing a segment | ~5.4k |
| `product-method/canon/jobs/value-mechanics.md` | At the differentiation / mechanic stage (Section 3) | The fuller menu of value mechanics | ~4.9k |

In **Quick** mode, begin with the two core files; bring in each staged file only once the run first arrives at the stage that depends on it. In **Deep** mode, each subagent reads only the slice for its wave: the sizing and competitor agents read the core only; the Strategy agent reads core plus RAT plus method-overview plus value-mechanics; the Pivot agent reads core plus method-overview. No agent loads outside its slice.

### Do not fall back on generic JTBD

The Jobs To Be Done used here is the method's version, and it diverges from the JTBD floating around the internet and in model training data. Do not let the popular defaults leak in. Five wrong defaults to actively block (these mirror the project's CLAUDE.md):

- **A Job is a desired transition.** State A (the situation someone is in) moves to an expected outcome, State B, in service of a higher-level Job. It is not "a struggle for progress."
- **Value is greater brain energy-efficiency at performing a Job, judged against the brain's own prediction.** The Aha Moment is the experience of value coming in above prediction; a Problem is value landing below prediction. Never reach for the prediction-error abbreviations — write Aha Moment and Problem.
- **"I want to + verb" names just one of a Job's eight elements** — it is not the Job in its entirety.
- **A Problem is a downstream effect:** it surfaces once a Solution hired for some Job misses that Job's success criteria. Treating it as the underlying cause is wrong.
- **A Solution is something that actually exists out in the world,** and within the Job Map it doubles as the name for the sub-graph of Core and Sub-jobs that it brings along.

**Methodological invariants — break any of these and the output is invalid:**

- Segments are formed by similar Core Jobs that share similar success criteria. They are never cut primarily by demographics, industry, or the Aspiration Job.
- A real segmentation criterion is a cause — a behaviour or a characteristic. It is never a paraphrase of a value or a consequence.
- What counts as a competitor is set by the Jobs at stake rather than by a product category: rivals on the Core Job are direct, and rivals on the Aspiration Job are indirect — among them "do nothing" and substitutes you wouldn't first think of.
- The success criteria together with whichever value mechanic you pick are what drive the features; you never start from the features and work backward.
- Every segment is scored on the selection screen, and the focus pick is justified on it.

---

## Plain-language output rule

The person reading the report is a product operator, not a methodologist. Write everything user-facing in the everyday language of the segment. When a method term truly makes a point sharper, open with the everyday meaning and tuck the term into parentheses on its first appearance. No sentence, bullet, or heading should ever open with a method label.

One illustration:

- **Wrong (jargon leads):** "The segment's indirect competitors on the Aspiration Job have eroded our differentiation hypothesis."
- **Right (plain leads, term earned in parens):** "Rivals copied the parts customers cared about, so the gap we'd be selling into has narrowed — the edge we were counting on shrank as competitors caught up."

**Who reads this.** The audience is US founders, solo builders and vibe-coders, PMs at growth-stage companies, senior PMs and product VPs, and people who do product marketing. Language that lands with them: reaching product-market fit, cash runway, changing course, a small market that actually pays, getting it out the door, the first customers who pay, a roadmap you can defend, a number that genuinely moves, how you're positioned, turning interest into sign-ups. Language that makes them leave: blitz-scaling, going 10x, hockey-stick curves, "battle-tested framework," growth hacking, hacking the funnel, listicle promises like "7 tricks to…," and anything that opens cold with jargon.

**Plain ↔ method glossary** (speak the left column; reach for the right-column term, set in parentheses, only where it pulls its weight):

- the outcome they actually want → the Job / the Aspiration Job
- the largest task the product completes by itself, top to bottom, as far up as it currently reaches → the Core Job
- the actual sequence of steps the customer moves through → the Delivery Chain
- the precise point at which they stall → a break in that chain
- the moment something clicks and beats their expectation → the Aha Moment
- a result for less time, effort, money, or stress than they expected → value
- the bad surprise when a tool does less than it should → a problem
- the few things they have to learn or believe before they'll switch → the Choice Activators
- a genuine blocker versus merely a worry → a Barrier versus a fear
- the belief that could sink the whole thing, checked first and on the cheap → the riskiest assumption (the Riskiest Assumption Test, RAT)

The phrases "Positive Prediction Error" and "Negative Prediction Error" are never to be written. Use Aha Moment and Problem instead.

Precision still rules underneath. The Job grammar discipline governs the internal reasoning, any debug notes, and any explicit method appendix. It just never surfaces as the lead the reader sees.

---

## The output file (one per run)

The skill writes exactly one file. Unless intake supplied a custom path, it lands under the product's own folder in the project root — never under a temp directory or `.claude/`:

```
method-results/{product-slug}/market-research/{YYYY-MM-DD_HH-MM}_{product-slug}-market-research-result.{md|html}
```

The extension follows the format you chose. Markdown is the default. HTML is a single self-contained file: inline CSS, working in-page anchors so the how-to-read jumps and every drill-down link resolve, `<details>` blocks collapsing Layers 2 and 3 and the method traces, and source links that open in a new tab. The HTML carries identical content to the Markdown. The skill never writes both.

A custom path means the one file goes there, with the same filename pattern. The 24-hour local timestamp keeps every run unique, so reruns never overwrite an earlier one.

Everything else — your raw inputs, the hypotheses that got discarded, the antisegment checks, the Aspiration-Job validation, the full sizing tables, the milestone notes, every method citation — stays in context and is never spilled into a separate file. Deep mode adds no intermediate files either: the subagents return their work in their final messages and the orchestrator writes the single result file.

---

## Stage 0 — Orientation (the helicopter view) and language

Before asking anything, print the orientation block:

- **What you'll get.** A single report carrying a GO (to validation) / NARROW / PIVOT call, the segment to go after first, the reason they'd buy, the risk that makes or breaks it, and how large the market is.
- **The steps.** (1) A few questions, (2) find and score the segments, (3) size the market, (4) pick where you can win and rank the strategic options, (5) one report written at three depths.
- **Where I work versus where you decide.** The model does the analysis and forms the hypotheses; you choose the direction and run the field validation.
- **Two modes.** Quick (fast, offline) or Deep (slower, web-backed).
- **Honest caveat.** What accelerates here is the reasoning, not the evidence. Treat each figure and each segment as a hypothesis right up until you've tested it with real customers.

Then settle the document language. The default is English. If you write in another language, offer a choice via AskUserQuestion (English / your language / Other) and hold whatever you pick. The canon files and the source URLs stay in their original language regardless.

---

## Stage 1 — The idea, the context, and the assets

**Step 0 — How much to ask (intake depth fork).** Ask this first, and keep it separate from the Quick/Deep research mode. Offer two options:

> - **Just the essentials.** I ask the three or four highest-value questions, then go. I infer or skip the rest. No separate assets capture or claims ledger up front — I surface a claims-and-risks pass after the first draft.
> - **The full interview.** A complete, multi-batch intake (Steps 1–7 below).

Whichever you choose, the research runs the same; all this branch decides is how many questions I put to you up front.

**Step 1 — The idea as a stream (free text, both paths).** One prompt: what is it, who is it for, what does it do for them, and what do you already have (technology, team, partners, traction)? In the full interview this is followed by two batched AskUserQuestion calls, at most four questions each.

**Step 2 — Batch 1 (both paths).** Mode (Quick / Deep); output format (Markdown default / HTML); stage (Idea / MVP / Launched / Scaling); country or market (US / UK / Russia-CIS / Global-English / Other); business type (B2C / B2B / Both / B2B2C — and B2B2C only when the channel genuinely runs through another business).

**Step 3 — Batch 2 (full interview; in essentials, inferred or skipped).**

- **Project context and materials.** A path, a URL, or Skip. Folders, files, a Notion export, spreadsheets, past research, interview notes, a strategy doc, the site. Quick mode reads local files; Deep mode also fetches URLs. Everything pulled in is tagged `[user data]`.
- **Hypothesized segments.** Describe them, let me find them (default), or Skip.
- **Known competitors.** List them, let me find them (default), or Skip.
- **Ambition.** Describe target revenue, margin, and timeframe, or Skip.
- **Where to save.** Default `method-results/{project}/market-research/…` or a custom folder. One file per run.

**Step 4 — Batch 2b: assets and constraints (full interview only).** This feeds the pivot work in Stage 9. One free-text prompt that captures the transferable assets and the hard constraints: (1) the core technology or unique capability; (2) the team's expertise and unfair advantages; (3) the resources in hand (money and runway, partners, traction, distribution, data, brand); (4) the hard constraints and non-negotiables (regulatory, geographic, ethical). If skipped, infer these from the idea stream and context and note in context that they were inferred.

**Step 5 — Adaptive clarifying questions (full interview; in essentials, at most the single gap that would flip the verdict).** Once Steps 1–4 are done, look for holes that would meaningfully shift the research, and put roughly five to seven pointed questions in a single batch — every one offering an outright "I don't have this info" choice. Leave out whatever you've already answered. Candidate gaps:

- **Local versus global** — and which local sources and competitors you already know about, since built-in web search routinely misses local players.
- **Segment specifics** — anything you know about who buys and why.
- **Sizing logic** — agree the calculation logic before computing anything: what the licensable or billable unit is, the real-world object it attaches to, and how it extrapolates. Propose it, then let you correct it.
- **What NOT to do** — any direction, segment, or framing you've taken off the table.

Answering "I don't have this info" is perfectly fine; that response is logged as a stated assumption, and whatever figure leans on it is flagged as an assumption instead of being fabricated.

**Step 6 — User-claims ledger and the input-as-hypothesis gate (a full-interview step; in essentials, folded into the post-draft pass).** Pull each firm factual claim from Steps 1–5, plus every load-bearing input drawn from the uploaded materials, into a ledger held in context. None of it counts as fact yet — it is all hypothesis. Tag each item by source: **data** (measured or documented), **observation** (seen in interviews or sales), or **hunch** (a belief — the default for a pitch deck, a landing page, or the idea stream). If the source is unclear, ask one batched question. Then actively hunt for the risks buried in the input: Is this customer-validated or just team belief? Does this capture the Job the customer truly has, or merely the team's projection onto them — the costliest mistake of all? Are there internal contradictions? Are guesses dressed up as data? This feeds the Layer 2 block "What you gave me, and the risks I see in it," with the single worst item lifted up into Layer 1.

Downstream rules: claims and materials stay tagged as hypotheses and are never silently merged into the analysis or baked into the wedge. Deep mode web-verifies the load-bearing claims (at most two fetches each — confirmed gets a citation, otherwise it keeps its tag). No verdict, target-segment pick, wedge, or pivot may rest primarily on a single unverified user input; if one does, the report says so out loud, names it as the single most expensive risk, and points the matching RAT row straight at it.

**Step 7 — Confirm the direction (both paths, before any research or agents run).** Play back your understanding in one short block: the product, the market (and local versus global), the hypothetical buyer, the existing assets, what's out of scope, and a one-sentence research direction. Ask one AskUserQuestion: Confirm or Correct. On Correct, update and re-confirm once. This is the cheapest possible moment to fix a wrong heading.

Hold all of it in context.

---

## The selection screen (four go/no-go questions)

The same four questions get applied to every segment and to each alternative market the pivot pipeline surfaces. Taken together they settle a single matter: among the tasks, and the segments behind them, which deserve our first push? Rate each reply strong / medium / weak, where more is better. And a single hard blocker is enough, by itself, to knock a segment out.

1. **Will the customer actually feel the added value?** Relative to how they handle it today, is there a value gap they'd notice? The wider that gap, the stronger the answer.
2. **Can the margin we're aiming for hold up?** Do the per-unit economics leave us the average margin we want on each paying customer — that is, their price or budget once you subtract what it costs to serve them?
3. **Can demand be made or taken?** Are we able to spark demand and actually reach these people, and how large and how reachable is the channel? The demand you can win equals the number of customers whose current tool has let them down and who are primed to move — so study what triggers a switch. A segment that is content and firmly locked in can't be won, no matter how big it appears.
4. **Is it big enough to scale?** In dollars: customers × average yearly spend on this task (their job budget).

**Hard blocker (pass / FAIL).** A legal or regulatory ban, or a technical impossibility of the fusion-energy-class kind (genuinely impossible, not merely hard). A FAIL removes the segment no matter how the four questions scored.

**How each segment renders.** A table titled "Why this segment, scored (the selection screen)" with columns Question / Rating / One line, one row per question (rating strong / medium / weak) plus an "Any hard blocker?" row (pass / FAIL), followed by a "Compose to focus?" line: Yes / on the edge / No, plus the binding constraint.

Pick as the target the segment that both stacks the four answers most in our favour **and** lines up best with what the idea's assets can actually deliver.

---

## Job grammar (every Job, every time)

Format:

> When **{context + trigger + the negative emotions felt beforehand}**, I want to **{expected outcome}** with success criteria **{concrete, measurable, in plain text}**, in order to **{the higher-level Job + the positive emotions afterwards}**.

The canon uses "in order to," not "so that." The "I want to" clause names the expected outcome — the primary Job element. Each infinitive verb is one Job; if a clause has several verbs, split it into a hierarchy.

Name the level every single time — Aspiration / Core / Sibling / Sub-job. Levels are relative to your product's reach, not absolute. **Core Jobs** are the highest-level Jobs the product performs in full; **Aspiration Jobs** are the motivation context one level above (and are not the root you segment on). The number of Core Jobs varies.

The **Aha Moment** lands when a customer feels a Core Job done above the success criteria they were braced for. Position it as far up the Delivery Chain as possible. Whatever the chain genuinely produces sets the ceiling on what positioning can claim — promise beyond that and you've engineered a Problem.

In any customer-facing question, use the everyday word "task," never "Job."

---

## Mandatory disclaimers (once, at the top of the file; never repeated below)

> **On the numbers.** Every numerical estimate in this report is generated by a language model and is a hypothesis. Each one names the assumptions it rests on and carries a verification path you can actually run (see the appendix). In Deep mode the sizing is built from three methods on real sources and averaged. Validate before you put money behind any of it.

> **On hallucination.** Everything here is model-generated and may contain errors anywhere in it. For any expensive decision, run full quantitative and qualitative research. Do not act on this report alone.

**Source links.** Every named source in the report and the appendix is a clickable Markdown link. When Quick mode runs offline, fall back to the most widely-recognized canonical URL or a "(URL TBD)" placeholder, then record that entry in the verification checklist.

---

## Readability rules

The report is three reading depths in one file, linked top to bottom. Most readers stop at Layer 1; a skeptic drops one level; an expert reads the bottom.

- **Each conclusion appears a single time within a layer — don't restate it at the same depth.** One risk shows up as a Layer 1 headline, a straightforward Layer 2 sentence, and a complete Layer 3 row — but never duplicated within one of those depths.
- **Drill-down links are mandatory.** Every doubtable Layer 1 claim links down to its Layer 2 anchor; every Layer 2 claim links down to the Layer 3 section that derives it. Use Markdown anchors — a `▸`-style link plus a matching unique `<a id="…">` placed just above the target.
- **Layer 1** leads with plain words and minimal jargon. A method term may appear in parentheses as a short gloss only when it helps. Never open a sentence with a raw term. Keep sentences short — explain it the way you'd explain it to a smart friend.
- **Layer 2** leads with plain language and glosses each term on first use in three to five words in parentheses. Nested or repeated parenthetical glosses are fine. Link `references/glossary.md` once at the top of Layer 2.
- **No internal method citations in Layers 1–2** — no canon file paths, no "Rule N."
- **Layer 3** may carry method citations, but fenced rather than inline: tuck canon references into a collapsed `▸ methodology trace` line that closes a subsection, kept visually apart from the main reading flow. Never break report prose with an inline citation, and never let a project-internal rule number appear in any layer.
- **Disclaimers appear once, at the top,** plus a one-line pointer in Layer 1. Don't repeat the block lower down.
- Keep the source links for external facts.

**Enforcement gate (run through every item before the file is written; the complete version lives in `../READABILITY-CONTRACT.md`):**

- **Unique, resolving anchors.** Each drill-down link has to target its own `<a id>` that occurs once and only once — no anchor is shared. Before you ship, enumerate the targets and verify each one resolves.
- **Inline gloss on opaque Layer 3 headers.** A non-obvious column header carries a three-to-six-word plain gloss right there (for example: job budget, ready to switch, reachability). Don't make the reader open the glossary file.
- **Segment depth across layers.** Layer 2 gives the target segment a partial profile — who they are, the task they're getting done, the thing that matters to them most, the reason they'd move — alongside a short strategic recommendation; the other leading candidates get only a light pass in Layer 2; and the complete Segment Map lives at full depth in Layer 3.
- **Validation plan across layers.** Layer 1 grazes it (the make-or-break risk and the next action); Layer 2 narrows to a list — each risky assumption set beside the way we'd test it; Layer 3 lays out the per-assumption steps in detail, anchored in the RAT.

---

## Report structure — three layers in one file

Assemble a single file with three reading depths linked top to bottom. Layer 1 is the whole answer for most readers; Layer 2 explains how each answer was reached; Layer 3 is the audit trail.

Sequence of the file: an attribution-free opening line plus the disclaimers (stated a single time) → a "How to read this (the three levels)" block → Layer 1 → Layer 2 → Layer 3. Derive Layers 1 and 2 **last**, working back from the completed Layer 3 analysis.

### How to read this (emitted once, after the disclaimers, before Layer 1)

A short, plain-language block (no method words) describing the three levels, each with a jump link:

- **Level 1 — The Answer.** One page. The whole answer. Most people stop here. [jump]
- **Level 2 — The Reasoning.** Optional. How we reached each answer, plus every assumption and how to check it. [jump]
- **Level 3 — The Full Work.** Optional. The audit trail: the full sizing with a do-it-yourself re-check, every segment at depth, the competitors, the strategy, and a step-by-step test plan. [jump]

### Layer 1 — The Answer (template — rebuild the prose, don't copy it)

- Anchor `layer-1`. H1: "{Product} — what the research says." Subtitle line: date · plain one-phrase market · stage.
- A one-line pointer: "these are hypotheses, not facts — see the full disclaimer."
- **The answer** (heading): the verdict in plain words (GO (to validation) / aim narrower / pivot), then two to four short, jargon-free sentences giving the single most important conclusion and the one binding constraint. The first GO (to validation) gets a half-line gloss — "worth the next step, which means checking it in the field, not building yet." Drill link.
- A **Validation debt** blockquote: this stands on N unvalidated assumptions, M of them fatal; the fatal ones get checked first. Drill link. A sub-note defines N (the risky assumptions in the RAT) and M (the fatal ones), and notes honestly that a Quick run on thin input carries high debt — say so.
- **Who to sell to** — the target segment in one plain sentence. Drill link.
- **Why they'd buy** — the value in one or two plain sentences (the concrete gain versus the current way). Drill link.
- **The one thing that decides everything** — the single make-or-break risk, stated plainly. Drill link.
- **Do this next** — one concrete next action. Drill link.
- **How big** — TAM / SAM / SOM in one plain line, plus whether size is the binding constraint. Drill link.

Layer 1 stays minimal-jargon, plain words leading, and every skeptic-doubtable line ends with a drill link.

### Layer 2 — The Reasoning (template)

Plain English, one gloss per term, glossary linked once at the top. No big tables — prose plus at most one small table. Each subsection carries its own `<a id>` that Layer 1 links to, and links down to Layer 3.

- Anchor `layer-2`. H1: "How we got here — the reasoning," with an italic intro line.
- Subsection `l2-input-risks` — "What you gave me, and the risks I see in it" (drop it only when there were no claims or materials). A table with columns: What you provided or claimed (tagged data / observation / hunch) / How I treated it / The risk I see / How to check it fast. Add a bold sentence if any wedge, segment, or verdict rests primarily on unvalidated input, pointing at its RAT row.
- Subsection `l2-verdict` — "Why '{verdict}', not a clean yes." The idea is tested by walking a chain: market → a customer who'll buy → real value → working economics → reachable. Name in plain words where the chain holds and where it breaks. Drill link.
- Subsection `l2-buyer` — "The buyer, in a bit more detail." A partial target-segment profile (who, their situation, what they're getting done, the dominant success criteria in plain words, why they'd switch) plus a brief strategic recommendation (one or two sentences). Then a short paragraph or a three-row table on the other top candidate segments (name, one line on who they are, why they ranked lower). Drill link to the full Segment Map.
- Subsection `l2-edge` — "The edge, in plain terms." What every existing option forces the customer to give up, and why ours doesn't. Drill link to the criteria × competitor matrix.
- Subsection `l2-risks` — "How we'd prove or kill this — every assumption and its check" (the heart of Layer 2). List every risky assumption across the chain (market → buyer → value → economics → reach), each paired with how we'd check it in one plain sentence. Order them by how-bad-if-wrong ÷ cost-to-check. Render as a compact two-column table: Assumption (in plain, falsifiable words) / How we'd find out fast. Drill link to the Layer 3 detailed plan.
- Subsection `l2-next` — "The plan, in order." The next moves as a short numbered list, in plain words — which assumption to test first, second, third, with one line on why that order (riskiest and cheapest-to-kill first). Drill link.
- Subsection — "If this market is too slow, where else this fits." The pivot markets, one plain sentence each. Drill link to the ranked pivots.

### Layer 3 — The Full Work

Anchor `layer-3`. The full report spans Sections 1–6 and the appendix. So Layers 1–2 can jump in, place an HTML anchor just above each section heading: `l3-segments` ahead of Section 2; `l3-differentiation` ahead of Section 3; `l3-verdict` and `l3-pivot` ahead of the matching pieces of Section 4; `l3-risks` ahead of Section 5; `l3-sizing` ahead of the appendix; and `disclaimers` ahead of Section 6. Method citations stay out of the prose, fenced within `▸ methodology trace` lines.

#### Section 1 — Market snapshot

Heading: "1. Market snapshot ({Country})." Then: "Market-level Aspiration Job:" {infinitive verb + noun, in plain words}.

A table with columns Metric / Estimate / How computed (one line); rows TAM (global), SAM ({Country}), SOM (one to two years). Quick mode shows one bottom-up calculation with its key assumption; Deep mode shows the figure averaged across three methods.

Then a landscape line (new market / red ocean / blue ocean / niche); an ambition-versus-share line (target revenue → needs Y% of SAM → ✅ <10% / ⚠️ 10–30% / ❌ >30%); and a takeaway (is the market big enough, and if not, what the binding constraint is instead).

Note that the sizing tables and the verification live in the appendix, and that the market-level Aspiration Job was validated in context rather than shown here.

**Sizing honesty.** Quick mode computes each figure once, bottom-up, on the logic agreed at intake, names every assumption, and marks it "estimate without data — verify via appendix." No fake three-method averaging out of the same reasoning. Three-method averaging (top-down / bottom-up / analog) happens only in Deep mode, each method on a real, linked source.

#### Section 2 — Segment Map (depth follows the verdict)

Comparison table first, then expand each segment. Depth tracks the verdict: a ✅ target gets a full block; a ⚠️ hold gets a half block (the recommendation line, the persona, the Core Jobs, the selection screen — skip the full size and competitor tables); a ❌ not-ours gets one paragraph (who they are, the single binding reason, coverage %).

Anchor `l3-segments`. Heading: "2. Who's in this market — the segments (Segment Map), covering ~80% of the total market."

The comparison table, columns: Segment / $ size per year / Job budget (yearly spend) / Ready to switch (how many hit a problem and would move) / Reachability (channel) / Verdict (✅ focus / ⚠️ hold / ❌ not ours). Note that the segments are grouped by similar Core Jobs and similar success criteria — not by vertical or demographics, and that the same vertical can split across segments. Order them ✅ → ⚠️ → ❌.

Each segment block (✅ first), at its earned depth:

- Heading: "{S#} — {a name tied to the Jobs and the real criteria} {✅/⚠️/❌}."
- A recommendation blockquote ("I propose we focus…" / "I'd hold off…" / "This isn't our segment…") — one or two sentences on how the four selection-screen answers compose, how many are ready to switch, and the binding constraint; plus "Coverage ~X% of total market customers."
- "Why this segment is attractive" — one short paragraph (motivation, urgency, willingness to pay, reachability). Never use the word "pain."
- "Persona" — one short paragraph as a story, then three to five inline causal-criteria bullets (the persona *is* the criteria; demographics are only second-order). Each bullet is a causal criterion plus a one-line cause — how it produces buying behaviour, value, margin, or acquisition.
- "Core Jobs" — numbered, in the customer's own words, in full Job grammar (When … I want to {expected outcome} with success criteria … in order to {Aspiration Job + positive emotions}).
- "Aspiration Jobs (the motivation context above the Core Jobs)" — Personal: I want to {verb}{noun} in order to {a life, status, or identity outcome}; Business (for B2B or hybrid): … in order to {a business outcome}.
- "Segment size + Job budget" — a table, columns Metric / Estimate; rows: people or companies in the segment, what one customer spends per year (the Job budget), total money in the segment per year (N × B), and the share ready to switch (%). Note: the sizing method and verification are in the appendix.
- The selection-screen table (per the section above).
- "Direct competitors (Core Job level, in this segment)" — table, columns Competitor / Core Jobs covered / Main message or USP / Covers poorly (by success criteria).
- "Indirect competitors (Aspiration Job level — other ways customers close this Aspiration Job)" — table, columns Way or solution / The Aspiration Job it closes / Why people use it / What it does poorly. Include rows for "do nothing / postpone" and "hire someone / an agency."
- "Who can do the whole job for them (turnkey, Aspiration-Job-level players)" — table, columns Player / How they close the Aspiration Job turnkey / Scaling capacity / Threat (low / med / high).

Close Section 2 with a cross-segment themes block (four to seven patterns that span the segments) and a one-line coverage-verification path: interview six to eight past payers, and if 30%+ don't fit any segment, add one.

#### Section 3 — Differentiation hypothesis (target segment)

Anchor `l3-differentiation`. Heading: "3. Differentiation hypothesis: target segment '{name}'."

- "Positioning (the Core Job → Aspiration Job link — headline first)" — a positioning blockquote: For {segment, with real criteria} who perform Core Job {…} in pursuit of Aspiration Job {…}, {Product} delivers {value via the chosen mechanic} so that {Aspiration Job} is achieved {faster / more reliably / without doing X / turnkey / with a guarantee}.
- "Why this segment" — one paragraph (ROI × opportunity cost × how the selection screen balances × fit with the assets).
- "Matrix: success criteria × competitors" — table, columns Core Job success criterion / Direct 1 / Direct 2 / Indirect (Aspiration-Job) / Our hypothesis. Cells ⚠️ / ❌ / ✅.
- "Underserved criteria — where we win" — the one to three success criteria that every competitor closes poorly (usually an intersection, not a single criterion).
- "Value-creation direction (one line, not a feature list)" — Mechanic direction: one published mechanic (from `product-method/canon/jobs/overview.md §22–§23` or `product-method/canon/jobs/value-mechanics.md`; most powerful when it applies — climb a level or kill a Job as a whole class) plus one sentence on how the customer's life gets more energy-efficient.
- A pointer blockquote: what to actually build to deliver this (features, delivery format, cost, the Aha Moment) is `/value-prop`'s job; this report stops at the underserved criteria and the mechanic direction.
- "Threat from Aspiration-Job-level players" — if turnkey players with scaling potential exist, how serious the threat is, and whether to partner with or displace them.

#### Section 4 — Strategic recommendation and pivot

Anchor `l3-verdict`. Heading: "4. Strategic recommendation and pivot options."

- "Verdict on the proposed segment + Jobs: GO (to validation) / NARROW / PIVOT" — walk the RAT cause-and-effect chain (Market → Segment + Jobs → Value → Unit economics → Channels), name the verdict and the binding constraint. GO (to validation) means the chain holds on the evidence so far and the next step is field validation, not a build. NARROW means it holds only for a sub-segment or sub-Job. PIVOT means an upstream link is broken and an alternative market scores better. Never a bare "GO."
- "Adjacent jobs you could capture next (Job switches within the segment)" — using the segment's Job Map: which Previous Job or Next Job to capture; whether to climb to a higher Aspiration Job (the most powerful mechanic); which Sibling Jobs to add.
- Anchor `l3-pivot`. "Alternative Aspiration-Job markets for your assets (ranked)" — generated by the pivot pipeline from the tech, team, and resources, scored on the same selection screen. Table, columns: Alternative Aspiration-Job market / Hypothesized segment + Core Jobs / Why your assets transfer / Selection-screen read (value · demand · margin · size × switch · risk-gate) / What changes versus the original (channel · UE · build) / Confidence (high / med / low).
- "Strategic options — top 3–5, ranked" — compose three to five concrete, runnable strategies from the full move space: stay and narrow to the strongest sub-segment; pivot to an alternative Aspiration-Job market; sequence markets (fund B from cash-flowing A); change the business model or pricing; capture the Previous or Next Job; climb to a higher Aspiration Job. Rank by expected return × confidence. Table, columns: # / Strategy (one sentence) / Why it can win (the mechanism) / Main risk / First cheapest step to validate. Note that each is a hypothesis with a validation step, and if a strategy rests on a ledger claim, name it.
- "Suggested reruns" — numbered: rerun this skill on {an alternative Aspiration-Job market} (and why); rerun with {a narrower segment / a different model / a different channel} (and why).

#### Section 5 — Risks and next moves (action-first RAT)

Anchor `l3-risks`. Heading: "5. Risks and next moves." Intro: we walked the whole package along the chain (Market → Segment + Jobs → Value → Unit economics → Channels); each assumption is stated in positive, falsifiable form and paired with the action that validates it; the goal is to falsify cheaply and kill or pivot before the build.

Table, columns: # / Risky assumption (positive form) / Why it's risky · cost if wrong / What to do to validate it (the action — the cheapest falsifying test). Around five rows; the top risk is usually Segment-and-Jobs or willingness-to-pay.

"Action plan — the next moves, in priority order" — numbered steps, cheapest and highest-leverage falsification first. Order by (P(wrong) × cost-if-wrong) ÷ cost-to-validate. Segment-and-Jobs validation usually comes first.

"Detailed validation plan — per assumption, step by step" (the heart of Layer 3). For each risky assumption (at least the top three or four), one block:

- **Method (per the canon)** — the right test for that risk type (for example: JTBD customer interviews about past behaviour for a Segment-and-Jobs risk; a fake-door or landing smoke test, or a priced letter-of-intent, for willingness-to-pay; a concierge or done-manually run for value-delivery; a back-test against historical data for a prediction risk) plus why it fits (the RAT — riskiest and cheapest-to-falsify first; interview real past Jobs, not hypotheticals).
- **Steps** — numbered: who to recruit and how many, what to ask or build, what to measure. Use "task," not "Job," in any customer question.
- **Kill criterion** — the specific falsifying result, with the threshold stated up front (narrow / pivot / stop).
- **Cost / time** — honest, with no artificial one-week cap.

Close with a fenced `▸ methodology trace` citing `product-method/canon/riskiest-assumption-test.md` and `product-method/canon/jobs/segmentation.md`.

#### Section 6 — Verification checklist

Emit `<a id="disclaimers"></a>` above the heading (Layer 1 links here). Do not repeat the full disclaimer — one italic pointer line: "*The disclaimers at the top of this file apply.*"

What the checklist asks you to do: work through the sizing verifications (in the appendix — Quick covers the lone calculation's assumptions, Deep covers the three-method tables); recruit six to eight prior payers from the target segment for JTBD interviews (phrase questions around tasks, never "Jobs"); verify that the segments cover the market and check the antisegment; test the tagged user claims the analysis rested on; carry out the Section 5 action plan; and audit the source links — confirming each named source is a live, clickable link and revisiting every "URL TBD" flag.

#### Appendix — market sizing and DIY re-check

Anchor `l3-sizing` above the heading (Layer 1's "How big" links here). The aim here is that any figure can be re-verified without taking our word for it: lay out the arithmetic, then supply a hands-on re-check the reader can run themselves — which source to visit, which number to grab, how to multiply them, and which outcome would confirm or sink it. Every named source is clickable; any source named without internet access gets a "(URL TBD — look this up)" flag.

**A. The calculations.** Give one tight block apiece for TAM, SAM, and SOM, and another for every segment's size plus its Job budget:

- **Figure** — the result.
- **Formula** — explicit arithmetic (for example, SOM = reachable buyers × annual price × win-rate).
- **Inputs** — a table, columns Input / Value / Where it came from / Assumption · confidence.

In Quick mode this is a single bottom-up calculation, assumptions spelled out, with no bogus three-method averaging. In Deep mode it becomes a tight table of three approaches (top-down / bottom-up / analog) — every approach tied to an actual linked source — together with the reconciled figure.

**B. Re-check it yourself.** For SOM and for each segment's size, a runnable recipe:

1. **Count the buyers** — go to the named source, pull the figure or apply the filter, and land near our input. Source types to choose from: official statistics, industry analysts, trade associations, company-count tools, public financials (include fresh generic links).
2. **Get the price** — competitor pricing pages, review-site plan tiers, procurement records, or quotes you've collected; compare to our annual price.
3. **Bound the win-rate** (SOM only) — reachable-via-your-channels × a conversion benchmark for your motion.
4. **Redo the multiply.** Confirm/break rule: landing within ~30% confirms the order of magnitude; being off by more than 2× means an input is wrong — challenge the weakest-tagged one first.

As for the Job budget: say where it can be checked — the line items the customer already pays for, the size of competitors' contracts, what interviews turn up — and name the single number worth asking for in a customer interview.

Stay concrete, and keep the links in. Someone should be able to rerun the math in roughly 20 minutes. Full input breakdowns stay in context.

---

## Methodology self-critic — checked before the report ships

Method only; the format is guaranteed by the templates, not re-checked here.

1. Segments are grouped by similar Core Jobs + similar success criteria — not by demographics, Aspiration Jobs, or industry.
2. The real criteria are causes (a behaviour or characteristic that explains value, margin, or acquisition), not paraphrased values or consequences.
3. The selection screen is applied to every segment and the focus pick is justified on it.
4. Switchability has been judged — the segment holds customers who are triggered, dissatisfied, and ready to move (it's the Problem that triggers them), rather than just locked-in creatures of habit.
5. Every Job follows the canon grammar — a single expected outcome per Job, with levels both named and set relative to the product.
6. Core and Aspiration are kept apart — Core being the topmost Job the product fully performs, Aspiration being the motivation sitting above it rather than the root you segment on.
7. The Aha Moment is placed where delivered value beats the expected criteria, and positioning promises only what the chain delivers.
8. What qualifies as a competitor follows from the Job at stake rather than from any product category — a rival is direct when it contests the Core Job and indirect when it contests the Aspiration Job (do-nothing and unexpected substitutes counted in).
9. The wedge consists of an underserved overlap of success criteria together with a single line of published-mechanic direction — and carries no list of features, since features belong to `/value-prop`.
10. The RAT walks the cause-and-effect chain; each risk is positive and falsifiable and paired with a validation action, riskiest-and-cheapest-first.
11. Pivot markets are evaluated on the same selection screen against the extracted assets, the existential-risk gate is applied, and each is a concrete Segment + Aspiration-Job pair.
12. User claims remained hypotheses — every load-bearing one labelled data / observation / hunch; no verdict, choice of target segment, or strategy leaning chiefly on one unverified hunch without flagging it; and any "I don't have this info" turned into a stated assumption instead of a made-up specific.
13. Strategic options are ranked hypotheses — three to five of them, every one carrying its mechanism, its primary risk, and the cheapest first step to validate it, and not one sounding like generic consultant boilerplate.

Then a checklist:

- [ ] **Plain-language-led** — each point the reader sees opens in their own words, with terms confined to parentheses.
- [ ] **Three layers present and correctly leveled** — no conclusion repeated at the same depth.
- [ ] **Drill-down links resolve and are unique** — every target exists exactly once; no shared targets.
- [ ] **Segment depth across layers** — the target is partially profiled in Layer 2 with a brief recommendation; others are touched on; the full Segment Map sits at depth in Layer 3.
- [ ] **Validation plan across layers** — Layer 1 grazes it; Layer 2 enumerates each assumption alongside its check; Layer 3 goes deep assumption-by-assumption (Method / Steps / Kill / Cost), rooted in the canon.
- [ ] **Opaque Layer 3 headers carry an inline plain gloss,** and the off-canon phrase "switchable demand" appears in no rendered header or row whatsoever.
- [ ] **Disclaimers appear a single time** — in full only at the top, with a pointer in Layer 1, and no restatement in Section 6.
- [ ] **Citations fenced** — no canon path or "Rule N" inline in Layers 1–2 or in Layer 3 prose; references sit in `▸ methodology trace` lines.
- [ ] **Step ledger ran** — every stage checked off by name; any skip declared, never silent.
- [ ] **Producer contract satisfied** (`../PRODUCER-CONTRACT.md`: helicopter view before intake; output format and path asked; if HTML, one self-contained file with resolving anchors and `<details>`; the "What you gave me, and the risks I see in it" block present unless nothing was supplied; the validation-debt line in Layer 1; every GO written as GO (to validation); Deep mode hit the evidence floor and ran the self-critic loop, or flagged thin coverage and offered the web MCP).

---

## Quick mode (default)

One model, no internet, no subagents. The sequence:

1. Hold all the user input in context (there is no input file) — the materials read in, the clarifying answers, the claims ledger, the confirmed direction.
2. Read the eager core (`overview.md` and `segmentation.md`), then pull each staged file (`riskiest-assumption-test.md`, `method-overview.md`, `value-mechanics.md`) the first time the run reaches its stage.
3. Construct Layer 3 first, directly from reasoning: market snapshot → Segment Map (all segments, each run through the selection screen) → differentiation → pivot (pull out the assets, produce three to five alternative Aspiration-Job markets, each carrying a segment + Jobs hypothesis, and score them on the selection screen) → strategic options (the top three to five, ranked) → action-first RAT → appendix. Drop in the section anchors.
4. Pass the self-critic over the draft, correct it in place, and hold the method trace fenced and in context.
5. Step ledger — tick off each stage by name before you write; announce any skip, and where it touches the verdict, secure the user's sign-off.
6. Derive Layer 2, and then Layer 1, **last** of all, out of the completed Layer 3, hooking the drill links to the Layer 3 anchors.
7. Write the single file (top disclaimers → Layer 1 → Layer 2 → Layer 3).
8. Chat: a brief outcome, Layer 1, the rerun suggestions, and the file path.

Quick mode has no internet, no subagents, and no quantitative validation — use Deep mode for those.

---

## Deep mode pipeline

This kicks in once the user selects Deep. A crew of web-enabled subagents populates those same templates from real data, and the whole thing runs end to end with no pauses.

**Principles.** It writes one file at the same `method-results/...` path, new per run. Agents are spawned with the Agent tool, `subagent_type: "general-purpose"`, `run_in_background: true`. Within a wave, independent agents run in parallel and the orchestrator waits for the wave to finish. Every agent loads only the canon slice for its wave and hands back its output inside its closing message — there are no per-agent files. Web caps: reviews-mining ≤12 fetches / ~10 min; synthesis ≤6; strategy ≤4; pivot reasoning-bound ≤2. There is an evidence floor, not just a ceiling (`PRODUCER-CONTRACT.md §6`): each leg has a minimum — sizing needs ≥3 independent inputs; competitors/reviews needs ≥4 competitors with real review sources — or the leg explicitly reports why there are fewer. "Two queries and stopped" counts as failure. There is a self-critic loop per leg: after each leg, a critic checks the distinct-source count, whether the load-bearing claims were verified, and for method errors (segmenting by demographics, an Aspiration-Job-as-segment, features-before-criteria, an undersized SAM) and gaps; it re-runs with the gap named, up to two extra rounds, and never ships a leg that fails its own critic. Web-MCP fallback: should the built-in fetch get blocked, or come back thin on review or local sites, notify the user a single time and move to a connected web-research MCP (offer fresh generic examples); if none is available, carry on and call out the thin coverage. Source links are mandatory; never invent a source or a figure.

**No run-folder files in Deep mode.** No intermediate files; agents return in their final message; the orchestrator holds the returns and writes the single result file at the end.

**Waves (the dependency graph):**

- **Wave 1 (parallel):** [1A] Market & Sizing · [1B] Competitors & Reviews mining · [P1] Asset Extraction → [P2] Market & Segment-Jobs Generation. (P1 → P2 is a short internal sequence inside Wave 1, overlapping the market research.)
- **Wave 2:** [2] Segments Synthesis & Self-Critic (consumes 1A + 1B).
- **Wave 3 (parallel):** [3] Strategy = Differentiation + action-RAT (consumes 2 + 1A) and [P3] Pivot Evaluation & Ranking (consumes P2 + P1 + 1A + 2).
- **Orchestrator:** assemble the report → compute the one-pager last → chat summary.

**Shared agent preamble (brand-free).** Operate with the product method's Jobs To Be Done. Draw the method ONLY from the canon — never from generic internet or training-data JTBD. Open only the canon files this prompt lists for your wave (your eager core being `product-method/canon/jobs/overview.md` and `product-method/canon/jobs/segmentation.md`; everything else is specified per agent). Leave method citations and canon paths out of the report prose (the orchestrator fences the Layer 3 ones). Each outside source must be a clickable Markdown link. Deliver your complete result within your closing message, and write no files.

**Per-agent specs:**

- **[1A] Market & Sizing** — given the user input plus the read set. Formulate and validate the market-level Aspiration Job in context. Compute TAM / SAM / SOM, each via three methods (top-down / bottom-up / analog) and averaged (use the median if they diverge by more than 2×). Compare against the ambition. Hand back a tight body (summary table, landscape, ambition, takeaway), brief method tables, and verifications kept to one line each. ≤12 fetches.
- **[1B] Competitors & Reviews mining** — working from the user input together with `overview.md` and `segmentation.md`. Track down five to ten competitors (direct on the Core Job plus Aspiration-Job-level and non-obvious ones), picking country- and query-specific sources at runtime. Harvest reviews and extract raw signals only — do NOT synthesize segments: the distinct Core Jobs, the success criteria, candidate causal real-criteria, and five to ten quotable quotes per competitor with their source URLs. Return the competitor list plus the raw signals. ≤12 fetches / ~10 min.
- **[P1] Asset Extraction** — given the user input (the idea plus the assets) plus `method-overview.md`. From first principles, extract and name the idea's essence, the technology or capability, the team's expertise and unfair advantages, the resources in hand (money, partners, traction, distribution, data, brand), and the hard constraints. Tag each as transferable or idea-specific. Return the asset inventory. No web.
- **[P2] Market & Segment-Jobs Generation** — given the P1 inventory plus the read set. Produce five to eight candidate Aspiration-Job markets in which the assets generate value, approached from varied angles (places the tech is applicable / places the team's know-how, access, and partners reach / neighbouring Aspiration Jobs / a level up). For each, also generate the Segment-and-Jobs hypothesis (a named target segment with causal criteria, its Core Jobs and success criteria, and which assets transfer). Depth is hypothesis, not deep research. Return the candidate markets. ≤2 fetches.
- **[2] Segments Synthesis & Self-Critic** — given the user input plus the 1A sizing plus the 1B returns plus the read set. Cluster the customers surfaced in the mined signals where Core Jobs, success criteria, and causal criteria align. Assemble every segment block following the Section 2 template (persona → Core Jobs → Aspiration Jobs → size + budget + switchable share → selection screen → competitors inline). Order ✅ → ⚠️ → ❌, with depth following the verdict. Include the cross-segment themes. Run the self-critic and fix in place. Keep the internal-only items (the Aspiration-Job validation, the antisegment causality, the discarded segments) in reasoning. Return the segment blocks plus short method tables.
- **[3] Strategy (Differentiation + action-RAT + strategic options)** — given the user input including the claims ledger plus 1A plus 2 plus the 1B signals plus the read set plus `value-mechanics.md`. Choose the target segment (how the selection screen composes, plus the fit with the assets). Generate Section 3 (positioning headline → why this segment → the criteria × competitors matrix → the underserved wedge → a one-line mechanic direction carrying NO feature list → the Aspiration-Job-level threat) and Section 5 (the action-first RAT on the chain plus a Step 1/2/3 action plan ordered by RAT priority, dropping any one-week constraint, plus the detailed per-assumption plan for the top three or four with Method / Steps / Kill / Cost-time). Also draft the strategic-options table (top three to five, ranked, from the full move space). Verify any load-bearing ledger claim (≤2 fetches); a strategy resting on an unverified claim must say so. Return Section 3, the options, and Section 5. ≤6 fetches.
- **[P3] Pivot Evaluation & Ranking** — given the P2 candidates plus the P1 assets plus the 1A sizing plus the 2 segments plus the read set. Score every candidate on the selection screen (added value · demand · margin · size × switchability · the existential-risk gate). Drop the gate-failures. Rank, and select the top three to five. Reuse the main-pipeline sizing on any overlap. For each pick, state what changes versus the original (channel · UE · build · which assets carry over) plus a confidence. Return the ranked pivot markets. ≤2 fetches.

**Orchestrator steps:** (1) hold the input, record the start time; (2) spawn Wave 1 in the background, wait, collect; (3) spawn Wave 2 with the Wave 1 returns, wait; (4) spawn Wave 3 in parallel, wait; (5) build the one file in three layers (disclaimers once up top → How to read → Layer 1 → Layer 2 → Layer 3, where Layer 3 runs Section 1 sizing → Section 2 segments → Section 3 differentiation → Section 4 covering within-segment switches, alternative markets, and strategic options → Section 5 action-RAT → Section 6 → Appendix), drop in the anchors, derive Layer 2 and then Layer 1 last while wiring the drill links, and fence the method citations; (6) Step ledger — check every wave and section off by name, declare any skips; (7) source-link audit, flagging anything bare or "URL TBD"; (8) chat output.

---

## End-of-run chat output (both modes)

Output only:

1. A short outcome in three to five lines — the verdict, the segment to focus on, the leading risk, and whether some pivot market now looks stronger than the one you started with.
2. Layer 1, printed verbatim.
3. Concrete rerun suggestions — for example: "Rerun this on the SMB-bookkeeping market, where your reconciliation engine (the core tech) transfers almost wholesale," or "Rerun on the same segment with a usage-based price instead of a seat license, since their spend scales with transaction volume."
4. The single result file path.

How to frame it: what we're after is a win for the entire business initiative rather than only the opening idea (local versus global optimum). Treat reruns as a first-class invitation, never a tacked-on extra.

---

## What this skill does NOT do

- It runs no quantitative survey of 300 to 500 respondents.
- No Customer Tiering analysis of an existing customer base.
- No full unit-economics model.

Those are separate skills. Quick mode has no internet, no subagents, and no quantitative validation. The skill does not pause mid-pipeline — Deep mode runs straight through. And it never invents sources or numbers: thin data is recorded as thin, never fabricated.
