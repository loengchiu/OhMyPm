# Preflight Runbook

## Goal

Run `omp-preflight` as a complete chain:

1. Check the formal delivery gate
2. Verify the six closure conditions
3. Apply status and memory updates

## Steps

### 1. Gate check

```powershell
powershell -File .\scripts\stage-gate.ps1 -Gate omp-preflight
```

### 2. Apply preflight status

```powershell
powershell -File .\scripts\status-apply.ps1 -PayloadPath .\docs\examples\preflight-status.sample.json
```

如果 preflight 未通过，应补写：

- `FallbackType`
- `FallbackReason`

### 3. Apply preflight memory

```powershell
powershell -File .\scripts\memory-apply.ps1 -PayloadPath .\docs\examples\preflight-memory.sample.json
```
