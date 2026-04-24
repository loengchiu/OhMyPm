param(
    [string]$Path = '.ohmypm/status.json',
    [string]$Stage,
    [string]$Mode,
    [string]$Version,
    [string]$LastAction,
    [string]$NextRecommended,
    [string]$ContextSummary,
    [string]$ContextPackageJson,
    [string]$AnchorsStateJson,
    [string]$BaselineField,
    [string]$BaselinePath,
    [string]$ArtifactField,
    [string]$ArtifactPath,
    [string]$BlockersJson,
    [string]$PendingConfirmationsJson,
    [string]$ReviewResult,
    [string]$ReviewMustFixJson,
    [string]$OverwriteQueueJson,
    [string]$SystemMemoryCardsJson,
    [int]$RoundNumber,
    [string]$RoundGoal,
    [string]$RoundInputsJson,
    [string]$CurrentOutput,
    [string]$RoundResult,
    [string]$LoopHistorySummary,
    [string]$FallbackType,
    [string]$FallbackReason,
    [string]$ChangeCategory,
    $ChangeCategoryConfirmedByPm
)

function Fail {
    param([string]$Message)
    Write-Error "[OhMyPm] $Message"
    exit 1
}

function Parse-JsonArray {
    param(
        [string]$Raw,
        [string]$FieldName
    )

    if ([string]::IsNullOrWhiteSpace($Raw)) {
        return @()
    }

    try {
        $parsed = $Raw | ConvertFrom-Json
    }
    catch {
        Fail "$FieldName 不是合法 JSON"
    }

    if ($parsed -is [System.Array]) {
        return @($parsed)
    }

    return @($parsed)
}

function Ensure-OneOf {
    param(
        [string]$Value,
        [string[]]$Allowed,
        [string]$FieldName
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return
    }

    if ($Allowed -notcontains $Value) {
        $allowedText = ($Allowed -join ', ')
        Fail "$FieldName 可选值应为：$allowedText"
    }
}

function Parse-BoolValue {
    param(
        $Raw,
        [string]$FieldName
    )

    if ($null -eq $Raw) {
        Fail "$FieldName 不能为空"
    }

    if ($Raw -is [bool]) {
        return $Raw
    }

    $text = "$Raw".Trim().ToLowerInvariant()

    switch ($text) {
        'true' { return $true }
        'false' { return $false }
        '1' { return $true }
        '0' { return $false }
        'yes' { return $true }
        'no' { return $false }
        default { Fail "$FieldName 不是合法布尔值" }
    }
}

if (-not (Test-Path -LiteralPath $Path)) {
    Fail '状态文件不存在：.ohmypm/status.json'
}

$status = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
$roundResultEnums = @('continue_alignment', 'need_materials', 'need_internal_repair', 'ready_for_preflight')
$fallbackEnums = @('internal_repair', 'need_materials', 'reopen_alignment')
$changeEnums = @('minor_patch', 'within_module', 'new_module', 'structural_change')

if ($PSBoundParameters.ContainsKey('Stage')) { $status.current_stage = $Stage }
if ($PSBoundParameters.ContainsKey('Mode')) { $status.current_mode = $Mode }
if ($PSBoundParameters.ContainsKey('Version')) { $status.current_version = $Version }
if ($PSBoundParameters.ContainsKey('LastAction')) { $status.last_action = $LastAction }
if ($PSBoundParameters.ContainsKey('NextRecommended')) { $status.next_recommended = $NextRecommended }
if ($PSBoundParameters.ContainsKey('ContextSummary')) { $status.context_summary = $ContextSummary }

if ($PSBoundParameters.ContainsKey('ContextPackageJson')) {
    if ([string]::IsNullOrWhiteSpace($ContextPackageJson)) {
        Fail 'ContextPackageJson 不能为空'
    }

    try {
        $status.context_package = $ContextPackageJson | ConvertFrom-Json
    }
    catch {
        Fail 'ContextPackageJson 不是合法 JSON'
    }
}

if ($PSBoundParameters.ContainsKey('AnchorsStateJson')) {
    if ([string]::IsNullOrWhiteSpace($AnchorsStateJson)) {
        Fail 'AnchorsStateJson 不能为空'
    }

    try {
        $status.anchors_state = $AnchorsStateJson | ConvertFrom-Json
    }
    catch {
        Fail 'AnchorsStateJson 不是合法 JSON'
    }
}

if ($PSBoundParameters.ContainsKey('BaselineField')) {
    if (-not $PSBoundParameters.ContainsKey('BaselinePath')) {
        Fail '传入 BaselineField 时必须同时传入 BaselinePath'
    }

    if (-not $status.baselines.PSObject.Properties.Name.Contains($BaselineField)) {
        Fail "不支持的 baseline 字段：$BaselineField"
    }

    if (-not (Test-Path -LiteralPath $BaselinePath)) {
        Fail "baseline 路径不存在：$BaselinePath"
    }

    $status.baselines.$BaselineField = $BaselinePath
}

