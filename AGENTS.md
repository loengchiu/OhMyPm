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

### 短命令

- `/ompgo` -> 初始化或进入 OhMyPm 工作流
- `/omprespond` -> `omp-respond`
- `/ompalign` -> `omp-align`
- `/omppreflight` -> `omp-preflight`
- `/ompprototype` -> `omp-deliver-prototype`
- `/ompprd` -> `omp-deliver-prd`
- `/ompreview` -> `omp-review`
- `/ompchange` -> `omp-change`
- `/ompfix` -> `omp-fix`

### 自然语言路由

用户意图与 skill 的默认映射：

- 初始化项目 -> `omp-intake`
- 新需求 / 补充需求 / 先回应一下 -> `omp-respond`
- 继续对齐 / 根据反馈调整 -> `omp-align`
- 检查能否进入正式交付 -> `omp-preflight`
- 做交付型原型 -> `omp-deliver-prototype`
- 写正式 PRD -> `omp-deliver-prd`
- 开评审 / 做评审会材料 -> `omp-review`
- 正式交付后新增需求 / 范围变化 -> `omp-change`
- 修正已有产物 -> `omp-fix`

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

## 9. 复写与评审

- 下游发现上游结论错误、遗漏或冲突时，必须读取 `contracts/overwrite.md`
- 开评审会或形成评审结论时，必须读取 `contracts/review.md`

## 10. 禁止事项

- 不得替用户拍板范围
- 不得跳过门禁直接进入更重交付
- 不得在未判清版本关系时混用旧新产物
- 不得把新增需求默认吞进当前稳定版本
- 不得在高上下文风险下强行输出长文
