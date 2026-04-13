# SeaBridgeAI — AI Co-Scientist Stack

A unified guide to the research and scientific intelligence tools installed across SeaBridgeAI.
These tools work together as a layered research pipeline: from literature search and hypothesis generation
through autonomous experimentation, paper extraction, and academic benchmarking.

---

## Stack Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        SeaBridgeAI Co-Scientist Stack                   │
│                                                                         │
│  ACTIVE TOOLS                                                           │
│   ┌──────────────┐         ┌──────────────┐   ┌──────────────────────┐ │
│   │   feynman    │──────▶  │  Paper2Agent │──▶│  Paper2AgentBench    │ │
│   │  (Research   │         │  (Paper →    │   │  (Benchmark)         │ │
│   │    Agent)    │         │  MCP Agent)  │   └──────────────────────┘ │
│   └──────┬───────┘         └──────────────┘                            │
│          │                                                              │
│          ▼                                                              │
│   ┌──────────────┐   ┌──────────────────────────────────────────────┐  │
│   │   graphify   │   │  unsloth  (Local Fine-Tuning — RTX 4090)     │  │
│   │  (Knowledge  │   │  Studio UI: http://127.0.0.1:8891             │  │
│   │    Graph)    │   └──────────────────────────────────────────────┘  │
│   └──────────────┘                                                      │
│                                                                         │
│  SHELVED (prerequisites unmet / not wired into any active pipeline)     │
│   ┌──────────────┐   ┌──────────────────────────────────────────────┐  │
│   │ AI-CoScienti │   │         ai-scientist (Sakana AI)              │  │
│   │     st       │   │   (requires Docker sandbox + GPU node)        │  │
│   │  (Shelved)   │   │               (Shelved)                       │  │
│   └──────────────┘   └──────────────────────────────────────────────┘  │
│                                                                         │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │   manageesg-backend  /  sustainability_ai  (Production Layer)   │   │
│   │   ai_agents/ · ai_manager/ · ai_mcp/ · memory/ · pipeline/     │   │
│   └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Quick Start: Sustainability Research

The canonical entry point for all sustainability research workflows:

```powershell
# Scenario A — New ESG research question
.\sustainability_research.ps1 -Scenario A -Task "What biodiversity metrics best predict physical risk for real estate?"

# Scenario B — Improve an existing backend agent
.\sustainability_research.ps1 -Scenario B -Task "Latest TNFD Alpha framework biodiversity risk requirements"

# Scenario C — Quick ESG data intelligence question
.\sustainability_research.ps1 -Scenario C -Task "SFDR Article 8 classification methodology for green bonds"

# Preview any scenario without executing cost-incurring steps
.\sustainability_research.ps1 -Scenario A -DryRun
```

**Full runbook:** [SUSTAINABILITY_WORKFLOW.md](SUSTAINABILITY_WORKFLOW.md)

---

## Research Orchestrator UI (Streamlit)

A local-only Streamlit app for running research scenarios without the terminal.

```powershell
# Install Streamlit (one-time)
uv sync --extra ui
# or: pip install streamlit

# Launch
.\run_ui.ps1
# or directly:
streamlit run app.py
```

**URL:** http://localhost:8501

**Features:**
- Scenario A/B/C selector with descriptions
- Research task text input
- DeepResearch and DryRun toggles
- Live streaming output from PowerShell scripts
- Scenario A: Paper2Agent handoff fields (GitHub URL + project dir) shown inline
- Cost gate warnings before execution
- Approval checkbox for Paper2Agent (high-cost step)

---

| Scenario | Use When | Pipeline |
|----------|----------|----------|
| A | New ESG research question | Feynman → Paper2Agent (paper/repo → MCP agent) |
| B | Improve a backend agent | Feynman → Graphify → autoresearch loop |
| C | Quick cited ESG answer | Feynman (rapid mode) |

---

## Tools

### 1. Feynman — Research Agent

**What it does:** Open-source TypeScript AI research agent for cited research briefs,
literature reviews, paper audits, and deep multi-agent investigations. Outputs are
source-grounded — every claim links to papers, docs, or repos with direct URLs.

