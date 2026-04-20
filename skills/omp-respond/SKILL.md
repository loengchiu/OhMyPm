---
name: omp-respond
description: "形成当前理解与一版可信回应，暴露不确定项，建立当前版本方案。"
---

# Respond

## 读取顺序

第 0 层：最小状态

1. `docs/ohmypm/ohmypm-status.json`
2. `docs/ohmypm/ohmypm-memory.md` 的最小必要摘要

第 1 层：当前动作 skill

3. 当前只执行 `omp-respond`，不得默认并读其他 skill

第 2 层：当前动作必要 contract

4. `contracts/gates.md`
5. `contracts/context-guard.md`

第 3 层：条件触发读取

6. 仅当回应门禁被事实缺口阻塞时，再读取 `contracts/ask-back.md`
7. 仅当当前回应明确依赖系统知识或外部资料时，再局部回查 `contracts/knowledge.md` 所指向的资料

## 目标

- 给出当前理解
- 给出当前版本方案
- 记录未确认事实与未澄清问题
- 给出模块级粗估或量级判断

## 执行顺序

1. 检查回应门禁是否具备最小输入
2. 评估上下文风险，必要时先做分块计划
3. 若需要长材料或外部知识，只允许做摘要或局部回查
4. 形成回应稿或更新回应稿
5. 长文生成后只保留摘要、索引和稳定路径
4. 产出状态载荷和记忆载荷
5. 调用 `scripts/status-apply.ps1`
6. 调用 `scripts/memory-apply.ps1`

## 必读状态

- `current_version`
- `context_summary`
- `latest_artifacts.response_notes`
- `stable_baselines.response_plan`
- `pending_confirmations`
- `blockers`

## 最低输出

- 一段当前理解摘要
- 一版当前版本方案
- 一组未确认事实
- 一组未澄清问题
- 至少一条模块级粗估或量级判断

## 建议脚本

- `scripts/context-plan.ps1`
- `scripts/material-extract.ps1`
- `scripts/status-apply.ps1`
- `scripts/memory-apply.ps1`

## 强制规则

- 未过回应门禁，不得形成像承诺一样的正式回应
- 若事实缺口阻塞推进，转入 `omp-ask-back`
- 若当前只是轮次内修正或待补资料，不得擅自增加轮次编号
- 若文字已经不足以支撑需求方判断改动落点、流程或可达结果，可建议生成对齐型原型；是否实际生成由 PM 决定
- 若范围边界未确认且已影响模块、工时或排期判断，不得继续把当前理解包装成稳定回应
- 不得默认同时读取多个 skill
- 不得为了保险预读 `ask-back`、`knowledge` 或其他 contract
- 外部资料只允许局部回查，不得整篇整包载入
- 输出最后必须只给一个“下一步唯一动作”

## 阻断条件

- 当前需求任务无法定义
- 当前版本方案无法成形
- 未确认事实与未澄清问题未显式记录
- 粗粒度量级判断完全缺失

## 回写要求

- 更新 `docs/ohmypm/ohmypm-memory.md` 中的：
  - `当前版本方案`
  - `未确认事实`
  - `未澄清问题`
  - `当前方案预估工时`
  - `当前建议`
- 更新 `docs/ohmypm/ohmypm-status.json` 中的：
  - `current_stage`
  - `current_mode`
  - `last_action`
  - `next_recommended`
  - 必要时 `loop_state.round_result`
  - 必要时 `fallback_state.fallback_type`
  - 必要时 `fallback_state.fallback_reason`
  - `latest_artifacts.response_notes`
  - 必要时 `pending_confirmations`
