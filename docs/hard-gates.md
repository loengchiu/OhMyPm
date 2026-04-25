# OMP 硬门禁运行说明

## 1. 门禁链路

当前只固定三类硬门禁：

| 脚本 | 使用时机 | 作用 |
| --- | --- | --- |
| `scripts/tools/context-lint.ps1` | 调研结束前、方案开始前 | 检查上下文包是否足够进入方案 |
| `scripts/tools/trace-lint.ps1` | 原型结束后、PRD 结束后、评审开始前 | 检查 manifest、PRD、原型是否断链或泄漏机读字段 |
| `scripts/tools/review-pack.ps1` | 评审开始前 | 生成冷启动评审包 |

## 2. 结果解释

三个脚本都按统一口径处理结果：

| 结果 | 含义 | 处理 |
| --- | --- | --- |
| `pass` | 可以继续 | 进入下一步 |
| `warn` | 可以继续，但有风险 | 记录风险，不阻断 |
| `fail` | 阻断 | 先修复，不得进入下一阶段 |

## 3. 常用命令

在已初始化 OMP 的项目根目录执行：

```powershell
powershell -File D:\work\OhMyPm\scripts\tools\context-lint.ps1 -StatusPath .ohmypm/status.json
powershell -File D:\work\OhMyPm\scripts\tools\trace-lint.ps1 -StatusPath .ohmypm/status.json
powershell -File D:\work\OhMyPm\scripts\tools\review-pack.ps1 -StatusPath .ohmypm/status.json -OutputPath .ohmypm/review/review-pack.json
```

## 4. 回归检查

```powershell
rg -n "M[0-9]{2}-P[0-9]{2}-A[0-9]{2}|anchor_id|rules_ref|prototype_ref" output
git diff --check
```

`review-pack.json` 只能写入 `.ohmypm/review/`，不得写入 `output/`。
