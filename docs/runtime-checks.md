# OMP 硬门禁运行说明

## 1. 门禁链路

当前只固定两类校验能力和一个内部聚合能力：

| 工具 | 使用时机 | 作用 |
| --- | --- | --- |
| `schema-check` | AI 写回 `status.json`、`solution.manifest.json`、`review-pack.json` 后 | 检查字段、枚举、类型、必填项 |
| `trace-check` | 原型结束后、PRD 结束后、评审开始前 | 检查 manifest、PRD、原型是否断链或泄漏机读字段 |
| `build-review-pack` | 评审开始前 | 聚合内部冷启动评审包 |

## 2. 结果解释

Python lint 都按统一口径处理结果：

| 结果 | 含义 | 处理 |
| --- | --- | --- |
| `pass` | 可以继续 | 进入下一步 |
| `warn` | 可以继续，但有风险 | 记录风险，不阻断 |
| `fail` | 阻断 | 先修复，不得进入下一阶段 |

## 3. 常用命令

在已初始化 OMP 的项目根目录执行：

```powershell
python scripts/python/omp-lint.py schema-check --target manifest --file .ohmypm/alignment/solution.manifest.json
python scripts/python/omp-lint.py trace-check --status-path .ohmypm/status.json
python scripts/python/omp-lint.py build-review-pack --status-path .ohmypm/status.json --output-path .ohmypm/review/review-pack.json
python scripts/python/omp-lint.py encoding --root .
```

## 4. 回归检查

```powershell
rg -n "M[0-9]{2}-P[0-9]{2}-A[0-9]{2}|anchor_id|rules_ref|prototype_ref" output
git diff --check
```

`review-pack.json` 只能写入 `.ohmypm/review/`，不得写入 `output/`。
