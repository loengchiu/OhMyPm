---
name: omp-memory-write
description: "将本轮新确认事实、变化点、评审结果和系统知识回写到项目记忆或系统记忆卡。"
---

# Memory Write

## 读取顺序

第 0 层：最小状态

1. `docs/ohmypm/ohmypm-status.json`
2. `docs/ohmypm/ohmypm-memory.md` 的最小必要摘要

第 1 层：当前动作 skill

3. 当前只执行 `omp-memory-write`，不得默认并读其他 skill

第 2 层：当前动作必要 contract

4. `contracts/memory.md`

第 3 层：条件触发读取

5. 仅当确认需要回写跨项目复用知识时，再局部读取相关系统记忆卡

## 目标

- 回写项目记忆文件
- 按需回写系统记忆卡
- 保持事实、推断、建议分离

## 强制规则

- `ohmypm-status.json` 负责运行时真值，项目记忆不替代状态文件
- 不得把纯操作日志当作项目语义直接塞进项目记忆
- 跨项目复用知识才进入系统记忆卡
- 若评审或复写推翻既有结论，记忆必须同步更新
- 不得默认同时读取多个 skill
- 不得整篇整包读取系统记忆卡
- 输出只保留当前回写摘要、索引和稳定路径

## 建议脚本

- `scripts/tools/memory-write.ps1`
- `scripts/tools/memory-apply.ps1`

## 标准化输入

若宿主更适合先产出结构化载荷，再统一落盘，可使用：

- `docs/examples/respond-memory.sample.json`
- `docs/examples/align-memory.sample.json`
- `docs/examples/preflight-memory.sample.json`
- `docs/examples/review-memory.sample.json`
- `docs/examples/fix-memory.sample.json`
- `scripts/tools/memory-apply.ps1`
