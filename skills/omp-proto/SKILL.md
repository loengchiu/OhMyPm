---
name: omp-proto
description: "做原型。生成交付型原型，作为当前最小主链中的第一阅读入口。"
---

# 做原型

## 最小读取

- 先读 `.ohmypm/status.json`
- 再读 `.ohmypm/memory.md` 的最小必要摘要
- 当前只执行 `omp-proto`
- 默认只补 `contracts/delivery.md`、`contracts/traceability.md`
- 门禁异常补 `contracts/gates.md`；长材料补 `contracts/context-guard.md`
- 外部知识只允许局部回查

## 目标

- 生成交付型原型
- 明确页面落点、主流程、页面用途、用户动作、关键状态、关键交互标注和页面间关系
- 保证原型挂在当前模块 / 页面 / 流程锚点上
- 保证原型先交付页面本体，再补标注解释
- 根据 `solution_shape` 选择展示重点

## 必读状态

- `baselines.response_plan`
- `context_package.solution_shape`
- `alignment_state.round_result`
- `fallback_state`
- `anchors_state.meta.anchor_manifest`
- `baselines.prototype`
- `baselines.prd`
- `solution-shape diff`

## 执行顺序

1. 检查正式交付门禁
2. 确认当前版本已进入正式交付模式
3. 若需要外部知识或长材料，只允许读摘要、索引和局部片段
4. 生成交付型原型主展示物
5. 长文或长说明生成后，只保留摘要、索引和稳定路径
6. 回写原型基线与原型产物路径
7. 执行 `trace-check`
8. 下一步直接承接到 `omp-prd`

## 最低输出

- 一个可评审的交付型原型
- 页面落点和主流程标注
- 关键状态与关键交互标注
- 与 PRD 的引用边界
- 页面主体里能直接看出元素、基本流程和基本交互

## 强制规则

- 未通过正式交付门禁，不得开始
- 页面主体先出现，再补编号标注和解释
- 标注使用编号，不在页面主体铺大段说明文字
- 编号标注必须贴着元素走，点击后展示解释
- 不使用大 hero、大流程说明区、长段导语替代真实页面结构
- 页面风格、结构、共享 css/js 默认沿用当前原型共享壳；只在允许的差异点上调整
- 原型正文不写方法论说明、内部术语、契约说明
- 列表页 / 详情页 / 弹窗或抽屉 / 结果页中，至少要有当前需求真正需要的页面承接位
- 原型不得脱离当前追溯元数据和锚点生成
- 原型生成时必须读取内部 `anchor_manifest`；页面可见区域只显示页面编号和标注小数字，完整组合锚点只写入隐藏属性或内部 manifest
- 原型生成后必须执行 `python scripts/python/omp-lint.py trace-check --status-path .ohmypm/status.json`；结果为 `fail` 时不得进入 PRD，必须先修正 manifest、路径或机读字段泄漏
- 原型必须让研发只看原型即可先理解页面位置、主流程、关键动作、状态变化和联动关系
- 编号标注必须能挂到 PRD 对应章节或内部 manifest
- 原型必须读取“建设类型差异说明表”，按其中的原型重点展示，不得自行脑补另一套展示逻辑
- 当 `solution_shape=iteration` 时，原型必须优先讲清改造点在哪里、挂在哪个已有页面/流程上
- 当 `solution_shape=new_build` 时，原型必须优先讲清完整页面承接和主流程
- 当 `solution_shape=hybrid` 时，原型必须明确区分存量承接页面和新建页面
- 若 `fallback_state.fallback_type` 非空，不得伪装进入交付型原型
- 当前版本完成原型后，默认直接进入 `omp-prd`
- 原型生成后必须自检页面主体是否优先、必要页面承接位是否完整、标注是否贴着元素走

## 回写要求

- 更新 `.ohmypm/status.json` 中的：
  - `current_stage`
  - `current_mode`
  - `last_action`
  - `next_recommended`
  - `baselines.prototype`
  - `artifacts.prototypes`

