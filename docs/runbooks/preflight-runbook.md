# Preflight Runbook

## 目标

把 `omp-ready` 执行成一条完整链：

1. 检查正式交付门禁
2. 核对六项闭合条件
3. 回写状态和项目记忆

## 步骤

### 1. 门禁检查

```powershell
powershell -File .\scripts\tools\stage-gate.ps1 -Gate omp-ready
```

### 2. 回写 preflight 状态

```powershell
powershell -File .\scripts\tools\status-apply.ps1 -PayloadPath .\docs\examples\preflight-status.sample.json
```

如果 preflight 未通过，应补写：

- `FallbackType`
- `FallbackReason`

注意：

- preflight 入口要求 `RoundResult=ready_for_preflight`
- 如果 preflight 失败并决定 `reopen_alignment`，应回到 `omp-align`
- 不应把 `reopen_alignment` 改写成新的 `RoundResult`

### 3. 回写 preflight 记忆

```powershell
powershell -File .\scripts\tools\memory-apply.ps1 -PayloadPath .\docs\examples\preflight-memory.sample.json
```
