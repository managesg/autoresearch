---
name: jobs
description: Inspect active background research work including running processes, scheduled follow-ups, and pending tasks. Use when the user asks what's running, checks on background work, or wants to see scheduled jobs.
---

# Jobs

Run the `/jobs` workflow. Read the prompt template at `../prompts/jobs.md` for the full procedure.

Shows active `pi-processes`, scheduled `pi-schedule-prompt` entries, and running subagent tasks.

<!-- SEABRIDGE_GOAL_SKILL_INHERITANCE_START -->
## /goal Inheritance

This skill inherits the SeaBridgeAI `/goal` default protocol. Frame the work with a persistent goal, Definition of Done, validation plan, risks, dependencies, expected artifacts, and completion evidence. Do not claim completion until the DoD is validated or a hard blocker is documented.

Canonical protocol: `C:\Users\adelm\SeaBridgeAI\everything-claude-code\protocols\GOAL_PROTOCOL.md`
<!-- SEABRIDGE_GOAL_SKILL_INHERITANCE_END -->
