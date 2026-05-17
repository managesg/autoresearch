---
name: session-search
description: Search past Feynman session transcripts to recover prior work, conversations, and research context. Use when the user references something from a previous session, asks "what did we do before", or when you suspect relevant past context exists.
---

# Session Search

Use the `/search` command to search prior Feynman sessions interactively, or search session JSONL files directly via bash.

## Interactive search

```
/search <query>
```

Opens the session search UI. Supports `resume <sessionPath>` to continue a found session.

## Direct file search

Session transcripts are stored as JSONL files in `~/.feynman/sessions/`. Each line is a JSON record with `type` (session, message, model_change) and `message.content` fields.

```bash
grep -ril "scaling laws" ~/.feynman/sessions/
```

For structured search across sessions, use the interactive `/search` command.

<!-- SEABRIDGE_GOAL_SKILL_INHERITANCE_START -->
## /goal Inheritance

This skill inherits the SeaBridgeAI `/goal` default protocol. Frame the work with a persistent goal, Definition of Done, validation plan, risks, dependencies, expected artifacts, and completion evidence. Do not claim completion until the DoD is validated or a hard blocker is documented.

Canonical protocol: `C:\Users\adelm\SeaBridgeAI\everything-claude-code\protocols\GOAL_PROTOCOL.md`
<!-- SEABRIDGE_GOAL_SKILL_INHERITANCE_END -->
