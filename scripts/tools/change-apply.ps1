param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeJsonPath
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

if (-not (Test-Path -LiteralPath $ChangeJsonPath)) {
    Fail "change json not found: $ChangeJsonPath"
}

$change = Get-Content -Raw -LiteralPath $ChangeJsonPath | ConvertFrom-Json

Ensure-OneOf -Value $change.change_category -Allowed @('minor_patch', 'within_module', 'new_module', 'structural_change') -FieldName 'change_category'

if ($null -eq $change.change_category_confirmed_by_pm) {
    Fail "change json missing change_category_confirmed_by_pm"
}

if (($change.change_category -in @('new_module', 'structural_change')) -and (-not [bool]$change.change_category_confirmed_by_pm)) {
    Fail "$($change.change_category) requires change_category_confirmed_by_pm=true"
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
            $nextAction = 'Treat as minor patch and repair inside the current delivery scope'
        }
    }
    'within_module' {
        $stage = 'omp-fix'
        $mode = 'formal_delivery'
        if (-not $nextAction) {
            $nextAction = 'Treat as within-module change and repair inside the current delivery scope'
        }
    }
    'new_module' {
        $stage = 'omp-align'
        $mode = 'alignment_loop'
        $fallbackType = 'reopen_alignment'
        $fallbackReason = 'change classified as new_module'
        $roundResult = 'continue_alignment'
        if (-not $nextAction) {
            $nextAction = 'Reopen alignment and rebuild delivery scope around the new module'
        }
    }
    'structural_change' {
        $stage = 'omp-align'
        $mode = 'alignment_loop'
        $fallbackType = 'reopen_alignment'
        $fallbackReason = 'change classified as structural_change'
        $roundResult = 'continue_alignment'
        if (-not $nextAction) {
            $nextAction = 'Reopen alignment because the change affects the main structure'
        }
    }
}

$artifactSync = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'artifact-sync.ps1'
$forward = @{
    Stage = $stage
    Mode = $mode
    LastAction = 'Applied change classification result'
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
