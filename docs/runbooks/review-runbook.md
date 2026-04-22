# Review Runbook

## 目标

把 `omp-review` 执行成一条完整链：

1. 准备评审材料
2. 生成评审团 JSON
3. 应用评审结论到状态文件
4. 回写项目记忆

## 步骤

### 1. 检查前提

- `.ohmypm/status.json` 已存在
- 至少已有可评审版本
- 当前评审对象已判清

建议已有：

- `stable_baselines.prototype`
- `stable_baselines.prd`

### 2. 生成评审团 JSON

```powershell
powershell -File .\scripts\tools\review-panel.ps1 `
  -FactIssuesJson '[{"role":"dev","issue":"Missing API contract"}]' `
  -RiskIssuesJson '[{"role":"qa","issue":"Acceptance coverage is incomplete"}]' `
  -SuggestionIssuesJson '[{"role":"pm","issue":"Clarify scope note"}]' `
  -Conclusion conditional_pass `
  -NextAction 'Fix blockers and rerun omp-review' `
  -MustFixJson '["Missing API contract","Acceptance coverage is incomplete"]'
```

### 3. 应用评审结论

```powershell
powershell -File .\scripts\tools\review-apply.ps1 -ReviewJsonPath .\docs\ohmypm\cache\review-result.json
```

这一步会更新：

- `review_state.last_review_result`
- `review_state.must_fix_before_next_stage`
- `next_recommended`
- 必要时 `current_stage`
- 必要时 `fallback_state`

### 4. 更新项目记忆

```powershell
powershell -File .\scripts\tools\memory-apply.ps1 -PayloadPath .\docs\examples\review-memory.sample.json
```

回写后当前行为固定为：

- `pass`：保留在评审态
- `conditional_pass`：转入 `omp-fix`
- `rework_required`：转入 `omp-fix`
- `defer`：转入 `omp-check`

