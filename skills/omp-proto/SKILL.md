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
- 验证原型模板是否足够承接这类需求
- 保证原型先交付页面本体，再补标注解释

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
- 页面主体里能直接看出元素、基本流程和基本交互

## 强制规则

- 未通过正式交付门禁，不得开始
- 标注方式采用编号，不在页面铺大量正文
- 标注应采用 `ShitPM note` 风格：编号贴元素、点击出浮窗、浮窗可直接承接开发说明
- 页面本体必须先于方案说明出现
- 列表页 / 详情页 / 弹窗或抽屉 / 结果页中，至少要有当前需求真正需要的页面承接位
- 不得用大 hero、大流程说明区、长段导语替代真实页面结构
- 原型不得脱离当前追溯元数据和锚点生成
- 不得把 OMP 方法论、契约说明或“模板试跑”元话语写进正式原型正文
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

