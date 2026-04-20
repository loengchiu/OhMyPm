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

- `docs/ohmypm/ohmypm-status.json`
- `docs/ohmypm/ohmypm-memory.md`

### 1.3 入口

默认主入口：

- 自然语言

默认交互方式：

- 用户只需要直接说需求或下一步
- 系统先自动判断当前意图，再进入对应动作
- 用户不需要自己判断现在该敲哪个命令

系统必须先自动判断当前意图属于：

- respond
- align
- ask-back
- preflight
- deliver prototype
- deliver prd
- review
- change
- fix

短命令只保留为：

- 调试入口
- 强制指定入口
- 高级用户入口

可用短命令：

- `/ompgo`
- `/omprespond`
- `/ompaskback`
- `/ompalign`
- `/omppreflight`
- `/ompprototype`
- `/ompprd`
- `/ompreview`
- `/ompchange`
- `/ompfix`

### 1.3.1 分层加载

运行时默认按以下顺序加载，详细规则见 `contracts/loading.md`：

1. 第 0 层：只读 `docs/ohmypm/ohmypm-status.json` 和 `docs/ohmypm/ohmypm-memory.md` 的最小必要摘要
2. 第 1 层：只按当前自然语言意图读取一个 skill
3. 第 2 层：只读当前动作必须的 contract
4. 第 3 层：外部知识和长材料只做局部回查
5. 第 4 层：长文生成后只保留摘要、索引和稳定路径

禁止：

- 默认把多个 skill 一起读入
- 为了保险一次读很多 contract
- 整篇整包载入外部知识或长材料

## 1.4 输出收口

每次输出最后，系统必须只给一个“下一步唯一动作”。

形式只能是：

- `现在建议你做的下一步是：...`
- `现在只需要你回答的唯一问题是：...`

不得一次给 PM 一串操作菜单。
不得要求 PM 自己从 runbook 或 usage 里挑下一步。
不得直接把内部状态机术语当作外部提问内容。

## 2. 回应与对齐

### 2.1 首轮回应

进入 `omp-respond` 前，先读取：

- `docs/ohmypm/ohmypm-status.json`
- `docs/ohmypm/ohmypm-memory.md`
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

在范围、结构、表达边界和粗估判断上，优先遵循：

- 当前流程内置的方法论规则

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

- `docs/ohmypm/cache/material-extract.md`

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
powershell -File .\scripts\review-apply.ps1 -ReviewJsonPath .\docs\ohmypm\cache\review-result.json
```

## 5. 下游修正上游

### 5.1 生成复写判定

```powershell
powershell -File .\scripts\overwrite-judge.ps1 `
  -AffectedUpstreamJson '["docs/ohmypm/ohmypm-memory.md"]' `
  -ConflictType review_reversal `
  -Severity high `
  -ActionLevel restart_alignment `
  -WritebackTargetsJson '["stable_baselines.response_plan","overwrite_queue"]' `
  -Reason 'Review conclusion reversed a baseline assumption'
```

### 5.2 应用复写判定

将上一步 JSON 保存后执行：

```powershell
powershell -File .\scripts\overwrite-apply.ps1 -JudgeJsonPath .\docs\ohmypm\cache\overwrite-result.json
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

## 6.2 追问触发与回写

当以下情况出现时，应直接转入 `omp-ask-back`，而不是继续推进：

- `pending_confirmations` 非空且当前动作不是 `internal_repair / need_materials`
- 正式交付前仍有未确认范围或事实
- `change_state.change_category_confirmed_by_pm=false`

生成最小问题：

```powershell
powershell -File .\scripts\ask-back-plan.ps1
```

应用 PM 回答后的状态回写：

```powershell
powershell -File .\scripts\ask-back-apply.ps1 `
  -AnsweredConfirmation 'Need confirmation on scope boundary' `
  -ChangeCategoryConfirmedByPm $true `
  -NextRecommended 'Return to the blocked stage and rerun the gate'
```

## 7. 示例文件

核心规则文件：

- `contracts/gates.md`
- `contracts/ask-back.md`
- `contracts/memory.md`
- `contracts/context-guard.md`
- `contracts/delivery.md`
- `contracts/review.md`
- `contracts/overwrite.md`

可直接参考：

- `docs/examples/review-result.sample.json`
- `docs/examples/overwrite-result.sample.json`
- `docs/examples/context-plan.sample.json`
- `docs/examples/fallback-status.sample.json`
- `docs/examples/change-status.sample.json`
- `docs/examples/change-status-confirmed.sample.json`
- `docs/examples/reopen-alignment.sample.json`
- `docs/examples/prototype-status.sample.json`
- `docs/examples/prd-status.sample.json`
- `docs/examples/review-memory.sample.json`
- `docs/examples/fix-memory.sample.json`

常用流程手册：

- `docs/runbooks/respond-runbook.md`
- `docs/runbooks/ask-back-runbook.md`
- `docs/runbooks/align-runbook.md`
- `docs/runbooks/preflight-runbook.md`
- `docs/runbooks/prototype-runbook.md`
- `docs/runbooks/prd-runbook.md`
- `docs/runbooks/round-state-flow.md`
- `docs/runbooks/demo-flow.md`
- `docs/runbooks/review-runbook.md`
- `docs/runbooks/fix-runbook.md`

快捷验证：

- `powershell -File .\scripts\demo-smoke.ps1`
