---
name: preview
description: Preview Markdown, LaTeX, PDF, or code artifacts in the browser or as PDF. Use when the user wants to review a written artifact, export a report, or view a rendered document.
---

# Preview

Use the `/preview` command to render and open artifacts.

## Commands

| Command | Description |
|---------|-------------|
| `/preview` | Preview the most recent artifact in the browser |
| `/preview --file <path>` | Preview a specific file |
| `/preview-browser` | Force browser preview |
| `/preview-pdf` | Export to PDF via pandoc + LaTeX |
| `/preview-clear-cache` | Clear rendered preview cache |

## Fallback

If the preview commands are not available, use bash:

```bash
open <file.md>          # macOS â€” opens in default app
open <file.pdf>         # macOS â€” opens in Preview
```

<!-- SEABRIDGE_GOAL_SKILL_INHERITANCE_START -->
## /goal Inheritance

This skill inherits the SeaBridgeAI `/goal` default protocol. Frame the work with a persistent goal, Definition of Done, validation plan, risks, dependencies, expected artifacts, and completion evidence. Do not claim completion until the DoD is validated or a hard blocker is documented.

Canonical protocol: `C:\Users\adelm\SeaBridgeAI\everything-claude-code\protocols\GOAL_PROTOCOL.md`
<!-- SEABRIDGE_GOAL_SKILL_INHERITANCE_END -->
