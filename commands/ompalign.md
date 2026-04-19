# /ompalign

直接进入 `omp-align`，用于回应/校验循环中的修正推进。

进入前应确认：

- 当前轮的 `round_number`、`round_goal`、`round_inputs` 已存在
- `round_result` 只使用以下稳定值：
  - `continue_alignment`
  - `need_materials`
  - `need_internal_repair`
  - `ready_for_preflight`
- `reopen_alignment` 只能作为 `fallback_state.fallback_type`

本命令的核心动作：

- 归并本轮新增输入
- 更新当前输出、变化点、模块和粗估
- 必要时建议生成对齐型原型
- 更新 `loop_state.history_summary`

建议先执行：

```powershell
powershell -File .\scripts\stage-gate.ps1 -Gate omp-align
```
