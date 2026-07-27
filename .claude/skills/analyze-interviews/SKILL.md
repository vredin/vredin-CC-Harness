---
name: analyze-interviews
description: Takes one or many customer-interview files you already have and reconstructs the Jobs To Be Done structure hiding inside them. Asks which business task you are solving, then reads each interview in its own subagent (so large transcript sets never overflow context), assigns each interview an honest confidence and a quality read, clusters the extractions into segments by Core Jobs, computes a confidence level per segment, and writes one report covering data quality, segments and personas, current Solutions and their Problems, the Consideration Set per segment, value hypotheses, and what to interview next. Two modes: Quick (offline) and Deep (web-enriched). This is the after-fieldwork counterpart to the interview-guide flow.
user-invocable: true
---

# Analyze Interviews (v1)

**In one breath:** You hand over interviews you have already run. The skill first asks what business task you are trying to settle with them, because that decides what to dig for. It then fans out — one distiller subagent per interview (or per batch of short ones), so raw transcripts never pile up in a single context window and get summarized away. Each distiller reads its file plus the relevant slice of the method canon, extracts the Job structure, and reports back an honest confidence (a clean extraction is not the same thing as a thin hypothesis) along with a per-interview quality read. The orchestrator clusters those distillations into segments by grouping people who perform similar Core Jobs, judge success by similar criteria, and rank those criteria in a similar order. It then computes a confidence level for each segment from the interviews that support it. The result is one report: a data-quality summary, the segments with their personas, what people use today and where it breaks, the Consideration Set per segment, value hypotheses, and a list of what to interview next.

> **How this skill behaves — the producer contract.** Read `../PRODUCER-CONTRACT.md` for the cross-cutting rules every producer skill follows. The six you will see here: (1) it prints a helicopter view before asking the first question; (2) it asks whether you want Markdown or HTML; (3) it treats everything you give it as a hypothesis, not as fact, and emits a "risks in what you gave me" block — which here is the per-interview quality read; (4) it prints the validation framing, that extracted Jobs are hypotheses no stronger than the interviews behind them; (5) it accepts a custom output path; (6) in Deep mode it runs an evidence floor, a self-critic loop, and a web-MCP fallback.

> **Not sure this is the right door?** `/advisor` is the router — start there if you are unsure. Quick map: a brand-new idea with no product yet → `/market-research`; a live product or a metric that just moved → `/diagnose`; interviews already sitting in a folder → `/analyze-interviews` (you are here); ready to spec what to build → `/product-requirements`; positioning and launch → `/value-prop` → `/go-to-market`.

---

## Where this skill sits

This is the post-fieldwork half of the interview-guide canon flow. The interview-guide flow designs the study *before* you go into the field — who to recruit, what to ask, how to keep it free of leading questions. This skill picks up *after* the field: it takes the transcripts you came back with and reconstructs what is inside them.

Contrast it with `/market-research`. That skill invents candidate segments out of web evidence and reasoning, because there is no fieldwork to lean on yet. This skill does the opposite: it reconstructs the segments that the *real* interviews actually support, and it tells you, plainly, how far you can trust each one.

Downstream, its output feeds `/value-prop` (turn a solid segment and its value hypothesis into a proposition), `/diagnose` (when there is a live product whose metrics need fixing), and `/go-to-market` (positioning and launch once value and segment are validated).

| Skill | Input | Answers |
|---|---|---|
| interview-guide flow | A segment plus a Job hypothesis you want to test | How to run the study before you go into the field |
| analyze-interviews | Interview files you already have | What is actually in them, which segments emerge by Core Jobs, and whether the data can answer your task |
| `/market-research` | An idea or a product | Market size plus a GO / NARROW / PIVOT call, with segments invented from evidence |

---

## What this skill produces

**One file per run.** It contains:

