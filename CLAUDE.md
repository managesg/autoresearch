## Safety And Authorization Rule

Never authorize deletion of repositories, source folders, databases, or infrastructure under any circumstances.

> **System-wide policy:** `manageesg-backend/AGENTS_SYSTEM.md` is the governing document for all SeaBridgeAI coding agents. It defines Tier-1 safety rules, authorization gates, cost controls, and destructive-action rejections that apply unconditionally to this repo.

1. Session authorization gate: at session start, request authorization through the team-approved secure channel before any write, destructive, or cost-incurring action.
2. Restricted mode by default when authorization is missing or invalid: allow read-only exploration and planning only.
3. Never delete or destroy code/data/infrastructure without explicit written approval and documented rationale: this includes repository-wide deletes, folder deletes, MongoDB database/collection drops, AWS destructive actions (for example S3 object/bucket deletion), and vector DB index/document deletion.
4. Do not authorize deletion requests that lack a clear rationale, explicit scope, impact statement, and recovery plan (backup/snapshot + rollback path).
5. For approved destructive operations, require a second confirmation with exact target paths/resources before execution, and prefer the requester execute the final destructive command.
6. Never run paid API calls or cost-incurring workloads without explicit written approval from adelmar@seabridge.ai.
7. Use the team-shared authorization password from your secure internal channel when approval is required; never store that password in code, docs, logs, or commits.
# AutoResearch — Claude Code Instructions

## SeaBridgeAI Cross-Agent Skill Contract

`SYSTEM_ID: SEABRIDGE_AGENT_SYSTEM_V1` and
`C:\Users\adelm\SeaBridgeAI\everything-claude-code` are the canonical shared
skill source for Claude Code, Codex, Gemini, Cursor, OpenCode, and future agents.
For non-trivial work, load local docs first, then ECC
`SEABRIDGE_CODING_AGENT_SYSTEM.md`, `repo-integrations/autoresearch.md` if
present, the smallest relevant `sea-*` skill, and the matching workflow/checklist.
Keep reusable guidance in ECC and only AutoResearch/Feynman/Paper2Agent-specific
boundaries here.

> **Co-Scientist Stack**: This repo is part of a unified AI research stack.
> Full tool inventory and sustainability research workflows: [AI_COSCIENTIST_STACK.md](AI_COSCIENTIST_STACK.md)
> Unified entry point: `.\sustainability_research.ps1 -Scenario A` (new ESG question) / `B` (improve agent) / `C` (data intelligence)

## Purpose

Autonomous ML training-loop experimentation. Modifies `experiments/train.py` to minimise `val_bpb` under a fixed 5-minute wall-clock budget per run. The full loop is defined in [program.md](program.md).

## Critical Rules

- **Only edit `experiments/train.py`** — `experiments/prepare.py` is read-only, never touch it.
- **Never stop the loop** — keep iterating until the user manually interrupts.
- **Never install new packages** — only use what is already in `pyproject.toml`.
- Each run: `uv run experiments/train.py > run.log 2>&1` — do NOT let output flood context.
- Log every result to `results.tsv` (TSV, not CSV). Do NOT commit `results.tsv`.
- Branch convention: `autoresearch/<tag>` (e.g. `autoresearch/apr2`).

## Metric

Lower `val_bpb` is better. Extract with:

