---
name: omp-proto
description: "做原型。生成交付型原型，作为当前最小主链中的第一阅读入口。"
---

# 做原型

## 最小读取

- 先读 `.ohmypm/status.json`
- 再读 `.ohmypm/memory.md` 的最小必要摘要
- 当前只执行 `omp-proto`
- 默认只补 `contracts/gates.md`、`contracts/delivery.md`、`contracts/context-guard.md`、`contracts/traceability.md`、`contracts/boundary-guard.md`
- 外部知识和长材料只允许局部回查

## 目标

- 生成交付型原型
- 明确页面落点、主流程、页面用途、用户动作、关键状态、关键交互标注和页面间关系
- 保证原型挂在当前模块 / 页面 / 流程锚点上
- 保证原型先交付页面本体，再补标注解释

## 必读状态

- `baselines.response_plan`
- `alignment_state.round_result`
- `fallback_state`
- `baselines.prototype`
- `baselines.prd`

## 执行顺序

1. 检查正式交付门禁
2. 确认当前版本已进入正式交付模式
3. 若需要外部知识或长材料，只允许读摘要、索引和局部片段
4. 生成交付型原型主展示物
5. 长文或长说明生成后，只保留摘要、索引和稳定路径
6. 回写原型基线与原型产物路径
7. 下一步直接承接到 `omp-prd`

## 最低输出

- 一个可评审的交付型原型
- 页面落点和主流程标注
- 关键状态与关键交互标注
- 与 PRD 的引用边界
- 页面主体里能直接看出元素、基本流程和基本交互

## 强制规则

- 未通过正式交付门禁，不得开始
- 列表页 / 详情页 / 弹窗或抽屉 / 结果页中，至少要有当前需求真正需要的页面承接位
- 原型不得脱离当前追溯元数据和锚点生成
- 若 `fallback_state.fallback_type` 非空，不得伪装进入交付型原型
- 当前版本完成原型后，默认直接进入 `omp-prd`
- 不得默认同时读取多个 skill
- 不得为了保险一次读取很多 contract
- 不得整篇整包载入外部知识或长材料
- 输出最后必须只给一个“下一步唯一动作”

## 回写要求

- 更新 `.ohmypm/status.json` 中的：
  - `current_stage`
  - `current_mode`
  - `last_action`
  - `next_recommended`
  - `baselines.prototype`
  - `artifacts.prototypes`

