---
name: omp-governance
description: "治理。统一处理基线一致性、复写判断、产物承接和状态同步。"
---

# 治理

## 最小读取

- 先读 `.ohmypm/status.json`
- 再读 `.ohmypm/memory.md` 的最小必要摘要
- 当前只执行 `omp-governance`
- 默认只补当前治理动作真正需要的 contract
- 涉及复写判断时再补 `contracts/overwrite.md`

## 目标

- 同步 `.ohmypm/status.json`
- 必要时刷新稳定基线和最新产物路径
- 判断下游发现的问题是否需要修正上游文件，并定义回写范围
- 保持产物承接、复写记录和状态字段一致

## 强制规则

- 必须先判断版本关系是否清楚
- 若版本关系不清，直接阻断
- 若发生复写判断，输出必须包含 `reason`
- 只同步当前动作明确需要的状态字段
- 不得为了保险预读其他 contract
- 对外默认表现为会自己判断下一步的协作型大 skill
- 输出最后必须只给一个“下一步唯一动作”

## 建议脚本

- `scripts/tools/artifact-sync.ps1`
- `scripts/tools/status-apply.ps1`
- `scripts/tools/overwrite-judge.ps1`
- `scripts/tools/overwrite-apply.ps1`