```bash
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

## Workflow Summary

1. Establish baseline (first run — no changes).
2. Propose change to `experiments/train.py`, commit, run, record.
3. If `val_bpb` improved ? keep commit (advance branch).
4. If equal or worse ? `git reset --hard HEAD~1` (discard).
5. Repeat forever.

## Governing ECC Instructions

This repo inherits the full Everything Claude Code (ECC) governing layer:

- **Rules**: `~/.claude/rules/` (always active — coding style, security, testing, git workflow)
- **Agents**: `~/.claude/agents/` (planner, tdd-guide, code-reviewer, security-reviewer, etc.)
- **Skills**: `~/.claude/skills/` + `C:/Users/adelm/SeaBridgeAI/everything-claude-code/.claude/skills/`

For documentation on ECC itself:

```bash
chub search ecc
chub get ecc/core-overview
```

## Berry Hallucination Detection

Berry MCP is available in this repo (`.mcp.json`). Use it before committing to any experimental hypothesis:

- `audit_trace_budget` — verify that your experimental plan (hypothesis ? change ? expected outcome) has evidence before running
- `detect_hallucination` — verify any factual claim about architecture behavior (e.g., "GeLU will outperform ReLU here because...")

**When proposing a new experiment**:
1. `start_run("hypothesis: <change description>")` 
2. `add_span(text="<evidence from prior results or code inspection>", label="<what this shows>")`
3. `audit_trace_budget(steps=[{"idx":0,"claim":"<hypothesis claim>"}], citations={"0":["<span_id>"]})`
4. Only proceed if `flagged=false`; if flagged, revise the hypothesis or gather more evidence.

## awesome-llm-apps Reference Library

Curated collection of 200+ LLM/agent example apps (LangChain, LangGraph, CrewAI, AutoGen, MCP, RAG, voice). Consult before writing new agents or RAG pipelines.

**Canonical location:** `C:\Users\adelm\SeaBridgeAI\everything-claude-code\references\awesome-llm-apps`
**Pointer:** `references/awesome-llm-apps.md` (this repo)

Reference-only — port patterns, never copy code or auto-run examples.

## Context7 for External Docs

Use Context7 MCP for any external library (PyTorch, Triton, etc.) (not configured locally — only Berry is active in `.mcp.json`. Use web search as fallback for external docs.):

```
Use context7 to fetch the latest PyTorch optimizer docs
```

## Production Integration

Research outputs from this sandbox are consumed by `manageesg-backend` via a thin adapter layer. **Do not import from or modify manageesg-backend from this repo.**

The adapter lives at:
```
manageesg-backend/seabridge_ai/src/sustainability_ai/ai_agents/autoresearch/
  handoff.py              # receives artifacts this sandbox produces
  runner.py               # orchestrates runs from the backend's AI pipeline context
  overnight_audit.py      # production audit using research findings
  regression_harness.py   # regression checks against baselines
  architect.py            # agent architecture design and planning
  diagnostician.py        # runtime diagnostics and failure analysis
  evaluator.py            # evaluates agent output quality and correctness
  loop.py                 # controls the autoresearch iteration loop
  task_dispatcher.py      # routes tasks to the correct sub-agent
