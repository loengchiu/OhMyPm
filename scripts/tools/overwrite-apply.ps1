param(
    [Parameter(Mandatory = $true)]
    [string]$JudgeJsonPath
)

function Fail {
    param([string]$Message)
    Write-Error "[OhMyPm] $Message"
    exit 1
}

if (-not (Test-Path -LiteralPath $JudgeJsonPath)) {
    Fail "judge json not found: $JudgeJsonPath"
}

$judge = Get-Content -Raw -LiteralPath $JudgeJsonPath | ConvertFrom-Json

if (-not $judge.conflict_type) {
    Fail "judge json missing conflict_type"
}

$queueItem = @(
    [ordered]@{
        affected_upstream = $judge.affected_upstream
        conflict_type = $judge.conflict_type
        severity = $judge.severity
        action_level = $judge.action_level
        writeback_targets = $judge.writeback_targets
        reason = $judge.reason
    }
) | ConvertTo-Json -Depth 10 -Compress

$nextAction = if ($judge.can_continue) { 'Continue current stage after writeback' } else { 'Return to alignment and repair upstream artifacts' }

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$artifactSync = Join-Path $scriptRoot 'artifact-sync.ps1'

& $artifactSync `
    -Stage 'omp-fix' `
    -LastAction 'Applied overwrite judge result' `
    -NextRecommended $nextAction `
    -OverwriteQueueJson $queueItem
