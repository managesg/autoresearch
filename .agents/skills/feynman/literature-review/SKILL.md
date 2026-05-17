---
name: literature-review
description: Run a literature review using paper search and primary-source synthesis. Use when the user asks for a lit review, paper survey, state of the art, or academic landscape summary on a research topic.
---

# Literature Review

Run the `/lit` workflow. Read the prompt template at `../prompts/lit.md` for the full procedure.

Agents used: `researcher`, `verifier`, `reviewer`

Output: literature review in `outputs/` with `.provenance.md` sidecar.

<!-- SEABRIDGE_GOAL_SKILL_INHERITANCE_START -->
## /goal Inheritance

This skill inherits the SeaBridgeAI `/goal` default protocol. Frame the work with a persistent goal, Definition of Done, validation plan, risks, dependencies, expected artifacts, and completion evidence. Do not claim completion until the DoD is validated or a hard blocker is documented.

Canonical protocol: `C:\Users\adelm\SeaBridgeAI\everything-claude-code\protocols\GOAL_PROTOCOL.md`
<!-- SEABRIDGE_GOAL_SKILL_INHERITANCE_END -->
