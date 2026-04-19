---
name: omp-preflight
description: "正式交付前检查。判断当前方案是否满足进入正式交付的门槛。"
---

# Preflight

## 读取顺序

1. `docs/project-status.json`
2. `docs/project-memory.md`
3. `contracts/gates.md`
4. `contracts/review.md`

## 目标

- 检查目标闭合
- 检查主流程闭合
- 检查模块闭合
- 检查关键未澄清项是否仍会推翻方案
- 检查预估是否可讲清
- 检查正式表达路径是否明确

## 执行顺序

1. 检查正式交付门禁
2. 按六项闭合条件逐项判断
3. 形成通过或回退结论
4. 产出状态载荷和记忆载荷
5. 调用 `scripts/status-apply.ps1`
6. 调用 `scripts/memory-apply.ps1`

## 必读状态

- `stable_baselines.response_plan`
- `loop_state.round_result`
- `loop_state.history_summary`
- `fallback_state`
- `pending_confirmations`
- `blockers`
- `review_state.must_fix_before_next_stage`
- `context_summary`

## 结果

- 通过：允许进入正式交付
- 不通过：回退回应/校验循环

## 强制规则

- 进入 `omp-preflight` 前，`loop_state.round_result` 必须是 `ready_for_preflight`
- 若正式交付门禁失败，必须给出明确回退类型：
  - `internal_repair`
  - `need_materials`
  - `reopen_alignment`
- `reopen_alignment` 是回退动作，不是轮次结果值
- 若判定为 `reopen_alignment`，下一步应回到 `omp-align` 并在重新进入正式对齐时递增轮次编号
- 进入正式交付前，建议补一次轮次历史摘要，便于评审会和后续交接快速回顾
- 若 `pending_confirmations` 仍非空，必须先转入 `omp-ask-back`，不得静默进入 preflight
- 输出最后必须只给一个“下一步唯一动作”

## 阻断条件

- `pending_confirmations` 未清空
- `blockers` 未清空
- `stable_baselines.response_plan` 缺失
- `review_state.must_fix_before_next_stage` 未清空

## 建议脚本

- `scripts/status-apply.ps1`
- `scripts/memory-apply.ps1`

## 回写要求

- 更新 `docs/project-memory.md` 中的：
  - `当前建议`
  - `评审摘要` 或交付前检查摘要
- 更新 `docs/project-status.json` 中的：
  - `current_stage`
  - `last_action`
  - `next_recommended`
  - 必要时 `fallback_state.fallback_type`
  - 必要时 `fallback_state.fallback_reason`
  - 必要时 `blockers`
  - 必要时 `pending_confirmations`
