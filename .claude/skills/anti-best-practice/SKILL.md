---
name: anti-best-practice
description: "Use this skill when you encounter a failure, mistake, or unexpected error caused by your own actions, or when you learn a critical lesson that prevents future errors. It guides you in documenting the failure in `docs/FAILS.md` to build a repository of 'what not to do' and 'how to fix it'."
---

# Anti-Best-Practice: The Art of Failing Forward

## Overview

This skill turns failures into assets. When you fumble, break something, or realize a "best practice" wasn't actually the best for this specific context, you MUST log it. This creates a persistent memory of lessons learned, preventing the same mistakes from recurring.

## When to Use

- **After a failed tool call sequence** that wasted time or resources.
- **When a 'fix' broke something else** (regression).
- **When you misunderstood the codebase** or environment.
- **When you violate a project rule** (e.g., language consistency, commit atomicity).
- **When you encounter a 'gotcha'** that isn't documented elsewhere.

## Workflow

1.  **Analyze the Failure**:
    *   **What happened?** (Symptom)
    *   **Why did it happen?** (Root Cause)
    *   **How did you fix it?** (Fix)
    *   **How to catch it next time?** (Detect Next Time)

2.  **Format the Entry**:
    Use the format from `docs/FAILS.md`:

    ```markdown
    ### F-NNN — [Short Title]

    **Date**: YYYY-MM-DD
    **Symptom**: [What was observed — error message, test failure, wrong behavior]
    **Root Cause**: [What actually caused it — not the symptom, the cause]
    **Fix**: [What resolved it]
    **Detect Next Time**:
    - [Check X before Y]
    - [grep for pattern Z]
    - [run command W to verify]
    ```

3.  **Update `docs/FAILS.md`**:
    *   Read the current content to determine the next F-NNN number.
    *   Append your new entry at the end (before "Adding New Entries" section).
    *   Increment F-NNN from the last entry.

## Guiding Principles

- **Be Honest**: Don't sugarcoat the mistake. If you hallucinated a library, say so.
- **Be Technical**: "I messed up" is not a reason. "I assumed `date-fns` was installed because `package.json` had similar dependencies" is a reason.
- **Focus on Detection**: The most important part is **Detect Next Time** — it should be actionable instructions for catching this before it happens again.
- **Cross-reference**: If this failure leads to a new pattern, add it to `docs/PATTERNS.md` too.
