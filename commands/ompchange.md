# /ompchange

直接进入 `omp-change`，用于处理正式交付后的新增内容或范围变化。

进入后必须先做分类：

- `minor_patch`
- `within_module`
- `new_module`
- `structural_change`

处理原则：

- `minor_patch` 和 `within_module` 可评估后并入
- `new_module` 和 `structural_change` 不得默认吞入当前交付
- `new_module` 和 `structural_change` 必须有 PM 最终确认

若变更推翻主结构：

- 下一步应写成 `reopen_alignment` 或正式变更流程
- 不应直接继续补原 PRD

执行原则：

- 变更分类和处理路径由当前 skill 直接判断
- 不通过额外脚本做范围决策或推进建议
