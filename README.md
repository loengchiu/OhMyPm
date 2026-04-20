# OhMyPm

## 当前定位

`OhMyPm` 仍然保持自己的定位：

- 一个帮助 PM 在复杂存量系统环境中回应需求、反复对齐并生成正式交付的辅助器

当前要落实的不是定位变更，而是共存边界。

共存原则以 `D:\work\ShitPM\ohmypm\COEXISTENCE.md` 为准：

- 状态分离
- 目录分离
- 预留单向交接

这不等于现在就改成由 `ShitPM` 接管主线，只是先把以后真要衔接时的大改成本降下来。

## How To Use

默认通过自然语言使用 OhMyPm。

你不需要先判断该敲哪个命令，也不需要先看 runbook 才能开始。

对外心智默认是：

- 你面对的是一个会自己判断下一步的协作型大 skill
- 不是一个要你自己操作状态机的流程系统
- 它可以独立帮助你把一个需求从接收到交付完整跑通
- 若未来验证后决定与 `ShitPM` 衔接，再通过预留交接接口处理

短命令只保留给调试、强制指定入口和高级用户使用。

## 激活与状态

`OhMyPm` 不再占用主 `docs/project-status.json`。

当前协作层自己的状态与记忆固定放在：

- `docs/ohmypm/ohmypm-status.json`
- `docs/ohmypm/ohmypm-memory.md`

只有 `ShitPM` 可以继续使用：

- `docs/project-status.json`

## 目录边界

`OhMyPm` 的中间材料、样例、交付前产物和缓存，统一收在：

- `docs/ohmypm/status/`
- `docs/ohmypm/memory/`
- `docs/ohmypm/alignment/`
- `docs/ohmypm/deliverables/`
- `docs/ohmypm/cache/`

`OhMyPm` 产物不是正式项目产物树。只有在明确进入正式项目层后，才允许把结果单向交接给 `ShitPM`。

## Handoff

当前阶段先预留单向交接接口：

- `OhMyPm` -> `ShitPM`

最小交接对象应位于：

- `docs/ohmypm/handoff.md`
  或
- `docs/ohmypm/handoff.json`

它是未来可选的 `ShitPM` 输入，不是 `ShitPM` 状态文件本身。

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
