# 固定动作卡片

## 接收需求

- 最小输入：需求原话，或一个要初始化的新项目上下文
- 最小输出：建立当前协作上下文，明确下一步进入生成回应稿还是先补初始化
- 回写：`docs/ohmypm/ohmypm-status.json` 的当前阶段、最近动作；必要时初始化 `docs/ohmypm/ohmypm-memory.md`

## 生成回应稿

- 最小输入：最小状态、最小记忆摘要、当前需求内容
- 最小输出：当前理解、当前版本方案、未确认事实、粗量级判断
- 回写：`last_action`、`next_recommended`、`context_summary`，必要时补 `latest_artifacts.response_notes`

## 继续对齐

- 最小输入：上一版回应结果、最新反馈、最小状态
- 最小输出：变化点、模块清单更新、是否继续对齐或进入交付前检查
- 回写：`loop_state.*`、`pending_confirmations`、`next_recommended`

## 交付前检查

- 最小输入：已收敛的对齐结果、最小状态、交付承接信息
- 最小输出：通过或不通过，以及唯一下一步
- 回写：`loop_state.round_result`、`fallback_state.*`、`next_recommended`

## 生成原型

- 最小输入：通过交付前检查的方案、交付骨架、最小状态
- 最小输出：交付型原型本体
- 回写：`stable_baselines.prototype`、`latest_artifacts.prototypes`、`last_action`

## 生成 PRD

- 最小输入：通过交付前检查的方案、原型承接信息、PRD 骨架
- 最小输出：正式 PRD 主文件
- 回写：`stable_baselines.prd`、`latest_artifacts.prd`、`last_action`

## 开评审

- 最小输入：当前交付物、评审材料、最小状态
- 最小输出：统一评审结论和必须修正项
- 回写：`review_state.*`、`latest_artifacts.review_records`、`next_recommended`

## 处理变更

- 最小输入：正式交付基线、当前新增诉求、最小状态
- 最小输出：变更归属判断，以及继续并入、重开对齐或正式变更的唯一下一步
- 回写：`change_state.*`、`pending_confirmations`、`next_recommended`

## 修正问题

- 最小输入：问题项、受影响基线、最小状态
- 最小输出：修正结果或上游复写结论
- 回写：`overwrite_queue`、`review_state.must_fix_before_next_stage`、相关交付物路径
