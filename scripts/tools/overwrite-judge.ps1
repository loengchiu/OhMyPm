param(
    [string]$AffectedUpstreamJson = '[]',
    [ValidateSet('missing_scope', 'missing_rule', 'structure_conflict', 'baseline_stale', 'review_reversal')]
    [string]$ConflictType = 'missing_rule',
    [ValidateSet('low', 'medium', 'high')]
    [string]$Severity = 'medium',
    [ValidateSet('patch', 'rollback_upstream', 'restart_alignment')]
    [string]$ActionLevel = 'patch',
    [string]$WritebackTargetsJson = '[]',
    [string]$Reason = '',
    [switch]$VersionUnclear
)

function Parse-JsonArray {
    param([string]$Raw)
    if ([string]::IsNullOrWhiteSpace($Raw)) { return @() }
    $parsed = $Raw | ConvertFrom-Json
    if ($parsed -is [System.Array]) { return @($parsed) }
    return @($parsed)
}

$affected = @(Parse-JsonArray $AffectedUpstreamJson)
$writebackTargets = @(Parse-JsonArray $WritebackTargetsJson)
$canContinue = $true

if ($VersionUnclear) {
    $canContinue = $false
}
elseif ($ActionLevel -eq 'restart_alignment') {
    $canContinue = $false
}

$result = [ordered]@{
    affected_upstream = $affected
    conflict_type = $ConflictType
    severity = $Severity
    action_level = $ActionLevel
    writeback_targets = $writebackTargets
    can_continue = $canContinue
    reason = $Reason
}

$result | ConvertTo-Json -Depth 10
