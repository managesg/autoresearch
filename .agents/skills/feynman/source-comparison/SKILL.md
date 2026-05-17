---
name: source-comparison
description: Compare multiple sources on a topic and produce a grounded comparison matrix. Use when the user asks to compare papers, tools, approaches, frameworks, or claims across multiple sources.
---

# Source Comparison

Run the `/compare` workflow. Read the prompt template at `../prompts/compare.md` for the full procedure.

Agents used: `researcher`, `verifier`

Output: comparison matrix in `outputs/`.

<!-- SEABRIDGE_GOAL_SKILL_INHERITANCE_START -->
## /goal Inheritance

This skill inherits the SeaBridgeAI `/goal` default protocol. Frame the work with a persistent goal, Definition of Done, validation plan, risks, dependencies, expected artifacts, and completion evidence. Do not claim completion until the DoD is validated or a hard blocker is documented.

Canonical protocol: `C:\Users\adelm\SeaBridgeAI\everything-claude-code\protocols\GOAL_PROTOCOL.md`
<!-- SEABRIDGE_GOAL_SKILL_INHERITANCE_END -->
