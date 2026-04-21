---
name: omp-memory
description: "记忆。统一处理项目记忆和系统记忆的读取、摘要与回写。"
---

# 记忆

## 读取顺序

第 0 层：最小状态

1. `.ohmypm/status.json`
2. `.ohmypm/memory.md` 的最小必要摘要

第 1 层：当前动作 skill

3. 当前只执行 `omp-memory`，不得默认并读其他 skill

第 2 层：当前动作必要 contract

4. `contracts/memory.md`

第 3 层：条件触发读取

5. 仅当项目记忆不足或确认需要回写跨项目知识时，再局部读取相关系统记忆卡

## 目标

- 读取 `.ohmypm/memory.md`
- 按需读取 `.ohmypm/system-memory/*.md`
- 只抽取当前动作所需的事实、规则、风险和引用
- 回写项目记忆文件
- 按需回写系统记忆卡

## 强制规则

- 先读项目记忆，再决定是否需要系统记忆卡
- 只抽取当前动作所需的最小必要上下文
- 若项目记忆已足够，不重复载入整张系统记忆卡
- `ohmypm-status.json` 负责运行时真值，项目记忆不替代状态文件
- 不得把纯操作日志当作项目语义直接塞进项目记忆
- 跨项目复用知识才进入系统记忆卡
- 若评审或复写推翻既有结论，记忆必须同步更新
- 不得整篇整包读取系统记忆卡
- 输出只保留当前动作所需摘要、索引和稳定路径

## 建议脚本

- `scripts/tools/memory-write.ps1`
- `scripts/tools/memory-apply.ps1`