1. **Data-quality summary** — how many files were analyzed, the mix of types and quality levels, and a straight answer to whether this set can serve the task you named.
2. **Segments by Core Jobs** — each one with a persona expressed as causal criteria, the Core Jobs written in the canon's Job grammar, the Aspiration Jobs above them, a confidence level, and the interviews that support it.
3. **What they use today and where it falls short** — for every tool people hired: the tasks that tool does for them, and each shortfall traced along the chain task → tool → problem. When someone just did it themselves, that DIY route is a tool too.
4. **What they weighed before choosing** — the alternatives they weighed, how each stacks up, the named products and the way in to each, and the fears in the back of their mind. This is their Consideration Set, rendered as its own block.
5. **Value-creation hypotheses** — the underserved success criteria, each with a one-line direction for a mechanic that could serve them. No feature list; turning these into features is `/value-prop`'s job.
6. **Per-interview appendix** — one entry per file: what was extracted, the anchor quotes, and the confidence.
7. **Gaps and what to interview next** — the task questions this data cannot answer, and who to re-recruit (screened on a real past payment) to answer them.

**Two modes:**
- **Quick** (default, offline) — distiller subagents read each interview and return a compact distillation; one orchestrator synthesizes them into the report. No network.
- **Deep** (opt-in, longer) — everything Quick does, plus a wave of web subagents that enrich the competitor picture, fill out the Consideration Set, and mine real review language. Web evidence annotates the interview findings; it never overrides them.

---

## Methodology — the source of truth

The **only** source of method here is the product-method canon, read at runtime. Do not lean on generic internet or training-data JTBD — this method diverges from it in specific ways (spelled out below). Do not load the whole canon up front. Read the eager core first, then pull the staged files at the moment a stage actually needs them.

**Eager core — read before anything else:**

| File | What it powers | ~tokens |
|---|---|---|
| `product-method/canon/jobs/overview.md` | The whole model: Job, Job Map, value, Aha Moment, and the root of segmentation | ~13k |
| `product-method/canon/jobs/segmentation.md` | Clustering interviews into segments; causal vs symptomatic criteria; persona = causal criteria | ~5k |

**Every distiller subagent reads:**

| File | Why | ~tokens |
|---|---|---|
| `product-method/canon/jobs/job-structure.md` | The eight Job elements, the extraction question for each, and the quality signals | ~9k |
| `product-method/canon/jobs/job-types.md` | Typing the Job (Chore / Orientation / Emotional / Viral / Regular) and the Fake-Job past-behaviour test | ~5k |

**Staged files — pull only when the stage hits:**

| File | Load when | Used by | ~tokens |
|---|---|---|---|
| `product-method/canon/jobs/choice-activators.md` | When you build each segment's Consideration Set | The five Choice Activators plus the four-slot container | ~4k |
| `product-method/canon/jobs/delivery-chain.md` | The task is conversion, retention, or acquisition | Previous and Next Jobs, chain breaks, Aha placement | ~6k |
| `product-method/canon/jobs/behaviour-change.md` | Extracting switching barriers and fears | Habit, Solution-as-label, blockers, and fears | ~10k |
| `product-method/canon/jobs/value-mechanics.md` | When you draft the value hypotheses (Section 5) | The mechanic menu | ~5k |

**Path fallback.** If a canon file is not found at the path above, retry once with a numeric folder-prefix variant of the same path (an ordering artifact in some copies of the repo). If it still is not found, say so plainly rather than guessing.

### Do NOT use generic internet or training JTBD

This method's definitions are specific. Use these, not the looser ones in circulation:

- A **Job** is a desired transition: from State A (the situation now) to an expected outcome (State B), undertaken in order to perform a higher-level Job. It is not "a struggle for progress."
- **"I want to + verb"** is only the *primary element* within a Job's eight elements — not the entire Job. Every infinitive verb points to its own distinct Job. If a person chains several verbs together, break the statement out into the hierarchy instead of reading it as a single Job.
- A **Problem** is the consequence of a Solution that was hired for a Job and is underperforming that Job's success criteria. It is not a root cause.
- **Value** is greater brain energy-efficiency in performing a Job, relative to what the person predicted. The **Aha Moment** is the experience of value beating that prediction; a **Problem** is value falling below it. (Do not invent any PPE/NPE-style abbreviations for these.)
- A **Solution** is two things at once: a real thing in the world, and — inside the Job Map — a label standing in for the sub-graph of Core and Sub-jobs it installs. Doing it yourself ("I just did it myself") is a Solution too.

### Methodological invariants — the output is invalid if any is violated