**Installed at:** `C:\Users\adelm\SeaBridgeAI\autoresearch\feynman\` (v0.2.17)

**In PATH:** Yes — linked globally via `npm link`

**Built on:** Pi (agent runtime) + alphaXiv (paper search/analysis)

**Four bundled research sub-agents:**

| Sub-agent  | Role                                              |
|------------|---------------------------------------------------|
| Researcher | Gathers evidence across papers, web, repos, docs  |
| Reviewer   | Simulated peer review with severity-graded feedback|
| Writer     | Structured paper-style drafts from research notes |
| Verifier   | Inline citations, source URL verification, dead-link cleanup |

**Key commands:**

```bash
# Interactive REPL
feynman

# One-shot research brief
feynman "what do we know about scaling laws?"

# Multi-agent deep investigation
feynman deepresearch "TNFD disclosure requirements for nature risk"

# Literature review
feynman lit "RLHF alternatives"

# Paper vs codebase audit
feynman audit 2401.12345

# Replicate an experiment
feynman replicate "chain-of-thought improves math"

# Setup (run once interactively)
feynman setup
feynman doctor
```

**PowerShell wrapper:** `C:\Users\adelm\SeaBridgeAI\autoresearch\feynman.ps1`

**Skills installed (19 skill directories):**

| Skill | Purpose |
|-------|---------|
| `deep-research` | Multi-agent source-heavy investigation |
| `literature-review` | Consensus, disagreements, open questions |
| `peer-review` | Severity-graded review with revision plan |
| `paper-code-audit` | Paper claims vs public codebase |
| `replication` | Replicate experiments on local/cloud GPUs |
| `autoresearch` | Autonomous experiment loop |
| `alpha-research` | alphaXiv paper Q&A, code reading, annotations |
| `docker` | Isolated container execution for safe experiments |
| `modal-compute` | Serverless GPU compute (Modal) |
| `runpod-compute` | Persistent GPU pods (RunPod) |
| `paper-writing` | Paper-style draft from research findings |
| `source-comparison` | Source comparison matrix |
| `watch` | Recurring research watch on a topic |
| `session-search` | Indexed recall across prior research sessions |
| `session-log` | Lab notebook management |
| `eli5` | Explain Like I'm 5 summaries |
| `preview` | Browser and PDF export of artifacts |
| `jobs` | Job/opportunity research |
| `contributing` | Open-source contribution research |

**Skills locations:**
- Global: `C:\Users\adelm\.codex\skills\feynman\`
- ECC: `C:\Users\adelm\SeaBridgeAI\everything-claude-code\.agents\skills\feynman\`
- Autoresearch local: `C:\Users\adelm\SeaBridgeAI\autoresearch\.agents\skills\feynman\`

**Output conventions:**
- Research briefs → `outputs/<slug>.md`
- Paper drafts → `papers/<slug>.md`
- Session logs → `notes/`
- Plans → `outputs/.plans/<slug>.md`
- Provenance sidecars → `<slug>.provenance.md`

**First-time setup:**

1. **Set API keys** — Edit `autoresearch/feynman/.env` (copied from `.env.example`):
   ```
   ANTHROPIC_API_KEY=sk-ant-...   # or OPENAI_API_KEY / OPENROUTER_API_KEY
   FEYNMAN_MODEL=                  # leave blank to use provider default
   FEYNMAN_THINKING=medium         # low / medium / high
   ```
2. **Run setup** — configures the Pi runtime interactively (run once):
   ```powershell
   cd autoresearch/feynman
   feynman setup
   feynman doctor   # verify all components
   ```
3. Node.js ≥ 20.19.0 required (current: v24.12.0). Status: **Pending** — run `feynman setup` once.

---

### 2. AI-CoScientist — Multi-Agent Hypothesis Evolution

> **STATUS: SHELVED** — AI-CoScientist output feeds nowhere automatically in the current
> pipeline. Feynman covers the research brief step; Paper2Agent covers the methodology
> extraction step. Re-evaluate if a structured hypothesis-ranking step becomes needed.

**What it does:** Multi-agent framework implementing the "Towards an AI Co-Scientist"
methodology. Generates research hypotheses, runs peer review, tournament-based Elo
ranking, and iteratively evolves the best ideas.

**Installed at:** `C:\Users\adelm\SeaBridgeAI\autoresearch\AI-CoScientist\`

**Source:** [The Swarm Corporation / AI-CoScientist](https://github.com/The-Swarm-Corporation/AI-CoScientist)

**Six specialized agents:**

| Agent | Role |
|-------|------|
| Generation Agent | Creates initial hypotheses from the research goal |
| Reflection Agent | Peer reviews each hypothesis for scientific merit |
| Ranking Agent | Orders hypotheses by review scores |
| Tournament Agent | Pairwise Elo comparisons |
| Meta-Review Agent | Synthesizes insights across all reviews |
| Evolution Agent | Refines top hypotheses based on feedback |

**Workflow:**

```
Research Goal → Generation → Reflection → Ranking → Tournament → Meta-Review → Evolution
                                                                      ↑              │
                                                                      └──────────────┘
                                                                      (iterates N rounds)
