# /ompgo

初始化或进入 OhMyPm 工作流。

默认行为：

- 读取 `docs/project-status.json`
- 若不存在，则创建最小初始化文件
- 若存在，则按 `AGENTS.md` 进入当前阶段
- 若当前处于回应/对齐循环，优先读取：
  - `loop_state.round_number`
  - `loop_state.round_result`
  - `fallback_state.fallback_type`
  - `change_state.change_category`
- 若检测到 `fallback_state.fallback_type=reopen_alignment`，下一步应回到正式对齐轮次，而不是把 `reopen_alignment` 写成轮次结果

启动后优先判断：

- 当前在哪个阶段
- 当前轮次是否已闭合
- 是否存在门禁失败后的回退动作
- 是否需要更新轮次历史摘要

建议脚本：

- `scripts/init-project.ps1`
- `scripts/stage-gate.ps1`
