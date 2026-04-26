# OhMyPm

OhMyPm 是一个给 PM 用的需求对齐与正式交付辅助器。

## 仓库保留内容

- `skills/`：动作级执行规则
- `contracts/`：跨动作底层规则
- `contracts/schemas/`：结构校验基准
- `docs/templates/`：初始化模板、PRD 模板、原型模板、评审模板
- `scripts/python/omp-lint.py`：结构校验、关系校验与内部 `review-pack` 聚合

## 生效方式

- 零脚本接入：不写 IDE 配置目录，不依赖安装器
- 但不是跨项目自动挂载：在业务项目里使用时，目标项目根目录必须有一个轻量 `AGENTS.md`，指向本仓库规则
- 轻量接入模板见 `docs/templates/project-agents.template.md`

## 接入步骤

1. 在目标项目根目录放置一个轻量 `AGENTS.md`
2. 内容模板使用 `docs/templates/project-agents.template.md`
3. 该 `AGENTS.md` 只做一件事：把业务项目里的 PM 请求路由到本仓库 `AGENTS.md`

## 首次运行初始化

首次在项目中提出 PM 主线请求时，AI 自动创建：

- `.ohmypm/status.json`
- `.ohmypm/memory.md`
- `.ohmypm/alignment`
- `output/disc`
- `output/solution`
- `output/prd`
- `output/prototype`
- `output/review`

其中：

- `output/` 只放人读交付物
- `.ohmypm/` 只放内部状态、机读锚点和运行时文件

## 运行方式

- 默认通过自然语言使用，由 AI 直接按 skill 规则执行
- 正确执行顺序是：先读 `.ohmypm/status.json` 判断当前动作，再读取对应 `skills/omp-*/SKILL.md`，最后才读取该动作需要的模板与 contract
- 模板只负责产物骨架，不是独立入口；不得跳过 skill 直接按模板生成 `solution / prototype / prd / review`
- 只有结构校验、关系校验和内部 `review-pack.json` 聚合时才调用 `scripts/python/omp-lint.py`
- 不需要执行安装器
- 不需要向 IDE 配置目录写全局规则
- 不需要预创建 `.ohmypm/status.json`

## 当前约束

- 模板管文风和版式
- skill 管流程、门禁、回写
- contracts 管跨动作底层规则
- Schema 管字段、枚举、类型
- Python lint 管引用、存在性、一致性与 `review-pack`
- 对外稿件默认去 AI 化