```

**Quick start (Python):**

```python
from ai_coscientist import AIScientistFramework

ai = AIScientistFramework(
    model_name="gemini/gemini-2.0-flash",
    max_iterations=3,
    hypotheses_per_generation=10,
    tournament_size=8,
    evolution_top_k=3,
)

results = ai.run_research_workflow(
    "Identify ESG risk factors in climate transition scenarios"
)

for h in results["top_ranked_hypotheses"]:
    print(h["text"], "— Elo:", h["elo_rating"])
```

**Run via orchestrator:**

```powershell
# Check readiness
.\co-scientist-orchestrator.ps1 -Action status

# Dry-run
.\co-scientist-orchestrator.ps1 -Action run-coscientist -Task "ESG risk factors in climate transition" -DryRun

# Execute (manual opt-in — incurs API cost)
.\co-scientist-orchestrator.ps1 -Action run-coscientist -Task "ESG risk factors in climate transition"
```

**Cost/safety:** Manual opt-in only. Requires explicit approval from adelmar@seabridge.ai.
Do not auto-run via hooks.

---

### 3. AI-Scientist — Autonomous Experiment Generation

> **STATUS: SHELVED** — Requires a Docker-sandboxed GPU node to run safely (model-written
> code is executed). Prerequisites have not been met. Re-evaluate when a dedicated
> isolated compute node is provisioned.

**What it does:** Sakana AI framework that autonomously generates novel research ideas,
writes experiment code, executes experiments, and produces paper-style LaTeX write-ups
with review scores.

**Installed at:** `C:\Users\adelm\SeaBridgeAI\autoresearch\ai-scientist\`

**Source:** [sakanaai/ai-scientist](https://github.com/sakanaai/ai-scientist)

**Workflow:** Idea generation → Code writing → Experiment execution → Paper write-up → Peer review scoring

**Run via orchestrator:**

```powershell
# Dry-run (always prints ISOLATION WARNING)
.\co-scientist-orchestrator.ps1 -Action run-ai-scientist -DryRun

# Execute with seed idea (ISOLATION REQUIRED)
.\co-scientist-orchestrator.ps1 -Action run-ai-scientist -Idea "Novel ESG metric combining physical risk and regulatory exposure"
```

**Output:** Experiment code, results, LaTeX paper drafts, and review scores under `ai-scientist/` output directories.

**Safety — ISOLATION REQUIRED:** This framework executes model-written code. Never run
on a production machine or shared infrastructure. Manual opt-in only.

---

### 4. Paper2Agent — Research Paper → MCP Agent

**What it does:** Converts a research paper's GitHub repository into an interactive
MCP-backed agent with extracted tools, test coverage, and a quality report.

**Installed at:** `C:\Users\adelm\SeaBridgeAI\autoresearch\Paper2Agent\`

**Outputs per run:**
- MCP server: `<project_dir>/src/<repo_name>_mcp.py`
- Extracted tools: `<project_dir>/src/tools/`
- Quality/coverage report: `<project_dir>/reports/coverage_and_quality_report.md`

**Run:**

```powershell
cd C:\Users\adelm\SeaBridgeAI\autoresearch

