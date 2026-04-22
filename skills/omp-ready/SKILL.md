---
name: omp-ready
description: "开工检查。判断当前方案是否满足进入正式交付的门槛。"
---

# 开工检查

## 所属层级

- 决策层动作

## 最小读取

- 先读 `.ohmypm/status.json`
- 再读 `.ohmypm/memory.md` 的最小必要摘要
- 当前只执行 `omp-ready`
- 默认只补 `contracts/gates.md`、`contracts/checkpoint.md`、`contracts/delivery.md`、`contracts/traceability.md`、`contracts/boundary-guard.md`
- 需要核对交付材料时只做局部回查

## 目标

- 检查范围是否闭合
- 检查流程是否闭合
- 检查模块是否闭合
- 检查未澄清项风险
- 检查工时是否可解释
- 检查交付承接是否完整
- 检查最小追溯元数据是否闭合
- 输出统一的开工 Checkpoint 结论
- 判断当前是否已经足够进入“原型 -> PRD”最小交付链

## 对外动作名

- 开工检查

## 结果

- 通过：允许进入正式交付
- 不通过：回到内部修正或 ask-back

## 强制规则

- 当前动作一次只推进一件事
- 若仍有待确认项，必须先转入 `omp-check`
- 若已发生边界越界，不得放行到正式交付
- 不得默认预读评审、变更、修正等不相关 skill
- 不得为了保险一次读取多个规则
- 输出最后必须只给一个“下一步唯一动作”

