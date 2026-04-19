param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("omp-respond", "omp-align", "omp-preflight", "omp-deliver", "omp-change")]
    [string]$Gate,

    [string]$Path = "docs/project-status.json"
)

function Fail {
    param([string]$Message)
    Write-Error "[OhMyPm] $Message"
    exit 1
}

function HasText {
    param([object]$Value)
    return ($null -ne $Value -and $Value.ToString().Trim().Length -gt 0)
}

function HasItems {
    param([object]$Value)
    if ($null -eq $Value) { return $false }
    return @($Value).Count -gt 0
}

function IsOneOf {
    param(
        [string]$Value,
        [string[]]$Allowed
    )

    if (-not (HasText $Value)) {
        return $false
    }

    return $Allowed -contains $Value
}

function AddEnumError {
    param(
        [System.Collections.Generic.List[string]]$List,
        [string]$FieldName,
        [string]$Value,
        [string[]]$Allowed
    )

    $allowedText = ($Allowed -join ", ")
    $List.Add("$FieldName must be one of: $allowedText; actual: $Value")
}

if (-not (Test-Path -LiteralPath $Path)) {
    Fail "docs/project-status.json not found."
}

$status = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
$errors = New-Object System.Collections.Generic.List[string]
$roundResultEnums = @("continue_alignment", "need_materials", "need_internal_repair", "ready_for_preflight")
$fallbackEnums = @("internal_repair", "need_materials", "reopen_alignment")
$changeEnums = @("minor_patch", "within_module", "new_module", "structural_change")

if (HasItems $status.blockers) {
    $errors.Add("blockers are not empty")
}

