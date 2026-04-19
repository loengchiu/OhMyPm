# Fix Runbook

## 目标

把 `omp-fix` 执行成一条完整链：

1. 明确修复对象
2. 判定是否影响上游
3. 生成复写判定 JSON
4. 应用到覆盖队列和状态

## 步骤

### 1. 检查前提

- 当前修复对象路径明确
- 版本关系已判清

### 2. 生成复写判定 JSON

```powershell
powershell -File .\scripts\overwrite-judge.ps1 `
  -AffectedUpstreamJson '["docs/project-memory.md"]' `
  -ConflictType review_reversal `
  -Severity high `
  -ActionLevel restart_alignment `
  -WritebackTargetsJson '["stable_baselines.response_plan","overwrite_queue"]' `
  -Reason 'Review conclusion reversed a baseline assumption'
```

### 3. 应用复写判定

```powershell
powershell -File .\scripts\overwrite-apply.ps1 -JudgeJsonPath .\docs\cache\overwrite-result.json
```
