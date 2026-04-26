# OhMyPm

OhMyPm 是一个给 PM 用的需求对齐与正式交付辅助器。

## 仓库保留内容

- `skills/`：动作级执行规则
- `contracts/`：跨动作底层规则
- `docs/templates/`：初始化模板、PRD 模板、原型模板、评审模板
- `scripts/control/`：项目初始化与主控入口
- `scripts/tools/`：状态、门禁、回写工具

## 项目初始化

在目标项目根目录执行：

```powershell
powershell -File D:\work\OhMyPm\scripts\control\init-project.ps1
```

初始化后会生成：

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

## 运行入口

默认通过自然语言使用。  
如需强制走主控入口：

```powershell
python D:\work\OhMyPm\scripts\python\ohmypm_tools.py ompgo
```

## 当前约束

- 模板管文风和版式
- skill 管流程、门禁、回写
- contracts 管跨动作底层规则
- 对外稿件默认去 AI 化
