---
name: omp-review
description: "组织评审会材料、执行多角色评审团、输出评审结论并回写。"
---

# Review

## 读取顺序

1. `docs/project-status.json`
2. `docs/project-memory.md`
3. `contracts/review.md`
4. `contracts/delivery.md`
5. `contracts/overwrite.md`

## 目标

- 形成评审材料包
- 组织多角色评审团
- 输出评审结论
- 回写评审结果

## 执行顺序

1. 确认当前已有可评审版本
2. 归并评审输入，形成材料包
3. 调用 `omp-review-panel`
4. 产出统一评审 JSON
5. 调用 `scripts/review-apply.ps1`
6. 将评审摘要回写到 `docs/project-memory.md`

## 必读状态

- `stable_baselines.prototype`
- `stable_baselines.prd`
- `review_state`
- `latest_artifacts.review_records`

## 最低输出

- 事实问题
- 风险问题
- 建议问题
- 统一结论
- 后续动作

## 建议脚本

- `scripts/review-panel.ps1`
- `scripts/review-apply.ps1`

## 阻断条件

- `stable_baselines.prototype` 与 `stable_baselines.prd` 同时为空
- 当前评审对象未判清
- 评审材料包缺少变化点、风险点或待决策点

## 回写要求

- 更新 `docs/project-memory.md` 中的：
  - `评审摘要`
  - 必要时 `复写记录`
- 更新 `docs/project-status.json` 中的：
  - `current_stage`
  - `last_action`
  - `next_recommended`
  - `review_state.last_review_result`
  - `review_state.must_fix_before_next_stage`
  - `latest_artifacts.review_records`
