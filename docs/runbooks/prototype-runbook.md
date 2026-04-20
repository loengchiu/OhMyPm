# Prototype Runbook

## 目标

把 `omp-deliver-prototype` 执行成一条完整链：

1. 检查正式交付门禁
2. 形成交付型原型基线
3. 回写原型基线和产物状态

## 步骤

### 1. 门禁检查

```powershell
powershell -File .\scripts\tools\stage-gate.ps1 -Gate omp-deliver
```

### 2. 回写原型状态

```powershell
powershell -File .\scripts\tools\status-apply.ps1 -PayloadPath .\docs\examples\prototype-status.sample.json
```

预期结果：

- `stable_baselines.prototype` 已被记录
- `latest_artifacts.prototypes` 包含当前原型产物
