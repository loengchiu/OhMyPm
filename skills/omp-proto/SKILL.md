---
name: omp-proto
description: "做原型。生成交付型原型，作为当前最小主链中的第一阅读入口。"
---

# 做原型

## 读取顺序

第 0 层：最小状态

1. `.ohmypm/status.json`
2. `.ohmypm/memory.md` 的最小必要摘要

第 1 层：当前动作 skill

3. 当前只执行 `omp-proto`，不得默认并读其他 skill

第 2 层：当前动作必要 contract

4. `contracts/gates.md`
5. `contracts/delivery.md`
6. `contracts/context-guard.md`

第 3 层：条件触发读取

7. 只有当当前原型需要依赖外部知识或长材料时，才允许做局部回查

## 目标

- 生成交付型原型
- 明确页面落点、主流程、页面用途、用户动作、关键状态、关键交互标注和页面间关系
- 验证原型模板是否足够承接这类需求

## 必读状态

- `stable_baselines.response_plan`
- `loop_state.round_result`
- `fallback_state`
- `stable_baselines.prototype`
- `stable_baselines.prd`

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
- 一条对模板是否够用的简短结论

## 强制规则

- 未通过正式交付门禁，不得开始
- 标注方式采用编号，不在页面铺大量正文
- 若 `fallback_state.fallback_type` 非空，不得伪装进入交付型原型
- 当前版本完成原型后，默认直接进入 `omp-prd`
- 不得默认同时读取多个 skill
- 不得为了保险一次读取很多 contract
- 不得整篇整包载入外部知识或长材料
- 对外默认表现为会自己判断下一步的协作型大 skill，不让 PM 自己判断命令或流程节点
- 输出最后必须只给一个“下一步唯一动作”

## 回写要求

- 更新 `.ohmypm/status.json` 中的：
  - `current_stage`
  - `current_mode`
  - `last_action`
  - `next_recommended`
  - `stable_baselines.prototype`
  - `latest_artifacts.prototypes`

