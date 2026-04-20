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
    $question = "请确认这个还没定下来的点：$item"
    $handling = "ask_pm"

    if ($isSampleScenario) {
        $question = "当前是样例或演示场景。不要把这个业务细节抛给 PM，请改为占位值或明确标注为仅用于机制验证。"
        $handling = "internal_placeholder"
    }

    if ($item -match "scope boundary") {
        $category = "scope_gap"
        $impacts = @("module_list", "estimate", "schedule")
        $question = "这次新增内容是否仍然属于当前版本范围内的补充，而不是需要拆成单独的新范围？"
        if ($isSampleScenario) {
            $question = "当前是样例或演示场景。请把范围说明留在样例内部，不要转成向 PM 追问的真实业务问题。"
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
    $categoryQuestion = "这次新增内容是否已经大到需要按独立模块处理，而不是继续算作原模块内补充？"
    $handling = "ask_pm"
    if ($isSampleScenario) {
        $categoryQuestion = "当前是样例或演示场景。请把这个分类留在样例内部处理，或标成样例假设，不要向 PM 要真实项目判断。"
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
    $fallbackQuestion = "在继续更重动作之前，是否需要重新开一轮对齐？"
    $handling = "ask_pm"
    if ($isSampleScenario) {
        $fallbackQuestion = "当前是样例或演示场景。如果需要重开对齐，请只在样例内部处理，不要转成 PM 决策。"
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

$nextRecommended = "当前没有需要抛给 PM 的追问"
if ($triggers.Count -gt 0) {
    if ($isSampleScenario) {
        $nextRecommended = "当前是样例或演示场景：不要把虚拟业务缺口抛给 PM，请改为占位值或内部修正"
    }
    else {
        $nextRecommended = "进入 ask-back，等待 PM 回答唯一问题"
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
