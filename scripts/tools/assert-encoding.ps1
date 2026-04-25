param(
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
)

$ErrorActionPreference = 'Stop'

$utf8Strict = New-Object System.Text.UTF8Encoding($false, $true)
$errors = New-Object System.Collections.Generic.List[string]

function Test-Utf8Strict {
    param([string]$Path)

    try {
        $bytes = [System.IO.File]::ReadAllBytes($Path)
        [void]$utf8Strict.GetString($bytes)
        return $true
    }
    catch {
        return $false
    }
}

$files = Get-ChildItem -LiteralPath $Root -Recurse -File |
    Where-Object {
        $_.FullName -notmatch '\\.git\\' -and
        $_.Extension -in @('.ps1', '.md', '.json')
    }

foreach ($file in $files) {
    $path = $file.FullName
    $bytes = [System.IO.File]::ReadAllBytes($path)

    if (-not (Test-Utf8Strict -Path $path)) {
        $errors.Add("不是合法 UTF-8：$path")
        continue
    }

    if ($file.Extension -eq '.ps1') {
        $hasBom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
        if (-not $hasBom) {
            $errors.Add(".ps1 缺少 UTF-8 BOM：$path")
        }
    }
}

if ($errors.Count -gt 0) {
    foreach ($item in $errors) {
        Write-Host "[OhMyPm] 编码问题：$item" -ForegroundColor Yellow
    }
    Write-Error "[OhMyPm] 编码检查未通过"
    exit 1
}

Write-Host '[OhMyPm] 编码检查通过。' -ForegroundColor Green
