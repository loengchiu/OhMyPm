param(
    [string[]]$Hosts = @('codex', 'copilot', 'cursor', 'antigravity', 'trae', 'trae-cn')
)

$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptRoot '..')
$writer = Join-Path $repoRoot 'scripts\write-global-rules.ps1'
$normalizedHosts = New-Object System.Collections.Generic.List[string]

foreach ($item in $Hosts) {
    foreach ($part in ($item -split ',')) {
        $name = $part.Trim()
        if ($name.Length -gt 0) {
            $normalizedHosts.Add($name)
        }
    }
}

foreach ($hostKind in $normalizedHosts) {
    Write-Host "[OhMyPm] configuring host: $hostKind" -ForegroundColor Cyan
    & $writer -HostKind $hostKind
}

Write-Host "[OhMyPm] install completed." -ForegroundColor Green
