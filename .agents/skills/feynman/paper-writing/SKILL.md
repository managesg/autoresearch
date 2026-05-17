---
name: paper-writing
description: Turn research findings into a polished paper-style draft with sections, equations, and citations. Use when the user asks to write a paper, draft a report, write up findings, or produce a technical document from collected research.
---

# Paper Writing

Run the `/draft` workflow. Read the prompt template at `../prompts/draft.md` for the full procedure.

Agents used: `writer`, `verifier`

Output: paper draft in `papers/`.

<!-- SEABRIDGE_GOAL_SKILL_INHERITANCE_START -->
## /goal Inheritance

This skill inherits the SeaBridgeAI `/goal` default protocol. Frame the work with a persistent goal, Definition of Done, validation plan, risks, dependencies, expected artifacts, and completion evidence. Do not claim completion until the DoD is validated or a hard blocker is documented.

Canonical protocol: `C:\Users\adelm\SeaBridgeAI\everything-claude-code\protocols\GOAL_PROTOCOL.md`
<!-- SEABRIDGE_GOAL_SKILL_INHERITANCE_END -->
