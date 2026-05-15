# Autoresearch Coding Agent System Guide

## SeaBridgeAI Central System Pointer

SYSTEM_ID: SEABRIDGE_AGENT_SYSTEM_V1

Canonical shared coding-agent system: C:\Users\adelm\SeaBridgeAI\everything-claude-code

Use the central system above as the source of truth for reusable skills, workflows, checklists, cross-agent compatibility, self-verification, controlled auto mode, and review collaboration. Repo-local guidance remains authoritative only for autoresearch-specific research tooling, experiment harnesses, and safety overrides. Do not copy central skill bodies into this repo.

Shared skills, Harness Engineering, Agent Shield, and Strix are inherited from ECC. Load ECC `AGENT_SKILLS.md` for `grill-me`, `ubiquitous-language`, `improve-codebase-architecture`, `sea-*` skills, and Harness reviewer skills. Load ECC `docs/harness/HARNESS_ENGINEERING.md` and `scripts/check-harness.ps1` for baseline-aware guardrails. Full vulnerability scans must use the approved ECC wrapper so Agent Shield and Strix run together only on approved local/staging scope.

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
