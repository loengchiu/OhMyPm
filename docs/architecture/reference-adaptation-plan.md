# OMP 参考仓偷师改造计划

## 1. 目的

本计划不引入外部仓库代码，不改外部仓库结构。

只做一件事：

- 把外部参考仓中已经验证过的规则设计，吸收到 OMP 自己的流程、contract、skill 和状态模型里

当前参考源：

- `D:\work\refs\testany-agent-skills`
- `D:\work\refs\pm-skills`

## 2. 吸收原则

- 不照搬整条长链路
- 不把 OMP 做成超长研发流水线
- 只吸收能直接提升 OMP 交付质量的基础机制
- 先吸收规则，再决定是否补脚本和运行面

## 3. 主要偷师对象

### 3.1 来自 `testany-agent-skills`

重点吸收四类能力：

- 追溯元数据体系
- 阶段化 Checkpoint Gate
- Phase 0 最小上下文收集
- 边界守护机制

### 3.2 来自 `pm-skills`

重点吸收两类能力：

- `pm-review-board` 的三级风险分层
- `pm-prd-writer` 的生成后补漏清单

## 4. 已确定直接吸收的内容

### 4.1 已落地

以下内容已经进入 OMP：

- 评审三级风险：
  - `阻断项`
  - `重要项`
  - `建议项`
- PRD 生成后补漏清单：
  - 异常流程
  - 边界条件
  - 验收口径
  - 角色、权限影响
  - 数据、接口影响
  - 非功能要求
  - 待确认项

已落地文件：

- `contracts/review.md`
- `contracts/delivery.md`
- `skills/omp-review/SKILL.md`
- `skills/omp-prd/SKILL.md`

### 4.2 待落地

接下来要吸收但尚未完全落地的内容：

- 最小追溯元数据块（规则层与运行面已落地，后续看真实项目再补）
- 阶段化 Checkpoint 卡片（规则层与运行面已落地，后续补更多真实用例）
- Phase 0 最小上下文包（规则层与运行面已落地）
- 统一边界守护规则面（规则层与运行面已落地，已覆盖样例污染、未确认泄漏、shared_refs 失配、open_questions/can_progress 冲突）
- 变更闭环的真实项目验证（规则层、脚本层、样例 runbook 已落地）

## 5. 分阶段改造路线

## 5.1 第一阶段：追溯元数据

目标：

- 解决原型、PRD、评审、变更之间的“下游跑偏”

要做：

- 为重产物定义统一最小追溯块
- 明确哪些追溯信息写入状态
- 明确哪些追溯信息只进附录/隐藏区，不进正文

最小追溯块建议字段：

- 当前版本
- 当前范围
- 当前模块
- 当前锚点
- 上游来源
- 当前未确认项
- 当前是否允许进入下一阶段

优先落点：

- `contracts/delivery.md`
- `contracts/anchors.md`
- `skills/omp-proto/SKILL.md`
- `skills/omp-prd/SKILL.md`
- `skills/omp-review/SKILL.md`

## 5.2 第二阶段：阶段化 Checkpoint Gate

目标：

- 把现在已有门禁收成清晰的阶段准出卡

要做：

- 每阶段统一表达五件事：
  - 当前输入条件
  - 当前最低输出
  - 当前禁止越过条件
  - 通过后的稳定基线
  - 不通过时的回退动作

优先覆盖阶段：

- 听需求
- 回应 / 对齐
- 开工检查
- 原型
- PRD
- 评审

优先落点：

- `contracts/gates.md`
- `contracts/loading.md`
- `skills/omp-listen/SKILL.md`
- `skills/omp-reply/SKILL.md`
- `skills/omp-ready/SKILL.md`
- `skills/omp-check/SKILL.md`

## 5.3 第三阶段：Phase 0 最小上下文收集

目标：

- 避免 OMP 在“听需求”阶段凭空猜

注意：

- 不做重访谈模板
- 只做最小必要收集
- 不足信息进入后续对齐轮补齐

最小上下文包建议字段：

- 想做什么
- 属于哪个业务环节
- 是否有现有系统 / 页面线索
- 是否有现成材料

优先落点：

- `skills/omp-listen/SKILL.md`
- `skills/omp-reply/SKILL.md`
- `.ohmypm/status.json` 相关字段约定
- `.ohmypm/memory.md` 记录约定

## 5.4 第四阶段：统一边界守护

目标：

- 把当前散落在各处的“禁止越界规则”统一收口

最低统一规则：

- 锚点不足时，不写确定性正文
- 样例场景不污染真实协作
- 未确认事实不伪装成已确认
- 方法论元话语不进入正式产物
- 新增内容不默认吞入当前稳定版本

优先落点：

- `contracts/anchors.md`
- `contracts/review.md`
- `contracts/delivery.md`
- `contracts/gates.md`
- `contracts/ask-back.md`

## 6. 不吸收的内容

以下内容当前明确不吸收：

- 外部仓库的完整研发长链路
- 过重的 enterprise 命名体系
- 与 OMP 当前场景无关的 API / HLD / LLD / code 生成流程
- 为了“看起来完整”而增加大量中间阶段

## 7. 关于 skill 长度的吸收判断

参考仓中存在四五百行的单个 skill，这一点可以借鉴，但要带条件吸收。

判断原则：

- 允许单动作 skill 变长
- 不允许总入口、总规则、全局激活文件继续变胖

具体规则：

- `AGENTS`、主控入口、总路由规则必须保持短
- `omp-prd`、`omp-review`、后续独立整理类 skill 可以适当变长
- 只要某个长 skill 仍然是“单动作闭环”，长不是问题
- 如果一个文件承担多个层级职责，即使只有 200 行，也应继续压缩

结论：

- OMP 后续偷师时，可以接受“单动作大 skill”
- 但不能回到“全局入口堆规则”的写法

## 8. 对 OMP 的预期收益

完成以上四阶段后，预期收益：

- 原型和 PRD 更不容易脱锚
- 评审结论更可执行
- 听需求阶段更少凭空推测
- 正式产物更少混入元话语
- 下游返工和方向跑偏概率下降

## 9. 当前建议顺序

建议按以下顺序推进：

1. 追溯元数据
2. 阶段化 Checkpoint Gate
3. Phase 0 最小上下文收集
4. 统一边界守护

原因：

- 前两项直接影响交付物稳定性
- 第三项影响听需求质量
- 第四项用于把已有规则彻底收口

## 10. 当前状态

当前状态判断：

- 参考仓已下载到本地参考区
- `pm-review-board` 的三级风险已吸收一部分
- `pm-prd-writer` 的补漏清单已吸收一部分
- `testany-eng` 的追溯、Checkpoint、Phase 0、边界守护已进入 OMP 的 contract + runtime 第一版
- 当前剩余重点已从“补规则”转为“跑真实单、收敛模板、继续减噪”
