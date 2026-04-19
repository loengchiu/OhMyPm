---
name: omp-deliver-prd
description: "生成正式归档所需 PRD，补足规则、异常、权限、数据影响和验收说明。"
---

# Deliver PRD

## 读取顺序

1. `docs/project-status.json`
2. `docs/project-memory.md`
3. `contracts/gates.md`
4. `contracts/delivery.md`
5. `contracts/context-guard.md`
6. 按需读取相关系统记忆卡

## 目标

- 生成正式归档主文件 PRD
- 按两层九段结构组织内容
- 避免重复原型已清楚表达的页面内容

## 强制规则

- 未通过正式交付门禁，不得开始
- 长文必须分块生成并做摘要回收
