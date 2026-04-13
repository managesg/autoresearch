<#
.SYNOPSIS
    Unified sustainability research orchestrator for the SeaBridgeAI co-scientist stack.

.DESCRIPTION
    Chains Feynman, Paper2Agent, Unsloth, and the autoresearch experiment loop into
    three research scenarios tailored for ESG/sustainability work.

    Scenario A: New ESG research question
        Feynman (cited brief) -> Paper2Agent (convert paper/repo -> MCP agent)

    Scenario B: Improve an existing backend agent
        Feynman (research) -> Graphify (codebase) -> autoresearch loop (ML experiment)

    Scenario C: ESG data intelligence question
        Feynman (quick cited answer) -> optional Berry hallucination check

.PARAMETER Scenario
    A, B, or C. Required.

.PARAMETER Task
    Research question or task description. Required for Feynman steps.

.PARAMETER DeepResearch
    Enable Feynman deep-research mode (parallel sub-agents, ~20 min, higher cost).

.PARAMETER DryRun
    Preview all steps without executing any cost-incurring or model-written-code steps.

.EXAMPLE
    .\sustainability_research.ps1 -Scenario A -Task "What biodiversity metrics best predict physical risk for real estate?"
    .\sustainability_research.ps1 -Scenario B -Task "Latest TNFD Alpha framework requirements"
    .\sustainability_research.ps1 -Scenario C -Task "SFDR Article 8 classification methodology for green bonds"
    .\sustainability_research.ps1 -Scenario A -DryRun
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("A", "B", "C")]
    [string]$Scenario,

    [Parameter(Mandatory = $false)]
    [string]$Task = "",

    [switch]$DeepResearch,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# ─── Helpers ─────────────────────────────────────────────────────────────────

function Write-Step {
    param([string]$Step, [string]$Msg)
    Write-Host "`n==> [$Step] $Msg" -ForegroundColor Cyan
}

function Write-DryRun {
    param([string]$Cmd)
    Write-Host "    [DRY RUN] Would run: $Cmd" -ForegroundColor Yellow
}

function Confirm-CostGate {
    param([string]$Tool, [string]$CostEstimate)
    if ($DryRun) {
        Write-Host "    [DRY RUN] Would prompt for $Tool cost gate (est. $CostEstimate)" -ForegroundColor Yellow
        return
    }
    Write-Host "`n  COST GATE: $Tool costs approximately $CostEstimate in API credits." -ForegroundColor Magenta
    Write-Host "  Requires explicit approval from adelmar@seabridge.ai." -ForegroundColor Magenta
    $confirm = Read-Host "  Proceed? (yes/no)"
    if ($confirm -ne "yes") {
        Write-Host "  Aborted by user." -ForegroundColor Red
        exit 0
    }
}

function Invoke-Feynman {
    param([string]$Query, [switch]$Deep)
    $feynmanScript = Join-Path $ScriptDir "feynman.ps1"
    if (-not (Test-Path $feynmanScript)) {
        Write-Host "  ERROR: feynman.ps1 not found at $feynmanScript" -ForegroundColor Red
        Write-Host "  Run: Copy-Item manageesg-backend/feynman.ps1 autoresearch/ or check the autoresearch root." -ForegroundColor Yellow
        return
    }
    if ($Deep) {
        $cmd = "powershell -ExecutionPolicy Bypass -File `"$feynmanScript`" `"$Query`" --deep-research"
    } else {
        $cmd = "powershell -ExecutionPolicy Bypass -File `"$feynmanScript`" `"$Query`""
    }
    if ($DryRun) {
        Write-DryRun $cmd
    } else {
        Write-Host "  Running Feynman research..." -ForegroundColor Green
        Invoke-Expression $cmd
    }
}

function Invoke-Paper2Agent {
    param([string]$GithubUrl, [string]$ProjectDir)
    $script = Join-Path $ScriptDir "paper2agent.ps1"
    if (-not (Test-Path $script)) {
        Write-Host "  ERROR: paper2agent.ps1 not found at $script" -ForegroundColor Red
        return
    }
    Confirm-CostGate -Tool "Paper2Agent" -CostEstimate "`$2-10 (30 min - 3 hrs)"
    $cmd = "powershell -ExecutionPolicy Bypass -File `"$script`" -ProjectDir `"$ProjectDir`" -GithubUrl `"$GithubUrl`""
    if ($DryRun) {
        Write-DryRun $cmd
    } else {
        Invoke-Expression $cmd
    }
}

# ─── Scenario A: New ESG Research Question ────────────────────────────────────

