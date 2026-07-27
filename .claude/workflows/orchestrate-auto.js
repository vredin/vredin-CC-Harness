export const meta = {
  name: 'orchestrate-auto',
  description: 'Background conductor: read backlog, worker does each task non-stop, Opus verifies, loop until empty or blocked',
  phases: [
    { title: 'Backlog', detail: 'one agent reads docs/TASK.md → open tasks' },
    { title: 'Work', detail: 'per task: worker plans or implements' },
    { title: 'Verify', detail: 'Opus conductor reviews each' },
  ],
}

// args: { project: "/abs/path", mode: "dry-run" | "write", cap: number }
// - dry-run  = READ-ONLY validation of the loop: worker produces a plan, Opus reviews. No writes.
// - write    = SEQUENTIAL real work: worker writes failing test → implements → green → lint; Opus+Diablo
//              review the diff; commit. NEVER deploys. Stops the loop on a real BLOCKED verdict.
// args may arrive as an object OR as a JSON string (harness-dependent) — normalize both.
let A = args
if (typeof A === 'string') { try { A = JSON.parse(A) } catch (e) { A = {} } }
A = A || {}
const proj = A.project || ''
const mode = A.mode || 'dry-run'
const cap  = A.cap  || 3

// Safety: never let a worker read/write "whatever cwd happens to be". A missing project path is a hard error.
if (!proj || proj[0] !== '/') {
  log(`ABORT: no absolute project path in args (got ${JSON.stringify(A)})`)
  return { error: 'missing or non-absolute project path in args.project', received: A }
}

const BACKLOG_SCHEMA = {
  type: 'object', required: ['tasks'],
  properties: { tasks: { type: 'array', items: {
    type: 'object', required: ['id', 'title'],
    properties: {
      id: { type: 'string' }, title: { type: 'string' },
      spec_path: { type: 'string' }, blocked: { type: 'boolean' },
      blocked_reason: { type: 'string' },
    } } } },
}
const PLAN_SCHEMA = {
  type: 'object', required: ['summary', 'test_list', 'files'],
  properties: {
    summary: { type: 'string' },
    test_list: { type: 'array', items: { type: 'string' } },
    files: { type: 'array', items: { type: 'string' } },
    risks: { type: 'string' },
  },
}
const VERDICT_SCHEMA = {
  type: 'object', required: ['verdict', 'rationale'],
  properties: { verdict: { enum: ['PASS', 'REVISE', 'BLOCKED'] }, rationale: { type: 'string' } },
}

// ── Phase 1: read the backlog (one agent; the script itself has no filesystem access) ──
phase('Backlog')
const bl = await agent(
  `Read ${proj}/docs/TASK.md (it is LARGE and mixed-format) and extract EVERY open task. Tasks appear in TWO forms:\n` +
  `  (a) markdown table rows: \`| [T-NNN](specs/…) | Title | … |\` — the id is the T-NNN in the first column;\n` +
  `  (b) numbered / bulleted lists: \`N. **T-NNN** — Title\` or \`- **T-NNN** …\`.\n` +
  `Rules:\n` +
  `  • DONE → SKIP: the id or line is struck-through (~~…~~) OR contains ✅ / "DONE" / "done".\n` +
  `  • BLOCKED → include with blocked=true: line has 🚧 / "БЛОК" / "BLOCKED" / "нужен owner" / "needs owner" / "missing secret" / "образцы от заказчика".\n` +
  `  • Everything else that is a T-NNN and not struck/✅ → an OPEN task.\n` +
  `PRIORITY ORDER (put first in the array): any 🔴 or backup/restore/ops-safety task, then "In Progress", then ` +
  `the top sprint section (in its numbered order), then the other Backlog sections top-to-bottom.\n` +
  `For each open task return: id (T-NNN), title (human, trimmed of markup), spec_path (the specs/… path from the ` +
  `link if present, else ""), blocked, blocked_reason. There are likely 15–40 open tasks — return them ALL. Read-only.`,
  { label: 'read-backlog', phase: 'Backlog', schema: BACKLOG_SCHEMA }
)
const open = ((bl && bl.tasks) || []).filter(t => t && !t.blocked)
const blocked = ((bl && bl.tasks) || []).filter(t => t && t.blocked)
const tasks = open.slice(0, cap)
log(`backlog: ${open.length} open, ${blocked.length} blocked; running ${tasks.length} (mode=${mode}, cap=${cap})`)
if (!tasks.length) return { done: true, reason: open.length ? 'all runnable tasks capped out' : 'backlog empty or all blocked', blocked }

