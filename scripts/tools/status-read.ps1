param(
    [string]$Path = '.ohmypm/status.json'
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptRoot 'encoding.ps1')

if (-not (Test-Path -LiteralPath $Path)) {
    Write-Host '[OhMyPm] 状态文件不存在：.ohmypm/status.json' -ForegroundColor Yellow
    exit 1
}

Read-Utf8Text -Path $Path
