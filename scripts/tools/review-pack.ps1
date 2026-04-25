param(
    [string]$StatusPath = '.ohmypm/status.json',
    [string]$OutputPath = '.ohmypm/review/review-pack.json'
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptRoot 'encoding.ps1')

function HasText {
    param([object]$Value)
    return ($null -ne $Value -and $Value.ToString().Trim().Length -gt 0)
}

function HasProperty {
    param([object]$Object, [string]$Name)
    return ($null -ne $Object -and $null -ne $Object.PSObject.Properties[$Name])
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

function Invoke-Lint {
    param(
        [string]$ScriptPath,
        [string]$StatusPath
    )

    $exe = (Get-Process -Id $PID).Path
    $arguments = @('-NoProfile', '-File', $ScriptPath, '-StatusPath', $StatusPath)
    $output = & $exe @arguments 2>&1
    $exitCode = $LASTEXITCODE
    $raw = ($output | Out-String).Trim()

    try {
        $json = $raw | ConvertFrom-Json
        return [ordered]@{
            exit_code = $exitCode
            parsed = $json
            raw = $raw
        }
    }
    catch {
        return [ordered]@{
            exit_code = $exitCode
            parsed = $null
            raw = $raw
        }
    }
}

function Summarize-Manifest {
    param([object]$Manifest)

    $modules = @($Manifest.modules)
    $pages = 0
    $actions = 0
    $moduleNames = @()

    foreach ($module in $modules) {
        if (HasText $module.module_name) { $moduleNames += $module.module_name.ToString() }
        foreach ($page in @($module.pages)) {
            $pages++
            $actions += @($page.actions).Count
        }
    }

    return [ordered]@{
        module_count = $modules.Count
        page_count = $pages
        action_count = $actions
        module_names = @($moduleNames)
    }
}

if (-not (Test-Path -LiteralPath $StatusPath)) {
    Write-Error "[OhMyPm] 状态文件不存在：$StatusPath"
    exit 1
}

$resolvedStatusPath = (Resolve-Path -LiteralPath $StatusPath).Path
$projectRoot = Get-ProjectRoot -ResolvedStatusPath $resolvedStatusPath
$status = Read-Utf8Json -Path $resolvedStatusPath

$contextLintPath = Join-Path $scriptRoot 'context-lint.ps1'
$traceLintPath = Join-Path $scriptRoot 'trace-lint.ps1'
$contextLint = Invoke-Lint -ScriptPath $contextLintPath -StatusPath $resolvedStatusPath
$traceLint = Invoke-Lint -ScriptPath $traceLintPath -StatusPath $resolvedStatusPath

$manifestSummary = [ordered]@{
    module_count = 0
    page_count = 0
    action_count = 0
    module_names = @()
}

if (HasProperty $status 'anchors_state' -and HasProperty $status.anchors_state 'meta' -and HasText $status.anchors_state.meta.anchor_manifest) {
    $manifestPath = Resolve-ProjectPath -ProjectRoot $projectRoot -Path $status.anchors_state.meta.anchor_manifest.ToString()
    if (Test-Path -LiteralPath $manifestPath) {
        try {
            $manifestSummary = Summarize-Manifest -Manifest (Read-Utf8Json -Path $manifestPath)
        }
        catch {
            $manifestSummary = [ordered]@{
                error = 'manifest 无法解析'
            }
        }
    }
}

$pack = [ordered]@{
    generated_at = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    project_root = $projectRoot
    status_summary = [ordered]@{
        current_stage = $status.current_stage
        current_mode = $status.current_mode
        current_version = $status.current_version
        next_recommended = $status.next_recommended
        blockers = @($status.blockers)
        pending_confirmations = @($status.pending_confirmations)
    }
    baselines = $status.baselines
    artifacts = [ordered]@{
        prototypes = if (HasProperty $status 'artifacts' -and HasProperty $status.artifacts 'prototypes') { @($status.artifacts.prototypes) } else { @() }
        prd = if (HasProperty $status 'artifacts') { $status.artifacts.prd } else { '' }
        review_records = if (HasProperty $status 'artifacts' -and HasProperty $status.artifacts 'review_records') { @($status.artifacts.review_records) } else { @() }
    }
    traceability = [ordered]@{
        anchor_manifest = if (HasProperty $status 'anchors_state' -and HasProperty $status.anchors_state 'meta') { $status.anchors_state.meta.anchor_manifest } else { '' }
        manifest_summary = $manifestSummary
    }
    lint_results = [ordered]@{
        context_lint = $contextLint
        trace_lint = $traceLint
    }
    review_inputs = [ordered]@{
        use_this_pack_only = $true
        instruction = '评审时基于本冷启动包、PRD、原型和 manifest 重新判断，不沿用 writer 长上下文惯性。'
    }
}

$resolvedOutputPath = Resolve-ProjectPath -ProjectRoot $projectRoot -Path $OutputPath
$outputDir = Split-Path -Parent $resolvedOutputPath
if (-not (Test-Path -LiteralPath $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$json = $pack | ConvertTo-Json -Depth 20
Write-Utf8BomText -Path $resolvedOutputPath -Content $json

[ordered]@{
    tool = 'review-pack'
    result = 'pass'
    output_path = $OutputPath
    context_lint_result = if ($contextLint.parsed) { $contextLint.parsed.result } else { 'unparsed' }
    trace_lint_result = if ($traceLint.parsed) { $traceLint.parsed.result } else { 'unparsed' }
} | ConvertTo-Json -Depth 5
