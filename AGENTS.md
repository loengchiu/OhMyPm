# OhMyPm 工作流

当当前项目根目录存在 `docs/project-status.json` 时，OhMyPm 工作流激活。

## 1. 宿主总规则

当用户提出 PM 需求处理相关请求时：

1. 先读取 `docs/project-status.json`
2. 再读取 `docs/project-memory.md`
3. 根据当前任务需要，按需读取 `docs/system-memory/*.md` 和外部知识资料
4. 根据当前意图读取对应 `skills/{skill}/SKILL.md`
5. 先执行门禁判断，再执行上下文风险判断，再推进当前动作
6. 完成后回写状态文件、项目记忆文件，必要时回写系统记忆卡

未真实读取状态文件前，不得表述为“已确认可以推进”。

默认交互规则：

- 用户默认通过自然语言使用 OhMyPm
- 系统必须先自动判断当前意图属于：
  - `omp-respond`
  - `omp-align`
  - `omp-ask-back`
  - `omp-preflight`
  - `omp-deliver-prototype`
  - `omp-deliver-prd`
  - `omp-review`
  - `omp-change`
  - `omp-fix`
- 短命令只作为：
  - 调试入口
  - 强制指定入口
  - 高级用户入口

输出收口规则：

- 每次输出最后，必须只给一个“下一步唯一动作”
- 形式只能是以下两类之一：
  - `现在建议你做的下一步是：...`
  - `现在只需要你回答的唯一问题是：...`
- 不得一次给用户一串操作菜单
- 不得要求 PM 先去 runbook 或 usage 里自己挑下一步

## 2. 激活与未激活

- 若 `docs/project-status.json` 不存在：视为未初始化，只允许执行初始化说明、纯咨询或创建初始化文件
- 若 `docs/project-status.json` 存在：进入 OhMyPm 正式工作流

## 3. 主流程

OhMyPm 主流程固定为：

- `需求接收`
- `回应/校验循环`
- `交付前检查`
- `正式交付`
- `变更控制`

其中：

- 需求方可以继续提需求
- 系统不锁需求输入，但锁推进动作

## 4. 默认路由

### 自然语言主入口

自然语言是默认主入口。

用户意图与 skill 的默认映射：

- 初始化项目 -> `omp-intake`
- 新需求 / 补充需求 / 先回应一下 -> `omp-respond`
- 先问我需要确认的点 / 把待确认项抛给我 -> `omp-ask-back`
- 继续对齐 / 根据反馈调整 -> `omp-align`
- 检查能否进入正式交付 -> `omp-preflight`
- 做交付型原型 -> `omp-deliver-prototype`
- 写正式 PRD -> `omp-deliver-prd`
- 开评审 / 做评审会材料 -> `omp-review`
- 正式交付后新增需求 / 范围变化 -> `omp-change`
- 修正已有产物 -> `omp-fix`

### 短命令兜底入口

短命令只作为调试、强制指定和高级用户入口：

- `/ompgo` -> 初始化或进入 OhMyPm 工作流
- `/omprespond` -> `omp-respond`
- `/ompaskback` -> `omp-ask-back`
- `/ompalign` -> `omp-align`
- `/omppreflight` -> `omp-preflight`
- `/ompprototype` -> `omp-deliver-prototype`
- `/ompprd` -> `omp-deliver-prd`
- `/ompreview` -> `omp-review`
- `/ompchange` -> `omp-change`
- `/ompfix` -> `omp-fix`

## 5. 门禁强制规则

推进前必须读取 `contracts/gates.md`。

OhMyPm 固定采用四层门禁：

- 回应门禁
- 对齐推进门禁
- 正式交付门禁
- 变更门禁

任一门禁不通过时：

- 不得推进对应动作
- 必须说明缺失条件
- 必要时转入追问或内部整理

## 6. 上下文控制强制规则

推进前必须读取 `contracts/context-guard.md`。

当来源材料、当前上下文或目标输出存在爆炸风险时：

- 不得整篇载入
- 不得一次性整篇输出
- 必须改为抽取、分块、摘要、逐段生成和回收

## 7. 正式交付强制规则

推进正式交付时必须读取 `contracts/delivery.md`。

正式交付包固定包含：

- 交付型原型
- PRD

原型为评审和研发理解主入口，PRD 为正式归档主文件。

## 8. 知识协同强制规则

涉及系统知识时必须读取 `contracts/knowledge.md`。

规则：

- 外部知识主仓优先
- OhMyPm 按需读取
- AI 整理为系统记忆卡
- 系统记忆卡回写供人工阅读和修改

## 8.1 记忆强制规则

涉及项目记忆读取、系统记忆卡读取或记忆回写时，必须读取 `contracts/memory.md`。

## 8.2 追问强制规则

当前阶段若因信息不足无法过门禁时，必须读取 `contracts/ask-back.md`。

补充规则：

- 若 `pending_confirmations` 非空，且当前动作不是 `internal_repair` 或 `need_materials`，不得静默推进到更重阶段
- 若 `change_state.change_category_confirmed_by_pm=false`，不得把当前变更分类当作最终结论继续推进正式交付或正式变更处理

## 9. 复写与评审

- 下游发现上游结论错误、遗漏或冲突时，必须读取 `contracts/overwrite.md`
- 开评审会或形成评审结论时，必须读取 `contracts/review.md`

## 10. 禁止事项

- 不得替用户拍板范围
- 不得跳过门禁直接进入更重交付
- 不得在未判清版本关系时混用旧新产物
- 不得把新增需求默认吞进当前稳定版本
- 不得在高上下文风险下强行输出长文
