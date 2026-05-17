---
name: watch
description: Set up a recurring research watch on a topic, company, paper area, or product surface. Use when the user asks to monitor a field, track new papers, watch for updates, or set up alerts on a research area.
---

# Watch

Run the `/watch` workflow. Read the prompt template at `../prompts/watch.md` for the full procedure.

Agents used: `researcher`

Output: baseline survey in `outputs/`, recurring checks via `pi-schedule-prompt`.

<!-- SEABRIDGE_GOAL_SKILL_INHERITANCE_START -->
## /goal Inheritance

This skill inherits the SeaBridgeAI `/goal` default protocol. Frame the work with a persistent goal, Definition of Done, validation plan, risks, dependencies, expected artifacts, and completion evidence. Do not claim completion until the DoD is validated or a hard blocker is documented.

Canonical protocol: `C:\Users\adelm\SeaBridgeAI\everything-claude-code\protocols\GOAL_PROTOCOL.md`
<!-- SEABRIDGE_GOAL_SKILL_INHERITANCE_END -->
