---
name: omp-check
description: "推进检查。判断当前能不能继续推进；若不能，决定是追问、内部修正还是阻断。"
---

# 推进检查

## 最小读取

- 先读 `.ohmypm/status.json`
- 再读 `.ohmypm/memory.md` 的最小必要摘要
- 当前只执行 `omp-check`
- 默认只补 `contracts/gates.md`、`contracts/checkpoint.md`、`contracts/boundary-guard.md`
- 需要追问时再补 `contracts/ask-back.md`

## 目标

- 判断当前动作能否继续推进
- 给出门禁通过、阻断原因或回退建议
- 把当前判断收口成统一的 Checkpoint 结论
- 当无法继续推进时，只追当前最阻塞的一个问题
- 判断当前问题应转成 PM 追问，还是内部修正

## 强制规则

- 必须先判断当前动作的推进条件是否成立
- 追问必须直接服务当前门禁
- 优先一次只追一个问题
- 若已有证据可从现有资料中查出，先查证，不先问人
- 必须先判断当前是否已发生边界越界：虚构内容污染正式结论、未确认伪装已确认、脱锚扩写
- 内部矛盾、占位口径、引用失配不得抛给 PM
- 未得到回答前，必要时保留到 `pending_confirmations`
- 不得默认一次追多个问题
- 不得默认同时读取多个 skill 或很多 contract
- 对外必须使用自然语言，不得直接把内部状态机术语抛给 PM
- 输出最后必须只给一个“下一步唯一动作”
