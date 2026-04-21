# /omplisten

用于强制进入“听需求”动作。

这是调试入口和强制入口，不是默认使用方式。

本命令只负责：

- 接住新的业务原话
- 建立当前需求任务
- 判断是否具备进入首轮回应的最小输入

建议脚本：

- `powershell -File .\scripts\control\ompgo.ps1 -ForceSkill omp-listen`
