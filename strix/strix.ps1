# strix.ps1 - Strix AI security pentesting wrapper for SeaBridgeAI
# Usage examples:
#   .\strix.ps1 -Target backend
#   .\strix.ps1 -Target frontend
#   .\strix.ps1 -Target backend -Mode quick
#   .\strix.ps1 -Target backend -Headless
#   .\strix.ps1 -Target custom -Path "C:\path\to\app"

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("backend", "frontend", "custom")]
    [string]$Target,

    [string]$Path = "",

    [ValidateSet("quick", "standard", "deep")]
    [string]$Mode = "deep",

    [string]$Model = "anthropic/claude-sonnet-4-6",

    [switch]$Headless,

    [switch]$DryRun
)

$strixDir = $PSScriptRoot
$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$backendRoot   = Join-Path $workspaceRoot "manageesg-backend"
$frontendRoot  = Join-Path $workspaceRoot "manageesg-frontend"

# Resolve target path
switch ($Target) {
    "backend"  { $targetPath = $backendRoot }
    "frontend" { $targetPath = $frontendRoot }
    "custom"   {
        if (-not $Path) {
            Write-Error "Target 'custom' requires -Path parameter."
            exit 1
        }
        $targetPath = $Path
    }
}

# Validate strix is installed
if (-not (Test-Path -LiteralPath $strixDir)) {
    Write-Error "Strix not found at: $strixDir`nRe-clone: git clone https://github.com/usestrix/strix `"$strixDir`""
    exit 1
}

if (-not (Test-Path -LiteralPath (Join-Path $strixDir "pyproject.toml"))) {
    Write-Error "Strix directory is incomplete. Re-clone: git clone https://github.com/usestrix/strix `"$strixDir`""
    exit 1
}

if (-not (Test-Path -LiteralPath $targetPath)) {
    Write-Error "Target path not found: $targetPath"
    exit 1
}

# Resolve LLM API key: prefer ANTHROPIC_API_KEY for Anthropic models
$apiKey = $env:LLM_API_KEY
if (-not $apiKey) {
    if ($Model -like "anthropic/*") {
        $apiKey = $env:ANTHROPIC_API_KEY
    } elseif ($Model -like "openai/*") {
        $apiKey = $env:OPENAI_API_KEY
    }
}

if (-not $apiKey) {
    Write-Error "No API key found. Set LLM_API_KEY, ANTHROPIC_API_KEY, or OPENAI_API_KEY."
    exit 1
}

Write-Host "[strix] Target  : $targetPath"
Write-Host "[strix] Model   : $Model"
Write-Host "[strix] Mode    : $Mode"
Write-Host "[strix] Headless: $Headless"

# Build strix args
$strixArgs = @("--target", $targetPath, "--scan-mode", $Mode)
if ($Headless) { $strixArgs += "--non-interactive" }

if ($DryRun) {
    Write-Host "[DRY RUN] Would run: uv run strix $($strixArgs -join ' ')"
    Write-Host "[DRY RUN] STRIX_LLM=$Model LLM_API_KEY=<redacted>"
    exit 0
}

# Run strix from within its directory so uv picks up the right virtualenv
Push-Location $strixDir
try {
    $env:STRIX_LLM   = $Model
    $env:LLM_API_KEY = $apiKey

    uv run strix @strixArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Strix exited with code $LASTEXITCODE"
        exit $LASTEXITCODE
    }
} finally {
    Pop-Location
    Remove-Item Env:\STRIX_LLM   -ErrorAction SilentlyContinue
    Remove-Item Env:\LLM_API_KEY -ErrorAction SilentlyContinue
}
