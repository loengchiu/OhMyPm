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
- `latest_artifacts.change_records`
- `overwrite_queue`

## 最低输出

- 变化分类
- 影响范围
- 处理路径
- 是否需要重开对齐

## 回写要求

- 更新 `docs/project-memory.md` 中的：
  - `本轮变化点`
  - `当前建议`
  - 必要时 `复写记录`
- 更新 `docs/project-status.json` 中的：
  - `current_stage`
  - `last_action`
  - `next_recommended`
  - `latest_artifacts.change_records`
  - 必要时 `overwrite_queue`