// ── dry-run: read-only proof of the loop (plan → Opus review), tasks independent ──
if (mode === 'dry-run') {
  phase('Work')
  const reviewed = await pipeline(tasks,
    (t) => agent(
      `Read the spec ${t.spec_path || ('for ' + t.id)} in ${proj}. Produce an IMPLEMENTATION PLAN ONLY — ` +
      `do NOT write any code or files. Return: summary, test_list (the failing tests to write first), ` +
      `files (paths you would touch), risks. Read-only.`,
      { label: `plan:${t.id}`, phase: 'Work', schema: PLAN_SCHEMA }
    ).then(plan => ({ t, plan })),
    ({ t, plan }) => agent(
      `You are the Opus conductor reviewing a worker's PLAN for ${t.id} — "${t.title}".\n` +
      `PLAN: ${JSON.stringify(plan)}\n` +
      `Judge: is it complete, test-first, in-scope, low-risk? PASS if you'd let the worker build it, ` +
      `REVISE if the plan has gaps, BLOCKED if it can't proceed without the owner. Verdict + one-line rationale.`,
      { label: `verify:${t.id}`, phase: 'Verify', schema: VERDICT_SCHEMA, effort: 'high' }
    ).then(v => ({ id: t.id, title: t.title, verdict: (v && v.verdict) || 'REVISE', rationale: v && v.rationale, plan }))
  )
  return { mode, reviewed: reviewed.filter(Boolean), blocked }
}

// ── write: SEQUENTIAL real work on the shared repo, stop the loop on a real blocker ──
phase('Work')
const done = []
for (const t of tasks) {
  const build = await agent(
    `Implement backlog task ${t.id} — "${t.title}" in ${proj} via the full TDD workflow:\n` +
    `1) write the failing test(s) FIRST and confirm they fail (red);\n` +
    `2) implement the minimum to pass; run ONLY the targeted tests to green;\n` +
    `3) run lint/typecheck from ${proj}/docs/STACK.md.\n` +
    `Operate on the main working tree. DO NOT deploy. DO NOT commit yet (the conductor commits after review).\n` +
    `If you hit a REAL blocker (missing secret, a decision only the owner can make, a destructive op that ` +
    `needs approval) — STOP immediately and say "BLOCKED: <what you need>". Return what you changed + test results.`,
    { label: `build:${t.id}`, phase: 'Work' }
  )
  const v = await agent(
    `You are the Opus conductor + Diablo reviewing the implementation of ${t.id} — "${t.title}" in ${proj}.\n` +
    `WORKER REPORT: ${build}\n` +
    `Read the ACTUAL \`git -C ${proj} diff\` and the new/changed tests. Verify: correct; test-first (the test ` +
    `fails without the change — mentally revert it); in-scope (only files this task needs); no regressions; ` +
    `lint clean. Verdict PASS / REVISE / BLOCKED + rationale citing file:line.`,
    { label: `verify:${t.id}`, phase: 'Verify', schema: VERDICT_SCHEMA, effort: 'high' }
  )
  if (v && v.verdict === 'BLOCKED') { done.push({ id: t.id, status: 'BLOCKED', why: v.rationale }); break }
  if (v && v.verdict === 'REVISE') {
    await agent(
      `Address the reviewer's concerns on ${t.id} in ${proj}: ${v && v.rationale}. Re-run the targeted tests ` +
      `to green + lint. No deploy, no commit.`,
      { label: `revise:${t.id}`, phase: 'Work' }
    )
  }
  await agent(
    `Commit ${t.id} in ${proj} with a proper [CHANGE] message per the commit taxonomy (What/Why/Risk/DA verdict/` +
    `Tested-by). Stage only this task's files (never \`git add -A\`). DO NOT deploy.`,
    { label: `commit:${t.id}`, phase: 'Verify' }
  )
  done.push({ id: t.id, status: 'DONE' })
}
return { mode, done, blocked, note: 'write mode never deploys; run /deploy separately when ready' }
