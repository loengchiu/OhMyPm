# /ompgo

用于强制初始化或重新进入 OhMyPm 工作流。

这是调试入口和强制入口，不是默认使用方式。  
默认仍然是直接用自然语言说需求或说“继续”。

本命令只负责：

- 检查 `.ohmypm/status.json` 是否存在
- 不存在时初始化项目
- 存在时根据当前状态恢复到正确动作

建议入口：

- `python D:\work\OhMyPm\scripts\python\ohmypm_tools.py ompgo`

硬门禁结果：`pass` 继续，`warn` 记录风险后继续，`fail` 先修复。

