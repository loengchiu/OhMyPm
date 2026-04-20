---
name: omp-review-panel
description: "从多角色视角审视当前方案，归并形成统一评审意见。"
---

# Review Panel

## 读取顺序

第 0 层：最小状态

1. `docs/ohmypm/ohmypm-status.json`
2. `docs/ohmypm/ohmypm-memory.md` 的最小必要摘要

第 1 层：当前动作 skill

3. 当前只执行 `omp-review-panel`，不得默认并读其他 skill

第 2 层：当前动作必要 contract

4. `contracts/review.md`

默认角色：

- 需求方代表
- PM 代表
- 研发代表
- 测试代表
- 项目经理 / 实施代表
- 存量系统守门人

输出应归并为：

- 事实问题
- 风险问题
- 建议问题
- 统一结论

## 强制规则

- 每个问题都要标记来源角色
- 事实问题、风险问题、建议问题不得混写
- 统一结论只能是 `pass / conditional_pass / rework_required / defer`
- 输出必须带 `next_action` 与 `can_continue`
- 不得为了保险预读其他 contract
- 对外默认表现为会自己判断下一步的协作型大 skill
- 输出最后必须只给一个“下一步唯一动作”

## 建议脚本

- `scripts/review-panel.ps1`
- `scripts/review-apply.ps1`
