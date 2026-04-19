---
name: omp-artifact-sync
description: "同步状态文件、稳定基线、产物索引和必要的复写记录。"
---

# Artifact Sync

## 目标

- 更新 `docs/project-status.json`
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
