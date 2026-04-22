param(
    [Parameter(Mandatory = $true)]
    [string]$JudgeJsonPath
)

function Fail {
    param([string]$Message)
    Write-Error "[OhMyPm] $Message"
    exit 1
}

function Ensure-OneOf {
    param(
        [string]$Value,
        [string[]]$Allowed,
        [string]$FieldName
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        Fail "$FieldName cannot be empty"
    }

    if ($Allowed -notcontains $Value) {
        $allowedText = ($Allowed -join ", ")
        Fail "$FieldName must be one of: $allowedText"
    }
}

if (-not (Test-Path -LiteralPath $JudgeJsonPath)) {
    Fail "judge json not found: $JudgeJsonPath"
}

$judge = Get-Content -Raw -LiteralPath $JudgeJsonPath | ConvertFrom-Json

if (-not $judge.conflict_type) {
    Fail "judge json missing conflict_type"
}

Ensure-OneOf -Value $judge.conflict_type -Allowed @('missing_scope', 'missing_rule', 'structure_conflict', 'baseline_stale', 'review_reversal') -FieldName 'conflict_type'
Ensure-OneOf -Value $judge.action_level -Allowed @('patch', 'rollback_upstream', 'restart_alignment') -FieldName 'action_level'

if ($null -eq $judge.can_continue) {
    Fail "judge json missing can_continue"
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
$stage = 'omp-fix'
$mode = 'formal_delivery'
$fallbackType = 'internal_repair'
$fallbackReason = "overwrite judge applied: $($judge.conflict_type)"
$roundResult = $null

switch ($judge.action_level) {
    'patch' {
        $stage = 'omp-fix'
        $mode = 'formal_delivery'
        $fallbackType = 'internal_repair'
    }
    'rollback_upstream' {
        $stage = 'omp-fix'
        $mode = 'formal_delivery'
        $fallbackType = 'internal_repair'
    }
    'restart_alignment' {
        $stage = 'omp-align'
        $mode = 'alignment_loop'
        $fallbackType = 'reopen_alignment'
        $nextAction = 'Return to alignment and repair upstream artifacts'
        $roundResult = 'continue_alignment'
    }
}

if (($judge.action_level -eq 'restart_alignment') -and [bool]$judge.can_continue) {
    Fail "restart_alignment cannot set can_continue=true"
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$artifactSync = Join-Path $scriptRoot 'artifact-sync.ps1'

$forward = @{
    Stage = $stage
    Mode = $mode
    LastAction = 'Applied overwrite judge result'
    NextRecommended = $nextAction
    FallbackType = $fallbackType
    FallbackReason = $fallbackReason
    OverwriteQueueJson = $queueItem
}

if ($null -ne $roundResult) {
    $forward.RoundResult = $roundResult
}

& $artifactSync @forward
