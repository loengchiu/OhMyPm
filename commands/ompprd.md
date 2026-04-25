# /ompprd

直接进入 `omp-prd`，用于生成正式 PRD。

进入前应确认：

- 已通过正式交付门禁
- 当前原型已形成稳定表达
- 长文输出已准备按分块方式生成

本命令负责：

- 生成正式归档主文件
- 与原型分工互补
- 写入 `baselines.prd`
- 让当前主链停在“可判断模板和规则是否够用”的状态

建议先执行：

```powershell
powershell -File .\scripts\tools\stage-gate.ps1 -Gate omp-deliver
```

PRD 回写后必须执行：

```powershell
powershell -File .\scripts\tools\trace-lint.ps1 -StatusPath .ohmypm/status.json
```

`fail` 时先修锚点、路径或泄漏问题，不进入评审。

