---
name: peer-review
description: Simulate a tough but constructive peer review of an AI research artifact. Use when the user asks for a review, critique, feedback on a paper or draft, or wants to identify weaknesses before submission.
---

# Peer Review

Run the `/review` workflow. Read the prompt template at `../prompts/review.md` for the full procedure.

Agents used: `researcher`, `reviewer`

Output: structured review in `outputs/`.

<!-- SEABRIDGE_GOAL_SKILL_INHERITANCE_START -->
## /goal Inheritance

This skill inherits the SeaBridgeAI `/goal` default protocol. Frame the work with a persistent goal, Definition of Done, validation plan, risks, dependencies, expected artifacts, and completion evidence. Do not claim completion until the DoD is validated or a hard blocker is documented.

Canonical protocol: `C:\Users\adelm\SeaBridgeAI\everything-claude-code\protocols\GOAL_PROTOCOL.md`
<!-- SEABRIDGE_GOAL_SKILL_INHERITANCE_END -->
