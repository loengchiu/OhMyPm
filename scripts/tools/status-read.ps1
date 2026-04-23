param(
    [string]$Path = '.ohmypm/status.json'
)

if (-not (Test-Path -LiteralPath $Path)) {
    Write-Host '[OhMyPm] 状态文件不存在：.ohmypm/status.json' -ForegroundColor Yellow
    exit 1
}

Get-Content -Raw -LiteralPath $Path
