---
name: omp-context-guard
description: "评估输入、上下文和输出规模风险，并决定是否分块、摘要、裁剪和回收。"
---

# Context Guard

## 读取顺序

1. `contracts/context-guard.md`
2. `docs/project-status.json`
3. 按需读取当前输入材料

输出：

- 风险来源
- 风险等级
- 分块策略
- 回收策略

## 执行顺序

1. 先调用 `scripts/context-plan.ps1`
2. 若输入过长，再调用 `scripts/material-extract.ps1`
3. 仅将分块计划和提取结果载入当前上下文
4. 长文生成后只保留摘要、索引和稳定路径

## 强制规则

- 风险等级为 `high` 时，不得直接整篇输入或整篇输出
- 必须先产出分块计划，再进入实际生成
- 来源材料过长时，优先写入 `docs/cache/material-extract.md`

## 建议脚本

- `scripts/context-plan.ps1`
- `scripts/material-extract.ps1`

## 默认分块模板

- `response` -> `module_or_problem_domain`
- `prototype` -> `page`
- `prd` -> `chapter_or_page_unit`
- `review_pack` -> `decision_bucket`
