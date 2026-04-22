# OhMyPm 加载规则

## 1. 主规则

### 第一步：先读最小状态

默认先读：

- `.ohmypm/status.json`
- `.ohmypm/memory.md` 的最小必要摘要

只回答：

- 当前大致走到哪一步
- 当前是否有阻塞
- 当前是否已有稳定交付物
- 当前是真实协作还是样例场景

### 第二步：再判当前动作

由宿主根据自然语言判断当前更像哪一个动作：

- `omp-listen`
- `omp-reply`
- `omp-align`
- `omp-check`
- `omp-ready`
- `omp-proto`
- `omp-prd`
- `omp-review`
- `omp-change`
- `omp-fix`

### 第三步：只读当前动作所需内容

- 默认只读一个当前动作 skill
- 只补当前动作真正需要的少量 contract

最小规则读取：

- 涉及长材料或长输出时补读 `contracts/context-guard.md`
- 需要提问时补读 `contracts/ask-back.md`
- 开工检查或变更判断时补读 `contracts/gates.md`
- 进入正式交付时补读 `contracts/delivery.md`
- 写 PRD 详细需求说明时补读 `contracts/anchors.md`
- 做评审时补读 `contracts/review.md`
- 涉及复写时补读 `contracts/overwrite.md`
- 涉及记忆时补读 `contracts/memory.md`
- 涉及外部知识时补读 `contracts/knowledge.md`

## 2. 补充约束

- 长材料和外部知识只允许局部回查，不得整篇整包载入
- 长文生成后必须摘要回收，只保留摘要、索引、稳定路径和状态回写

## 3. 禁止项

- 默认同时读取多个 skill
- 为了保险一次读取很多规则
- 让 PM 自己决定该走哪个命令
- 直接把内部状态字段丢给 PM
