# Output Style Routing — Detailed Rules

> Referenced from `workflow.md`. Read when authoring commands that produce human-facing reports.

---

## caveman-distillate (token economy — ALWAYS active)

- All commands load it as default
- Strips filler words, articles, hedging
- Fragments OK
- Output ~65-85% shorter than naive AI prose
- Applied to: tool calls, status updates, internal artifacts, code review findings

## humanizer (anti-AI-prose — applied to FINAL human-facing output)

- Strips «delve», «tapestry», «pivotal», em-dash overuse
- Removes sycophantic openers («Great question…»)
- Removes promotional language («seamlessly», «cutting-edge»)
- Keeps facts/numbers/code intact, only prose changes

**Applied to:**
- `/report` daily status (humans read in morning)
- `/docs sync` auto-generated content (devs read for onboarding)
- `/self-audit` remediation file (you decide which to apply)
- `/gaps` audit report (prioritization basis)
- `/intent` PRD (contract for team)
- `/decompose` ADRs/Epics (architecture review)

## caveman + humanizer together

- caveman fights LLM verbosity at generation time
- humanizer fights LLM prose-mannerisms at finalization time
- They compose: terse + natural

## NOT applied with humanizer

- Tables (already structured)
- Code blocks (semantic, can't paraphrase)
- Diff blocks in self-audit (exact citations)
- Direct quotes from source files (in /general VERIFIED claims)
