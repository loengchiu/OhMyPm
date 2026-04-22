param(
    [string]$Stage,
    [string]$Mode,
    [string]$Version,
    [string]$LastAction,
    [string]$NextRecommended,
    [string]$ContextSummary,
    [string]$ContextPackageJson,
    [string]$TraceabilityJson,
    [string]$BaselineField,
    [string]$BaselinePath,
    [string]$ArtifactField,
    [string]$ArtifactPath,
    [string]$BlockersJson,
    [string]$PendingConfirmationsJson,
    [string]$ReviewResult,
    [string]$ReviewMustFixJson,
    [string]$OverwriteQueueJson,
    [string]$SystemMemoryCardsJson,
    [int]$RoundNumber,
    [string]$RoundGoal,
    [string]$RoundInputsJson,
    [string]$CurrentOutput,
    [string]$RoundResult,
    [string]$LoopHistorySummary,
    [string]$FallbackType,
    [string]$FallbackReason,
    [string]$ChangeCategory,
    [bool]$ChangeCategoryConfirmedByPm
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$statusWrite = Join-Path $scriptRoot 'status-write.ps1'
$forward = @{}

foreach ($key in $PSBoundParameters.Keys) {
    if ($key -ne 'Path') {
        $forward[$key] = $PSBoundParameters[$key]
    }
}

& $statusWrite @forward
