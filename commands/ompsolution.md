# /ompsolution

用于强制进入“方案”动作。

这是调试入口和强制入口，不是默认使用方式。

本命令只负责：

- 基于调研结论生成或更新当前版本方案稿
- 吸收 PM 对方案稿的修改
- 判断当前方案是否足够进入原型或 PRD

- 执行前先确认调研结论已足够支撑方案生成
- 生成 `solution.manifest.json` 后执行 `schema-check --target manifest`
