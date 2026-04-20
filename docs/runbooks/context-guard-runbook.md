# Context Guard Runbook

## 目标

把 `omp-context-guard` 执行成一条完整链：

1. 判断上下文风险
2. 生成分块计划
3. 为长材料写缓存提取
4. 只把摘要和索引留在上下文

## 步骤

### 1. 生成分块计划

```powershell
powershell -File .\scripts\context-plan.ps1 -InputPath .\product-definition.md -OutputKind prd -ExpectedOutputChars 9000
```

### 2. 为长材料写缓存

```powershell
powershell -File .\scripts\material-extract.ps1 -InputPath .\product-definition.md
```

### 3. 使用缓存

默认缓存文件：

- `docs/ohmypm/cache/material-extract.md`

后续只读取：

- 分块计划
- 缓存提取结果
- 必要的原文局部片段
