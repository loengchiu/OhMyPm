param(
    [string]$Path = '.ohmypm/status.json'
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptRoot 'encoding.ps1')

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

function Get-BoolValue {
    param([object]$Value)

    if ($null -eq $Value) { return $false }
    if ($Value -is [bool]) { return $Value }

    $text = $Value.ToString().Trim().ToLowerInvariant()
    return $text -in @('true', '1', 'yes')
}

function New-Trigger {
    param(
        [string]$Code,
        [string]$Category,
        [string]$Source,
        [string[]]$Impacts,
        [string]$Question,
        [string]$Handling
    )

    return [pscustomobject]@{
        trigger_code = $Code
        question_category = $Category
        source = $Source
        impacts = $Impacts
        minimal_question = $Question
        handling = $Handling
    }
}

if (-not (Test-Path -LiteralPath $Path)) {
    Fail '状态文件不存在：.ohmypm/status.json'
}

$status = Read-Utf8Json -Path $Path
$triggers = New-Object System.Collections.Generic.List[object]

foreach ($fact in @($status.anchors_state.meta.confirmed_facts)) {
    if (-not (HasText "$fact")) { continue }
    if ("$fact" -match '未确认|待确认|待澄清|open question|pending confirmation') {
        $triggers.Add((New-Trigger -Code 'unconfirmed_leaked_into_confirmed' -Category 'boundary_guard' -Source 'anchors_state.meta.confirmed_facts' -Impacts @('scope_judgement', 'delivery_validity') -Question '当前已确认事实里混入了未确认内容，先做内部修正，把未确认项移回待确认区域后再继续。' -Handling 'internal_repair'))
        break
    }
}

if ($null -ne $status.anchors_state -and $null -ne $status.anchors_state.meta -and (HasItems $status.anchors_state.meta.open_questions) -and (Get-BoolValue $status.anchors_state.meta.can_progress)) {
    $triggers.Add((New-Trigger -Code 'open_question_progress_conflict' -Category 'boundary_guard' -Source 'anchors_state.meta.open_questions' -Impacts @('gate_validity', 'delivery_validity') -Question '当前未确认项仍会影响推进，但状态被写成可推进，先做内部修正，重新判定 can_progress 后再继续。' -Handling 'internal_repair'))
}

if ($null -ne $status.anchors_state -and $null -ne $status.anchors_state.anchors -and $null -ne $status.anchors_state.artifact_contract) {
    $expectedRefs = New-Object System.Collections.Generic.List[string]
    foreach ($module in @($status.anchors_state.anchors.modules)) {
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
    $shared = @($status.anchors_state.artifact_contract.shared_refs | ForEach-Object { "$_".Trim() } | Where-Object { $_ })
    if ($expected.Count -gt 0) {
        $mismatch = $shared.Count -eq 0
        if (-not $mismatch) {
            foreach ($item in $expected) {
                if ($shared -notcontains $item) {
                    $mismatch = $true
                    break
                }
            }
        }

        if ($mismatch) {
            $triggers.Add((New-Trigger -Code 'anchors_state_shared_ref_mismatch' -Category 'boundary_guard' -Source 'anchors_state.artifact_contract.shared_refs' -Impacts @('delivery_validity', 'review_validity') -Question '当前原型编号和 PRD 规则引用没有对齐，先做内部修正，补齐 shared_refs 后再继续。' -Handling 'internal_repair'))
        }
    }
}

if ($null -eq $status.context_package -or -not (HasText $status.context_package.request_summary)) {
    $triggers.Add((New-Trigger -Code 'missing_request_summary' -Category 'phase0_context' -Source 'context_package.request_summary' -Impacts @('reply_quality', 'scope_judgement') -Question '这次你想做的事情，能不能先用一句人话说清楚？' -Handling 'ask_pm'))
}
elseif (-not (HasText $status.context_package.business_stage)) {
    $triggers.Add((New-Trigger -Code 'missing_business_stage' -Category 'phase0_context' -Source 'context_package.business_stage' -Impacts @('reply_quality', 'module_judgement') -Question '这件事大概发生在哪个业务环节？' -Handling 'ask_pm'))
}
elseif ((-not (HasItems $status.context_package.system_or_page_clues)) -and (-not (HasItems $status.context_package.material_paths))) {
    $triggers.Add((New-Trigger -Code 'missing_system_clue_and_material' -Category 'phase0_context' -Source 'context_package.system_or_page_clues + material_paths' -Impacts @('reply_quality', 'alignment_efficiency') -Question '你现在能给到的最直接线索是什么：现有系统或页面，还是一份现成资料？' -Handling 'ask_pm'))
}

foreach ($item in @($status.pending_confirmations)) {
    $category = 'fact_gap'
    $impacts = @('current_understanding')
    $question = "请确认这个还没定下来的点：$item"

    if ($item -match 'scope boundary') {
        $category = 'scope_gap'
        $impacts = @('module_list', 'estimate', 'schedule')
        $question = '这次新增内容是否仍然属于当前版本范围内的补充，而不是需要拆成单独的新范围？'
    }

    $triggers.Add((New-Trigger -Code 'pending_confirmation' -Category $category -Source $item -Impacts $impacts -Question $question -Handling 'ask_pm'))
}

$changeConfirmedByPm = Get-BoolValue $status.change_state.change_category_confirmed_by_pm
if ((HasText $status.change_state.change_category) -and (-not $changeConfirmedByPm)) {
    $triggers.Add((New-Trigger -Code 'pm_change_confirmation' -Category 'change_classification' -Source $status.change_state.change_category -Impacts @('delivery_scope', 'change_path', 'baseline_decision') -Question "当前请求是否最终确认保持 '$($status.change_state.change_category)' 这个分类？" -Handling 'ask_pm'))
}

if ((HasText $status.fallback_state.fallback_type) -and ($status.fallback_state.fallback_type -notin @('internal_repair', 'need_materials'))) {
    $triggers.Add((New-Trigger -Code 'fallback_requires_pm_alignment' -Category 'alignment_decision' -Source $status.fallback_state.fallback_type -Impacts @('next_stage', 'round_progression') -Question '在继续更重动作之前，是否需要重新开一轮对齐？' -Handling 'ask_pm'))
}

$askPmTriggers = @($triggers | Where-Object { $_.handling -eq 'ask_pm' })
$internalOnlyTriggers = @($triggers | Where-Object { $_.handling -eq 'internal_repair' })
$nextRecommended = '当前没有需要抛给 PM 的追问'

if ($askPmTriggers.Count -gt 0) {
    $nextRecommended = '进入 ask-back，等待 PM 回答唯一问题'
}
elseif ($internalOnlyTriggers.Count -gt 0) {
    $nextRecommended = '当前存在内部矛盾或引用失配，先做内部修正，不要把这个问题抛给 PM。'
}

$triggerArray = @()
foreach ($trigger in $triggers) {
    $triggerArray += $trigger
}

$result = @{
    current_stage = $status.current_stage
    current_mode = $status.current_mode
    ask_back_required = ($askPmTriggers.Count -gt 0)
    internal_placeholder_required = ($internalOnlyTriggers.Count -gt 0)
    trigger_count = $triggers.Count
    triggers = $triggerArray
    next_recommended = $nextRecommended
}

$result | ConvertTo-Json -Depth 10
