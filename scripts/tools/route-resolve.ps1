param(
    [string]$IntentText = "",
    [ValidateSet("", "omp-listen", "omp-reply", "omp-check", "omp-align", "omp-ready", "omp-proto", "omp-prd", "omp-review", "omp-change", "omp-fix")]
    [string]$ForceSkill = "",
    [string]$StatusPath = ".ohmypm/status.json"
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
        "omp-listen" { return "听需求" }
        "omp-reply" { return "先回应" }
        "omp-check" { return "推进检查" }
        "omp-align" { return "对齐" }
        "omp-ready" { return "开工检查" }
        "omp-proto" { return "做原型" }
        "omp-prd" { return "写 PRD" }
        "omp-review" { return "评审" }
        "omp-change" { return "改需求" }
        "omp-fix" { return "修问题" }
        default { return $Skill }
    }
}

function Get-GateName {
    param([string]$Skill)

    switch ($Skill) {
        "omp-reply" { return "omp-reply" }
        "omp-align" { return "omp-align" }
        "omp-ready" { return "omp-ready" }
        "omp-proto" { return "omp-deliver" }
        "omp-prd" { return "omp-deliver" }
        "omp-change" { return "omp-change" }
        default { return "" }
    }
}

function Get-RequiredContracts {
    param([string]$Skill)

    switch ($Skill) {
        "omp-listen" { return @("contracts/gates.md", "contracts/context-guard.md", "contracts/context-package.md", "contracts/traceability.md") }
        "omp-reply" { return @("contracts/context-guard.md", "contracts/context-package.md", "contracts/traceability.md", "contracts/boundary-guard.md") }
        "omp-check" { return @("contracts/gates.md", "contracts/checkpoint.md", "contracts/ask-back.md", "contracts/context-package.md", "contracts/boundary-guard.md") }
        "omp-align" { return @("contracts/context-guard.md", "contracts/ask-back.md", "contracts/boundary-guard.md") }
        "omp-ready" { return @("contracts/gates.md", "contracts/checkpoint.md", "contracts/traceability.md", "contracts/delivery.md", "contracts/boundary-guard.md") }
        "omp-proto" { return @("contracts/delivery.md", "contracts/gates.md", "contracts/context-guard.md", "contracts/boundary-guard.md", "contracts/traceability.md") }
        "omp-prd" { return @("contracts/delivery.md", "contracts/gates.md", "contracts/context-guard.md", "contracts/anchors.md", "contracts/traceability.md", "contracts/boundary-guard.md") }
        "omp-review" { return @("contracts/review.md", "contracts/traceability.md", "contracts/boundary-guard.md") }
        "omp-change" { return @("contracts/gates.md", "contracts/ask-back.md", "contracts/boundary-guard.md", "contracts/overwrite.md") }
        "omp-fix" { return @("contracts/overwrite.md", "contracts/boundary-guard.md", "contracts/traceability.md") }
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

    if ($text -match "听需求|listen|初始化") { return "omp-listen" }
    if ($text -match "评审|review") { return "omp-review" }
    if ($text -match "改需求|需求变更|变更分类|变更处理|change") { return "omp-change" }
    if ($text -match "修问题|修正|修复|修复问题|处理问题|fix") { return "omp-fix" }
    if ($text -match "做原型|原型|proto|prototype") { return "omp-proto" }
    if ($text -match "prd") { return "omp-prd" }
    if ($text -match "开工检查|预检|preflight|开工检查|检查能不能进正式交付") { return "omp-ready" }
    if ($text -match "推进检查|追问|ask-back|确认的点|唯一问题") { return "omp-check" }
    if ($text -match "对齐|调整") { return "omp-align" }
    if ($text -match "先回应|回应|回个话|回话|reply|需求|先看|先帮我|新需求") { return "omp-reply" }
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
    delivery_layer_activated = ($skill -in @("omp-proto", "omp-prd", "omp-review", "omp-fix", "omp-change"))
    allowed_skills = @($state.allowed_skills)
}

$result | ConvertTo-Json -Depth 10

