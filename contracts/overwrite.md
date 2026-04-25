# OhMyPm 下游修正上游规则

## 1. 定义

当下游产物发现上游文件存在错误、遗漏、冲突或失效结论时，必须触发正式判定，而不是只在下游私自修补。

## 2. 触发场景

- PRD 暴露功能或范围缺项
- 原型暴露页面结构错误
- 评审意见推翻先前结论
- 修复记录证明稳定基线失效

## 3. 判定步骤

1. 标记冲突来源和受影响上游文件
2. 判断是局部补充、局部修正还是整体失效
3. 决定继续推进、局部回退还是整体回退
4. 回写被修正的上游文件、状态文件和项目记忆
5. 记录复写原因、证据和影响范围

## 4. 强制规则

- 下游不得默默覆盖上游结论
- 版本关系未判清时必须停止推进
- 复写后必须更新稳定基线或撤销稳定状态
- `restart_alignment` 不得继续保留 `ready_for_preflight`
- `restart_alignment` 必须把当前推进状态拉回对齐链

## 5. 冲突分类

复写判定时，冲突至少归为以下之一：

- `missing_scope`
- `missing_rule`
- `structure_conflict`
- `baseline_stale`
- `review_reversal`

## 6. 处理级别

处理级别固定为三档：

- `patch`
- `rollback_upstream`
- `restart_alignment`

## 7. 统一输出格式

复写判定必须输出：

- `affected_upstream`
- `conflict_type`
- `severity`
- `action_level`
- `writeback_targets`
- `can_continue`
- `reason`

## 8. 回写约束

复写判定应用到状态时，至少应满足：

- `patch`
  - `fallback_type=internal_repair`
  - 当前阶段可保持修复态
- `rollback_upstream`
  - `fallback_type=internal_repair`
  - 当前阶段可保持修复态
- `restart_alignment`
  - 转入对齐链
  - `current_mode=alignment_loop`
  - `fallback_type=reopen_alignment`
  - `alignment_state.round_result=continue_alignment`

补充规则：

- `restart_alignment` 时，`can_continue` 必须为 `false`