switch ($Gate) {
    "omp-respond" {
        if (-not (HasText $status.current_version)) {
            $errors.Add("current_version is missing")
        }

        $hasPlan = HasText $status.stable_baselines.response_plan
        $hasNote = HasItems $status.latest_artifacts.response_notes
        if (-not ($hasPlan -or $hasNote)) {
            $errors.Add("no response plan or response note is recorded")
        }

        if (-not (HasText $status.context_summary)) {
            $errors.Add("context_summary is empty")
        }
    }
    "omp-align" {
        if (-not ($status.loop_state.round_number -ge 1)) {
            $errors.Add("loop_state.round_number must be >= 1")
        }

        if (-not (HasText $status.loop_state.round_goal)) {
            $errors.Add("loop_state.round_goal is empty")
        }

        if (-not (HasItems $status.loop_state.round_inputs)) {
            $errors.Add("loop_state.round_inputs is empty")
        }

        if (-not (HasText $status.loop_state.current_output)) {
            $errors.Add("loop_state.current_output is empty")
        }

        if (-not (HasText $status.loop_state.history_summary)) {
            $errors.Add("loop_state.history_summary is empty")
        }

        if (-not (IsOneOf $status.loop_state.round_result $roundResultEnums)) {
            AddEnumError -List $errors -FieldName "loop_state.round_result" -Value $status.loop_state.round_result -Allowed $roundResultEnums
        }

        if (HasText $status.fallback_state.fallback_type) {
            if (-not (IsOneOf $status.fallback_state.fallback_type $fallbackEnums)) {
                AddEnumError -List $errors -FieldName "fallback_state.fallback_type" -Value $status.fallback_state.fallback_type -Allowed $fallbackEnums
            }

            if (-not (HasText $status.fallback_state.fallback_reason)) {
                $errors.Add("fallback_state.fallback_reason is empty")
            }
        }

        if ($status.fallback_state.fallback_type -eq "reopen_alignment" -and $status.loop_state.round_result -eq "ready_for_preflight") {
            $errors.Add("fallback_state.fallback_type=reopen_alignment cannot coexist with loop_state.round_result=ready_for_preflight")
        }

        if (HasItems $status.pending_confirmations) {
            $errors.Add("pending_confirmations are not empty")
        }

        $hasPlan = HasText $status.stable_baselines.response_plan
        $hasNote = HasItems $status.latest_artifacts.response_notes
        if (-not ($hasPlan -or $hasNote)) {
            $errors.Add("no response artifact is available for alignment")
        }

        if (-not (HasText $status.next_recommended)) {
            $errors.Add("next_recommended is empty")
        }
    }
    "omp-preflight" {
        if (-not (IsOneOf $status.loop_state.round_result $roundResultEnums)) {
            AddEnumError -List $errors -FieldName "loop_state.round_result" -Value $status.loop_state.round_result -Allowed $roundResultEnums
        }

        if ($status.loop_state.round_result -ne "ready_for_preflight") {
            $errors.Add("loop_state.round_result must be ready_for_preflight before omp-preflight")
        }

        if (HasText $status.fallback_state.fallback_type) {
            if (-not (IsOneOf $status.fallback_state.fallback_type $fallbackEnums)) {
                AddEnumError -List $errors -FieldName "fallback_state.fallback_type" -Value $status.fallback_state.fallback_type -Allowed $fallbackEnums
            }

            if ($status.fallback_state.fallback_type -eq "reopen_alignment") {
                $errors.Add("fallback_state.fallback_type=reopen_alignment must return to alignment instead of entering omp-preflight")
            }
        }

        if (HasItems $status.pending_confirmations) {
            $errors.Add("pending_confirmations are not empty")
        }

        $hasPlan = HasText $status.stable_baselines.response_plan
        $hasNote = HasItems $status.latest_artifacts.response_notes
        if (-not ($hasPlan -or $hasNote)) {
            $errors.Add("no stabilized response artifact is available")
        }

        if (-not (HasText $status.context_summary)) {
            $errors.Add("context_summary is empty")
        }
    }
    "omp-deliver" {
        if (-not (IsOneOf $status.loop_state.round_result $roundResultEnums)) {
            AddEnumError -List $errors -FieldName "loop_state.round_result" -Value $status.loop_state.round_result -Allowed $roundResultEnums
        }

        if ($status.loop_state.round_result -ne "ready_for_preflight") {
            $errors.Add("formal delivery requires loop_state.round_result=ready_for_preflight")
        }

        if (HasText $status.fallback_state.fallback_type) {
            if (-not (IsOneOf $status.fallback_state.fallback_type $fallbackEnums)) {
                AddEnumError -List $errors -FieldName "fallback_state.fallback_type" -Value $status.fallback_state.fallback_type -Allowed $fallbackEnums
            }

            $errors.Add("fallback_state.fallback_type must be empty before formal delivery")
        }

        if (HasItems $status.pending_confirmations) {
            $errors.Add("pending_confirmations are not empty")
        }

        $hasPlan = HasText $status.stable_baselines.response_plan
        if (-not $hasPlan) {
            $errors.Add("stable_baselines.response_plan is missing")
        }

        $reviewBlockers = HasItems $status.review_state.must_fix_before_next_stage
        if ($reviewBlockers) {
            $errors.Add("review_state.must_fix_before_next_stage is not empty")
        }
    }
    "omp-change" {
        if (-not (IsOneOf $status.change_state.change_category $changeEnums)) {
            AddEnumError -List $errors -FieldName "change_state.change_category" -Value $status.change_state.change_category -Allowed $changeEnums
        }

        if (($status.change_state.change_category -eq "new_module") -or ($status.change_state.change_category -eq "structural_change")) {
            if (-not $status.change_state.change_category_confirmed_by_pm) {
                $errors.Add("PM confirmation is required for new_module or structural_change")
            }
        }

        if ((-not (HasText $status.stable_baselines.prototype)) -and (-not (HasText $status.stable_baselines.prd))) {
            $errors.Add("no formal delivery baseline exists")
        }
    }
}

if ($errors.Count -gt 0) {
    foreach ($item in $errors) {
        Write-Host "[OhMyPm] gate issue: $item" -ForegroundColor Yellow
    }
    Fail "gate blocked: $Gate"
}

Write-Host "[OhMyPm] gate passed: $Gate" -ForegroundColor Green