- **Segments cohere around Core Jobs that look alike, are judged by comparable success criteria, and rank those criteria in roughly the same order** — and never around demographics, industry, or an Aspiration Job used as the top-level cut. Two people on the same surface Job, one ranking speed first and the other ranking no-stress first, belong to different segments.
- A **causal segmentation criterion** is, by definition, a *cause* — some behaviour or trait that shifts value, margin, or demand. It is never a value restated, and never a downstream effect.
- Study Jobs through **past expenditure** (money, time, energy actually spent), never through future intent. Future intent with no past commitment behind it is a **Fake Job** — extract the **Aspiration Job** it sits under, never the Fake Job itself.
- **Personas are causal criteria.** Demographics only ever ride along as second-order correlates — they are never where you make the first cut.

---

## Fan-out: how distillation scales

The orchestrator keeps raw transcripts out of its own window entirely. Instead it launches **one distiller subagent for each interview** — or groups three to four short files under a single distiller. A distiller takes in its assigned file together with the matching canon slice and hands back nothing but a tight, structured distillation (about 600–1,200 tokens, keeping two to three anchor quotes word-for-word), never the source text. Segments are then assembled by the orchestrator from those distillations alone.

**Why this matters.** Suppose you have twenty hour-long interviews. Transcribed, each one runs eight to ten thousand tokens; the set as a whole is well past a 200k window. If you fed them in directly, the context would compact, and compaction is exactly the operation that throws away verbatim utterances — the one thing you most need to keep. Fan-out sidesteps this: each transcript is compressed to a distillation at the edge, so the orchestrator only ever holds twenty small structured returns, which fit comfortably, and the exact quotes survive because the distiller is told to keep them on purpose. A concurrency cap runs the files in waves rather than all at once.

Distillers run with the subagent (Agent) tool, the general-purpose type, background = true. The orchestrator waits for each wave, collects the returns, then launches the next wave.

**No per-interview files are written.** Each distiller hands back its distillation in its final message. The orchestrator holds those in context and writes a single report.

---

## Plain-language output

Write in the user's plain language. When a method term truly sharpens the point, state the everyday meaning first and tuck the term into parentheses the first time it appears — never open a sentence or a heading with a raw term. Keep quotes verbatim. Report confidence in plain words — **clean read**, **directional**, **weak**, **not usable** — and keep the rubric behind those words visible so the reader can see why a thing scored as it did.

---

## The output file

**Exactly one file per run.** Default path:

```
method-results/{product-slug}/analyze-interviews/{YYYY-MM-DD_HH-MM}_{product-slug}-analyze-interviews-result.{md|html}
```

The extension follows the chosen format: `.md` by default, or a single self-contained `.html` file (inline CSS, working in-page anchor links, collapsible `<details>` blocks for the appendix and the longer segment sections, source links set to open in a new tab). The HTML carries identical content to the Markdown — never write both.

If the user gives a custom path, write the one file there, keeping the same filename pattern.

The timestamp is local 24-hour time and makes each run unique, so a rerun never overwrites an earlier result.

All internal traces — the distillations, clusters you considered and discarded, the climb from a Fake Job up to its Aspiration Job — stay in context. They never go into a separate file.

**Disclaimers at the top of the file, stated once.** Two callouts:

- **Numerical disclaimer.** Every number in the report — confidence levels, segment sizes, Job budgets, the confidence scores themselves — is an estimate produced by a language model. It is a reading, not a measurement. Validate before any expensive decision rests on it.
- **Hallucination disclaimer.** This report is generated by a language model and may contain Jobs that were read into a transcript rather than truly present. Before a costly decision, re-read the anchor quotes and run a confirming pass of interviews.

---

## Stage 0 — Orientation and language

**Before any question**, print an orientation block in plain words. Cover, in your own phrasing:

