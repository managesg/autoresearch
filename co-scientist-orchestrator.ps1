param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("build-graphs", "query-graph", "load-falkordb", "build-paper-agent", "benchmark-paper-agent",
                 "run-coscientist", "run-feynman", "run-strix", "status", "help")]
    [string]$Action,

    # graph actions
    [string]$RepoName,        # build-graphs: "backend", "frontend", "autoresearch", "ecc", or "all"
    [string]$Query,           # query-graph: natural-language query string
    [string]$GraphJson,       # load-falkordb: graphify graph.json path
    [string]$GraphName,       # load-falkordb: FalkorDB graph name
    [string]$FalkorHost = "127.0.0.1",
    [int]$FalkorPort = 6380,
    [switch]$FalkorDryRun,

    # paper-agent actions
    [string]$ProjectDir,      # build-paper-agent: output project directory name
    [string]$GithubUrl,       # build-paper-agent: source repo URL
    [string[]]$Tutorials,     # build-paper-agent (optional): tutorial topics
    [string]$BenchAction,     # benchmark-paper-agent: install|register-mcp|labels|analyze

    # feynman actions
    [string]$Task,            # run-feynman: research task description

    # feynman options
    [switch]$DeepResearch,    # run-feynman: use deepresearch (multi-agent) mode instead of single query
    [string]$FeynmanProvider, # run-feynman (optional): custom provider (e.g. "ollama")

    # strix options
    [ValidateSet("backend", "frontend", "custom")]
    [string]$StrixTarget = "backend",  # run-strix: which target to scan
    [string]$StrixPath = "",           # run-strix: custom path (when StrixTarget=custom)
    [ValidateSet("quick", "standard", "deep")]
    [string]$StrixMode = "deep",       # run-strix: scan depth
    [string]$StrixModel = "anthropic/claude-sonnet-4-6",  # run-strix: LLM model
    [switch]$StrixHeadless,            # run-strix: non-interactive mode

    [switch]$DryRun
)

# ── Paths (derived from this script's location — no machine-specific hardcoding) ─
$autoresearchRoot  = $PSScriptRoot
$workspaceRoot     = Split-Path -Parent $PSScriptRoot
$backendRoot       = Join-Path $workspaceRoot "manageesg-backend"
$eccRoot           = Join-Path $workspaceRoot "everything-claude-code"
$graphifyRepo      = Join-Path $autoresearchRoot "graphify"
$paper2agentRepo   = Join-Path $autoresearchRoot "paper2agent-suite\Paper2Agent"
$paper2agentBench  = Join-Path $autoresearchRoot "paper2agent-suite\Paper2AgentBench"
$coScientistRepo   = Join-Path $autoresearchRoot "archived\AI-CoScientist"
$feynmanRepo       = Join-Path $autoresearchRoot "feynman"
$strixRepo         = Join-Path $autoresearchRoot "strix"
$frontendRoot      = Join-Path $workspaceRoot "manageesg-frontend"
$pythonExe         = Join-Path $autoresearchRoot ".venv\Scripts\python.exe"

function Invoke-OrDryRun {
    param([string]$Description, [scriptblock]$Cmd)
    Write-Host "[ACTION] $Description"
    if ($DryRun) {
        Write-Host "[DRY RUN] $($Cmd.ToString().Trim())"
    } else {
        & $Cmd
    }
}

function Assert-Repo {
    param([string]$Path, [string]$Name)
    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Error "$Name not found at: $Path`nClone it first: git clone <url> `"$Path`""
        exit 1
    }
}

function Assert-Python {
    if (-not (Test-Path -LiteralPath $pythonExe)) {
        Write-Error "Python venv not found at: $pythonExe`nRun: cd `"$autoresearchRoot`" && uv sync"
        exit 1
    }
}

