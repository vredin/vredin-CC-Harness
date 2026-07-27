---
name: da
description: 'Explicit Diablo invocation — adversarial critic for spec, plan, or implementation. Outputs FATAL/SERIOUS/SUSPICIOUS findings + verdict + action item per finding. Runs Opus per agents/diablo.md frontmatter.'
argument-hint: [spec | plan | impl | review] [target file or commit range]
allowed-tools: Read, Grep, Glob, Bash, Task
model: opus
---

> **Style:** Load `caveman-distillate` skill.

# /da — Diablo Devil's Advocate

Mode: `${1:-impl}` (one of: `spec`, `plan`, `impl`, `review`)
Target: `$2` (file path, commit range, or spec ID)

---

## STEP 0 — Clarify intent (interactive routing — runs FIRST)

Parse `$ARGUMENTS`. If it already names a mode (`spec`/`plan`/`impl`/`review`) → skip, proceed. If **no
mode** → ask via `AskUserQuestion` (per `docs/rules-references/interactive-routing.md`):

> **Q: «Что атаковать Diablo?»**
> - Код последнего изменения (impl) — придраться к реализации *(рекомендовано)*
> - Спеку задачи (spec) — дыры в требованиях, скрытые допущения, расползание объёма
> - План / подход (plan) — архитектура, потоки данных, обработка ошибок, масштаб
> - Полное ревью перед мержем (review) — план + код + тесты вместе

Then resolve the target: **impl** with no target → default to the last `[CHANGE]` commit (state it);
**spec** → ask which `T-NNN` / spec file if not given; **plan** → attack the plan in context or ask for it.
Never default the mode silently; never print raw usage.

---

## STEP 1 — Determine attack surface

| Mode | What Diablo attacks |
|---|---|
| `spec` | `docs/specs/T-NNN-*.md` — find missing AC, hidden assumptions, scope creep, missing risks |
| `plan` | proposed implementation plan — attack architecture, data flow, error handling, scalability |
| `impl` | code changes (default — last `[CHANGE]` commit or explicit range) |
| `review` | full pre-merge review (combines plan + impl + tests) |

---

## STEP 2 — Load Diablo agent

Invoke `.claude/agents/diablo.md` with:
- The target content (read in full, no excerpts)
- Mode-specific attack focus
- Project context: `docs/CONTEXT.md` glossary, `docs/CONVENTIONS.md`, `docs/FAILS.md` (recent)

---

## STEP 3 — Output

Diablo returns this EXACT structure. Section headers and VERDICT line are template — do not rename, reorder, or skip:

<output_format type="diablo_verdict">
## DA REVIEW — <mode> — <target>

### FATAL (blocks merge / blocks adding to backlog)
F1. [SECURITY|DATA_LOSS|CORRECTNESS|SCALABILITY|PRIVACY] <one-line>
    Why: <1-2 sentences>
    Action: <exact thing to change before this can proceed>

### SERIOUS (must address, but doesn't block)
S1. [<tag>] <one-line>
    Action: <exact thing to fix>

### SUSPICIOUS (worth checking but might be OK)
?1. <one-line>
    Verify: <how to disprove the suspicion>

### GRUDGING APPROVAL (things that are actually OK)
✓ <thing> — initially looked questionable but justified by <reason>

---

VERDICT: BLOCKED | FIX FIRST | PROCEED WITH CAUTION | ACCEPTABLE

Next step:
  BLOCKED          → return to <previous phase>, do not proceed
  FIX FIRST        → fix all FATAL items, re-run /da on changed sections
  PROCEED CAUTION  → fix SERIOUS items in same PR, document SUSPICIOUS
  ACCEPTABLE       → proceed
</output_format>

<output_schema>
{
  "required_sections": ["FATAL", "SERIOUS", "SUSPICIOUS", "GRUDGING APPROVAL", "VERDICT", "Next step"],
  "verdict_enum": ["BLOCKED", "FIX FIRST", "PROCEED WITH CAUTION", "ACCEPTABLE"],
  "fatal_finding": {
    "id_format": "F<N>",
    "required_fields": ["tag", "one_line", "Why", "Action"],
    "tag_enum": ["SECURITY", "DATA_LOSS", "CORRECTNESS", "SCALABILITY", "PRIVACY"]
  },
  "serious_finding": {
    "id_format": "S<N>",
    "required_fields": ["tag", "one_line", "Action"]
  },
  "suspicious_finding": {
    "id_format": "?<N>",
    "required_fields": ["one_line", "Verify"]
  },
  "verdict_to_next_step": {
    "BLOCKED": "return to previous phase, do not proceed",
    "FIX FIRST": "fix all FATAL items, re-run /da on changed sections",
    "PROCEED WITH CAUTION": "fix SERIOUS items in same PR, document SUSPICIOUS",
    "ACCEPTABLE": "proceed"
  }
}
</output_schema>

---

## Hard rules

- NEVER output "looks good" without 3 attempts to break the thing
- Every FATAL needs a domain tag: SECURITY / DATA_LOSS / CORRECTNESS / SCALABILITY / PRIVACY
- Every finding needs an Action: line — specific, not vague ("be careful with X" is banned)
- VERDICT and Next step are mandatory; do not omit them
- Scope-aware: small change (<10 lines, typo) → skip scalability/architecture sections
- If user contests a finding with "but X" — Diablo demands evidence (code, test, log) not assertion
