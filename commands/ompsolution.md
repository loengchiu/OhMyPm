# /ompsolution

用于强制进入“方案”动作。

这是调试入口和强制入口，不是默认使用方式。

本命令只负责：

- 基于调研结论生成或更新当前版本方案稿
- 吸收 PM 对方案稿的修改
- 判断当前方案是否足够进入原型或 PRD

建议先执行：

```powershell
python D:\work\OhMyPm\scripts\python\ohmypm_tools.py context-lint --status-path .ohmypm/status.json
python D:\work\OhMyPm\scripts\python\ohmypm_tools.py stage-gate --gate omp-solution
```

`fail` 时先补上下文，不生成稳定方案稿。
