param(
    [Parameter(Mandatory = $true)]
    [string]$ReviewJsonPath
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptRoot 'encoding.ps1')

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
        Fail "$FieldName 不能为空"
    }

    if ($Allowed -notcontains $Value) {
        $allowedText = ($Allowed -join ', ')
        Fail "$FieldName 可选值应为：$allowedText"
    }
}

if (-not (Test-Path -LiteralPath $ReviewJsonPath)) {
    Fail "评审结果文件不存在：$ReviewJsonPath"
}

$review = Read-Utf8Json -Path $ReviewJsonPath

if (-not $review.unified_conclusion) {
    Fail '缺少字段：unified_conclusion'
}

$result = $review.unified_conclusion.result
Ensure-OneOf -Value $result -Allowed @('pass', 'conditional_pass', 'rework_required', 'defer') -FieldName 'unified_conclusion.result'
$mustFix = @($review.unified_conclusion.must_fix_before_next_stage) | ConvertTo-Json -Compress
$nextAction = $review.unified_conclusion.next_action
$mustFixItems = @($review.unified_conclusion.must_fix_before_next_stage)
$canContinue = $review.unified_conclusion.can_continue

if ($null -eq $canContinue) {
    Fail '缺少字段：unified_conclusion.can_continue'
}

$artifactSync = Join-Path $scriptRoot 'artifact-sync.ps1'

$forward = @{
    LastAction = 'review_apply'
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
        $forward.FallbackReason = 'review_result=conditional_pass'
    }
    'rework_required' {
        $forward.Stage = 'omp-fix'
        $forward.FallbackType = 'internal_repair'
        $forward.FallbackReason = 'review_result=rework_required'
    }
    'defer' {
        $forward.Stage = 'omp-disc'
        $forward.FallbackType = 'need_materials'
        $forward.FallbackReason = 'review_result=defer'
    }
}

if (($result -eq 'pass') -and ($mustFixItems.Count -gt 0)) {
    Fail 'pass 结论下不得保留 must_fix_before_next_stage'
}

if (($result -in @('conditional_pass', 'rework_required')) -and ($mustFixItems.Count -eq 0)) {
    Fail "$result 结论下必须存在 must_fix_before_next_stage"
}

if (($result -eq 'pass') -and (-not [bool]$canContinue)) {
    Fail 'pass 结论不能设置 can_continue=false'
}

if (($result -eq 'rework_required' -or $result -eq 'defer') -and [bool]$canContinue) {
    Fail "$result 结论不能设置 can_continue=true"
}

& $artifactSync @forward
