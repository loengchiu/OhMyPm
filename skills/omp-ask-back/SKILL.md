---
name: omp-ask-back
description: "围绕最阻塞推进的问题发起追问，并将结果回写项目记忆。"
---

# Ask Back

## 读取顺序

第 0 层：最小状态

1. `docs/ohmypm/ohmypm-status.json`
2. `docs/ohmypm/ohmypm-memory.md` 的最小必要摘要

第 1 层：当前动作 skill

3. 当前只执行 `omp-ask-back`，不得默认并读其他 skill

第 2 层：当前动作必要 contract

4. `contracts/ask-back.md`

第 3 层：条件触发读取

5. 仅当需要核对当前阶段阻塞类型时，再局部读取当前阶段对应 contract

## 目标

- 只追当前最阻塞推进的一个问题
- 追问围绕目标、范围、事实、规则、风险或交付缺口
- 追问结果回写项目记忆文件

## 强制规则

- 追问必须直接服务当前门禁
- 优先一次只追一个问题
- 若已有证据可从现有资料中查出，先查证，不先问人
- 必须先判断当前是真实项目协作还是机制验证样例 / demo
- 若当前是机制验证样例 / demo，不得向 PM 追问样例中的虚拟业务口径；应改为占位值、样例说明或内部修正
- 未得到回答前，必要时保留到 `pending_confirmations`
- 不得默认一次追多个问题
- 不得默认同时读取多个 skill 或很多 contract
- 对外必须使用自然语言，不得直接把内部状态机术语抛给 PM
- 对外默认表现为会自己判断下一步的协作型大 skill
- 输出最后必须只给一个“下一步唯一动作”

## 最低输出

- 当前为什么不能继续推进
- 当前最阻塞的问题
- 该问题属于哪类缺口
- 回答后将解除什么阻塞

## 建议脚本

- `scripts/ask-back-plan.ps1`
- `scripts/ask-back-apply.ps1`

## 回写要求

- 更新 `docs/ohmypm/ohmypm-memory.md`
- 必要时更新 `docs/ohmypm/ohmypm-status.json.pending_confirmations`
