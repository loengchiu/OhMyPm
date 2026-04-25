param(
    [Parameter(Mandatory = $true)]
    [string]$PayloadPath
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptRoot 'encoding.ps1')

function Fail {
    param([string]$Message)
    Write-Error "[OhMyPm] $Message"
    exit 1
}

if (-not (Test-Path -LiteralPath $PayloadPath)) {
    Fail "状态载荷文件不存在：$PayloadPath"
}

$payload = Read-Utf8Json -Path $PayloadPath
$artifactSync = Join-Path $scriptRoot 'artifact-sync.ps1'
$forward = @{}

$fieldMap = @{
    Stage = 'Stage'
    Mode = 'Mode'
    Version = 'Version'
    LastAction = 'LastAction'
    NextRecommended = 'NextRecommended'
    ContextSummary = 'ContextSummary'
    ContextPackageJson = 'ContextPackageJson'
    AnchorsStateJson = 'AnchorsStateJson'
    BaselineField = 'BaselineField'
    BaselinePath = 'BaselinePath'
    ArtifactField = 'ArtifactField'
    ArtifactPath = 'ArtifactPath'
    BlockersJson = 'BlockersJson'
    PendingConfirmationsJson = 'PendingConfirmationsJson'
    ReviewResult = 'ReviewResult'
    ReviewMustFixJson = 'ReviewMustFixJson'
    OverwriteQueueJson = 'OverwriteQueueJson'
    SystemMemoryCardsJson = 'SystemMemoryCardsJson'
    RoundNumber = 'RoundNumber'
    RoundGoal = 'RoundGoal'
    RoundInputsJson = 'RoundInputsJson'
    CurrentOutput = 'CurrentOutput'
    RoundResult = 'RoundResult'
    LoopHistorySummary = 'LoopHistorySummary'
    FallbackType = 'FallbackType'
    FallbackReason = 'FallbackReason'
    ChangeCategory = 'ChangeCategory'
    ChangeCategoryConfirmedByPm = 'ChangeCategoryConfirmedByPm'
}

foreach ($entry in $fieldMap.GetEnumerator()) {
    $prop = $payload.PSObject.Properties.Match($entry.Key) | Select-Object -First 1
    if ($null -ne $prop) {
        $forward[$entry.Value] = $prop.Value
    }
}

& $artifactSync @forward
