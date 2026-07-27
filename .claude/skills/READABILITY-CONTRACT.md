# Readability contract — the three-layer output gate (binding on every producer skill)

> The producer skills — `market-research`, `value-prop`, `product-requirements`, and
> `go-to-market` — all emit the same three-layer document, and they all owe the same
> readability standard. The neighboring file `../PRODUCER-CONTRACT.md` governs intake,
> framing, and analytical honesty; **this** file governs how the finished document reads.
> Every producer skill links here and treats the gates below as pass/fail, not as advice.

The shape we ask for was always three layers:

- **Layer 1 — The Answer.** The decision and the one-paragraph "so what," readable in about a minute.
- **Layer 2 — The Reasoning.** The argument behind the answer, in plain prose, with the moving parts named.
- **Layer 3 — The Full Work.** Every table, every assumption, every calculation — the audit trail.

That structure was specified from the start, but it was never really enforced, and the same
failures kept showing up in shipped files: Layer 1 leaked raw method jargon; the disclaimer
got paraphrased and pasted in three different places; the single biggest risk was restated so
many times the reader lost count; and the little drill-down links pointed at anchors that
didn't exist or collided with each other so the jump landed on the wrong heading.

This contract turns each of those soft intentions into a concrete, checkable gate. **Run every
gate before the file ships.** A worked redesign that shows all of this applied to a real
deliverable lives in the companion mockup file alongside this contract; consult it when an
abstract rule below needs a picture.

---

## Who the reader is (decide this once, then write for them)

Picture a junior product manager about a year into the job. Sharp, but new. They have never
encountered Jobs To Be Done, never seen the acronym JTBD, and have never heard of this method.
They will not stop to look anything up — if a sentence requires a glossary, they bounce.

The document passes when that person:

- gets the actual answer in roughly **60 seconds** from Layer 1 alone, and
- can read all of **Layer 2 without ever opening a glossary** or asking what a word means.

If either of those fails, the readability gates have failed, no matter how good the analysis is.

---

## Gate 1 — Layer 1 leads in plain words, jargon kept to the floor

Layer 1 is written in plain product English first. A method term is allowed to ride along
**inside parentheses as a short plain gloss** when naming it actually helps the reader connect
to the analysis below — but the sentence itself must make sense to someone who skips the
parenthetical. **Never open a sentence on a raw term.** And keep the count low: Layer 1 is the
one-minute exit, not a vocabulary quiz.

A trap worth calling out: a lot of "business English" reads like plain language but is really
jargon the junior PM won't parse the same way you do. Translate it.

| Reads as plain, but leaks as jargon | Say it as / gloss it in parentheses |
|---|---|
| wedge | the narrow first thing you sell to get a foot in the door |
| beachhead | the first customer group you go all-in on before expanding |
| the bet / the riskiest bet | the one assumption that, if wrong, sinks the plan |
| ACV | the average yearly amount one customer pays |
| TAM / SAM / SOM | the whole market / the slice you could serve / the slice you can realistically win soon |
| Aha Moment | the first time a user clearly feels the product working for them |

**Check:** read Layer 1 out loud as if you were the junior PM. No sentence should begin on a
raw method term, and you should be able to count the jargon words on one hand.

---

## Gate 2 — Every term in Layer 2 gets a gloss the first time it appears

Layer 2 may use the method's vocabulary, but each term earns a **three-to-five-word plain
gloss the first time it shows up**, set right next to it. After that first introduction you can
use the bare term freely.

For instance:

> The interview pointed at the Aspiration Job (the outcome the customer is really after) rather
> than the feature they asked for, which is why the roadmap reorders around it.

Glosses can nest, and a parenthetical can repeat one you already gave earlier in a long
section. That's fine — **clarity beats consistency-for-its-own-sake** here. Don't withhold a
second gloss just because purists would call it redundant.

What you may never do is ship a term that is glossed **nowhere** in the file. The failure to
avoid looks like this:

