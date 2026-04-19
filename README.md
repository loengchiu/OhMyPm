# OhMyPm

## How To Use

默认通过自然语言使用 OhMyPm。

你不需要先判断该敲哪个命令，也不需要先看 runbook 才能开始。

系统会先自动判断你当前是在：

- 回应需求
- 继续对齐
- 需要先回答阻塞问题
- 做交付前检查
- 做交付型原型
- 写正式 PRD
- 开评审
- 处理变更
- 修复已有产物

短命令只保留给调试、强制指定入口和高级用户使用。

## Quick Checks

最小链路自动验证：

```powershell
powershell -File .\scripts\demo-smoke.ps1
```

更多运行说明见：

- `docs/usage.md`
- `docs/runbooks/demo-flow.md`
- `docs/runbooks/round-state-flow.md`
- `docs/runbooks/prototype-runbook.md`
- `docs/runbooks/prd-runbook.md`
- `docs/runbooks/review-runbook.md`
- `docs/runbooks/fix-runbook.md`
