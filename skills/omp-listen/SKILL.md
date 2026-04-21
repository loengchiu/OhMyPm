---
name: omp-listen
description: "听需求。建立当前需求任务、初始化协作上下文，并判断是否具备进入第一轮回应的最小输入。"
---

# 听需求

## 读取顺序

第 0 层：最小状态

1. `.ohmypm/status.json`
2. `.ohmypm/memory.md` 的最小必要摘要

第 1 层：当前动作 skill

3. 当前只执行 `omp-listen`，不得默认并读其他 skill

第 2 层：当前动作必要 contract

4. `contracts/gates.md`
5. `contracts/context-guard.md`

第 3 层：条件触发读取

6. 仅当信息不足以建立当前需求任务时，再读取 `contracts/ask-back.md`

## 目标

- 保留业务原话
- 建立当前需求任务
- 初始化项目记忆
- 判断是否具备进入 `omp-reply` 的条件

## 输出要求

- 更新 `.ohmypm/memory.md`
- 更新 `.ohmypm/status.json`
- 若信息不足，记录到 `pending_confirmations`
- 不得默认同时读取多个 skill
- 不得为了保险一次读取很多 contract
- 对外默认表现为会自己判断下一步的协作型大 skill
- 输出最后必须只给一个“下一步唯一动作”

