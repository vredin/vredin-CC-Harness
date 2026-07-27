# Examples

Two contrasting runs: one task fits a workflow, the other does not. The gate's reasoning and the resulting artifact are shown.

---

## Example 1: fits a workflow

**User task:** "Check 20 site pages for SEO issues and assemble a summary report."

**Gate reasoning:** 20 same-type independent units (pages) - they can be checked at once. Plus a final assembly from all results. The volume justifies a background run. -> **Fits.** Parallel checks + a barrier before the synthesis (the report needs all results).

**Plan (workflow-plan.md, short):**

- Phase 1 "Checks" [parallel, branches independent]: one checker agent per page. Branch output: the page's list of SEO issues.
- Phase 2 "Synthesis" [depends on Phase 1]: one agent takes all 20 results and assembles a summary report. Input: all check results.
- Post-verify: eyeball that the report covers 20 pages and has no empty entries.

**Script (`.claude/workflows/seo-check-20.js`):**

```js
export const meta = {
  name: 'seo-check-20',
  description: 'Check 20 pages for SEO and assemble a summary report',
  phases: [{ title: 'Checks' }, { title: 'Synthesis' }],
}

const pages = [/* 20 URLs */]

phase('Checks')
const checks = await parallel(
  pages.map((url, i) => () =>
    agent(`Check the SEO of ${url}: title, meta, headings, alt, speed. Return a list of issues.`,
          { label: `check:${i}`, phase: 'Checks' }))
).then(r => r.filter(Boolean))   // barrier: all are needed for the report

phase('Synthesis')
const report = await agent(
  `Assemble a summary SEO report over 20 pages. Check results:\n${checks.join('\n\n')}`,
  { label: 'synth', phase: 'Synthesis' }
)
return report
```

The `parallel` barrier is justified here: the synthesizer needs ALL checks at once.

---

## Example 2: does NOT fit (a linear plan)

**User task:** "Add a contact form to the landing page: markup, validation, email submission, test."

**Gate reasoning:** This is a linear chain with hard dependencies: validation goes on top of finished markup, submission comes after validation, the test comes after everything. There are no independent chunks for parallelism, no stream of same-type items. Remove parallelism and flow - nothing is lost. -> **Does not fit. A linear plan.**

**Plan (linear-plan.md, short):**

```
Mode: Linear (a hard chain of dependencies, nothing to parallelize)

1. Build the form (fields: name, email, message) -> verify: form is visible on the page, fields render
2. Add client-side validation -> verify: empty submit is blocked, a malformed email is flagged
3. Wire up email submission -> verify: a test request arrives in the mailbox
4. Run an end-to-end test -> verify: filled in -> submitted -> email received, form cleared
```

Here a workflow would only add background-run overhead with no gain - a linear plan is shorter and clearer.
