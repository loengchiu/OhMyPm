---
name: omp-review
description: "组织评审会材料、执行多角色评审团、输出评审结论并回写。"
---

# Review

## 输出模板

- `docs/templates/review-record.template.md`

## 最小读取

- 先读 `.ohmypm/status.json`
- 再读 `.ohmypm/memory.md` 的最小必要摘要
- 当前只执行 `omp-review`
- 默认只补 `contracts/review.md`、`contracts/anchors-and-trace.md`
- 涉及交付分工补 `contracts/delivery.md`；涉及复写补 `contracts/overwrite.md`

## 目标

- 形成评审材料包
- 组织多角色评审团
- 输出评审结论
- 检查当前产物是否仍挂在同一套追溯元数据上
- 回写评审结果
- 通过冷启动评审包降低 writer 上下文惯性

## 必读状态

- `anchors_state.meta.anchor_manifest`
- `baselines.prototype`
- `baselines.prd`
- `review_state`

## 强制规则

- 评审会是正式流程节点，不是普通聊天确认
- 评审开始前必须执行 `python scripts/python/omp-lint.py trace-check --status-path .ohmypm/status.json`
- 评审开始前必须执行 `python scripts/python/omp-lint.py build-review-pack --status-path .ohmypm/status.json --output-path .ohmypm/review/review-pack.json`
- `trace-check` 结果为 `fail` 时不得直接给通过结论，必须先进入修复
- 评审必须基于 `review-pack.json`、PRD、原型和 manifest 冷启动判断，不沿用 writer 长上下文惯性
- 评审记录直接记录问题和结论，不写流程说明或方法论说明
- 评审记录不出现 `AI`、绝对路径、调试路径、内部状态字段
- 对人可见的问题按“事实 / 风险 / 建议”归类，不混写
- `下一步` 一律写成：`下一步：`
- 评审材料包至少应覆盖：当前版本方案摘要、原型、PRD 或关键规则说明、本轮变化点、风险点、待决策点、模块级粗估和排期影响
- 评审结论必须归并为：事实问题、风险问题、建议问题、统一结论
- 风险问题必须再归并为：阻断项、重要项、建议项
- 评审记录必须包含“变更传播检查”，写清本轮改动点、已同步关联位置、未同步关联位置和传播状态
- 未完成传播检查时不得给出 `pass`
- 统一结论必须按三级风险判定规则给出，不得只凭语气判断
- 评审时必须检查当前原型、PRD 是否仍引用同一版本、同一范围和同一组核心锚点
- 评审对人表达使用页面名、页面编号和自然问题描述；内部问题记录使用 `anchor_manifest` 中的组合锚点定位
- 评审时必须检查是否存在：虚构内容污染正式结论、未确认伪装已确认、元话语污染正式产物
- 若评审结论推翻稳定基线，应转入 `omp-fix` 并触发复写判定
- 开工检查结论必须直接写允许、不允许或需补充；不通过时写清不通过原因、修正方向和下一步
