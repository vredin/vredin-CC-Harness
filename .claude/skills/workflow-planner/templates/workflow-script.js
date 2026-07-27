// Dynamic Workflow JS script template.
// Generated from workflow-plan.md. One file = one workflow.
// Goes into <project>/.claude/workflows/<kebab-name>.js
// Fill in <...>, remove the unused pattern (parallel OR pipeline), drop the extra comments.

// LANGUAGE: phase/label titles and the agent task prompts are written in the
// language of the user's task, NOT English by default.

export const meta = {
  name: '<kebab-name>',                  // matches the file name
  description: '<one line: what it does>',
  phases: [{ title: '<Phase 1>' }, { title: '<Phase 2>' }],  // one per phase() call
}

// -------------------------------------------------------------
// PATTERN A: independent branches at once, then assembly (parallel = barrier)
// Use when the next step needs ALL results together.
// -------------------------------------------------------------
phase('<Phase 1>')
// parallel keeps POSITIONS: a failed branch is null in its own slot (it does not
// collapse the array), so `a` is always branch A and `b` is always branch B.
const [a, b] = await parallel([
  () => agent('<branch A prompt: role + its atoms>', { label: 'A:<role>', phase: '<Phase 1>' }),
  () => agent('<branch B prompt: role + its atoms>', { label: 'B:<role>', phase: '<Phase 1>' }),
])

phase('<Phase 2>')
// Branch C needs BOTH A and B. NAMED, distinct branches are NOT interchangeable:
// do not .filter(Boolean) here - that collapses positions and would mislabel a
// survivor (B printed as "Input A"). Guard each by name instead.
// (Use .filter(Boolean) only for a COLLECTION of interchangeable results - see Pattern B.)
if (!a || !b) {
  // A failed branch is null - stop instead of stitching null into branch C's prompt.
  log('Phase 2 skipped: A or B failed in Phase 1')
  return null
}
// Both are non-null past the guard - pass them INTO THE PROMPT (the agent is blind).
const c = await agent(
  `<branch C prompt>\n\nInput A:\n${a}\n\nInput B:\n${b}`,
  { label: 'C:<role>', phase: '<Phase 2>' }
)
return c

// -------------------------------------------------------------
// PATTERN B: a flow of items through stages (pipeline = NO barrier, the DEFAULT)
// Each item flows on its own; verify is the second stage.
// -------------------------------------------------------------
// const items = [/* <list of independent units> */]
// const results = await pipeline(
//   items,
//   (item, _orig, i) => agent(`<stage 1: process> ${item}`, { label: `do:${i}`, phase: '<Phase 1>' }),
//   (res, item, i)   => agent(`<stage 2: check the result> ${res}`, { label: `verify:${i}`, phase: '<Phase 2>' }),
// )
// return results.filter(Boolean)

// -------------------------------------------------------------
// STRUCTURED OUTPUT (when the result is processed by code, not as text)
// -------------------------------------------------------------
// const SCHEMA = { type: 'object', properties: { items: { type: 'array', items: { type: 'string' } } }, required: ['items'] }
// const data = await agent('<prompt>', { schema: SCHEMA })   // -> validated object
// data.items.forEach(/* ... */)

// Limits reminder: concurrent min(16, cores-2), at most 1000 per run, <=4096 items per parallel/pipeline call.
// Budget: before a big run, check budget.remaining(); if it won't fit, batch it or stop - don't fail mid-run.
// Not allowed in the script: Date.now(), Math.random(), new Date() with no args. Plain JS only, not TS.

// -------------------------------------------------------------
// SELF-CHECK before treating the script as ready-to-run
// -------------------------------------------------------------
// 1. meta is a clean literal: no variables, calls, spreads or interpolation inside it.
// 2. Only the 5 primitives are used (agent / parallel / pipeline / phase / log) - nothing invented.
// 3. No Date.now(), Math.random() or new Date() without an argument anywhere.
// 4. For every dependent branch, the data from previous branches is written INTO the prompt TEXT.
// 5. parallel (barrier, waits for ALL) vs pipeline (flow, the DEFAULT) is a deliberate choice.
// 6. If the script loops (until-dry / until-budget / retry), it has an EXPLICIT stop:
//    iteration cap + no-progress break + budget guard - never an open while(true).
