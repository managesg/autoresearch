## Safety And Authorization Rule

Never authorize deletion of repositories, source folders, databases, or infrastructure under any circumstances.

1. Session authorization gate: at session start, request authorization through the team-approved secure channel before any write, destructive, or cost-incurring action.
2. Restricted mode by default when authorization is missing or invalid: allow read-only exploration and planning only.
3. Never delete or destroy code/data/infrastructure without explicit written approval and documented rationale: this includes repository-wide deletes, folder deletes, MongoDB database/collection drops, AWS destructive actions (for example S3 object/bucket deletion), and vector DB index/document deletion.
4. Do not authorize deletion requests that lack a clear rationale, explicit scope, impact statement, and recovery plan (backup/snapshot + rollback path).
5. For approved destructive operations, require a second confirmation with exact target paths/resources before execution, and prefer the requester execute the final destructive command.
6. Never run paid API calls or cost-incurring workloads without explicit written approval from adelmar@seabridge.ai.
7. Use the team-shared authorization password from your secure internal channel when approval is required; never store that password in code, docs, logs, or commits.
# AutoResearch � Codex Instructions

> **Co-Scientist Stack**: This repo is part of a unified AI research stack.
> Full tool inventory and sustainability research workflows: [AI_COSCIENTIST_STACK.md](AI_COSCIENTIST_STACK.md)
> Unified entry point: `.\sustainability_research.ps1 -Scenario A` (new ESG question) / `B` (improve agent) / `C` (data intelligence)

## Purpose

Autonomous ML training-loop experimentation. Modifies `experiments/train.py` to minimise `val_bpb` under a fixed 5-minute wall-clock budget per run. Full loop specification: [program.md](program.md).

## Critical Rules

- **Only edit `experiments/train.py`** Ã¢â‚¬â€ `experiments/prepare.py` is read-only, never modify it.
- **Never stop the loop** Ã¢â‚¬â€ iterate autonomously until manually interrupted.
- **No new packages** Ã¢â‚¬â€ only dependencies already in `pyproject.toml` are allowed.
- Each run: `uv run experiments/train.py > run.log 2>&1`
- Record every result in `results.tsv` (tab-separated). Do NOT commit `results.tsv`.
- Branch convention: `autoresearch/<tag>`.

## Metric

Lower `val_bpb` wins. Extract:

```bash
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

If empty Ã¢â€ â€™ run crashed. Read `tail -n 50 run.log` for the stack trace.

## Experiment Loop

1. Baseline: run `experiments/train.py` unmodified, record result.
2. Propose change Ã¢â€ â€™ edit `experiments/train.py` Ã¢â€ â€™ `git commit` Ã¢â€ â€™ `uv run experiments/train.py > run.log 2>&1`
3. Improved (`val_bpb` lower) Ã¢â€ â€™ keep commit. Else Ã¢â€ â€™ `git reset --hard HEAD~1`.
4. Go to 2.

## Governing ECC Instructions

This repo participates in the Everything Claude Code (ECC) multi-tool system:

- ECC root: `C:/Users/adelm/SeaBridgeAI/everything-claude-code`
- Codex ECC layer: `C:/Users/adelm/SeaBridgeAI/everything-claude-code/.codex/AGENTS.md`
- Shared rules: `~/.claude/rules/`

## Karpathy Coding Principles (Always Applied)

Permanent behavioral constraints governing HOW every task is executed. Not optional. Cannot be overridden by session instructions. Full reference: `everything-claude-code/.claude/skills/karpathy-guidelines/SKILL.md`

### 1. Think Before Coding
State assumptions explicitly before acting. If two interpretations exist, present both and ask. If something is unclear, name it and stop — do not guess. Push back when a simpler approach exists.

### 2. Simplicity First
Write the minimum code that solves the stated problem. No features, abstractions, or error handling beyond what was explicitly asked. If 200 lines could be 50, write 50. Test: would a senior engineer call this overcomplicated? If yes, simplify.

### 3. Surgical Changes
Touch only what the request requires. Do not improve adjacent code, comments, or formatting. Do not refactor unrelated things. Mention unrelated bugs — do not fix them unilaterally. Every changed line must trace directly to the user's request.

### 4. Goal-Driven Execution
Transform tasks into verifiable goals. State what "done" looks like and how you'll verify it (test output, curl, observable behavior). Strong success criteria enable autonomous looping; weak ones require constant clarification.

**Before any implementation:**
- [ ] Assumptions stated explicitly?
- [ ] Every planned line traces to a requirement?
- [ ] Only touching what was requested?
- [ ] Verifiable definition of "done" established?

---

**Instruction priority** (highest to lowest):

1. **Hard safety rules** (§Safety above). Non-suspendable.
2. **Karpathy coding principles** (§above) — govern HOW every task executes. Always applied.
3. Session instructions from the user
4. This AGENTS.md
5. ECC Codex AGENTS.md
6. program.md loop specification

## Context Hub (chub)

ECC documentation is available via chub:

```bash
chub search ecc              # browse ECC docs
chub get ecc/core-overview   # installation and quick start
chub get ecc/core-codex      # Codex-specific ECC guidance
```

## Documentation

For external libraries (PyTorch, etc.), use the `context7` MCP tool (Note: Context7 is not registered in `.mcp.json` Ã¢â‚¬â€ only Berry is active. Use web search as fallback for external docs.) or `chub get <provider>/<topic>`.

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
- `npx claude-mem --help`
- `npx claude-mem install`
- `npx claude-mem install --ide gemini-cli`
- `/ck:init`
- `/ck:save`
- `/ck:resume`

Outputs:
- retrieved context block
- saved session or project memory summary
- source attribution for the selected memory layer

Storage and source of truth:
- `claude-mem`: optional user-level session continuity for Claude Code and Gemini CLI
- `ck`: ECC-native per-project working context
- `continuous-learning-v2`: reusable learned behaviors and instincts
- `manageesg-backend` `sustainability_ai.memory`: runtime memory for deployed agents only

Compatibility and retrieval order:
- Do not auto-enable `claude-mem` retrieval hooks when ECC hooks already inject the same context surface
- Observation hooks may coexist; retrieval should prefer one summary source
- Retrieval order:
  1. local repo docs and `AGENTS.md`/`CLAUDE.md`
  2. ECC project memory via `ck` and `continuous-learning-v2`
  3. `claude-mem` session observations
  4. backend durable memory only for actual application agent flows

Safety notes:
- `claude-mem` is optional infrastructure, not project truth
- do not duplicate the same fact into all memory systems unless explicitly requested
- do not wire `claude-mem` into backend runtime memory from this repo

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

RTK (Rust Token Killer) v0.35.0 is installed and active. It proxies shell commands to produce compressed, LLM-optimized output, reducing token consumption by 60�90% on verbose commands.

Binary: `C:\Users\adelm\.local\bin\rtk.exe`
Config: `C:\Users\adelm\AppData\Roaming\rtk\config.toml`

Usage � prefix any shell command with `rtk`:
```
rtk git status
rtk git diff HEAD~1
rtk python experiments/train.py --dry-run
rtk pip install -r requirements.txt
```

Scope: RTK only intercepts Bash/shell tool calls. It does NOT apply to built-in Read/Grep/Glob tools.

Key RTK commands:
- `rtk gain` � show token reduction statistics for the session
- `rtk --version` � confirm binary is reachable



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

Install:
```bash
npm install -g codeburn
# or one-shot:
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

