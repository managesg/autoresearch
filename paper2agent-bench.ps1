param(
    [ValidateSet("help", "install", "register-mcp", "labels", "analyze")]
    [string]$Action = "help",
    [switch]$DryRun
)

$benchRepo = "C:\Users\adelm\SeaBridgeAI\autoresearch\Paper2AgentBench"

function Get-Python {
    $preferred = "C:\Users\adelm\SeaBridgeAI\autoresearch\.venv\Scripts\python.exe"
    if (Test-Path -LiteralPath $preferred) { return $preferred }
    $py = Get-Command python -ErrorAction SilentlyContinue
    if ($py) { return $py.Source }
    return $null
}

function Show-Usage {
    Write-Host "paper2agent-bench wrapper"
    Write-Host ""
    Write-Host "Actions:"
    Write-Host "  help          Show this help"
    Write-Host "  install       Install Paper2AgentBench in editable mode"
    Write-Host "  register-mcp  Register AlphaGenome MCP server with claude-code via fastmcp"
    Write-Host "  labels        Generate tutorial and novel labels"
    Write-Host "  analyze       Summarize human graded benchmark data"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\paper2agent-bench.ps1 -Action install"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\paper2agent-bench.ps1 -Action register-mcp"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\paper2agent-bench.ps1 -Action labels"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\paper2agent-bench.ps1 -Action analyze"
}

if (-not (Test-Path -LiteralPath $benchRepo)) {
    Write-Error "Paper2AgentBench repository not found: $benchRepo"
    exit 1
}

$python = Get-Python
if (-not $python -and $Action -ne "help") {
    Write-Error "Python executable not found."
    exit 1
}

switch ($Action) {
    "help" {
        Show-Usage
        exit 0
    }
    "install" {
        $cmd = "$python -m pip install -e ."
        if ($DryRun) { Write-Host "[DRY RUN] $cmd"; exit 0 }
        Push-Location $benchRepo
        try { & $python -m pip install -e .; exit $LASTEXITCODE } finally { Pop-Location }
    }
    "register-mcp" {
        $cmd = "fastmcp install claude-code ./eval/AlphaGenome/src/alphagenome_mcp.py --project ./Paper2AgentBench"
        if ($DryRun) { Write-Host "[DRY RUN] $cmd"; exit 0 }
        Push-Location $benchRepo
        try { & fastmcp install claude-code ./eval/AlphaGenome/src/alphagenome_mcp.py --project ./Paper2AgentBench; exit $LASTEXITCODE } finally { Pop-Location }
    }
    "labels" {
        $cmd1 = "$python eval/AlphaGenome/benchmarking/scripts/ag_tutorial_labeler_cli.py"
        $cmd2 = "$python eval/AlphaGenome/benchmarking/scripts/ag_novel_labeler_cli.py"
        if ($DryRun) { Write-Host "[DRY RUN] $cmd1"; Write-Host "[DRY RUN] $cmd2"; exit 0 }
        Push-Location $benchRepo
        try {
            & $python eval/AlphaGenome/benchmarking/scripts/ag_tutorial_labeler_cli.py
            if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
            & $python eval/AlphaGenome/benchmarking/scripts/ag_novel_labeler_cli.py
            exit $LASTEXITCODE
        } finally { Pop-Location }
    }
    "analyze" {
        $cmd = "$python eval/AlphaGenome/benchmarking/scripts/analyze_human_graded_data.py"
        if ($DryRun) { Write-Host "[DRY RUN] $cmd"; exit 0 }
        Push-Location $benchRepo
        try { & $python eval/AlphaGenome/benchmarking/scripts/analyze_human_graded_data.py; exit $LASTEXITCODE } finally { Pop-Location }
    }
}
