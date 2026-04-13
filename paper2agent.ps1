param(
    [string]$ProjectDir,
    [string]$GithubUrl,
    [string]$Tutorials,
    [string]$ApiKey,
    [switch]$Benchmark,
    [switch]$DryRun,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ExtraArgs
)

$paper2agentRepo = "C:\Users\adelm\SeaBridgeAI\autoresearch\Paper2Agent"
$runnerScript = Join-Path $paper2agentRepo "Paper2Agent.sh"

function Show-Usage {
    Write-Host "paper2agent wrapper"
    Write-Host ""
    Write-Host "Required (for full run mode):"
    Write-Host "  -ProjectDir <name>"
    Write-Host "  -GithubUrl  <url>"
    Write-Host ""
    Write-Host "Optional:"
    Write-Host "  -Tutorials <title-or-url>"
    Write-Host "  -ApiKey <key>"
    Write-Host "  -Benchmark"
    Write-Host "  -DryRun"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\paper2agent.ps1 -ProjectDir TISSUE_Agent -GithubUrl https://github.com/sunericd/TISSUE"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\paper2agent.ps1 -ProjectDir Scanpy_Agent -GithubUrl https://github.com/scverse/scanpy -Tutorials ""Preprocessing and clustering"""
    Write-Host ""
    Write-Host "Pass-through mode:"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\paper2agent.ps1 -- --project_dir X --github_url https://github.com/org/repo"
}

if (-not (Test-Path -LiteralPath $paper2agentRepo)) {
    Write-Error "Paper2Agent repository not found: $paper2agentRepo"
    exit 1
}

if (-not (Test-Path -LiteralPath $runnerScript)) {
    Write-Error "Paper2Agent runner not found: $runnerScript"
    exit 1
}

$bash = Get-Command bash -ErrorAction SilentlyContinue
if (-not $bash) {
    Write-Error "bash is required. Install Git Bash/WSL and ensure 'bash' is on PATH."
    exit 1
}

$argList = @()

if ($ExtraArgs -and $ExtraArgs.Count -gt 0) {
    $argList += $ExtraArgs
} elseif ($ProjectDir -and $GithubUrl) {
    $argList += "--project_dir"
    $argList += $ProjectDir
    $argList += "--github_url"
    $argList += $GithubUrl

    if ($Tutorials) {
        $argList += "--tutorials"
        $argList += $Tutorials
    }
    if ($ApiKey) {
        $argList += "--api"
        $argList += $ApiKey
    }
    if ($Benchmark) {
        $argList += "--benchmark"
    }
} else {
    Show-Usage
    exit 0
}

$cmdPreview = "bash `"$runnerScript`" " + ($argList -join " ")
if ($DryRun) {
    Write-Host "[DRY RUN] $cmdPreview"
    exit 0
}

Write-Host "Running: $cmdPreview"
& bash $runnerScript @argList
exit $LASTEXITCODE
