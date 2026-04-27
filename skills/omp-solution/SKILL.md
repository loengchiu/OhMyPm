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
- 默认只补 `contracts/anchors-and-trace.md`
- 命中长材料、跨模块、跨产物或多轮累积时补 `contracts/context-guard.md`；追问补 `contracts/ask-back.md`
- 只有在判断页面展开粒度、字段前置方式或文风取舍时，才补读 `reference/solution-writing.md`

## 目标

- 基于调研结论生成当前版本方案稿
- 吸收 PM 对方案稿的修改
- 写清本次属于 `迭代 / 新建 / 混合` 中的哪一类
- 产出一份人能看懂的“建设类型差异说明表”，告诉后续原型和 PRD 重点要变在哪里
- 更新模块、页面、关键字段、关键动作和关键约束
- 生成当前方案的机读锚点
- 判断当前方案是否足够进入原型或 PRD，并在当前动作结束后默认停下等待 PM 确认

## 对外动作名

- 方案

## 强制规则

- 当前动作一次只推进一件事
- 当前动作开始前必须先完成调研结论充分性自检；若结论仍不足以稳定生成方案稿，必须先回到 `omp-disc`
- 当前动作必须先判断调研结论是否足够生成方案稿；不够时明确回到 `omp-disc`
- 当前动作必须先读取 `context_package.solution_shape`
- 若 `context_package.solution_shape` 为空或仍为“暂不能判断”，不得假装进入稳定方案，必须明确回到 `omp-disc`
- 方案稿是当前版本的唯一人读真值；PM 对方案的修改优先落在方案稿，不要求手改上游调研稿
- 每次重跑当前动作时，必须先吸收已有方案稿修改，再判断是继续补方案、回到 `omp-disc`，还是具备进入 `omp-proto` / `omp-prd` 的条件
- 当前动作不得把“PM 看着满意”直接等同于“已满足进入下一步条件”
- 方案稿生成完成后默认停在当前阶段；只有 PM 显式执行 `/proto` 或 `/prd`，才允许进入下一阶段
- 当前动作不得只按字数判断是否防爆；必须同时看文件类型、模块范围、产物范围和轮次复杂度
- `context_risk` 的 `length_signals / complexity_signals / decision` 必须使用 `contracts/context-guard.md` 中的标准口径
- 不得为了完整感擅自新增模块、页面、流程、规则、字段、验收项
- 只能补“当前范围内必需内容”；其余标为待确认或不写
- 模块、页面、动作的新增、删除或范围扩张必须由 PM 确认，不得自行扩充
- 方案稿按“模块写全、页面按复杂度展开”表达；简单页面用 1-2 句带过，复杂页面再补字段、动作、约束，不追求每页同样重
- 页面层默认只保留“页面说明”；“关键字段 / 关键动作 / 关键约束 / 存量承接字段 / 本次新增字段 / 待确认口径”按需出现，不得为了模板齐整机械补全
- 只要页面涉及展示字段、录入字段、筛选字段、统计字段或存量字段承接，方案稿必须在对应页面下显式列出相关字段或口径，不得等到 PRD 才首次出现字段清单
- 方案稿正文使用自然标题、短段落和必要列表；不用批量加粗标签、小标题套小标题或解释性空话撑结构
- 页面字段、动作、约束只写当前页面真正影响理解、原型或 PRD 的重点；简单页轻写，复杂页重写
- 只有在方案范围、模块、页面、关键字段、关键动作、关键约束已经足够稳定时，才能把当前方案作为稳定锚点
- 当 `solution_shape=iteration` 时，方案稿必须显式写出存量承接、改造入口和兼容约束
- 当 `solution_shape=new_build` 时，方案稿必须显式写出新建模块、页面和主流程
- 当 `solution_shape=hybrid` 时，方案稿必须把存量承接部分和新建部分分开写
- 仅参考旧系统字段、流程、页面或文案时，不得把方案写成 `hybrid`
- 若部署、代码、数据库、运行实例都是全新的，只是业务规则参考旧系统，方案稿必须按 `new_build` 处理
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
  - `next_recommended` 默认写成：`下一步：如进入原型请执行 /proto；如当前方案已足够直接写 PRD 请执行 /prd。`
  - `baselines.solution`
  - `artifacts.solution_notes`
  - `anchors_state.meta.anchor_manifest`
  - `alignment_state.current_output`
  - `context_risk.level`
  - `context_risk.length_signals`
  - `context_risk.complexity_signals`
  - `context_risk.decision`
  - `context_risk.last_updated`
