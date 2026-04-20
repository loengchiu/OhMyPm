# PRD Runbook

## 目标

把 `omp-deliver-prd` 执行成一条完整链：

1. 检查正式交付门禁
2. 形成正式 PRD 基线
3. 回写 PRD 基线和产物状态

## 步骤

### 1. 门禁检查

```powershell
powershell -File .\scripts\tools\stage-gate.ps1 -Gate omp-deliver
```

### 2. 回写 PRD 状态

```powershell
powershell -File .\scripts\tools\status-apply.ps1 -PayloadPath .\docs\examples\prd-status.sample.json
```

预期结果：

- `stable_baselines.prd` 已被记录
- 当前 PRD 产物已可在评审中与交付型原型配对
