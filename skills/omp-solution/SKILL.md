---
name: omp-solution
description: "方案。基于调研结论生成和迭代当前版本方案稿，并判断是否足够进入原型或 PRD。"
---

# 方案

## 输出模板

- `docs/templates/solution-note.template.md`
- `docs/templates/solution-manifest.template.json`
- `docs/templates/solution-shape-diff.template.md`

## 所属层级

- 决策层动作

## 最小读取

- 先读 `.ohmypm/status.json`
- 再读 `.ohmypm/memory.md` 的最小必要摘要
- 读取 `context_risk`；若不存在，先按最小结构补齐
- 当前只执行 `omp-solution`
- 默认只补 `contracts/traceability.md`
- 命中长材料、跨模块、跨产物或多轮累积时补 `contracts/context-guard.md`；追问补 `contracts/ask-back.md`

## 目标

- 基于调研结论生成当前版本方案稿
- 吸收 PM 对方案稿的修改
- 写清本次属于 `迭代 / 新建 / 混合` 中的哪一类，以及为什么
- 产出一份人能看懂的“建设类型差异说明表”，告诉后续原型和 PRD 重点要变在哪里
- 更新模块、页面、页面骨架、关键元素、关键动作和关键约束
- 生成当前方案的机读锚点
- 判断当前方案是否足够进入原型或 PRD

## 对外动作名

- 方案

## 强制规则

- 当前动作一次只推进一件事
- 当前动作开始前必须先完成调研结论充分性自检；若结论仍不足以稳定生成方案稿，必须先回到 `omp-disc`
- 当前动作必须先判断调研结论是否足够生成方案稿；不够时明确回到 `omp-disc`
- 当前动作必须先读取 `context_package.solution_shape`
- 若 `context_package.solution_shape` 为空或仍为“暂不能判断”，不得假装进入稳定方案，必须明确回到 `omp-disc`
- 方案稿是当前版本的唯一人读真值；PM 对方案的修改优先落在方案稿，不要求手改上游调研稿
- 每次重跑当前动作时，必须先吸收已有方案稿修改，再判断是继续补方案、回到 `omp-disc`，还是进入 `omp-proto` / `omp-prd`
- 当前动作不得把“PM 看着满意”直接等同于“已满足进入下一步条件”
- 当前动作不得只按字数判断是否防爆；必须同时看文件类型、模块范围、产物范围和轮次复杂度
- `context_risk` 的 `length_signals / complexity_signals / decision` 必须使用 `contracts/context-guard.md` 中的标准口径
- 方案稿使用完整列举和明确边界来表达范围；已确认内容写完整，未确认内容单独标注待补
- 只有在方案范围、模块、页面、关键元素、关键动作、关键约束已经足够稳定时，才能把当前方案作为稳定锚点
- 当 `solution_shape=iteration` 时，方案稿必须显式写出存量承接、改造入口和兼容约束
- 当 `solution_shape=new_build` 时，方案稿必须显式写出新建模块、页面和主流程
- 当 `solution_shape=hybrid` 时，方案稿必须把存量承接部分和新建部分分开写
- `迭代 / 新建 / 混合` 三类需求统一通过“建设类型差异说明表”表达后续原型和 PRD 的重点差异
- 人读版只允许落在 `solution.md` 与“建设类型差异说明表”里，不得写机读字段名、JSON 键名、绝对路径或调度说明
- 机读版只允许落在 `solution.manifest.json` 里，必须以稳定字段、短标签和结构化列表表达，不得把整段人话分析直接复制进去
- `solution.manifest.json` 重点是锚定建设类型、模块、页面、元素、动作、约束和范围标签，不是重复写一份人读方案稿
- `solution.md` 与 `solution.manifest.json` 必须同轮生成、同轮修改；禁止从人读稿反推机读稿
- 生成 `solution.manifest.json` 后，必须执行 `python scripts/python/omp-lint.py schema-check --target manifest --file <manifest-path>`
- `output/solution` 只放 PM 可直接阅读的方案产物
- `.ohmypm/alignment` 只放当前方案的内部机读锚点、状态快照和供后续动作读取的结构化文件
- 因此“建设类型差异说明表”留在 `output/solution`，`solution.manifest.json` 必须落在 `.ohmypm/alignment`
- 当前动作完成后，必须回写：
  - `baselines.solution`
  - `artifacts.solution_notes`
  - `anchors_state.meta.anchor_manifest`
  - `alignment_state.current_output`
  - `context_risk.level`
  - `context_risk.length_signals`
  - `context_risk.complexity_signals`
  - `context_risk.decision`
  - `context_risk.last_updated`
