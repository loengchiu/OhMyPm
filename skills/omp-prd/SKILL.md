---
name: omp-prd
description: "写 PRD。生成正式归档所需 PRD，补足规则、异常、权限、数据影响和验收说明。"
---

# 写 PRD

## 最小读取

- 先读 `.ohmypm/status.json`
- 再读 `.ohmypm/memory.md` 的最小必要摘要
- 当前只执行 `omp-prd`
- 默认只补 `contracts/gates.md`、`contracts/delivery.md`、`contracts/context-guard.md`、`contracts/anchors.md`、`contracts/traceability.md`、`contracts/boundary-guard.md`
- 系统记忆和外部知识只允许局部回查

## 目标

- 生成正式归档主文件 PRD
- 按两层九段结构组织内容
- 避免重复原型已清楚表达的页面内容
- 保证 PRD 规则正文挂在当前模块 / 页面 / 动作锚点上

## 必读状态

- `baselines.response_plan`
- `baselines.prototype`
- `alignment_state.round_result`
- `fallback_state`
- `baselines.prd`

## 执行顺序

1. 检查正式交付门禁
2. 读取原型与交付规则边界
3. 若需要系统记忆或外部知识，只允许读摘要、索引和局部片段
4. 分块写 PRD
5. 按补漏清单检查 PRD 缺口
6. 汇总长文摘要并回收上下文
7. 回写 PRD 基线与产物路径

详细需求说明阶段固定附加规则：

1. 先按模块切块
2. 再按页面切块
3. 最后按动作切块
4. 每个动作都必须有对应锚点

## 最低输出

- 一版两层九段结构的 PRD
- 与原型互补而不重复的规则说明
- 异常、边界、权限、数据影响和验收说明
- 一份补漏结果摘要

## 强制规则

- 未通过正式交付门禁，不得开始
- 长文必须分块生成并做摘要回收
- 详细需求说明必须遵守模块、页面、动作三层锚点规则
- PRD 不得脱离当前追溯元数据和锚点扩写
- PRD 初稿生成后必须执行一轮补漏检查
- 若当前原型尚未稳定，PRD 不得伪装为最终归档版本
- 不得默认同时读取多个 skill
- 不得为了保险一次读取很多 contract
- 不得整篇整包载入系统记忆、外部知识或长材料
- 输出最后必须只给一个“下一步唯一动作”

## 回写要求

- 更新 `.ohmypm/status.json` 中的：
  - `current_stage`
  - `current_mode`
  - `last_action`
  - `next_recommended`
  - `baselines.prd`
  - `artifacts.prd`

