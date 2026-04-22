# OhMyPm 最小上下文包契约

## 1. 作用

本契约用于约束 `听需求` 和 `先回应` 阶段的最小上下文收集。

目标不是做重访谈，而是避免 OMP 凭空猜。

## 2. 最小结构

状态中的最小上下文包固定放在 `context_package`，至少包含：

- `request_summary`
- `business_stage`
- `system_or_page_clues`
- `material_paths`
- `context_gaps`

## 3. 字段要求

### 3.1 `request_summary`

- 用人话写一句当前想做什么
- 不得直接照抄方法论术语

### 3.2 `business_stage`

- 写当前需求大概落在哪个业务环节
- 例如：申请、审批、登记、查询、报表、通知

### 3.3 `system_or_page_clues`

- 记录现有系统、模块、页面、入口或截图线索
- 可以为空数组
- 为空时，不代表阻断，但应优先进入后续补齐判断

### 3.4 `material_paths`

- 记录当前已拿到的文档、截图、手册、旧 PRD 等资料路径
- 可以为空数组

### 3.5 `context_gaps`

- 只记录当前会影响回应质量的缺口
- 普通优化建议不得写进这里

## 4. 最低通过标准

`omp-reply` 前的最小上下文包至少满足：

- `request_summary` 非空
- `business_stage` 非空
- `system_or_page_clues` 和 `material_paths` 两个字段都存在
- `context_gaps` 字段存在

说明：

- 线索和资料允许为空
- 但不能既不记录线索，也不记录“当前没有线索”

## 5. 缺口处理

出现以下情况时，不得伪装成“已理解需求”：

- `request_summary` 为空
- `business_stage` 为空
- 上下文包字段缺失

出现以下情况时，可继续进入回应，但必须显式保留缺口：

- 现有系统或页面线索为空
- 现成资料为空

## 6. 正文边界

- 最小上下文包属于内部运行信息
- 不进入 PRD 正文
- 不进入原型正文
- 可进入状态、项目记忆、对齐承接材料

## 7. 适用动作

本契约优先约束以下动作：

- `omp-listen`
- `omp-reply`
- `omp-check`
