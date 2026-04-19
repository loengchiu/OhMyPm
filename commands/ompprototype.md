# /ompprototype

直接进入 `omp-deliver-prototype`，用于生成交付型原型。

进入前应确认：

- 已通过正式交付门禁
- `loop_state.round_result=ready_for_preflight`
- 当前没有要求回退的 `fallback_state.fallback_type`

本命令负责：

- 生成评审会主展示物
- 写入 `stable_baselines.prototype`
- 为后续 `ompreview` 准备可评审原型基线

建议先执行：

```powershell
powershell -File .\scripts\stage-gate.ps1 -Gate omp-deliver
```