# Basic
.\Paper2Agent\Paper2Agent.sh --project_dir TISSUE_Agent --github_url https://github.com/sunericd/TISSUE

# With tutorial filter
.\Paper2Agent\Paper2Agent.sh --project_dir Scanpy_Agent --github_url https://github.com/scverse/scanpy --tutorials "Preprocessing and clustering"

# With benchmark
.\Paper2Agent\Paper2Agent.sh --project_dir MyAgent --github_url <url> --benchmark
```

**Cost/safety:** Manual opt-in only. Takes 30 minutes to 3+ hours per paper. Incurs API cost.

---

### 5. Paper2AgentBench — Benchmark Evaluation

**What it does:** Evaluates Paper2Agent output quality using official benchmark datasets
and scripts (labels, grading, analysis).

**Installed at:** `C:\Users\adelm\SeaBridgeAI\autoresearch\Paper2AgentBench\`

**Run:**

```powershell
.\paper2agent-bench.ps1 -Action install       # Install benchmark dependencies
.\paper2agent-bench.ps1 -Action register-mcp  # Register generated MCP server
.\paper2agent-bench.ps1 -Action labels        # Run labeling pass
.\paper2agent-bench.ps1 -Action analyze       # Produce grading summary
```

---

### 6. Graphify — Codebase Knowledge Graph

**What it does:** Builds and queries a knowledge graph of the backend codebase.
Exposes god nodes (highest connectivity), community structure, and architecture
relationships for rapid orientation and architecture Q&A.

**Installed at:** `C:\Users\adelm\SeaBridgeAI\autoresearch\graphify\`

**Output:** `graphify-out/` in each project root.

**Run:**

```powershell
# Query graph (from manageesg-backend)
.\graphify.ps1 query "show the AI manager to autoresearch handoff flow" --graph graphify-out/graph.json

# Rebuild after code changes
python3 -c "from graphify.watch import _rebuild_code; from pathlib import Path; _rebuild_code(Path('.'))"
```

**Usage rule:** Before answering architecture or codebase questions, read
`graphify-out/GRAPH_REPORT.md` for god nodes and community structure.

---

### 9. manageesg-backend — Production AI Layer

**What it does:** The SeaBridgeAI FastAPI backend where research findings from the
co-scientist stack are operationalized as production AI agents and endpoints.

**Path:** `C:\Users\adelm\SeaBridgeAI\manageesg-backend\`

**Key sub-systems:**

| Sub-system | Path | Purpose |
|------------|------|---------|
| AI Agents | `seabridge_ai/src/sustainability_ai/ai_agents/` | 18+ LangGraph/LangChain agents |
| AI Manager | `seabridge_ai/src/sustainability_ai/ai_manager/` | Sustainability chatbot |
| MCP Layer | `seabridge_ai/src/sustainability_ai/ai_mcp/` | MCP integrations (Axion, MongoDB, S3, Tavily) |
| Memory | `seabridge_ai/src/sustainability_ai/memory/` | Runtime agent memory (tenant-scoped) |
| Autoresearch Adapter | `ai_agents/autoresearch/` | Bridge from autoresearch sandbox → production |

**Autoresearch adapter files:**

| File | Role |
|------|------|
| `handoff.py` | Receives research artifacts from autoresearch sandbox |
| `runner.py` | Orchestrates autoresearch runs from backend context |
| `overnight_audit.py` | Production overnight audit using research findings |
| `regression_harness.py` | Regression checks against autoresearch baselines |
| `architect.py` | Designs experiment strategies for autoresearch runs |
| `diagnostician.py` | Diagnoses failed/regressed experiments |
| `evaluator.py` | Evaluates research outputs against baselines |
| `loop.py` | Continuous improvement loop controller |
| `task_dispatcher.py` | Dispatches research tasks to autoresearch sandbox |

---

### 7. Unsloth — Local Fine-Tuning Studio

**What it does:** Local LLM fine-tuning and inference using the Unsloth framework.
2× faster with up to 70% less VRAM than standard training. Powers Gemma 4 fine-tuning
on the local RTX 4090 for SeaBridgeAI's proprietary ESG models.

**Installed at:** `C:\Users\adelm\SeaBridgeAI\everything-claude-code\unsloth\`

**Current status:**
- Unsloth CLI: operational
- Unsloth Studio UI: operational — http://127.0.0.1:8891
- CUDA + PyTorch: confirmed — RTX 4090 detected
- Remaining blocker: Hugging Face token and Gemma 4 model access not yet configured

**Launch commands:**

```powershell
# Start Studio UI
unsloth studio -H 127.0.0.1 -p 8891

