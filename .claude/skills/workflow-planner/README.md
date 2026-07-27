# workflow-planner

**🇬🇧 English** · [🇩🇪 Deutsch](README.de.md)

A Claude Code skill that turns a task into the right atomic plan. It first decides whether the task needs parallel orchestration (a Dynamic Workflow via the Workflow tool) or a plain linear plan, and writes the matching artifact.

## Why

Not every task should be wrapped in a workflow. A linear chain of steps gains nothing from parallelism, while a background run of dozens of agents adds overhead. And the reverse: a task made of dozens of independent chunks is a waste to run sequentially. This skill takes that decision off your hands: it classifies the task and writes a plan for the right mode.

## What it does

1. **Applicability gate (hybrid).** Scores the task against a checklist. If the answer is obvious, it gives a verdict with a rationale. If borderline, it asks 1-2 clarifying questions.
2. **If it does not fit** - writes a linear `PLAN.md` in "step -> verify" format.
3. **If it fits** - writes an atomic plan with branches, roles and parallelism, and after your approval generates a ready-to-run JS script for the Workflow tool.

## Install

Copy the `workflow-planner/` folder into your skills directory:

- macOS / Linux: `~/.claude/skills/workflow-planner/`
- Windows: `%USERPROFILE%\.claude\skills\workflow-planner\`

Confirm it is visible: `/skills` should list `workflow-planner`.

## Usage

```
/workflow-planner check 30 blog pages for broken links and assemble a report
```

Or just describe a task - the skill activates from the description. Then:

1. The skill gives a verdict (fits a workflow or not).
2. It shows the plan.
3. After approval it places the artifacts into the **current project**:
   - `PLAN.md` in the root;
   - `.claude/workflows/<name>.js` (in workflow mode).
4. Running the workflow is a separate step and your explicit choice. The skill never runs anything itself.

Note: artifacts (the plan, diagram, agent prompts) come out in the **language of your task** - write the task in German and the plan is in German. The skill's own instructions are in English; that is what the model reads and it does not affect the output.

## Boundary with other skills

- **agent-constructor** builds reusable subagent roles (`.claude/agents/*.md`) and coordination via a README. workflow-planner is about one-off orchestration of a concrete task and about plans. They compose: if roles already exist, the script can reference them via `opts.agentType`.

## Structure

```
workflow-planner/
|-- SKILL.md                      # orchestration: gate + flow + navigation
|-- reference/
|   |-- applicability.md          # "fits / does not fit" criteria
|   |-- workflow-primitives.md    # Workflow tool primitives, limits, common mistakes
|   |-- plan-to-script.md         # how to turn a plan into a JS script
|   `-- diagram-html.md           # optional client-facing HTML diagram of a workflow
|-- templates/
|   |-- workflow-plan.md          # workflow plan template
|   |-- workflow-script.js        # JS script template
|   `-- linear-plan.md            # linear plan template
|-- examples.md                   # two worked examples
|-- README.md                     # English
|-- README.de.md                  # German / Deutsch
`-- LICENSE
```

## Requirements

- Claude Code with Agent Skills and Dynamic Workflows (the Workflow tool) support.
- For `isolation:'worktree'` (when branches write to the same files in parallel) - a git repository.

## License

MIT. See `LICENSE`.
