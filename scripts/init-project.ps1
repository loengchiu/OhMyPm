param(
    [string]$DocsDir = "docs",
    [string]$OhMyPmDir = "ohmypm"
)

function Ensure-Dir {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptRoot '..')

$sourceStatus = Join-Path $repoRoot 'docs\ohmypm\ohmypm-status.json'
$sourceMemory = Join-Path $repoRoot 'docs\ohmypm\ohmypm-memory.md'
$sourceSystemTemplate = Join-Path $repoRoot 'docs\system-memory\_template.md'

$targetDocs = Resolve-Path -LiteralPath '.' | ForEach-Object { Join-Path $_ $DocsDir }
$targetOhMyPm = Join-Path $targetDocs $OhMyPmDir
$targetSystemMemory = Join-Path $targetOhMyPm 'system-memory'
$targetCache = Join-Path $targetOhMyPm 'cache'
$targetDeliverables = Join-Path $targetOhMyPm 'deliverables'
$targetAlignment = Join-Path $targetOhMyPm 'alignment'
$targetStatusDir = Join-Path $targetOhMyPm 'status'
$targetMemoryDir = Join-Path $targetOhMyPm 'memory'

Ensure-Dir $targetDocs
Ensure-Dir $targetOhMyPm
Ensure-Dir $targetSystemMemory
Ensure-Dir $targetCache
Ensure-Dir $targetDeliverables
Ensure-Dir $targetAlignment
Ensure-Dir $targetStatusDir
Ensure-Dir $targetMemoryDir

$statusTarget = Join-Path $targetOhMyPm 'ohmypm-status.json'
$memoryTarget = Join-Path $targetOhMyPm 'ohmypm-memory.md'
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

Write-Host "[OhMyPm] project initialized at $targetOhMyPm" -ForegroundColor Green