> The Delivery Chain breaks at the third node, so the Choice Activators never fire.

To a one-year PM that is two opaque proper nouns and zero meaning. Either gloss both on first
use or rewrite the sentence in plain language.

**Check:** scan Layer 2 for capitalized method terms; each must have a plain gloss somewhere on
or before its first appearance, and the sentences around them must still read smoothly.

---

## Gate 3 — Disclaimers appear exactly once (plus one pointer)

There is **one** disclaimer block, and it is a two-part block, and it sits at the very top of
the file carrying the anchor `<a id="disclaimers">`. The two parts: what this document is
(reasoning and hypotheses, not validated fact) and what the reader still has to do (prove it in
the real world).

Layer 1 then gets **exactly one short, single-line pointer** back to that block — a pointer,
not a paraphrase. Something like:

> Note: this is analysis, not proof — read the caveats before you act on it ([what to know ▸](#disclaimers)).

(Write fresh pointer wording for each skill; don't reuse a stock sentence.) The job here is to
**cut the old paraphrased restatement down to that one pointer line.** A restatement such as
"…remember none of this is confirmed, each claim links to its working and a test, and you
shouldn't spend money before you run that test" just re-says the top block — delete it and keep
only the pointer. Nothing else, nowhere else: not a second time in Layer 1, not buried in
Layer 3, not echoed in the ship checklist.

**GTM exception:** the go-to-market deliverable carries a validation flag, and it sits
**below** the Layer-1 answer, capped at **two lines**. Answer first, caveat second — never the
caveat ahead of the thing the reader came for.

**Check:** search the whole file for your disclaimer wording. More than two hits (the top block
plus the one pointer) means something needs cutting.

---

## Gate 3b — A "How to read this" map, right under the disclaimers

Immediately after the disclaimer block and before Layer 1, drop a tiny orientation block —
**one line per layer**, in plain words, saying what the reader will find at each depth, each
line ending in a jump link:

> - **Level 1 — the answer.** What we recommend and why, in a minute. ([jump ▸](#layer-1))
> - **Level 2 — the reasoning.** The argument behind it, in plain prose. ([jump ▸](#layer-2))
> - **Level 3 — the full work.** Every table, number, and assumption. ([jump ▸](#layer-3))

The three layer headings must carry the matching anchors: `<a id="layer-1">`,
`<a id="layer-2">`, and `<a id="layer-3">`. The point is to hand the reader a depth map up
front so they can choose how far down they want to go before they start scrolling.

---

## Gate 4 — Every drill-down link resolves to its own unique anchor

Every `▸` drill-down link must resolve to **one anchor id all its own**. No target is reused
across two links, and each one has to land on a real `<a id="…">` present **exactly once** in
the file.

The two failure modes that keep recurring:

- two different Layer-1 links both pointing at the same anchor, so both jumps land in the same
  spot and one of them is wrong; and
- one heading carrying two distinct anchor ids stacked together, so links that should reach two
  different places both stop at the first.

A fresh illustration of the colliding case: Layer 1 has a link `▸ pricing risk` and another
`▸ segment risk`, and both were written as `(#risks)` — so clicking either drops the reader at
the same generic "risks" heading instead of the specific row they were promised.

**Before shipping:** list out every `▸` target in the file and confirm, one by one, that each
resolves to exactly one anchor and that no anchor is the destination of two different links.

---

## Gate 5 — Opaque Layer-3 table headers carry their gloss inline

Layer 3 is dense with tables, and a casual reader will not decode a terse column header on
their own. So any **non-obvious** column header carries a **three-to-six-word plain gloss right
inside the header cell**. Obvious headers (Name, Price) need nothing; cryptic ones do.

Examples of header + inline gloss:

- **Budget owner (who signs off on the spend)**
- **Switchable demand (buyers ready to leave a rival)**
- **Reachability (how easily we can get in front of them)**

Do **not** offload these definitions to a separate `references/glossary.md`. The casual reader
never opens that file; the meaning has to travel with the column.

---

## Gate 6 — Segment depth spread across the layers *(market-research only)*

The recommended target segment gets a **partial profile in Layer 2** — enough to act on without
scrolling to the bottom:

- who they are,
- the job they're trying to get done,
- what they care about most, and
- why they'd switch to you.

Add a brief **strategic recommendation** — one or two sentences: focus here, here's how to get
in, here's the thing to lead with. The other strong candidate segments get a **light touch** in
Layer 2 — named and characterized in a line or two, no more.

The **full Segment Map at full depth** — every segment, every dimension — lives in Layer 3.

---

## Gate 7 — Validation plan spread across the layers *(market-research only)*

The plan for de-risking the deliverable shows up at all three depths, each tuned to its layer:

- **Layer 1 — light touch.** Name the single make-or-break risk and the one next action. Two
  sentences, no list.
- **Layer 2 — the focused list.** Each shaky assumption sits beside the way we'd test it — a
  single plain sentence apiece, **sequenced so the riskiest and cheapest-to-disprove come
  first**. This is the version the reader can genuinely act on.
- **Layer 3 — the detailed plan.** A step-by-step test design per assumption, grounded in the
  Riskiest Assumption Test (RAT). Each entry covers:
  - **Method** — the right test for this assumption, and why it fits.
  - **Steps** — who you talk to or run it on, how many, and what you measure.
  - **Kill criterion** — the result that proves the assumption false, with the threshold stated
    up front, before you run it.
  - **Cost / time** — roughly what it takes.

---

## Gate 8 — Skill-specific guardrails

- **GTM.** Every number or factual claim inside landing-page and ad copy keeps its inline
  `[VERIFY — source]` guardrail right where the claim sits, and it stays there until the claim
  is actually proven. Assume the reader may copy a block straight into production — the
  disclaimer at the top of the file will not stop them, so the brake has to live next to the
  claim itself.
- **PRD.** For each requirement, the `mechanic:` line and the `Core Job → Aspiration Job → Aha`
  mapping are **internal bookkeeping**, not part of the readable requirement. Tuck them inside a
  fenced `▸ methodology trace` block. What the reader sees is **what to build plus its
  acceptance criteria**; the mapping is the audit trail underneath, available but out of the way.

---

> **Not a gate: length.** This contract does not police how long the file runs. The three-layer
> document will usually come out longer than the old single-pass report, and that's acceptable —
> the plain layers **earn** their length by giving the casual reader a one-page exit at the top.
> What you must not do is trade substance for a lower line count. Shortness is never a reason to
> drop a table, an assumption, or a kill criterion.

---

## Ship checklist

- [ ] **Gate 1** — Layer 1 opens in plain English; no sentence starts cold on a raw term; jargon held near zero.
- [ ] **Gate 2** — each method term in Layer 2 carries a gloss at first use; none left undefined anywhere in the file.
- [ ] **Gate 3** — disclaimer phrasing shows up twice at most (the top block plus a lone L1 pointer); the GTM flag sits beneath the answer.
- [ ] **Gate 3b** — the "How to read this" map follows the disclaimers; all three layer anchors are in place.
- [ ] **Gate 4** — each `▸` link lands on a real, one-of-a-kind anchor; no destination is shared between two of them.
- [ ] **Gate 5** — cryptic table headers in Layer 3 each carry their own inline plain gloss.
- [ ] **Gate 6** *(MR)* — the target segment is profiled with a strategic recommendation back in Layer 2; the complete Segment Map lands in Layer 3.
- [ ] **Gate 7** *(MR)* — the validation plan is touched on in L1, enumerated in L2, then spelled out assumption-by-assumption in L3.
- [ ] **Gate 8** — GTM copy retains `[VERIFY]`; the PRD's mechanic mapping stays fenced and off the readable requirement.
