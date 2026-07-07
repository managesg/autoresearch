# Autoresearch Coding Agent System Guide

<!-- SEABRIDGE_GOAL_PROTOCOL_START -->
## /goal Default Operating Mode

All SeaBridgeAI coding-agent tasks default to `/goal`.

Before implementation, establish a persistent execution goal, Definition of Done, validation plan, affected systems, dependencies, risks, expected artifacts, and likely edge cases. Continue the execution loop until the DoD is validated or a hard blocker is documented.

Canonical protocol: `C:\Users\adelm\SeaBridgeAI\everything-claude-code\protocols\GOAL_PROTOCOL.md`

Compact form: `C:\Users\adelm\SeaBridgeAI\everything-claude-code\protocols\GOAL_PROTOCOL_SHORT.md`

Do not claim completion from code edits, generated files, or partial tests. Completion requires validated behavior, checked integrations, regression coverage proportional to risk, and documented skipped checks or blockers.
<!-- SEABRIDGE_GOAL_PROTOCOL_END -->


## SeaBridgeAI Central System Pointer

SYSTEM_ID: SEABRIDGE_AGENT_SYSTEM_V1

Canonical shared coding-agent system: C:\Users\adelm\SeaBridgeAI\everything-claude-code

Use the central system above as the source of truth for reusable skills, workflows, checklists, cross-agent compatibility, self-verification, controlled auto mode, and review collaboration. Repo-local guidance remains authoritative only for autoresearch-specific research tooling, experiment harnesses, and safety overrides. Do not copy central skill bodies into this repo.

Shared skills, Harness Engineering, Agent Shield, and Strix are inherited from ECC. Load ECC `AGENT_SKILLS.md` for `grill-me`, `ubiquitous-language`, `improve-codebase-architecture`, `sea-*` skills, and Harness reviewer skills. Load ECC `docs/harness/HARNESS_ENGINEERING.md` and `scripts/check-harness.ps1` for baseline-aware guardrails. Full vulnerability scans must use the approved ECC wrapper so Agent Shield and Strix run together only on approved local/staging scope.

## Instruction File Architecture

Authoritative AutoResearch instruction files:

1. `AGENTS_SYSTEM.md` - cross-agent AutoResearch operating system, safety, workspace, and research/tool-running boundaries.
2. `AGENTS.md` - generic/Codex-style execution instructions.
3. `CLAUDE.md`, `CODEX.md`, `GEMINI.md`, and `OPENCODE.md` - thin per-agent adapters where tooling benefits from explicit files.
4. ECC `SEABRIDGE_CODING_AGENT_SYSTEM.md` and `AGENT_SKILLS.md` - canonical reusable skills, workflows, and shared governance.

Do not recreate repo-local `AGENT.md` or `AGENT_SKILLS.md`. Tools should load the standard files above. Feynman, Graphify, Paper2Agent, Strix, Terrabit, and the co-scientist-orchestrator dispatcher are intentionally promoted into ECC as canonical+wrapper skills (`feynman`, `graphify`, `paper2agent`, `strix`, `terrabit`, `co-scientist-orchestrator`); load those for command reference instead of re-deriving usage from source. Any other source-owned research-tool skill not listed here may remain with its source tool unless intentionally promoted into ECC.

Before non-trivial work, load:

- `C:\Users\adelm\SeaBridgeAI\everything-claude-code\SEABRIDGE_CODING_AGENT_SYSTEM.md`
- `C:\Users\adelm\SeaBridgeAI\everything-claude-code\repo-integrations\autoresearch.md`
- the smallest relevant `sea-*` skill from `skills\sea-*` or `.agents\skills\sea-*`
- matching `workflows\` and `checklists\`

## Repo Baseline

- Project structure, build commands, test commands, lint/typecheck commands, local startup examples, recurring lessons, and artifact policy are documented in local `AGENTS.md`, `CLAUDE.md`, subproject docs, and ECC `repo-integrations\autoresearch.md`.
- Write reports/logs only under `docs/reports`, `logs`, `test-results`, or `artifacts/agent-runs`, except tool-native generated outputs documented by the specific research tool.

## Required Execution Loop

- Plan before edits.
- Write or update relevant tests when practical.
- Prove the test fails on old behavior when practical.
- Prove focused tests pass after the fix.
- Run broader checks when risk warrants it.
- Document skipped tests and why.
- Never claim completion from code changes alone.

## Controlled Auto Mode

Allowed without repeated prompts: formatting, lint/typecheck fixes, test discovery, import cleanup, small tested refactors, moving logs/reports into approved folders, docs link/path fixes, and safe read-only scans.

Requires explicit approval: commits, pushes, dependency installs, migrations, production data changes, auth/security changes, billing changes, destructive file operations, yolo/autonomous/dangerous permission modes, global installs, and long-running training jobs.
