# OhMyPm 入口规则

当当前项目根目录存在 `.ohmypm/status.json` 时，启用 OhMyPm。
当 `.ohmypm/status.json` 不存在但用户显式执行 `/disc` 或明确说“初始化 OMP”时，也启用 OhMyPm。

## 1. 激活与初始化

- `.ohmypm/status.json` 已存在：先读状态，再进入 OhMyPm 主线
- `.ohmypm/status.json` 不存在且用户显式执行 `/disc` 或明确说“初始化 OMP”：先按 `docs/templates/init-status.template.json` 和 `docs/templates/init-memory.template.md` 初始化最小运行时，再进入 `omp-disc`
- `.ohmypm/status.json` 不存在且只是纯咨询：只回答，不初始化

## 2. 执行顺序

- 正确顺序固定为：读 `.ohmypm/status.json` → 判断当前动作 → 只读一个对应 `skills/omp-*/SKILL.md` → 再读取该动作需要的模板与 `contracts/`
- 模板不是入口；不得跳过 skill 直接按模板生成 `solution / prototype / prd / review`
- 除首次初始化外，未先读取 `.ohmypm/status.json`，不得开始任何 `omp-*` 主动作

## 3. 主线入口

- 默认使用显式命令推进主线：`/disc`、`/solution`、`/proto`、`/prd`、`/review`、`/change`、`/fix`
- 自然语言只用于补材料、回答待确认项、询问当前阶段或当前阻塞
- `继续`、`下一步` 不负责跨阶段推进；只允许汇报当前阶段并给出唯一下一步命令
- 跨阶段只认显式命令；`继续做原型`、`继续写 PRD`、`进入评审` 这类自然语言不再作为切阶段入口

## 4. 跨阶段规则

- 切换到目标动作，只代表允许进入该动作
- 进入新动作后，必须重新执行：读状态 → 读目标 skill → 执行该动作的最小读取与门禁
- 不得沿用上一动作的上下文直接生成下一阶段产物

## 5. 硬门禁

- `omp-proto`、`omp-prd`、`omp-review` 进入正式产出前执行 `trace-check`
- `omp-review` 开始前先生成 `.ohmypm/review/review-pack.json`
- `pass` 可继续，`warn` 记录风险后继续，`fail` 先修复
- 具体校验方式见 `docs/runtime-checks.md`

## 6. 运行边界

- `AI / Markdown` 负责主流程动作、产物生成、普通状态回写
- `Schema` 负责字段、类型、枚举、必填项
- `scripts/python/omp-lint.py` 只负责 `schema-check / trace-check / build-review-pack / encoding`
- `solution.md` 与 `solution.manifest.json` 必须同轮生成、同轮修改
