# OhMyPm

OhMyPm 是一个给 PM 用的需求对齐与正式交付辅助器。

## 仓库保留内容

- `skills/`：动作级执行规则
- `contracts/`：跨动作底层规则
- `reference/`：写法参考、样例和复杂场景示范
- `contracts/schemas/`：结构校验基准
- `docs/templates/`：初始化模板、PRD 模板、原型模板、评审模板
- `scripts/python/omp-lint.py`：结构校验、关系校验与内部 `review-pack` 聚合

## 生效方式

- 先安装一次全局规则，再在业务项目里直接使用
- 不再要求每个业务项目手动放桥接 `AGENTS.md`
- 当前安装脚本支持：`codex`、`trae`、`trae-cn`

## 安装

```powershell
.\install.ps1 -HostKind codex
.\install.ps1 -HostKind trae
.\install.ps1 -HostKind trae-cn
```

安装完成后，全局规则会写入对应宿主目录：

- `codex`：`%USERPROFILE%\.codex\AGENTS.md`
- `trae`：`%USERPROFILE%\.trae\rules\ohmypm-global.md`
- `trae-cn`：`%USERPROFILE%\.trae-cn\rules\ohmypm-global.md`

如需移除：

```powershell
.\scripts\remove-global-rules.ps1 -HostKind codex
```

## 首次运行初始化

首次在新项目里使用 OMP 时，执行 `/disc` 或明确说“初始化 OMP”，AI 自动创建：

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

- 默认通过显式命令推进主线：`/disc`、`/solution`、`/proto`、`/prd`、`/review`、`/change`、`/fix`
- 新项目首次接入只认 `/disc` 或“初始化 OMP”；不再承诺任意 PM 自然语言都会自动初始化
- 跨阶段只认命令，不再依赖“继续”“下一步”“继续写 PRD”这类自然语言
- 正确执行顺序是：先读 `.ohmypm/status.json` 判断当前动作，再读取对应 `skills/omp-*/SKILL.md`，最后才读取该动作需要的模板与 contract
- 模板只负责产物骨架，不是独立入口；不得跳过 skill 直接按模板生成 `solution / prototype / prd / review`
- 只有结构校验、关系校验和内部 `review-pack.json` 聚合时才调用已安装的 `omp-lint.py` 入口
- 不需要预创建 `.ohmypm/status.json`

## 当前约束

- 模板管骨架与格式
- skill 管流程、门禁、回写
- contracts 管跨动作底层规则
- reference 管写法参考与样例
- Schema 管字段、枚举、类型
- Python lint 管引用、存在性、一致性与 `review-pack`
- 对外稿件默认去 AI 化
