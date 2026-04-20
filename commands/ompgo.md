# /ompgo

用于强制初始化或重新进入 OhMyPm 工作流。

这是调试入口和强制入口，不是默认使用方式。  
默认仍然是直接用自然语言说需求或说“继续”。

本命令只负责：

- 检查 `docs/ohmypm/ohmypm-status.json` 是否存在
- 不存在时初始化项目
- 存在时根据当前状态恢复到正确动作

建议脚本：

- `scripts/control/ompgo.ps1`
