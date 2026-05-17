---
name: paper-code-audit
description: Compare a paper's claims against its public codebase. Use when the user asks to audit a paper, check code-claim consistency, verify reproducibility of a specific paper, or find mismatches between a paper and its implementation.
---

# Paper-Code Audit

Run the `/audit` workflow. Read the prompt template at `../prompts/audit.md` for the full procedure.

Agents used: `researcher`, `verifier`

Output: audit report in `outputs/`.

<!-- SEABRIDGE_GOAL_SKILL_INHERITANCE_START -->
## /goal Inheritance

This skill inherits the SeaBridgeAI `/goal` default protocol. Frame the work with a persistent goal, Definition of Done, validation plan, risks, dependencies, expected artifacts, and completion evidence. Do not claim completion until the DoD is validated or a hard blocker is documented.

Canonical protocol: `C:\Users\adelm\SeaBridgeAI\everything-claude-code\protocols\GOAL_PROTOCOL.md`
<!-- SEABRIDGE_GOAL_SKILL_INHERITANCE_END -->
