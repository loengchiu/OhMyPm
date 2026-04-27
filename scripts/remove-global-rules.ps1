param(
    [Parameter(Mandatory = $true)][ValidateSet('codex', 'trae', 'trae-cn')][string]$HostKind
)

$ErrorActionPreference = 'Stop'

$userHome = $env:USERPROFILE
$startMarker = '<!-- OHMYPM GLOBAL RULES START -->'
$endMarker = '<!-- OHMYPM GLOBAL RULES END -->'
$toolPath = Join-Path $userHome '.ohmypm\bin\omp-lint.py'

switch ($HostKind) {
    'codex' {
        $path = Join-Path $userHome '.codex\AGENTS.md'
        if (-not (Test-Path -LiteralPath $path)) { break }
        $content = Get-Content -LiteralPath $path -Raw
        if ($content -match [regex]::Escape($startMarker)) {
            $pattern = "(?s)\r?\n?$([regex]::Escape($startMarker)).*?$([regex]::Escape($endMarker))\r?\n?"
            $updated = [regex]::Replace($content, $pattern, '')
            Set-Content -LiteralPath $path -Value $updated.Trim() -Encoding UTF8
        }
    }

    'trae' {
        $path = Join-Path $userHome '.trae\rules\ohmypm-global.md'
        if (Test-Path -LiteralPath $path) {
            Remove-Item -LiteralPath $path -Force
        }
    }

    'trae-cn' {
        $path = Join-Path $userHome '.trae-cn\rules\ohmypm-global.md'
        if (Test-Path -LiteralPath $path) {
            Remove-Item -LiteralPath $path -Force
        }
    }
}

if (Test-Path -LiteralPath $toolPath) {
    Remove-Item -LiteralPath $toolPath -Force
}

Write-Output 'global-rules:removed'
