param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('omp-reply', 'omp-align', 'omp-ready', 'omp-deliver', 'omp-change')]
    [string]$Gate,

    [string]$Path = '.ohmypm/status.json'
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

function HasMinimalContextPackage {
    param([object]$Status)

    if ($null -eq $Status.context_package) { return $false }

    $package = $Status.context_package
    return ((HasText $package.request_summary) -and
        (HasText $package.business_stage) -and
        $null -ne $package.PSObject.Properties['system_or_page_clues'] -and
        $null -ne $package.PSObject.Properties['material_paths'] -and
        $null -ne $package.PSObject.Properties['context_gaps'])
}

function HasAnchorsStateMeta {
    param([object]$Status)

    return ($null -ne $Status.anchors_state -and
        $null -ne $Status.anchors_state.meta -and
        (HasText $Status.anchors_state.meta.version) -and
        (HasText $Status.anchors_state.meta.scope_summary) -and
        (HasText $Status.anchors_state.meta.business_goal))
}

function HasModuleAnchors {
    param([object]$Status)

    if ($null -eq $Status.anchors_state -or $null -eq $Status.anchors_state.anchors) { return $false }
    return HasItems $Status.anchors_state.anchors.modules
}

function HasPageOrFlowAnchors {
    param([object]$Status)

    if (-not (HasModuleAnchors $Status)) { return $false }

    foreach ($module in @($Status.anchors_state.anchors.modules)) {
        if ($null -eq $module -or -not (HasItems $module.pages)) { continue }
        foreach ($page in @($module.pages)) {
            if ($null -eq $page) { continue }
            if ((HasText $page.page_name) -or (HasItems $page.flows)) {
                return $true
            }
        }
    }

    return $false
}

function Get-AnchorsStateActionRefs {
    param([object]$Status)

    $refs = New-Object System.Collections.Generic.List[string]
    if (-not (HasModuleAnchors $Status)) { return @() }

    foreach ($module in @($Status.anchors_state.anchors.modules)) {
        if ($null -eq $module -or -not (HasItems $module.pages)) { continue }
        foreach ($page in @($module.pages)) {
            if ($null -eq $page -or -not (HasItems $page.flows)) { continue }
            foreach ($flow in @($page.flows)) {
                if ($null -eq $flow -or -not (HasItems $flow.actions)) { continue }
                foreach ($action in @($flow.actions)) {
                    if ($null -eq $action) { continue }
                    foreach ($ruleRef in @($action.rules_ref)) {
                        foreach ($protoRef in @($action.prototype_ref)) {
                            if (HasText "$ruleRef" -and HasText "$protoRef") {
                                $refs.Add(("{0} <-> {1}" -f "$protoRef".Trim(), "$ruleRef".Trim()))
                            }
                        }
                    }
                }
            }
        }
    }

    return @($refs | Select-Object -Unique)
}

function HasAnchorsStateReferenceMismatch {
    param([object]$Status)

    if ($null -eq $Status.anchors_state -or $null -eq $Status.anchors_state.artifact_contract) { return $true }

    $expected = @(Get-AnchorsStateActionRefs -Status $Status)
    $shared = @($Status.anchors_state.artifact_contract.shared_refs | Where-Object { $null -ne $_ } | ForEach-Object { $_.ToString().Trim() } | Where-Object { $_ })

    if ($expected.Count -eq 0) { return $false }
    if ($shared.Count -eq 0) { return $true }

    foreach ($item in $expected) {
        if ($shared -notcontains $item) {
            return $true
        }
    }

    return $false
}

function HasConfirmedFactsBoundaryLeak {
    param([object]$Status)

    if ($null -eq $Status.anchors_state -or $null -eq $Status.anchors_state.meta) { return $false }

    foreach ($fact in @($Status.anchors_state.meta.confirmed_facts)) {
        if (-not (HasText $fact)) { continue }
        if ($fact.ToString().Trim() -match '未确认|待确认|待澄清|open question|open_questions|pending confirmation') {
            return $true
        }
    }

    return $false
}

function HasOpenQuestionProgressConflict {
    param([object]$Status)

    if ($null -eq $Status.anchors_state -or $null -eq $Status.anchors_state.meta) { return $false }
    if (-not (HasItems $Status.anchors_state.meta.open_questions)) { return $false }
    if ($null -eq $Status.anchors_state.meta.can_progress) { return $false }

    return [bool]$Status.anchors_state.meta.can_progress
}

function CanProgressByAnchorsState {
    param([object]$Status)

    if ($null -eq $Status.anchors_state -or $null -eq $Status.anchors_state.meta) { return $false }
    if ($null -eq $Status.anchors_state.meta.can_progress) { return $false }
    return [bool]$Status.anchors_state.meta.can_progress
}

function IsOneOf {
    param(
        [string]$Value,
        [string[]]$Allowed
    )

    if (-not (HasText $Value)) { return $false }
    return $Allowed -contains $Value
}

