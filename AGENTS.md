<!-- SEABRIDGE_GOAL_PROTOCOL_START -->
## /goal Default Operating Mode

All SeaBridgeAI coding-agent tasks default to /goal.

Before implementation, establish a persistent execution goal, Definition of Done, validation plan, affected systems, dependencies, risks, expected artifacts, and likely edge cases. Continue the execution loop until the DoD is validated or a hard blocker is documented.

### /goal and Auto-Loop Are the Same Mode

/goal is the user-facing command; auto-loop is the autonomous persistent execution behavior. The agent must not return early after code generation, must not claim completion until validation passes, and must keep working until the Definition of Done is satisfied or a hard blocker is proven. If the task is multi-phase (touches more than 2 files, adds a dependency, requires a schema/migration change, or spans more than one repo), state the expected phases and validation steps before starting. If a non-trivial task finishes unusually quickly, include evidence explaining why it was genuinely small or already validated.

Canonical protocol: C:\Users\adelm\SeaBridgeAI\everything-claude-code\protocols\GOAL_PROTOCOL.md

Compact form: C:\Users\adelm\SeaBridgeAI\everything-claude-code\protocols\GOAL_PROTOCOL_SHORT.md

Do not claim completion from code edits, generated files, or partial tests. Completion requires validated behavior, checked integrations, regression coverage proportional to risk, and documented skipped checks or blockers.

### Completion Evidence Required

Every final report must include files changed, commands run, tests run, validation results, errors encountered, fixes applied, unverified items, remaining risks, and whether the Definition of Done is satisfied. If no tests were run, state why tests were not run, what validation was substituted, and what risk remains. The phrase "complete" is prohibited unless accompanied by validation evidence.

### Anti-Stuck Loop Rule

Timeout/stagnation rule: if a command or approach fails twice, do not repeat it blindly. Inspect logs, change strategy, isolate the problem, reduce scope, use a different validation path, and document the blocker if unresolved. If a process hangs or becomes a hung process, stop it safely, check logs, run a smaller command, verify the environment, and continue with an alternate route.

<!-- SEABRIDGE_GOAL_PROTOCOL_END -->

<!-- SEABRIDGE_SAFETY_RULE_START -->
## Safety And Authorization Rule

Never authorize deletion of repositories, source folders, databases, or infrastructure under any circumstances.

> **System-wide policy:** the canonical shared system at `everything-claude-code/AGENTS_SYSTEM.md` (mirrored locally as `AGENTS_SYSTEM.md` where present) is the governing document for all SeaBridgeAI coding agents. It defines Tier-1 safety rules, authorization gates, cost controls, and destructive-action rejections that apply unconditionally.

1. Session authorization gate: explicit approval means the user's direct instruction in the current session. Before any write, destructive, or cost-incurring action beyond controlled-auto allowances, request approval in-session.
2. Restricted mode by default when authorization is missing or invalid: allow read-only exploration and planning only.
3. Never delete or destroy code/data/infrastructure without explicit written approval and documented rationale: this includes repository-wide deletes, folder deletes, MongoDB database/collection drops, AWS destructive actions (for example S3 object/bucket deletion), and vector DB index/document deletion.
4. Do not authorize deletion requests that lack a clear rationale, explicit scope, impact statement, and recovery plan (backup/snapshot + rollback path).
5. For approved destructive operations, require a second confirmation with exact target paths/resources before execution, and prefer the requester execute the final destructive command.
6. Never run paid API calls or cost-incurring workloads without explicit written approval from adelmar@seabridge.ai.
7. Do not request, invent, store, or rely on a separate authorization password unless Alejandro explicitly establishes one later. Never store secrets in code, docs, logs, or commits.
<!-- SEABRIDGE_SAFETY_RULE_END -->

## Skill Selection Default

Follow the ECC skill-selection default (`everything-claude-code/AGENTS_SYSTEM.md`):
load at most ONE skill per task. A task is simple (no skill needed) when it
touches at most 2 files, adds no dependency, and involves no
auth/tenant/billing/migration/security/production-data/destructive/AI-grounding/
provenance concern. When unsure which skill applies, load only `sea-skill-map`
and follow its routing. Mandatory named triggers are never waived by this
default: cross-repo changes always use `sea-cross-repo-handoff`, and
done/fixed/production-ready claims always use
`sea-verification-before-completion`.
# AutoResearch — Codex Instructions

