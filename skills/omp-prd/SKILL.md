---
name: omp-prd
description: "写 PRD。生成正式归档所需 PRD，补足规则、异常、权限、数据影响和验收说明。"
---

# 写 PRD

## 最小读取

- 先读 `.ohmypm/status.json`
- 再读 `.ohmypm/memory.md` 的最小必要摘要
- 当前只执行 `omp-prd`
- 默认只补 `contracts/delivery.md`、`contracts/anchors.md`、`contracts/traceability.md`
- 门禁异常补 `contracts/gates.md`；长文补 `contracts/context-guard.md`
- 系统记忆和外部知识只允许局部回查

## 目标

- 生成正式归档主文件 PRD
- 按两层九段结构组织内容
- 保证 PRD 规则正文挂在当前模块 / 页面 / 动作锚点上
- 根据 `solution_shape` 选择写法重点
- 章节目录可按 OMP 骨架组织，正文写法、文风和规格表达默认对齐当前已验证成熟的 PRD 写法
- PRD 本身应支持独立归档、独立评审、独立实施；原型用于辅助理解页面呈现，PRD 负责完整交代规则、边界、权限、数据影响和验收

## 必读状态

- `baselines.response_plan`
- `baselines.prototype`
- `context_package.solution_shape`
- `alignment_state.round_result`
- `fallback_state`
- `anchors_state.meta.anchor_manifest`
- `baselines.prd`
- `solution-shape diff`

## 执行顺序

1. 检查正式交付门禁
2. 读取原型与交付规则边界
3. 若需要系统记忆或外部知识，只允许读摘要、索引和局部片段
4. 分块写 PRD
5. 按补漏清单检查 PRD 缺口
6. 汇总长文摘要并回收上下文
7. 回写 PRD 基线与产物路径
8. 执行 `trace-check`

详细需求说明阶段固定附加规则：

1. 先按模块切块
2. 再按页面切块
3. 最后按动作切块
4. 每个动作都必须有对应锚点

## 最低输出

- 一版两层九段结构的 PRD
- 与原型互补而不重复的规则说明
- 异常、边界、权限、数据影响和验收说明
- 一份补漏结果摘要

## 强制规则

- 未通过正式交付门禁，不得开始
- 长文必须分块生成并做摘要回收
- 详细需求说明必须遵守模块、页面、动作三层锚点规则
- PRD 不得脱离当前追溯元数据和锚点扩写
- PRD 生成时必须读取内部 `anchor_manifest`；正文标题使用自然标题，页面最多保留 `P1 / P2` 这类页面编号，完整组合锚点只保存在内部 manifest
- PRD 生成后必须执行 `python scripts/python/omp-lint.py trace-check --status-path .ohmypm/status.json`；结果为 `fail` 时不得进入评审，必须先修正 manifest、路径或机读字段泄漏
- PRD 只写正式归档正文，不写模板说明、方法论说明、元话语
- PRD 不出现 `AI`、绝对路径、调试路径、试跑结论等内部表述
- 除结构目录外，正文写法必须遵守以下默认风格：
  - 文档信息区使用简短正文或必要时最小列表表达
  - 背景、目标、范围、整体方案以自然段和短列表为主，表格只承担映射关系表达
  - 表格优先用于字段、枚举、权限、状态映射、验收映射这类天然适合映射的内容
  - 正文直接交代本章规则和结论，默认写成可独立阅读的归档正文
  - 对外资料引用使用人类可读名称，路径、链路和调试信息保留在内部状态或证据文件
  - 页面结构说明可压缩，但规则、边界、权限、数据影响和验收要求必须在本文中完整表达
  - 详细需求说明按“模块 → 页面 → 动作”展开，页面先概括区域职责，再按动作写规则
  - 动作说明使用自然规格说明写清默认展示、触发条件、交互顺序、状态变化、成功反馈、失败提示和边界限制
  - 规则描述使用具体条件、具体结果和明确边界，避免占位词和省略词
- PRD 必须读取“建设类型差异说明表”，按其中的 PRD 重点补足规则，不得自行切换为另一套结构
- 当 `solution_shape=iteration` 时，PRD 必须显式写清改造说明、挂载点、兼容约束和存量影响
- 当 `solution_shape=new_build` 时，PRD 必须显式写清新建范围、模块结构、角色边界和主流程规则
- 当 `solution_shape=hybrid` 时，PRD 必须把存量承接规则和新建规则分段写清
- PRD 初稿生成后必须执行一轮补漏检查
- 若当前原型尚未稳定，PRD 不得伪装为最终归档版本

## 回写要求

- 更新 `.ohmypm/status.json` 中的：
  - `current_stage`
  - `current_mode`
  - `last_action`
  - `next_recommended`
  - `baselines.prd`
  - `artifacts.prd`