function AddEnumError {
    param(
        [System.Collections.Generic.List[string]]$List,
        [string]$FieldName,
        [string]$Value,
        [string[]]$Allowed
    )

    $allowedText = ($Allowed -join ', ')
    $List.Add("$FieldName 可选值应为：$allowedText；当前值：$Value")
}

function AddAskBackError {
    param(
        [System.Collections.Generic.List[string]]$List,
        [string]$Reason,
        [string]$Question
    )

    $List.Add("需要追问：$Reason | 最小问题：$Question")
}

if (-not (Test-Path -LiteralPath $Path)) {
    Fail '状态文件不存在：.ohmypm/status.json'
}

$status = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
$errors = New-Object System.Collections.Generic.List[string]
$roundResultEnums = @('continue_alignment', 'need_materials', 'need_internal_repair', 'ready_for_preflight')
$fallbackEnums = @('internal_repair', 'need_materials', 'reopen_alignment')
$changeEnums = @('minor_patch', 'within_module', 'new_module', 'structural_change')

if (HasItems $status.blockers) { $errors.Add('blockers 不为空') }
if (HasConfirmedFactsBoundaryLeak $status) { $errors.Add('confirmed_facts 混入了未确认内容') }
if (HasOpenQuestionProgressConflict $status) { $errors.Add('open_questions 未清空但 can_progress=true') }

