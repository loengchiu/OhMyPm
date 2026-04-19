---
name: omp-deliver-prototype
description: "生成交付型原型，作为评审会主展示物和研发第一阅读入口。"
---

# Deliver Prototype

## 读取顺序

1. `docs/project-status.json`
2. `docs/project-memory.md`
3. `contracts/gates.md`
4. `contracts/delivery.md`
5. `contracts/context-guard.md`

## 目标

- 生成交付型原型
- 明确页面落点、主流程、页面用途、用户动作、关键状态、关键交互标注和页面间关系

## 必读状态

- `stable_baselines.response_plan`
- `loop_state.round_result`
- `fallback_state`
- `stable_baselines.prototype`
- `stable_baselines.prd`

## 执行顺序

1. 检查正式交付门禁
2. 确认当前版本已进入正式交付模式
3. 生成交付型原型主展示物
4. 回写原型基线与原型产物路径

## 最低输出

- 一个可评审的交付型原型
- 页面落点和主流程标注
- 关键状态与关键交互标注
- 与 PRD 的引用边界

## 强制规则

- 未通过正式交付门禁，不得开始
- 标注方式采用编号，不在页面铺大量正文
- 若 `fallback_state.fallback_type` 非空，不得伪装进入交付型原型
- 交付型原型是评审会主展示物，完成后应能直接进入 `omp-review`

## 回写要求

- 更新 `docs/project-status.json` 中的：
  - `current_stage`
  - `current_mode`
  - `last_action`
  - `next_recommended`
  - `stable_baselines.prototype`
  - `latest_artifacts.prototypes`
