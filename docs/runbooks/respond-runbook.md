# Respond Runbook

## 目标

把 `omp-respond` 执行成一条完整链：

1. 检查回应门禁
2. 判断上下文风险
3. 形成第一版可信回应
4. 回写状态和项目记忆

## 步骤

### 1. 检查上下文风险

```powershell
powershell -File .\scripts\tools\context-plan.ps1 -InputPath .\product-definition.md -OutputKind response -ExpectedOutputChars 2500
```

### 2. 必要时提取长材料

```powershell
powershell -File .\scripts\tools\material-extract.ps1 -InputPath .\product-definition.md
```

### 3. 回写回应状态

```powershell
powershell -File .\scripts\tools\status-apply.ps1 -PayloadPath .\docs\examples\respond-status.sample.json
```

其中建议同步写入：

- `RoundNumber`
- `RoundGoal`
- `RoundInputsJson`
- `CurrentOutput`
- `RoundResult`

### 4. 回写回应记忆

```powershell
powershell -File .\scripts\tools\memory-apply.ps1 -PayloadPath .\docs\examples\respond-memory.sample.json
```
