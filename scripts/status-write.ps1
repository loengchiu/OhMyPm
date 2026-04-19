param(
    [string]$Path = "docs/project-status.json",
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
    [bool]$ChangeCategoryConfirmedByPm
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

if (-not (Test-Path -LiteralPath $Path)) {
    Fail "project-status.json not found."
}

$status = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json

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
    $status.loop_state.round_result = $RoundResult
}

if ($PSBoundParameters.ContainsKey("LoopHistorySummary")) {
    $status.loop_state.history_summary = $LoopHistorySummary
}

if ($PSBoundParameters.ContainsKey("FallbackType")) {
    $status.fallback_state.fallback_type = $FallbackType
}

if ($PSBoundParameters.ContainsKey("FallbackReason")) {
    $status.fallback_state.fallback_reason = $FallbackReason
}

if ($PSBoundParameters.ContainsKey("ChangeCategory")) {
    $status.change_state.change_category = $ChangeCategory
}

if ($PSBoundParameters.ContainsKey("ChangeCategoryConfirmedByPm")) {
    $status.change_state.change_category_confirmed_by_pm = $ChangeCategoryConfirmedByPm
}

$status | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $Path -Encoding utf8
Write-Host "[OhMyPm] project-status.json updated." -ForegroundColor Green
