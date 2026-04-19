---
name: omp-fix
description: "修正已有产物缺陷，并在需要时触发下游修正上游的判定复写。"
---

# Fix

## 读取顺序

1. `docs/project-status.json`
2. `docs/project-memory.md`
3. `contracts/overwrite.md`
4. `contracts/review.md`

## 目标

- 修正评审或执行过程中发现的问题
- 判断是否影响稳定基线
- 必要时回写上游

## 执行顺序

1. 确认当前修复对象和目标版本
2. 判断问题是否仅为局部修订，还是已影响上游结论
3. 若影响上游，调用 `omp-overwrite-judge`
4. 产出复写判定 JSON
5. 调用 `scripts/overwrite-apply.ps1`
6. 回写状态与项目记忆

## 必读状态

- `stable_baselines.*`
- `review_state`
- `overwrite_queue`
- `latest_artifacts.fix_records`

## 阻断条件

- 修复对象路径不清
- 存在多个版本但关系未判清
- 复写判定要求回退而当前仍试图直接推进

## 建议脚本

- `scripts/overwrite-judge.ps1`
- `scripts/overwrite-apply.ps1`

## 回写要求

- 更新 `docs/project-memory.md` 中的：
  - `复写记录`
  - 必要时 `当前建议`
- 更新 `docs/project-status.json` 中的：
  - `current_stage`
  - `last_action`
  - `next_recommended`
  - `overwrite_queue`
  - 必要时 `stable_baselines.*`
