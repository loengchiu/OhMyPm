param(
    [string]$Path = "docs/ohmypm/ohmypm-status.json"
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

function Get-ScenarioMode {
    param([object]$Status)

    if ($null -ne $Status.scenario_mode -and $Status.scenario_mode.ToString().Trim().Length -gt 0) {
        return $Status.scenario_mode.ToString().Trim().ToLowerInvariant()
    }

    if ($null -ne $Status.collaboration_context -and
        $null -ne $Status.collaboration_context.scenario_mode -and
        $Status.collaboration_context.scenario_mode.ToString().Trim().Length -gt 0) {
        return $Status.collaboration_context.scenario_mode.ToString().Trim().ToLowerInvariant()
    }

    return "real_project"
}

function IsSampleScenario {
    param([string]$ScenarioMode)

    return $ScenarioMode -in @("sample_validation", "demo_smoke", "demo", "sample")
}

function Get-BoolValue {
    param([object]$Value)

    if ($null -eq $Value) { return $false }
    if ($Value -is [bool]) { return $Value }

    $text = $Value.ToString().Trim().ToLowerInvariant()
    return $text -in @("true", "1", "yes")
}

if (-not (Test-Path -LiteralPath $Path)) {
    Fail "ohmypm-status.json not found."
}

$status = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
$triggers = New-Object System.Collections.Generic.List[object]
$scenarioMode = Get-ScenarioMode $status
$isSampleScenario = IsSampleScenario $scenarioMode

foreach ($item in @($status.pending_confirmations)) {
    $category = "fact_gap"
    $impacts = @("current_understanding")
    $question = "Please confirm the unresolved item: $item"
    $handling = "ask_pm"

    if ($isSampleScenario) {
        $question = "Sample/demo scenario detected. Do not ask PM to answer this business detail. Replace it with a placeholder or mark it as mechanism-validation-only."
        $handling = "internal_placeholder"
    }

    if ($item -match "scope boundary") {
        $category = "scope_gap"
        $impacts = @("module_list", "estimate", "schedule")
        $question = "Please confirm the scope boundary for the current version: is the approval-path expansion still inside the current version, or should it be treated as a separate scope/module?"
        if ($isSampleScenario) {
            $question = "Sample/demo scenario detected. Keep the scope note inside the sample itself, and do not turn this into a PM business confirmation."
            $handling = "internal_placeholder"
        }
    }

    $triggers.Add((New-Object psobject -Property @{
        trigger_code = "pending_confirmation"
        question_category = $category
        source = $item
        impacts = $impacts
        minimal_question = $question
        handling = $handling
    }))
}

$changeConfirmedByPm = Get-BoolValue $status.change_state.change_category_confirmed_by_pm
if ((HasText $status.change_state.change_category) -and (-not $changeConfirmedByPm)) {
    $categoryQuestion = "Please confirm whether this newly added content is already large enough that it should be treated as a separate new module, rather than still being handled as an in-module supplement."
    $handling = "ask_pm"
    if ($isSampleScenario) {
        $categoryQuestion = "Sample/demo scenario detected. Keep the change classification inside the demo narrative or mark it as a sample assumption instead of asking PM for a real-project decision."
        $handling = "internal_placeholder"
    }
    $triggers.Add((New-Object psobject -Property @{
        trigger_code = "pm_change_confirmation"
        question_category = "change_classification"
        source = $status.change_state.change_category
        impacts = @("delivery_scope", "change_path", "baseline_decision")
        minimal_question = $categoryQuestion
        handling = $handling
    }))
}

if ((HasText $status.fallback_state.fallback_type) -and ($status.fallback_state.fallback_type -notin @("internal_repair", "need_materials"))) {
    $fallbackQuestion = "Please confirm whether the current state should reopen formal alignment before any heavier stage continues."
    $handling = "ask_pm"
    if ($isSampleScenario) {
        $fallbackQuestion = "Sample/demo scenario detected. Reopen alignment only inside the sample flow if needed; do not turn this into a PM decision."
        $handling = "internal_placeholder"
    }
    $triggers.Add((New-Object psobject -Property @{
        trigger_code = "fallback_requires_pm_alignment"
        question_category = "alignment_decision"
        source = $status.fallback_state.fallback_type
        impacts = @("next_stage", "round_progression")
        minimal_question = $fallbackQuestion
        handling = $handling
    }))
}

$nextRecommended = "No ask-back trigger found"
if ($triggers.Count -gt 0) {
    if ($isSampleScenario) {
        $nextRecommended = "Sample/demo scenario detected: do not route virtual business gaps to PM; use placeholders or internal repair instead"
    }
    else {
        $nextRecommended = "Route to omp-ask-back and wait for PM confirmation"
    }
}

$triggerArray = @()
foreach ($trigger in $triggers) {
    $triggerArray += $trigger
}

$result = @{
    current_stage = $status.current_stage
    current_mode = $status.current_mode
    scenario_mode = $scenarioMode
    ask_back_required = (($triggers.Count -gt 0) -and (-not $isSampleScenario))
    internal_placeholder_required = (($triggers.Count -gt 0) -and $isSampleScenario)
    trigger_count = $triggers.Count
    triggers = $triggerArray
    next_recommended = $nextRecommended
}

$result | ConvertTo-Json -Depth 10
