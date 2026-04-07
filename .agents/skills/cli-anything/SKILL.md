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
- Reproducible “run → artifact → verify” pipelines
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
- read that harness’s own `SKILL.md`

(See upstream CLI-Anything docs for the current CLI-Hub entrypoint.)

## Integration Guidance (for our repos)

- Prefer wrapping flaky/external steps behind a CLI contract so pipelines become replayable.
- Capture inputs/outputs as files and verify outputs (magic bytes, schema validity, checksums, expected counts).
- Keep agent instructions narrow: “call the CLI with `--json`, parse JSON, fail fast on non-zero exits.”

## Safety / Constraints

- Do not run generated harnesses against proprietary repos or secrets without explicit approval.
- On Windows, some plugin flows expect a bash-like environment; prefer Git for Windows bash or WSL if needed.
- Treat the generated CLI as an untrusted boundary: validate JSON and sanitize paths/args.
