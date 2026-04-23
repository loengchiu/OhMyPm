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
- 默认只补 `contracts/review.md`、`contracts/traceability.md`、`contracts/boundary-guard.md`
- 涉及交付分工或复写时再补 `contracts/delivery.md`、`contracts/overwrite.md`

## 目标

- 形成评审材料包
- 组织多角色评审团
- 输出评审结论
- 检查当前产物是否仍挂在同一套追溯元数据上
- 回写评审结果

## 强制规则

- 评审会是正式流程节点，不是普通聊天确认
- 评审材料包至少应覆盖：当前版本方案摘要、原型、PRD 或关键规则说明、本轮变化点、风险点、待决策点、模块级粗估和排期影响
- 评审结论必须归并为：事实问题、风险问题、建议问题、统一结论
- 风险问题必须再归并为：阻断项、重要项、建议项
- 统一结论必须按三级风险判定规则给出，不得只凭语气判断
- 评审时必须检查当前原型、PRD 是否仍引用同一版本、同一范围和同一组核心锚点
- 评审时必须检查是否存在：虚构内容污染正式结论、未确认伪装已确认、元话语污染正式产物
- 若评审结论推翻稳定基线，应转入 `omp-fix` 并触发复写判定
- 不得默认同时读取多个 skill
- 不得为了保险一次读取很多 contract
- 输出最后必须只给一个“下一步唯一动作”
