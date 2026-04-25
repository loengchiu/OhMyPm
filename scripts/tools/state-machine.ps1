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

function Get-PreferredSkill {
    param([object]$Status)

    if ($Status.current_mode -eq 'change_control' -or $Status.current_stage -eq 'omp-change') {
        return 'omp-change'
    }

    if (HasItems $Status.overwrite_queue) {
        return 'omp-fix'
    }

    if (HasItems $Status.review_state.must_fix_before_next_stage) {
        return 'omp-fix'
    }

    if (-not (HasMinimalContextPackage $Status)) {
        return 'omp-disc'
    }

    if (HasItems $Status.pending_confirmations) {
        return 'omp-disc'
    }

    if (HasText $Status.fallback_state.fallback_type) {
        return 'omp-disc'
    }

    if ($Status.current_stage -eq 'omp-review') {
        return 'omp-review'
    }

    if ($Status.current_stage -eq 'omp-proto') {
        if (-not (HasText $Status.baselines.prd)) {
            return 'omp-prd'
        }
        return 'omp-review'
    }

    if ($Status.current_stage -eq 'omp-prd') {
        return 'omp-review'
    }

    if ($Status.alignment_state.round_result -eq 'ready_for_preflight') {
        if (-not (HasText $Status.baselines.prototype)) {
            return 'omp-proto'
        }
        if (-not (HasText $Status.baselines.prd)) {
            return 'omp-prd'
        }
        return 'omp-review'
    }

    if ($Status.current_mode -eq 'alignment_loop') {
        if ($Status.alignment_state.round_number -ge 1) {
            return 'omp-solution'
        }
        return 'omp-disc'
    }

    if ($Status.current_stage -in @('omp-listen', 'omp-disc')) {
        return 'omp-disc'
    }

    if ($Status.current_stage -in @('omp-reply', 'omp-align', 'omp-solution')) {
        return 'omp-solution'
    }

    return 'omp-disc'
}

if (-not (Test-Path -LiteralPath $Path)) {
    Fail '状态文件不存在：.ohmypm/status.json'
}

$status = Read-Utf8Json -Path $Path
$preferredSkill = Get-PreferredSkill -Status $status

$result = [ordered]@{
    current_mode = $status.current_mode
    current_stage = $status.current_stage
    preferred_skill = $preferredSkill
    blocked_by = @($status.blockers)
    pending_confirmations = @($status.pending_confirmations)
    review_must_fix = @($status.review_state.must_fix_before_next_stage)
    fallback_type = $status.fallback_state.fallback_type
    round_result = $status.alignment_state.round_result
}

$result | ConvertTo-Json -Depth 10