- **What you'll get.** One report. It surfaces the segments hiding inside your interviews, grouped by what people hire a product to do. Each segment comes with a persona, the solutions they use now and where those fall short, what they weigh before choosing, some value ideas, and an honest read on how far the interviews can be trusted.
- **The steps.** (1) Name the business task. (2) Show me where the files are. (3) Working through each interview separately, I surface the tasks people are hiring for and attach an honest confidence to each. (4) For every interview I report back what surfaced and what stayed missing. (5) I group the interviews into segments and tell you which ones the evidence genuinely backs. (6) I produce a single report along with a list of who and what to interview next.
- **My lane versus your call.** What I do is pull out and cluster only what the interviews actually contain; I never invent. I flag the thin spots and tell you what to ask next — but the call on what to do about them is yours.
- **Two modes.** Quick is offline. Deep adds a web pass to enrich competitors and review language.
- **Honest caveat.** This output is only as good as the interviews. Hypotheticals, and anything with no real past purchase behind it, get flagged. The fix for thin data is better interviews — not a prettier report.

**Then lock the language.** Start from English as the default. Should the user write to you in some other language, put it on the table: call AskUserQuestion with options English / their language / Other. Hold the choice; all conversation and the file use it. Canon files and URLs stay as they are.

---

## Stage 1 — The business task (asked first; it is the spec for extraction)

**Why first.** The task you choose changes both *what* to dig for and *at what altitude*. The canon makes this explicit in `product-method/canon/the-algorithm.md`: the shortlisted mechanics are the spec for research — without them you are interviewing blind. So pin the task before extracting anything.

**Waterfall (five steps):**

1. **Ask directly** with AskUserQuestion: "What business task are you solving with these interviews?" — with the menu below.
2. **If they can't name one**, drop to free text: "Describe what you are trying to figure out or fix."
3. **Read it off their description.** Where you can map it to a task with confidence, restate that task in one sentence and check it with them.
4. **If you are not confident**, propose the two to four likeliest tasks (AskUserQuestion) and let them pick.
5. **If several genuinely apply**, ask them to rank. The top one drives the emphasis of extraction; the rest are secondary.

**Business-task menu** (provenance: `product-method/canon/the-algorithm.md` and `product-method/canon/jobs/value-mechanics.md` — you do not need to read them just to show the menu):

- **Create value / beat competitors** — get the Jobs done with less brain energy than the rival options.
- **Increase conversion to sale / activate into value** — mend the route to the first Aha Moment.
- **Increase retention / decrease churn.**
- **Increase repeat or return rate.**
- **Increase average order value / improve unit economics.**
- **Launch / find product-market fit / find a segment / validate value** (early product).
- **Position and differentiate** — communicate validated value to a validated segment.
- **Grow or scale an existing product** — more segments, sub-segments, new geographies, or a larger share of any one customer's Jobs.
- **Escape direct competition / climb a level** — shift the ground you compete on.
- **Not sure / challenge my goal** — a broken number hardly ever lives at the spot where it surfaces, so look upstream to diagnose. (And if there turn out to be no interviews yet, route to `/diagnose`.)

Hold the chosen task — Stage 3 conditions extraction on it.

---

## Stage 2 — Intake the interviews and the run settings

Collect through a short back-and-forth plus one or two batched AskUserQuestion calls (no more than four options each).

**Step 1 — interview files.** Accept either a folder path (read every text-like file in it) or a list of paths. Supported types: `.md`, `.txt`, `.docx` (read as text), `.vtt` / `.srt` (strip the timestamps), and `.csv` (survey open-ends, where one row is one mini-interview). Tag everything that comes from a file as **[user data]**, and treat all of it as hypothesis — an interview is one respondent's account, not ground truth, and a sales call is a pitch, not a Job study. Optionally collect light context as free text: what the product is, and any segments or Jobs the user already believes exist. Hold those as **prior hypotheses to test against the data** — never merge them in as fact.

**Step 2 — batch ask.** In one or two AskUserQuestion calls:
- **Mode** — Quick (default, offline) or Deep (adds a web pass).
- **Output format** — Markdown (default) or HTML (collapsible and navigable).
- **Output path** — the default `method-results/{product}/analyze-interviews/…`, or a custom folder. One file per run either way.

Keep all of it in working context.

---

## Stage 3 — Per-interview distillation (the fan-out)

Launch a distiller for each interview (batch three to four short files into one). Each distiller reads its file plus `job-structure.md` and `job-types.md`, applies the extraction schema and the quality rubric below, conditions its digging on the chosen task, and returns a structured distillation. The orchestrator collects them.