# Dry-run config validation
unsloth train --dry-run <config-path>

# Full fine-tune (requires HF_TOKEN and Gemma 4 license acceptance)
python unsloth-cli.py `
  --model_name "unsloth/gemma-4-9b" `
  --max_seq_length 8192 `
  --load_in_4bit `
  --hub_token "$env:HF_TOKEN" `
  --output_dir outputs/
```

**Prerequisites for Gemma 4:**
1. `$env:HF_TOKEN = "hf_..."` — set Hugging Face token
2. Accept Gemma 4 license at https://huggingface.co/google/gemma-4-9b
3. Provide training config path

**Cost/safety:** Manual opt-in only. Never commit HF_TOKEN or model weights.
Use `--dry-run` or `--max_steps 5` before launching a full training job.

---

### 8. manageesg-backend — Production AI Layer

### Typical Research-to-Production Pipeline

```
1. DISCOVER   feynman lit "TNFD biodiversity risk"
                  ↓ cited literature review with provenance
2. VALIDATE   feynman deepresearch "<specific hypothesis>"
                  ↓ multi-agent investigation with source verification
3. EXTRACT    Paper2Agent: convert key methodology repo into an MCP agent
                  ↓ MCP-backed agent with extracted tools + quality report
4. PRODUCTIZE autoresearch adapter → sustainability_ai agents
                  ↓ overnight audit + regression harness → production endpoints
5. VERIFY     feynman audit <paper_id> | graphify query "show data flow"
              unsloth: fine-tune local model on domain corpus (optional)
```

### ESG Research Example

```
User question: "What ESG factors drive climate transition risk for real estate?"

feynman lit "climate transition risk real estate ESG"
    → Consensus view, key disagreements, open questions, 15 citations

feynman deepresearch "physical risk scoring for commercial real estate TNFD TCFD"
    → 3-agent investigation: Researcher + Reviewer + Verifier
    → Cited brief with provenance sidecar

Paper2Agent on key methodology paper/repo identified in the brief
    → MCP server with extracted scoring tools + quality report

Production: sustainability_ai/ai_agents/climate_agent/ or nature_agent/
    → Live endpoint in FastAPI returning scored risk for tenant portfolios
```

### Integration with Everything-Claude-Code (ECC)

The co-scientist stack integrates with ECC through:

- **Skills:** Feynman's 19 research skills are installed into ECC's `.agents/skills/feynman/`
  — all coding agents (Claude Code, Codex, Gemini CLI) can invoke them
- **Berry MCP:** Hallucination detection during `/plan` — `audit_trace_budget` prevents
  hallucinated technical claims before code is written
- **AGENTS.md / CLAUDE.md:** Both autoresearch and manageesg-backend AGENTS.md files
  document all tools so any agent knows how to trigger them
- **Graphify:** `graphify-out/GRAPH_REPORT.md` gives every agent instant architecture context

---

## File Locations Quick Reference

