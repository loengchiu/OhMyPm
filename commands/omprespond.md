# /omprespond

用于强制进入“生成回应稿”动作。

这是调试入口和强制入口，不是默认使用方式。

本命令只负责：

- 强制走首轮回应或补充回应
- 形成当前理解、当前版本方案和待确认项

建议先执行：

```powershell
powershell -File .\scripts\tools\stage-gate.ps1 -Gate omp-respond
```
