param(
    [Parameter(Mandatory = $true)][ValidateSet('codex', 'trae', 'trae-cn')][string]$HostKind
)

$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$writeScript = Join-Path $scriptRoot 'scripts\write-global-rules.ps1'
$verifyScript = Join-Path $scriptRoot 'scripts\verify-global-rules.ps1'
$toolDir = Join-Path $env:USERPROFILE '.ohmypm\bin'
$toolPath = Join-Path $toolDir 'omp-lint.py'
$ompLintSource = Join-Path $scriptRoot 'scripts\python\omp-lint.py'

if (-not (Test-Path -LiteralPath $toolDir)) {
    New-Item -ItemType Directory -Force -Path $toolDir | Out-Null
}

$wrapper = @(
    'from pathlib import Path'
    'import runpy'
    ''
    "TARGET = Path(r'$($ompLintSource -replace '\\', '\\')')"
    'runpy.run_path(str(TARGET), run_name="__main__")'
) -join "`r`n"

Set-Content -LiteralPath $toolPath -Value $wrapper -Encoding UTF8

& $writeScript -HostKind $HostKind
& $verifyScript -HostKind $HostKind

Write-Output 'ohmypm-install:ok'
