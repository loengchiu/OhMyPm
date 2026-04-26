# OhMyPm 全局规则

当用户在当前项目里提出 PM 主线工作请求时，OhMyPm 工作流可激活；若 `.ohmypm/status.json` 不存在，先初始化最小运行时，再进入主线动作。

## 1. 激活条件

- `.ohmypm/status.json` 存在：直接进入 OhMyPm 工作流
- `.ohmypm/status.json` 不存在且用户提出 PM 主线请求：先按模板创建最小运行时，再进入 `omp-disc`
- `.ohmypm/status.json` 不存在且只是纯咨询：允许只回答，不创建运行时

## 2. 默认入口

- 用户默认通过自然语言使用 OhMyPm
- OhMyPm 的 skill 不是单独的 Tool 按钮，但也绝不是“直接读模板生成”；正确顺序必须是：先读 `.ohmypm/status.json` → 判断当前动作 → 只读一个对应 `skills/omp-*/SKILL.md` → 再读取该动作需要的模板和 contract
- 若 `.ohmypm/status.json` 不存在，先创建：
  - `.ohmypm/status.json`（来自 `docs/templates/init-status.template.json`）
  - `.ohmypm/memory.md`（来自 `docs/templates/init-memory.template.md`）
  - `.ohmypm/alignment/`
  - `output/disc`
  - `output/solution`
  - `output/prd`
  - `output/prototype`
  - `output/review`
- 再读 `.ohmypm/status.json` 与 `.ohmypm/memory.md` 的最小必要摘要
- 再判断当前更像哪个动作，只读取一个对应 skill
- 模板不是入口；任何 `solution / proto / prd / review` 产物都不得在未读取对应 skill 的前提下直接按模板生成
- 除首次初始化外，未先读取 `.ohmypm/status.json` 不得开始 `omp-solution / omp-proto / omp-prd / omp-review / omp-change / omp-fix`
- 若存在待确认项、门禁缺口或真实项目阻塞，优先停在当前主动作内处理，不额外暴露机制型 skill
- 每次输出最后只能收口为：
  - `下一步：...`
  - `现在只需要你回答的唯一问题是：...`

## 3. 路由边界

- 只要当前项目根目录存在 `.ohmypm/status.json`，该项目内的 PM 主线动作统一由 `OhMyPm` 接管
- `OhMyPm` 项目中的正式阶段主线推进，仍然只能落到 `omp-disc / omp-solution / omp-proto / omp-prd / omp-review / omp-change / omp-fix`
- 外部成熟做法只允许作为参考，不得在 `OhMyPm` 已激活项目里被直接路由成执行技能
- 外部固定动作只保留：调研、方案、做原型、写 PRD、评审、改需求、修问题
- 短命令只作为调试入口、强制入口和高级用户入口

## 4. 强禁止项

- 不得替用户拍板范围
- 不得跳过当前门槛直接进入更重交付
- 不得默认同时读取多个 skill
- 不得为了保险一次读取很多 contract
- 不得把长版记忆、外部知识或长材料整篇整包塞进活跃上下文
- 不得把虚构业务问题伪装成真实项目问题抛给 PM
- 不得把未确认内容伪装成已确认事实
- 不得让 `OhMyPm` 的中间材料直接污染正式产物树
- 在 `OhMyPm` 已激活项目里，不得把自然语言“做原型 / 写 PRD / 继续下一步”误路由到非当前动作链的旧命令或同名技能
- 不得跳过“读状态 → 判动作 → 读 skill”这条主链，直接根据模板文件名或上一轮产物名生成新产物

## 5. 硬门禁

- 调研 / 方案：由当前 skill 直接完成上下文充分性自检
- 原型 / PRD / 评审：执行 `trace-check`
- 评审：先生成 `review-pack.json`
- `pass` 继续，`warn` 记录风险后继续，`fail` 先修复
- 命令见 `docs/runtime-checks.md`

# 长期协作原则

- `AI / Markdown` 负责主流程动作、产物生成、普通状态回写
- `Schema` 只负责形状校验：字段、类型、枚举、必填项
- `Python lint` 只负责关系校验：引用、存在性、一致性、泄漏检查
- Python 默认只读不写、只查不改；唯一允许生成的新文件是内部 `review-pack.json`
- Python 不得改写 `status.json`、`.ohmypm/memory.md`、`solution.manifest.json`、PRD、原型等主产物
- `solution.md` 与 `solution.manifest.json` 必须同轮生成、同轮修改，禁止从人读稿反推机读稿
- OMP 默认坚持“规则驱动，脚本兜底”；默认由 AI 直接按 skill 执行动作，不得把脚本当主流程驱动层
- 高频动作不得依赖包装脚本；OMP 仓库不再保留任何运行时 `ps1`
- `omp-lint.py` 只承接 `schema-check / trace-check / build-review-pack / encoding`；若明显超过 `200-300` 行职责边界，应优先判定为职责漂移
- 若规则、skill、contract 三处同时描述同一件事，优先把动作规则收回 `SKILL.md`，`contracts/` 只保留跨动作底层约束

- 稳定且反复使用的执行规则，写进对应 `skills/<skill>/SKILL.md`
- 只跨多个 skill 复用的底层约束，才写进 `contracts/`
- 模板只负责产物格式，不承载大段解释性规则
- 一次性讨论、临时决策背景、只需告诉用户一遍的话，不写进 `SKILL.md`
- `SKILL.md` 只保留执行时必须依赖、否则会跑偏的规则
- `SKILL.md` 中的写作与产物规则，优先描述目标状态和正确形态，不用基于上一个错误的补救式表述；只有门禁、安全、越界、防幻觉这类规则才优先使用禁止式写法
- 对外稿件默认去 AI 化：不写 AI 痕迹、绝对路径、解释性引用块
- 对外资料来源用人类可读名称；机器路径只放内部状态、证据或调试文件
- 若模板、skill、contract 三处同时描述同一件事，优先收敛到 skill；避免规则分散
- OMP 默认零脚本接入，但不是跨项目自动挂载；若在业务项目中使用，目标项目根目录必须有一个轻量 `AGENTS.md` 指向本仓库规则
- 若遇到编码问题，优先用 `python scripts/python/omp-lint.py encoding --root <project>` 检查 `.ohmypm/` 和 `output/`
- 先质疑再设计：不要把用户刚提出的结构默认当成正确方向；先检查是否重复、过度设计或只是新增层级，优先给更小、更稳的方案，只有在简化方案不够时才接受更复杂的结构
