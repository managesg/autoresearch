# Strix — AI Security Pentesting for SeaBridgeAI

Strix deploys autonomous AI hacker agents that find and validate real vulnerabilities with proof-of-concepts. It runs OWASP Top 10 checks dynamically inside a Docker sandbox.

**Repo:** `C:\Users\adelm\SeaBridgeAI\autoresearch\strix\` (cloned from `https://github.com/usestrix/strix`)
**Wrapper:** `C:\Users\adelm\SeaBridgeAI\autoresearch\strix.ps1`
**Version:** 0.8.3

---

## Prerequisites

| Requirement | Details |
|-------------|---------|
| Docker Desktop | Must be **running** — Strix executes PoCs in a sandbox container |
| `uv` | Python package manager — used to run Strix |
| `ANTHROPIC_API_KEY` | Set in your environment — passed as `LLM_API_KEY` to LiteLLM |

---

## Scan Targets

| Target | Path |
|--------|------|
| Backend | `C:\Users\adelm\SeaBridgeAI\manageesg-backend` (FastAPI + MongoDB + AWS) |
| Frontend | `C:\Users\adelm\SeaBridgeAI\manageesg-frontend` (Next.js) |

---

## Quick Start

```powershell
# Open PowerShell from the autoresearch directory:
cd C:\Users\adelm\SeaBridgeAI\autoresearch

# Deep scan of the backend (default mode)
.\strix.ps1 -Target backend

# Deep scan of the frontend
.\strix.ps1 -Target frontend

# Quick scan (CI/CD speed — fewer checks)
.\strix.ps1 -Target backend -Mode quick
.\strix.ps1 -Target frontend -Mode quick

# Standard scan
.\strix.ps1 -Target backend -Mode standard

# Headless (non-interactive, for scripting / CI)
.\strix.ps1 -Target backend -Headless

# Custom target path
.\strix.ps1 -Target custom -Path "C:\path\to\app"

# Dry run (prints the command without executing)
.\strix.ps1 -Target backend -DryRun

# Different model
.\strix.ps1 -Target backend -Model "anthropic/claude-opus-4-6"
```

---

## Via Co-Scientist Orchestrator

```powershell
cd C:\Users\adelm\SeaBridgeAI\autoresearch

.\co-scientist-orchestrator.ps1 -Action run-strix -StrixTarget backend
.\co-scientist-orchestrator.ps1 -Action run-strix -StrixTarget frontend
.\co-scientist-orchestrator.ps1 -Action run-strix -StrixTarget backend -StrixMode quick
.\co-scientist-orchestrator.ps1 -Action run-strix -StrixTarget backend -StrixHeadless
```

---

## Scan Modes

| Mode | Speed | Depth | Use When |
|------|-------|-------|----------|
| `quick` | Fast | Surface-level | CI/CD gates, rapid iteration |
| `standard` | Medium | Moderate | Regular development scans |
| `deep` | Slow | Comprehensive | Pre-release, security audits (default) |

---

## What Strix Checks

- **Authentication & Authorization** — JWT bypass, privilege escalation, Cognito misconfiguration
- **Injection** — SQL/NoSQL injection (MongoDB `$where`, operator injection), command injection, SSTI
- **XSS** — reflected, stored, DOM-based
- **SSRF / CSRF** — server-side request forgery, missing CSRF tokens
- **Sensitive Data Exposure** — hardcoded secrets, API key leakage in responses, error message leakage
- **Security Misconfiguration** — CORS policy, missing security headers, debug endpoints
- **Broken Access Control** — IDOR, insecure direct object references
- **API Security** — rate limiting, input validation, verbose error responses

---

## Output

Results are saved to:

```
C:\Users\adelm\SeaBridgeAI\autoresearch\strix\strix_runs\<run-name>\
  ├── report.html       # Full HTML vulnerability report
  ├── findings.json     # Structured findings with CVSS scores
  └── poc/              # Proof-of-concept scripts for confirmed vulnerabilities
```

---

## Manual Setup (first time only — already done)

```powershell
cd C:\Users\adelm\SeaBridgeAI\autoresearch\strix
uv sync --no-dev
```

Verify installation:
```powershell
cd C:\Users\adelm\SeaBridgeAI\autoresearch\strix
uv run strix --help
```

---

## Manual Run (direct CLI)

```powershell
$env:STRIX_LLM   = "anthropic/claude-sonnet-4-6"
$env:LLM_API_KEY = $env:ANTHROPIC_API_KEY
cd C:\Users\adelm\SeaBridgeAI\autoresearch\strix
uv run strix --target "C:\Users\adelm\SeaBridgeAI\manageesg-backend" --scan-mode deep
```

---

## Environment Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `STRIX_LLM` | `anthropic/claude-sonnet-4-6` | LLM model for Strix agents |
| `LLM_API_KEY` | Value of `$ANTHROPIC_API_KEY` | API key passed to LiteLLM |
| `STRIX_SCAN_MODE` | `quick`, `standard`, or `deep` | Scan depth (wrapper sets via CLI flag) |

---

## Safety Policy

- **Local codebases only** — never run against live production endpoints without explicit written approval from adelmar@seabridgesustainability.com
- **Manual opt-in only** — do not auto-invoke from hooks or scheduled tasks
- **Docker isolation** — all PoC execution happens inside the Strix sandbox container, not on the host

---

## ECC Skill

The full Strix skill is at:
```
C:\Users\adelm\SeaBridgeAI\everything-claude-code\.claude\skills\strix\SKILL.md
C:\Users\adelm\.claude\skills\strix\SKILL.md
```

Trigger phrases in Claude Code: `security scan`, `pentest`, `vulnerability scan`, `strix`, `security audit`, `owasp`, `security assessment`
