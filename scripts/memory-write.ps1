param(
    [string]$Path = "docs/project-memory.md",
    [string]$SectionTitle,
    [int]$SectionNumber = 0,
    [Parameter(Mandatory = $true)]
    [string]$Content
)

function Fail {
    param([string]$Message)
    Write-Error "[OhMyPm] $Message"
    exit 1
}

if (-not (Test-Path -LiteralPath $Path)) {
    Fail "project-memory.md not found."
}

$lines = Get-Content -LiteralPath $Path
$startIndex = -1
$endIndex = $lines.Count
$headingPattern = '^##\s+\d+\.\s+(.+)$'
$numberPattern = '^##\s+(\d+)\.\s+(.+)$'

for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    if ($line -match $numberPattern) {
        $matchedNumber = [int]$matches[1]
        $matchedTitle = $matches[2].Trim()
        $targetMatched = $false

        if ($SectionNumber -gt 0 -and $matchedNumber -eq $SectionNumber) {
            $targetMatched = $true
        }
        elseif (-not [string]::IsNullOrWhiteSpace($SectionTitle) -and $matchedTitle -eq $SectionTitle) {
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
    if ($SectionNumber -gt 0) {
        Fail "section not found: $SectionNumber"
    }

    Fail "section not found: $SectionTitle"
}

$before = @()
if ($startIndex -gt 0) {
    $before = $lines[0..$startIndex]
}

$contentLines = @($Content -split "`r?`n")
$after = @()
if ($endIndex -lt $lines.Count) {
    $after = $lines[$endIndex..($lines.Count - 1)]
}

$updated = @()
$updated += $before
$updated += $contentLines
$updated += ""
$updated += $after

$updated | Set-Content -LiteralPath $Path -Encoding utf8
Write-Host "[OhMyPm] project-memory.md updated: $SectionTitle" -ForegroundColor Green
