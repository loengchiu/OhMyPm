---
name: omp-gate-check
description: "执行当前动作对应的门禁检查，并输出通过、阻断原因或回退建议。"
---

# Gate Check

读取 `contracts/gates.md`，根据当前动作输出：

- 当前门禁名称
- 检查项
- 已满足项
- 未满足项
- 下一步建议
