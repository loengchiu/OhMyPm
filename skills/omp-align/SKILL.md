---
name: omp-align
description: "回应/校验循环中的修正推进。根据反馈更新方案、变化点、模块判断与粗估。"
---

# Align

## 读取顺序

1. `docs/project-status.json`
2. `docs/project-memory.md`
3. `contracts/gates.md`
4. `contracts/context-guard.md`
5. 按需读取相关系统记忆卡

## 目标

- 根据反馈修正当前理解
- 更新本轮变化点
- 更新模块清单、粗估和排期影响
- 判断是否继续下一轮，或进入 `omp-preflight`

## 执行顺序

1. 检查对齐推进门禁
2. 归并本轮新增内容到事实、模块或变化点
3. 更新方案、粗估和排期影响
4. 判断继续下一轮还是进入 `omp-preflight`
5. 产出状态载荷和记忆载荷
6. 调用 `scripts/status-apply.ps1`
7. 调用 `scripts/memory-apply.ps1`

## 必读状态

- `current_version`
- `pending_confirmations`
- `latest_artifacts.response_notes`
- `stable_baselines.response_plan`
- `review_state`

## 阻断条件

- 本轮变化点说不清
- 新增内容尚未归并到模块或事实状态
- 无法判断新增内容是否影响主结构

## 建议脚本

- `scripts/status-apply.ps1`
- `scripts/memory-apply.ps1`

## 回写要求

- 更新 `docs/project-memory.md` 中的：
  - `本轮变化点`
  - `当前版本方案`
  - `当前模块清单`
  - `当前方案预估工时`
  - `排期影响判断`
  - `新增资料记录`
- 更新 `docs/project-status.json` 中的：
  - `current_stage`
  - `last_action`
  - `next_recommended`
  - 必要时 `pending_confirmations`
  - 必要时 `stable_baselines.response_plan`
