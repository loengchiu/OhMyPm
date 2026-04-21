# /ompalign

用于强制进入“对齐”动作。

这是调试入口和强制入口，不是默认使用方式。

本命令只负责：

- 吸收新增反馈
- 更新方案、变化点、模块和粗估
- 判断是对齐还是准备进入开工检查

建议先执行：

```powershell
powershell -File .\scripts\tools\stage-gate.ps1 -Gate omp-align
```
