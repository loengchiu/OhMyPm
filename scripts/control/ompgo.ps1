param(
    [string]$IntentText = "",
    [ValidateSet("", "omp-intake", "omp-respond", "omp-ask-back", "omp-align", "omp-preflight", "omp-deliver-prototype", "omp-deliver-prd", "omp-review", "omp-change", "omp-fix")]
    [string]$ForceSkill = "",
    [string]$StatusPath = "docs/ohmypm/ohmypm-status.json",
    [string]$MemoryPath = "docs/ohmypm/ohmypm-memory.md",
    [switch]$AsJson
)

function Fail {
    param([string]$Message)
    Write-Error "[OhMyPm] $Message"
    exit 1
}

function Read-Json {
    param([string]$Path)
    return Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
}

function HasText {
    param([object]$Value)
    return ($null -ne $Value -and $Value.ToString().Trim().Length -gt 0)
}

function Get-ScenarioMode {
    param([object]$Status)

    if ($null -ne $Status.scenario_mode -and $Status.scenario_mode.ToString().Trim().Length -gt 0) {
        return $Status.scenario_mode.ToString().Trim().ToLowerInvariant()
    }

    if ($null -ne $Status.collaboration_context -and
        $null -ne $Status.collaboration_context.scenario_mode -and
        $Status.collaboration_context.scenario_mode.ToString().Trim().Length -gt 0) {
        return $Status.collaboration_context.scenario_mode.ToString().Trim().ToLowerInvariant()
    }

    return "real_project"
}

function Resolve-Skill {
    param(
        [string]$ForceSkill,
        [string]$IntentText,
        [object]$Status
    )

    if (HasText $ForceSkill) {
        return $ForceSkill
    }

    $text = $IntentText.Trim().ToLowerInvariant()
    if ($text -match "评审|review") { return "omp-review" }
    if ($text -match "变更|change") { return "omp-change" }
    if ($text -match "修正|fix") { return "omp-fix" }
    if ($text -match "原型|prototype") { return "omp-deliver-prototype" }
    if ($text -match "prd") { return "omp-deliver-prd" }
    if ($text -match "预检|preflight|交付前检查|检查能不能进正式交付") { return "omp-preflight" }
    if ($text -match "追问|ask-back|确认的点|唯一问题") { return "omp-ask-back" }
    if ($text -match "对齐|调整|继续") {
        if ($Status.current_mode -eq "alignment_loop" -or $Status.current_stage -eq "omp-align") {
            return "omp-align"
        }
    }
    if ($text -match "回应|需求|先看|先帮我") { return "omp-respond" }

    if ($Status.current_stage -eq "omp-preflight") { return "omp-preflight" }
    if ($Status.current_stage -eq "omp-review") { return "omp-review" }
    if ($Status.current_mode -eq "alignment_loop") { return "omp-align" }
    return "omp-respond"
}

function Get-ActionName {
    param([string]$Skill)

    switch ($Skill) {
        "omp-intake" { return "接收需求" }
        "omp-respond" { return "生成回应稿" }
        "omp-ask-back" { return "提唯一问题" }
        "omp-align" { return "继续对齐" }
        "omp-preflight" { return "交付前检查" }
        "omp-deliver-prototype" { return "生成原型" }
        "omp-deliver-prd" { return "生成 PRD" }
        "omp-review" { return "开评审" }
        "omp-change" { return "处理变更" }
        "omp-fix" { return "修正问题" }
        default { return $Skill }
    }
}

function Get-GateName {
    param([string]$Skill)

    switch ($Skill) {
        "omp-respond" { return "omp-respond" }
        "omp-align" { return "omp-align" }
        "omp-preflight" { return "omp-preflight" }
        "omp-deliver-prototype" { return "omp-deliver" }
        "omp-deliver-prd" { return "omp-deliver" }
        "omp-change" { return "omp-change" }
        default { return "" }
    }
}

