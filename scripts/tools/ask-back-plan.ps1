param(
    [string]$Path = ".ohmypm/status.json"
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

function HasSamplePattern {
    param([string]$Text)

    if (-not (HasText $Text)) { return $false }
    return $Text -match "机制验证|仅用于机制验证|样例|demo|sample"
}

if (-not (Test-Path -LiteralPath $Path)) {
    Fail "ohmypm-status.json not found."
}

$status = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
$triggers = New-Object System.Collections.Generic.List[object]
$scenarioMode = Get-ScenarioMode $status
$isSampleScenario = IsSampleScenario $scenarioMode

if (-not $isSampleScenario) {
    foreach ($fact in @($status.traceability.meta.confirmed_facts)) {
        if (HasSamplePattern "$fact") {
            $triggers.Add((New-Object psobject -Property @{
                trigger_code = "sample_leak_into_real_project"
                question_category = "boundary_guard"
                source = "traceability.meta.confirmed_facts"
                impacts = @("scope_judgement", "delivery_validity")
                minimal_question = "当前真实项目状态里混入了样例结论，先做内部修正，清掉样例口径后再继续。"
                handling = "internal_placeholder"
            }))
            break
        }
    }

    if ($null -ne $status.collaboration_context -and (HasSamplePattern "$($status.collaboration_context.sample_notice)")) {
        $triggers.Add((New-Object psobject -Property @{
            trigger_code = "sample_notice_in_real_project"
            question_category = "boundary_guard"
            source = "collaboration_context.sample_notice"
            impacts = @("scope_judgement", "delivery_validity")
            minimal_question = "当前真实项目状态里仍保留样例说明，先做内部修正，清掉样例说明后再继续。"
            handling = "internal_placeholder"
        }))
    }
}

foreach ($fact in @($status.traceability.meta.confirmed_facts)) {
    if (-not (HasText "$fact")) { continue }
    if ("$fact" -match "未确认|待确认|待澄清|open question|pending confirmation") {
        $triggers.Add((New-Object psobject -Property @{
            trigger_code = "unconfirmed_leaked_into_confirmed"
            question_category = "boundary_guard"
            source = "traceability.meta.confirmed_facts"
            impacts = @("scope_judgement", "delivery_validity")
            minimal_question = "当前已确认事实里混入了未确认内容，先做内部修正，把未确认项移回待确认区域后再继续。"
            handling = "internal_placeholder"
        }))
        break
    }
}

if ($null -ne $status.traceability -and $null -ne $status.traceability.meta -and (HasItems $status.traceability.meta.open_questions) -and (Get-BoolValue $status.traceability.meta.can_progress)) {
    $triggers.Add((New-Object psobject -Property @{
        trigger_code = "open_question_progress_conflict"
        question_category = "boundary_guard"
        source = "traceability.meta.open_questions"
        impacts = @("gate_validity", "delivery_validity")
        minimal_question = "当前未确认项仍会影响推进，但状态被写成可推进，先做内部修正，重新判定 can_progress 后再继续。"
        handling = "internal_placeholder"
    }))
}

if ($null -ne $status.traceability -and $null -ne $status.traceability.anchors -and $null -ne $status.traceability.artifact_contract) {
    $expectedRefs = New-Object System.Collections.Generic.List[string]
    foreach ($module in @($status.traceability.anchors.modules)) {
        if ($null -eq $module -or $null -eq $module.pages) { continue }
        foreach ($page in @($module.pages)) {
            if ($null -eq $page -or $null -eq $page.flows) { continue }
            foreach ($flow in @($page.flows)) {
                if ($null -eq $flow -or $null -eq $flow.actions) { continue }
                foreach ($action in @($flow.actions)) {
                    if ($null -eq $action) { continue }
                    foreach ($ruleRef in @($action.rules_ref)) {
                        foreach ($protoRef in @($action.prototype_ref)) {
                            if (HasText "$ruleRef" -and HasText "$protoRef") {
                                $expectedRefs.Add(("{0} <-> {1}" -f "$protoRef".Trim(), "$ruleRef".Trim()))
                            }
                        }
                    }
                }
            }
        }
    }

    $expected = @($expectedRefs | Select-Object -Unique)
    $shared = @($status.traceability.artifact_contract.shared_refs | ForEach-Object { "$_".Trim() } | Where-Object { $_ })
    if ($expected.Count -gt 0) {
        $mismatch = $false
        if ($shared.Count -eq 0) {
            $mismatch = $true
        }
        else {
            foreach ($item in $expected) {
                if ($shared -notcontains $item) {
                    $mismatch = $true
                    break
                }
            }
        }

        if ($mismatch) {
            $triggers.Add((New-Object psobject -Property @{
                trigger_code = "traceability_shared_ref_mismatch"
                question_category = "boundary_guard"
                source = "traceability.artifact_contract.shared_refs"
                impacts = @("delivery_validity", "review_validity")
                minimal_question = "当前原型编号和 PRD 规则引用没有对齐，先做内部修正，补齐 shared_refs 后再继续。"
                handling = "internal_placeholder"
            }))
        }
    }
}

if ($null -eq $status.context_package -or -not (HasText $status.context_package.request_summary)) {
    $question = "这次你想做的事情，能不能先用一句人话说清楚？"
    $handling = "ask_pm"
    if ($isSampleScenario) {
        $question = "当前是样例或演示场景。请先在样例内部补一句清晰的需求摘要，不要把机制验证缺口抛给 PM。"
        $handling = "internal_placeholder"
    }

    $triggers.Add((New-Object psobject -Property @{
        trigger_code = "missing_request_summary"
        question_category = "phase0_context"
        source = "context_package.request_summary"
        impacts = @("reply_quality", "scope_judgement")
        minimal_question = $question
        handling = $handling
    }))
}
elseif (-not (HasText $status.context_package.business_stage)) {
    $question = "这件事大概发生在哪个业务环节？"
    $handling = "ask_pm"
    if ($isSampleScenario) {
        $question = "当前是样例或演示场景。请先在样例内部补业务环节，不要把机制验证缺口抛给 PM。"
        $handling = "internal_placeholder"
    }

    $triggers.Add((New-Object psobject -Property @{
        trigger_code = "missing_business_stage"
        question_category = "phase0_context"
        source = "context_package.business_stage"
        impacts = @("reply_quality", "module_judgement")
        minimal_question = $question
        handling = $handling
    }))
}
elseif ((-not (HasItems $status.context_package.system_or_page_clues)) -and (-not (HasItems $status.context_package.material_paths))) {
    $question = "你现在能给到的最直接线索是什么：现有系统或页面，还是一份现成资料？"
    $handling = "ask_pm"
    if ($isSampleScenario) {
        $question = "当前是样例或演示场景。请在样例内部补一个系统或页面线索，或补一份样例资料，不要转成 PM 追问。"
        $handling = "internal_placeholder"
    }

    $triggers.Add((New-Object psobject -Property @{
        trigger_code = "missing_system_clue_and_material"
        question_category = "phase0_context"
        source = "context_package.system_or_page_clues + material_paths"
        impacts = @("reply_quality", "alignment_efficiency")
        minimal_question = $question
        handling = $handling
    }))
}

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
$askPmTriggers = @($triggers | Where-Object { $_.handling -eq "ask_pm" })
$internalOnlyTriggers = @($triggers | Where-Object { $_.handling -eq "internal_placeholder" })

if ($askPmTriggers.Count -gt 0) {
    $nextRecommended = "进入 ask-back，等待 PM 回答唯一问题"
}
elseif ($internalOnlyTriggers.Count -gt 0) {
    if ($isSampleScenario) {
        $nextRecommended = "当前是样例或演示场景：不要把虚拟业务缺口抛给 PM，请改为占位值或内部修正"
    }
    else {
        $nextRecommended = "当前存在边界越界或内部矛盾，先做内部修正，不要把这个问题抛给 PM。"
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
    ask_back_required = ($askPmTriggers.Count -gt 0)
    internal_placeholder_required = ($internalOnlyTriggers.Count -gt 0)
    trigger_count = $triggers.Count
    triggers = $triggerArray
    next_recommended = $nextRecommended
}

$result | ConvertTo-Json -Depth 10

