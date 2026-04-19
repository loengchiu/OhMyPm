param(
    [string]$InputPath = '',
    [ValidateSet('response', 'prototype', 'prd', 'review_pack', 'generic')]
    [string]$OutputKind = 'generic',
    [int]$InputWarningChars = 3000,
    [int]$OutputWarningChars = 4000,
    [int]$ExpectedOutputChars = 0
)

function Get-RiskLevel {
    param([int]$Size, [int]$WarningChars)
    if ($Size -ge ($WarningChars * 2)) { return 'high' }
    if ($Size -ge $WarningChars) { return 'medium' }
    return 'low'
}

$inputChars = 0
$inputRisk = 'low'
$riskSources = New-Object System.Collections.Generic.List[string]

if (-not [string]::IsNullOrWhiteSpace($InputPath) -and (Test-Path -LiteralPath $InputPath)) {
    $inputChars = (Get-Content -Raw -LiteralPath $InputPath).Length
    $inputRisk = Get-RiskLevel -Size $inputChars -WarningChars $InputWarningChars
    if ($inputRisk -ne 'low') {
        $riskSources.Add('input_material_too_large')
    }
}

$outputRisk = 'low'
if ($ExpectedOutputChars -gt 0) {
    $outputRisk = Get-RiskLevel -Size $ExpectedOutputChars -WarningChars $OutputWarningChars
    if ($outputRisk -ne 'low') {
        $riskSources.Add('output_target_too_large')
    }
}

$riskOrder = @{ low = 1; medium = 2; high = 3 }
$overallRisk = if ($riskOrder[$inputRisk] -ge $riskOrder[$outputRisk]) { $inputRisk } else { $outputRisk }

$chunkBy = switch ($OutputKind) {
    'response' { 'module_or_problem_domain' }
    'prototype' { 'page' }
    'prd' { 'chapter_or_page_unit' }
    'review_pack' { 'decision_bucket' }
    default { 'logical_section' }
}

$plan = [ordered]@{
    input_chars = $inputChars
    expected_output_chars = $ExpectedOutputChars
    risk_sources = @($riskSources)
    risk_level = $overallRisk
    input_strategy = if ($inputRisk -eq 'low') { 'direct_read_allowed' } else { 'extract_then_targeted_lookup' }
    output_strategy = if ($outputRisk -eq 'low') { 'single_pass_allowed' } else { 'chunk_then_summarize' }
    chunk_by = $chunkBy
    keep_in_context = if ($overallRisk -eq 'high') { 'summary_and_index_only' } else { 'minimal_required_context' }
}

$plan | ConvertTo-Json -Depth 10
