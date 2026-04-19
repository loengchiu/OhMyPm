param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,
    [string]$CachePath = "docs/cache/material-extract.md",
    [int]$DirectReadThreshold = 3000
)

function Fail {
    param([string]$Message)
    Write-Error "[OhMyPm] $Message"
    exit 1
}

if (-not (Test-Path -LiteralPath $InputPath)) {
    Fail "input file not found: $InputPath"
}

$content = Get-Content -Raw -LiteralPath $InputPath
$length = $content.Length

if ($length -lt $DirectReadThreshold) {
    $result = [ordered]@{
        source = $InputPath
        strategy = 'direct_read_allowed'
        chars = $length
        cache_written = $false
    }
    $result | ConvertTo-Json -Depth 10
    exit 0
}

$cacheDir = Split-Path -Parent $CachePath
if (-not (Test-Path -LiteralPath $cacheDir)) {
    New-Item -ItemType Directory -Force -Path $cacheDir | Out-Null
}

$lines = @($content -split "`r?`n")
$head = ($lines | Select-Object -First 40) -join "`r`n"

$sections = @(
    @{ Title = 'Business Goals And Background'; Body = $head },
    @{ Title = 'Roles And Responsibilities'; Body = '- Pending manual enrichment or second-pass extraction' },
    @{ Title = 'Key Flows'; Body = '- Pending manual enrichment or second-pass extraction' },
    @{ Title = 'Rules And Constraints'; Body = '- Pending manual enrichment or second-pass extraction' },
    @{ Title = 'Data And Interface Clues'; Body = '- Pending manual enrichment or second-pass extraction' },
    @{ Title = 'Exceptions And Boundaries'; Body = '- Pending manual enrichment or second-pass extraction' },
    @{ Title = 'Unclassified'; Body = '- Pending manual enrichment or second-pass extraction' }
)

$buffer = New-Object System.Collections.Generic.List[string]
$buffer.Add('# Material Extract Cache')
$buffer.Add('')
$buffer.Add("- Source: $InputPath")
$buffer.Add('- HasUnclassified: true')
$buffer.Add('- TargetedLookupAllowed: true')
$buffer.Add("- ExtractedAt: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
$buffer.Add('')

foreach ($section in $sections) {
    $buffer.Add("## $($section.Title)")
    $buffer.Add($section.Body)
    $buffer.Add('')
}

$buffer | Set-Content -LiteralPath $CachePath -Encoding utf8

$result = [ordered]@{
    source = $InputPath
    strategy = 'extract_then_cached_lookup'
    chars = $length
    cache_path = $CachePath
    cache_written = $true
}

$result | ConvertTo-Json -Depth 10
