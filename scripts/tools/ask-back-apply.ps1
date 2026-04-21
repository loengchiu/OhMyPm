param(
    [string]$Path = ".ohmypm/status.json",
    [string]$AnsweredConfirmation,
    [string]$PendingConfirmationsJson,
    [string]$ChangeCategoryConfirmedByPm,
    [string]$LastAction = "Applied PM confirmation from omp-check",
    [string]$NextRecommended = "继续回到刚才被卡住的阶段，并按最新确认结果重新判断是否可以推进。",
    [string]$ContextSummary
)

function Fail {
    param([string]$Message)
    Write-Error "[OhMyPm] $Message"
    exit 1
}

function Parse-JsonArray {
    param([string]$Raw)
    if ([string]::IsNullOrWhiteSpace($Raw)) { return @() }
    try {
        $parsed = $Raw | ConvertFrom-Json
    }
    catch {
        Fail "invalid JSON for pending confirmations"
    }

    if ($parsed -is [System.Array]) { return @($parsed) }
    return @($parsed)
}

function Parse-BoolString {
    param([string]$Raw)

    if ([string]::IsNullOrWhiteSpace($Raw)) {
        return $null
    }

    switch ($Raw.Trim().ToLowerInvariant()) {
        "true" { return $true }
        "false" { return $false }
        "1" { return $true }
        "0" { return $false }
        default { Fail "invalid boolean for ChangeCategoryConfirmedByPm" }
    }
}

if (-not (Test-Path -LiteralPath $Path)) {
    Fail "ohmypm-status.json not found."
}

$status = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json

if ($PSBoundParameters.ContainsKey("PendingConfirmationsJson")) {
    $status.pending_confirmations = @(Parse-JsonArray $PendingConfirmationsJson)
}
elseif ([string]::IsNullOrWhiteSpace($AnsweredConfirmation) -eq $false) {
    $remaining = @()
    foreach ($item in @($status.pending_confirmations)) {
        if ($item -ne $AnsweredConfirmation) {
            $remaining += $item
        }
    }
    $status.pending_confirmations = @($remaining)
}

$parsedPmConfirmation = Parse-BoolString -Raw $ChangeCategoryConfirmedByPm
if ($null -ne $parsedPmConfirmation) {
    $status.change_state.change_category_confirmed_by_pm = [bool]$parsedPmConfirmation
}

$status.last_action = $LastAction
$status.next_recommended = $NextRecommended

if ($PSBoundParameters.ContainsKey("ContextSummary")) {
    $status.context_summary = $ContextSummary
}

$json = $status | ConvertTo-Json -Depth 10
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path -LiteralPath $Path), $json, $utf8Bom)
Write-Host "[OhMyPm] ask-back status applied." -ForegroundColor Green