## SeaBridgeAI Cross-Agent Skill Contract

`SYSTEM_ID: SEABRIDGE_AGENT_SYSTEM_V1` and
`C:\Users\adelm\SeaBridgeAI\everything-claude-code` are the canonical shared
skill source for Claude Code, Codex, Gemini, Cursor, OpenCode, and future agents.
For non-trivial work, load local docs first, then ECC
`SEABRIDGE_CODING_AGENT_SYSTEM.md`, `repo-integrations/autoresearch.md` if
present, the smallest relevant `sea-*` skill, and the matching workflow/checklist.
Keep reusable guidance in ECC and only AutoResearch/Feynman/Paper2Agent-specific
boundaries here.

## Goal Protocol Default

For non-trivial AutoResearch work, `/goal` is the default operating contract.
Load ECC `goal-default` and
`C:\Users\adelm\SeaBridgeAI\everything-claude-code\protocols\GOAL_PROTOCOL.md`
to frame the request with Definition of Done, validation plan, risks,
dependencies, scope, blockers, and artifacts, then continue until validated or
blocked. It does not override experiment-loop constraints, cost gates, or
approval rules.

> **Co-Scientist Stack**: This repo is part of a unified AI research stack.
> Full tool inventory and sustainability research workflows: [AI_COSCIENTIST_STACK.md](AI_COSCIENTIST_STACK.md)
> Unified entry point: `.\sustainability_research.ps1 -Scenario A` (new ESG question) / `B` (improve agent) / `C` (data intelligence)

## Purpose

Autonomous ML training-loop experimentation. Modifies `experiments/train.py` to minimise `val_bpb` under a fixed 5-minute wall-clock budget per run. Full loop specification: [program.md](program.md).

## Critical Rules

- **Only edit `experiments/train.py`** — `experiments/prepare.py` is read-only, never modify it.
- **Never stop the loop** — within a user-started `experiments/train.py` session, iterate autonomously until manually interrupted. Applies only to this experiment loop, never to general coding work.
- **No new packages** — only dependencies already in `pyproject.toml` are allowed.
- Each run: `uv run experiments/train.py > run.log 2>&1`
- Record every result in `results.tsv` (tab-separated). Do NOT commit `results.tsv`.
- Branch convention: `autoresearch/<tag>`, cut from and merged back to the base branch `master`.

## Metric

Lower `val_bpb` wins. Extract:

