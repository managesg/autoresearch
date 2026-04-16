# Sustainability Research Workflow

Runbook for using the AI Co-Scientist stack to advance ESG/sustainability research and improve the SeaBridgeAI backend.

**Quick start:**
```powershell
.\sustainability_research.ps1 -Scenario A  # New ESG research question
.\sustainability_research.ps1 -Scenario B  # Improve an existing backend agent
.\sustainability_research.ps1 -Scenario C  # ESG data intelligence question
.\sustainability_research.ps1 -DryRun      # Preview any scenario without executing

# Or use the Streamlit UI:
.\run_ui.ps1
```

See [AI_COSCIENTIST_STACK.md](AI_COSCIENTIST_STACK.md) for tool inventory and architecture.

---

## Scenario A: New ESG Research Question

**When to use**: You have a sustainability/ESG question that requires literature review, hypothesis generation, and potentially a novel experiment.

**Example**: "What biodiversity metrics best predict physical risk for real estate portfolios?"

### Steps

#### Step A1 — Cited Research Brief (Feynman)
```powershell
.\sustainability_research.ps1 -Scenario A -Task "Your ESG research question"
# Or directly:
.\feynman\feynman.ps1 "Your ESG research question"
# Deep research mode (parallel sub-agents, ~20 min, higher cost):
.\feynman\feynman.ps1 "Your ESG research question" --deep-research
```
**Output**: `autoresearch/feynman/outputs/<slug>.md` with citations, `papers/<slug>.md` with paper summaries.

**Proceed when**: You have a solid literature grounding and can formulate a hypothesis.

#### Step A2 — Convert Key Paper to MCP Agent (Paper2Agent)

Review the Feynman output and identify the most relevant methodology paper or repo. Then convert it to an interactive MCP-backed agent:

```powershell
.\paper2agent-suite\Paper2Agent\paper2agent.ps1 -ProjectDir <AgentDir> -GithubUrl <PaperRepoUrl>
# Example:
.\paper2agent-suite\Paper2Agent\paper2agent.ps1 -ProjectDir TNFD_Risk_Agent -GithubUrl https://github.com/example/tnfd-methodology
```
**Output**: `autoresearch/<AgentDir>/src/<repo>_mcp.py`, extracted tools, quality report.

**Cost gate**: $2-10, 30 min - 3 hrs. Manual opt-in required.

> **REMOVED STEPS (A2-old / A3-old):** The original Scenario A included two additional steps —
> AI-CoScientist (hypothesis evolution) and ai-scientist (autonomous experiment) — that have
> been removed. AI-CoScientist is archived (`autoresearch/archived/AI-CoScientist/`); its output
> fed nowhere in the active pipeline. ai-scientist (Sakana AI) has been deleted — it executed
> model-written code and required a Docker-sandboxed GPU node. Do not attempt to invoke either tool.

#### Step A3 — Handoff to Backend (Optional)
If the experiment produces findings relevant to an existing backend agent:
- Write a summary to `autoresearch/handoff/<slug>_findings.md`
- Reference it from `seabridge_ai/src/sustainability_ai/ai_agents/autoresearch/handoff.py`
- Run Scenario B to improve the relevant agent using the findings

---

## Scenario B: Improve an Existing Backend Agent

**When to use**: You want to improve an existing backend agent (e.g., `climate_agent`, `nature_agent`, `regulation_monitoring`) using research findings or by running ML experiments.

**Example**: "Improve the nature_agent's biodiversity risk scoring using TNFD Alpha framework."

### Steps

#### Step B1 — Research Current State (Feynman)
```powershell
.\feynman\feynman.ps1 "Latest [framework/methodology] for [domain]"
# Example:
.\feynman\feynman.ps1 "TNFD Alpha framework biodiversity risk disclosure requirements 2024"
```
**Output**: Cited brief at `feynman/outputs/`.

#### Step B2 — Review Existing Agent Code
```bash
# In manageesg-backend:
cat seabridge_ai/src/sustainability_ai/ai_agents/nature_agent/*.py
# Read the relevant doc first:
cat seabridge_ai/docs/AI_agents.md
```

#### Step B3 — Build Knowledge Graph (Graphify)
```powershell
# In autoresearch/:
powershell -ExecutionPolicy Bypass -File .\graphify.ps1 query "show the nature_agent architecture and data flow" --graph graphify/output/graph.json
```

#### Step B4 — ML Experiment Loop (autoresearch)
If the improvement can be framed as a training experiment:
```bash
# In autoresearch/ repo:
git checkout -b autoresearch/<tag>
# Edit experiments/train.py per the research question
uv run experiments/train.py > run.log 2>&1
grep "^val_bpb:\|^peak_vram_mb:" run.log
# Record in results.tsv, iterate
```

