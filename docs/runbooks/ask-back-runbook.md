# Ask-Back Runbook

## 目标

把 ask-back 从“写在规则里”变成“运行时会主动触发的动作”：

1. 识别需要 PM 决策的阻塞点
2. 阻断更重动作推进
3. 生成最小提问
4. 将 PM 回答回写到状态

## 运行时检查

以下运行时节点一旦命中条件，就必须中断并转入 ask-back：

- `scripts/tools/stage-gate.ps1`
- `omp-respond`
- `omp-preflight`
- `omp-change`

## 触发场景

至少在以下场景必须触发 ask-back：

- 生成回应稿时被关键事实缺口卡住
- 交付前检查前仍然有待确认项
- 变更分类还未得到 PM 确认
- 范围边界尚未确认，但已经影响模块清单、工时或排期

## 第 1 步：生成最小问题

```powershell
powershell -File .\scripts\tools\ask-back-plan.ps1
```

预期结果：

- `ask_back_required=true`
- 至少一条触发记录
- 每条触发记录都带一条最小 PM 问题

## 第 2 步：向 PM 提最小阻塞问题

优先处理最靠前的触发项。

人话问法示例：

- 这次新增内容是否仍然属于当前版本范围？
- 即使仍然属于当前版本范围，这次新增内容是否已经大到需要单独算作一个新模块？

注意：

- 不要把“范围判断”和“模块分类判断”混成一个问题
- 先问范围
- 再问模块分类

## 第 3 步：回写 PM 回答

```powershell
powershell -File .\scripts\tools\ask-back-apply.ps1 `
  -AnsweredConfirmation 'Need confirmation on scope boundary' `
  -ChangeCategoryConfirmedByPm $true `
  -NextRecommended '回到刚才被卡住的阶段，并按最新确认结果重新判断是否可以推进。'
```

预期结果：

- 对应的 `pending_confirmations` 项被移除
- PM 确认状态被更新
- 被卡住的动作可以重新判断是否继续
