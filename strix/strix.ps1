# strix.ps1 - Strix AI security testing wrapper for SeaBridgeAI.
# Safe defaults:
# - no production target by default
# - supports dry-run and health checks
# - redacts API keys
# - keeps Strix execution inside the local autoresearch/strix clone

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("backend", "frontend", "custom")]
    [string]$Target = "backend",

    [string]$Path = "",

    [ValidateSet("quick", "standard", "deep")]
    [string]$Mode = "quick",

    # Cloud model. Used when -Local is not set.
    [string]$Model = "anthropic/claude-sonnet-4-6",

    # Route through local llama.cpp server at localhost:8080.
    [switch]$Local,

    # Route through LiteLLM proxy at localhost:4000 instead of llama.cpp.
    [switch]$LiteLLM,

    # Override the local model name.
    [string]$LocalModel = "openai/gemma-4-31b-it",

    [switch]$Headless,
    [switch]$DryRun,
    [switch]$CheckOnly
)

$ErrorActionPreference = "Stop"

$strixDir = $PSScriptRoot
$workspaceRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$backendRoot = Join-Path $workspaceRoot "manageesg-backend"
$frontendRoot = Join-Path $workspaceRoot "manageesg-frontend"

function Info($message) { Write-Host "[strix] $message" -ForegroundColor Cyan }
function Warn($message) { Write-Host "[strix][WARN] $message" -ForegroundColor Yellow }
function Fail($message) { Write-Error "[strix] $message" }

function Test-Url($url) {
    try {
        $response = Invoke-WebRequest -Uri $url -TimeoutSec 4 -UseBasicParsing -ErrorAction Stop
        return ($response.StatusCode -ge 200 -and $response.StatusCode -lt 500)
    } catch {
        return $false
    }
}

function Resolve-TargetPath {
    switch ($Target) {
        "backend" { return $backendRoot }
        "frontend" { return $frontendRoot }
        "custom" {
            if (-not $Path) {
                Fail "Target 'custom' requires -Path."
                exit 1
            }
            return $Path
        }
    }
}

function Test-StrixEnvironment {
    $ok = $true

    if (-not (Test-Path -LiteralPath $strixDir)) {
        Fail "Strix directory not found: $strixDir"
        return $false
    }

    if (-not (Test-Path -LiteralPath (Join-Path $strixDir "pyproject.toml"))) {
        Fail "Strix directory is incomplete: $strixDir"
        return $false
    }

    if (-not (Get-Command "uv" -ErrorAction SilentlyContinue)) {
        Warn "uv is not on PATH; Strix cannot run until uv is available."
        $ok = $false
    }

    if (-not (Get-Command "docker" -ErrorAction SilentlyContinue)) {
        Warn "Docker CLI is not on PATH; Strix sandbox execution may fail."
        $ok = $false
    } else {
        $dockerPs = docker ps --format "{{.ID}}" 2>&1
        if ($LASTEXITCODE -ne 0) {
            Warn "Docker CLI is present but Docker is not reachable."
            $ok = $false
        } else {
            Info "Docker reachable."
        }
    }

    return $ok
}

if (-not (Test-StrixEnvironment)) {
    if ($CheckOnly) { exit 1 }
    Fail "Strix environment check failed."
    exit 1
}

$targetPath = Resolve-TargetPath
if (-not (Test-Path -LiteralPath $targetPath)) {
    Fail "Target path not found: $targetPath"
    exit 1
}

$apiBase = $null
$apiKey = $null

if ($Local) {
    $activeModel = $LocalModel

    if ($LiteLLM) {
        $apiBase = "http://localhost:4000/v1"
        $endpoint = "http://localhost:4000/v1/models"
        $serverName = "LiteLLM proxy"
    } else {
        $apiBase = "http://localhost:8080/v1"
        $endpoint = "http://localhost:8080/v1/models"
        $serverName = "llama.cpp"
    }

    if (-not (Test-Url $endpoint)) {
        Warn "$serverName is not reachable at $apiBase."
        if ($CheckOnly) { exit 1 }
        Fail "Start the local model endpoint first or run without -Local using an approved cloud key."
        exit 1
    }

    $apiKey = "local"
    Info "Provider: LOCAL ($serverName)"
    Info "API base: $apiBase"
} else {
    $activeModel = $Model
    $apiKey = $env:LLM_API_KEY

    if (-not $apiKey) {
        if ($Model -like "anthropic/*") {
            $envFile = Join-Path $backendRoot ".env"
            if (Test-Path $envFile) {
                $line = Select-String -Path $envFile -Pattern "^ANTHROPIC_API_KEY=" | Select-Object -First 1
                if ($line) {
                    $apiKey = $line.Line.Split("=", 2)[1].Trim()
                }
            }
            if (-not $apiKey) { $apiKey = $env:ANTHROPIC_API_KEY }
        } elseif ($Model -like "openai/*") {
            $apiKey = $env:OPENAI_API_KEY
        }
    }

    if (-not $apiKey) {
        Warn "No cloud LLM API key found. Set LLM_API_KEY, ANTHROPIC_API_KEY, or OPENAI_API_KEY, or use -Local."
        if ($CheckOnly) { exit 1 }
        Fail "Strix requires an approved LLM provider before an active scan."
        exit 1
    }

    Info "Provider: CLOUD"
}

Info "Target  : $targetPath"
Info "Model   : $activeModel"
Info "Mode    : $Mode"
Info "Headless: $Headless"

$strixArgs = @("--target", $targetPath, "--scan-mode", $Mode)
if ($Headless) { $strixArgs += "--non-interactive" }

if ($CheckOnly) {
    Info "CheckOnly passed."
    exit 0
}

if ($DryRun) {
    Info "DRY RUN: uv run strix $($strixArgs -join ' ')"
    Info "DRY RUN: STRIX_LLM=$activeModel LLM_API_KEY=<redacted> LLM_API_BASE=$apiBase"
    exit 0
}

Push-Location $strixDir
try {
    $env:STRIX_LLM = $activeModel
    $env:LLM_API_KEY = $apiKey
    if ($apiBase) { $env:LLM_API_BASE = $apiBase }

    # litellm's Anthropic provider checks ANTHROPIC_API_KEY directly in addition
    # to the generic LLM_API_KEY, so set both when routing to anthropic/* models.
    $setAnthropicKey = $false
    if ($activeModel -like "anthropic/*" -and -not $env:ANTHROPIC_API_KEY) {
        $env:ANTHROPIC_API_KEY = $apiKey
        $setAnthropicKey = $true
    }

    uv run strix @strixArgs
    if ($LASTEXITCODE -ne 0) {
        Fail "Strix exited with code $LASTEXITCODE"
        exit $LASTEXITCODE
    }
} finally {
    Pop-Location
    Remove-Item Env:\STRIX_LLM -ErrorAction SilentlyContinue
    Remove-Item Env:\LLM_API_KEY -ErrorAction SilentlyContinue
    Remove-Item Env:\LLM_API_BASE -ErrorAction SilentlyContinue
    if ($setAnthropicKey) { Remove-Item Env:\ANTHROPIC_API_KEY -ErrorAction SilentlyContinue }
}
