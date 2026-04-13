# feynman.ps1 - Feynman research agent wrapper for SeaBridgeAI autoresearch
# Usage: .\feynman.ps1 [args...]
# Examples:
#   .\feynman.ps1 "what do we know about scaling laws"
#   .\feynman.ps1 deepresearch "mechanistic interpretability"
#   .\feynman.ps1 lit "RLHF alternatives"

param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Args
)

$feynmanDir = Join-Path $PSScriptRoot "feynman"
$feynmanBin = Join-Path $feynmanDir "bin\feynman.js"

if (-not (Test-Path $feynmanBin)) {
    Write-Error "Feynman not built. Run: cd $feynmanDir && npm install && npm run build"
    exit 1
}

node $feynmanBin @Args
