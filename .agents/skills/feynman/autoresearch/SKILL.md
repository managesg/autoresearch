---
name: autoresearch
description: Autonomous experiment loop that tries ideas, measures results, keeps what works, and discards what doesn't. Use when the user asks to optimize a metric, run an experiment loop, improve performance iteratively, or automate benchmarking.
---

# Autoresearch

Run the `/autoresearch` workflow. Read the prompt template at `../prompts/autoresearch.md` for the full procedure.

Tools used: `init_experiment`, `run_experiment`, `log_experiment` (from pi-autoresearch)

Session files: `autoresearch.md`, `autoresearch.sh`, `autoresearch.jsonl`

<!-- SEABRIDGE_GOAL_SKILL_INHERITANCE_START -->
## /goal Inheritance

This skill inherits the SeaBridgeAI `/goal` default protocol. Frame the work with a persistent goal, Definition of Done, validation plan, risks, dependencies, expected artifacts, and completion evidence. Do not claim completion until the DoD is validated or a hard blocker is documented.

Canonical protocol: `C:\Users\adelm\SeaBridgeAI\everything-claude-code\protocols\GOAL_PROTOCOL.md`
<!-- SEABRIDGE_GOAL_SKILL_INHERITANCE_END -->
