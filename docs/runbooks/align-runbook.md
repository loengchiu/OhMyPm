# Align Runbook

## 目标

把 `omp-align` 执行成一条完整链：

1. 把新反馈并入事实和模块判断
2. 更新变化点、工时和排期影响
3. 回写状态和项目记忆

## 步骤

### 1. 回写对齐状态

```powershell
powershell -File .\scripts\tools\status-apply.ps1 -PayloadPath .\docs\examples\align-status.sample.json
```

如果当前轮次未能直接进入下一步，还应同步写入：

- `FallbackType`
- `FallbackReason`

注意：

- `FallbackType` 可以是 `internal_repair`、`need_materials`、`reopen_alignment`
- `reopen_alignment` 是回退动作，不是 `RoundResult`
- 只有重新进入下一轮正式对齐时，才增加 `RoundNumber`

### 2. 回写对齐记忆

```powershell
powershell -File .\scripts\tools\memory-apply.ps1 -PayloadPath .\docs\examples\align-memory.sample.json
```
