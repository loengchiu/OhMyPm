---
name: omp-change
description: "处理正式交付后的新增内容或范围变化，判断是否并入、重开对齐或转入变更。"
---

# Change

## 读取顺序

1. `docs/project-status.json`
2. `docs/project-memory.md`
3. `contracts/gates.md`
4. `contracts/overwrite.md`

## 目标

- 判断新增内容类型
- 判断是否影响模块、工时、排期、主流程和 PRD 范围
- 决定并入、修复、重开对齐或转入变更

## 必读状态

- `stable_baselines.prototype`
- `stable_baselines.prd`
- `change_state.change_category`
- `change_state.change_category_confirmed_by_pm`
- `latest_artifacts.change_records`
- `overwrite_queue`

## 最低输出

- 变化分类
- 影响范围
- 处理路径
- 是否需要重开对齐

## 强制规则

- `change_state.change_category` 只能使用：
  - `minor_patch`
  - `within_module`
  - `new_module`
  - `structural_change`
- 变更分类由 AI 先初判，PM 最终确认
- 当分类为 `new_module` 或 `structural_change` 时，不得默认吞入当前交付
- 当分类为 `new_module` 或 `structural_change` 时，必须显式记录 `change_state.change_category_confirmed_by_pm`
- 若变更推翻主结构，应将下一步写为 `reopen_alignment` 或转正式变更流程，而不是直接补 PRD

## 回写要求

- 更新 `docs/project-memory.md` 中的：
  - `本轮变化点`
  - `当前建议`
  - 必要时 `复写记录`
- 更新 `docs/project-status.json` 中的：
  - `current_stage`
  - `last_action`
  - `next_recommended`
  - `change_state.change_category`
  - `change_state.change_category_confirmed_by_pm`
  - `latest_artifacts.change_records`
  - 必要时 `overwrite_queue`
