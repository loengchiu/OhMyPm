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
powershell -File .\scripts\tools\overwrite-judge.ps1 `
  -AffectedUpstreamJson '[".ohmypm/memory.md"]' `
  -ConflictType review_reversal `
  -Severity high `
  -ActionLevel restart_alignment `
  -WritebackTargetsJson '["stable_baselines.response_plan","overwrite_queue"]' `
  -Reason 'Review conclusion reversed a baseline assumption'
```

### 3. 应用复写判定

```powershell
powershell -File .\scripts\tools\overwrite-apply.ps1 -JudgeJsonPath .\docs\ohmypm\cache\overwrite-result.json
```

### 4. 更新项目记忆

```powershell
powershell -File .\scripts\tools\memory-apply.ps1 -PayloadPath .\docs\examples\fix-memory.sample.json
```

注意：

- 若复写结果为 `restart_alignment`，下一步必须返回对齐链
- 不得继续假装处于已稳定的正式交付阶段
- 当前脚本会同步把：
  - `current_stage` 切到 `omp-align`
  - `current_mode` 切到 `alignment_loop`
  - `fallback_type` 写成 `reopen_alignment`
  - `loop_state.round_result` 改回 `continue_alignment`

