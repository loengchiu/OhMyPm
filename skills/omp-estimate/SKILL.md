---
name: omp-estimate
description: "按模块给出区间型工时粗估，并说明依据、风险和排期影响。"
---

# Estimate

## 读取顺序

第 0 层：最小状态

1. `docs/ohmypm/ohmypm-status.json`
2. `docs/ohmypm/ohmypm-memory.md` 的最小必要摘要

第 1 层：当前动作 skill

3. 当前只执行 `omp-estimate`，不得默认并读其他 skill

第 2 层：当前动作必要 contract

4. 无默认 contract；仅当当前估算需要核对门禁或上下文风险时，再读取单一必要 contract

## 输出要求

- 模块级区间粗估
- 复杂度来源
- 风险提醒
- 排期影响判断

最终对外承诺仍由 PM 拍板。

## 强制规则

- 只抽取当前估算所需最小上下文
- 不得为了保险预读多个 contract
- 对外默认表现为会自己判断下一步的协作型大 skill
- 输出最后必须只给一个“下一步唯一动作”
