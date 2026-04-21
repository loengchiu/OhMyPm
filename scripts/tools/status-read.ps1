param(
    [string]$Path = ".ohmypm/status.json"
)

if (-not (Test-Path -LiteralPath $Path)) {
    Write-Host "[OhMyPm] ohmypm-status.json not found." -ForegroundColor Yellow
    exit 1
}

Get-Content -Raw -LiteralPath $Path