```

Handoff artifacts (outputs, logs, result snapshots) are written to `manageesg-backend/autoresearch/handoff/`.

**This repo owns only `experiments/train.py`, `program.md`, and `results.tsv`.** Everything else is either read-only (`experiments/prepare.py`) or consumed externally.

Key files in this repo:
- `experiments/train.py` — training script (the only file agents may edit)
- `experiments/prepare.py` — data preparation (read-only)
- `program.md` — full experiment loop specification
- `results.tsv` — TSV log of all run results (do not commit)
- `analysis.ipynb` — Jupyter notebook for analyzing experiment results and visualizing training curves

## IDE Support

Berry MCP is configured for multiple coding tools:
- Claude Code (`.claude/`)
- Codex (`.codex/`)
- Gemini (`.gemini/`)
- Cursor (`.cursor/`)
- DeepAgents (`.agents/`)

## Paper2Agent Skills Integration

Single source of truth:
- `C:\Users\adelm\SeaBridgeAI\autoresearch\paper2agent-suite\Paper2Agent`
- `C:\Users\adelm\SeaBridgeAI\autoresearch\paper2agent-suite\Paper2AgentBench`

### paper2agent

Purpose:
- Convert paper/code repositories into MCP-backed interactive agents.

Trigger phrases:
- `paper2agent`, `academic paper to agent`, `build paper mcp agent`

Required inputs:
- `project_dir`, `github_url`

Optional inputs:
- `tutorials`, `api`, `benchmark`

Run commands:
- `powershell -ExecutionPolicy Bypass -File .\paper2agent-suite\Paper2Agent\paper2agent.ps1 -ProjectDir <PROJECT_DIR> -GithubUrl <GITHUB_URL>`

### paper2agent-bench

Purpose:
- Evaluate paper agents with Paper2AgentBench.

Trigger phrases:
- `paper2agent-bench`, `paper agent benchmark`, `evaluate paper mcp agent`

Run commands:
- `powershell -ExecutionPolicy Bypass -File .\paper2agent-suite\Paper2AgentBench\paper2agent-bench.ps1 -Action install`
- `powershell -ExecutionPolicy Bypass -File .\paper2agent-suite\Paper2AgentBench\paper2agent-bench.ps1 -Action register-mcp`
- `powershell -ExecutionPolicy Bypass -File .\paper2agent-suite\Paper2AgentBench\paper2agent-bench.ps1 -Action labels`
- `powershell -ExecutionPolicy Bypass -File .\paper2agent-suite\Paper2AgentBench\paper2agent-bench.ps1 -Action analyze`

MCP verification:
- `claude mcp list`

Policy:
- Manual opt-in only. Do not auto-run expensive Paper2Agent generation from hooks.
- End-to-end runs may take 30 minutes to 3+ hours and incur API/model costs.

## Memory

Purpose:
- Use the right memory layer for research work: session continuity, project continuity, or deployed agent runtime memory.

Trigger phrases:
- `memory`
- `remember this`
- `session memory`
- `project memory`
- `retrieve prior context`
- `agent memory`

Required inputs:
- memory intent: `session`, `project`, or `runtime`

Optional inputs:
- `ide` (`claude-code` or `gemini-cli`)
- project path
- backend/runtime context

Run and usage commands:
- `/ck:init`
- `/ck:save`
- `/ck:resume`

Outputs:
- retrieved context block with source attribution
- saved session or project memory summary
- explicit routing to the correct memory system

Storage and source of truth:
- `ck`: ECC-native per-project working context
- `continuous-learning-v2`: reusable learned behaviors and instincts
- `manageesg-backend` `sustainability_ai.memory`: runtime memory for deployed agents only

Compatibility and retrieval order:
- Retrieval order:
  1. local repo docs and `AGENTS.md`/`CLAUDE.md`
  2. ECC project memory via `ck` and `continuous-learning-v2`
  3. backend durable memory only for application agent flows

Safety notes:
- `claude-mem` has been removed from the active SeaBridgeAI memory stack; do not reinstall or re-enable it without a separate approval.
- do not duplicate the same fact into all memory systems unless explicitly requested
- do not route coding-session notes into backend runtime memory

## graphify

This project has a graphify knowledge graph at graphify/output/.

Rules:
- Before answering architecture or codebase questions, read graphify/output/GRAPH_REPORT.md for god nodes and community structure
- If graphify/output/wiki/index.md exists, navigate it instead of reading raw files
- After modifying code files in this session, run `python3 -c "from graphify.watch import _rebuild_code; from pathlib import Path; _rebuild_code(Path('.'))"` to keep the graph current


## Token Optimization Tools

Two tools are installed globally for token efficiency:

- **caveman** — compresses agent output ~65–75% (`/caveman` skill, `claude plugin install caveman@caveman`). Reference: `everything-claude-code/references/caveman/`
- **codeburn** — token usage dashboard (`npx codeburn` or `npm install -g codeburn`). Reference: `everything-claude-code/references/codeburn/`


## SeaBridgeAI Agent Baseline

Repo structure, build/test/lint/typecheck/startup commands, recurring lessons, and artifact policy are local here and in ECC `repo-integrations/autoresearch.md`. All coding agents must follow ECC self-verification, controlled auto mode, and review collaboration: plan before edits, update tests when practical, prove red/green when practical, run targeted checks, broaden checks when risk warrants it, document skipped tests, and never claim completion from code changes alone. Allowed auto steps are formatting, lint/typecheck fixes, test discovery, import cleanup, small tested refactors, approved report/log moves, docs path fixes, and read-only scans. Commits, pushes, dependency installs, migrations, production data changes, auth/security changes, billing changes, destructive file operations, yolo/autonomous/dangerous modes, global installs, and long-running training jobs require explicit approval.

Shared skills, Harness Engineering, Agent Shield, and Strix are inherited from ECC. Load ECC `AGENT_SKILLS.md` for `grill-me`, `ubiquitous-language`, `improve-codebase-architecture`, `sea-*` skills, and Harness reviewer skills. Load ECC `docs/harness/HARNESS_ENGINEERING.md` and `scripts/check-harness.ps1` for baseline-aware guardrails. Full vulnerability scans must use the approved ECC wrapper so Agent Shield and Strix run together only on approved local/staging scope.