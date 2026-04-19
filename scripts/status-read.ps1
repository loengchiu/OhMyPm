param(
    [string]$Path = "docs/project-status.json"
)

if (-not (Test-Path -LiteralPath $Path)) {
    Write-Host "[OhMyPm] project-status.json not found." -ForegroundColor Yellow
    exit 1
}

Get-Content -Raw -LiteralPath $Path
