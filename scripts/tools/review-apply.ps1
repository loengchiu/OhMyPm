param(
    [Parameter(Mandatory = $true)]
    [string]$ReviewJsonPath
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

if (-not (Test-Path -LiteralPath $ReviewJsonPath)) {
    Fail "review json not found: $ReviewJsonPath"
}

$review = Get-Content -Raw -LiteralPath $ReviewJsonPath | ConvertFrom-Json

if (-not $review.unified_conclusion) {
    Fail "review json missing unified_conclusion"
}

$result = $review.unified_conclusion.result
Ensure-OneOf -Value $result -Allowed @('pass', 'conditional_pass', 'rework_required', 'defer') -FieldName 'unified_conclusion.result'
$mustFix = @($review.unified_conclusion.must_fix_before_next_stage) | ConvertTo-Json -Compress
$nextAction = $review.unified_conclusion.next_action
$mustFixItems = @($review.unified_conclusion.must_fix_before_next_stage)
$canContinue = $review.unified_conclusion.can_continue

if ($null -eq $canContinue) {
    Fail "review json missing unified_conclusion.can_continue"
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$artifactSync = Join-Path $scriptRoot 'artifact-sync.ps1'

$forward = @{
    LastAction = 'Applied review panel result'
    NextRecommended = $nextAction
    ReviewResult = $result
    ReviewMustFixJson = $mustFix
}

switch ($result) {
    'pass' {
        $forward.Stage = 'omp-review'
        $forward.FallbackType = ''
        $forward.FallbackReason = ''
        $forward.OverwriteQueueJson = '[]'
    }
    'conditional_pass' {
        $forward.Stage = 'omp-fix'
        $forward.FallbackType = 'internal_repair'
        $forward.FallbackReason = 'review returned conditional_pass and requires fixes before next stage'
    }
    'rework_required' {
        $forward.Stage = 'omp-fix'
        $forward.FallbackType = 'internal_repair'
        $forward.FallbackReason = 'review returned rework_required'
    }
    'defer' {
        $forward.Stage = 'omp-check'
        $forward.FallbackType = 'need_materials'
        $forward.FallbackReason = 'review returned defer'
    }
}

if (($result -eq 'pass') -and ($mustFixItems.Count -gt 0)) {
    Fail "pass result cannot keep must_fix_before_next_stage items"
}

if (($result -in @('conditional_pass', 'rework_required')) -and ($mustFixItems.Count -eq 0)) {
    Fail "$result requires must_fix_before_next_stage items"
}

if (($result -eq 'pass') -and (-not [bool]$canContinue)) {
    Fail "pass result cannot set can_continue=false"
}

if (($result -eq 'rework_required' -or $result -eq 'defer') -and [bool]$canContinue) {
    Fail "$result cannot set can_continue=true"
}

& $artifactSync @forward
