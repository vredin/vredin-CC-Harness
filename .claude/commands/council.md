---
name: council
description: 'Multi-model deliberation — spawn Opus + Sonnet in parallel for divergent perspectives on architecture/security decisions. Within Claude subscription, no external API.'
argument-hint: <question or design choice>
allowed-tools: Read, Bash, Grep, Glob
model: sonnet
---

> **Style:** Load `caveman-distillate` skill.

# /council — Two-model deliberation

Question: **$ARGUMENTS**

Spawns **Opus 4.7** and **Sonnet 4.6** as parallel subagents. Same prompt, different perspectives.
Cost: subscription only, no API charges.

---

## When to use

✅ Architecture forks (DB choice, framework choice, build vs buy)  
✅ Security-critical decisions  
✅ Refactor scope decisions (small surgical fix vs deep restructure)  
✅ Tech debt vs speed trade-offs

❌ Routine bug fixes (use `/fix`)  
❌ Trivial questions (use `/general`)  
❌ Questions with obvious answers (don't burn 2 model calls)

---

## STEP 1 — Frame the question

Before spawning models, write 2–4 sentences of context:
1. What is the decision?
2. What are the constraints (perf, deadline, team skills)?
3. What's already been considered?
4. What is the user's gut feeling (if any)?

Pass this framing to both models.

---

## STEP 2 — Spawn parallel subagents

Two `Agent` calls in a single message:

```
Agent A:
  description: "Council Opus perspective"
  subagent_type: "general-purpose"
  model: "opus"
  prompt: |
    [full framing from STEP 1]
    
    The question: $ARGUMENTS
    
    Provide your analysis and recommendation. Format:
    - Recommendation (1 paragraph)
    - Reasoning (3-5 bullets, evidence-based)
    - What you'd want to know to be more sure
    - Risks of this recommendation
    
    Be opinionated. Don't hedge with "it depends" — pick a direction.

Agent B:
  description: "Council Sonnet perspective"  
  subagent_type: "general-purpose"
  model: "sonnet"
  prompt: |
    [same framing + question + format]
```

Both agents see the SAME prompt. Different models = different training, different defaults.

---

## STEP 3 — Synthesize

After both return, produce structured comparison:

```
COUNCIL VERDICT — <one-line topic>

## Opus says
<recommendation in 1 sentence>
Key reasoning: <2-3 bullets>

## Sonnet says
<recommendation in 1 sentence>
Key reasoning: <2-3 bullets>

## Where they agree (high-confidence claims)
- <claim>
- <claim>

## Where they diverge (genuine uncertainty)
- Topic: <X>
  - Opus: <position>
  - Sonnet: <position>
  - Why this matters: <one line>

## Synthesizer's read
<your read on the divergence — but DO NOT pick the winner for the user>

## What you'd want to know to decide
- <question 1>
- <question 2>
```

**The /council command does NOT decide for the user.** Its job is to surface the disagreement, not paper over it. If both models agree → high confidence answer. If they disagree → the user needs to provide the missing context (constraints, preferences, internal knowledge).

---

## Hard rules

- ALWAYS spawn both models. If one is unavailable, abort with error — single-model output defeats the purpose.
- The synthesis step is YOUR work, not delegated. You read both outputs and produce the comparison.
- NEVER append a "my recommendation" — that turns 2-model deliberation into 3-model. Stop at synthesis.
- Cost discipline: typical /council = ~3-5x base prompt cost. Worth it only for non-trivial decisions.

---

## Output saved to

After synthesis: ask user `Save council verdict to Outline Knowledge Base / Best Practices? [y/n]`

If y → `mcp__outline__create_document` with title `council: <topic> — <date>`, body = full synthesis. Tagged for future reference (other instances of the same decision can lookup prior deliberations).
