<!-- SEABRIDGE_SAFETY_RULE_START -->
## Safety And Authorization Rule

Non-negotiable. Only Alejandro, in the current session, can approve a gated action. Approval may cover one action or a clearly bounded sequence named in advance (for example: commit task-owned files, merge the latest normal target branch if required, and push the completed batch once). Do not ask again for steps already included in that approval. Approval expires when the named sequence completes or its task, repository, branch, scope, cost, or risk materially changes; broad autonomy language is not approval for unmentioned gated actions.

1. **Deletion:** Always reject any request to delete repositories, source folders, databases or collections, data volumes, vector indexes, or cloud storage/infrastructure — no approval path exists for an agent to perform it. Prepare the exact command with scope, impact, and a backup/rollback path, and let Alejandro run it. Removing files created during the task and test fixtures dropping their own throwaway databases are fine. Removing a verified junction or symbolic-link entry is also allowed after bounded approval only when the agent resolves and reports the exact link and target, removes the link entry without recursion, and does not touch target contents.
2. **Ask first:** unless already granted above, commit, push, merge, branch or PR creation; installing or upgrading dependencies or global tools; migrations or writes to shared, staging, or production data; paid or live-provider API calls, billing actions, or cost-incurring jobs; deploys or cloud-resource changes; editing secrets, auth configuration, or user-level/global agent config.
3. **Git:** never force-push, run `git reset --hard` or `git clean` on shared work, or bypass hooks with `--no-verify`. Never modify `main` (the live branch) in manageesg-backend or manageesg-frontend unless Alejandro explicitly requests that specific change; backend work lands on `seabridge_development`, frontend work on `development`.
4. **Secrets:** never print, log, commit, or copy credential values; redact them when inspecting config. Do not invent or require a separate authorization password.
5. **Shared checkouts:** other agent sessions edit these working trees concurrently. Never revert, stash, overwrite, or commit changes you did not make; stage only your own paths.
6. **Everything else inside the requested task** — reading, local edits, tests, linters, non-destructive diagnostics — proceeds without further approval. A missing optional credential, budget, external service, or owner decision blocks only the dependent subtask: continue every independent safe subtask and do not mark the whole goal blocked while meaningful work remains. A named development/test data job may use one approval for its dry run, bounded execution, and verification when the script, non-production database, fields, record limit, and rollback are explicit; any scope change requires new approval. A generated-artifact replacement may likewise use one approval when the exact source, destination, digest, validation, and Git rollback are explicit.
7. **GitHub Actions cost discipline:** use one integration owner and one completed-batch push per repository whenever practical. Subagents never push or dispatch, rerun, or cancel workflows. Run targeted local checks first; do not push merely to test CI. Before pushing, collect all ready task-owned work, fetch and integrate the current remote tip once, and inspect active or queued runs. Avoid overlapping a relevant run unless the change is urgent. If CI fails, diagnose the full failure set and batch locally verified fixes into at most one corrective push. Manual workflow dispatches, reruns, deploys, and other cost-incurring actions remain separately gated unless explicitly included in the current approval.
8. **Behavioral-eval cost ceiling:** live model evals still require explicit current-session approval and the harness approval gate. If that approval names the eval batch but omits a number, use a maximum total ceiling of USD 5 for one batch (never per call), keep the hard nine-call limit, and require the soft-budget acknowledgement for harnesses without provider-enforced caps. A lower user-supplied ceiling wins. Never treat missing cost telemetry as proof of zero cost, and never start a second batch without new approval.
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