switch ($Action) {

    "help" {
        Write-Host @"
co-scientist-orchestrator.ps1 — Unified SeaBridgeAI research stack wrapper
Source-of-truth clones: C:\Users\adelm\SeaBridgeAI\autoresearch\

ACTIONS
  build-graphs           Build Graphify knowledge graphs for one or all repos
  query-graph            Query an existing Graphify knowledge graph
  load-falkordb          Load graphify graph.json into FalkorDB with non-destructive MERGE queries
  build-paper-agent      Convert a paper/code repo into an MCP-backed agent (Paper2Agent)
  benchmark-paper-agent  Run Paper2AgentBench evaluation on generated agents
  run-coscientist        [ARCHIVED] AI-CoScientist archived at autoresearch/archived/AI-CoScientist/; use run-feynman instead
  run-feynman            Run Feynman AI research agent (single query or deepresearch)
  run-strix              Run Strix AI security pentest against backend or frontend
  status                 Report clone presence for all 6 tool repos
  help                   Show this message

FLAGS
  -RepoName <name>       For build-graphs: backend | frontend | autoresearch | ecc | all
  -Query <text>          For query-graph: natural-language query
  -GraphJson <path>      For load-falkordb: graphify graph.json path
  -GraphName <name>      For load-falkordb: FalkorDB graph name
  -FalkorDryRun          For load-falkordb: inspect graph without connecting to FalkorDB
  -ProjectDir <dir>      For build-paper-agent: output project directory name
  -GithubUrl <url>       For build-paper-agent: source repo URL
  -Tutorials <topics>    For build-paper-agent (optional): comma-separated tutorial topics
  -BenchAction <action>  For benchmark-paper-agent: install | register-mcp | labels | analyze
  -Task <text>           For run-feynman: research task or query string
  -DeepResearch          For run-feynman: use multi-agent deepresearch mode (slower, more thorough)
  -FeynmanProvider       For run-feynman (optional): custom provider (e.g. "ollama")
  -StrixTarget <target>  For run-strix: backend | frontend | custom (default: backend)
  -StrixPath <path>      For run-strix: custom target path (when StrixTarget=custom)
  -StrixMode <mode>      For run-strix: standard | quick (default: standard)
  -StrixModel <model>    For run-strix: LLM model (default: anthropic/claude-sonnet-4-6)
  -StrixHeadless         For run-strix: non-interactive headless mode
  -DryRun                Print commands without executing

EXAMPLES
  .\co-scientist-orchestrator.ps1 -Action status
  .\co-scientist-orchestrator.ps1 -Action build-graphs -RepoName all -DryRun
  .\co-scientist-orchestrator.ps1 -Action query-graph -Query "show AI manager handoff flow"
  .\co-scientist-orchestrator.ps1 -Action load-falkordb -GraphName backend -FalkorDryRun
  .\co-scientist-orchestrator.ps1 -Action build-paper-agent -ProjectDir TISSUE_Agent -GithubUrl https://github.com/sunericd/TISSUE
  .\co-scientist-orchestrator.ps1 -Action benchmark-paper-agent -BenchAction analyze
  .\co-scientist-orchestrator.ps1 -Action run-feynman -Task "What are the latest TNFD disclosure requirements for nature risk?"
  .\co-scientist-orchestrator.ps1 -Action run-feynman -Task "Biodiversity net gain methodologies" -DeepResearch
  .\co-scientist-orchestrator.ps1 -Action run-strix -StrixTarget backend
  .\co-scientist-orchestrator.ps1 -Action run-strix -StrixTarget frontend -StrixMode quick
  .\co-scientist-orchestrator.ps1 -Action run-strix -StrixTarget backend -StrixHeadless
"@
    }

    "status" {
        Write-Host "=== SeaBridgeAI Research Stack Status ==="
        $repos = @{
            "graphify"        = $graphifyRepo
            "Paper2Agent"     = $paper2agentRepo
            "Paper2AgentBench"= $paper2agentBench
            "AI-CoScientist"  = $coScientistRepo
            "feynman"         = $feynmanRepo
            "strix"           = $strixRepo
        }
        $cloneUrls = @{
            "graphify"        = "https://github.com/safishamsi/graphify"
            "Paper2Agent"     = "https://github.com/jmiao24/Paper2Agent"
            "Paper2AgentBench"= "https://github.com/jmiao24/Paper2AgentBench"
            "AI-CoScientist"  = "https://github.com/The-Swarm-Corporation/AI-CoScientist"
            "feynman"         = "https://github.com/getcompanion-ai/feynman"
            "strix"           = "https://github.com/usestrix/strix"
        }
        foreach ($name in $repos.Keys) {
            $path = $repos[$name]
            if (Test-Path -LiteralPath $path) {
                Write-Host "  [OK]     $name -> $path"
            } else {
                Write-Host "  [MISSING] $name -> $path"
                Write-Host "             Clone: git clone $($cloneUrls[$name]) `"$path`""
            }
        }
        Write-Host ""
        if (Test-Path -LiteralPath $pythonExe) {
            Write-Host "  [OK]     Python venv -> $pythonExe"
        } else {
            Write-Host "  [MISSING] Python venv -> $pythonExe"
            Write-Host "             Setup: cd `"$autoresearchRoot`" && uv sync"
        }
        # Check for graph output (autoresearch graph lives inside graphify/output/)
        $graphJson = Join-Path $graphifyRepo "output\graph.json"
        if (Test-Path -LiteralPath $graphJson) {
            Write-Host "  [OK]     Autoresearch graph -> $graphJson"
        } else {
            Write-Host "  [INFO]   No autoresearch graph yet. Run: .\co-scientist-orchestrator.ps1 -Action build-graphs -RepoName autoresearch"
        }
    }

    "build-graphs" {
        Assert-Repo $graphifyRepo "graphify"
        Assert-Python
        if (-not $RepoName) { $RepoName = "all" }
        $targets = @{
            "backend"     = $backendRoot
            "frontend"    = $frontendRoot
            "autoresearch"= $autoresearchRoot
            "ecc"         = $eccRoot
        }
        $selected = if ($RepoName -eq "all") { $targets.Keys } else { @($RepoName) }
        foreach ($name in $selected) {
            if (-not $targets.ContainsKey($name)) {
                Write-Error "Unknown repo name '$name'. Use: backend | frontend | autoresearch | ecc | all"
                exit 1
            }
            $repoPath = $targets[$name]
            # Autoresearch graph output lives inside graphify/output/ to keep tool+output together.
            # All other repos write their graph to <repo>/graphify-out/ as before.
            $outDir   = if ($name -eq "autoresearch") { Join-Path $graphifyRepo "output" } else { Join-Path $repoPath "graphify-out" }
            $env:PYTHONPATH = "$graphifyRepo;$env:PYTHONPATH"
            Invoke-OrDryRun "Build graph for $name ($repoPath)" {
                # graphify has no 'build' CLI command — use the Python API directly (AST-only, free)
                & $pythonExe -c @"
import sys, json, os
from pathlib import Path

repo_path = Path(sys.argv[1])
out_dir   = Path(sys.argv[2])
out_dir.mkdir(parents=True, exist_ok=True)

from graphify.detect  import detect
from graphify.extract import collect_files, extract
from graphify.build   import build_from_json
from graphify.cluster import cluster, score_all
from graphify.analyze import god_nodes, surprising_connections, suggest_questions
from graphify.report  import generate
from graphify.export  import to_json

print(f'[graphify] Detecting files in {repo_path}')
manifest = detect(repo_path)

print(f'[graphify] Extracting AST (code-only, no LLM)')
files = collect_files(manifest, include_docs=False, include_papers=False, include_images=False)
records = extract(files, use_llm=False)

print(f'[graphify] Building graph')
G = build_from_json(records)
G = cluster(G)
G = score_all(G)

graph_json = out_dir / 'graph.json'
to_json(G, str(graph_json))
print(f'[graphify] Graph saved -> {graph_json}')

report_md = out_dir / 'GRAPH_REPORT.md'
report = generate(G, god_nodes(G), surprising_connections(G), suggest_questions(G))
report_md.write_text(report, encoding='utf-8')
print(f'[graphify] Report saved -> {report_md}')
"@ "$repoPath" "$outDir"
            }
        }
    }

    "query-graph" {
        Assert-Repo $graphifyRepo "graphify"
        Assert-Python
        if (-not $Query) { Write-Error "-Query is required for query-graph"; exit 1 }
        $graphJson = Join-Path $graphifyRepo "output\graph.json"
        if (-not (Test-Path -LiteralPath $graphJson)) {
            Write-Warning "No autoresearch graph found at $graphJson. Run build-graphs -RepoName autoresearch first."
        }
        $env:PYTHONPATH = "$graphifyRepo;$env:PYTHONPATH"
        Invoke-OrDryRun "Query graph: $Query" {
            & $pythonExe -m graphify query $Query --graph $graphJson
        }
    }

    "load-falkordb" {
        Assert-Repo $graphifyRepo "graphify"
        Assert-Python
        if (-not $GraphName) {
            $GraphName = if ($RepoName) { $RepoName } else { "backend" }
        }
        if (-not $GraphJson) {
            if ($GraphName -eq "autoresearch") {
                $GraphJson = Join-Path $graphifyRepo "output\graph.json"
            } else {
                $repoMap = @{
                    "backend"  = $backendRoot
                    "frontend" = $frontendRoot
                    "ecc"      = $eccRoot
                }
                if (-not $repoMap.ContainsKey($GraphName)) {
                    Write-Error "-GraphJson is required when -GraphName is not backend, frontend, ecc, or autoresearch"
                    exit 1
                }
                $GraphJson = Join-Path $repoMap[$GraphName] "graphify-out\graph.json"
            }
        }
        if (-not (Test-Path -LiteralPath $GraphJson)) {
            Write-Error "Graph JSON not found at: $GraphJson"
            exit 1
        }
        $loader = Join-Path $graphifyRepo "load_to_falkordb.py"
        $loaderArgs = @(
            "--graph-json", $GraphJson,
            "--graph-name", $GraphName,
            "--host", $FalkorHost,
            "--port", $FalkorPort
        )
        if ($FalkorDryRun) { $loaderArgs += "--dry-run" }
        Invoke-OrDryRun "Load graph into FalkorDB graph '$GraphName' from $GraphJson" {
            & $pythonExe $loader @loaderArgs
        }
    }

    "build-paper-agent" {
        Assert-Repo $paper2agentRepo "Paper2Agent"
        if (-not $ProjectDir) { Write-Error "-ProjectDir is required for build-paper-agent"; exit 1 }
        if (-not $GithubUrl)  { Write-Error "-GithubUrl is required for build-paper-agent"; exit 1 }
        Write-Host "[NOTICE] Paper2Agent runs can take 30 min to 3+ hours and may incur API costs."
        Write-Host "         Ensure you have approved this run explicitly."
        $ps1 = Join-Path $paper2agentRepo "paper2agent.ps1"
        $extraArgs = @("-ProjectDir", $ProjectDir, "-GithubUrl", $GithubUrl)
        if ($Tutorials) { $extraArgs += @("-Tutorials", ($Tutorials -join ",")) }
        if ($DryRun)    { $extraArgs += "-DryRun" }
        Invoke-OrDryRun "Build paper agent: $ProjectDir from $GithubUrl" {
            & powershell -ExecutionPolicy Bypass -File $ps1 @extraArgs
        }
    }

    "benchmark-paper-agent" {
        Assert-Repo $paper2agentBench "Paper2AgentBench"
        if (-not $BenchAction) { Write-Error "-BenchAction is required (install|register-mcp|labels|analyze)"; exit 1 }
        $ps1 = Join-Path $paper2agentBench "paper2agent-bench.ps1"
        $extraArgs = @("-Action", $BenchAction)
        if ($DryRun) { $extraArgs += "-DryRun" }
        Invoke-OrDryRun "Benchmark paper agent: $BenchAction" {
            & powershell -ExecutionPolicy Bypass -File $ps1 @extraArgs
        }
    }

    "run-coscientist" {
        Write-Error "AI-CoScientist is ARCHIVED and cannot be invoked. Use run-feynman instead:`n  .\co-scientist-orchestrator.ps1 -Action run-feynman -Task `"$Task`""
        exit 1
    }

    "run-feynman" {
        Assert-Repo $feynmanRepo "feynman"
        if (-not $Task) { Write-Error "-Task is required for run-feynman"; exit 1 }

        # Resolve the feynman binary (local install preferred, then global)
        $feynmanBin = Join-Path $feynmanRepo "bin\feynman.js"
        $nodeCmd    = "node"
        if (-not (Test-Path -LiteralPath $feynmanBin)) {
            # Fall back to globally installed feynman CLI
            $feynmanBin = "feynman"
            $nodeCmd    = ""
        }

        $mode = if ($DeepResearch) { "deepresearch" } else { $null }

        $extraArgs = @()
        if ($FeynmanProvider) { $extraArgs += @("--provider", $FeynmanProvider) }

        if ($DryRun) {
            if ($mode) {
                Write-Host "[DRY RUN] node $feynmanBin $mode `"$Task`" $extraArgs"
            } else {
                Write-Host "[DRY RUN] node $feynmanBin `"$Task`" $extraArgs"
            }
            exit 0
        }

        Invoke-OrDryRun "Run Feynman ($( if ($DeepResearch) { 'deepresearch' } else { 'query' } )): $Task" {
            if ($nodeCmd) {
                if ($mode) {
                    & $nodeCmd $feynmanBin $mode $Task @extraArgs
                } else {
                    & $nodeCmd $feynmanBin $Task @extraArgs
                }
            } else {
                if ($mode) {
                    & $feynmanBin $mode $Task @extraArgs
                } else {
                    & $feynmanBin $Task @extraArgs
                }
            }
        }
        exit $LASTEXITCODE
    }

    "run-strix" {
        Assert-Repo $strixRepo "strix"

        # Resolve target path
        $resolvedTarget = switch ($StrixTarget) {
            "backend"  { $backendRoot }
            "frontend" { $frontendRoot }
            "custom"   {
                if (-not $StrixPath) { Write-Error "-StrixPath is required when StrixTarget=custom"; exit 1 }
                $StrixPath
            }
        }

        if (-not (Test-Path -LiteralPath $resolvedTarget)) {
            Write-Error "Target path not found: $resolvedTarget"
            exit 1
        }

        # Resolve API key
        $apiKey = $env:LLM_API_KEY
        if (-not $apiKey) {
            if ($StrixModel -like "anthropic/*") { $apiKey = $env:ANTHROPIC_API_KEY }
            elseif ($StrixModel -like "openai/*") { $apiKey = $env:OPENAI_API_KEY }
        }
        if (-not $apiKey) {
            Write-Error "No API key found. Set LLM_API_KEY, ANTHROPIC_API_KEY, or OPENAI_API_KEY."
            exit 1
        }

        # Build strix args
        $strixArgs = @("--target", $resolvedTarget, "--scan-mode", $StrixMode)
        if ($StrixHeadless) { $strixArgs += "--non-interactive" }

        Write-Host "[strix] Target  : $resolvedTarget"
        Write-Host "[strix] Model   : $StrixModel"
        Write-Host "[strix] Mode    : $StrixMode"
        Write-Host "[strix] Headless: $StrixHeadless"

        if ($DryRun) {
            Write-Host "[DRY RUN] STRIX_LLM=$StrixModel LLM_API_KEY=<redacted>"
            Write-Host "[DRY RUN] cd `"$strixRepo`" && uv run strix $($strixArgs -join ' ')"
            exit 0
        }

        Push-Location $strixRepo
        try {
            $env:STRIX_LLM   = $StrixModel
            $env:LLM_API_KEY = $apiKey
            uv run strix @strixArgs
            $exitCode = $LASTEXITCODE
        } finally {
            Pop-Location
            Remove-Item Env:\STRIX_LLM   -ErrorAction SilentlyContinue
            Remove-Item Env:\LLM_API_KEY -ErrorAction SilentlyContinue
        }
        exit $exitCode
    }
}
