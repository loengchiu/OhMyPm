param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeJsonPath
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

if (-not (Test-Path -LiteralPath $ChangeJsonPath)) {
    Fail "变更结果文件不存在：$ChangeJsonPath"
}

$change = Read-Utf8Json -Path $ChangeJsonPath

Ensure-OneOf -Value $change.change_category -Allowed @('minor_patch', 'within_module', 'new_module', 'structural_change') -FieldName 'change_category'

if ($null -eq $change.change_category_confirmed_by_pm) {
    Fail '缺少字段：change_category_confirmed_by_pm'
}

if (($change.change_category -in @('new_module', 'structural_change')) -and (-not [bool]$change.change_category_confirmed_by_pm)) {
    Fail "重变更分类未确认：$($change.change_category)"
}

$stage = 'omp-change'
$mode = 'change_control'
$fallbackType = ''
$fallbackReason = ''
$roundResult = $null
$nextAction = $change.next_action

switch ($change.change_category) {
    'minor_patch' {
        $stage = 'omp-fix'
        $mode = 'formal_delivery'
        if (-not $nextAction) {
            $nextAction = '下一步：按小修补处理，留在当前交付范围内修正。'
        }
    }
    'within_module' {
        $stage = 'omp-fix'
        $mode = 'formal_delivery'
        if (-not $nextAction) {
            $nextAction = '下一步：按模块内补充处理，留在当前交付范围内修正。'
        }
    }
    'new_module' {
        $stage = 'omp-disc'
        $mode = 'alignment_loop'
        $fallbackType = 'reopen_alignment'
        $fallbackReason = 'change_category=new_module'
        $roundResult = 'continue_alignment'
        if (-not $nextAction) {
        $nextAction = '下一步：回到调研，按新模块重建范围和交付边界。'
        }
    }
    'structural_change' {
        $stage = 'omp-disc'
        $mode = 'alignment_loop'
        $fallbackType = 'reopen_alignment'
        $fallbackReason = 'change_category=structural_change'
        $roundResult = 'continue_alignment'
        if (-not $nextAction) {
        $nextAction = '下一步：回到调研，按结构性变化重建范围和交付边界。'
        }
    }
}

$artifactSync = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'artifact-sync.ps1'
$forward = @{
    Stage = $stage
    Mode = $mode
    LastAction = 'change_apply'
    NextRecommended = $nextAction
    ChangeCategory = $change.change_category
    ChangeCategoryConfirmedByPm = [bool]$change.change_category_confirmed_by_pm
}

if ($fallbackType) {
    $forward.FallbackType = $fallbackType
    $forward.FallbackReason = $fallbackReason
}

if ($null -ne $roundResult) {
    $forward.RoundResult = $roundResult
}

if ($null -ne $change.change_record_path -and "$($change.change_record_path)".Trim().Length -gt 0) {
    $forward.ArtifactField = 'change_records'
    $forward.ArtifactPath = $change.change_record_path
}

& $artifactSync @forward
