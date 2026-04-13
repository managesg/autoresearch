param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("build-graphs", "query-graph", "build-paper-agent", "benchmark-paper-agent",
                 "run-coscientist", "run-ai-scientist", "run-feynman", "status", "help")]
    [string]$Action,

    # graph actions
    [string]$RepoName,        # build-graphs: "backend", "autoresearch", "ecc", or "all"
    [string]$Query,           # query-graph: natural-language query string

    # paper-agent actions
    [string]$ProjectDir,      # build-paper-agent: output project directory name
    [string]$GithubUrl,       # build-paper-agent: source repo URL
    [string[]]$Tutorials,     # build-paper-agent (optional): tutorial topics
    [string]$BenchAction,     # benchmark-paper-agent: install|register-mcp|labels|analyze

    # co-scientist / ai-scientist actions
    [string]$Task,            # run-coscientist / run-feynman: research task description
    [string]$Idea,            # run-ai-scientist (optional): seed idea for experiment

    # feynman options
    [switch]$DeepResearch,    # run-feynman: use deepresearch (multi-agent) mode instead of single query
    [string]$FeynmanProvider, # run-feynman (optional): custom provider (e.g. "ollama")

    [switch]$DryRun
)

# ── Paths (derived from this script's location — no machine-specific hardcoding) ─
$autoresearchRoot  = $PSScriptRoot
$workspaceRoot     = Split-Path -Parent $PSScriptRoot
$backendRoot       = Join-Path $workspaceRoot "manageesg-backend"
$eccRoot           = Join-Path $workspaceRoot "everything-claude-code"
$graphifyRepo      = Join-Path $autoresearchRoot "graphify"
$paper2agentRepo   = Join-Path $autoresearchRoot "Paper2Agent"
$paper2agentBench  = Join-Path $autoresearchRoot "Paper2AgentBench"
$coScientistRepo   = Join-Path $autoresearchRoot "AI-CoScientist"
$aiScientistRepo   = Join-Path $autoresearchRoot "ai-scientist"
$feynmanRepo       = Join-Path $autoresearchRoot "feynman"
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
  build-paper-agent      Convert a paper/code repo into an MCP-backed agent (Paper2Agent)
  benchmark-paper-agent  Run Paper2AgentBench evaluation on generated agents
  run-coscientist        Launch multi-agent scientific ideation via AI-CoScientist (Swarm)
  run-ai-scientist       Run autonomous experiment generation via AI-Scientist (Sakana)
  run-feynman            Run Feynman AI research agent (single query or deepresearch)
  status                 Report clone presence for all 6 tool repos
  help                   Show this message

FLAGS
  -RepoName <name>       For build-graphs: backend | autoresearch | ecc | all
  -Query <text>          For query-graph: natural-language query
  -ProjectDir <dir>      For build-paper-agent: output project directory name
  -GithubUrl <url>       For build-paper-agent: source repo URL
  -Tutorials <topics>    For build-paper-agent (optional): comma-separated tutorial topics
  -BenchAction <action>  For benchmark-paper-agent: install | register-mcp | labels | analyze
  -Task <text>           For run-coscientist / run-feynman: research task or query string
  -Idea <text>           For run-ai-scientist (optional): seed idea for experiment
  -DeepResearch          For run-feynman: use multi-agent deepresearch mode (slower, more thorough)
  -FeynmanProvider       For run-feynman (optional): custom provider (e.g. "ollama")
  -DryRun                Print commands without executing

EXAMPLES
  .\co-scientist-orchestrator.ps1 -Action status
  .\co-scientist-orchestrator.ps1 -Action build-graphs -RepoName all -DryRun
  .\co-scientist-orchestrator.ps1 -Action query-graph -Query "show AI manager handoff flow"
  .\co-scientist-orchestrator.ps1 -Action build-paper-agent -ProjectDir TISSUE_Agent -GithubUrl https://github.com/sunericd/TISSUE
  .\co-scientist-orchestrator.ps1 -Action benchmark-paper-agent -BenchAction analyze
  .\co-scientist-orchestrator.ps1 -Action run-coscientist -Task "Identify ESG risk factors in climate transition scenarios"
  .\co-scientist-orchestrator.ps1 -Action run-ai-scientist -Idea "Novel ESG metric combining physical risk and regulatory exposure"
  .\co-scientist-orchestrator.ps1 -Action run-feynman -Task "What are the latest TNFD disclosure requirements for nature risk?"
  .\co-scientist-orchestrator.ps1 -Action run-feynman -Task "Biodiversity net gain methodologies" -DeepResearch
