# /omprespond

直接进入 `omp-respond`，用于形成当前理解与一版可信回应。

本命令负责：

- 建立当前版本方案
- 显式暴露未确认事实和未澄清问题
- 给出模块级粗估

补充规则：

- 未过回应门禁，不得给出像承诺一样的正式回应
- 若只是轮次内修正或待补资料，不得擅自增加轮次编号
- 若文字已不足以支撑理解，可建议生成对齐型原型，但由 PM 决定是否实际生成

建议先执行：

```powershell
powershell -File .\scripts\stage-gate.ps1 -Gate omp-respond
```
