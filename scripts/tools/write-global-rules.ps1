param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('codex', 'copilot', 'cursor', 'antigravity', 'trae', 'trae-cn')]
    [string]$HostKind
)

$ErrorActionPreference = 'Stop'

$ompRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
. (Join-Path $PSScriptRoot 'encoding.ps1')
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
            'If the current project root contains `.ohmypm/status.json`,'
            "read ${ompRoot}\AGENTS.md and follow all rules in that file."
            'If `.ohmypm/status.json` does not exist, ignore this rule and do not run any OhMyPm workflow.'
            $endMarker
        ) -join "`r`n"

        $existing = if (Test-Path -LiteralPath $path) { Read-Utf8Text -Path $path } else { '' }
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

        Write-Utf8BomText -Path $path -Content $updated
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
            'If the current project root contains `.ohmypm/status.json`,'
            "read ${ompRoot}\AGENTS.md and follow all rules in that file."
            'If `.ohmypm/status.json` does not exist, ignore this rule and do not run any OhMyPm workflow.'
        ) -join "`r`n"

        Write-Utf8BomText -Path $path -Content $content
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
            'If the current project root contains `.ohmypm/status.json`,'
            "read ${ompRoot}\AGENTS.md and follow all rules in that file."
            'If `.ohmypm/status.json` does not exist, ignore this rule and do not run any OhMyPm workflow.'
            $endMarker
        ) -join "`r`n"

        $existing = if (Test-Path -LiteralPath $path) { Read-Utf8Text -Path $path } else { '' }
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

        Write-Utf8BomText -Path $path -Content $updated
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
            'If the current project root contains `.ohmypm/status.json`,'
            "read ${ompRoot}\AGENTS.md and follow all rules in that file."
            'If `.ohmypm/status.json` does not exist, ignore this rule and do not run any OhMyPm workflow.'
        ) -join "`r`n"

        Write-Utf8BomText -Path $path -Content $content
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
            'If the current project root contains `.ohmypm/status.json`,'
            "read ${ompRoot}\AGENTS.md and follow all rules in that file."
            'If `.ohmypm/status.json` does not exist, ignore this rule and do not run any OhMyPm workflow.'
        ) -join "`r`n"

        Write-Utf8BomText -Path $path -Content $content
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
            'If the current project root contains `.ohmypm/status.json`,'
            "read ${ompRoot}\AGENTS.md and follow all rules in that file."
            'If `.ohmypm/status.json` does not exist, ignore this rule and do not run any OhMyPm workflow.'
        ) -join "`r`n"

        Write-Utf8BomText -Path $path -Content $content
    }
}

Write-Output 'global-rules:ok'

