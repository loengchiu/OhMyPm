# AGENTS / contracts / skills / docs 责任边界

## 1. 总原则

同一件事只保留一个主责层。

禁止：

- 在 `AGENTS.md` 重复展开完整规则
- 在 `contracts/` 重复写教程式入口说明
- 在 `skills/` 重复定义总规则
- 在 `docs/` 重复定义运行时约束

## 2. 责任边界表

| 层 | 只负责什么 | 不负责什么 |
| --- | --- | --- |
| `AGENTS.md` | 激活条件、主控权判断、五层加载总原则、动作路由原则、强禁止项 | 细规则、完整枚举、教程式说明 |
| `contracts/` | 运行时规则、门禁、上下文控制、ask-back、交付、评审、复写、记忆等硬约束 | 默认入口说明、动作教程、样例演示脚本说明 |
| `skills/` | 单个动作如何执行、该动作最少读什么、该动作最低输出要求 | 总流程定义、全局路由、重复抄写所有 contract |
| `docs/` | 人能看懂的说明、架构视图、动作卡片、进度清单、runbook | 代替运行时主控、代替 contract 做硬规则判定 |
| `scripts/control/` | 单一主控入口、初始化、最小链路回放 | 承载所有零散工具逻辑 |
| `scripts/tools/` | 路由解析、状态机判断、门禁、ask-back、状态回写、记忆回写、评审、复写、材料抽取等底层工具 | 对外主入口、默认协作心智 |

## 3. 当前单一主控链

固定链路：

1. `AGENTS.md` 决定是否进入 OhMyPm
2. `scripts/tools/state-machine.ps1` 读取最小状态并判断当前主链位置
3. `scripts/tools/route-resolve.ps1` 判断当前动作
4. `scripts/control/ompgo.ps1` 汇总路由、门禁、ask-back 与唯一收口
5. 只加载一个 `skills/omp-*/SKILL.md`
6. 只补当前动作必要的 `contracts/*.md`
7. 需要时调用 `scripts/tools/*.ps1`
8. 回写 `.ohmypm/status.json`
9. 对外只保留唯一下一步

