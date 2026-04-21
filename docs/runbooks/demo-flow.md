# 开发样例回放流程

## 目标

用一条最小样例链路回放 OhMyPm，从首轮回应走到对齐，再分支验证：

- 正式交付前准备
- 正式评审与修正
- preflight 失败后的重开对齐
- 交付后变更分类处理

这份 runbook 只用于开发验证和 smoke check，不属于正式协作入口。它说明哪些样例 payload 可以按顺序回放，而不需要每次重新解释架构。

如需一键回放，可执行：

```powershell
powershell -File .\scripts\control\demo-smoke.ps1
```

## 准备

先确认项目已经初始化：

```powershell
powershell -File .\scripts\control\init-project.ps1
```

建议先备份：

```powershell
Copy-Item .\.ohmypm\status.json .\.ohmypm\cache\status.demo.backup.json -Force
Copy-Item .\.ohmypm\memory.md .\.ohmypm\cache\memory.demo.backup.md -Force
```

## 路径 A：回应 -> 对齐 -> preflight 通过

### 1. 首轮回应

```powershell
powershell -File .\scripts\tools\status-apply.ps1 -PayloadPath .\docs\examples\respond-status.sample.json
powershell -File .\scripts\tools\memory-apply.ps1 -PayloadPath .\docs\examples\respond-memory.sample.json
```

预期状态：

- `RoundNumber=1`
- `RoundResult=continue_alignment`

### 2. 反馈后对齐

```powershell
powershell -File .\scripts\tools\status-apply.ps1 -PayloadPath .\docs\examples\align-status.sample.json
powershell -File .\scripts\tools\memory-apply.ps1 -PayloadPath .\docs\examples\align-memory.sample.json
```

预期状态：

- `RoundNumber=2`
- `RoundResult=ready_for_preflight`

### 3. preflight 通过

```powershell
powershell -File .\scripts\tools\status-apply.ps1 -PayloadPath .\docs\examples\preflight-status.sample.json
powershell -File .\scripts\tools\memory-apply.ps1 -PayloadPath .\docs\examples\preflight-memory.sample.json
```

预期状态：

- 当前方案已经可进入正式交付
- 下一步可以进入 `omp-proto`

### 4. 交付型原型

```powershell
powershell -File .\scripts\tools\status-apply.ps1 -PayloadPath .\docs\examples\prototype-status.sample.json
```

### 5. 正式 PRD

```powershell
powershell -File .\scripts\tools\status-apply.ps1 -PayloadPath .\docs\examples\prd-status.sample.json
```

### 6. 评审

```powershell
powershell -File .\scripts\tools\review-apply.ps1 -ReviewJsonPath .\docs\examples\review-result.sample.json
powershell -File .\scripts\tools\memory-apply.ps1 -PayloadPath .\docs\examples\review-memory.sample.json
```

### 7. 修正与复写

```powershell
powershell -File .\scripts\tools\overwrite-apply.ps1 -JudgeJsonPath .\docs\examples\overwrite-result.sample.json
powershell -File .\scripts\tools\memory-apply.ps1 -PayloadPath .\docs\examples\fix-memory.sample.json
```

预期结果：

- 评审阻塞项被记录
- 复写队列被更新
- 如果基线被推翻，下一步会回到对齐链

## 路径 B：preflight 失败 -> 重开对齐

当相关方在 preflight 期间或之后推翻结构结论时，使用这条分支。

```powershell
powershell -File .\scripts\tools\status-apply.ps1 -PayloadPath .\docs\examples\reopen-alignment.sample.json
```

预期状态：

- `RoundResult=need_internal_repair`
- `FallbackType=reopen_alignment`

说明：

- `reopen_alignment` 只写在 fallback_state 中
- 只有重新进入下一轮正式对齐时，才递增轮次编号

## 路径 C：交付后变更处理

### 1. 未确认分类示例

这个文件不用于直接 happy path 回放，只用于展示 PM 确认前的状态：

- `docs/examples/change-status.sample.json`

### 2. 已确认分类示例

如需可运行的变更处理样例，使用：

```powershell
powershell -File .\scripts\tools\status-apply.ps1 -PayloadPath .\docs\examples\change-status-confirmed.sample.json
```

预期状态：

- `ChangeCategory=new_module`
- `ChangeCategoryConfirmedByPm=true`
- 下一步应回到对齐链，而不是静默吞并进当前稳定版本

## 恢复

如果前面做了备份，回放完成后可按下面方式恢复：

```powershell
Copy-Item .\.ohmypm\cache\status.demo.backup.json .\.ohmypm\status.json -Force
Copy-Item .\.ohmypm\cache\memory.demo.backup.md .\.ohmypm\memory.md -Force
```

