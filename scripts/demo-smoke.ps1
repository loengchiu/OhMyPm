param(
    [string]$StatusPath = "docs/ohmypm/ohmypm-status.json",
    [string]$MemoryPath = "docs/ohmypm/ohmypm-memory.md"
)

function Fail {
    param([string]$Message)
    Write-Error "[OhMyPm] $Message"
    exit 1
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$cacheDir = Join-Path $repoRoot "docs\ohmypm\cache"

if (-not (Test-Path -LiteralPath $StatusPath)) {
    Fail "project status file not found: $StatusPath"
}

if (-not (Test-Path -LiteralPath $MemoryPath)) {
    Fail "project memory file not found: $MemoryPath"
}

$statusApply = Join-Path $scriptRoot "status-apply.ps1"
$memoryApply = Join-Path $scriptRoot "memory-apply.ps1"
$reviewApply = Join-Path $scriptRoot "review-apply.ps1"
$overwriteApply = Join-Path $scriptRoot "overwrite-apply.ps1"

$statusBackup = Join-Path $cacheDir "project-status.demo-smoke.backup.json"
$memoryBackup = Join-Path $cacheDir "project-memory.demo-smoke.backup.md"

$steps = @(
    @{ Type = "status"; Path = (Join-Path $repoRoot "docs\examples\respond-status.sample.json") },
    @{ Type = "memory"; Path = (Join-Path $repoRoot "docs\examples\respond-memory.sample.json") },
    @{ Type = "status"; Path = (Join-Path $repoRoot "docs\examples\align-status.sample.json") },
    @{ Type = "memory"; Path = (Join-Path $repoRoot "docs\examples\align-memory.sample.json") },
    @{ Type = "status"; Path = (Join-Path $repoRoot "docs\examples\preflight-status.sample.json") },
    @{ Type = "memory"; Path = (Join-Path $repoRoot "docs\examples\preflight-memory.sample.json") },
    @{ Type = "status"; Path = (Join-Path $repoRoot "docs\examples\prototype-status.sample.json") },
    @{ Type = "status"; Path = (Join-Path $repoRoot "docs\examples\prd-status.sample.json") },
    @{ Type = "review"; Path = (Join-Path $repoRoot "docs\examples\review-result.sample.json") },
    @{ Type = "memory"; Path = (Join-Path $repoRoot "docs\examples\review-memory.sample.json") },
    @{ Type = "overwrite"; Path = (Join-Path $repoRoot "docs\examples\overwrite-result.sample.json") },
    @{ Type = "memory"; Path = (Join-Path $repoRoot "docs\examples\fix-memory.sample.json") },
    @{ Type = "status"; Path = (Join-Path $repoRoot "docs\examples\reopen-alignment.sample.json") },
    @{ Type = "status"; Path = (Join-Path $repoRoot "docs\examples\change-status-confirmed.sample.json") }
)

try {
    Copy-Item -LiteralPath $StatusPath -Destination $statusBackup -Force
    Copy-Item -LiteralPath $MemoryPath -Destination $memoryBackup -Force

    foreach ($step in $steps) {
        if (-not (Test-Path -LiteralPath $step.Path)) {
            Fail "demo payload not found: $($step.Path)"
        }

        if ($step.Type -eq "status") {
            & $statusApply -PayloadPath $step.Path
        }
        elseif ($step.Type -eq "memory") {
            & $memoryApply -PayloadPath $step.Path
        }
        elseif ($step.Type -eq "review") {
            & $reviewApply -ReviewJsonPath $step.Path
        }
        elseif ($step.Type -eq "overwrite") {
            & $overwriteApply -JudgeJsonPath $step.Path
        }
        else {
            Fail "unsupported demo step type: $($step.Type)"
        }

        if (-not $?) {
            Fail "demo step failed: $($step.Path)"
        }
    }

    Write-Host "[OhMyPm] demo smoke passed." -ForegroundColor Green
}
finally {
    if (Test-Path -LiteralPath $statusBackup) {
        Copy-Item -LiteralPath $statusBackup -Destination $StatusPath -Force
        Remove-Item -LiteralPath $statusBackup -Force
    }

    if (Test-Path -LiteralPath $memoryBackup) {
        Copy-Item -LiteralPath $memoryBackup -Destination $MemoryPath -Force
        Remove-Item -LiteralPath $memoryBackup -Force
    }
}
