# 使用说明

## 1. 初始化

### 1.1 安装

在 OhMyPm 仓库中执行：

```powershell
powershell -File .\installers\install.ps1
```

### 1.2 激活项目

在目标项目根目录执行：

```powershell
powershell -File <OHMYPM_PATH>\scripts\init-project.ps1
```

当项目根目录存在以下文件时，OhMyPm 激活：

- `docs/project-status.json`
- `docs/project-memory.md`

### 1.3 入口

主入口：

- `/ompgo`

常用短命令：

- `/omprespond`
- `/ompalign`
- `/omppreflight`
- `/ompprototype`
- `/ompprd`
- `/ompreview`
- `/ompchange`
- `/ompfix`

## 2. 回应与对齐

### 2.1 首轮回应

进入 `omp-respond` 前，先读取：

- `docs/project-status.json`
- `docs/project-memory.md`
- `contracts/gates.md`
- `contracts/context-guard.md`

要求输出：

- 当前理解
- 当前版本方案
- 未确认事实
- 未澄清问题
- 模块级粗估

### 2.2 多轮对齐

进入 `omp-align` 后：

- 更新本轮变化点
- 更新模块清单
- 更新粗估和排期影响
- 判断是否进入 `omp-preflight`

轮次状态建议同步写入：

- `RoundNumber`
- `RoundGoal`
- `RoundInputsJson`
- `CurrentOutput`
- `RoundResult`
- `LoopHistorySummary`

推荐使用稳定枚举值：

- `continue_alignment`
- `need_materials`
- `need_internal_repair`
- `ready_for_preflight`

## 3. 上下文防爆

### 3.1 先做分块计划

```powershell
powershell -File .\scripts\context-plan.ps1 -InputPath .\product-definition.md -OutputKind prd -ExpectedOutputChars 9000
```

### 3.2 长材料先做提取缓存

```powershell
powershell -File .\scripts\material-extract.ps1 -InputPath .\product-definition.md
```

缓存默认写到：

- `docs/cache/material-extract.md`

## 4. 评审会

### 4.1 生成评审团输出

```powershell
powershell -File .\scripts\review-panel.ps1 `
  -FactIssuesJson '[{"role":"dev","issue":"Missing API contract"}]' `
  -RiskIssuesJson '[{"role":"qa","issue":"Acceptance coverage is incomplete"}]' `
  -SuggestionIssuesJson '[{"role":"pm","issue":"Clarify scope note"}]' `
  -Conclusion conditional_pass `
  -NextAction 'Fix blockers and rerun omp-review' `
  -MustFixJson '["Missing API contract","Acceptance coverage is incomplete"]'
```

### 4.2 应用评审结论

将上一步 JSON 保存后执行：

```powershell
powershell -File .\scripts\review-apply.ps1 -ReviewJsonPath .\docs\cache\review-result.json
```

## 5. 下游修正上游

### 5.1 生成复写判定

```powershell
powershell -File .\scripts\overwrite-judge.ps1 `
  -AffectedUpstreamJson '["docs/project-memory.md"]' `
  -ConflictType review_reversal `
  -Severity high `
  -ActionLevel restart_alignment `
  -WritebackTargetsJson '["stable_baselines.response_plan","overwrite_queue"]' `
  -Reason 'Review conclusion reversed a baseline assumption'
```

### 5.2 应用复写判定

将上一步 JSON 保存后执行：

```powershell
powershell -File .\scripts\overwrite-apply.ps1 -JudgeJsonPath .\docs\cache\overwrite-result.json
```

## 6. 状态同步

统一状态同步入口：

```powershell
powershell -File .\scripts\artifact-sync.ps1 `
  -Stage 'omp-review' `
  -Mode 'alignment_loop' `
  -Version 'v0.3' `
  -LastAction 'Validated review runtime chain' `
  -NextRecommended 'Run omp-review-panel'
```

## 6.1 回退与变更分类

门禁不通过时，建议同步写入：

- `FallbackType`
- `FallbackReason`

推荐使用稳定枚举值：

- `internal_repair`
- `need_materials`
- `reopen_alignment`

变更门禁分类时，建议同步写入：

- `ChangeCategory`
- `ChangeCategoryConfirmedByPm`

推荐使用稳定枚举值：

- `minor_patch`
- `within_module`
- `new_module`
- `structural_change`

## 7. 示例文件

可直接参考：

- `docs/examples/review-result.sample.json`
- `docs/examples/overwrite-result.sample.json`
- `docs/examples/context-plan.sample.json`
- `docs/examples/fallback-status.sample.json`
- `docs/examples/change-status.sample.json`
