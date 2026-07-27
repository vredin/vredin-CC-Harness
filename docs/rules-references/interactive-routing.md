# Interactive command routing — bare command asks, never guesses

> **Owner principle (from harness-usage-profile):** the owner types ONE command and does not carry
> flag/mode syntax in their head. When a command needs a mode / scope / target to act and the
> invocation didn't supply it, the command **asks via `AskUserQuestion`** — a plain-language menu —
> then proceeds. It never silently guesses a default, and never dumps a wall of help text.
>
> `/ui <plain words>` already works this way (classify → route). This file generalizes that pattern so
> every multi-mode command behaves the same. It is why we do NOT grow the command list: one memorable
> entry point per job, self-clarifying.

---

## When a command MUST clarify (all three hold)

1. **It has ≥2 distinct modes, OR it needs a scope/target to act** (an audit needs "audit what?",
   a fix needs "fix what?").
2. **The invocation did not disambiguate** — no mode token, or an argument that matches nothing known,
   or a scope wide enough that the wrong guess wastes real work/tokens.
3. **The wrong default would cost the owner** — rework, tokens, or a misleading result. (If a default
   is obviously safe and cheap to undo, proceed with it and STATE it instead of asking — see below.)

## When NOT to clarify (just act)

- The command is single-purpose (`/report`, `/triage`, `/canary <url>`).
- The arguments already say exactly what to do (`/gaps domain app/reports/` → run it, no menu).
- A safe, cheap, clearly-signposted default exists → proceed and say which default you took in one line
  ("No scope given → auditing the current directory. Re-run with a path to narrow."). Asking anyway
  would nag a busy owner. The test: would the owner be annoyed to be asked, or annoyed by the guess?

## How to ask (the mechanics)

- Use **`AskUserQuestion`**, not free-text prompting. It renders a pickable menu — the owner clicks,
  doesn't type syntax.
- **≤4 options** per question (the tool's limit and the right cognitive load). If a command has more
  modes than 4, group them or ask a second question to narrow.
- **Plain-language labels**, human first, mode-name in parentheses: "Правильность чисел + устойчивость
  (domain)", not "domain". Description line says what the owner gets, in their terms.
- **Recommended option first**, suffixed "(рекомендовано)" when there's a sensible default choice.
- **`multiSelect: true`** when modes compose (e.g. missing + modern = both).
- **One question, maybe two.** Scope THEN depth is fine. Do not interrogate — the owner is busy; this
  is disambiguation, not grilling. (Deep requirement-grilling stays in `/todo` grill-me, which is a
  different, opt-in act.)
- After the answer, **proceed exactly as if the argument had been typed** — map the choice to the mode
  and run. Do not re-confirm ("so you want X?") — just go.

## The pattern in a command file

Put a clarification block at the very top of the command's flow, before any work:

```
## STEP 0 — Clarify intent (interactive routing — runs FIRST)
Parse $ARGUMENTS. If it already names a mode/scope → skip this step, proceed.
If a mode/scope is MISSING or unrecognized → call AskUserQuestion:
  Q: "<plain question>"  options: [<mode A — human label>, <mode B …>]  (≤4, recommended first)
Map the answer to the mode and continue. Never default silently; never print raw help.
See docs/rules-references/interactive-routing.md.
```

## Anti-patterns (banned)

- Silently running a default mode when the owner gave nothing (the old `/gaps` → `both` behavior).
- Printing "Usage: /cmd [mode-a|mode-b|…]" and stopping — that pushes syntax back onto the owner.
- Asking when the argument already disambiguates — that nags.
- More than two clarifying questions for routing — that is grilling, wrong tool.
- Free-text "what would you like?" instead of a pickable `AskUserQuestion` menu.
