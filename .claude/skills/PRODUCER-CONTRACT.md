# Producer Contract

This is a shared contract, not a skill. It carries no frontmatter, it is not something a user invokes, and it performs no version check or network call of any kind. Its job is to spell out the behaviors that every producer skill must honor so that all of them move in lockstep from a single definition rather than drifting apart copy by copy.

The skills bound by this contract are the four that generate a deliverable for the user: `/market-research`, `/value-prop`, `/product-requirements`, and `/go-to-market`. Each of them imports the rules below.

There is a companion file next to this one. `../READABILITY-CONTRACT.md` governs how the finished artifact is laid out — the three-layer output, the drill-down links, the source attribution. This file, `../PRODUCER-CONTRACT.md`, governs everything that happens before and around that output: how the skill greets the user, how it frames their inputs, and how it keeps the work honest. The two are siblings and are meant to be read together.

The behaviors gathered here were shaped by watching real people use the skills and noting where they got tripped up, misled, or over-trusted a fast answer. They exist to close those gaps.

There are **six** behaviors. Here is the roster, one line each:

1. **Helicopter-view first** — orient the user before asking anything.
2. **Output-format choice** — the user selects Markdown (fast) or HTML (which reads more comfortably).
3. **Critical treatment of all user input** — every input is a hypothesis, and its risks get their own visible block.
4. **Visible validation debt** — print how many assumptions are unproven, and write `GO (to validation)` rather than a bare `GO`.
5. **Configurable output path** — default to `method-results/…`, but accept the host repo's convention.
6. **Deep-mode QA loop with a web-MCP fallback** — enforce an evidence floor, self-check each leg, and recommend a web MCP when fetching is blocked.

Each is detailed below.

---

## §1 — Helicopter-view first

Before STAGE 0, and before the very first `AskUserQuestion` call, the skill prints a short orientation block. It is written in plain language, in whatever document language the user has chosen, and it reads like a map of the journey rather than a manual for operating the tool.

Keep it tight: roughly **8 to 12 lines**. If it runs longer than that, it has stopped being a map and started being the territory.

The block must cover these elements, each in about a line:

- **What you'll walk away with.** Name the single deliverable in one sentence.
- **The route.** List the phases as 3 to 6 numbered steps, one line apiece.
- **Where the AI does the work and where you do.** Be explicit: the AI handles the analysis and synthesis, but the user is the one who chooses the direction and who runs the real-world checks — talking to customers, trying to sell, shipping a test. The AI cannot do that proving on the user's behalf.
- **The two modes.** Quick is the default: no internet, around 3 to 5 minutes, reasoning only — ideal for a first pass, for generating hypotheses, or for a "what am I overlooking?" sanity check. Deep is opt-in: it spins up subagents and does live web research, takes considerably longer, and brings back actual data on competitors, market size, and customer reviews.
- **Roughly what it costs.** Give a ballpark on both time and token spend so the user can decide which model to point at the task. Quick is light. Deep is heavy and is best run on a top-tier model with a web MCP connected.
- **One honest caveat.** Say plainly that the method speeds up the thinking, not the proving. The figures and segments it produces stay hypotheses until someone checks them in the field.

A fresh way to phrase that caveat: think of the skill as handing you a detailed map of a coastline it has never actually sailed. The map is genuinely useful — it tells you where to point the boat and which reefs to fear — but until you take the boat out, every depth marked on it is a guess rather than a sounding. The artifact is the map; the customer interviews are the voyage.

Close the block with a brief handoff, something to the effect of "ready to start? I just need to ask a few things first," and then move into intake.

---

## §2 — Output-format choice (Markdown or HTML)

Ask this **once**, inside the intake batch, right next to the mode question. Do not ask it again later.

The two options mean:

- **Markdown** — the default. Faster to produce, and it opens in essentially any tool.
- **HTML** — a little slower to produce, but easier to actually read: sections collapse, and the in-page navigation works.

Whichever the user picks, every link stays clickable. That covers both the source links required by Readability Rule 2 and the `▸` drill-down links that move a reader from Layer 1 to Layer 2 to Layer 3. HTML keeps all of those and simply presents them more cleanly, with in-page anchors and sources opening in a new tab.

