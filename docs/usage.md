# 使用说明

## 1. 初始化

### 1.1 安装

在 OhMyPm 仓库中执行：

```powershell
powershell -File .\installers\install.ps1
```

### 1.2 激活项目

在目标项目根目录执行：

```powershell
powershell -File <OHMYPM_PATH>\scripts\control\init-project.ps1
```

当项目根目录存在以下文件时，OhMyPm 激活：

- `.ohmypm/status.json`
- `.ohmypm/memory.md`

## 2. 默认入口

默认主入口是自然语言。

用户只需要直接说需求、补反馈，或者回答系统抛出的唯一问题。  
系统会自己判断当前动作，不需要用户自己决定该敲哪个命令。

对外固定动作只保留：

- 听需求
- 先回应
- 对齐
- 开工检查
- 做原型
- 写 PRD
- 评审
- 改需求
- 修问题

短命令只保留为：

- 调试入口
- 强制指定入口
- 高级用户入口

可用短命令：

- `/ompgo`
- `/omplisten`
- `/ompreply`
- `/ompcheck`
- `/ompalign`
- `/ompready`
- `/ompproto`
- `/ompprd`
- `/ompreview`
- `/ompchange`
- `/ompfix`

如需强制走主控脚本，统一入口是：

```powershell
powershell -File .\scripts\control\ompgo.ps1
```

这条入口固定只做六件事：

1. 读最小状态
2. 判断当前动作
3. 只加载一个 skill
4. 只加载必要规则
5. 回写状态
6. 只输出唯一下一步

## 3. 分层加载

运行时固定按五层加载：

1. 入口层：判断当前意图、主控权和真实/样例场景
2. 状态层：只读 `.ohmypm/status.json` 和 `.ohmypm/memory.md` 的最小必要摘要
3. 决策层：只按当前动作读取一个 skill 和少量必要规则
4. 交付层：只在重动作时读取交付规则、局部材料和稳定基线
5. 归档层：只回写稳定路径、摘要、索引和状态

禁止：

- 默认把多个 skill 一起读入
- 为了保险一次读很多规则
- 整篇整包载入外部知识或长材料

## 4. 输出收口

每次输出最后，系统必须只给一个“下一步唯一动作”。

形式只能是：

- `现在建议你做的下一步是：...`
- `现在只需要你回答的唯一问题是：...`

不得一次给 PM 一串操作菜单。  
不得要求 PM 自己从 runbook 或 usage 里挑下一步。  
不得直接把内部状态字段当作外部提问内容。

## 5. 常见动作

### 5.1 先回应

进入这个动作前，先读取：

- `.ohmypm/status.json`
- `.ohmypm/memory.md`
- 必要时 `contracts/context-guard.md`、`contracts/context-package.md` 与 `contracts/boundary-guard.md`

输出至少要覆盖：

- 当前理解
- 当前版本方案
- 未确认事实
- 未澄清问题
- 模块级粗估

### 5.2 对齐

进入这个动作后：

- 更新本轮变化点
- 更新模块清单
- 更新粗估和排期影响
- 判断是否对齐，还是进入开工检查

### 5.3 开工检查

这个动作只检查六项高价值闭合：

- 范围闭合
- 流程闭合
- 模块闭合
- 未澄清项风险
- 工时可解释
- 交付承接是否完整

只有通过这一关，才允许进入正式交付。

### 5.4 做原型与写 PRD

正式交付固定包含：

- 交付型原型
- PRD

默认分工：

- 原型负责让研发和评审先理解页面、流程和关键交互
- PRD 负责归档规则、异常、权限、数据影响和验收说明

### 5.5 评审

评审会需要形成统一结论，而不是普通确认。

统一输出至少包括：

- 事实问题
- 风险问题
- 建议问题
- 统一结论

### 5.6 推进检查

当存在最阻塞推进的问题时，应主动进入 `omp-check`，而不是继续推进。

`omp-check` 只做一件事：

- 向 PM 提一个最阻塞的问题

应用 PM 回答后的状态回写：

```powershell
powershell -File .\scripts\tools\ask-back-apply.ps1 `
  -AnsweredConfirmation 'Need confirmation on scope boundary' `
  -ChangeCategoryConfirmedByPm $true `
  -NextRecommended '回到刚才被卡住的阶段，并按最新确认结果重新判断是否可以推进。'
```

## 6. 常用规则和手册

核心规则文件：

- `contracts/loading.md`
- `contracts/ask-back.md`
- `contracts/context-guard.md`
- `contracts/context-package.md`
- `contracts/boundary-guard.md`
- `contracts/delivery.md`
- `contracts/review.md`
- `contracts/overwrite.md`

开发/验证手册：

- `docs/runbooks/respond-runbook.md`
- `docs/runbooks/ask-back-runbook.md`
- `docs/runbooks/align-runbook.md`
- `docs/runbooks/preflight-runbook.md`
- `docs/runbooks/prototype-runbook.md`
- `docs/runbooks/prd-runbook.md`
- `docs/runbooks/review-runbook.md`
- `docs/runbooks/change-runbook.md`
- `docs/runbooks/fix-runbook.md`
- `docs/architecture/responsibility-boundaries.md`
- `docs/architecture/action-cards.md`
- `docs/progress.md`

快捷验证：

- `powershell -File .\scripts\control\demo-smoke.ps1`

