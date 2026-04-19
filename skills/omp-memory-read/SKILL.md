---
name: omp-memory-read
description: "读取项目记忆与系统记忆，抽取当前动作所需的最小必要上下文。"
---

# Memory Read

## 读取顺序

1. `contracts/memory.md`
2. `docs/project-memory.md`
3. 按需读取 `docs/system-memory/*.md`

## 目标

- 读取 `docs/project-memory.md`
- 按需读取 `docs/system-memory/*.md`
- 只抽取当前动作所需的事实、规则、风险和引用

## 强制规则

- 先读项目记忆，再决定是否需要系统记忆卡
- 只抽取当前动作所需的最小必要上下文
- 若项目记忆已足够，不重复载入整张系统记忆卡
