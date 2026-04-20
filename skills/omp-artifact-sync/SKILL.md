---
name: omp-artifact-sync
description: "同步状态文件、稳定基线、产物索引和必要的复写记录。"
---

# Artifact Sync

## 读取顺序

第 0 层：最小状态

1. `docs/ohmypm/ohmypm-status.json`

第 1 层：当前动作 skill

2. 当前只执行 `omp-artifact-sync`，不得默认并读其他 skill

第 2 层：当前动作必要 contract

3. 无默认 contract；仅当当前同步内容需要校验特定规则时，才读取对应单一 contract

## 目标

- 更新 `docs/ohmypm/ohmypm-status.json`
- 必要时刷新 `stable_baselines`
- 同步最新产物路径
- 记录复写影响

## 建议脚本

- `scripts/artifact-sync.ps1`
- `scripts/status-apply.ps1`

## 可同步字段

- `current_stage`
- `current_mode`
- `current_version`
- `last_action`
- `next_recommended`
- `context_summary`
- `stable_baselines.*`
- `latest_artifacts.*`
- `blockers`
- `pending_confirmations`
- `review_state.*`
- `overwrite_queue`

## 标准化输入

若宿主更适合先产出结构化载荷，再统一落盘，可使用：

- `docs/examples/status-apply.sample.json`
- `scripts/status-apply.ps1`

## 强制规则

- 不得为了保险预读多个 contract
- 只同步当前动作明确需要的状态字段
- 输出最后必须只给一个“下一步唯一动作”
