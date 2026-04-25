# /ompdisc

用于强制进入“调研”动作。

这是调试入口和强制入口，不是默认使用方式。

本命令只负责：

- 强制进入当前调研轮次
- 形成会面问题提纲、会后判断和调研结论

建议先执行：

```powershell
powershell -File .\scripts\tools\stage-gate.ps1 -Gate omp-disc
powershell -File .\scripts\tools\context-lint.ps1 -StatusPath .ohmypm/status.json
```

`fail` 时先补上下文，不进入方案。
