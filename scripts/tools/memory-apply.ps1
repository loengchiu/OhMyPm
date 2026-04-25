param(
    [Parameter(Mandatory = $true)]
    [string]$PayloadPath,
    [string]$Path = '.ohmypm/memory.md'
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptRoot 'encoding.ps1')

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
        Fail '项目记忆章节不存在'
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
    $updated += ''
    $updated += $after
    return $updated
}

if (-not (Test-Path -LiteralPath $PayloadPath)) {
    Fail "项目记忆更新载荷不存在：$PayloadPath"
}

if (-not (Test-Path -LiteralPath $Path)) {
    Fail '项目记忆文件不存在：.ohmypm/memory.md'
}

$payload = Read-Utf8Json -Path $PayloadPath
if (-not $payload.updates) {
    Fail '缺少字段：updates'
}

$lines = @(Read-Utf8Lines -Path $Path)
foreach ($update in @($payload.updates)) {
    if (-not $update.PSObject.Properties['Content']) {
        Fail '缺少字段：Content'
    }

    $lines = @(Apply-SectionUpdate -Lines $lines -Update $update)
}

$content = ($lines -join [Environment]::NewLine)
Write-Utf8BomText -Path $Path -Content $content
Write-Host '[OhMyPm] 项目记忆已批量更新。' -ForegroundColor Green
