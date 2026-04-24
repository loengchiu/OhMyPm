---
name: omp-solution
description: "方案。基于调研结论生成和迭代当前版本方案稿，并判断是否足够进入原型或 PRD。"
---

# 方案

## 输出模板

- `docs/templates/solution-note.template.md`
- `docs/templates/solution-manifest.template.json`

## 所属层级

- 决策层动作

## 最小读取

- 先读 `.ohmypm/status.json`
- 再读 `.ohmypm/memory.md` 的最小必要摘要
- 当前只执行 `omp-solution`
- 默认只补 `contracts/context-guard.md`、`contracts/traceability.md`
- 需要追问时再补 `contracts/ask-back.md`

## 目标

- 基于调研结论生成当前版本方案稿
- 吸收 PM 对方案稿的修改
- 更新模块、页面、页面骨架、关键元素、关键动作和关键约束
- 生成当前方案的机读锚点
- 判断当前方案是否足够进入原型或 PRD

## 对外动作名

- 方案

## 强制规则

- 当前动作一次只推进一件事
- 当前动作必须先判断调研结论是否足够生成方案稿；不够时明确回到 `omp-disc`
- 方案稿是当前版本的唯一人读真值；PM 对方案的修改优先落在方案稿，不要求手改上游调研稿
- 每次重跑当前动作时，必须先吸收已有方案稿修改，再判断是继续补方案、回到 `omp-disc`，还是进入 `omp-proto` / `omp-prd`
- 当前动作不得把“PM 看着满意”直接等同于“已满足进入下一步条件”
- 只有在方案范围、模块、页面、关键元素、关键动作、关键约束已经足够稳定时，才能把当前方案作为稳定锚点
- 不得默认同时读取多个 skill
- 不得为了保险一次读取很多规则
- 输出最后必须只给一个“下一步唯一动作”
