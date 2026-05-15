# Local LLM — Unsloth

Unsloth Studio is centrally managed from:
  C:\Users\adelm\SeaBridgeAI\everything-claude-code\external\unsloth

Full documentation:
  C:\Users\adelm\SeaBridgeAI\everything-claude-code\docs\local-llm\unsloth.md

## Quick Start (from any repo)

```powershell
# Health check
C:\Users\adelm\SeaBridgeAI\everything-claude-code\scripts\check-unsloth.ps1

# Start Studio
unsloth studio -p 8888

# Use with Claude Code (dot-source in your terminal)
. C:\Users\adelm\SeaBridgeAI\everything-claude-code\scripts\use-unsloth-claude-code.ps1
claude

# Use with Codex / OpenAI-compatible clients
. C:\Users\adelm\SeaBridgeAI\everything-claude-code\scripts\use-unsloth-openai-compatible.ps1
codex
```

## Models (16 GB VRAM)

| Model | Command |
|-------|---------|
| Qwen3.5-4B (cached) | `unsloth studio run --model unsloth/Qwen3.5-4B-GGUF:Q4_K_M -p 8888` |
| Qwen3-14B | `unsloth studio run --model unsloth/Qwen3-14B-GGUF:Q4_K_M -p 8888` |
| Gemma-4-12B | `unsloth studio run --model unsloth/gemma-4-12b-it-GGUF:Q5_K_M -p 8888` |

Do NOT add production dependencies on Unsloth in this repo.

