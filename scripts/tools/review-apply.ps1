param(
    [Parameter(Mandatory = $true)]
    [string]$ReviewJsonPath
)

function Fail {
    param([string]$Message)
    Write-Error "[OhMyPm] $Message"
    exit 1
}

if (-not (Test-Path -LiteralPath $ReviewJsonPath)) {
    Fail "review json not found: $ReviewJsonPath"
}

$review = Get-Content -Raw -LiteralPath $ReviewJsonPath | ConvertFrom-Json

if (-not $review.unified_conclusion) {
    Fail "review json missing unified_conclusion"
}

$result = $review.unified_conclusion.result
$mustFix = @($review.unified_conclusion.must_fix_before_next_stage) | ConvertTo-Json -Compress
$nextAction = $review.unified_conclusion.next_action
$mustFixItems = @($review.unified_conclusion.must_fix_before_next_stage)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$artifactSync = Join-Path $scriptRoot 'artifact-sync.ps1'

$forward = @{
    Stage = 'omp-review'
    LastAction = 'Applied review panel result'
    NextRecommended = $nextAction
    ReviewResult = $result
    ReviewMustFixJson = $mustFix
}

if ($result -eq 'pass' -and $mustFixItems.Count -eq 0) {
    $forward.FallbackType = ''
    $forward.FallbackReason = ''
}

& $artifactSync @forward
