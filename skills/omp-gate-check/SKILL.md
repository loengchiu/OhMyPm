---
name: omp-gate-check
description: "执行当前动作对应的门禁检查，并输出通过、阻断原因或回退建议。"
---

# Gate Check

## 读取顺序

第 0 层：最小状态

1. `docs/ohmypm/ohmypm-status.json`

第 1 层：当前动作 skill

2. 当前只执行 `omp-gate-check`，不得默认并读其他 skill

第 2 层：当前动作必要 contract

3. `contracts/gates.md`

读取 `contracts/gates.md`，根据当前动作输出：

- 当前门禁名称
- 检查项
- 已满足项
- 未满足项
- 下一步建议

## 强制规则

- 不得为了保险预读其他 contract
- 对外默认表现为会自己判断下一步的协作型大 skill
- 输出最后必须只给一个“下一步唯一动作”
