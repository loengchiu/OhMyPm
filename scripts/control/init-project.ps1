param(
    [string]$RuntimeDir = ".ohmypm",
    [string]$OutputDir = "output"
)

function Ensure-Dir {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptRoot '..\..')
$projectRoot = Resolve-Path -LiteralPath '.'

$sourceStatus = Join-Path $repoRoot '.ohmypm\status.json'
$sourceMemory = Join-Path $repoRoot '.ohmypm\memory.md'
$sourceSystemTemplate = Join-Path $repoRoot '.ohmypm\system-memory\_template.md'

$targetRuntime = Join-Path $projectRoot $RuntimeDir
$targetSystemMemory = Join-Path $targetRuntime 'system-memory'
$targetCache = Join-Path $targetRuntime 'cache'
$targetAlignment = Join-Path $targetRuntime 'alignment'
$targetOutput = Join-Path $projectRoot $OutputDir
$targetPrd = Join-Path $targetOutput 'prd'
$targetPrototype = Join-Path $targetOutput 'prototype'
$targetReview = Join-Path $targetOutput 'review'

Ensure-Dir $targetRuntime
Ensure-Dir $targetSystemMemory
Ensure-Dir $targetCache
Ensure-Dir $targetAlignment
Ensure-Dir $targetOutput
Ensure-Dir $targetPrd
Ensure-Dir $targetPrototype
Ensure-Dir $targetReview

$statusTarget = Join-Path $targetRuntime 'status.json'
$memoryTarget = Join-Path $targetRuntime 'memory.md'
$systemTemplateTarget = Join-Path $targetSystemMemory '_template.md'

if (-not (Test-Path -LiteralPath $statusTarget)) {
    Copy-Item -LiteralPath $sourceStatus -Destination $statusTarget
}

if (-not (Test-Path -LiteralPath $memoryTarget)) {
    Copy-Item -LiteralPath $sourceMemory -Destination $memoryTarget
}

if (-not (Test-Path -LiteralPath $systemTemplateTarget)) {
    Copy-Item -LiteralPath $sourceSystemTemplate -Destination $systemTemplateTarget
}

Write-Host "[OhMyPm] project initialized at $targetRuntime and $targetOutput" -ForegroundColor Green
