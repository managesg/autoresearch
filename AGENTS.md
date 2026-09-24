# AutoResearch — Agent Instructions

SYSTEM_ID: SEABRIDGE_AGENT_SYSTEM_V1 · Shared agent system (skills, protocols, validators): `C:\Users\adelm\SeaBridgeAI\everything-claude-code` (ECC).
This file is the single instruction source for every coding agent in this repo; `CLAUDE.md` imports it.

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

<!-- SEABRIDGE_GOAL_PROTOCOL_START -->
## Goal Protocol Default

For non-trivial work, settle what done means and how you will prove it before editing, then keep going until it is proven or you reach a real blocker. `/goal` in a prompt asks for exactly this.

- **Scope from evidence.** Build what the request needs, grounded in the current code, git history, tests, and the current plan. Do not invent product functionality or sustainability, emissions, climate, or financial data; preserve source, provenance, and units. Treat memory, handoffs, and old summaries as leads to verify, not facts.
- **Done means** the requested behavior works, tests that would catch its failure pass, there are no unexplained regressions, and you know the state of the tree. Scale checks to risk: tenant isolation, auth, persistence, AI grounding, and cross-repo contracts warrant broader tests. Do not re-run checks nothing has changed since.
- **When stuck,** change strategy after two failures of the same approach. Keep working on independent parts; stop only at an approval boundary or an external dependency, and name it.
- **Report** what changed, how it was verified, what remains or is risky, and any check you skipped and why. Never call unverified work done.

Full protocol, for long multi-phase work: C:\Users\adelm\SeaBridgeAI\everything-claude-code\protocols\GOAL_PROTOCOL.md
<!-- SEABRIDGE_GOAL_PROTOCOL_END -->

## Purpose

Autonomous ML training-loop experimentation: modify `experiments/train.py` to minimise `val_bpb` under a fixed ~5-minute wall-clock budget per run. Full loop specification: `program.md`. This repo is also one component of the SeaBridge co-scientist stack (`AI_COSCIENTIST_STACK.md`; entry point `.\sustainability_research.ps1 -Scenario A|B|C`).

## Experiment loop rules

- Edit only `experiments/train.py`; `experiments/prepare.py` is read-only. No new packages beyond `pyproject.toml`.
- Run: `uv run experiments/train.py > run.log 2>&1` (never let run output flood context). Metric: `grep "^val_bpb:\|^peak_vram_mb:" run.log`; empty output means a crash — read `tail -n 50 run.log`. Kill a run that exceeds 10 minutes and treat it as a failure.
- Record every run in `results.tsv` (tab-separated, untracked; never commit it).
- **Scope of autonomy:** when Alejandro starts an experiment session, that start is the approval for the loop to commit to, and `git reset --hard HEAD~1` its own just-made commit on, the session's `autoresearch/<tag>` branch (cut from `master`), and to keep iterating without asking until interrupted. It authorizes nothing else: no push, no merge, no other branch, no new packages, no paid API calls. Outside a user-started session, normal rules apply and the loop does not run.

## Boundaries

- Research outputs reach `manageesg-backend` only through its adapter at `C:\Users\adelm\SeaBridgeAI\manageesg-backend\seabridge_ai\src\sustainability_ai\ai_agents\autoresearch\`; handoff artifacts go to `manageesg-backend/autoresearch/handoff/`. Do not import from or modify the backend from this repo.
- Paper2Agent (`paper2agent-suite/Paper2Agent`, `paper2agent-suite/Paper2AgentBench`) and Feynman runs are manual opt-in only: they take 30 minutes to 3+ hours and incur model costs. Never trigger them from hooks.
- `archived/AI-CoScientist` is archived; do not invoke it.
- Session and project memory stay in ECC (`ck`, `continuous-learning-v2`); never route coding-session notes into the backend runtime memory. `claude-mem` stays removed.
- Reports go under `docs/reports/`, logs under `logs/`, run artifacts under `artifacts/agent-runs/`; keep the repo root clean.

## On demand

Small or single-file work needs none of these.

| When | Use |
|---|---|
| Architecture or codebase questions | `graphify/output/GRAPH_REPORT.md` (and the graphify wiki index, when one has been generated); after code edits, rebuild with `python3 -c "from graphify.watch import _rebuild_code; from pathlib import Path; _rebuild_code(Path('.'))"` |
| Checking an experimental hypothesis against evidence | Berry MCP (`start_run`, `add_span`, `audit_trace_budget`; proceed only if `flagged=false`) |
| Converting a paper repo into an MCP agent | `.\paper2agent-suite\Paper2Agent\paper2agent.ps1 -ProjectDir <dir> -GithubUrl <url>` |
| Benchmarking a paper agent | `.\paper2agent-suite\Paper2AgentBench\paper2agent-bench.ps1 -Action install|register-mcp|labels|analyze` |
| Writing a new agent or RAG pipeline | patterns from ECC `references/awesome-llm-apps` (reference only; never copy code or auto-run examples) |
| External library docs (PyTorch, Triton) | web search; Context7 is not configured here |
