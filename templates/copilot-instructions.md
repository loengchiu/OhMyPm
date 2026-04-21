# Copilot 项目指令

本项目使用 **OhMyPm** 进行需求处理工作流管理。

## 使用方式

- 默认入口是自然语言 + 项目根目录 `AGENTS.md`
- 当前项目已激活时，模型应优先读取 `.ohmypm/status.json`
- 若用户使用短命令，则直接按命令进入对应 skill：
  - `/ompgo /omplisten /ompreply /ompcheck /ompalign /ompready /ompproto /ompprd /ompreview /ompchange /ompfix`
- 若用户使用自然语言，则按 `AGENTS.md` 的自然语言路由规则执行
- 若未真实读取状态或未完成门禁检查，不得表述为“已确认可推进”

## 状态文件

`.ohmypm/status.json` 记录当前协作层阶段、稳定基线和待处理事项。不存在时代表当前项目尚未激活 OhMyPm。

