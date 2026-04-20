---
name: omp-memory-read
description: "读取项目记忆与系统记忆，抽取当前动作所需的最小必要上下文。"
---

# Memory Read

## 读取顺序

第 0 层：最小状态

1. `docs/ohmypm/ohmypm-memory.md` 的最小必要摘要

第 1 层：当前动作 skill

2. 当前只执行 `omp-memory-read`，不得默认并读其他 skill

第 2 层：当前动作必要 contract

3. `contracts/memory.md`

第 3 层：条件触发读取

4. 仅当项目记忆不足时，再局部读取 `docs/ohmypm/system-memory/*.md`

## 目标

- 读取 `docs/ohmypm/ohmypm-memory.md`
- 按需读取 `docs/ohmypm/system-memory/*.md`
- 只抽取当前动作所需的事实、规则、风险和引用

## 强制规则

- 先读项目记忆，再决定是否需要系统记忆卡
- 只抽取当前动作所需的最小必要上下文
- 若项目记忆已足够，不重复载入整张系统记忆卡
- 不得整篇整包读取系统记忆卡
- 输出只保留当前动作所需摘要、索引和稳定路径
