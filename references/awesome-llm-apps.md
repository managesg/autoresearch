# awesome-llm-apps (reference library)

**Canonical location:** `C:\Users\adelm\SeaBridgeAI\everything-claude-code\references\awesome-llm-apps`

Single source of truth — do **not** re-clone here. This file is a pointer.

## What it is

[Shubhamsaboo/awesome-llm-apps](https://github.com/Shubhamsaboo/awesome-llm-apps) — curated collection of 200+ runnable LLM / AI-agent example apps across frameworks (LangChain, LangGraph, LlamaIndex, CrewAI, AutoGen, OpenAI SDK, Anthropic SDK, etc.).

## Top-level buckets

| Directory | Contents |
|-----------|----------|
| `starter_ai_agents/` | Single-file agent examples — good for prototyping |
| `advanced_ai_agents/` | Multi-agent systems, planning, tool-use |
| `ai_agent_framework_crash_course/` | Framework-by-framework walkthroughs |
| `mcp_ai_agents/` | MCP server / client examples |
| `rag_tutorials/` | RAG patterns (hybrid, agentic, multimodal, graph) |
| `voice_ai_agents/` | Voice pipelines (STT/TTS + agent) |
| `advanced_llm_apps/` | End-to-end LLM applications |
| `awesome_agent_skills/` | Reusable agent skill patterns |

## When to consult it

- Before writing a new AI agent in `seabridge_ai/src/sustainability_ai/ai_agents/` — check for an analogous pattern
- Before wiring a new MCP integration — `mcp_ai_agents/` often has a minimal working server
- Before designing a RAG pipeline — `rag_tutorials/` covers most variants
- For framework comparison when choosing between LangGraph / CrewAI / AutoGen for a new feature

## Rules

- **Reference only** — do not import code directly. Port patterns, do not copy files.
- **No auto-runs** — examples may hit paid APIs; never execute from a hook.
- **License** — check each example's license before porting (most are MIT, but verify).

## Updating

The canonical clone is shallow (`--depth=1`). To refresh:

```powershell
cd C:\Users\adelm\SeaBridgeAI\everything-claude-code\references\awesome-llm-apps
git pull --depth=1
```
