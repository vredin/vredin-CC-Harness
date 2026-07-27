# Dynamic Workflow primitives

Reference for the Workflow tool: what actually exists in the API and what is a fabrication. The skill builds the JS script on this knowledge.

Source of truth: the official docs at https://code.claude.com/docs/en/workflows and the Workflow tool description itself.

## What a Dynamic Workflow is

It is deterministic orchestration of subagents by a JS script. The script is not "a program that does the work" but a list of instructions: which agents to launch, in what order, which in parallel, which in sequence, and what to do with their answers. Control flow (what runs in parallel, what runs sequentially) is encoded in the script and executed literally - not "at the model's discretion".

It runs in the background; the result arrives via notification. It requires an explicit opt-in from the user (it is expensive in tokens). The script is auto-saved and supports resume.

## Script structure

```js
export const meta = {
  name: 'kebab-case-name',
  description: 'One line - what it does',
  phases: [{ title: 'Phase 1' }, { title: 'Phase 2' }],  // one per phase() call
}
// body: async context, you can await directly
phase('Phase 1')
const x = await agent('...')
return x   // returned as the final result
```

`meta` is required and must be a PURE literal - no variables, function calls, spreads, or interpolation. Required fields: `name`, `description`. Optional: `phases`, `whenToUse`, `model`.

## The 5 primitives (only these)

**`agent(prompt, opts?)`** - launch a subagent. Without a schema it returns the final text (a string). With `opts.schema` (a JSON Schema) it returns a validated object (the model retries on mismatch). Returns `null` if the user skips the agent (filter with `.filter(Boolean)`).
- `opts.label` - label in the progress view
- `opts.phase` - explicit phase assignment (important inside parallel/pipeline, to avoid racing the global phase() state)
- `opts.schema` - JSON Schema for structured output
- `opts.agentType` - a custom subagent from `.claude/agents`. Works only if the role is **registered at the start of the session** - the Workflow runtime does not hot-reload a role file added mid-session; an unknown name errors with "agent type ... not found".
- `opts.model` - override the model. By default do NOT set it - the agent inherits the main-loop model, which is usually right. **Exception - an explicit user rule wins:** if the user's CLAUDE.md requires always naming the model for subagents / `agent()` calls, follow it and set `opts.model` explicitly (`opus` for hard tasks, `sonnet` for simple/mechanical ones). With no such rule, omit it when unsure which tier fits; under such a rule, do not omit - default to `opus` for anything non-trivial.
- `opts.effort` - reasoning-effort level of the subagent (`low` | `medium` | `high` | `xhigh` | `max`); omit to inherit the session effort. Use `low` for cheap mechanical stages, higher tiers only for the hardest verify/judge stages.
- `opts.isolation: 'worktree'` - its own git worktree (expensive; only when agents write to files in parallel and would otherwise conflict; requires a git repository)

**`parallel(thunks[])`** - a BARRIER: launches all thunks at once and waits until ALL finish. Array elements are functions `() => agent(...)` (so they start under parallel's control, not immediately). A failed thunk yields `null` in the result (the call itself does not throw) - filter with `.filter(Boolean)`. Use when the next step needs ALL results at once.

**`pipeline(items, ...stages)`** - a FLOW with no barrier: each item goes through all stages on its own. Item A can be at stage 3 while B is still at stage 1. This is the DEFAULT for multi-stage work. A stage is a function `(prevResult, originalItem, index) => ...`. A failed stage drops the item to `null` and skips its remaining stages. `items` are NOT wrapped in `() =>` (unlike parallel).

**`phase(title)`** - start a new phase; subsequent `agent()` calls are grouped under it in the progress view.

**`log(message)`** - a progress line for the user.

## Also available (not primitives, but available in the body)

- `args` - the value passed into Workflow as `args` (for parameterizing named workflows).
- `budget` - the turn's token budget: `budget.total` (null if not set), `budget.spent()`, `budget.remaining()`.
- `workflow(nameOrRef, args?)` - run another saved workflow as a sub-step (one level of nesting).

## parallel vs pipeline - the main fork

- `parallel` = a gate. All start, but the script does not advance until all finish. Needed when a common result of all is required (dedup, merge, single report, early-exit on zero).
- `pipeline` = a conveyor. Each item flows on its own. Faster in wall-clock. The default.

Rule: pipeline by default; a parallel barrier only when the result of ALL agents is genuinely needed at once. A plain flatten/map/filter in the middle, with no inter-element dependency, is not a reason for a barrier - do the transform inside a pipeline stage.

## Limits and runtime constraints

- Concurrent: `min(16, cores - 2)` agents. Excess queue up and run as slots free (you may pass more items than the concurrency cap - they just queue).
- A single `parallel`/`pipeline` call accepts at most **4096 items** per call; passing more is an explicit error, not a silent truncation. For larger sets, split into batches.
- Total per run: up to 1000 agents across the whole workflow (a runaway-loop backstop).
- The script is plain JS, NOT TypeScript (type annotations, interfaces, generics do not parse).
- Unavailable: `Date.now()`, `Math.random()`, `new Date()` with no arguments (they break resume) - pass time via `args`, get variety via index/label. No filesystem or Node API access from inside the script.
- Every `agent()` starts with a CLEAN isolated context: it sees neither the conversation nor other agents. Everything it needs goes into the prompt.

## Depth and nesting (workflow agents are leaves)

A workflow-spawned agent does NOT receive the Agent tool - it cannot spawn its own subagents. Verified empirically on 2026-06-24 (three probe runs: the default workflow agent, and even `agentType: 'general-purpose'` with full tools, all reported the Agent tool unavailable - they see only `TaskCreate`, a session task tracker). This is not in the official docs; treat it as a tested fact, not a guess.

Consequence:
- **Inside a workflow, depth/scale comes only from the script primitives** - `parallel` (width), `pipeline` (flow), `workflow()` (nested orchestration, one level). A branch cannot fan out into sub-workers by itself.
- **True nested subagents** (a subagent spawning subagents, up to **5 levels** deep - Claude Code v2.1.172) live in the **regular Agent tool + `.claude/agents`** path, OUTSIDE the Workflow tool (the agent-constructor domain). The depth limit is a fixed 5; each level is an isolated context, so tokens grow with depth. Prefer width (a flat fan-out) and reach for depth only when a sub-task is itself a large decomposition that needs its own isolated fan-out. (Agent-tool nesting is documented but has reported flakiness - GitHub issue #19077.)

So: if a task needs a worker that itself splits into sub-workers, that is NOT a Workflow branch - route it to the Agent-tool / `.claude/agents` path.

## Fabrications (these do NOT exist - do not use)

- `isolation: "isolated"` / `isolation: "fresh"` - do not exist. Context isolation is the default anyway; for an "independent opinion" (judge panel, skeptic) no separate option is needed - just pass the data into the prompt as a string.
- `EnterWorktree` / `ExitWorktree` inside the script - not allowed. These are session-scoped MCP tools, not primitives; they switch the CWD of the whole session. For parallel write isolation use `agent(..., {isolation:'worktree'})`, or have the subagent run `git worktree add` itself via Bash.
- There is no sixth primitive. Only agent / parallel / pipeline / phase / log.
