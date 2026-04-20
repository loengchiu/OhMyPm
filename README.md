# OhMyPm

## 当前定位

`OhMyPm` 仍然保持自己的定位：

- 一个帮助 PM 在复杂存量系统环境中接收需求、持续对齐并生成正式交付的辅助器

当前要落实的不是定位变更，而是共存边界。

共存原则以 `D:\work\ShitPM\ohmypm\COEXISTENCE.md` 为准：

- 状态分离
- 目录分离
- 预留单向交接

这不等于现在就改成由 `ShitPM` 接管主线，只是先把以后真要衔接时的大改成本降下来。

## 默认使用方式

默认通过自然语言使用 OhMyPm。

你不需要先判断该敲哪个命令，也不需要先看 runbook 才能开始。

对外默认心智是：

- 你面对的是一个会自己判断下一步的协作助手
- 不是一个要你自己操作流程状态的系统
- 你只需要提需求、补反馈，或者回答它抛出的唯一问题

它每次只会做一件事，并且最后只会以两种方式收口：

- `现在建议你做的下一步是：...`
- `现在只需要你回答的唯一问题是：...`

短命令只保留给调试、强制指定入口和高级用户使用。

## 固定动作流

对外固定动作只保留以下几类：

- 接收需求
- 生成回应稿
- 继续对齐
- 交付前检查
- 生成原型
- 生成 PRD
- 开评审
- 处理变更
- 修正问题

你不需要记住这些动作背后的内部实现名。  
系统会根据当前状态自动判断现在该走哪一步。

## 分层加载

运行时固定采用五层加载：

1. 入口层：只判断当前意图、主控权和真实/样例场景
2. 状态层：只读最小状态与最小项目记忆摘要
3. 决策层：只读取当前动作对应的单个 skill 与必要规则
4. 交付层：只在进入重动作时读取交付规则、局部材料和稳定基线
5. 归档层：只回写稳定路径、摘要、索引和状态

这套分层的目的，是让模型先用小上下文跑起来，再按需逐层补充，而不是一上来吞整套规则和历史。

## 单一主控入口

当前主控入口固定为：

```powershell
powershell -File .\scripts\control\ompgo.ps1
```

它只做一条运行链：

1. 读最小状态
2. 判断当前动作
3. 只加载一个 skill 和必要规则
4. 判断是否需要主动提问或内部修正
5. 回写状态
6. 只保留唯一下一步

脚本目录固定分层：

- `scripts/control/`：主控脚本
- `scripts/tools/`：底层工具脚本

## 激活与状态

`OhMyPm` 不占用主 `docs/project-status.json`。

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

## 预留交接

当前阶段先预留单向交接接口：

- `OhMyPm` -> `ShitPM`

最小交接对象应位于：

- `docs/ohmypm/handoff.md`
  或
- `docs/ohmypm/handoff.json`

它是未来可选的 `ShitPM` 输入，不是 `ShitPM` 状态文件本身。

## 快速验证

最小链路自动验证：

```powershell
powershell -File .\scripts\control\demo-smoke.ps1
```

更多运行说明见：

- `docs/usage.md`
- `contracts/loading.md`
- `docs/architecture/workflow.md`
- `docs/architecture/responsibility-boundaries.md`
