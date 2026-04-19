# Review Runbook

## 目标

把 `omp-review` 执行成一条完整链：

1. 准备评审材料
2. 生成评审团 JSON
3. 应用评审结论到状态文件
4. 回写项目记忆

## 步骤

### 1. 检查前提

- `docs/project-status.json` 已存在
- 至少已有可评审版本
- 当前评审对象已判清

### 2. 生成评审团 JSON

```powershell
powershell -File .\scripts\review-panel.ps1 `
  -FactIssuesJson '[{"role":"dev","issue":"Missing API contract"}]' `
  -RiskIssuesJson '[{"role":"qa","issue":"Acceptance coverage is incomplete"}]' `
  -SuggestionIssuesJson '[{"role":"pm","issue":"Clarify scope note"}]' `
  -Conclusion conditional_pass `
  -NextAction 'Fix blockers and rerun omp-review' `
  -MustFixJson '["Missing API contract","Acceptance coverage is incomplete"]'
```

### 3. 应用评审结论

```powershell
powershell -File .\scripts\review-apply.ps1 -ReviewJsonPath .\docs\cache\review-result.json
```

### 4. 更新项目记忆

```powershell
powershell -File .\scripts\memory-apply.ps1 -PayloadPath .\docs\examples\memory-apply.sample.json
```
