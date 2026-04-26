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

## 3.1 单点变更传播检查

任何 PRD、原型或方案中的单点改动，都不得只修当前句子、表格、页面或标注。必须先检查同一交付包内的关联位置是否需要同步，再判断是否影响稳定基线。

常见传播方向：

- 页面动作变化：检查页面说明、主流程、按钮条件、状态变化、异常处理、权限、验收和原型标注
- 字段或数据口径变化：检查数据影响、页面展示、表单录入、校验、接口影响、权限、验收和 PRD 规则正文
- 状态变化：检查状态流转、列表筛选、详情展示、按钮可见性、通知/回流和异常分支
- 权限变化：检查角色说明、权限矩阵、页面按钮、数据范围和异常提示
- 规则阈值变化：检查业务规则、页面提示、提交校验、异常提示、测试边界和验收标准
- 原型标注变化：检查 PRD 对应规则、页面列表、主流程和追溯元数据

若关联位置未同步，不得判定修复完成；若传播结果推翻当前版本方案、模块范围或主流程，必须进入复写判定。

### 3.1.1 传播检查输出

每次修复必须输出一段传播检查结果，最少包含：

- `changed_points`：本轮实际改动点
- `linked_targets`：按页面、流程、规则、权限、数据影响、验收、原型标注列出的关联位置
- `synced_targets`：已经同步完成的位置
- `unsynced_targets`：仍未同步的位置；没有则写空数组
- `baseline_impact`：是否影响当前版本方案、PRD、原型或追溯元数据
- `status`：`complete / incomplete / not_applicable`
- `next_action`：下一步唯一动作

判定规则：

- `unsynced_targets` 非空时，`status` 必须为 `incomplete`
- `status=incomplete` 时，不得给出“修复完成”结论
- `baseline_impact` 不为空时，必须继续做复写判定

## 4. 强制规则

- 下游不得默默覆盖上游结论
- 版本关系未判清时必须停止推进
- 复写后必须更新稳定基线或撤销稳定状态
- 单点变更未完成传播检查时，不得进入评审或下一交付动作
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

- `propagation_check`
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

