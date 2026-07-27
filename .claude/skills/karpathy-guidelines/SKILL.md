---
name: karpathy-guidelines
description: "Behavioral guidelines to reduce common LLM coding mistakes. Use when writing, reviewing, or refactoring code — especially when extending this framework with new agents, skills, or commands. Prevents overcomplication, speculative features, non-surgical edits, and vague success criteria."
license: MIT
---

# Karpathy Guidelines

Behavioral guidelines to reduce common LLM coding mistakes, derived from Andrej Karpathy's observations on LLM coding pitfalls. Verbatim copy of the upstream skill by Forrest Chang (MIT) at `forrestchang/andrej-karpathy-skills`.

**When to use in this framework:** load this skill before editing or extending framework code — new agents in `.claude/agents/`, new skills in `.claude/skills/`, new commands in `.claude/commands/`, new Python scripts. The framework already enforces evidence-required / surgical-change discipline for analysis outputs; these guidelines extend that discipline to framework internals so the tooling itself doesn't bloat.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

## How this connects to the framework's own invariants

The framework's analysis invariants (in `CLAUDE.md`) and Karpathy's principles overlap by design:

| Framework invariant | Karpathy principle |
|---|---|
| Evidence-required on every factual claim | Goal-Driven Execution — each claim has a verifiable source |
| Spec-normalizer lifts implicit assumptions | Think Before Coding — surface assumptions explicitly |
| Diablo "verifiable" ISO 29148 criterion | Goal-Driven Execution — vague "must be fast" is rejected |
| Researcher's `?` on missing evidence | Think Before Coding — don't hide confusion, name it |

When in doubt about whether to add a feature / file / agent to the framework, apply principle 2 (Simplicity First).

---

## Attribution

Upstream: <https://github.com/forrestchang/andrej-karpathy-skills>
Based on: <https://x.com/karpathy/status/2015883857489522876>
License: MIT (both upstream and this copy).
