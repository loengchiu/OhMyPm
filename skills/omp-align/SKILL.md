---
name: omp-align
description: "对齐。根据反馈更新方案、变化点、模块判断与粗估。"
---

# 对齐

## 所属层级

- 决策层动作

## 最小读取

- 先读 `.ohmypm/status.json`
- 再读 `.ohmypm/memory.md` 的最小必要摘要
- 当前只执行 `omp-align`
- 默认只补 `contracts/context-guard.md`
- 需要追问时再补 `contracts/ask-back.md`

## 目标

- 根据反馈修正当前理解
- 更新本轮变化点
- 更新模块清单、粗估和排期影响
- 判断是对齐，还是进入开工检查

## 对外动作名

- 对齐

## 强制规则

- 当前动作一次只推进一件事
- 若存在待确认项并影响继续推进，必须主动转入 `omp-check`
- 不得默认同时读取多个 skill
- 不得为了保险一次读取很多规则
- 输出最后必须只给一个“下一步唯一动作”