"@
    }

    "status" {
        Write-Host "=== SeaBridgeAI Research Stack Status ==="
        $repos = @{
            "graphify"        = $graphifyRepo
            "Paper2Agent"     = $paper2agentRepo
            "Paper2AgentBench"= $paper2agentBench
            "AI-CoScientist"  = $coScientistRepo
            "ai-scientist"    = $aiScientistRepo
            "feynman"         = $feynmanRepo
        }
        $cloneUrls = @{
            "graphify"        = "https://github.com/safishamsi/graphify"
            "Paper2Agent"     = "https://github.com/jmiao24/Paper2Agent"
            "Paper2AgentBench"= "https://github.com/jmiao24/Paper2AgentBench"
            "AI-CoScientist"  = "https://github.com/The-Swarm-Corporation/AI-CoScientist"
            "ai-scientist"    = "https://github.com/sakanaai/ai-scientist"
            "feynman"         = "https://github.com/getcompanion-ai/feynman"
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
        # Check for graph output
        $graphJson = Join-Path $backendRoot "graphify-out\graph.json"
        if (Test-Path -LiteralPath $graphJson) {
            Write-Host "  [OK]     Backend graph -> $graphJson"
        } else {
            Write-Host "  [INFO]   No backend graph yet. Run: .\co-scientist-orchestrator.ps1 -Action build-graphs -RepoName backend"
        }
    }

    "build-graphs" {
        Assert-Repo $graphifyRepo "graphify"
        Assert-Python
        if (-not $RepoName) { $RepoName = "all" }
        $targets = @{
            "backend"     = $backendRoot
            "autoresearch"= $autoresearchRoot
            "ecc"         = $eccRoot
        }
        $selected = if ($RepoName -eq "all") { $targets.Keys } else { @($RepoName) }
        foreach ($name in $selected) {
            if (-not $targets.ContainsKey($name)) {
                Write-Error "Unknown repo name '$name'. Use: backend | autoresearch | ecc | all"
                exit 1
            }
            $repoPath = $targets[$name]
            $outDir   = Join-Path $repoPath "graphify-out"
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
manifest = detect(str(repo_path))

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
        $graphJson = Join-Path $backendRoot "graphify-out\graph.json"
        if (-not (Test-Path -LiteralPath $graphJson)) {
            Write-Warning "No backend graph found at $graphJson. Run build-graphs first."
        }
        $env:PYTHONPATH = "$graphifyRepo;$env:PYTHONPATH"
        Invoke-OrDryRun "Query graph: $Query" {
            & $pythonExe -m graphify query $Query --graph $graphJson
        }
    }

    "build-paper-agent" {
        Assert-Repo $paper2agentRepo "Paper2Agent"
        if (-not $ProjectDir) { Write-Error "-ProjectDir is required for build-paper-agent"; exit 1 }
        if (-not $GithubUrl)  { Write-Error "-GithubUrl is required for build-paper-agent"; exit 1 }
        Write-Host "[NOTICE] Paper2Agent runs can take 30 min to 3+ hours and may incur API costs."
        Write-Host "         Ensure you have approved this run explicitly."
        $ps1 = Join-Path $backendRoot "paper2agent.ps1"
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
        $ps1 = Join-Path $backendRoot "paper2agent-bench.ps1"
        $extraArgs = @("-Action", $BenchAction)
        if ($DryRun) { $extraArgs += "-DryRun" }
        Invoke-OrDryRun "Benchmark paper agent: $BenchAction" {
            & powershell -ExecutionPolicy Bypass -File $ps1 @extraArgs
        }
    }

    "run-coscientist" {
        Assert-Repo $coScientistRepo "AI-CoScientist"
        Assert-Python
        if (-not $Task) { Write-Error "-Task is required for run-coscientist"; exit 1 }
        Write-Host "[COST NOTICE] AI-CoScientist is a multi-agent Swarm framework."
        Write-Host "              This may invoke many LLM calls and incur significant API cost."
        Write-Host "              Ensure explicit written approval from adelmar@seabridge.ai before proceeding."
        $env:PYTHONPATH = "$coScientistRepo;$env:PYTHONPATH"
        Invoke-OrDryRun "Run AI-CoScientist: $Task" {
            & $pythonExe -m ai_coscientist --task $Task
        }
    }

    "run-ai-scientist" {
        Write-Host "[ISOLATION REQUIRED] AI-Scientist (Sakana) generates and EXECUTES model-written code."
        Write-Host "                     This action MUST be run in an isolated/sandboxed environment."
        Write-Host "                     Never run on a production machine or shared infrastructure."
        Write-Host "                     Ensure explicit written approval from adelmar@seabridge.ai."
        if ($DryRun) {
            Write-Host "[DRY RUN] Would launch AI-Scientist from: $aiScientistRepo"
            exit 0
        }
        Assert-Repo $aiScientistRepo "AI-Scientist"
        Assert-Python
        $env:PYTHONPATH = "$aiScientistRepo;$env:PYTHONPATH"
        $extraArgs = @()
        if ($Idea) { $extraArgs += @("--idea", $Idea) }
        & $pythonExe -m aiscientist @extraArgs
        exit $LASTEXITCODE
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
}
