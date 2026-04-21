# 轮次状态流转

## 目标

提供一份简明参考，说明轮次状态、回退状态和变更状态如何在 OhMyPm 主循环中流转。

## 核心规则

- `loop_state.round_result` only uses:
  - `continue_alignment`
  - `need_materials`
  - `need_internal_repair`
  - `ready_for_preflight`
- `fallback_state.fallback_type` only uses:
  - `internal_repair`
  - `need_materials`
  - `reopen_alignment`
- `reopen_alignment` 是回退动作，不是轮次结果
- 只有正式进入新一轮对齐时，才递增 `round_number`

## 主流程

### 1. Respond

用于当前请求需要第一版可信回应时。

典型输出：

- 当前版本方案
- 未澄清问题
- 模块级粗估
- 可选的对齐型原型建议

典型状态写法：

- `RoundResult=continue_alignment`
- `FallbackType` 为空

参考：

- `docs/examples/respond-status.sample.json`

### 2. Align

用于收到新反馈、截图或补充澄清时。

典型输出：

- 更新后的变化点
- 更新后的模块清单
- 更新后的工时和排期影响
- 更新后的轮次历史摘要

可能的状态写法：

- 对齐：
  - `RoundResult=continue_alignment`
- 等待资料：
  - `RoundResult=need_materials`
  - `FallbackType=need_materials`
- 先做内部整理：
  - `RoundResult=need_internal_repair`
  - `FallbackType=internal_repair`
- 可进入 preflight：
  - `RoundResult=ready_for_preflight`
  - `FallbackType` empty

参考：

- `docs/examples/align-status.sample.json`
- `docs/examples/fallback-status.sample.json`

### 3. Preflight

仅在当前轮次已经稳定到足以做正式交付检查时使用。

进入条件：

- `RoundResult` 必须已经是 `ready_for_preflight`

如果 preflight 通过：

- 进入正式交付

如果 preflight 不通过：

- 选择一种回退方式：
  - `internal_repair`
  - `need_materials`
  - `reopen_alignment`

注意：

- 不要把 `RoundResult` 改写成 `reopen_alignment`
- 如果 fallback 是 `reopen_alignment`，下一次正式进入对齐时才创建新的 `RoundNumber`

参考：

- `docs/examples/preflight-status.sample.json`
- `docs/examples/reopen-alignment.sample.json`

### 4. Change Control

用于正式交付后出现新增范围时。

先做分类：

- `minor_patch`
- `within_module`
- `new_module`
- `structural_change`

判定规则：

- `new_module` 和 `structural_change` 需要 PM 确认
- 如果主结构被推翻，优先选择 `reopen_alignment`，不要静默合并

参考：

- `docs/examples/change-status.sample.json`

## 快速判断

### 什么时候可以增加轮次编号？

只有正式开启新一轮对齐时才可以。

### 能不能把 `reopen_alignment` 写成轮次结果？

不能。它只属于 `fallback_state.fallback_type`。

### 什么时候更新 `loop_state.history_summary`？

通常在以下场景更新：

- 已累计 2-3 轮正式对齐
- 发生了结构性变化
- 即将进入 preflight
- 后续会话需要快速接管
