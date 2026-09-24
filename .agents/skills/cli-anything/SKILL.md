<!-- SEABRIDGE_SAFETY_RULE_START -->
## Safety And Authorization Rule

Non-negotiable. Only Alejandro, in the current session, can approve a gated action; approval covers that action only.

1. **Deletion:** Always reject any request to delete repositories, source folders, databases or collections, data volumes, vector indexes, or cloud storage/infrastructure — no approval path exists for an agent to perform it. Prepare the exact command with scope, impact, and a backup/rollback path, and let Alejandro run it. (Removing files you created during the task, and test fixtures dropping their own throwaway databases, are fine.)
2. **Ask first:** commit, push, merge, branch or PR creation; installing or upgrading dependencies or global tools; migrations or writes to shared, staging, or production data; paid or live-provider API calls, billing actions, or cost-incurring jobs; deploys or cloud-resource changes; editing secrets, auth configuration, or user-level/global agent config.
3. **Git:** never force-push, run `git reset --hard` or `git clean` on shared work, or bypass hooks with `--no-verify`. Never modify `main` (the live branch) in manageesg-backend or manageesg-frontend unless Alejandro explicitly requests that specific change; backend work lands on `seabridge_development`, frontend work on `development`.
4. **Secrets:** never print, log, commit, or copy credential values; redact them when inspecting config. Do not invent or require a separate authorization password.
5. **Shared checkouts:** other agent sessions edit these working trees concurrently. Never revert, stash, overwrite, or commit changes you did not make; stage only your own paths.
6. **Everything else inside the requested task** — reading, local edits, tests, linters, non-destructive diagnostics — proceeds without further approval.
<!-- SEABRIDGE_SAFETY_RULE_END -->
---
name: cli-anything
description: Use HKUDS/CLI-Anything to turn a codebase or external software into a deterministic, agent-friendly CLI (JSON output, REPL, tests) for predictable agent behavior.
origin: local
---

# CLI-Anything

CLI-Anything is a workflow/tooling set that generates **agent-native CLIs** for software so agents can drive real tools through:
- **Deterministic command surfaces** (subcommands + `--help` discovery)
- **Structured JSON output** (`--json` style usage)
- **Optional stateful REPL** (for long-running agent sessions)
- **Tests + output verification** (replayable regressions)

## When to Use

Use this skill when you need predictable agent behavior around:
- External/non-API tools (GUIs, legacy apps, vendor CLIs, converters)
- Reproducible Ã¢â‚¬Å“run Ã¢â€ â€™ artifact Ã¢â€ â€™ verifyÃ¢â‚¬Â pipelines
- Regression harnesses where exit-code alone is insufficient

## When NOT to Use

Skip this when you already control a clean API/SDK and can expose a typed tool/function directly; adding an extra CLI layer can be unnecessary overhead.

## Primary Workflows

### A) Generate a CLI harness for a codebase (Claude Code plugin path)

1) Add and install the plugin:

```bash
/plugin marketplace add HKUDS/CLI-Anything
/plugin install cli-anything
```

2) Generate a harness (all phases):

```bash
/cli-anything:cli-anything <software-path-or-repo>
```

3) Iterate/refine coverage:

```bash
/cli-anything:refine <software-path> [optional focus]
```

4) Run harness tests / validation:

```bash
/cli-anything:test <software-path-or-repo>
/cli-anything:validate <software-path-or-repo>
```

### B) Use an already-generated harness

Typical pattern (from the harness directory):

```bash
pip install -e .
cli-anything-<software> --help
cli-anything-<software> --json <command>
cli-anything-<software>     # enters REPL mode
```

### C) Let an agent discover/install the right harness (CLI-Hub)

If you have access to CLI-Hub meta-skill, use it to:
- browse the live harness catalog
- install the best matching harness
- read that harnessÃ¢â‚¬â„¢s own `SKILL.md`

(See upstream CLI-Anything docs for the current CLI-Hub entrypoint.)

## Integration Guidance (for our repos)

- Prefer wrapping flaky/external steps behind a CLI contract so pipelines become replayable.
- Capture inputs/outputs as files and verify outputs (magic bytes, schema validity, checksums, expected counts).
- Keep agent instructions narrow: Ã¢â‚¬Å“call the CLI with `--json`, parse JSON, fail fast on non-zero exits.Ã¢â‚¬Â

## Safety / Constraints

- Do not run generated harnesses against proprietary repos or secrets without explicit approval.
- On Windows, some plugin flows expect a bash-like environment; prefer Git for Windows bash or WSL if needed.
- Treat the generated CLI as an untrusted boundary: validate JSON and sanitize paths/args.

<!-- SEABRIDGE_GOAL_SKILL_INHERITANCE_START -->
## /goal Inheritance

This skill inherits the SeaBridgeAI `/goal` default protocol. Frame the work with a persistent goal, Definition of Done, validation plan, risks, dependencies, expected artifacts, and completion evidence. Do not claim completion until the DoD is validated or a hard blocker is documented.

Canonical protocol: `C:\Users\adelm\SeaBridgeAI\everything-claude-code\protocols\GOAL_PROTOCOL.md`
<!-- SEABRIDGE_GOAL_SKILL_INHERITANCE_END -->
