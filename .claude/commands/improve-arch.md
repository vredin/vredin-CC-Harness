---
name: improve-arch
description: 'Find deepening opportunities in the codebase. Wraps the improve-codebase-architecture skill with project context (CONTEXT.md, ADRs, KNOWLEDGE.md).'
argument-hint: [optional: subsystem path, e.g. app/services/]
allowed-tools: Read, Grep, Glob, Bash
model: opus
---

> **Style:** Load `caveman-distillate` skill (deactivate if user wants verbose architecture discussion).

# /improve-arch — Refactor for depth

Target: `${ARGUMENTS:-<whole codebase>}`

---

## STEP 1 — Load skill + project context

Read in order:
1. `.claude/skills/improve-codebase-architecture/SKILL.md` (process)
2. `.claude/skills/improve-codebase-architecture/LANGUAGE.md` (glossary — use these terms exactly)
3. `docs/CONTEXT.md` (project domain glossary — gives names to good seams)
4. `docs/adr/*.md` (decisions the skill should NOT re-litigate)
5. `docs/KNOWLEDGE.md` (existing architectural patterns)

---

## STEP 2 — Run the skill's 3-phase workflow

### Phase 1: Explore
Use Agent tool with `subagent_type=general-purpose` to walk the target. Note:
- Shallow modules (interface ≈ implementation complexity)
- Tightly-coupled modules leaking across seams
- Untested or hard-to-test interfaces
- Pass-through functions (fail the deletion test)

### Phase 2: Present candidates
Numbered list, each candidate:
- Files involved
- Problem statement (using LANGUAGE.md terms)
- Plain-English solution
- Benefits (locality / leverage / testability)

### Phase 3: Grilling loop
For each accepted candidate, Socratic dialog:
- "If we did this, what's the new interface?"
- "Which dependency category — in-process / local-substitutable / remote-owned / true external?"
- "How many adapters justify the seam?"

For interface design (when needed): spawn 3 sub-agents in parallel per skill's
INTERFACE-DESIGN.md (Minimalist, Flexible, Pragmatist). Compare by depth, locality, seam placement.

---

## STEP 3 — Outputs

After grilling:
1. **Refactor plan** in `docs/specs/T-NNN-refactor-<slug>.md` — accepted candidates, in order.
2. **ADR** in `docs/adr/<NNNN>-<slug>.md` — IF a candidate was REJECTED for a non-obvious reason. Per skill: rejection reasoning has architectural weight worth recording.
3. **CONTEXT.md update** — IF the grilling surfaced new domain terms or invalidated existing ones. Inline edit.

---

## STEP 4 — Shared Knowledge Base integration (auto + ask)

### 4.1 — Search for prior art (always)
Resolve backend per `docs/OUTLINE-CONTRACT.md` § Backend, search Best Practices for similar
refactor patterns.
- If found → link from new spec / refactor doc.
- If not found → fresh judgment.

### 4.2 — ADR publish to project collection
For each ADR-NNN created in this session, read `.claude/.setup.json` →
`outline.auto_publish.adrs_to_project`.
- **`outline.mode = "cloud"`** and flag `true` (default) → `mcp__outline__create_document`
  (title `ADR-NNN: <slug>`, collection = `outline.project_collection_id`, parent = Decisions sub-page).
- **`outline.mode = "github"` or `"local"`** → no-op per `docs/OUTLINE-CONTRACT.md` § Backend —
  `docs/adr/ADR-NNN-*.md` committed to this project's own repo IS the publication. Just confirm
  the file is committed, print that, move on.

### 4.3 — Reusable patterns to shared (ask + flag)
If a candidate pattern from this refactor seems generalizable beyond this project:

1. Ask user: "Is this pattern likely to apply to ≥2 projects? [yes / no / not sure]"
2. If `yes` AND `outline.auto_publish.reusable_patterns_to_shared = true` → resolve backend
   per `docs/OUTLINE-CONTRACT.md` § Backend, publish to Best Practices (github: category
   `best-practices`, slug = pattern name) with body:
   ```
   **Origin**: <project name>, ADR-NNN
   **Context**: <when this pattern applies>
   **Pattern**: <description>
   **Forces**: <what trade-offs it resolves>
   **Anti-patterns to avoid**: <what NOT to do>
   ```
3. If `not sure` → save with tag `[CANDIDATE]` in title/slug; reviewable later via /self-audit.
4. If `no` → keep local only in docs/PATTERNS.md.

---

## Designed for explicit invocation only

NOT for /loop. Architecture refactors require human attention and aren't autonomous.

Typical chain: `/improve-arch` → produces refactor spec → `/todo add` references the spec → `/orchestrate` executes.

---

## Hard rules

- ALWAYS use LANGUAGE.md vocabulary: module / interface / seam / adapter / depth. Reject "service", "boundary", "API alone".
- "Adapter threshold": one adapter = hypothetical seam (don't add yet). Two = real seam.
- "Interface is the test surface" — proposals that require testing past the interface mean the module is wrong-shaped.
- Do NOT propose refactors that contradict existing ADRs. If a refactor implies overturning an ADR, it must be marked as such and supersede the old ADR explicitly.
- Cost: this command runs Opus + spawns sub-agents. Use rarely (refactor sessions, not daily).
