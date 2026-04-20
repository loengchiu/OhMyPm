param(
    [Parameter(Mandatory = $true)]
    [string]$PayloadPath,
    [string]$Path = "docs/ohmypm/ohmypm-memory.md"
)

function Fail {
    param([string]$Message)
    Write-Error "[OhMyPm] $Message"
    exit 1
}

function Apply-SectionUpdate {
    param(
        [string[]]$Lines,
        [pscustomobject]$Update
    )

    $startIndex = -1
    $endIndex = $Lines.Count
    $numberPattern = '^##\s+(\d+)\.\s+(.+)$'

    for ($i = 0; $i -lt $Lines.Count; $i++) {
        $line = $Lines[$i]
        if ($line -match $numberPattern) {
            $matchedNumber = [int]$matches[1]
            $matchedTitle = $matches[2].Trim()
            $targetMatched = $false

            if ($Update.PSObject.Properties['SectionNumber'] -and [int]$Update.SectionNumber -eq $matchedNumber) {
                $targetMatched = $true
            }
            elseif ($Update.PSObject.Properties['SectionTitle'] -and [string]$Update.SectionTitle -eq $matchedTitle) {
                $targetMatched = $true
            }

            if ($targetMatched) {
                $startIndex = $i
                continue
            }

            if ($startIndex -ge 0) {
                $endIndex = $i
                break
            }
        }
    }

    if ($startIndex -lt 0) {
        Fail "memory section not found"
    }

    $before = @()
    if ($startIndex -gt 0) {
        $before = $Lines[0..$startIndex]
    }

    $contentLines = @([string]$Update.Content -split "`r?`n")
    $after = @()
    if ($endIndex -lt $Lines.Count) {
        $after = $Lines[$endIndex..($Lines.Count - 1)]
    }

    $updated = @()
    $updated += $before
    $updated += $contentLines
    $updated += ""
    $updated += $after
    return $updated
}

if (-not (Test-Path -LiteralPath $PayloadPath)) {
    Fail "memory payload not found: $PayloadPath"
}

if (-not (Test-Path -LiteralPath $Path)) {
    Fail "ohmypm-memory.md not found."
}

$payload = Get-Content -Raw -LiteralPath $PayloadPath | ConvertFrom-Json
if (-not $payload.updates) {
    Fail "memory payload missing updates"
}

$lines = @(Get-Content -LiteralPath $Path)
foreach ($update in @($payload.updates)) {
    if (-not $update.PSObject.Properties['Content']) {
        Fail "memory update missing Content"
    }

    $lines = @(Apply-SectionUpdate -Lines $lines -Update $update)
}

$content = ($lines -join [Environment]::NewLine)
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Resolve-Path -LiteralPath $Path), $content, $utf8Bom)
Write-Host "[OhMyPm] ohmypm-memory.md batch updated." -ForegroundColor Green
