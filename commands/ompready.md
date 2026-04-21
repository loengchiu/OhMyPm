# /ompready

用于强制进入“开工检查”动作。

这是调试入口和强制入口，不是默认使用方式。

本命令只负责：

- 检查当前方案是否已足够稳定进入正式交付
- 给出是否能进入“原型 -> PRD”最小主链的结论

建议先执行：

```powershell
powershell -File .\scripts\tools\stage-gate.ps1 -Gate omp-ready
```
