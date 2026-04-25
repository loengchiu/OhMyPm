param(
    [string]$StatusPath = '.ohmypm/status.json'
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptRoot 'encoding.ps1')

function New-List {
    return New-Object System.Collections.Generic.List[string]
}

function HasText {
    param([object]$Value)
    return ($null -ne $Value -and $Value.ToString().Trim().Length -gt 0)
}

function HasProperty {
    param([object]$Object, [string]$Name)
    return ($null -ne $Object -and $null -ne $Object.PSObject.Properties[$Name])
}

function Add-Checked {
    param([System.Collections.Generic.List[string]]$List, [string]$Name)
    $List.Add($Name) | Out-Null
}

function Resolve-ProjectPath {
    param([string]$ProjectRoot, [string]$Path)
    if (-not (HasText $Path)) { return '' }
    if ([System.IO.Path]::IsPathRooted($Path)) { return $Path }
    return (Join-Path $ProjectRoot $Path)
}

function Get-ProjectRoot {
    param([string]$ResolvedStatusPath)
    $statusDir = Split-Path -Parent $ResolvedStatusPath
    if ((Split-Path -Leaf $statusDir) -eq '.ohmypm') {
        return (Split-Path -Parent $statusDir)
    }
    return (Get-Location).Path
}

function Get-Array {
    param([object]$Value)
    if ($null -eq $Value) { return @() }
    return @($Value)
}

function Emit-Result {
    param(
        [System.Collections.Generic.List[string]]$Errors,
        [System.Collections.Generic.List[string]]$Warnings,
        [System.Collections.Generic.List[string]]$Checked,
        [hashtable]$Summary
    )

    $result = if ($Errors.Count -gt 0) { 'fail' } elseif ($Warnings.Count -gt 0) { 'warn' } else { 'pass' }
    $payload = [ordered]@{
        tool = 'trace-lint'
        result = $result
        errors = @($Errors)
        warnings = @($Warnings)
        checked = @($Checked)
        summary = $Summary
    }

    $payload | ConvertTo-Json -Depth 10
    if ($Errors.Count -gt 0) { exit 1 }
}

$errors = New-List
$warnings = New-List
$checked = New-List
$summary = @{
    modules = 0
    pages = 0
    actions = 0
    prototype_markers = 0
}

if (-not (Test-Path -LiteralPath $StatusPath)) {
    $errors.Add("状态文件不存在：$StatusPath") | Out-Null
    Emit-Result -Errors $errors -Warnings $warnings -Checked $checked -Summary $summary
}

$resolvedStatusPath = (Resolve-Path -LiteralPath $StatusPath).Path
$projectRoot = Get-ProjectRoot -ResolvedStatusPath $resolvedStatusPath

try {
    $status = Read-Utf8Json -Path $resolvedStatusPath
}
catch {
    $errors.Add("状态文件不是合法 UTF-8 JSON：$StatusPath") | Out-Null
    Emit-Result -Errors $errors -Warnings $warnings -Checked $checked -Summary $summary
}

Add-Checked $checked 'status-json-readable'

if (-not (HasProperty $status 'anchors_state') -or -not (HasProperty $status.anchors_state 'meta') -or -not (HasText $status.anchors_state.meta.anchor_manifest)) {
    $errors.Add('anchors_state.meta.anchor_manifest 缺失') | Out-Null
    Emit-Result -Errors $errors -Warnings $warnings -Checked $checked -Summary $summary
}

$manifestPath = Resolve-ProjectPath -ProjectRoot $projectRoot -Path $status.anchors_state.meta.anchor_manifest.ToString()
if (-not (Test-Path -LiteralPath $manifestPath)) {
    $errors.Add("manifest 路径不存在：$($status.anchors_state.meta.anchor_manifest)") | Out-Null
    Emit-Result -Errors $errors -Warnings $warnings -Checked $checked -Summary $summary
}

try {
    $manifest = Read-Utf8Json -Path $manifestPath
}
catch {
    $errors.Add("manifest 不是合法 UTF-8 JSON：$($status.anchors_state.meta.anchor_manifest)") | Out-Null
    Emit-Result -Errors $errors -Warnings $warnings -Checked $checked -Summary $summary
}

Add-Checked $checked 'manifest-json-readable'

$modules = Get-Array $manifest.modules
if ($modules.Count -eq 0) {
    $errors.Add('manifest.modules 为空') | Out-Null
}

$manifestMarkers = New-Object System.Collections.Generic.HashSet[string]

