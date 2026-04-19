---
name: omp-respond
description: "形成当前理解与一版可信回应，暴露不确定项，建立当前版本方案。"
---

# Respond

## 读取顺序

1. `docs/project-status.json`
2. `docs/project-memory.md`
3. `contracts/gates.md`
4. `contracts/context-guard.md`
5. `contracts/knowledge.md`

## 目标

- 给出当前理解
- 给出当前版本方案
- 记录未确认事实与未澄清问题
- 给出模块级粗估或量级判断

## 执行顺序

1. 检查回应门禁是否具备最小输入
2. 评估上下文风险，必要时先做分块计划
3. 形成回应稿或更新回应稿
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

## 阻断条件

- 当前需求任务无法定义
- 当前版本方案无法成形
- 未确认事实与未澄清问题未显式记录
- 粗粒度量级判断完全缺失

## 回写要求

- 更新 `docs/project-memory.md` 中的：
  - `当前版本方案`
  - `未确认事实`
  - `未澄清问题`
  - `当前方案预估工时`
  - `当前建议`
- 更新 `docs/project-status.json` 中的：
  - `current_stage`
  - `current_mode`
  - `last_action`
  - `next_recommended`
  - `latest_artifacts.response_notes`
  - 必要时 `pending_confirmations`
