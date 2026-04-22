---
name: omp-reply
description: "先回应。形成当前理解、当前版本方案、待确认项和模块级粗估。"
---

# 先回应

## 所属层级

- 决策层动作

## 最小读取

- 先读 `.ohmypm/status.json`
- 再读 `.ohmypm/memory.md` 的最小必要摘要
- 当前只执行 `omp-reply`
- 默认只补 `contracts/context-guard.md`、`contracts/context-package.md`、`contracts/traceability.md`
- 需要追问时再补 `contracts/ask-back.md`

## 目标

- 给出当前理解
- 给出当前版本方案
- 记录未确认事实与未澄清问题
- 补齐最小上下文包中的缺口状态
- 补齐当前版本的最小追溯元数据
- 给出模块级粗估、复杂度来源和排期影响判断

## 对外动作名

- 先回应

## 强制规则

- 当前动作一次只推进一件事
- 未通过当前动作的最低判断，不得把回应包装成稳定承诺
- 若关键事实缺口阻塞推进，转入 `omp-check`
- 模块级粗估只给区间，不给伪精确数字
- 粗估必须带出复杂度来源、关键风险和排期影响
- 最终对外承诺仍由 PM 拍板
- 不得默认同时读取多个 skill
- 不得为了保险预读很多规则
- 输出最后必须只给一个“下一步唯一动作”

