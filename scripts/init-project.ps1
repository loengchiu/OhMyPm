param(
    [string]$DocsDir = "docs"
)

function Ensure-Dir {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptRoot '..')

$sourceStatus = Join-Path $repoRoot 'docs\project-status.json'
$sourceMemory = Join-Path $repoRoot 'docs\project-memory.md'
$sourceSystemTemplate = Join-Path $repoRoot 'docs\system-memory\_template.md'

$targetDocs = Resolve-Path -LiteralPath '.' | ForEach-Object { Join-Path $_ $DocsDir }
$targetSystemMemory = Join-Path $targetDocs 'system-memory'
$targetCache = Join-Path $targetDocs 'cache'

Ensure-Dir $targetDocs
Ensure-Dir $targetSystemMemory
Ensure-Dir $targetCache

$statusTarget = Join-Path $targetDocs 'project-status.json'
$memoryTarget = Join-Path $targetDocs 'project-memory.md'
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

Write-Host "[OhMyPm] project initialized at $targetDocs" -ForegroundColor Green
