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

    if (HasText $Status.scenario_mode) {
        return $Status.scenario_mode.ToString().Trim().ToLowerInvariant()
    }

    if ($null -ne $Status.collaboration_context -and (HasText $Status.collaboration_context.scenario_mode)) {
        return $Status.collaboration_context.scenario_mode.ToString().Trim().ToLowerInvariant()
    }

    return "real_project"
}

function Is-SampleScenario {
    param([string]$ScenarioMode)

    return $ScenarioMode -in @("sample_validation", "demo_smoke", "demo", "sample")
}

function Get-CurrentNode {
    param([object]$Status)

    $stage = "$($Status.current_stage)".Trim()
    $mode = "$($Status.current_mode)".Trim()

    if ($stage -eq "omp-change" -or $mode -eq "change_control") {
        return "处理变更"
    }

    if ($stage -eq "omp-fix") {
        return "修正问题"
    }

    if ($stage -eq "omp-review") {
        return "开评审"
    }

    if ($stage -in @("omp-deliver-prototype", "omp-deliver-prd") -or $mode -eq "formal_delivery") {
        return "正式交付"
    }

    if ($stage -eq "omp-preflight" -or $Status.loop_state.round_result -eq "ready_for_preflight") {
        return "交付前检查"
    }

    if ($stage -in @("omp-respond", "omp-align", "omp-ask-back") -or $mode -eq "alignment_loop") {
        return "回应/对齐"
    }

    return "接收需求"
}

function Get-PreferredSkill {
    param(
        [object]$Status,
        [bool]$IsSampleScenario
    )

    if (HasItems $Status.review_state.must_fix_before_next_stage) {
        return "omp-fix"
    }

    if ($Status.current_mode -eq "change_control" -or $Status.current_stage -eq "omp-change") {
        return "omp-change"
    }

    if (HasItems $Status.pending_confirmations) {
        if ($IsSampleScenario) {
            return "omp-align"
        }
        return "omp-ask-back"
    }

    if (HasText $Status.fallback_state.fallback_type) {
        return "omp-align"
    }

    if ($Status.current_stage -eq "omp-review") {
        return "omp-review"
    }

    if ($Status.current_stage -eq "omp-preflight") {
        if (-not (HasText $Status.stable_baselines.prototype)) {
            return "omp-deliver-prototype"
        }

        if (-not (HasText $Status.stable_baselines.prd)) {
            return "omp-deliver-prd"
        }

        return "omp-review"
    }

    if ($Status.current_stage -eq "omp-deliver-prototype") {
        if (-not (HasText $Status.stable_baselines.prd)) {
            return "omp-deliver-prd"
        }
        return "omp-review"
    }

    if ($Status.current_stage -eq "omp-deliver-prd") {
        return "omp-review"
    }

    if ($Status.loop_state.round_result -eq "ready_for_preflight") {
        return "omp-preflight"
    }

    if ($Status.current_mode -eq "alignment_loop") {
        if ($Status.loop_state.round_number -ge 1) {
            return "omp-align"
        }
        return "omp-respond"
    }

    if ($Status.current_stage -eq "omp-intake") {
        return "omp-respond"
    }

    return "omp-respond"
}

function Get-AllowedSkills {
    param(
        [object]$Status,
        [string]$PreferredSkill
    )

    if ($Status.current_mode -eq "change_control" -or $Status.current_stage -eq "omp-change") {
        return @("omp-change", "omp-ask-back", "omp-fix")
    }

    if ($PreferredSkill -in @("omp-deliver-prototype", "omp-deliver-prd", "omp-review", "omp-fix")) {
        return @("omp-deliver-prototype", "omp-deliver-prd", "omp-review", "omp-fix", "omp-change")
    }

    if ($PreferredSkill -eq "omp-preflight" -or $Status.loop_state.round_result -eq "ready_for_preflight") {
        return @("omp-preflight", "omp-deliver-prototype", "omp-deliver-prd")
    }

    return @("omp-respond", "omp-align", "omp-ask-back", "omp-preflight")
}

if (-not (Test-Path -LiteralPath $Path)) {
    Fail "ohmypm-status.json not found."
}

$status = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
$scenarioMode = Get-ScenarioMode $status
$isSampleScenario = Is-SampleScenario $scenarioMode
$currentNode = Get-CurrentNode $status
$preferredSkill = Get-PreferredSkill -Status $status -IsSampleScenario:$isSampleScenario
$allowedSkills = @(Get-AllowedSkills -Status $status -PreferredSkill $preferredSkill)

$result = [ordered]@{
    scenario_mode = $scenarioMode
    current_mode = $status.current_mode
    current_stage = $status.current_stage
    current_node = $currentNode
    preferred_skill = $preferredSkill
    allowed_skills = $allowedSkills
    blocked_by = @($status.blockers)
    pending_confirmations = @($status.pending_confirmations)
    review_must_fix = @($status.review_state.must_fix_before_next_stage)
    fallback_type = $status.fallback_state.fallback_type
    round_result = $status.loop_state.round_result
}

$result | ConvertTo-Json -Depth 10
