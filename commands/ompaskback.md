# /ompaskback

直接进入 `omp-ask-back`，用于把待确认事项转成最小 PM 问题，并在回答后回写状态。

典型触发：

- `pending_confirmations` 非空
- 范围边界未确认且已经影响模块、工时或排期
- `change_state.change_category_confirmed_by_pm=false`

建议先执行：

```powershell
powershell -File .\scripts\ask-back-plan.ps1
```
