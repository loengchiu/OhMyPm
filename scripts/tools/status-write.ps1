param(
    [string]$Path = ".ohmypm/status.json",
    [string]$Stage,
    [string]$Mode,
    [string]$Version,
    [string]$LastAction,
    [string]$NextRecommended,
    [string]$ContextSummary,
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
        Fail "invalid JSON for $FieldName"
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
        $allowedText = ($Allowed -join ", ")
        Fail "$FieldName must be one of: $allowedText"
    }
}

function Parse-BoolValue {
    param(
        $Raw,
        [string]$FieldName
    )

    if ($null -eq $Raw) {
        Fail "$FieldName cannot be null"
    }

    if ($Raw -is [bool]) {
        return $Raw
    }

    $text = "$Raw".Trim().ToLowerInvariant()

    switch ($text) {
        "true" { return $true }
        "false" { return $false }
        "1" { return $true }
        "0" { return $false }
        "yes" { return $true }
        "no" { return $false }
        default { Fail "$FieldName must be a boolean value" }
    }
}

if (-not (Test-Path -LiteralPath $Path)) {
    Fail "ohmypm-status.json not found."
}

$status = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
$roundResultEnums = @("continue_alignment", "need_materials", "need_internal_repair", "ready_for_preflight")
$fallbackEnums = @("internal_repair", "need_materials", "reopen_alignment")
$changeEnums = @("minor_patch", "within_module", "new_module", "structural_change")

if ($PSBoundParameters.ContainsKey("Stage")) { $status.current_stage = $Stage }
if ($PSBoundParameters.ContainsKey("Mode")) { $status.current_mode = $Mode }
if ($PSBoundParameters.ContainsKey("Version")) { $status.current_version = $Version }
if ($PSBoundParameters.ContainsKey("LastAction")) { $status.last_action = $LastAction }
if ($PSBoundParameters.ContainsKey("NextRecommended")) { $status.next_recommended = $NextRecommended }
if ($PSBoundParameters.ContainsKey("ContextSummary")) { $status.context_summary = $ContextSummary }

if ($PSBoundParameters.ContainsKey("BaselineField")) {
    if (-not $PSBoundParameters.ContainsKey("BaselinePath")) {
        Fail "BaselinePath is required when BaselineField is provided."
    }

    if (-not $status.stable_baselines.PSObject.Properties.Name.Contains($BaselineField)) {
        Fail "unsupported baseline field: $BaselineField"
    }

    if (-not (Test-Path -LiteralPath $BaselinePath)) {
        Fail "baseline path does not exist: $BaselinePath"
    }

    $status.stable_baselines.$BaselineField = $BaselinePath
}

if ($PSBoundParameters.ContainsKey("ArtifactField")) {
    if (-not $PSBoundParameters.ContainsKey("ArtifactPath")) {
        Fail "ArtifactPath is required when ArtifactField is provided."
    }

    if (-not $status.latest_artifacts.PSObject.Properties.Name.Contains($ArtifactField)) {
        Fail "unsupported artifact field: $ArtifactField"
    }

    $currentValue = $status.latest_artifacts.$ArtifactField

    if ($currentValue -is [System.Array]) {
        $items = @($currentValue)
        $items += $ArtifactPath
        $status.latest_artifacts.$ArtifactField = @($items | Where-Object { $_ } | Select-Object -Unique)
    }
    else {
        $status.latest_artifacts.$ArtifactField = $ArtifactPath
    }
}

if ($PSBoundParameters.ContainsKey("BlockersJson")) {
    $status.blockers = @(Parse-JsonArray -Raw $BlockersJson -FieldName "blockers")
}

if ($PSBoundParameters.ContainsKey("PendingConfirmationsJson")) {
    $status.pending_confirmations = @(Parse-JsonArray -Raw $PendingConfirmationsJson -FieldName "pending_confirmations")
}

if ($PSBoundParameters.ContainsKey("ReviewResult")) {
    $status.review_state.last_review_result = $ReviewResult
}

if ($PSBoundParameters.ContainsKey("ReviewMustFixJson")) {
    $status.review_state.must_fix_before_next_stage = @(Parse-JsonArray -Raw $ReviewMustFixJson -FieldName "review_state.must_fix_before_next_stage")
}

if ($PSBoundParameters.ContainsKey("OverwriteQueueJson")) {
    $status.overwrite_queue = @(Parse-JsonArray -Raw $OverwriteQueueJson -FieldName "overwrite_queue")
}

if ($PSBoundParameters.ContainsKey("SystemMemoryCardsJson")) {
    $status.memory_refs.system_memory_cards = @(Parse-JsonArray -Raw $SystemMemoryCardsJson -FieldName "memory_refs.system_memory_cards")
}

if ($PSBoundParameters.ContainsKey("RoundNumber")) {
    $status.loop_state.round_number = $RoundNumber
}

if ($PSBoundParameters.ContainsKey("RoundGoal")) {
    $status.loop_state.round_goal = $RoundGoal
}

if ($PSBoundParameters.ContainsKey("RoundInputsJson")) {
    $status.loop_state.round_inputs = @(Parse-JsonArray -Raw $RoundInputsJson -FieldName "loop_state.round_inputs")
}

if ($PSBoundParameters.ContainsKey("CurrentOutput")) {
    $status.loop_state.current_output = $CurrentOutput
}

if ($PSBoundParameters.ContainsKey("RoundResult")) {
    Ensure-OneOf -Value $RoundResult -Allowed $roundResultEnums -FieldName "RoundResult"
    $status.loop_state.round_result = $RoundResult
}

if ($PSBoundParameters.ContainsKey("LoopHistorySummary")) {
    $status.loop_state.history_summary = $LoopHistorySummary
}

if ($PSBoundParameters.ContainsKey("FallbackType")) {
    Ensure-OneOf -Value $FallbackType -Allowed $fallbackEnums -FieldName "FallbackType"
    $status.fallback_state.fallback_type = $FallbackType
}

if ($PSBoundParameters.ContainsKey("FallbackReason")) {
    $status.fallback_state.fallback_reason = $FallbackReason
}

if ($PSBoundParameters.ContainsKey("ChangeCategory")) {
    Ensure-OneOf -Value $ChangeCategory -Allowed $changeEnums -FieldName "ChangeCategory"
    $status.change_state.change_category = $ChangeCategory
}

if ($PSBoundParameters.ContainsKey("ChangeCategoryConfirmedByPm")) {
    $status.change_state.change_category_confirmed_by_pm = Parse-BoolValue -Raw $ChangeCategoryConfirmedByPm -FieldName "ChangeCategoryConfirmedByPm"
}

if (($PSBoundParameters.ContainsKey("FallbackType") -or $PSBoundParameters.ContainsKey("RoundResult")) -and
    $status.fallback_state.fallback_type -eq "reopen_alignment" -and
    $status.loop_state.round_result -eq "ready_for_preflight") {
    Fail "FallbackType=reopen_alignment cannot coexist with RoundResult=ready_for_preflight"
}

if (($PSBoundParameters.ContainsKey("ChangeCategory") -or $PSBoundParameters.ContainsKey("ChangeCategoryConfirmedByPm")) -and
    (($status.change_state.change_category -eq "new_module") -or ($status.change_state.change_category -eq "structural_change"))) {
    if (-not $status.change_state.change_category_confirmed_by_pm) {
        Fail "ChangeCategoryConfirmedByPm is required for new_module or structural_change"
    }
}

$json = $status | ConvertTo-Json -Depth 10
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path -LiteralPath $Path), $json, $utf8Bom)
Write-Host "[OhMyPm] ohmypm-status.json updated." -ForegroundColor Green