foreach ($module in $modules) {
    $summary.modules++
    if (-not (HasText $module.module_id)) { $errors.Add('模块缺少 module_id') | Out-Null }
    if (-not (HasText $module.module_name)) { $errors.Add("模块缺少 module_name：$($module.module_id)") | Out-Null }

    $pages = Get-Array $module.pages
    if ($pages.Count -eq 0) {
        $errors.Add("模块缺少 pages：$($module.module_id)") | Out-Null
    }

    foreach ($page in $pages) {
        $summary.pages++
        if (-not (HasText $page.page_id)) { $errors.Add("页面缺少 page_id：$($module.module_id)") | Out-Null }
        if (-not (HasText $page.page_name)) { $errors.Add("页面缺少 page_name：$($module.module_id)/$($page.page_id)") | Out-Null }
        if (-not (HasText $page.human_page_code)) { $warnings.Add("页面缺少 human_page_code：$($module.module_id)/$($page.page_id)") | Out-Null }

        $actions = Get-Array $page.actions
        if ($actions.Count -eq 0) {
            $errors.Add("页面缺少 actions：$($module.module_id)/$($page.page_id)") | Out-Null
        }

        foreach ($action in $actions) {
            $summary.actions++
            if (-not (HasText $action.anchor_id)) { $errors.Add("动作缺少 anchor_id：$($module.module_id)/$($page.page_id)") | Out-Null }
            elseif ($action.anchor_id.ToString() -notmatch '^M\d{2}-P\d{2}-A\d{2}$') { $errors.Add("anchor_id 格式非法：$($action.anchor_id)") | Out-Null }
            if (-not (HasText $action.action_name)) { $errors.Add("动作缺少 action_name：$($action.anchor_id)") | Out-Null }
            if (-not (HasProperty $action 'prd_locator')) { $errors.Add("动作缺少 prd_locator：$($action.anchor_id)") | Out-Null }
            if (-not (HasProperty $action 'prototype_locator')) { $errors.Add("动作缺少 prototype_locator：$($action.anchor_id)") | Out-Null }

            if (HasProperty $action 'prototype_locator' -and HasText $action.prototype_locator.marker) {
                $manifestMarkers.Add($action.prototype_locator.marker.ToString()) | Out-Null
            }
        }
    }
}

$summary.prototype_markers = $manifestMarkers.Count
Add-Checked $checked 'manifest-anchor-structure'

$prdPaths = @()
if (HasProperty $status 'baselines' -and HasText $status.baselines.prd) { $prdPaths += $status.baselines.prd.ToString() }
if (HasProperty $status 'artifacts' -and HasText $status.artifacts.prd) { $prdPaths += $status.artifacts.prd.ToString() }
$prdPaths = @($prdPaths | Where-Object { HasText $_ } | Select-Object -Unique)
foreach ($path in $prdPaths) {
    $resolved = Resolve-ProjectPath -ProjectRoot $projectRoot -Path $path
    if (-not (Test-Path -LiteralPath $resolved)) { $errors.Add("PRD 路径不存在：$path") | Out-Null }
}
Add-Checked $checked 'prd-paths'

$prototypePaths = @()
if (HasProperty $status 'baselines' -and HasText $status.baselines.prototype) { $prototypePaths += $status.baselines.prototype.ToString() }
if (HasProperty $status 'artifacts' -and HasProperty $status.artifacts 'prototypes') {
    $prototypePaths += @(Get-Array $status.artifacts.prototypes | Where-Object { HasText $_ } | ForEach-Object { $_.ToString() })
}
$prototypePaths = @($prototypePaths | Where-Object { HasText $_ } | Select-Object -Unique)
foreach ($path in $prototypePaths) {
    $resolved = Resolve-ProjectPath -ProjectRoot $projectRoot -Path $path
    if (-not (Test-Path -LiteralPath $resolved)) { $errors.Add("原型路径不存在：$path") | Out-Null }
}
Add-Checked $checked 'prototype-paths'

$outputPath = Join-Path $projectRoot 'output'
if (Test-Path -LiteralPath $outputPath) {
    $leakPattern = 'M[0-9]{2}-P[0-9]{2}-A[0-9]{2}|anchor_id|rules_ref|prototype_ref|data-anchor'
    $leaks = @(Get-ChildItem -LiteralPath $outputPath -Recurse -File -ErrorAction SilentlyContinue | Select-String -Pattern $leakPattern -ErrorAction SilentlyContinue)
    foreach ($leak in $leaks) {
        $relative = Resolve-Path -LiteralPath $leak.Path -Relative
        $errors.Add("人读产物泄漏机读字段：${relative}:$($leak.LineNumber)") | Out-Null
    }
}
Add-Checked $checked 'output-machine-field-leak'

$htmlMarkerPattern = 'data-anno=["'']([^"'']+)["'']|showAnno\(["'']([^"'']+)["'']'
$htmlMarkers = New-Object System.Collections.Generic.HashSet[string]
foreach ($path in $prototypePaths) {
    if ($path -notmatch '\.html?$') { continue }
    $resolved = Resolve-ProjectPath -ProjectRoot $projectRoot -Path $path
    if (-not (Test-Path -LiteralPath $resolved)) { continue }
    $content = Read-Utf8Text -Path $resolved
    foreach ($match in [regex]::Matches($content, $htmlMarkerPattern)) {
        $marker = if (HasText $match.Groups[1].Value) { $match.Groups[1].Value } else { $match.Groups[2].Value }
        if (HasText $marker) { $htmlMarkers.Add($marker) | Out-Null }
    }
}

if ($htmlMarkers.Count -gt 0 -and $manifestMarkers.Count -gt 0) {
    foreach ($marker in $manifestMarkers) {
        if (-not $htmlMarkers.Contains($marker)) {
            $warnings.Add("manifest 中的原型标注未在 HTML 中找到：$marker") | Out-Null
        }
    }
}
elseif ($htmlMarkers.Count -gt 0 -and $manifestMarkers.Count -eq 0) {
    $warnings.Add('HTML 中存在标注，但 manifest 未提供 prototype_locator.marker；当前仅提示，不阻断') | Out-Null
}
Add-Checked $checked 'prototype-marker-mapping'

Emit-Result -Errors $errors -Warnings $warnings -Checked $checked -Summary $summary
