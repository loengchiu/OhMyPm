# /ompreview

直接进入 `omp-review`，用于组织评审会与输出评审结论。

进入前应确认：

- 至少已有可评审的原型或 PRD
- 当前评审对象和版本已判清
- 评审材料包包含变化点、风险点和待决策点

本命令负责：

- 组织多角色评审团
- 归并为统一评审结论
- 必要时把推翻基线的问题转入 `ompfix`

评审开始前必须执行：

```powershell
python scripts/python/omp-lint.py trace-check --status-path .ohmypm/status.json
python scripts/python/omp-lint.py build-review-pack --status-path .ohmypm/status.json --output-path .ohmypm/review/review-pack.json
```

`fail` 时不得给通过结论；`review-pack.json` 是评审冷启动输入。
