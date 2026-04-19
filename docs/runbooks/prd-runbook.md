# PRD Runbook

## Goal

Run `omp-deliver-prd` as a complete chain:

1. Check the formal delivery gate
2. Produce the formal PRD baseline
3. Write PRD baseline and artifact state

## Steps

### 1. Gate check

```powershell
powershell -File .\scripts\stage-gate.ps1 -Gate omp-deliver
```

### 2. Apply PRD status

```powershell
powershell -File .\scripts\status-apply.ps1 -PayloadPath .\docs\examples\prd-status.sample.json
```

Expected result:

- `stable_baselines.prd` is recorded
- the current PRD artifact is ready to pair with the delivery prototype in review
