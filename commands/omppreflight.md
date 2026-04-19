# /omppreflight

直接进入 `omp-preflight`，用于正式交付前检查。

进入前应确认：

- `loop_state.round_result=ready_for_preflight`
- `pending_confirmations` 已清空
- 当前没有要求回退的 `fallback_state.fallback_type`

若本命令失败，必须明确回退动作：

- `internal_repair`
- `need_materials`
- `reopen_alignment`

其中：

- `reopen_alignment` 是回退动作，不是轮次结果
- 若走 `reopen_alignment`，应在重新进入正式对齐时递增轮次编号

建议先执行：

```powershell
powershell -File .\scripts\stage-gate.ps1 -Gate omp-preflight
```
