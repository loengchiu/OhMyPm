param(
    [string]$InputPath = "",
    [int]$WarningChars = 6000
)

if ([string]::IsNullOrWhiteSpace($InputPath)) {
    Write-Host "[OhMyPm] no input path provided. placeholder result only." -ForegroundColor Yellow
    exit 0
}

if (-not (Test-Path -LiteralPath $InputPath)) {
    Write-Error "[OhMyPm] input file not found: $InputPath"
    exit 1
}

$content = Get-Content -Raw -LiteralPath $InputPath
$length = $content.Length

if ($length -ge $WarningChars) {
    Write-Host "[OhMyPm] context risk detected. chunking recommended. chars=$length" -ForegroundColor Yellow
    exit 2
}

Write-Host "[OhMyPm] context size ok. chars=$length" -ForegroundColor Green