function Run-ScenarioA {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host " SCENARIO A: New ESG Research Question" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " Workflow: Feynman (cited brief) -> Paper2Agent (paper -> MCP agent)"

    if ([string]::IsNullOrWhiteSpace($Task)) {
        $script:Task = Read-Host "`nEnter your ESG research question"
    }

    Write-Step "A1" "Cited research brief (Feynman)"
    Invoke-Feynman -Query $Task -Deep:$DeepResearch

    Write-Host "`n  Feynman output is in autoresearch/feynman/outputs/" -ForegroundColor Green
    Write-Host "  Review the brief, identify key papers or methodology repos, then optionally"
    Write-Host "  convert the most relevant one into an MCP-backed agent with Paper2Agent."

    if (-not $DryRun) {
        $proceed = Read-Host "`nProceed to Paper2Agent (convert a paper/repo into an MCP agent)? (yes/no)"
        if ($proceed -ne "yes") {
            Write-Host "`nStopped after Feynman. Review outputs in autoresearch/feynman/outputs/ and re-run when ready." -ForegroundColor Yellow
            return
        }
    }

    $githubUrl = ""
    $projectDir = ""
    if (-not $DryRun) {
        $githubUrl = Read-Host "Enter the GitHub URL of the paper/methodology repo to convert"
        $projectDir = Read-Host "Enter a project directory name (e.g. TNFD_Risk_Agent)"
        if ([string]::IsNullOrWhiteSpace($projectDir)) { $projectDir = "Paper2Agent_Output" }
    } else {
        $githubUrl = "https://github.com/example/paper-repo"
        $projectDir = "Paper2Agent_DryRun"
    }

    Write-Step "A2" "Convert paper/repo to MCP agent (Paper2Agent)"
    Invoke-Paper2Agent -GithubUrl $githubUrl -ProjectDir $projectDir

    Write-Host "`n[Scenario A Complete]" -ForegroundColor Green
    Write-Host "MCP agent output: autoresearch/$projectDir/src/" -ForegroundColor Green
    Write-Host "Quality report:   autoresearch/$projectDir/reports/coverage_and_quality_report.md" -ForegroundColor Green
    Write-Host "Next: register the MCP server in .mcp.json or wire it into an ai_agents/ module." -ForegroundColor Green
}

# ─── Scenario B: Improve an Existing Backend Agent ────────────────────────────

function Run-ScenarioB {
    Write-Host "`n===============================================" -ForegroundColor Cyan
    Write-Host " SCENARIO B: Improve an Existing Backend Agent" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host " Workflow: Feynman (research) -> Graphify -> autoresearch loop"

    if ([string]::IsNullOrWhiteSpace($Task)) {
        $script:Task = Read-Host "`nDescribe the agent improvement task (e.g. 'Latest TNFD Alpha requirements')"
    }

    Write-Step "B1" "Research current methodology (Feynman)"
    Invoke-Feynman -Query $Task -Deep:$DeepResearch

    Write-Step "B2" "Build codebase knowledge graph (Graphify)"
    $graphifyScript = Join-Path $ScriptDir "graphify.ps1"
    $graphifyCmd = "powershell -ExecutionPolicy Bypass -File `"$graphifyScript`" query `"show the relevant agent architecture and data flow`" --graph graphify-out/graph.json"
    if ($DryRun) {
        Write-DryRun $graphifyCmd
    } elseif (Test-Path $graphifyScript) {
        Write-Host "  Running Graphify..." -ForegroundColor Green
        Invoke-Expression $graphifyCmd
    } else {
        Write-Host "  graphify.ps1 not found — skipping Graphify step." -ForegroundColor Yellow
        Write-Host "  Read graphify-out/GRAPH_REPORT.md manually if available." -ForegroundColor Yellow
    }

    Write-Step "B3" "Next steps for implementation"
    Write-Host ""
    Write-Host "  1. Read seabridge_ai/docs/AI_agents.md before writing any code." -ForegroundColor White
    Write-Host "  2. Use nature_agent/ as reference implementation." -ForegroundColor White
    Write-Host "  3. For ML experiment: git checkout -b autoresearch/<tag>, edit train.py, run loop." -ForegroundColor White
    Write-Host "  4. Write handoff artifact to autoresearch/handoff/<slug>_findings.md" -ForegroundColor White
    Write-Host "  5. Implement in manageesg-backend/seabridge_ai/src/sustainability_ai/ai_agents/" -ForegroundColor White

    Write-Host "`n[Scenario B Research Phase Complete]" -ForegroundColor Green
    Write-Host "Feynman output: autoresearch/feynman/outputs/" -ForegroundColor Green
}

# ─── Scenario C: ESG Data Intelligence Question ───────────────────────────────

function Run-ScenarioC {
    Write-Host "`n===============================================" -ForegroundColor Cyan
    Write-Host " SCENARIO C: ESG Data Intelligence Question" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host " Workflow: Feynman quick cited answer"

    if ([string]::IsNullOrWhiteSpace($Task)) {
        $script:Task = Read-Host "`nEnter your ESG data question"
    }

    Write-Step "C1" "Cited answer (Feynman)"
    Invoke-Feynman -Query $Task  # Never deep-research for Scenario C — quick is the point

    Write-Host "`n[Scenario C Complete]" -ForegroundColor Green
    Write-Host "Output: autoresearch/feynman/outputs/" -ForegroundColor Green
    Write-Host "Run Berry audit_trace_budget in Claude Code to verify factual claims before acting." -ForegroundColor Yellow
}

# ─── Main ─────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "SeaBridgeAI Sustainability Research Orchestrator" -ForegroundColor White
Write-Host "Stack: Feynman | Paper2Agent | Graphify | Unsloth | autoresearch" -ForegroundColor DarkGray
Write-Host "See: AI_COSCIENTIST_STACK.md | SUSTAINABILITY_WORKFLOW.md" -ForegroundColor DarkGray
if ($DryRun) {
    Write-Host "[DRY RUN MODE — no cost-incurring steps will execute]" -ForegroundColor Yellow
}

switch ($Scenario) {
    "A" { Run-ScenarioA }
    "B" { Run-ScenarioB }
    "C" { Run-ScenarioC }
}