if ($PSBoundParameters.ContainsKey('ArtifactField')) {
    if (-not $PSBoundParameters.ContainsKey('ArtifactPath')) {
        Fail '传入 ArtifactField 时必须同时传入 ArtifactPath'
    }

    if (-not $status.artifacts.PSObject.Properties.Name.Contains($ArtifactField)) {
        Fail "不支持的 artifact 字段：$ArtifactField"
    }

    $currentValue = $status.artifacts.$ArtifactField

    if ($currentValue -is [System.Array]) {
        $items = @($currentValue)
        $items += $ArtifactPath
        $status.artifacts.$ArtifactField = @($items | Where-Object { $_ } | Select-Object -Unique)
    }
    else {
        $status.artifacts.$ArtifactField = $ArtifactPath
    }
}

if ($PSBoundParameters.ContainsKey('BlockersJson')) {
    $status.blockers = @(Parse-JsonArray -Raw $BlockersJson -FieldName 'blockers')
}

if ($PSBoundParameters.ContainsKey('PendingConfirmationsJson')) {
    $status.pending_confirmations = @(Parse-JsonArray -Raw $PendingConfirmationsJson -FieldName 'pending_confirmations')
}

if ($PSBoundParameters.ContainsKey('ReviewResult')) {
    $status.review_state.last_review_result = $ReviewResult
}

if ($PSBoundParameters.ContainsKey('ReviewMustFixJson')) {
    $status.review_state.must_fix_before_next_stage = @(Parse-JsonArray -Raw $ReviewMustFixJson -FieldName 'review_state.must_fix_before_next_stage')
}

if ($PSBoundParameters.ContainsKey('OverwriteQueueJson')) {
    $status.overwrite_queue = @(Parse-JsonArray -Raw $OverwriteQueueJson -FieldName 'overwrite_queue')
}

if ($PSBoundParameters.ContainsKey('SystemMemoryCardsJson')) {
    $status.memory_refs.system_memory_cards = @(Parse-JsonArray -Raw $SystemMemoryCardsJson -FieldName 'memory_refs.system_memory_cards')
}

if ($PSBoundParameters.ContainsKey('RoundNumber')) {
    $status.alignment_state.round_number = $RoundNumber
}

if ($PSBoundParameters.ContainsKey('RoundGoal')) {
    $status.alignment_state.round_goal = $RoundGoal
}

if ($PSBoundParameters.ContainsKey('RoundInputsJson')) {
    $status.alignment_state.round_inputs = @(Parse-JsonArray -Raw $RoundInputsJson -FieldName 'alignment_state.round_inputs')
}

if ($PSBoundParameters.ContainsKey('CurrentOutput')) {
    $status.alignment_state.current_output = $CurrentOutput
}

if ($PSBoundParameters.ContainsKey('RoundResult')) {
    Ensure-OneOf -Value $RoundResult -Allowed $roundResultEnums -FieldName 'RoundResult'
    $status.alignment_state.round_result = $RoundResult
}

if ($PSBoundParameters.ContainsKey('LoopHistorySummary')) {
    $status.alignment_state.history_summary = $LoopHistorySummary
}

if ($PSBoundParameters.ContainsKey('FallbackType')) {
    Ensure-OneOf -Value $FallbackType -Allowed $fallbackEnums -FieldName 'FallbackType'
    $status.fallback_state.fallback_type = $FallbackType
}

if ($PSBoundParameters.ContainsKey('FallbackReason')) {
    $status.fallback_state.fallback_reason = $FallbackReason
}

if ($PSBoundParameters.ContainsKey('ChangeCategory')) {
    Ensure-OneOf -Value $ChangeCategory -Allowed $changeEnums -FieldName 'ChangeCategory'
    $status.change_state.change_category = $ChangeCategory
}

if ($PSBoundParameters.ContainsKey('ChangeCategoryConfirmedByPm')) {
    $status.change_state.change_category_confirmed_by_pm = Parse-BoolValue -Raw $ChangeCategoryConfirmedByPm -FieldName 'ChangeCategoryConfirmedByPm'
}

if (($PSBoundParameters.ContainsKey('FallbackType') -or $PSBoundParameters.ContainsKey('RoundResult')) -and
    $status.fallback_state.fallback_type -eq 'reopen_alignment' -and
    $status.alignment_state.round_result -eq 'ready_for_preflight') {
    Fail 'FallbackType=reopen_alignment 不能与 RoundResult=ready_for_preflight 同时存在'
}

$isHeavyChangeCategory = ($status.change_state.change_category -eq 'new_module') -or ($status.change_state.change_category -eq 'structural_change')
$isChangeDecisionStage = $status.current_stage -in @('omp-change', 'omp-disc')
if (($PSBoundParameters.ContainsKey('ChangeCategory') -or $PSBoundParameters.ContainsKey('ChangeCategoryConfirmedByPm')) -and $isHeavyChangeCategory) {
    if ((-not $status.change_state.change_category_confirmed_by_pm) -and (-not $isChangeDecisionStage)) {
        Fail '重变更在离开 omp-change / omp-disc 前必须确认 ChangeCategoryConfirmedByPm'
    }
}

$json = $status | ConvertTo-Json -Depth 10
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path -LiteralPath $Path), $json, $utf8Bom)
Write-Host '[OhMyPm] 状态文件已更新。' -ForegroundColor Green

