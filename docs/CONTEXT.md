# [PROJECT_NAME] — Domain Glossary

> Required by `improve-codebase-architecture` skill. Use these terms exactly in design discussions and ADRs.
> Add terms as the project grows. Drop terms that fall out of use.

## Core domain entities

<!-- Example:
- **Campaign**: A scheduled batch of messages to a target segment of clients.
- **Segment**: A predicate over the clients table; defines who receives what.
- **Outbox**: Persistent queue of messages awaiting send. Survives restart.
-->

## Recurring concepts

<!-- Example:
- **Trigger reason**: Why a campaign draft was created — `manual`, `scheduled`, `event-based`.
- **State machine**: Campaign drafts move: `draft → queued → sending → sent | failed`.
-->

## Banned synonyms

To avoid drift, do NOT use these:
- "service" → use **module** (per `improve-codebase-architecture/LANGUAGE.md`)
- "boundary" → use **seam**
- "API" alone → use **interface** (broader: includes invariants, ordering, error modes)