If the user chooses HTML, produce **one self-contained `.html` file** — still exactly one file per run, per Rule 4 — whose content is identical to what the Markdown version would have contained: the same attribution, the same disclaimers, the same three layers, every table, and every link. The HTML build must meet these requirements:

- **Inline CSS only, no external dependencies.** The file opens offline, needs no network, and requires no build step. Use a comfortable reading width of about **720px**, a system font stack, and generous line spacing.
- **Navigation that works.** Both the "how to read this" jump links and each `▸` drill-down resolve to real in-page anchors (`href="#id"`) pointing at matching `id` targets. Include a small sticky bar at the top with jumps to Level 1, Level 2, and Level 3.
- **Collapsible depth.** Wrap the Layer 3 sections and every `▸ methodology trace` in `<details>` elements. Levels 1 and 2 are open by default; Level 3 starts collapsed.
- **Source links open in a new tab,** using `target="_blank" rel="noopener"`.
- **Filename** follows the same pattern as the Markdown file but with an `.html` extension. Do not also write a `.md` file — it is one file per run, either way.

Build the HTML by rendering the finished content directly, reusing the same layers and anchors. Do not produce a thinned-down version for HTML.

---

## §3 — Critical treatment of all user input (everything is a hypothesis)

**The problem this solves.** It is tempting for a skill to take whatever the user describes at face value and bake it straight into the wedge — and in doing so to quietly swap the team's *imagined* Job for the customer's *real* one. The method forbids that shortcut; Phase II field validation is not optional, and no amount of confident input from the user replaces it.

**The rule.** Treat *every* input as a hypothesis and never as established fact. That applies to free-text claims, uploaded pitch decks, landing pages, codebases, prior research, and any "everyone obviously wants this" assertion. The user-claims ledger that the method already keeps for spoken claims is hereby extended to cover *all* materials the user hands over, not just things they say out loud.

This produces two obligations.

**(a) Hunt for the risks inside what was provided.** For each load-bearing input, the skill asks itself:

- Is this a fact the customer has validated, or is it the team's belief *about* the customer? (A landing page, for instance, is the team's value hypothesis — it is not evidence that anyone wants the thing.)
- Does the stated Job or segment look like the customer's actual Job, or like the team's projection onto the customer? Flag this one hard — it is the single most expensive mistake to get wrong.
- Are there internal contradictions, or guesses dressed up as data?
- What would have to be true for this input to hold — and has anyone actually checked that?

**(b) Emit a dedicated, visible block.** Give it an abstract title along the lines of *"what you provided — and the risks I see in it."* Place the block in Layer 2 as its own subsection, and lift the single worst item up into Layer 1 as (or alongside) the make-or-break risk.

The block is structured like this:

- A heading, followed by one italic preface line stating that everything below is being treated as hypothesis, not fact.
- A table with four columns:
  1. **What you provided / claimed** — tagged as data, observation, or hunch.
  2. **How I treated it** — for example, "used as a hypothesis in the segment ranking."
  3. **The risk I see in it** — specific, not generic.
  4. **How to check it fast** — the cheapest test that could falsify it.

As a fresh illustration: suppose the user uploads analytics showing that 70% of trial users never open the reporting screen, and concludes "people don't care about reporting." The data point is real (tag: data), but the conclusion is a hunch. The skill might treat it as a hypothesis that reporting is low-value, note the risk that low usage could equally mean the screen is buried or confusing rather than unwanted, and propose a five-interview check asking churned users whether they got the numbers some other way.

**The hard gate.** No verdict, choice of target segment, wedge, value proposition, or PRD scope is allowed to lean *chiefly* on a user input left unvalidated unless the output says so out loud **and** points a RAT row directly at that input. In particular, a wedge built on a Job that came from the user's own materials and has not been confirmed with customers must be named as the single most expensive risk in the whole artifact.

---

## §4 — Visible validation debt and "GO (to validation)"

**Why.** A fast artifact assembled from guesses looks every bit as convincing as one assembled from evidence — the prose is just as crisp either way. So the debt has to be printed where it cannot be missed. And a bare `GO` is dangerous shorthand: founders read it as "build this now," when what the method actually means is "this is worth going to validate."

Three changes follow.

**(a) A validation-debt line in Layer 1, near the top.** Structure it as a single blockquote line that states the artifact rests on N unvalidated assumptions, M of which are fatal — meaning they would sink the whole thing if they turn out wrong — and that the fatal ones should be checked first. End the line with a `▸` link to the Layer 2 risks anchor.

