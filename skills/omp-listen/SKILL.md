---
name: omp-listen
description: "听需求。建立当前需求任务、初始化协作上下文，并判断是否具备进入第一轮回应的最小输入。"
---

# 听需求

## 最小读取

- 先读 `.ohmypm/status.json`
- 再读 `.ohmypm/memory.md` 的最小必要摘要
- 当前只执行 `omp-listen`
- 默认只补 `contracts/gates.md`、`contracts/context-guard.md`、`contracts/context-package.md`、`contracts/traceability.md`
- 信息不足时再补 `contracts/ask-back.md`

## 目标

- 保留业务原话
- 建立当前需求任务
- 初始化项目记忆
- 初始化最小上下文包
- 初始化最小追溯元数据
- 判断是否具备进入 `omp-reply` 的条件

## 输出要求

- 更新 `.ohmypm/memory.md`
- 更新 `.ohmypm/status.json`
- 若信息不足，记录到 `pending_confirmations`
- 不得默认同时读取多个 skill
- 不得为了保险一次读取很多 contract
- 对外默认表现为会自己判断下一步的协作型大 skill
- 输出最后必须只给一个“下一步唯一动作”

