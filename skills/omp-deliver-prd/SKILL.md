---
name: omp-deliver-prd
description: "生成正式归档所需 PRD，补足规则、异常、权限、数据影响和验收说明。"
---

# Deliver PRD

## 读取顺序

第 0 层：最小状态

1. `docs/ohmypm/ohmypm-status.json`
2. `docs/ohmypm/ohmypm-memory.md` 的最小必要摘要

第 1 层：当前动作 skill

3. 当前只执行 `omp-deliver-prd`，不得默认并读其他 skill

第 2 层：当前动作必要 contract

4. `contracts/gates.md`
5. `contracts/delivery.md`
6. `contracts/context-guard.md`

第 3 层：条件触发读取

7. 只有当当前 PRD 写作明确依赖系统记忆或外部知识时，才局部回查相关资料

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
3. 若需要系统记忆或外部知识，只允许读摘要、索引和局部片段
4. 分块生成 PRD
5. 汇总长文摘要并回收上下文
6. 回写 PRD 基线与产物路径

## 最低输出

- 一版两层九段结构的 PRD
- 与原型互补而不重复的规则说明
- 异常、边界、权限、数据影响和验收说明

## 强制规则

- 未通过正式交付门禁，不得开始
- 长文必须分块生成并做摘要回收
- 若当前原型尚未稳定，PRD 不得伪装为最终归档版本
- 不得默认同时读取多个 skill
- 不得为了保险一次读取很多 contract
- 不得整篇整包载入系统记忆、外部知识或长材料
- 对外默认表现为会自己判断下一步的协作型大 skill，不让 PM 自己判断命令或流程节点
- 输出最后必须只给一个“下一步唯一动作”

## 回写要求

- 更新 `docs/ohmypm/ohmypm-status.json` 中的：
  - `current_stage`
  - `current_mode`
  - `last_action`
  - `next_recommended`
  - `stable_baselines.prd`
  - `latest_artifacts.prd`
