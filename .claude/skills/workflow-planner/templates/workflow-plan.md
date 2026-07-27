# Plan: <task name>

Mode: **Dynamic Workflow**
Gate verdict: fits - <which criteria you relied on: independent chunks / flow / volume>
Script artifact: `.claude/workflows/<kebab-name>.js`

> Fill in the angle brackets. Remove the example comments before delivering the plan.
> Before writing to `PLAN.md`: if it already exists in the project root (check with Glob), do not overwrite it silently - ask the user or write `PLAN.<task>.md` instead (an existing plan is unrecoverable once overwritten).

## Assumptions
- <what is taken as given about the task - environment, inputs, scope>
- <assumption 2>

State assumptions before the plan (in the language of the task). If any is wrong, the plan changes - confirm the doubtful ones with the user first.

## Branch map

| Branch | Role | Depends on | Parallel with | Input (data into the prompt) | Output |
|--------|------|-----------|---------------|------------------------------|--------|
| A | <role> | - | B | - | <what it returns> |
| B | <role> | - | A | - | <what it returns> |
| C | <role> | A, B | - | results of A and B | <what it returns> |

The dependency decides the primitive: independent branches in one phase - `parallel`/`pipeline`; a dependent branch - the next phase.

## Phases

### Phase 1: <name>  [parallel: branches are independent]
Primitive: `parallel` (need all results together) or `pipeline` (flow without a barrier, the default)

#### Branch A - <role>
- atom A.1 -> verify: <how to check the result: command / test / visual / adversarial check>
- atom A.2 -> verify: <...>
- Branch A output: <exactly what the agent returns>

#### Branch B - <role>
- atom B.1 -> verify: <...>
- Branch B output: <...>

### Phase 2: <name>  [depends on Phase 1]
Primitive: sequential (input - the previous phase's results)

#### Branch C - <role>
- input: results of A and B (passed into the agent's prompt)
- atom C.1 -> verify: <...>
- Branch C output: <final>

## verify strategy
- Expensive/important branches: a separate verify stage (a skeptic agent checks the result).
- Independence: prefer a check the generator did not make itself - a deterministic gate (test/linter/type-check) first, else a SEPARATE skeptic agent, not the same agent grading its own output.
- Cheap ones: the check is built into the prompt ("after X, run test Y").
- The whole result: post-verify below.
- Language check: the plan, branch roles, and the agent prompts are in the language of the task (not English by default).

## Post-verify (after the run)
- <how to check the workflow's final result as a whole>

## Running
A workflow runs in the background and requires an explicit opt-in. After the plan is approved, the script `.claude/workflows/<kebab-name>.js` is generated. If branches write to the same files in parallel, `isolation:'worktree'` and a git repository are needed.

## Diagram (optional, on request)
A self-contained HTML view of this workflow - phases, parallel branches, and loops with their stop conditions - can be generated on request as `PLAN.diagram.html` (see `reference/diagram-html.md`). Not produced unless asked.