| Tool | Source | Wrapper/Entry |
|------|--------|--------------|
| **sustainability_research.ps1** | `autoresearch/sustainability_research.ps1` | **Canonical unified entry point** |
| feynman | `autoresearch/feynman/` | `feynman` (global PATH via npm link) |
| feynman wrapper | `autoresearch/feynman.ps1` | PowerShell convenience wrapper |
| feynman env | `autoresearch/feynman/.env` | API keys for Feynman |
| AI-CoScientist | `autoresearch/AI-CoScientist/` | `python example.py` or orchestrator |
| ai-scientist | `autoresearch/ai-scientist/` | `co-scientist-orchestrator.ps1 run-ai-scientist` |
| Paper2Agent | `autoresearch/Paper2Agent/` | `Paper2Agent.sh` or orchestrator |
| Paper2AgentBench | `autoresearch/Paper2AgentBench/` | `paper2agent-bench.ps1` |
| graphify | `autoresearch/graphify/` | `graphify.ps1 query` |
| unsloth | `everything-claude-code/unsloth/` | `unsloth studio` / `unsloth train` |
| Orchestrator | `autoresearch/co-scientist-orchestrator.ps1` | AI-CoScientist + ai-scientist entry point |
| Sustainability workflow | `autoresearch/SUSTAINABILITY_WORKFLOW.md` | Detailed runbook for all 3 scenarios |

---

## Skill Locations

| Agent Runtime | Path |
|--------------|------|
| Claude Code global | `~/.claude/skills/` |
| Codex global | `~/.codex/skills/feynman/` |
| ECC shared | `C:\Users\adelm\SeaBridgeAI\everything-claude-code\.agents\skills\feynman\` |
| Autoresearch local | `C:\Users\adelm\SeaBridgeAI\autoresearch\.agents\skills\feynman\` |

---

## Prerequisites

| Requirement | Status |
|-------------|--------|
| Node.js ≥ 20.19.0 | v24.12.0 installed |
| feynman npm install | Done (autoresearch/feynman/) |
| feynman npm link (global) | Done — `feynman` in PATH |
| feynman `.env` API keys | Edit `autoresearch/feynman/.env` — set `ANTHROPIC_API_KEY` or `OPENAI_API_KEY` |
| feynman setup (Pi runtime) | **Pending** — run `feynman setup` interactively once after setting API keys |
| feynman skills (global/ECC/local) | Done — 21 items in each location |
| AI-CoScientist deps | `pip install -r autoresearch/AI-CoScientist/requirements.txt` |
| ai-scientist deps | `pip install -r autoresearch/ai-scientist/requirements.txt` |
| Paper2Agent deps | See `autoresearch/Paper2Agent/README.md` |
| unsloth CLI + Studio | Operational — RTX 4090 confirmed |
| unsloth Gemma 4 access | **Pending** — set `HF_TOKEN` + accept model license |

---

## Safety Summary

| Tool | Risk Level | Authorization Required |
|------|-----------|----------------------|
| feynman (research only) | Low | No — manual opt-in per run |
| AI-CoScientist | Medium | Yes — API cost; approval from adelmar@seabridge.ai |
| ai-scientist | **High** | Yes + **ISOLATED ENVIRONMENT** required; no production machines |
| Paper2Agent | Medium | Yes — 30min–3h runtime; approval from adelmar@seabridge.ai |
| Paper2AgentBench | Low | No |
| graphify | Low | No — read-only graph queries |
| unsloth | Medium | No — but never commit HF_TOKEN or weights; use --dry-run first |

---

## Related Documentation

| Doc | Location |
|-----|---------|
| **Sustainability research runbook** | `autoresearch/SUSTAINABILITY_WORKFLOW.md` |
| **Unified entry point script** | `autoresearch/sustainability_research.ps1` |
| Backend AI agents | `manageesg-backend/seabridge_ai/docs/AI_agents.md` |
| AI Manager | `manageesg-backend/seabridge_ai/docs/AI_manager.md` |
| MCP integrations | `manageesg-backend/seabridge_ai/docs/AI_mcp.md` |
| Overnight audit | `manageesg-backend/seabridge_ai/docs/AI_backend_overnight_audit.md` |
| Autoresearch loop | `autoresearch/program.md` |
| Feynman AGENTS.md | `autoresearch/feynman/AGENTS.md` |
| ECC governing instructions | `everything-claude-code/CLAUDE.md` |
| Berry hallucination detection | `manageesg-backend/.claude/rules/berry.md` |
