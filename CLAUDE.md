# AutoResearch — Claude Code

SYSTEM_ID: SEABRIDGE_AGENT_SYSTEM_V1

All shared rules, the experiment-loop scope, and boundaries live in `AGENTS.md`, imported here so Claude Code and Codex read the same text:

@AGENTS.md

## Claude Code specifics

- `/goal` is a Claude Code UI command, not a skill; never invoke `Skill(goal)`.
- Berry is registered for Claude Code in `.mcp.json`; `.claude/rules/berry.md` loads every session but only matters when Berry tools are in use.
- Subagents load this file, and `AGENTS.md` through the import, on their own (built-in Explore and Plan agents do not). Give them only task-specific context.
