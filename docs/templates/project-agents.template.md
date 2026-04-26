# OMP Project Bridge

把下面这段放到业务项目根目录的 `AGENTS.md` 中，并把 `__OHMYPM_RULES_PATH__` 替换成当前 OMP 仓库的实际路径；如果 OMP 仓库作为相对目录放在项目旁边，也可以改成相对路径。

```md
<!-- OHMYPM PROJECT BRIDGE START -->
# OhMyPm Project Rules

当用户在当前项目里提出 PM 主线工作请求时：

- 读取 `__OHMYPM_RULES_PATH__/AGENTS.md`
- 遵循其中全部规则
- 若 `.ohmypm/status.json` 不存在，则按该规则中的初始化方式先创建最小运行时

<!-- OHMYPM PROJECT BRIDGE END -->
```
