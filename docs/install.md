# 安装说明

## 快速安装

在 OhMyPm 仓库目录执行：

```powershell
powershell -File .\installers\install.ps1
```

## 安装结果

安装器会：

- 为已支持宿主写入全局规则
- 让宿主在已激活项目中自动读取 `AGENTS.md`
- 使短命令与自然语言路由都可用

## 当前支持宿主

- Codex
- VS Code Copilot
- Cursor
- Antigravity
- Trae
- Trae CN

## 项目启用

当项目根目录存在以下文件时，OhMyPm 工作流激活：

- `docs/project-status.json`
- `docs/project-memory.md`

## 入口

公开入口为：

- `/ompgo`
- `/omprespond`
- `/ompaskback`
- `/ompalign`
- `/omppreflight`
- `/ompprototype`
- `/ompprd`
- `/ompreview`
- `/ompchange`
- `/ompfix`

也支持直接自然语言。
