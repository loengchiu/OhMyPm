param(
    [string]$RolesJson = '["demand","pm","dev","qa","delivery","legacy_guard"]',
    [string]$FactIssuesJson = '[]',
    [string]$RiskIssuesJson = '[]',
    [string]$SuggestionIssuesJson = '[]',
    [ValidateSet('pass', 'conditional_pass', 'rework_required', 'defer')]
    [string]$Conclusion = 'conditional_pass',
    [string]$NextAction = '',
    [string]$MustFixJson = '[]'
)

function Parse-JsonArray {
    param([string]$Raw)
    if ([string]::IsNullOrWhiteSpace($Raw)) { return @() }
    $parsed = $Raw | ConvertFrom-Json
    if ($parsed -is [System.Array]) { return @($parsed) }
    return @($parsed)
}

$roles = @(Parse-JsonArray $RolesJson)
$factIssues = @(Parse-JsonArray $FactIssuesJson)
$riskIssues = @(Parse-JsonArray $RiskIssuesJson)
$suggestionIssues = @(Parse-JsonArray $SuggestionIssuesJson)
$mustFix = @(Parse-JsonArray $MustFixJson)
$canContinue = $Conclusion -in @('pass', 'conditional_pass')

$result = [ordered]@{
    roles = $roles
    fact_issues = $factIssues
    risk_issues = $riskIssues
    suggestion_issues = $suggestionIssues
    unified_conclusion = @{
        result = $Conclusion
        next_action = $NextAction
        must_fix_before_next_stage = $mustFix
        can_continue = $canContinue
    }
}

$result | ConvertTo-Json -Depth 10