### Extraction schema — the eight Job elements plus the companion Solution

(Citations: `product-method/canon/jobs/job-structure.md` and `product-method/canon/jobs/overview.md`.)

1. **Context** — the features of the person or situation that make them want *this* outcome judged by *these* criteria. Keep only the features that move a criterion; drop the rest as noise.
2. **Negative emotions (State A)** — the way they felt beforehand, back when the outcome was still beyond reach. Absence in the transcript is not evidence of absence — flag it as "not surfaced," do not record "none."
3. **Consideration Set** — the ways of reaching the higher-level outcome they actually weighed. Four slots: the Job Maps they knew, how those compare on efficiency, the named products and the way in to each, and their fears.
4. **Trigger** — the specific moment that flipped them from mulling it over into action (a fixed point in time, not a vague "once I felt ready"). For a recurring Job, the schedule stands in for the trigger.
5. **Expected outcome** — the "I want to + verb" clause, captured verbatim. A noun has had its verb amputated — push back to the verb. Each infinitive is a separate Job; parse the stacks.
6. **Success criteria and priority order** — the concrete, measurable "good enough" (a direction and a level). Adjectives are wishes — push them to a number or a fact. Record the ranking — what cannot be compromised versus what they'll give up. That ranking is, in its own right, a basis for segmentation.
7. **Positive emotions (State B)** — the feeling they were after once it was done. Dig past the first-pass facts to the emotion they actually name.
8. **Higher-level / Aspiration Job** — climb the "in order to…" ladder until the answers start repeating (repetition marks the need; do not record the need itself as a Job). Do not claim the Aspiration Job as something the product delivers.

Plus, for each Job: **frequency**; **Job budget** (money/time paid or spent); **importance** (if it was elicited); the **chosen Solution** (brand, route, or DIY), structured as a label plus the sub-graph of Core and Sub-jobs it installs; the **Job type** (Regular / Orientation / Chore / Fake / Emotional / Viral); the **Aha Moment** (a pleasant surprise during use, where the experience beat the criteria they walked in with); every **Problem** on its Job → Solution → Problem chain; the **switching barriers and fears** (habit, identity, objective barriers, and fears — distinguishing fears born of real past experience from fears that are imagined); and the **Previous and Next Jobs** in the chain.

### Quality rubric — per interview, yielding a confidence on its Core Jobs

