# OhMyPm 安装指令

你正在为用户安装 OhMyPm。请按以下步骤执行：

## 1. 准备安装路径

将 OhMyPm 放在用户机器上的固定路径中。

- macOS/Linux：`~/OhMyPm`
- Windows：`%USERPROFILE%\\OhMyPm`

如果用户已经在某个固定目录维护该仓库，也可以直接使用当前仓库路径作为安装路径。

## 2. 写入全局规则

运行：

```powershell
powershell -File .\installers\install.ps1
```

默认会为以下宿主写入全局规则：

- Codex
- VS Code Copilot
- Cursor
- Antigravity
- Trae
- Trae CN

## 3. 安装结果

安装器会：

- 为支持的宿主写入 OhMyPm 全局规则
- 让宿主在项目根目录存在 `.ohmypm/status.json` 时自动读取 `AGENTS.md`
- 让宿主在项目未激活时忽略 OhMyPm 规则

## 4. 项目启用

在业务项目中，创建最小初始化文件后，OhMyPm 即进入工作流。

当前最小文件为：

- `.ohmypm/status.json`
- `.ohmypm/memory.md`

## 5. 公开入口

安装完成后，公开短命令入口为：

- `/ompgo`
- `/omplisten`
- `/ompreply`
- `/ompcheck`
- `/ompalign`
- `/ompready`
- `/ompproto`
- `/ompprd`
- `/ompreview`
- `/ompchange`
- `/ompfix`

也支持自然语言路由。

## 6. 安装后自检

建议至少跑一次最小链路验证：

```powershell
powershell -File .\scripts\control\demo-smoke.ps1
```

它会按样例回放一条最小状态链，并在结束后恢复原始状态文件与项目记忆文件。

建议继续查看：

- `docs/usage.md`
- `docs/runbooks/demo-flow.md`
- `docs/runbooks/round-state-flow.md`

