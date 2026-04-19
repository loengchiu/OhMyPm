---
name: omp-ask-back
description: "围绕最阻塞推进的问题发起追问，并将结果回写项目记忆。"
---

# Ask Back

## 读取顺序

1. `contracts/ask-back.md`
2. `docs/project-status.json`
3. `docs/project-memory.md`
4. 按需读取当前阶段对应 contract

## 目标

- 只追当前最阻塞推进的一个问题
- 追问围绕目标、范围、事实、规则、风险或交付缺口
- 追问结果回写项目记忆文件

## 强制规则

- 追问必须直接服务当前门禁
- 优先一次只追一个问题
- 若已有证据可从现有资料中查出，先查证，不先问人
- 未得到回答前，必要时保留到 `pending_confirmations`

## 最低输出

- 当前为什么不能继续推进
- 当前最阻塞的问题
- 该问题属于哪类缺口
- 回答后将解除什么阻塞

## 建议脚本

- `scripts/ask-back-plan.ps1`
- `scripts/ask-back-apply.ps1`

## 回写要求

- 更新 `docs/project-memory.md`
- 必要时更新 `docs/project-status.json.pending_confirmations`