```bash
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

If empty → run crashed. Read `tail -n 50 run.log` for the stack trace.

## Experiment Loop

1. Baseline: run `experiments/train.py` unmodified, record result.
2. Propose change → edit `experiments/train.py` → `git commit` → `uv run experiments/train.py > run.log 2>&1`
3. Improved (`val_bpb` lower) → keep commit. Else → `git reset --hard HEAD~1` (allowed only inside this experiment loop, on `autoresearch/<tag>` branches, against the loop's own just-made commit).
4. Go to 2.

## Governing ECC Instructions

This repo participates in the Everything Claude Code (ECC) multi-tool system:

- ECC root: `C:/Users/adelm/SeaBridgeAI/everything-claude-code`
- Codex ECC layer: `C:/Users/adelm/SeaBridgeAI/everything-claude-code/.codex/AGENTS.md`
- Shared rules: `~/.claude/rules/`

## Coding-Agent Principles (Always Applied)

These are persistent behavioral guardrails, not optional skills, slash
commands, or triggers. Active user/developer instructions define what to do;
these principles govern how the work is executed across SeaBridgeAI agents —
Claude, Codex, Gemini, OpenCode, local models, and delegated subagents alike.
They are suspended only by direct higher-priority safety, system, or developer
policy. Principles 5-8 form a five-gate execution discipline with principle 1:
scope, gather evidence, reason adversarially, verify, report. Canonical copy:
ECC `AGENTS_SYSTEM.md`. Full playbook:
`everything-claude-code/.claude/skills/karpathy-guidelines/SKILL.md`.

1. **Think Before Coding (scope first):** state assumptions, scope, affected
   files and repos, ownership boundaries, and verification before acting on
   non-trivial work. Name what must not be touched. If the request is
   ambiguous, make one bounded, stated assumption or ask one focused question
   before execution.
2. **Simplicity First:** choose the smallest clear solution that satisfies the
   task. Avoid speculative features, broad abstractions, and complexity that
   the request does not require.
3. **Surgical Changes:** touch only files and lines that trace directly to the
   user's instruction. Mention unrelated issues instead of fixing them
   unilaterally.
4. **Goal-Driven Execution:** define success criteria and verification
   evidence before implementation, then iterate until the goal is met or a
   true blocker is documented.
5. **Evidence Before Reasoning:** read available files, reports, tests, logs,
   git history, source docs, and runtime state before relying on memory or
   plausible assumptions. Remembered facts are hypotheses until verified. A
   prompt implying that something exists is not evidence that it exists.
6. **Adversarial Reasoning:** before implementing or recommending a plan, look
   for ways it can fail — mandatory for cross-repo, security, tenant, data,
   AI, architecture, or cleanup work: stale assumptions, dirty worktrees,
   duplicate recent work, contract drift, generated artifacts, hidden
   dependencies, branch safety, cost/quota risk, and unsafe approval paths.
   Finding problems early beats a confident but brittle plan.
7. **Verification Before Completion:** specify targeted checks before
   claiming success. Run the smallest meaningful validation that proves the
   claim first, then broaden when shared contracts, auth, tenant isolation,
   AI/data, persistence, or user-facing behavior warrant it. Never claim
   completion from code changes, summaries, or confidence alone.
8. **Calibrated Reporting:** final reports must connect the work to the
   request and separate facts from inference: files reviewed and changed,
   commands run, evidence gathered, validation performed, skipped checks,
   residual risks, approval gates, and the next useful action.

- Prefer repository patterns over new abstractions.
- Read first, then edit. Do not act from stale memory when files are available.
- Evidence beats confidence. Never claim completion from code changes alone.
- Preserve user work. Do not revert dirty files you did not create.
- Spend reasoning effort deliberately: use low/medium effort for small,
  well-scoped edits and simple inspection or search; reserve high/max effort
  for orchestration, architecture, adversarial review, and high-risk
  verification. Do not default to max effort — it is an escalation, not a
  baseline. Delegate simple inspection and search to smaller or cheaper
  agents when available. Provider routing and live/paid calls follow ECC
  `AGENTS_SYSTEM.md`'s runtime-routing and guardrail rules; report the model,
  effort tier, and provider used for any non-trivial task in the final report.

---

**Instruction priority** (highest to lowest), consistent with the canonical
precedence in ECC `AGENTS_SYSTEM.md` ("Instruction Precedence And Load Order"):

1. **Tier-1 hard safety rules** (§Safety above + repo-local **`AGENTS_SYSTEM.md`**, which defers to the canonical shared system at `everything-claude-code/AGENTS_SYSTEM.md`). Non-suspendable.
2. Session instructions from the user (may relax anything except Tier-1).
3. This AGENTS.md and repo-local overrides.
4. ECC canonical files (`AGENTS_SYSTEM.md`, `SEABRIDGE_CODING_AGENT_SYSTEM.md`, `AGENT_SKILLS.md`, `.codex/AGENTS.md`).
5. program.md loop specification.

The Coding-Agent Principles (§above) govern HOW every task executes; only the
user may explicitly relax them for a specific task.

## Context Hub (chub)

ECC documentation is available via chub:

```bash
chub search ecc              # browse ECC docs
chub get ecc/core-overview   # installation and quick start
chub get ecc/core-codex      # Codex-specific ECC guidance
```

## Documentation

For external libraries (PyTorch, etc.), use the `context7` MCP tool (Note: Context7 is not registered in `.mcp.json` — only Berry is active. Use web search as fallback for external docs.) or `chub get <provider>/<topic>`.

## IDE Support

Berry MCP is configured for multiple coding tools:
- Claude Code (`.claude/`)
- Codex (`.codex/`)
- Gemini (`.gemini/`)
- Cursor (`.cursor/`) and DeepAgents (`.agents/skills/`) are also configured with Berry MCP.

## graphify

This project has a graphify knowledge graph at graphify/output/.

Rules:
- Before answering architecture or codebase questions, read graphify/output/GRAPH_REPORT.md for god nodes and community structure
- If graphify/output/wiki/index.md exists, navigate it instead of reading raw files
- After modifying code files in this session, run `python3 -c "from graphify.watch import _rebuild_code; from pathlib import Path; _rebuild_code(Path('.'))"` to keep the graph current

## memory

Purpose:
- Route memory requests to the right SeaBridge memory layer for research sessions, project continuity, and runtime agents.

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
- retrieved context block
- saved session or project memory summary
- source attribution for the selected memory layer

Storage and source of truth:
- `ck`: ECC-native per-project working context
- `continuous-learning-v2`: reusable learned behaviors and instincts
- `manageesg-backend` `sustainability_ai.memory`: runtime memory for deployed agents only

Compatibility and retrieval order:
- Retrieval order:
  1. local repo docs and `AGENTS.md`/`CLAUDE.md`
  2. ECC project memory via `ck` and `continuous-learning-v2`
  3. backend durable memory only for actual application agent flows

Safety notes:
- `claude-mem` has been removed from the active SeaBridgeAI memory stack; do not reinstall or re-enable it without a separate approval.
- do not duplicate the same fact into all memory systems unless explicitly requested
- do not wire session/project memory into backend runtime memory from this repo

## paper2agent

Purpose:
- Convert a research-paper code repository into an interactive MCP-backed agent.

Trigger phrases:
- `paper2agent`
- `academic paper to agent`
- `build paper mcp agent`

Required inputs:
- `project_dir`
- `github_url`

Optional inputs:
- `tutorials`
- `api`
- `benchmark`

Run commands:
- `powershell -ExecutionPolicy Bypass -File .\paper2agent-suite\Paper2Agent\paper2agent.ps1 -ProjectDir <PROJECT_DIR> -GithubUrl <GITHUB_URL>`
- `powershell -ExecutionPolicy Bypass -File .\paper2agent-suite\Paper2Agent\paper2agent.ps1 -ProjectDir <PROJECT_DIR> -GithubUrl <GITHUB_URL> -Tutorials "<FILTER>"`
- `powershell -ExecutionPolicy Bypass -File .\paper2agent-suite\Paper2Agent\paper2agent.ps1 -ProjectDir <PROJECT_DIR> -GithubUrl <GITHUB_URL> -ApiKey <API_KEY> -Benchmark`

Outputs:
- `<project_dir>/src/<repo_name>_mcp.py`
- `<project_dir>/src/tools/`
- `<project_dir>/reports/`

Storage path:
- `C:\Users\adelm\SeaBridgeAI\autoresearch\paper2agent-suite\Paper2Agent`

## paper2agent-bench

Purpose:
- Evaluate generated paper agents with the official Paper2AgentBench datasets and scripts.

Trigger phrases:
- `paper2agent-bench`
- `paper agent benchmark`
- `evaluate paper mcp agent`

Required inputs:
- benchmark action: `install`, `register-mcp`, `labels`, `analyze`

Run commands:
- `powershell -ExecutionPolicy Bypass -File .\paper2agent-suite\Paper2AgentBench\paper2agent-bench.ps1 -Action install`
- `powershell -ExecutionPolicy Bypass -File .\paper2agent-suite\Paper2AgentBench\paper2agent-bench.ps1 -Action register-mcp`
- `powershell -ExecutionPolicy Bypass -File .\paper2agent-suite\Paper2AgentBench\paper2agent-bench.ps1 -Action labels`
- `powershell -ExecutionPolicy Bypass -File .\paper2agent-suite\Paper2AgentBench\paper2agent-bench.ps1 -Action analyze`

Outputs:
- benchmark outputs under `eval/` and analysis summaries.

Storage path:
- `C:\Users\adelm\SeaBridgeAI\autoresearch\paper2agent-suite\Paper2AgentBench`

## ai-coscientist

> **ARCHIVED** — Output feeds nowhere automatically in the current pipeline. Feynman covers the research brief; Paper2Agent covers methodology extraction. Archived at `autoresearch/archived/AI-CoScientist/`. Do not invoke unless a structured hypothesis-ranking step is explicitly added to the workflow.

## rtk

RTK (Rust Token Killer) v0.35.0 is installed and active. It proxies shell commands to produce compressed, LLM-optimized output, reducing token consumption by 60–90% on verbose commands.

Binary: `C:\Users\adelm\.local\bin\rtk.exe`
Config: `C:\Users\adelm\AppData\Roaming\rtk\config.toml`

Usage — prefix any shell command with `rtk`:
```
rtk git status
rtk git diff HEAD~1
rtk python experiments/train.py --dry-run
rtk pip install -r requirements.txt
```

Scope: RTK only intercepts Bash/shell tool calls. It does NOT apply to built-in Read/Grep/Glob tools.

Key RTK commands:
- `rtk gain` — show token reduction statistics for the session
- `rtk --version` — confirm binary is reachable



---

## caveman — Token Compression

Caveman compresses agent output ~65–75% using terse "caveman-style" prose that preserves full technical accuracy. Auto-activates via SessionStart hook after install.

**Reference:** `C:\Users\adelm\SeaBridgeAI\everything-claude-code\references\caveman\`

Install (Claude Code):
```bash
claude plugin marketplace add JuliusBrussee/caveman && claude plugin install caveman@caveman
```

Skills:
- `/caveman` — activate compression (intensity: `lite` / `full` / `ultra` / `wenyan`)
- `/caveman-commit` — terse commit messages
- `/caveman-review` — one-line code reviews
- `/caveman-compress` — compress CLAUDE.md ~46% to save input tokens every session

Codex: use `$caveman` in prompts. Gemini: `gemini extensions install caveman`.

---

## codeburn — Token Usage Dashboard

Codeburn tracks AI coding token spend across Claude Code, Codex, Cursor, and others. Reads session data from disk — no API keys needed.

**Reference:** `C:\Users\adelm\SeaBridgeAI\everything-claude-code\references\codeburn\`

Run one-shot with no global install:
```bash
npx codeburn
```

Key commands:
```bash
codeburn              # interactive TUI dashboard (default: 7 days)
codeburn today        # today's spend
codeburn month        # this month
codeburn optimize     # find waste patterns + copy-paste fixes
codeburn status       # compact one-liner summary
codeburn export       # CSV/JSON export
```

## Repository Root Organization Policy

Do not place logs, smoke-test reports, QA reports, readiness reports, deployment
reports, benchmark reports, audit reports, or agent handoffs in the repository
root. Use the following standard locations:

| Content type | Target directory |
|---|---|
| Audit reports | `docs/reports/audits/` |
| Readiness reports | `docs/reports/readiness/` |
| QA reports and results | `docs/reports/qa/` |
| Smoke-test reports | `docs/reports/smoke-tests/` |
| Deployment reports | `docs/reports/deployments/` |
| Benchmark reports | `docs/reports/benchmarks/` |
| Fix/issue reports | `docs/reports/fixes/` |
| Handoff documents | `docs/reports/handoffs/` |
| Conflict logs | `docs/reports/conflicts/` |
| Onboarding guides | `docs/reports/onboarding/` |
| Review reports | `docs/reports/reviews/` |
| Build logs | `logs/build/` |
| Integration logs | `logs/integration/` |
| Playwright logs | `logs/playwright/` |
| Agent logs | `logs/agent/` |
| Runtime logs | `logs/runtime/` |
| Agent run artifacts | `artifacts/agent-runs/` |


## SeaBridgeAI Agent Baseline

Repo structure, build/test/lint/typecheck/startup commands, recurring lessons, and artifact policy are local here and in ECC `repo-integrations/autoresearch.md`. All coding agents must follow ECC self-verification, controlled auto mode, and review collaboration: plan before edits, update tests when practical, prove red/green when practical, run targeted checks, broaden checks when risk warrants it, document skipped tests, and never claim completion from code changes alone. Allowed auto steps are formatting, lint/typecheck fixes, test discovery, import cleanup, small tested refactors, approved report/log moves, docs path fixes, and read-only scans. Commits, pushes, dependency installs, migrations, production data changes, auth/security changes, billing changes, destructive file operations, yolo/autonomous/dangerous modes, global installs, and long-running training jobs require explicit approval.

Shared skills, Harness Engineering, Agent Shield, and Strix are inherited from ECC. Load ECC `AGENT_SKILLS.md` for `grill-me`, `ubiquitous-language`, `improve-codebase-architecture`, `sea-*` skills, and Harness reviewer skills. Load ECC `docs/harness/HARNESS_ENGINEERING.md` and `scripts/check-harness.ps1` for baseline-aware guardrails. Full vulnerability scans must use the approved ECC wrapper so Agent Shield and Strix run together only on approved local/staging scope.
