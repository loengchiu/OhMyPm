---
name: omp-review
description: "组织评审会材料、执行多角色评审团、输出评审结论并回写。"
---

# Review

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

## 执行顺序

1. 确认当前已有可评审版本
2. 归并评审输入，形成材料包
3. 若需要长材料或外部知识，只允许读摘要、索引和局部片段
4. 调用 `omp-review`
5. 产出统一评审 JSON
6. 长文生成后只保留摘要、索引和稳定路径
7. 调用 `scripts/tools/review-apply.ps1`
8. 将评审摘要回写到 `.ohmypm/memory.md`

## 必读状态

- `stable_baselines.prototype`
- `stable_baselines.prd`
- `review_state`
- `latest_artifacts.review_records`
- `overwrite_queue`

## 最低输出

- 事实问题
- 风险问题
- 建议问题
- 统一结论
- 三级风险分层结果
- 复评清单
- 后续动作

三级风险分层结果最少包含：

- `blocking_items`
- `major_items`
- `suggestions`

## 建议脚本

- `scripts/tools/review-panel.ps1`
- `scripts/tools/review-apply.ps1`

## 强制规则

- 评审会是正式流程节点，不是普通聊天确认
- 评审材料包至少应覆盖：当前版本方案摘要、原型、PRD 或关键规则说明、本轮变化点、风险点、待决策点、模块级粗估和排期影响
- 评审结论必须归并为：事实问题、风险问题、建议问题、统一结论
- 风险问题必须再归并为：阻断项、重要项、建议项
- 统一结论必须按三级风险判定规则给出，不得只凭语气判断
- 评审时必须检查当前原型、PRD 是否仍引用同一版本、同一范围和同一组核心锚点
- 评审时必须检查是否存在：样例污染真实、未确认伪装已确认、元话语污染正式产物
- 若评审结论推翻稳定基线，应转入 `omp-fix` 并触发复写判定
- 不得默认同时读取多个 skill
- 不得为了保险一次读取很多 contract
- 对外默认表现为会自己判断下一步的协作型大 skill
- 输出最后必须只给一个“下一步唯一动作”

## 阻断条件

- `stable_baselines.prototype` 与 `stable_baselines.prd` 同时为空
- 当前评审对象未判清
- 评审材料包缺少变化点、风险点或待决策点

## 回写要求

- 更新 `.ohmypm/memory.md` 中的：
  - `评审摘要`
  - 必要时 `复写记录`
- 更新 `.ohmypm/status.json` 中的：
  - `current_stage`
  - `last_action`
  - `next_recommended`
  - `review_state.last_review_result`
  - `review_state.must_fix_before_next_stage`
  - `latest_artifacts.review_records`
  - 必要时 `overwrite_queue`

