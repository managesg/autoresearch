from __future__ import annotations

import json
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "graphify"))


def test_sustainability_research_uses_argument_splatting_not_invoke_expression():
    src = (ROOT / "sustainability_research.ps1").read_text(encoding="utf-8")

    assert "Invoke-Expression" not in src
    assert "& powershell @psArgs" in src
    assert "& powershell @graphifyArgs" in src


def test_local_claude_settings_deny_env_reads_and_broad_shells():
    settings = json.loads((ROOT / ".claude" / "settings.local.json").read_text(encoding="utf-8"))
    allow = settings.get("permissions", {}).get("allow", [])
    deny = settings.get("permissions", {}).get("deny", [])

    forbidden_allow = {
        "Bash(cmd.exe:*)",
        "Bash(powershell.exe:*)",
        "Bash(powershell:*)",
        "Bash(wsl:*)",
        "Bash(cat /c/Users/adelm/SeaBridgeAI/manageesg-backend/.env*)",
    }
    assert forbidden_allow.isdisjoint(set(allow))
    assert settings.get("enableAllProjectMcpServers") is False
    assert "Read(**/.env*)" in deny
    assert "Bash(cat *.env*)" in deny
