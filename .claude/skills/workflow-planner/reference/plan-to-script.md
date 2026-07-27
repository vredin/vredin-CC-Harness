# From plan to script

How to turn an atomic workflow plan into a JS script. All the translation logic lives here.

## The main principle

**What gets parallelized is decided by DEPENDENCIES between branches, not by roles.**

- Branches independent of each other - run at once (`parallel` or `pipeline`).
- Branch B needs branch A's result - run in sequence (a sequence, or `pipeline` stages).

A classic mistake: treating different roles as parallelism. "Researcher -> writer" is a queue (pipeline), not parallelism: the writer waits for the researcher. Parallelism is between same-type independent chunks (3 researchers on 3 topics).

## The unit of an agent's work

An agent's branch = **a bundle of plan atoms by role**, not a single atom. An agent gets a meaningful, coherent chunk whole. Do not split trivial linear work into roles - one atom per agent shatters the context and agents start stumbling.

## Mapping plan -> primitive

| In the plan | In the script |
|---|---|
| Branches independent, the next step needs all results at once | `await parallel([() => agent(a), () => agent(b)])` |
| Each item passes through stages, no common barrier needed | `await pipeline(items, stage1, stage2)` |
| Role after role with a dependency | `const a = await agent(...); const b = await agent(\`...${a}\`)` |
| Parallel branches -> then assembly from all | `parallel` -> then one `agent` with all results in the prompt |
| A logical stage | `phase('Name')` before its agents |
| Report progress to the user | `log('...')` |

The default is `pipeline`. A `parallel` barrier only when the next step genuinely needs ALL results (dedup, merge, single report, early-exit on zero).

## Passing data (agents are blind)

Each agent starts with a clean context. A previous branch's result reaches the next one ONLY through the prompt:

```js
const research = await agent('Research topic X')
const article = await agent(`Write an article based on the research:\n${research}`)
```

If the result must be processed by code (not pasted as text), use a `schema`, and `agent()` returns an object:

```js
const data = await agent('Return the bugs found', { schema: BUGS_SCHEMA })
data.bugs.forEach(...)
```

In the plan, mark each dependent branch with "input: result of branch X" - that is the hand-off point into the prompt.

**Final check before generating the script: for EVERY dependent branch, is the previous branch's result actually written into the text of its prompt? An agent is blind - if the data is not in the prompt string, it will not see it.**

## verify in a workflow

An atomic verify ("how to check the step") maps onto a workflow in one of three ways:

1. **A pipeline verify stage** - a separate skeptic agent checks the branch's result (adversarial check):
   ```js
   pipeline(items, item => agent(`Do: ${item}`), res => agent(`Check the result, find errors: ${res}`))
   ```
2. **A check built into the prompt** - tell the agent directly: "after editing, run test X and confirm it passes".
3. **A post-check after the run** - manual or a separate step, once the workflow returns the result. Marked in the plan as "post-verify".

Choice: an expensive/important branch - a verify stage (an independent agent); a cheap one - a built-in check; the final assembly - a post-check.

**Independence of the check.** Prefer a check the generator did not produce itself. A deterministic gate first - a test, linter, type-check or compile that passes or fails on its own. If the judgment needs a model, use a SEPARATE skeptic agent with a clean context, not the same agent grading its own output. A self-report on the same context is the workflow version of testing on the data you trained on: it confirms what the agent already believes, not whether the result is real.

## Write isolation

If several agents write to the same files in parallel - `agent(..., {isolation:'worktree'})` (a git worktree per agent). Requires a git repository and is expensive (setup + disk). Only when they would otherwise conflict. If agents only read, or write to different files, isolation is not needed.

## Partial failure and budget

- **For a COLLECTION of interchangeable results, `.filter(Boolean)` after `parallel`/`pipeline`, then check enough survived.** Some branches return nothing. Filter out the empties, then verify the count is enough to assemble from. If fewer than the norm came back, degrade EXPLICITLY - tell the user the data is incomplete. Never glue `null`/`undefined` into the text of the next task.
- **For a few NAMED, distinct branches that are all required, do NOT filter - guard each by name.** Filtering collapses positions and would mislabel a survivor (B printed as "Input A"). Destructure `const [a, b] = await parallel([...])` (positions are preserved; a failed branch is `null` in its slot) and guard: `if (!a || !b) { log(...); return null }`.
- **Check `budget.remaining()` before a big batch.** Before spawning a large run, compare the cost against what is left. If it will not fit - cut into batches or stop with a clear message. Do not fail in the middle of the run.
- **Resume and re-verify.** The script saves and continues itself, so a break is recoverable. After any interruption, re-check the final result for completeness before trusting it.

## Loops with a stop condition

If a branch repeats until a goal is met (loop-until-dry, loop-until-budget, retry-until-pass), the loop MUST have an explicit way to stop - never an open `while (true)`:

- **Iteration cap.** A hard upper bound (a `for` up to N, or a counter), so a stuck loop ends instead of running to the 1000-agent backstop.
- **No-progress break.** Stop after K rounds that add nothing new - track what was already seen and compare, do not just count. Picking the "best of many" tries is choosing noise unless the bar rises with the number of attempts.
- **Budget guard.** `while (budget.total && budget.remaining() > COST) {...}` so the loop cannot run the account dry; guard on `budget.total` or with no target `remaining()` is `Infinity` and the loop never ends.

State the stop condition in the plan next to the looping branch, not only in the script.

## Parallelization anti-patterns

- **Confusing roles with parallelism.** Processing stages (research -> draft -> edit) run in sequence, not at once.
- **`parallel` where `pipeline` is enough.** A barrier makes fast branches wait for the slowest. With no inter-element dependency - `pipeline`.
- **Splitting atoms into agents.** An agent is a bundle of atoms, not one micro-step.
- **Forgetting to pass data.** An agent is blind; if you did not reference the previous branch's result in the prompt, the agent will not see it.
- **Chasing agent count.** More than 16 concurrent just queue up anyway; spawning entities for no reason is overhead. Split by meaning, not for a round number.
- **A barrier for a flatten/map/filter.** Do a transform with no inter-element dependency inside a pipeline stage, not in a parallel barrier.
