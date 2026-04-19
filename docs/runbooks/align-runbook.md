# Align Runbook

## Goal

Run `omp-align` as a complete chain:

1. Merge new feedback into facts and modules
2. Update change points, estimate, and schedule impact
3. Apply status and memory updates

## Steps

### 1. Apply alignment status

```powershell
powershell -File .\scripts\status-apply.ps1 -PayloadPath .\docs\examples\align-status.sample.json
```

如果当前轮次未能直接进入下一步，还应同步写入：

- `FallbackType`
- `FallbackReason`

### 2. Apply alignment memory

```powershell
powershell -File .\scripts\memory-apply.ps1 -PayloadPath .\docs\examples\align-memory.sample.json
```
