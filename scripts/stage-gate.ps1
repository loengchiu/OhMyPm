param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("omp-respond", "omp-align", "omp-preflight", "omp-deliver", "omp-change")]
    [string]$Gate,

    [string]$Path = "docs/project-status.json"
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

if (-not (Test-Path -LiteralPath $Path)) {
    Fail "docs/project-status.json not found."
}

$status = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
$errors = New-Object System.Collections.Generic.List[string]

if (HasItems $status.blockers) {
    $errors.Add("blockers are not empty")
}

switch ($Gate) {
    "omp-respond" {
        if (-not (HasText $status.current_version)) {
            $errors.Add("current_version is missing")
        }

        $hasPlan = HasText $status.stable_baselines.response_plan
        $hasNote = HasItems $status.latest_artifacts.response_notes
        if (-not ($hasPlan -or $hasNote)) {
            $errors.Add("no response plan or response note is recorded")
        }

        if (-not (HasText $status.context_summary)) {
            $errors.Add("context_summary is empty")
        }
    }
    "omp-align" {
        if (HasItems $status.pending_confirmations) {
            $errors.Add("pending_confirmations are not empty")
        }

        $hasPlan = HasText $status.stable_baselines.response_plan
        $hasNote = HasItems $status.latest_artifacts.response_notes
        if (-not ($hasPlan -or $hasNote)) {
            $errors.Add("no response artifact is available for alignment")
        }

        if (-not (HasText $status.next_recommended)) {
            $errors.Add("next_recommended is empty")
        }
    }
    "omp-preflight" {
        if (HasItems $status.pending_confirmations) {
            $errors.Add("pending_confirmations are not empty")
        }

        $hasPlan = HasText $status.stable_baselines.response_plan
        $hasNote = HasItems $status.latest_artifacts.response_notes
        if (-not ($hasPlan -or $hasNote)) {
            $errors.Add("no stabilized response artifact is available")
        }

        if (-not (HasText $status.context_summary)) {
            $errors.Add("context_summary is empty")
        }
    }
    "omp-deliver" {
        if (HasItems $status.pending_confirmations) {
            $errors.Add("pending_confirmations are not empty")
        }

        $hasPlan = HasText $status.stable_baselines.response_plan
        if (-not $hasPlan) {
            $errors.Add("stable_baselines.response_plan is missing")
        }

        $reviewBlockers = HasItems $status.review_state.must_fix_before_next_stage
        if ($reviewBlockers) {
            $errors.Add("review_state.must_fix_before_next_stage is not empty")
        }
    }
    "omp-change" {
        if ((-not (HasText $status.stable_baselines.prototype)) -and (-not (HasText $status.stable_baselines.prd))) {
            $errors.Add("no formal delivery baseline exists")
        }
    }
}

if ($errors.Count -gt 0) {
    foreach ($item in $errors) {
        Write-Host "[OhMyPm] gate issue: $item" -ForegroundColor Yellow
    }
    Fail "gate blocked: $Gate"
}

Write-Host "[OhMyPm] gate passed: $Gate" -ForegroundColor Green