- **N** is the count of risky assumptions in the RAT or risk table.
- **M** is how many of those are tagged "kills it if wrong."
- Count honestly. A thin Quick run carries a lot of debt, and the line should admit that rather than hide it.

**(b) Verdict wording.** Every `GO` is written as **`GO (to validation)`** — never as a bare `GO`. Leave `NARROW` and `PIVOT` exactly as they are. The first time `GO (to validation)` appears in Layer 1, add a half-line gloss making the meaning explicit: the idea has earned the *next step*, which is checking it in the field — not the green light to start building.

**(c) Debt travels down the chain.** When the work is handed off along the chain (`/market-research` → `/value-prop` → `/product-requirements` → `/go-to-market`), the receiving skill *opens* by asking which parts of the prior artifact's validation debt have since been checked, and it re-tags anything still unproven. The debt is carried forward at every handoff and is never silently dropped.

---

## §5 — Configurable output path

**Why.** A hard-coded root directory breaks teams who keep their research somewhere else — under `*/docs/research`, say, or wherever their repo already files such things.

Add a single intake line for this. The default keeps today's behavior with zero friction: write to `method-results/{project}/{skill}/…`. Otherwise, accept a folder or path convention that matches the host repo.

If the user supplies a path, write the one result file there, keeping the filename pattern `{YYYY-MM-DD_HH-MM}_{product-slug}-{skill}-result.{md|html}`. If the user skips the question, use the default. Either way, never write more than a single file, no matter where it lands (Rule 4).

Note that the default root is `method-results/`.

---

## §6 — Deep-mode QA loop and web-MCP fallback

**Why.** Deep research goes wrong in predictable ways: a leg fires two queries and calls it finished; a needed source blocks the fetcher; a methodology slip creeps in; the addressable market gets sized far too small. The following catches each.

**(a) An evidence floor, not just a ceiling.** Each Deep-mode leg has a cap on how many fetches it may make. Treat the *lower* bound as a real floor: a leg may not report "done" until it has either gathered a genuine minimum of distinct sources, or stated plainly why fewer were possible — the sources were blocked, or they simply do not exist. "Ran two queries and stopped" is a failure, not a completion.

**(b) A self-critic loop on every leg.** After a leg returns, run a short critic pass over it. In Quick mode this is an inline self-critique; in Deep mode it is a dedicated critic check. The critic asks:

- Were there enough distinct sources?
- Were the load-bearing claims actually verified against a source, or just asserted?
- Is there a methodology error — segmenting by demographics, treating an **Aspiration Job** as a segment, choosing features before success criteria, or sizing the market too small?
- Are there gaps still open?

If the leg fails its critic, re-run it with the specific gap named, for up to **2** additional rounds. Never ship a leg that failed its own critique.

**(c) Web-MCP fallback.** Whenever the built-in fetcher is blocked or returns thin results on a source you genuinely need — a review aggregator, a software-listing site, a regional market site — tell the user **once**, then reach for a web-research MCP if one is available. Structure that notice as a single blockquote: note that some sources block the built-in fetch, suggest connecting a web-research MCP (for example Firecrawl or Exa, both of which ship MCP servers), and say that without one the coverage will be flagged as thin. If such an MCP is already connected — discoverable through tool search — prefer it for the blocked sources. If none is available, carry on and flag the thin coverage in the verification checklist.

---

## How each skill wires this in

A producer skill satisfies this contract when all of the following are true:

- [ ] Before the very first intake question, it shows the helicopter-view block (§1).
- [ ] Both the output-format question (§2) and the output-path question (§5) sit inside its intake batch.
- [ ] If the user chooses HTML, it writes one self-contained `.html` file with working anchors and `<details>` collapsing (§2).
- [ ] Its template includes the "what you provided — and the risks I see in it" block, and the everything-is-a-hypothesis gate is enforced by its intake and self-critic steps (§3).
- [ ] The validation-debt line appears in its Layer 1 template, and each `GO` is rendered as `GO (to validation)` (§4).
- [ ] On handoff, it opens by asking what validation debt has been retired since the previous artifact (§4c).
- [ ] In Deep mode it enforces the evidence floor and the self-critic loop, and it offers the web-MCP fallback (§6).
