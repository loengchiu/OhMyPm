# Change Runbook

## 目标

把“改需求”收成一个明确闭环：

1. 先记录 AI 初判
2. 需要时向 PM 要最终分类确认
3. 按分类结果决定是继续修、还是重开对齐

## 运行时约束

- `change_state.change_category` 只允许：
  - `minor_patch`
  - `within_module`
  - `new_module`
  - `structural_change`
- `new_module` / `structural_change` 允许先以 `ChangeCategoryConfirmedByPm=false` 进入 `omp-change` 或 `omp-check`
- 但离开 `omp-change` / `omp-check` 进入更重动作前，必须先拿到 PM 确认
- 若 `overwrite_queue` 非空，先走 `omp-fix`，不要带着复写冲突继续做变更归类

## 第 1 步：记录初判状态

```powershell
powershell -File .\scripts\tools\status-write.ps1 `
  -Stage 'omp-change' `
  -Mode 'change_control' `
  -ChangeCategory 'new_module' `
  -ChangeCategoryConfirmedByPm $false `
  -NextRecommended '先向 PM 确认这次新增内容是否需要按独立模块处理。'
```

预期结果：

- 状态停留在 `omp-change`
- `change_state.change_category_confirmed_by_pm=false`
- 后续门禁会阻止系统把这个初判当成最终结论继续推进

## 第 2 步：需要时进入 ask-back

```powershell
powershell -File .\scripts\tools\ask-back-plan.ps1
```

预期结果：

- 若当前缺的是 PM 拍板，输出里会出现 `pm_change_confirmation`
- `ask_back_required=true`

## 第 3 步：应用最终分类结果

轻量变更示例：

```powershell
powershell -File .\scripts\tools\change-apply.ps1 -ChangeJsonPath .\docs\examples\change-apply-minor.sample.json
```

结构变化示例：

```powershell
powershell -File .\scripts\tools\change-apply.ps1 -ChangeJsonPath .\docs\examples\change-apply-structural.sample.json
```

预期结果：

- `minor_patch` / `within_module` -> 回到 `omp-fix`
- `new_module` / `structural_change` -> 回到 `omp-align`
- 若重开对齐：
  - `fallback_state.fallback_type = reopen_alignment`
  - `loop_state.round_result = continue_alignment`

## 第 4 步：验证状态是否正确

```powershell
powershell -File .\scripts\tools\stage-gate.ps1 -Gate 'omp-change'
```

验证重点：

- 是否仍有 `pending_confirmations`
- `new_module` / `structural_change` 是否已被 PM 确认
- 是否已有正式基线可作为变更判断参照
