---
name: omp-disc
description: "调研。根据需求方原话和材料生成会面问题提纲，接收会后回答，并判断是否足够进入方案阶段。"
---

# 调研 / 需求澄清工作台

## 输出模板

- `docs/templates/disc-note.template.md`

## 所属层级

- 决策层动作

## 最小读取

- 若 `.ohmypm/status.json` 不存在，先按 `docs/templates/init-status.template.json` 创建 `.ohmypm/status.json`
- 若 `.ohmypm/memory.md` 不存在，先按 `docs/templates/init-memory.template.md` 创建 `.ohmypm/memory.md`
- 若 `.ohmypm/alignment/`、`output/disc`、`output/solution`、`output/prd`、`output/prototype`、`output/review` 不存在，先创建目录
- 先读 `.ohmypm/status.json`
- 再读 `.ohmypm/memory.md` 的最小必要摘要
- 若 `context_risk` 不存在，先按最小结构补齐后再继续
- 当前只执行 `omp-disc`
- 默认只补 `contracts/intake-context.md`
- 命中长材料、文件类型高成本、多轮累积或复杂度升高时补 `contracts/context-guard.md`；追问补 `contracts/ask-back.md`
- 只有在判断轮次写法、问题粒度或对外表达取舍时，才补读 `reference/disc-writing.md`

## 目标

- 接住需求方原话、资料和 PM 补充材料
- 生成下一次会面要问的问题提纲
- 对本次需求先给出建设类型初判：`iteration / new_build / hybrid`
- 根据 PM 填回的答案判断是否已足够进入方案阶段
- 不能推进时，只生成下一轮差量问题
- 能推进时，输出调研结论，供后续进入 `omp-solution`

## 对外动作名

- 调研

## 强制规则

- 当前动作一次只推进一件事：生成问题、吸收回答、判断推进、输出调研结论四者不得混在同一轮里乱写
- 当前动作内必须先分清输入类型：背景材料、会面问题、会后回答、旧产物四类不得混用
- 背景材料只能用于补事实、缩小待确认项或重生成问题提纲；不得写进任何 `A：` 回答槽位
- 用户未明确提供 `A：` 或等价会后回答时，不得把背景材料、旧文档、常识推断或旧产物内容回填成回答
- 调研稿对外表达必须去 AI 化，不写 `AI`、`AI 当前`、`由 AI 判断`、`AI建议`、`AI提示`、`AI生成`
- 不写解释模板用途的说明性文字，例如“本文件用于记录”“已区分”“以下是”“当前第几轮已可推进”
- 资料来源使用人类可读名称，不写绝对路径、机器路径、调试路径
- `下一步` 一律写成：`下一步：`
- 调研结束后如具备进入方案条件，默认下一步命令只能推荐 `/solution`
- `当前已确认事实`、`当前未确认内容`、`判断依据` 统一放在文末 `内部依据与未确认内容`
- 未通过当前动作的最低判断，不得把会面问题包装成稳定方案
- 若关键事实缺口阻塞推进，在当前动作内只生成最小追问
- 调研稿必须优先使用 `docs/templates/disc-note.template.md`
- 首轮默认输出问题提纲，不输出完整方案
- 当当前轮目标是生成问题提纲时，产出提纲后默认停在本轮；不得自行补写会后判断或下一轮问题
- PM 填完 `A：` 后，先判断是否足够进入方案阶段；不能推进时只生成下一轮差量问题
- 第二轮及以后只问差量问题，不重复问已确认事实
- 只有确认足够进入方案阶段后，才输出调研结论
- 推进判断由当前动作完成；能推进时生成调研结论，不能推进时生成下一轮差量问题或补材料清单
- 当前动作结束前必须直接完成上下文包自检：`request_summary / solution_shape / business_stage / material_paths / context_gaps` 至少要能支撑“能否进入方案”的判断
- 上下文自检不过时，不得进入方案阶段，必须先补上下文包、补材料或回到追问
- `context_package.solution_shape` 必须在离开当前动作前满足以下之一：
  - 已判为 `iteration`
  - 已判为 `new_build`
  - 已判为 `hybrid`
  - 明确记录“暂不能判断”以及阻塞原因
- 调研结论不是方案稿，不冻结模块、页面、关键元素、关键动作或关键约束
- 若对齐已超过 4 轮，必须先生成轮次摘要再继续吸收新增信息
- 若对齐已超过 6 轮，必须先冻结当前状态，再决定继续追问还是允许推进
- `context_risk` 的 `length_signals / complexity_signals / decision` 必须使用 `contracts/context-guard.md` 中的标准口径
- 当 `solution_shape` 为 `iteration` 时，必须优先问清挂载点、改造入口、存量约束
- 当 `solution_shape` 为 `new_build` 时，必须优先问清模块边界、主流程、角色边界
- 当 `solution_shape` 为 `hybrid` 时，必须优先问清哪些沿用、哪些新建、两者怎么衔接
- 仅参考旧系统字段、流程、页面或文案时，不得判为 `hybrid`
- 若部署、代码、数据库、运行实例都是全新的，只是业务规则参考旧系统，默认优先判为 `new_build`
- 模块级粗估只给区间，不给伪精确数字；粗估必须带出复杂度来源、关键风险和排期影响
- 最终对外承诺仍由 PM 拍板

## 回写要求

- 更新 `.ohmypm/status.json` 中的：
  - `current_stage`
  - `current_mode`
  - `last_action`
  - `next_recommended`
  - `alignment_state.*`
  - `context_package.*`
  - `context_risk.level`
  - `context_risk.length_signals`
  - `context_risk.complexity_signals`
  - `context_risk.decision`
  - `context_risk.last_updated`
