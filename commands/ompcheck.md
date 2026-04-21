# /ompcheck

直接进入 `omp-check`，用于判断当前能不能继续推进；若不能，就转成最小 PM 问题或内部修正。

典型触发：

- `pending_confirmations` 非空
- 范围边界未确认且已经影响模块、工时或排期
- `change_state.change_category_confirmed_by_pm=false`

建议先执行：

```powershell
powershell -File .\scripts\tools\ask-back-plan.ps1
```