#### Step B5 — Paper-to-Agent (Paper2Agent, Optional)
If a specific paper should be converted to an MCP tool:
```powershell
.\paper2agent-suite\Paper2Agent\paper2agent.ps1 -ProjectDir <AgentDir> -GithubUrl <PaperRepoUrl>
```

#### Step B6 — Implement in Backend
- Read `seabridge_ai/docs/AI_agents.md` before writing any code
- Follow the `nature_agent/` reference implementation pattern
- Write tests first (TDD), then implement
- Run `pytest seabridge_ai/` to verify

---

## Scenario C: ESG Data Intelligence Question

**When to use**: You need a rapid cited answer to an ESG/sustainability data question — without running a full experiment. This is a quick research sprint.

**Example**: "What is the current SFDR Article 8/9 classification methodology for green bonds?"

### Steps

#### Step C1 — Cited Brief (Feynman)
```powershell
.\feynman\feynman.ps1 "Your ESG data question"
```
**Output**: `feynman/outputs/<slug>.md` — cited, structured answer within ~2-5 minutes.

#### Step C2 — Hallucination Check (Berry)
In Claude Code during `/plan`, use Berry to verify any factual claims from the brief before acting on them:
```
audit_trace_budget with citations from the Feynman output
```

#### Step C3 — Feed to AI Manager (Optional)
If the finding should update the AI Manager's knowledge base:
- Add source to `seabridge_ai/src/sustainability_ai/ai_manager/` knowledge tools
- Reference the Feynman output provenance sidecar as citation

---

## Tool Decision Tree

```
ESG question or task
│
├─ Need literature + citations?
│   └─ YES → Feynman (.\feynman\feynman.ps1 "question")
│       └─ Need to convert a key paper into an MCP agent?
│           └─ YES → Paper2Agent (.\paper2agent-suite\Paper2Agent\paper2agent.ps1 -ProjectDir X -GithubUrl Y)
│               └─ Benchmark it? → Paper2AgentBench (.\paper2agent-bench.ps1)
│
|       [REMOVED -- not reachable in current pipeline]
|       +- AI-CoScientist (hypothesis evolution) -- archived, output unconnected
|           +- ai-scientist (autonomous experiment) -- deleted
│
├─ Improve existing backend agent?
│   └─ YES → Scenario B
│       ├─ Feynman for research
│       ├─ Graphify for codebase understanding
│       └─ autoresearch loop for ML experiments
│
├─ Paper → MCP tool?
│   └─ YES → Paper2Agent (.\paper2agent.ps1)
│       └─ Benchmark? → Paper2AgentBench (.\paper2agent-bench.ps1)
│
└─ Local fine-tuning on domain data?
    └─ YES → Unsloth Studio (http://127.0.0.1:8891)
```

---

## Cost and Safety Gates

| Tool | Cost Level | Gate |
|------|-----------|------|
| Feynman (standard) | Low (~$0.05-0.50) | Auto-allowed with API key |
| Feynman (deep-research) | Medium (~$1-5) | Confirm before running |
| AI-CoScientist | High (~$5-20) | **ARCHIVED** -- do not invoke |
| ai-scientist | High + isolation required | **DELETED** -- do not invoke |
| Paper2Agent | High (30 min - 3hr) | Manual opt-in only |
| Unsloth | GPU only (local cost) | No API cost; confirm GPU availability |

**Rule**: Never run paid API calls without explicit written approval from adelmar@seabridge.ai.

---

## Output Locations

| Tool | Output Location |
|------|----------------|
| Feynman | `autoresearch/feynman/outputs/<slug>.md` |
| Feynman papers | `autoresearch/feynman/papers/<slug>.md` |
| AI-CoScientist | `autoresearch/archived/AI-CoScientist/` _(ARCHIVED)_ |
| ai-scientist | (deleted) |
| Paper2Agent | `autoresearch/<ProjectDir>/` |
| autoresearch loop | `autoresearch/results.tsv`, `autoresearch/run.log` |
| Backend handoff | `manageesg-backend/autoresearch/handoff/` |

---

## Common Pitfalls

1. **Invoking AI-CoScientist or ai-scientist** -- AI-CoScientist is archived; ai-scientist is deleted. Do not attempt to invoke either tool.
2. **Skipping feynman setup** — run `feynman setup` interactively once before use (configures Pi runtime).
3. **Committing results.tsv** — it's in `.gitignore` for a reason; contains run-specific artifacts.
4. **Merging autoresearch into manageesg-backend** — they must stay separate; use the adapter in `ai_agents/autoresearch/`.
5. **Not reading AI_agents.md before implementing** — the backend has strict agent layout rules.
