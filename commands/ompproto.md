# /ompproto

直接进入 `omp-proto`，用于做交付型原型。

进入前应确认：

- 已通过正式交付门禁
- `alignment_state.round_result=ready_for_preflight`
- 当前没有要求回退的 `fallback_state.fallback_type`

本命令负责：

- 生成当前最小主链的第一版原型本体
- 写入 `baselines.prototype`
- 为后续 `omp-prd` 提供页面、流程和编号基线

建议先执行：

```powershell
powershell -File .\scripts\tools\stage-gate.ps1 -Gate omp-deliver
```

