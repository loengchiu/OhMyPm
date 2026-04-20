---
name: omp-overwrite-judge
description: "判断下游发现的问题是否需要修正上游文件，并定义回写范围。"
---

# Overwrite Judge

## 读取顺序

第 0 层：最小状态

1. `docs/ohmypm/ohmypm-status.json`
2. `docs/ohmypm/ohmypm-memory.md` 的最小必要摘要

第 1 层：当前动作 skill

3. 当前只执行 `omp-overwrite-judge`，不得默认并读其他 skill

第 2 层：当前动作必要 contract

4. `contracts/overwrite.md`

读取 `contracts/overwrite.md`，输出：

- 受影响上游文件
- 冲突类型
- 处理级别
- 回写范围
- 是否允许继续推进

## 强制规则

- 必须先判断版本关系是否清楚
- 若版本关系不清，直接阻断
- 输出必须包含 `reason`
- 不得为了保险预读其他 contract
- 对外默认表现为会自己判断下一步的协作型大 skill
- 输出最后必须只给一个“下一步唯一动作”

## 建议脚本

- `scripts/tools/overwrite-judge.ps1`
- `scripts/tools/overwrite-apply.ps1`
