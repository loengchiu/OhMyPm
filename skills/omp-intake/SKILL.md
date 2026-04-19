---
name: omp-intake
description: "需求接收。建立当前需求任务、初始化项目记忆、判断是否具备进入第一轮回应的最小输入。"
---

# Intake

## 读取顺序

1. `docs/project-status.json`
2. `docs/project-memory.md`
3. `contracts/gates.md`
4. `contracts/context-guard.md`

## 目标

- 保留业务原话
- 建立当前需求任务
- 初始化项目记忆
- 判断是否具备进入 `omp-respond` 的条件

## 输出要求

- 更新 `docs/project-memory.md`
- 更新 `docs/project-status.json`
- 若信息不足，记录到 `pending_confirmations`
