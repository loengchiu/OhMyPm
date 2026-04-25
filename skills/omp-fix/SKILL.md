---
name: omp-fix
description: "修正已有产物缺陷，并在需要时触发下游修正上游的判定复写。"
---

# Fix

## 最小读取

- 先读 `.ohmypm/status.json`
- 再读 `.ohmypm/memory.md` 的最小必要摘要
- 当前只执行 `omp-fix`
- 默认只补 `contracts/overwrite.md`
- 涉及锚点补 `contracts/traceability.md`；涉及评审回流补 `contracts/review.md`

## 目标

- 修正评审或执行过程中发现的问题
- 判断是否影响稳定基线
- 必要时回写上游

## 执行顺序

1. 确认当前修复对象和目标版本
2. 判断问题是否仅为局部修订，还是已影响上游结论
3. 若影响上游，直接调用治理脚本完成复写判定与状态同步
4. 产出复写判定 JSON
5. 调用 `scripts/tools/overwrite-apply.ps1`
6. 回写状态与项目记忆

## 必读状态

- `baselines.*`
- `review_state`
- `overwrite_queue`
- `artifacts.fix_records`
- `alignment_state`
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
- 若 `overwrite_queue` 非空，应优先处理修复，不得跳回继续交付

## 回写要求

- 更新 `.ohmypm/memory.md` 中的：
  - `复写记录`
  - 必要时 `当前建议`
- 更新 `.ohmypm/status.json` 中的：
  - `current_stage`
  - `last_action`
  - `next_recommended`
  - `overwrite_queue`
  - 必要时 `baselines.*`


