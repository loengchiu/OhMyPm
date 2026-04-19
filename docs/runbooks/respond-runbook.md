# Respond Runbook

## Goal

Run `omp-respond` as a complete chain:

1. Check the response gate
2. Assess context risk
3. Produce the first credible response draft
4. Apply status and memory updates

## Steps

### 1. Check context risk

```powershell
powershell -File .\scripts\context-plan.ps1 -InputPath .\product-definition.md -OutputKind response -ExpectedOutputChars 2500
```

### 2. If needed, extract long material

```powershell
powershell -File .\scripts\material-extract.ps1 -InputPath .\product-definition.md
```

### 3. Apply response status

```powershell
powershell -File .\scripts\status-apply.ps1 -PayloadPath .\docs\examples\respond-status.sample.json
```

其中建议同步写入：

- `RoundNumber`
- `RoundGoal`
- `RoundInputsJson`
- `CurrentOutput`
- `RoundResult`

### 4. Apply response memory

```powershell
powershell -File .\scripts\memory-apply.ps1 -PayloadPath .\docs\examples\respond-memory.sample.json
```
