# 使用说明

## 零脚本接入

- 不需要执行安装器
- 不需要向 IDE 配置目录写全局规则
- 不需要预创建 `.ohmypm/status.json`

## 业务项目接入

- 在目标项目根目录放置一个轻量 `AGENTS.md`
- 内容模板见 `docs/templates/project-agents.template.md`
- 该 `AGENTS.md` 的作用只有一件事：把业务项目里的 PM 请求路由到本仓库 `AGENTS.md`

## 首次运行

首次在目标项目中提出 PM 主线请求时，AI 自动创建：

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

## 需要手动执行的只有 Python lint

- 默认自然语言触发
- 需要结构校验、关系校验或内部评审包时，执行 `python scripts/python/omp-lint.py ...`
