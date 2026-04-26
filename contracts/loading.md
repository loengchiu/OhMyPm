# OhMyPm 最小读取规则

## 1. 先读什么

默认先读：

- `.ohmypm/status.json`
- `.ohmypm/memory.md` 的最小必要摘要

只回答：

- 当前大致走到哪一步
- 当前是否有阻塞
- 当前是否已有稳定交付物
- 当前下一步是什么

## 2. 再读什么

由宿主根据自然语言和当前状态判断当前唯一动作。

默认只读一个当前动作 skill，只补当前动作真正需要的少量 contract。

最小补读规则：

- 涉及长材料、长输出、跨模块联动、多轮反复修改时补读 `contracts/context-guard.md`
- 需要追问时补读 `contracts/ask-back.md`
- 进入正式交付或做变更判断时补读 `contracts/gates.md`
- 进入正式交付时补读 `contracts/delivery.md`
- 写详细需求说明时补读 `contracts/anchors.md`
- 做评审时补读 `contracts/review.md`
- 涉及复写时补读 `contracts/overwrite.md`
- 涉及记忆时补读 `contracts/memory.md`
- 涉及外部知识时补读 `contracts/knowledge.md`

## 3. 禁止项

- 默认同时读取多个 skill
- 为了保险一次读取很多规则
- 让 PM 自己决定该走哪个命令
- 直接把内部状态字段丢给 PM
- 把长材料整篇整包塞进活跃上下文
- 只按字数判断是否防爆，不看文件类型、任务复杂度和轮次状态