function Get-RequiredContracts {
    param([string]$Skill)

    switch ($Skill) {
        "omp-respond" { return @("contracts/context-guard.md") }
        "omp-ask-back" { return @("contracts/ask-back.md") }
        "omp-align" { return @("contracts/context-guard.md", "contracts/ask-back.md") }
        "omp-preflight" { return @("contracts/gates.md") }
        "omp-deliver-prototype" { return @("contracts/delivery.md", "contracts/gates.md") }
        "omp-deliver-prd" { return @("contracts/delivery.md", "contracts/gates.md") }
        "omp-review" { return @("contracts/review.md") }
        "omp-change" { return @("contracts/gates.md", "contracts/ask-back.md") }
        "omp-fix" { return @("contracts/overwrite.md") }
        default { return @() }
    }
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptRoot "..\..")
$initScript = Join-Path $scriptRoot "init-project.ps1"
$toolsRoot = Join-Path $repoRoot "scripts\tools"
$statusWrite = Join-Path $toolsRoot "status-write.ps1"
$askBackPlan = Join-Path $toolsRoot "ask-back-plan.ps1"
$stageGate = Join-Path $toolsRoot "stage-gate.ps1"

if (-not (Test-Path -LiteralPath $StatusPath)) {
    & $initScript *> $null
}

if (-not (Test-Path -LiteralPath $StatusPath)) {
    Fail "ohmypm-status.json not found after init."
}

if (-not (Test-Path -LiteralPath $MemoryPath)) {
    Fail "ohmypm-memory.md not found."
}

$status = Read-Json -Path $StatusPath
$skill = Resolve-Skill -ForceSkill $ForceSkill -IntentText $IntentText -Status $status
$actionName = Get-ActionName -Skill $skill
$scenarioMode = Get-ScenarioMode -Status $status
$gateName = Get-GateName -Skill $skill
$contracts = @(Get-RequiredContracts -Skill $skill)
$skillPath = "skills/$skill/SKILL.md"

$nextRecommended = ("现在建议你做的下一步是：进入 '{0}'，并只加载 {1} 与当前动作必要规则。" -f $actionName, $skillPath)
$questionText = $null
$gatePassed = $true
$askBackRequired = $false
$internalRepairRequired = $false

if (HasText $gateName) {
    & $stageGate -Gate $gateName -Path $StatusPath *> $null
    if (-not $?) {
        $gatePassed = $false
        $askBackPlanResult = & $askBackPlan -Path $StatusPath | ConvertFrom-Json
        $askBackRequired = [bool]$askBackPlanResult.ask_back_required
        $internalRepairRequired = [bool]$askBackPlanResult.internal_placeholder_required

        if ($askBackPlanResult.trigger_count -gt 0) {
            $questionText = $askBackPlanResult.triggers[0].minimal_question
        }

        if ($askBackRequired -and (HasText $questionText)) {
            $nextRecommended = ("现在只需要你回答的唯一问题是：{0}" -f $questionText)
        }
        elseif ($internalRepairRequired) {
            $nextRecommended = "现在建议你做的下一步是：先在样例内部补占位值或样例说明，不要把虚拟业务问题抛给 PM。"
        }
        else {
            $nextRecommended = "现在建议你做的下一步是：先完成当前动作缺失条件的内部修正，再重新判断是否可以继续推进。"
        }
    }
}

& $statusWrite `
    -Path $StatusPath `
    -LastAction "Control dispatch -> $actionName" `
    -NextRecommended $nextRecommended *> $null

$result = @{
    ownership = "OhMyPm"
    input = @{
        intent_text = $IntentText
        forced_skill = $ForceSkill
    }
    loading = @{
        entry_layer = @{
            scenario_mode = $scenarioMode
            action = $actionName
        }
        state_layer = @{
            status = $StatusPath
            memory = $MemoryPath
        }
        decision_layer = @{
            skill = $skill
            skill_path = $skillPath
            contracts = $contracts
        }
        delivery_layer = @{
            activated = ($skill -in @("omp-deliver-prototype", "omp-deliver-prd", "omp-review", "omp-fix", "omp-change"))
        }
        archive_layer = @{
            writes = @($StatusPath)
        }
    }
    control = @{
        gate_checked = (HasText $gateName)
        gate_passed = $gatePassed
        ask_back_required = $askBackRequired
        internal_repair_required = $internalRepairRequired
    }
    output = @{
        final_line = $nextRecommended
    }
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 10
}
else {
    Write-Output $nextRecommended
}
