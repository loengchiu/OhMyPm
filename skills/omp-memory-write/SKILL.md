---
name: omp-memory-write
description: "将本轮新确认事实、变化点、评审结果和系统知识回写到项目记忆或系统记忆卡。"
---

# Memory Write

## 读取顺序

1. `contracts/memory.md`
2. `docs/project-status.json`
3. `docs/project-memory.md`
4. 按需读取相关系统记忆卡

## 目标

- 回写项目记忆文件
- 按需回写系统记忆卡
- 保持事实、推断、建议分离

## 强制规则

- `project-status.json` 负责运行时真值，项目记忆不替代状态文件
- 不得把纯操作日志当作项目语义直接塞进项目记忆
- 跨项目复用知识才进入系统记忆卡
- 若评审或复写推翻既有结论，记忆必须同步更新

## 建议脚本

- `scripts/memory-write.ps1`
- `scripts/memory-apply.ps1`

## 标准化输入

若宿主更适合先产出结构化载荷，再统一落盘，可使用：

- `docs/examples/respond-memory.sample.json`
- `docs/examples/align-memory.sample.json`
- `docs/examples/preflight-memory.sample.json`
- `docs/examples/review-memory.sample.json`
- `docs/examples/fix-memory.sample.json`
- `scripts/memory-apply.ps1`
