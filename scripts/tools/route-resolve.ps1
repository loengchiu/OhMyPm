param(
    [string]$IntentText = "",
    [ValidateSet("", "omp-intake", "omp-respond", "omp-ask-back", "omp-align", "omp-preflight", "omp-deliver-prototype", "omp-deliver-prd", "omp-review", "omp-change", "omp-fix")]
    [string]$ForceSkill = "",
    [string]$StatusPath = "docs/ohmypm/ohmypm-status.json"
)

function Fail {
    param([string]$Message)
    Write-Error "[OhMyPm] $Message"
    exit 1
}

function HasText {
    param([object]$Value)
    return ($null -ne $Value -and $Value.ToString().Trim().Length -gt 0)
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
        "omp-deliver-prototype" { return @("contracts/delivery.md", "contracts/gates.md", "contracts/context-guard.md") }
        "omp-deliver-prd" { return @("contracts/delivery.md", "contracts/gates.md", "contracts/context-guard.md", "contracts/anchors.md") }
        "omp-review" { return @("contracts/review.md") }
        "omp-change" { return @("contracts/gates.md", "contracts/ask-back.md") }
        "omp-fix" { return @("contracts/overwrite.md") }
        default { return @() }
    }
}

function Resolve-ExplicitSkill {
    param(
        [string]$IntentText,
        [string]$PreferredSkill
    )

    $text = $IntentText.Trim().ToLowerInvariant()

    if (-not (HasText $text)) {
        return $PreferredSkill
    }

    if ($text -match "评审|review") { return "omp-review" }
    if ($text -match "变更|change") { return "omp-change" }
    if ($text -match "修正|修复|fix") { return "omp-fix" }
    if ($text -match "原型|prototype") { return "omp-deliver-prototype" }
    if ($text -match "prd") { return "omp-deliver-prd" }
    if ($text -match "预检|preflight|交付前检查|检查能不能进正式交付") { return "omp-preflight" }
    if ($text -match "追问|ask-back|确认的点|唯一问题") { return "omp-ask-back" }
    if ($text -match "对齐|调整") { return "omp-align" }
    if ($text -match "回应|需求|先看|先帮我|新需求") { return "omp-respond" }
    if ($text -match "继续|下一步|继续吧|往下走") { return $PreferredSkill }

    return $PreferredSkill
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$stateMachine = Join-Path $scriptRoot "state-machine.ps1"

if (-not (Test-Path -LiteralPath $StatusPath)) {
    Fail "ohmypm-status.json not found."
}

$state = & $stateMachine -Path $StatusPath | ConvertFrom-Json
$skill = if (HasText $ForceSkill) { $ForceSkill } else { Resolve-ExplicitSkill -IntentText $IntentText -PreferredSkill $state.preferred_skill }
$actionName = Get-ActionName -Skill $skill
$gateName = Get-GateName -Skill $skill
$contracts = @(Get-RequiredContracts -Skill $skill)

$result = [ordered]@{
    scenario_mode = $state.scenario_mode
    current_node = $state.current_node
    preferred_skill = $state.preferred_skill
    skill = $skill
    skill_path = "skills/$skill/SKILL.md"
    action_name = $actionName
    gate_name = $gateName
    required_contracts = $contracts
    delivery_layer_activated = ($skill -in @("omp-deliver-prototype", "omp-deliver-prd", "omp-review", "omp-fix", "omp-change"))
    allowed_skills = @($state.allowed_skills)
}

$result | ConvertTo-Json -Depth 10
