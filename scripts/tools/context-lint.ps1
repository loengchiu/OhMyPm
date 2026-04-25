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

function Emit-Result {
    param(
        [System.Collections.Generic.List[string]]$Errors,
        [System.Collections.Generic.List[string]]$Warnings,
        [System.Collections.Generic.List[string]]$Checked
    )

    $result = if ($Errors.Count -gt 0) { 'fail' } elseif ($Warnings.Count -gt 0) { 'warn' } else { 'pass' }
    $payload = [ordered]@{
        tool = 'context-lint'
        result = $result
        errors = @($Errors)
        warnings = @($Warnings)
        checked = @($Checked)
    }

    $payload | ConvertTo-Json -Depth 8
    if ($Errors.Count -gt 0) { exit 1 }
}

$errors = New-List
$warnings = New-List
$checked = New-List

if (-not (Test-Path -LiteralPath $StatusPath)) {
    $errors.Add("状态文件不存在：$StatusPath") | Out-Null
    Emit-Result -Errors $errors -Warnings $warnings -Checked $checked
}

$resolvedStatusPath = (Resolve-Path -LiteralPath $StatusPath).Path
$projectRoot = Get-ProjectRoot -ResolvedStatusPath $resolvedStatusPath

try {
    $status = Read-Utf8Json -Path $resolvedStatusPath
}
catch {
    $errors.Add("状态文件不是合法 UTF-8 JSON：$StatusPath") | Out-Null
    Emit-Result -Errors $errors -Warnings $warnings -Checked $checked
}

Add-Checked $checked 'status-json-readable'

if (-not (HasProperty $status 'context_package')) {
    $errors.Add('缺少 context_package') | Out-Null
    Emit-Result -Errors $errors -Warnings $warnings -Checked $checked
}

$package = $status.context_package
Add-Checked $checked 'context_package-present'

if (-not (HasText $package.request_summary)) {
    $errors.Add('context_package.request_summary 为空') | Out-Null
}
Add-Checked $checked 'request_summary'

$allowedShapes = @('iteration', 'new_build', 'hybrid', '暂不能判断')
if (-not (HasProperty $package 'solution_shape')) {
    $errors.Add('context_package.solution_shape 字段缺失') | Out-Null
}
elseif (-not (HasText $package.solution_shape)) {
    $errors.Add('context_package.solution_shape 为空') | Out-Null
}
elseif ($allowedShapes -notcontains $package.solution_shape.ToString()) {
    $errors.Add("context_package.solution_shape 非法：$($package.solution_shape)") | Out-Null
}
Add-Checked $checked 'solution_shape'

if (-not (HasText $package.business_stage)) {
    $errors.Add('context_package.business_stage 为空') | Out-Null
}
Add-Checked $checked 'business_stage'

foreach ($field in @('system_or_page_clues', 'material_paths', 'context_gaps')) {
    if (-not (HasProperty $package $field)) {
        $errors.Add("context_package.$field 字段缺失") | Out-Null
    }
    Add-Checked $checked "context_package.$field"
}

if (HasProperty $package 'material_paths') {
    $materialPaths = @($package.material_paths | Where-Object { HasText $_ })
    if ($materialPaths.Count -eq 0) {
        $warnings.Add('context_package.material_paths 为空；允许继续，但后续不得伪装已有资料依据') | Out-Null
    }

    foreach ($item in $materialPaths) {
        $resolved = Resolve-ProjectPath -ProjectRoot $projectRoot -Path $item.ToString()
        if (-not (Test-Path -LiteralPath $resolved)) {
            $warnings.Add("资料路径不可访问：$item") | Out-Null
        }
    }
    Add-Checked $checked 'material_paths-accessibility'
}

if (HasProperty $package 'context_gaps') {
    $gaps = @($package.context_gaps | Where-Object { HasText $_ })
    if ($gaps.Count -eq 0) {
        $warnings.Add('context_package.context_gaps 为空；如仍有影响推进的缺口，应显式记录') | Out-Null
    }
    Add-Checked $checked 'context_gaps'
}

if (HasProperty $status 'anchors_state' -and HasProperty $status.anchors_state 'meta') {
    $meta = $status.anchors_state.meta

    $confirmedFacts = if (HasProperty $meta 'confirmed_facts') { @($meta.confirmed_facts | Where-Object { HasText $_ }) } else { @() }
    foreach ($fact in $confirmedFacts) {
        if ($fact.ToString() -match '未确认|待确认|待澄清|不确定|可能|疑似|open question|pending confirmation') {
            $errors.Add("confirmed_facts 混入未确认口径：$fact") | Out-Null
        }
    }
    Add-Checked $checked 'confirmed_facts-boundary'

    $openQuestions = if (HasProperty $meta 'open_questions') { @($meta.open_questions | Where-Object { HasText $_ }) } else { @() }
    if ($openQuestions.Count -gt 0 -and (HasProperty $meta 'can_progress') -and [bool]$meta.can_progress) {
        $errors.Add('open_questions 非空但 anchors_state.meta.can_progress=true') | Out-Null
    }
    Add-Checked $checked 'open_questions-can_progress'
}
else {
    $warnings.Add('anchors_state.meta 缺失；context-lint 仅完成上下文包检查') | Out-Null
}

Emit-Result -Errors $errors -Warnings $warnings -Checked $checked
