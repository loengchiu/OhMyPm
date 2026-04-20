# OhMyPm 工作流

当当前项目根目录存在 `docs/ohmypm/ohmypm-status.json` 时，OhMyPm 工作流激活。

## 1. 宿主总规则

当用户提出 PM 需求处理相关请求时：

1. 先判断当前主控权属于 `OhMyPm` 还是 `ShitPM`
2. 若属于 `OhMyPm`，先读取 `docs/ohmypm/ohmypm-status.json`
3. 再读取 `docs/ohmypm/ohmypm-memory.md` 的最小必要摘要
3. 根据自然语言先判断当前意图，只读取一个对应 `skills/{skill}/SKILL.md`
4. 只读取当前动作必须的 contract；分层加载规则以 `contracts/loading.md` 为准
5. 先执行门禁判断，再执行上下文风险判断，再推进当前动作
6. 需要系统记忆、外部知识或长材料时，只允许局部回查
7. 完成长文生成后，只保留摘要、索引和稳定路径
8. 完成后回写状态文件、项目记忆文件，必要时回写系统记忆卡

共存边界强规则：

- `OhMyPm` 继续保持自己的辅助器定位，不在这里提前改成“已由 ShitPM 接管”
- 当前先落实 `OhMyPm` 与 `ShitPM` 的边界分离
- `OhMyPm` 不得写入 `docs/project-status.json`
- `docs/project-status.json` 永远只属于 `ShitPM`
- `OhMyPm` 只维护自己的协作层状态和协作层产物

目录强规则：

- `OhMyPm` 状态文件：`docs/ohmypm/ohmypm-status.json`
- `OhMyPm` 项目记忆：`docs/ohmypm/ohmypm-memory.md`
- `OhMyPm` 自有目录：
  - `docs/ohmypm/status/`
  - `docs/ohmypm/memory/`
  - `docs/ohmypm/alignment/`
  - `docs/ohmypm/deliverables/`
  - `docs/ohmypm/cache/`
- `OhMyPm` 的 note、handoff、sample、prototype、prd skeleton 不得直接混入主 `docs/` 的正式产物区

单向交接规则：

- 当前阶段先预留 `OhMyPm -> ShitPM` 的交接接口
- `OhMyPm` 可以生成交接包
- 该交接包是未来可选输入，不等于现在就切换主控权
- 若未来 `ShitPM` 采纳，如何转写成正式主线状态，仍由 `ShitPM` 处理
- `OhMyPm` 内部术语不得原样抛给 `ShitPM`

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
- 对外默认表现必须像一个会自己判断下一步的协作型大 skill，而不是要求 PM 操作状态机
- 必须先判断当前属于：
  - `真实项目协作`
  - `机制验证样例`
  - `demo/smoke 回放`
- 若属于 `机制验证样例` 或 `demo/smoke 回放`：
  - 必须明确标记为样例场景
  - 不得把样例中的业务口径问题抛给 PM 决策
  - ask-back 只能用于样例边界、机制本身是否成立这类问题，不得要求 PM 补真实业务参数
  - 样例中的业务参数、角色映射、阈值等缺口应使用占位值，或明确标记为“仅用于机制验证”
- 只有在 `真实项目协作` 场景下，ask-back 才能向 PM 追问真实业务问题

输出收口规则：

- 每次输出最后，必须只给一个“下一步唯一动作”
- 形式只能是以下两类之一：
  - `现在建议你做的下一步是：...`
  - `现在只需要你回答的唯一问题是：...`
- 不得一次给用户一串操作菜单
- 不得要求 PM 先去 runbook 或 usage 里自己挑下一步

## 2. 激活与未激活

- 若 `docs/ohmypm/ohmypm-status.json` 不存在：视为未初始化，只允许执行初始化说明、纯咨询或创建初始化文件
- 若 `docs/ohmypm/ohmypm-status.json` 存在：进入 OhMyPm 正式工作流

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

默认主控权规则：

- 用户更像在做新需求、先回应、继续对齐、问阻塞点、先估工作量、判断新增内容算什么变化：优先进入 `OhMyPm`
- 用户更像在做正式 PRD、正式原型、正式评审、查看正式阶段、继续正式项目主线：优先进入 `ShitPM`
- 对于“继续”“下一步”这类模糊指令：
  - 若当前尚未进入正式项目主线，优先由 `OhMyPm` 接管
  - 若已进入正式项目主线，优先由 `ShitPM` 接管

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

加载层级必须同时遵守 `contracts/loading.md`。

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
- 若当前场景是 `机制验证样例` 或 `demo/smoke 回放`，不得因为样例业务参数缺口进入面向 PM 的 ask-back；必须先转为内部修正、占位补齐或显式标注“仅用于机制验证”

## 9. 复写与评审

- 下游发现上游结论错误、遗漏或冲突时，必须读取 `contracts/overwrite.md`
- 开评审会或形成评审结论时，必须读取 `contracts/review.md`

## 10. 禁止事项

- 不得替用户拍板范围
- 不得跳过门禁直接进入更重交付
- 不得在未判清版本关系时混用旧新产物
- 不得把新增需求默认吞进当前稳定版本
- 不得在高上下文风险下强行输出长文
- 不得默认同时读取多个 skill
- 不得为了保险一次读很多 contract
- 不得把长版项目记忆、system memory 或外部知识整篇整包塞进当前上下文
- 不得把虚拟样例中的业务问题伪装成真实项目问题抛给 PM
- 不得在未标清样例/真实边界时混用 demo 产物与真实协作结论
- 不得让 `OhMyPm` 占用或回写 `docs/project-status.json`
- 不得让 `OhMyPm` 的中间材料直接污染 `ShitPM` 的正式产物树
