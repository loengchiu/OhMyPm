---
name: omp-memory-write
description: "将本轮新确认事实、变化点、评审结果和系统知识回写到项目记忆或系统记忆卡。"
---

# Memory Write

## 目标

- 回写项目记忆文件
- 按需回写系统记忆卡
- 保持事实、推断、建议分离

## 建议脚本

- `scripts/memory-write.ps1`
- `scripts/memory-apply.ps1`

## 标准化输入

若宿主更适合先产出结构化载荷，再统一落盘，可使用：

- `docs/examples/memory-apply.sample.json`
- `scripts/memory-apply.ps1`
