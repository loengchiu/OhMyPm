# /ompprd

直接进入 `omp-deliver-prd`，用于生成正式 PRD。

进入前应确认：

- 已通过正式交付门禁
- 当前原型已形成稳定表达
- 长文输出已准备按分块方式生成

本命令负责：

- 生成正式归档主文件
- 与原型分工互补
- 写入 `stable_baselines.prd`

建议先执行：

```powershell
powershell -File .\scripts\stage-gate.ps1 -Gate omp-deliver
```