switch ($Gate) {
    'omp-reply' {
        if (-not (HasMinimalContextPackage $status)) { $errors.Add('context_package 不完整') }
        if (-not (HasText $status.current_version)) { $errors.Add('current_version 为空') }
if (-not (HasAnchorsStateMeta $status)) { $errors.Add('anchors_state.meta 不完整') }
        if (-not ((HasText $status.baselines.response_plan) -or (HasItems $status.artifacts.response_notes))) { $errors.Add('缺少回应基线或回应记录') }
        if (-not (HasText $status.context_summary)) { $errors.Add('context_summary 为空') }
    }
    'omp-align' {
        if (-not (HasMinimalContextPackage $status)) { $errors.Add('context_package 不完整') }
if (-not (HasAnchorsStateMeta $status)) { $errors.Add('anchors_state.meta 不完整') }
        if (-not (HasModuleAnchors $status)) { $errors.Add('anchors_state.anchors.modules 为空') }
        if (-not ($status.alignment_state.round_number -ge 1)) { $errors.Add('alignment_state.round_number 必须 >= 1') }
        if (-not (HasText $status.alignment_state.round_goal)) { $errors.Add('alignment_state.round_goal 为空') }
        if (-not (HasItems $status.alignment_state.round_inputs)) { $errors.Add('alignment_state.round_inputs 为空') }
        if (-not (HasText $status.alignment_state.current_output)) { $errors.Add('alignment_state.current_output 为空') }
        if (-not (HasText $status.alignment_state.history_summary)) { $errors.Add('alignment_state.history_summary 为空') }
        if (-not (IsOneOf $status.alignment_state.round_result $roundResultEnums)) { AddEnumError -List $errors -FieldName 'alignment_state.round_result' -Value $status.alignment_state.round_result -Allowed $roundResultEnums }
        if (HasText $status.fallback_state.fallback_type) {
            if (-not (IsOneOf $status.fallback_state.fallback_type $fallbackEnums)) { AddEnumError -List $errors -FieldName 'fallback_state.fallback_type' -Value $status.fallback_state.fallback_type -Allowed $fallbackEnums }
            if (-not (HasText $status.fallback_state.fallback_reason)) { $errors.Add('fallback_state.fallback_reason 为空') }
        }
        if ($status.fallback_state.fallback_type -eq 'reopen_alignment' -and $status.alignment_state.round_result -eq 'ready_for_preflight') { $errors.Add('reopen_alignment 不能与 ready_for_preflight 同时存在') }
        if (HasItems $status.pending_confirmations -and $status.fallback_state.fallback_type -notin @('internal_repair', 'need_materials')) {
            AddAskBackError -List $errors -Reason 'pending_confirmations 未清空，且未标为 internal_repair / need_materials' -Question '请先确认当前最阻塞的待确认项，再继续下一轮对齐。'
        }
        if (-not ((HasText $status.baselines.response_plan) -or (HasItems $status.artifacts.response_notes))) { $errors.Add('缺少回应产物，无法继续对齐') }
        if (-not (HasText $status.next_recommended)) { $errors.Add('next_recommended 为空') }
    }
    'omp-ready' {
if (-not (HasAnchorsStateMeta $status)) { $errors.Add('anchors_state.meta 不完整') }
        if (-not (HasModuleAnchors $status)) { $errors.Add('anchors_state.anchors.modules 为空') }
        if (-not (HasPageOrFlowAnchors $status)) { $errors.Add('缺少页面或流程锚点') }
if (HasAnchorsStateReferenceMismatch $status) { $errors.Add('shared_refs 与动作引用未对齐') }
if (-not (CanProgressByAnchorsState $status)) { $errors.Add('进入 omp-ready 前 anchors_state.meta.can_progress 必须为 true') }
        if (-not (IsOneOf $status.alignment_state.round_result $roundResultEnums)) { AddEnumError -List $errors -FieldName 'alignment_state.round_result' -Value $status.alignment_state.round_result -Allowed $roundResultEnums }
        if ($status.alignment_state.round_result -ne 'ready_for_preflight') { $errors.Add('进入 omp-ready 前 alignment_state.round_result 必须为 ready_for_preflight') }
        if (HasText $status.fallback_state.fallback_type) {
            if (-not (IsOneOf $status.fallback_state.fallback_type $fallbackEnums)) { AddEnumError -List $errors -FieldName 'fallback_state.fallback_type' -Value $status.fallback_state.fallback_type -Allowed $fallbackEnums }
            if ($status.fallback_state.fallback_type -eq 'reopen_alignment') { $errors.Add('reopen_alignment 状态下不能直接进入 omp-ready') }
        }
        if (HasItems $status.pending_confirmations) { AddAskBackError -List $errors -Reason '开工检查前 pending_confirmations 未清空' -Question '请先确认当前仍未闭合的范围或事实边界，再继续开工检查。' }
        if (-not ((HasText $status.baselines.response_plan) -or (HasItems $status.artifacts.response_notes))) { $errors.Add('缺少稳定回应产物') }
        if (-not (HasText $status.context_summary)) { $errors.Add('context_summary 为空') }
    }
    'omp-deliver' {
if (-not (HasAnchorsStateMeta $status)) { $errors.Add('anchors_state.meta 不完整') }
        if (-not (HasModuleAnchors $status)) { $errors.Add('anchors_state.anchors.modules 为空') }
        if (-not (HasPageOrFlowAnchors $status)) { $errors.Add('缺少页面或流程锚点') }
if (HasAnchorsStateReferenceMismatch $status) { $errors.Add('shared_refs 与动作引用未对齐') }
if (-not (CanProgressByAnchorsState $status)) { $errors.Add('正式交付前 anchors_state.meta.can_progress 必须为 true') }
        if (-not (IsOneOf $status.alignment_state.round_result $roundResultEnums)) { AddEnumError -List $errors -FieldName 'alignment_state.round_result' -Value $status.alignment_state.round_result -Allowed $roundResultEnums }
        if ($status.alignment_state.round_result -ne 'ready_for_preflight') { $errors.Add('正式交付前 alignment_state.round_result 必须为 ready_for_preflight') }
        if (HasText $status.fallback_state.fallback_type) {
            if (-not (IsOneOf $status.fallback_state.fallback_type $fallbackEnums)) { AddEnumError -List $errors -FieldName 'fallback_state.fallback_type' -Value $status.fallback_state.fallback_type -Allowed $fallbackEnums }
            $errors.Add('正式交付前 fallback_state.fallback_type 必须为空')
        }
        if (HasItems $status.pending_confirmations) { AddAskBackError -List $errors -Reason '正式交付前 pending_confirmations 未清空' -Question '请先确认当前仍未闭合的范围或事实边界，再继续原型或 PRD 交付。' }
        if (-not (HasText $status.baselines.response_plan)) { $errors.Add('baselines.response_plan 缺失') }
        if (HasItems $status.review_state.must_fix_before_next_stage) { $errors.Add('review_state.must_fix_before_next_stage 未清空') }
    }
    'omp-change' {
        if (-not (IsOneOf $status.change_state.change_category $changeEnums)) { AddEnumError -List $errors -FieldName 'change_state.change_category' -Value $status.change_state.change_category -Allowed $changeEnums }
        if (HasItems $status.pending_confirmations) { AddAskBackError -List $errors -Reason '变更处理前 pending_confirmations 未清空' -Question '请先确认当前变更涉及的关键事实或范围边界。' }
        if (-not $status.change_state.change_category_confirmed_by_pm) { AddAskBackError -List $errors -Reason 'change_category_confirmed_by_pm 仍未确认' -Question "当前请求是否最终确认保持 '$($status.change_state.change_category)' 这个分类？" }
        if ((-not (HasText $status.baselines.prototype)) -and (-not (HasText $status.baselines.prd))) { $errors.Add('缺少正式交付基线') }
    }
}

if ($errors.Count -gt 0) {
    foreach ($item in $errors) {
        Write-Host "[OhMyPm] 门禁问题：$item" -ForegroundColor Yellow
    }
    Fail "门禁未通过：$Gate"
}

Write-Host "[OhMyPm] 门禁通过：$Gate" -ForegroundColor Green


