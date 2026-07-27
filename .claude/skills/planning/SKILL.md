---
name: planning
description: 'Pre-implementation thinking bundle. Routes to: brainstorming (open dialog before code), idea-atomizer (stress-test idea for hidden assumptions), writing-plans (decompose spec into bite-sized steps). Use when the user has a non-trivial change to make and you need to think before touching code.'
---

# Planning Skill — Pre-Implementation Thinking

This skill bundles three thinking modes. Pick the right one based on stage.

## Routing

| Stage | Sub-skill | When |
|-------|-----------|------|
| Vague intent, no plan yet | `brainstorming.md` | User says "I want to add X" but specifics are unclear |
| Plan exists, suspect flaws | `idea-atomizer.md` | Critical analysis before commitment — find hidden assumptions |
| Plan validated, ready to code | `writing-plans.md` | Decompose spec into ordered, executable steps |

Typical chain: `brainstorming` → `idea-atomizer` → `writing-plans` → implementation.
Skip stages when not needed (clear bug fix doesn't need brainstorming).

## When NOT to use

- Bug fix where root cause is obvious — go straight to `/fix`
- Single-file change under 50 lines — direct edit
- Refactor with no behavior change — just do it (clean-code standards = built-in model knowledge)

## Loading sub-skills

When you've decided which mode, read the corresponding file:
- `.claude/skills/planning/brainstorming.md`
- `.claude/skills/planning/idea-atomizer.md`
- `.claude/skills/planning/writing-plans.md`

Each sub-file is self-contained — read only the one you need.