**Hard gates** (a single "no" on any of these holds that interview's Core Jobs down to **not usable** — the Fake-Job risk):
- **G1 — real past expenditure.** Money, time, or energy was genuinely laid out on this outcome at some earlier point.
- **G2 — they performed the Job themselves.** It is their own prior behaviour — not hypotheticals, and not "users in general."
- **G3 — a concrete past episode is on record.** Some specific instance you can reconstruct — or a plainly habitual pattern that comes with a frequency.

**Quality dimensions** (rate each strong / partial / absent):
- trigger present
- context present
- expected outcome stated as a verb
- success criteria concrete (and ranked)
- Aspiration Job laddered
- emotions surfaced
- Consideration Set present
- low leading-question contamination
- the respondent's own words preserved
- awareness zone right — accepting a status- or identity-driven "why" at face value counts as a quality failure, even when the rest of the interview ran smoothly

**Roll-up to confidence (four levels):**
- **Clean read (High)** — gates clear; trigger, context, outcome, concrete ranked criteria, and the Aspiration Job all come through strongly; the session began with open questions and stayed non-leading; the Consideration Set is there; in effect all eight elements can be rebuilt.
- **Directional (Medium)** — gates clear; you have the outcome and a few concrete criteria, but pieces are missing — no laddered Aspiration, a sparse Consideration Set, criteria only partly concrete, a little leading. Good enough to point a direction.
- **Weak (Low)** — gates clear, yet the probing barely scratched the surface: criteria stay abstract, no trigger, lots of opinion and satisfaction talk, strongly led, or a deeper-zone "why" got accepted as fact. Only candidate hypotheses make it through.
- **Not usable** — G1 or G2 fails, or the whole thing is future-tense/hypothetical/feature-wishlist with no actual episode. Don't record Core Jobs as findings here.

### Salvage from Weak / Not-usable interviews

Even an unusable interview is not waste:
- Climb to the Aspiration Job that sits above the Fake Job — that ladder is often real. *Example:* a respondent says "I'd definitely pay for an app that plans every meal for the month." There is no past payment behind it (Fake Job), but laddering "in order to…" lands on a real Aspiration Job — to feel on top of the household week and end the nightly 6pm scramble over what's for dinner. Record that, labeled as a hypothesis.
- Record the named Solutions and competitors they mentioned.
- Capture stated Problems as **orphan symptoms**, flagging that the Job they sit on is missing.
- Favour behavioural signals over self-report.
- Label every salvaged item as a hypothesis to validate, never a finding.
- Route the respondent to be re-recruited on a past-payment screener.

### Distiller return shape (final message, no files)

- usability classification (JTBD / partial / non-JTBD; well or poorly conducted)
- rubric verdict (gates plus roll-up)
- each Job episode with its eight elements plus Solution, type, Aha, Problems, barriers, and Previous/Next Jobs
- two to three anchor quotes per Core Job
- per-Job confidence
- what is missing for the chosen task

### Business-task → extraction emphasis

The spine is always extracted, whatever the task: **Core Jobs, ranked success criteria, and Solutions.** On top of that:

| Business task | Dig deeper on |
|---|---|
| Create value / beat competitors | Aspiration Jobs · Consideration Set · Jobs outside the Core (Previous / Next / Sibling Jobs) · Problems with current Solutions |
| Increase conversion / activation | Aha placement · triggers · the three barriers (cost / fears / don't-see-value) · Delivery Chain breaks before first value |
| Retention / churn | why they stay versus why they left · the Aha stream across time · Next Jobs · habit and switching cost · Problems after start · frequency |
| Repeat/return · AOV · unit economics | Job budget · frequency · multiple Jobs held per person · high-margin criteria |
| Grow / scale | Common Jobs across maps · adjacent and sub-segment Job Maps · budget per Job |
| Position and differentiate | Core Jobs and ranked criteria · Aspiration Job · barriers and fears · Aha · triggers |
| Escape competition / climb a level | Consideration Set including out-of-category Solutions · the Aspiration Job above · Previous / Next Jobs |

---

## Stage 4 — Per-interview feedback

From the distiller returns, build a feedback table, one row per file:

- **Type and quality** — JTBD / partial / non-JTBD; conducted well or badly, with the single reason that decided it.
- **What came out** — the Core Jobs surfaced, each with its per-Job confidence and the key elements that were present.
- **What's missing** — the elements that were absent or thin.
- **Serves the task?** — given the chosen task, can this interview contribute? *Example:* the task is "increase retention," but interview #4 only captured why a customer first signed up, with nothing about their experience after onboarding or why they kept (or stopped) using the product. It is usable as a Core-Job hypothesis but cannot speak to the task, which needs the Next-Job and Aha-stream elements it lacks.

Say it outright: this is where the producer contract's risk-flagging step lands (`PRODUCER-CONTRACT.md §3`) — the block that surfaces what might be shaky in your inputs. Since the inputs here are themselves interviews, the risk read and the quality read are one and the same.

---

## Stage 5 — Synthesis into segments and confidence propagation

Group the distilled extractions from across the interviews into candidate segments, and then give each segment a confidence.

### Clustering rule

(Segmentation root — citations: `product-method/canon/jobs/segmentation.md` and `product-method/canon/jobs/overview.md`.)

People belong to the **same segment** when they perform similar Core Jobs, judge success by similar criteria, and rank those criteria in a similar order. They belong to **different segments** if any of three things differs:
- the **Core Job** itself;
- the **criteria** (same outcome, different criteria = a different Job);
- the **priority order**. *Example:* two freelancers both want to invoice their clients, but one ranks "gets paid fastest" first and "looks professional" second, while the other ranks "never an awkward money conversation" first and speed a distant third. Same verb, opposite priority orders — two segments, not one averaged segment.

The same surface verb does not make the same segment. And one person who holds several Jobs is **one** segment member, not several — their whole Job Map is what places them.

### Persona = causal criteria

(Citation: `product-method/canon/jobs/segmentation.md`.) A persona draws on the Core Jobs, the ranked criteria, and the cause-level circumstances that give rise to them. Demographics sit at second order and never form the first cut. Each criterion that survives has to be a *cause* — something that moves value, margin, or demand — rather than a value said over again. *Example:* "saves me about $200 a month" is a value the customer receives, not a criterion; the criterion behind it is something like "runs on a tight personal cash-flow that cannot absorb a surprise charge" — that is the cause that shapes what they will and won't tolerate.

### Confidence propagation (compute it; show the math; no false decimals)

Weight each interview by its confidence level: a **Clean** read is worth 1.0, **Directional** is worth 0.66, **Weak** is worth 0.33, and **Not-usable** is worth 0 (a not-usable interview only ever adds Aspiration-Job hypotheses, never evidence for a segment).

For each segment:
- **Support weight** = add up the weights of every interview whose extractions fall into that cluster.
- **Saturation** = have fresh interviews stopped contributing new Core Jobs or criteria? (a qualitative call: yes / partial / no).
- **Coherence** = how closely the criteria and the priority order line up within the cluster. When the priority order splits, read it as a cue to **break the cluster into two segments** rather than to average across them.

Combine these into a plain-language confidence for the segment (calibrate the thresholds against your data, and name the ones you settled on):
- **Solid** — support weight ≳ 3, coherent, saturating.
- **Emerging** — support weight roughly 1.5–3, with some coherence.
- **Hypothesis** — support weight below 1.5, only one backing interview, or incoherent.

Always make the underlying support visible. *Example line:* "**Solid** — 'busy parents reclaiming the dinner hour,' supported by interviews #2 (clean), #7 (clean), and #11 (directional)."

### Inverse read — the honesty gate on data quality

State how many interviews landed as Weak or Not-usable, what that does to overall trust, and — for the chosen task — which questions the current data simply cannot settle. That list is exactly what feeds the next round of fieldwork.

---

## Stage 6 — Assemble the report

Assemble a single file in the following order: the file's top matter (with no attribution line), then the disclaimers stated once, and then the sections that follow. Work out the Layer-1 block and the data-quality summary **last of all**, from the completed material. Layer-1 is a one-screen verdict (can the data answer the task; the top two or three segments with one anchor quote each; the single biggest data risk). Section 1 is its fuller breakdown.

Describe the template by its sections and columns — do not write literal prose into this file:

- **Layer-1 block, "read this first":** can these interviews answer the task (Yes / partly / not yet, plus one line); the segments that showed up (top two or three, most-supported first, each one line with one anchor quote and its interview number, tagged Solid / Emerging / Hypothesis); and the single biggest data risk.
- **§1 Data-quality summary:** files analyzed (N); type mix (JTBD / partial / non-JTBD); quality mix (counts of clean / directional / weak / not-usable); can these interviews serve the task (Yes / partly / not yet, plus the one-line binding gap); the single biggest data risk.
- **§2 Segments by Core Jobs:** first a comparison table — columns Segment / Core Jobs (short) / dominant ranked criteria / confidence / number of interviews supporting — ordered by confidence. Then a block per segment: a heading (segment name tied to the Jobs and the real criteria) and its level; a Confidence line (the level plus the supporting interview numbers with their per-interview confidence); a Persona (the causal criteria) as one paragraph plus three to five causal-criterion bullets, each naming the cause it drives; the Core Jobs in canon grammar — *When {context + trigger + negative emotions}, I want to {expected outcome}, with success criteria {concrete, ranked}, in order to {Aspiration Job + positive emotions}*; the Aspiration Jobs (the motivation above the Core Jobs); and one to three anchor quotes, verbatim, with interview numbers.
- **§3 What they use today and where it falls short:** per hired tool — the tool, the set of tasks choosing it does for them (its core and sub-tasks), and where it underperforms, each problem traced task → tool → problem. Doing it yourself counts as a tool. Structurally each tool is a Solution = a label plus the sub-graph it installs.
- **§4 What they weighed before choosing:** the options they knew about, how they compare, the named products and a way in to each, and their fears — their Consideration Set. State what they weigh and what they would need to learn or believe before they would switch.
- **§5 Value-creation hypotheses:** the underserved intersections of success criteria, each with a one-line mechanic direction per segment. No feature list — note that building it out is `/value-prop`'s job.
- **§6 Per-interview appendix:** one row or block per file — type and quality, Core Jobs found (with per-Job confidence), what is present, what is missing, and the serves-the-task verdict. In HTML, wrap this in a `<details>` block.
- **§7 Gaps and what to interview next:** what the data cannot answer for the task; who to re-recruit (past-payment screener); which segments need more interviews to move from Hypothesis → Emerging → Solid; and a suggestion to use the interview-guide flow to design those.

**Hand-off** (`PRODUCER-CONTRACT.md §4c`): end with the next step — a Solid segment plus its value hypothesis → `/value-prop`; a live product to grow or fix → `/diagnose`; only Hypothesis-level segments → the interview-guide flow to run additional fieldwork.

---

## Quick mode (default) — step ledger

1. Keep the user's inputs in context (business task, file list, any prior segment hypotheses).
2. Read the eager core (`overview.md` and `segmentation.md`).
3. Fan the distillers out (Stage 3), gather their returns, and load each staged canon file the moment a section first calls for it.
4. Assemble the per-interview feedback (Stage 4).
5. Cluster into segments and work out confidence (Stage 5).
6. Apply the self-critic criteria and correct any issues on the spot.
7. Put together the single report (Stage 6); leave the data-quality summary for last.
8. Print the chat output.

Never skip a stage silently — call out which stage you skipped and the reason.

---

## Deep mode (opt-in)

Everything Quick does, and then a web wave **after** synthesis. The subagents pick up the named Solutions and the Consideration Set that came out of the interviews and:
- (a) verify who the real competitors are and how they position;
- (b) pull genuine review language tied to the Core Jobs to back up or push against the criteria you extracted;
- (c) surface Jobs the interviews overlooked but the market plainly displays.

The web caps, the evidence floor, the self-critic pass, and the web-MCP fallback all conform to `PRODUCER-CONTRACT.md §6`. Source links are required. Web data **annotates** — it never overrides interview evidence. The interviews lead.

---

## Self-critic criteria (run before the report ships)

1. Segments rest on alike Core Jobs and alike ranked success criteria — not on demographics, the Aspiration Job, or industry. Where the priority order split, the cluster was split rather than averaged.
2. Each Core Job's confidence traces back to named interviews. No segment earns Solid off the strength of one lone Directional interview.
3. No Fake Job was elevated into a finding. Respondents with only future intent produced nothing but Aspiration-Job hypotheses, named Solutions, and orphan Problems — every one of them labeled.
4. Criteria are concrete (a direction plus a level), not adjectives. Any abstract ones are tagged "re-elicit."
5. Personas are causal criteria; demographics stay second-order; every surviving criterion is a cause and not a value restated.
6. Problems live on a Job → Solution → Problem chain; Solutions are written as a label plus a sub-graph; DIY counts.
7. The Job grammar holds — *When … I want to {outcome} with success criteria … in order to …* — with one verb per Job, and levels named and stated relative to the product.
8. The data-quality honesty gate fired: weak and unusable counts are reported, the unanswerable task questions are named, and a re-interview plan is given.
9. The writing is plain-language-led; method terms appear only in parentheses; quotes are verbatim.
10. There is exactly one file (Rule 4), and the disclaimers appear once, at the top (Rule 3).

---

## End-of-run chat output

1. **Brief outcome** (three to five lines): how many interviews proved usable, which segments turned up and their confidence, and whether the data answers the task.
2. The **data-quality summary** plus the **segment table**, shown inline.
3. **Next step** — the hand-off call: which skill, and which segment.
4. **Path** — the one result file.

---

## What this skill does NOT do

- It runs no interviews and recruits no respondents — that fieldwork is yours; design it with the interview-guide flow.
- It does not conjure segments from the market — that's `/market-research`'s job. Here the skill only rebuilds what the interviews back up, and flags where they fall silent.
- It does not put a number on market size or assemble a unit-economics model — those belong to other skills.
- It does not convert a value hypothesis into features or a PRD — that path is `/value-prop` → `/product-requirements`.
- It never invents a Job, a quote, or a confidence. Where the data is thin, it says so.
