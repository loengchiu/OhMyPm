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

$sourceStatus = Join-Path $repoRoot 'docs\templates\init-status.template.json'
$sourceMemory = Join-Path $repoRoot 'docs\templates\init-memory.template.md'
$targetRuntime = Join-Path $projectRoot $RuntimeDir
$targetCache = Join-Path $targetRuntime 'cache'
$targetAlignment = Join-Path $targetRuntime 'alignment'
$targetOutput = Join-Path $projectRoot $OutputDir
$targetDisc = Join-Path $targetOutput 'disc'
$targetSolution = Join-Path $targetOutput 'solution'
$targetPrd = Join-Path $targetOutput 'prd'
$targetPrototype = Join-Path $targetOutput 'prototype'
$targetReview = Join-Path $targetOutput 'review'

Ensure-Dir $targetRuntime
Ensure-Dir $targetCache
Ensure-Dir $targetAlignment
Ensure-Dir $targetOutput
Ensure-Dir $targetDisc
Ensure-Dir $targetSolution
Ensure-Dir $targetPrd
Ensure-Dir $targetPrototype
Ensure-Dir $targetReview

$statusTarget = Join-Path $targetRuntime 'status.json'
$memoryTarget = Join-Path $targetRuntime 'memory.md'

if (-not (Test-Path -LiteralPath $statusTarget)) {
    Copy-Item -LiteralPath $sourceStatus -Destination $statusTarget
}

if (-not (Test-Path -LiteralPath $memoryTarget)) {
    Copy-Item -LiteralPath $sourceMemory -Destination $memoryTarget
}

Write-Host "[OhMyPm] project initialized at $targetRuntime and $targetOutput" -ForegroundColor Green
