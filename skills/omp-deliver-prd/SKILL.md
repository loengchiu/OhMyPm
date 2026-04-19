---
name: omp-deliver-prd
description: "生成正式归档所需 PRD，补足规则、异常、权限、数据影响和验收说明。"
---

# Deliver PRD

## 读取顺序

1. `docs/project-status.json`
2. `docs/project-memory.md`
3. `contracts/gates.md`
4. `contracts/delivery.md`
5. `contracts/context-guard.md`
6. 按需读取相关系统记忆卡

## 目标

- 生成正式归档主文件 PRD
- 按两层九段结构组织内容
- 避免重复原型已清楚表达的页面内容

## 必读状态

- `stable_baselines.response_plan`
- `stable_baselines.prototype`
- `loop_state.round_result`
- `fallback_state`
- `stable_baselines.prd`

## 执行顺序

1. 检查正式交付门禁
2. 读取原型与交付规则边界
3. 分块生成 PRD
4. 汇总长文摘要并回收上下文
5. 回写 PRD 基线与产物路径

## 最低输出

- 一版两层九段结构的 PRD
- 与原型互补而不重复的规则说明
- 异常、边界、权限、数据影响和验收说明

## 强制规则

- 未通过正式交付门禁，不得开始
- 长文必须分块生成并做摘要回收
- 若当前原型尚未稳定，PRD 不得伪装为最终归档版本

## 回写要求

- 更新 `docs/project-status.json` 中的：
  - `current_stage`
  - `current_mode`
  - `last_action`
  - `next_recommended`
  - `stable_baselines.prd`
  - `latest_artifacts.prd`
