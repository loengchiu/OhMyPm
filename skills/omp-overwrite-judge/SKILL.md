---
name: omp-overwrite-judge
description: "判断下游发现的问题是否需要修正上游文件，并定义回写范围。"
---

# Overwrite Judge

## 读取顺序

1. `contracts/overwrite.md`
2. `docs/project-status.json`
3. `docs/project-memory.md`

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

## 建议脚本

- `scripts/overwrite-judge.ps1`
- `scripts/overwrite-apply.ps1`
