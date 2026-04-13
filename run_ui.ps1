<#
.SYNOPSIS
    Launch the SeaBridgeAI Research Orchestrator Streamlit UI.

.DESCRIPTION
    Starts app.py on http://localhost:8501.
    Requires streamlit: pip install streamlit  (or: uv sync --extra ui)

.EXAMPLE
    .\run_ui.ps1
#>

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AppPath   = Join-Path $ScriptDir "app.py"

# Verify streamlit is installed
$streamlit = Get-Command streamlit -ErrorAction SilentlyContinue
if (-not $streamlit) {
    Write-Host "Streamlit is not installed." -ForegroundColor Red
    Write-Host "Install it with:  pip install streamlit" -ForegroundColor Yellow
    Write-Host "Or:               uv sync --extra ui" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "SeaBridgeAI Research Orchestrator UI" -ForegroundColor Cyan
Write-Host "URL: http://localhost:8501" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop." -ForegroundColor DarkGray
Write-Host ""

streamlit run $AppPath --server.port 8501 --server.headless false
