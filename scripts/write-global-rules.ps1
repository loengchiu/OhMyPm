param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('codex', 'copilot', 'cursor', 'antigravity', 'trae', 'trae-cn')]
    [string]$HostKind
)

$ErrorActionPreference = 'Stop'

$ompRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$userHome = $env:USERPROFILE
$startMarker = '<!-- OHMYPM GLOBAL RULES START -->'
$endMarker = '<!-- OHMYPM GLOBAL RULES END -->'

switch ($HostKind) {
    'codex' {
        $path = Join-Path $userHome '.codex\AGENTS.md'
        $dir = Split-Path -Parent $path
        if (-not (Test-Path -LiteralPath $dir)) {
            New-Item -ItemType Directory -Force -Path $dir | Out-Null
        }

        $block = @(
            $startMarker
            '# OhMyPm Global Rules'
            ''
            'If the current project root contains `docs/project-status.json`,'
            "read ${ompRoot}\AGENTS.md and follow all rules in that file."
            'If `docs/project-status.json` does not exist, ignore this rule and do not run any OhMyPm workflow.'
            $endMarker
        ) -join "`r`n"

        $existing = if (Test-Path -LiteralPath $path) { Get-Content -LiteralPath $path -Raw } else { '' }
        if ($existing -match [regex]::Escape($startMarker)) {
            $pattern = "(?s)$([regex]::Escape($startMarker)).*?$([regex]::Escape($endMarker))"
            $updated = [regex]::Replace($existing, $pattern, $block)
        }
        elseif ([string]::IsNullOrWhiteSpace($existing)) {
            $updated = $block
        }
        else {
            $updated = ($existing.TrimEnd() + "`r`n`r`n" + $block)
        }

        Set-Content -LiteralPath $path -Value $updated -Encoding UTF8
    }

    'copilot' {
        $dir = Join-Path $userHome '.copilot\instructions'
        $path = Join-Path $dir 'ohmypm-global.instructions.md'
        if (-not (Test-Path -LiteralPath $dir)) {
            New-Item -ItemType Directory -Force -Path $dir | Out-Null
        }

        $content = @(
            '---'
            'applyTo: "**"'
            '---'
            '# OhMyPm Global Rules'
            ''
            'If the current project root contains `docs/project-status.json`,'
            "read ${ompRoot}\AGENTS.md and follow all rules in that file."
            'If `docs/project-status.json` does not exist, ignore this rule and do not run any OhMyPm workflow.'
        ) -join "`r`n"

        Set-Content -LiteralPath $path -Value $content -Encoding UTF8
    }

    'cursor' {
        $path = Join-Path $userHome '.claude\CLAUDE.md'
        $dir = Split-Path -Parent $path
        if (-not (Test-Path -LiteralPath $dir)) {
            New-Item -ItemType Directory -Force -Path $dir | Out-Null
        }

        $block = @(
            $startMarker
            '# OhMyPm Global Rules'
            ''
            'If the current project root contains `docs/project-status.json`,'
            "read ${ompRoot}\AGENTS.md and follow all rules in that file."
            'If `docs/project-status.json` does not exist, ignore this rule and do not run any OhMyPm workflow.'
            $endMarker
        ) -join "`r`n"

        $existing = if (Test-Path -LiteralPath $path) { Get-Content -LiteralPath $path -Raw } else { '' }
        if ($existing -match [regex]::Escape($startMarker)) {
            $pattern = "(?s)$([regex]::Escape($startMarker)).*?$([regex]::Escape($endMarker))"
            $updated = [regex]::Replace($existing, $pattern, $block)
        }
        elseif ([string]::IsNullOrWhiteSpace($existing)) {
            $updated = $block
        }
        else {
            $updated = ($existing.TrimEnd() + "`r`n`r`n" + $block)
        }

        Set-Content -LiteralPath $path -Value $updated -Encoding UTF8
    }

    'antigravity' {
        $dir = Join-Path $userHome '.antigravity\rules'
        $path = Join-Path $dir 'ohmypm-global.md'
        if (-not (Test-Path -LiteralPath $dir)) {
            New-Item -ItemType Directory -Force -Path $dir | Out-Null
        }

        $content = @(
            '# OhMyPm Global Rules'
            ''
            'If the current project root contains `docs/project-status.json`,'
            "read ${ompRoot}\AGENTS.md and follow all rules in that file."
            'If `docs/project-status.json` does not exist, ignore this rule and do not run any OhMyPm workflow.'
        ) -join "`r`n"

        Set-Content -LiteralPath $path -Value $content -Encoding UTF8
    }

    'trae' {
        $dir = Join-Path $userHome '.trae\rules'
        $path = Join-Path $dir 'ohmypm-global.md'
        if (-not (Test-Path -LiteralPath $dir)) {
            New-Item -ItemType Directory -Force -Path $dir | Out-Null
        }

        $content = @(
            '---'
            'alwaysApply: true'
            '---'
            '# OhMyPm Global Rules'
            ''
            'If the current project root contains `docs/project-status.json`,'
            "read ${ompRoot}\AGENTS.md and follow all rules in that file."
            'If `docs/project-status.json` does not exist, ignore this rule and do not run any OhMyPm workflow.'
        ) -join "`r`n"

        Set-Content -LiteralPath $path -Value $content -Encoding UTF8
    }

    'trae-cn' {
        $dir = Join-Path $userHome '.trae-cn\rules'
        $path = Join-Path $dir 'ohmypm-global.md'
        if (-not (Test-Path -LiteralPath $dir)) {
            New-Item -ItemType Directory -Force -Path $dir | Out-Null
        }

        $content = @(
            '---'
            'alwaysApply: true'
            '---'
            '# OhMyPm Global Rules'
            ''
            'If the current project root contains `docs/project-status.json`,'
            "read ${ompRoot}\AGENTS.md and follow all rules in that file."
            'If `docs/project-status.json` does not exist, ignore this rule and do not run any OhMyPm workflow.'
        ) -join "`r`n"

        Set-Content -LiteralPath $path -Value $content -Encoding UTF8
    }
}

Write-Output 'global-rules:ok'
