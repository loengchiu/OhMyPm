# /ompsolution

用于强制进入“方案”动作。

这是调试入口和强制入口，不是默认使用方式。

本命令只负责：

- 基于调研结论生成或更新当前版本方案稿
- 吸收 PM 对方案稿的修改
- 判断当前方案是否足够进入原型或 PRD

建议先执行：

```powershell
powershell -File .\scripts\tools\context-lint.ps1 -StatusPath .ohmypm/status.json
powershell -File .\scripts\tools\stage-gate.ps1 -Gate omp-solution
```

`fail` 时先补上下文，不生成稳定方案稿。
