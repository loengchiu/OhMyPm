param(
    [Parameter(Mandatory = $true)][ValidateSet('codex', 'trae', 'trae-cn')][string]$HostKind
)

$ErrorActionPreference = 'Stop'

$ompRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$userHome = $env:USERPROFILE
$toolPath = Join-Path $userHome '.ohmypm\bin\omp-lint.py'

if (-not (Test-Path -LiteralPath $toolPath)) {
    Write-Error 'verify failed: installed omp-lint wrapper missing'
    exit 1
}

switch ($HostKind) {
    'codex' {
        $path = Join-Path $userHome '.codex\AGENTS.md'
        if (-not (Test-Path -LiteralPath $path)) {
            Write-Error 'verify failed: codex AGENTS.md missing'
            exit 1
        }

        $content = Get-Content -LiteralPath $path -Raw
        if ($content -notmatch 'OhMyPm Global Rules' -or $content -notmatch [regex]::Escape("$ompRoot\AGENTS.md")) {
            Write-Error 'verify failed: codex AGENTS.md missing OhMyPm rule block'
            exit 1
        }
    }

    'trae' {
        $path = Join-Path $userHome '.trae\rules\ohmypm-global.md'
        if (-not (Test-Path -LiteralPath $path)) {
            Write-Error 'verify failed: trae global rules missing'
            exit 1
        }

        $content = Get-Content -LiteralPath $path -Raw
        if ($content -notmatch 'OhMyPm Global Rules' -or $content -notmatch [regex]::Escape("$ompRoot\AGENTS.md")) {
            Write-Error 'verify failed: trae global rules missing OhMyPm rule'
            exit 1
        }
    }

    'trae-cn' {
        $path = Join-Path $userHome '.trae-cn\rules\ohmypm-global.md'
        if (-not (Test-Path -LiteralPath $path)) {
            Write-Error 'verify failed: trae-cn global rules missing'
            exit 1
        }

        $content = Get-Content -LiteralPath $path -Raw
        if ($content -notmatch 'OhMyPm Global Rules' -or $content -notmatch [regex]::Escape("$ompRoot\AGENTS.md")) {
            Write-Error 'verify failed: trae-cn global rules missing OhMyPm rule'
            exit 1
        }
    }
}

Write-Output 'global-rules:verify-ok'
