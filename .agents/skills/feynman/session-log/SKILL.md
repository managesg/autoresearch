---
name: session-log
description: Write a durable session log capturing completed work, findings, open questions, and next steps. Use when the user asks to log progress, save session notes, write up what was done, or create a research diary entry.
---

# Session Log

Run the `/log` workflow. Read the prompt template at `../prompts/log.md` for the full procedure.

Output: session log in `notes/session-logs/`.

<!-- SEABRIDGE_GOAL_SKILL_INHERITANCE_START -->
## /goal Inheritance

This skill inherits the SeaBridgeAI `/goal` default protocol. Frame the work with a persistent goal, Definition of Done, validation plan, risks, dependencies, expected artifacts, and completion evidence. Do not claim completion until the DoD is validated or a hard blocker is documented.

Canonical protocol: `C:\Users\adelm\SeaBridgeAI\everything-claude-code\protocols\GOAL_PROTOCOL.md`
<!-- SEABRIDGE_GOAL_SKILL_INHERITANCE_END -->
