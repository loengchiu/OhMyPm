---
name: omp-align
description: "回应/校验循环中的修正推进。根据反馈更新方案、变化点、模块判断与粗估。"
---

# Align

## 读取顺序

第 0 层：最小状态

1. `docs/ohmypm/ohmypm-status.json`
2. `docs/ohmypm/ohmypm-memory.md` 的最小必要摘要

第 1 层：当前动作 skill

3. 当前只执行 `omp-align`，不得默认并读其他 skill

第 2 层：当前动作必要 contract

4. `contracts/gates.md`
5. `contracts/context-guard.md`

第 3 层：条件触发读取

6. 仅当当前对齐明确依赖系统知识或长材料时，再做局部回查

## 目标

- 根据反馈修正当前理解
- 更新本轮变化点
- 更新模块清单、粗估和排期影响
- 维护轮次结果、回退类型和轮次历史摘要
- 判断是否继续下一轮，或进入 `omp-preflight`

## 执行顺序

1. 检查对齐推进门禁
2. 归并本轮新增内容到事实、模块或变化点
3. 若需要长材料或外部知识，只允许读摘要、索引和局部片段
4. 更新方案、粗估和排期影响
4. 判断继续下一轮还是进入 `omp-preflight`
5. 长文生成后只保留摘要、索引和稳定路径
6. 产出状态载荷和记忆载荷
7. 调用 `scripts/status-apply.ps1`
8. 调用 `scripts/memory-apply.ps1`

## 必读状态

- `current_version`
- `loop_state.round_number`
- `loop_state.round_goal`
- `loop_state.round_result`
- `loop_state.history_summary`
- `fallback_state`
- `pending_confirmations`
- `latest_artifacts.response_notes`
- `stable_baselines.response_plan`
- `review_state`

## 阻断条件

- 本轮变化点说不清
- 新增内容尚未归并到模块或事实状态
- 无法判断新增内容是否影响主结构

## 强制规则

- `loop_state.round_result` 只能使用：
  - `continue_alignment`
  - `need_materials`
  - `need_internal_repair`
  - `ready_for_preflight`
- `reopen_alignment` 不是轮次结果，只能写入 `fallback_state.fallback_type`
- `internal_repair` 和 `need_materials` 属于轮次内回退，不增加 `loop_state.round_number`
- 只有执行 `reopen_alignment` 并重新进入下一轮正式对齐时，才增加 `loop_state.round_number`
- 文字不足以完成当前轮对齐目标时，可建议生成对齐型原型；是否实际生成由 PM 决定
- 满足以下任一条件时，应更新 `loop_state.history_summary`：
  - 累计 2-3 轮正式对齐
  - 发生主结构变化
  - 准备进入 `omp-preflight`
  - 需要后续会话快速接手
- 若存在待确认项并影响继续推进，必须主动转入 `omp-ask-back`
- 不得默认同时读取多个 skill
- 不得为了保险一次读取很多 contract
- 外部资料只允许局部回查，不得整篇整包载入
- 对外默认表现为会自己判断下一步的协作型大 skill
- 输出最后必须只给一个“下一步唯一动作”

## 建议脚本

- `scripts/status-apply.ps1`
- `scripts/memory-apply.ps1`

## 回写要求

- 更新 `docs/ohmypm/ohmypm-memory.md` 中的：
  - `本轮变化点`
  - `当前版本方案`
  - `当前模块清单`
  - `当前方案预估工时`
  - `排期影响判断`
  - `新增资料记录`
- 更新 `docs/ohmypm/ohmypm-status.json` 中的：
  - `current_stage`
  - `last_action`
  - `next_recommended`
  - `loop_state.round_result`
  - `loop_state.history_summary`
  - 必要时 `fallback_state.fallback_type`
  - 必要时 `fallback_state.fallback_reason`
  - 必要时 `pending_confirmations`
  - 必要时 `stable_baselines.response_plan`
