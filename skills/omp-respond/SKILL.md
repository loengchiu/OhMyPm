---
name: omp-respond
description: "生成回应稿。形成当前理解、当前版本方案和待确认项。"
---

# 生成回应稿

## 所属层级

- 决策层动作

## 读取顺序

1. 读取最小状态：
  - `docs/ohmypm/ohmypm-status.json`
  - `docs/ohmypm/ohmypm-memory.md` 的最小必要摘要
2. 只读取当前 skill
3. 只读取必要规则：
  - `contracts/context-guard.md`
  - 必要时 `contracts/ask-back.md`
4. 若需要长材料或外部知识，只允许局部回查

## 目标

- 给出当前理解
- 给出当前版本方案
- 记录未确认事实与未澄清问题
- 给出模块级粗估或量级判断

## 对外动作名

- 生成回应稿

## 强制规则

- 当前动作一次只推进一件事
- 未通过当前动作的最低判断，不得把回应包装成稳定承诺
- 若关键事实缺口阻塞推进，转入 `omp-ask-back`
- 不得默认同时读取多个 skill
- 不得为了保险预读很多规则
- 输出最后必须只给一个“下一步唯一动作”
