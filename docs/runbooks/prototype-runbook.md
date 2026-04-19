# Prototype Runbook

## Goal

Run `omp-deliver-prototype` as a complete chain:

1. Check the formal delivery gate
2. Produce the delivery prototype baseline
3. Write prototype baseline and artifact state

## Steps

### 1. Gate check

```powershell
powershell -File .\scripts\stage-gate.ps1 -Gate omp-deliver
```

### 2. Apply prototype status

```powershell
powershell -File .\scripts\status-apply.ps1 -PayloadPath .\docs\examples\prototype-status.sample.json
```

Expected result:

- `stable_baselines.prototype` is recorded
- `latest_artifacts.prototypes` contains the current prototype artifact
