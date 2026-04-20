---
name: omp-fix
description: "修正已有产物缺陷，并在需要时触发下游修正上游的判定复写。"
---

# Fix

## 读取顺序

第 0 层：最小状态

1. `docs/ohmypm/ohmypm-status.json`
2. `docs/ohmypm/ohmypm-memory.md` 的最小必要摘要

第 1 层：当前动作 skill

3. 当前只执行 `omp-fix`，不得默认并读其他 skill

第 2 层：当前动作必要 contract

4. `contracts/overwrite.md`

第 3 层：条件触发读取

5. 仅当修复来源明确来自评审结论时，再读取 `contracts/review.md`

## 目标

- 修正评审或执行过程中发现的问题
- 判断是否影响稳定基线
- 必要时回写上游

## 执行顺序

1. 确认当前修复对象和目标版本
2. 判断问题是否仅为局部修订，还是已影响上游结论
3. 若影响上游，调用 `omp-overwrite-judge`
4. 产出复写判定 JSON
5. 调用 `scripts/tools/overwrite-apply.ps1`
6. 回写状态与项目记忆

## 必读状态

- `stable_baselines.*`
- `review_state`
- `overwrite_queue`
- `latest_artifacts.fix_records`
- `loop_state`
- `fallback_state`

## 阻断条件

- 修复对象路径不清
- 存在多个版本但关系未判清
- 复写判定要求回退而当前仍试图直接推进

## 建议脚本

- `scripts/tools/overwrite-judge.ps1`
- `scripts/tools/overwrite-apply.ps1`

## 强制规则

- 下游不得默默覆盖上游结论
- 若复写判定为 `restart_alignment`，下一步必须明确回到对齐链，不得继续假装处于正式交付
- 修复如果只解决局部缺陷，可保留当前阶段；若推翻基线，则必须同步更新 `overwrite_queue`
- 不得默认同时读取多个 skill
- 不得为了保险一次读取很多 contract
- 对外默认表现为会自己判断下一步的协作型大 skill
- 输出最后必须只给一个“下一步唯一动作”

## 回写要求

- 更新 `docs/ohmypm/ohmypm-memory.md` 中的：
  - `复写记录`
  - 必要时 `当前建议`
- 更新 `docs/ohmypm/ohmypm-status.json` 中的：
  - `current_stage`
  - `last_action`
  - `next_recommended`
  - `overwrite_queue`
  - 必要时 `stable_baselines.*`
