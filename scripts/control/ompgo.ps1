param(
    [string]$IntentText = "",
    [ValidateSet("", "omp-listen", "omp-reply", "omp-check", "omp-align", "omp-ready", "omp-proto", "omp-prd", "omp-review", "omp-change", "omp-fix")]
    [string]$ForceSkill = "",
    [string]$StatusPath = ".ohmypm/status.json",
    [string]$MemoryPath = ".ohmypm/memory.md",
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

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptRoot "..\..")
$initScript = Join-Path $scriptRoot "init-project.ps1"
$toolsRoot = Join-Path $repoRoot "scripts\tools"
$statusWrite = Join-Path $toolsRoot "status-write.ps1"
$askBackPlan = Join-Path $toolsRoot "ask-back-plan.ps1"
$stageGate = Join-Path $toolsRoot "stage-gate.ps1"
$stateMachine = Join-Path $toolsRoot "state-machine.ps1"
$routeResolve = Join-Path $toolsRoot "route-resolve.ps1"

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
$state = & $stateMachine -Path $StatusPath | ConvertFrom-Json
$route = & $routeResolve -IntentText $IntentText -ForceSkill $ForceSkill -StatusPath $StatusPath | ConvertFrom-Json

$skill = $route.skill
$actionName = $route.action_name
$scenarioMode = $route.scenario_mode
$gateName = $route.gate_name
$contracts = @($route.required_contracts)
$skillPath = $route.skill_path

$nextRecommended = ("现在建议你做的下一步是：进入 {0}，并只加载 {1} 与当前动作必要规则。" -f $actionName, $skillPath)
$questionText = $null
$gatePassed = $true
$askBackRequired = $false
$internalRepairRequired = $false

if ($null -ne $gateName -and $gateName.ToString().Trim().Length -gt 0) {
    & $stageGate -Gate $gateName -Path $StatusPath *> $null
    if (-not $?) {
        $gatePassed = $false
        $askBackPlanResult = & $askBackPlan -Path $StatusPath | ConvertFrom-Json
        $askBackRequired = [bool]$askBackPlanResult.ask_back_required
        $internalRepairRequired = [bool]$askBackPlanResult.internal_placeholder_required

        if ($askBackPlanResult.trigger_count -gt 0) {
            $questionText = $askBackPlanResult.triggers[0].minimal_question
        }

        if ($askBackRequired -and $null -ne $questionText -and $questionText.ToString().Trim().Length -gt 0) {
            $nextRecommended = ("现在只需要你回答的唯一问题是：{0}" -f $questionText)
        }
        elseif ($internalRepairRequired) {
            $nextRecommended = "现在建议你做的下一步是：先在内部补齐占位值或样例说明，不要把虚拟业务问题抛给 PM。"
        }
        else {
            $nextRecommended = "现在建议你做的下一步是：先补齐当前动作缺失条件，再重新判断是否可以继续推进。"
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
    state_machine = $state
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
            activated = [bool]$route.delivery_layer_activated
        }
        archive_layer = @{
            writes = @($StatusPath)
        }
    }
    control = @{
        gate_checked = ($null -ne $gateName -and $gateName.ToString().Trim().Length -gt 0)
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

