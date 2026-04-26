# /ompdisc

用于强制进入“调研”动作。

这是调试入口和强制入口，不是默认使用方式。

本命令只负责：

- 强制进入当前调研轮次
- 形成会面问题提纲、会后判断和调研结论

建议先执行：

```powershell
python D:\work\OhMyPm\scripts\python\ohmypm_tools.py stage-gate --gate omp-disc
python D:\work\OhMyPm\scripts\python\ohmypm_tools.py context-lint --status-path .ohmypm/status.json
```

`fail` 时先补上下文，不进入方案。
