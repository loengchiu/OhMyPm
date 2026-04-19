param(
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

if (-not (Test-Path -LiteralPath $Path)) {
    Fail "project-status.json not found."
}

$status = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
$triggers = New-Object System.Collections.Generic.List[object]

foreach ($item in @($status.pending_confirmations)) {
    $category = "fact_gap"
    $impacts = @("current_understanding")
    $question = "Please confirm the unresolved item: $item"

    if ($item -match "scope boundary") {
        $category = "scope_gap"
        $impacts = @("module_list", "estimate", "schedule")
        $question = "Please confirm the scope boundary for the current version: is the approval-path expansion still inside the current version, or should it be treated as a separate scope/module?"
    }

    $triggers.Add((New-Object psobject -Property @{
        trigger_code = "pending_confirmation"
        question_category = $category
        source = $item
        impacts = $impacts
        minimal_question = $question
    }))
}

if (HasText $status.change_state.change_category -and (-not $status.change_state.change_category_confirmed_by_pm)) {
    $categoryQuestion = "Please confirm whether this newly added content is already large enough that it should be treated as a separate new module, rather than still being handled as an in-module supplement."
    $triggers.Add((New-Object psobject -Property @{
        trigger_code = "pm_change_confirmation"
        question_category = "change_classification"
        source = $status.change_state.change_category
        impacts = @("delivery_scope", "change_path", "baseline_decision")
        minimal_question = $categoryQuestion
    }))
}

if ((HasText $status.fallback_state.fallback_type) -and ($status.fallback_state.fallback_type -notin @("internal_repair", "need_materials"))) {
    $triggers.Add((New-Object psobject -Property @{
        trigger_code = "fallback_requires_pm_alignment"
        question_category = "alignment_decision"
        source = $status.fallback_state.fallback_type
        impacts = @("next_stage", "round_progression")
        minimal_question = "Please confirm whether the current state should reopen formal alignment before any heavier stage continues."
    }))
}

$nextRecommended = "No ask-back trigger found"
if ($triggers.Count -gt 0) {
    $nextRecommended = "Route to omp-ask-back and wait for PM confirmation"
}

$triggerArray = @()
foreach ($trigger in $triggers) {
    $triggerArray += $trigger
}

$result = @{
    current_stage = $status.current_stage
    current_mode = $status.current_mode
    ask_back_required = ($triggers.Count -gt 0)
    trigger_count = $triggers.Count
    triggers = $triggerArray
    next_recommended = $nextRecommended
}

$result | ConvertTo-Json -Depth 10
