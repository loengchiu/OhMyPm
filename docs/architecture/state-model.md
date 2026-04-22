# OhMyPm 状态与记忆模型

## 1. 目标

OhMyPm 需要同时维护三类持久信息：

- 运行状态：当前项目走到哪、能不能继续
- 项目记忆：本项目已经确认了什么、还没确认什么
- 系统记忆：跨项目可复用的系统知识是什么

因此，最小数据模型采用“项目内两层 + 外部系统记忆仓”结构。

## 2. 文件分层

### 2.1 项目状态文件

建议路径：

- `.ohmypm/status.json`

职责：

- 作为 OhMyPm 激活开关
- 记录当前阶段、门禁结果、稳定基线、阻塞项、待确认项
- 为宿主提供“当前能否推进”的运行时真值

### 2.2 项目记忆文件

建议路径：

- `.ohmypm/memory.md`

职责：

- 记录需求任务、版本演化、已确认事实、未确认事实、关键问题、当前建议、模块判断、工时粗估、评审摘要
- 作为跨会话恢复项目语境的主文件
- 为追问机制、评审会机制和回写机制提供事实基础

### 2.3 外部系统记忆卡

建议路径：

- `D:\work\PMsyscard\wiki\systems\`

每个系统或子系统一个卡片，例如：

- `D:\work\PMsyscard\wiki\systems\审计系统.md`
- `D:\work\PMsyscard\wiki\systems\财务共享.md`

职责：

- 沉淀跨项目复用的系统知识
- 记录边界、职责、模块、角色、接口、权限、兼容约束、历史坑点
- 为后续项目提供可引用上下文，而不是每次重新解释

## 3. 项目状态文件模型

项目状态文件负责运行时门禁，不负责承载全部业务细节。

建议最小结构：

```json
{
  "current_mode": "alignment_loop",
  "current_stage": "omp-reply",
  "current_version": "v0.3",
  "last_action": "",
  "next_recommended": "",
  "context_summary": "",
  "context_package": {
    "request_summary": "",
    "business_stage": "",
    "system_or_page_clues": [],
    "material_paths": [],
    "context_gaps": []
  },
  "traceability": {
    "meta": {
      "version": "",
      "scope_summary": "",
      "business_goal": "",
      "in_scope": [],
      "out_of_scope": [],
      "open_questions": [],
      "confirmed_facts": [],
      "can_progress": false
    },
    "anchors": {
      "modules": []
    },
    "artifact_contract": {
      "prototype_covers": [],
      "prd_covers": [],
      "shared_refs": [],
      "must_not_repeat": []
    }
  },
  "stable_baselines": {
    "response_plan": "",
    "prototype": "",
    "prd": "",
    "review_pack": ""
  },
  "memory_refs": {
      "project_memory": ".ohmypm/memory.md",
      "system_memory_index": "D:\\work\\PMsyscard\\wiki\\index.md",
      "system_memory_cards": []
  },
  "latest_artifacts": {
    "response_notes": [],
    "prototypes": [],
    "prd": "",
    "review_records": [],
    "fix_records": [],
    "change_records": []
  },
  "loop_state": {
    "round_number": 0,
    "round_goal": "",
    "round_inputs": [],
    "current_output": "",
    "round_result": "",
    "history_summary": ""
  },
  "fallback_state": {
    "fallback_type": "",
    "fallback_reason": ""
  },
  "change_state": {
    "change_category": "",
    "change_category_confirmed_by_pm": false
  },
  "blockers": [],
  "pending_confirmations": [],
  "review_state": {
    "last_review_result": "",
    "must_fix_before_next_stage": []
  },
  "overwrite_queue": []
}
```

### 阶段约束

主流程固定为：

- `需求接收`
- `回应/校验循环`
- `开工检查`
- `正式交付`
- `变更控制`

其中：

- `current_mode` 用于标记当前处于回应循环、正式交付还是变更处理中
- `current_stage` 用于标记当前正在执行的具体 skill 或子步骤
- `loop_state` 用于记录当前处于第几轮、这轮输入了什么、这轮产出了什么、这轮结果是什么
- `loop_state.history_summary` 用于保存滚动的轮次历史摘要，便于跨会话回顾
- `fallback_state` 用于记录门禁不通过后当前应回退到哪一类处理
- `change_state` 用于记录变更门禁的分类初判与是否已被 PM 确认
- `context_package` 用于记录听需求阶段的最小上下文包
- `traceability` 用于记录当前版本的最小追溯元数据，供交付、评审和回退判断使用

### 运行时状态机

主控层实际只认五个大节点：

- 听需求
- 回应/对齐
- 开工检查
- 正式交付
- 变更控制

其中的运行时判断由脚本层承担：

- `scripts/tools/state-machine.ps1`：根据最小状态判断当前位于哪个节点、默认优先推进哪个动作
- `scripts/tools/route-resolve.ps1`：把自然语言或强制入口映射到单个动作
- `scripts/control/ompgo.ps1`：串起状态机、路由、门禁、ask-back 与唯一收口

最小迁移关系固定为：

- 听需求 -> 回应/对齐
- 回应/对齐 -> 开工检查
- 开工检查 -> 正式交付
- 正式交付 -> 评审
- 评审 -> 修问题 或 变更控制
- 变更控制 -> 回应/对齐 或 正式交付

ask-back 不是单独主节点，它是阻塞解除动作：

- 当 `pending_confirmations` 非空且当前是真实项目协作时，优先转入 ask-back
- 当当前是样例或演示场景时，不向 PM 追问虚拟业务细节，而是转为内部修正或占位说明

当前脚本层依赖这些状态字段完成最小迁移判断：

- `context_package.*`
- `current_mode`
- `current_stage`
- `loop_state.round_result`
- `fallback_state.fallback_type`
- `pending_confirmations`
- `review_state.must_fix_before_next_stage`
- `change_state.*`

追溯相关字段建议优先用于门禁和交付判断：

- `traceability.meta.*`
- `traceability.anchors.modules`
- `traceability.artifact_contract.*`

## 4. 项目记忆文件模型

项目记忆文件应采用 Markdown，可读性优先，但字段语义要稳定。

建议结构：

```md
# 项目记忆

## 1. 项目概览
- 项目名称：
- 当前需求任务：
- 当前模式：
- 当前版本：

## 2. 已确认事实
- ...

## 3. 未确认事实
- ...

## 4. 未澄清问题
- ...

## 5. 未澄清原因
- ...

## 6. 当前版本方案
- ...

## 7. 本轮变化点
- ...

## 8. 当前建议
- ...

## 9. 当前模块清单
- 模块：
  - 作用：
  - 风险：

## 10. 当前方案预估工时
- 模块：
  - 粗估区间：
  - 依据：

## 11. 排期影响判断
- ...

## 12. 系统记忆引用
- ...

## 13. 新增资料记录
- ...

## 14. 评审摘要
- ...

## 15. 复写记录
- ...
```

### 写入规则

- 项目记忆文件保存“项目语义”，不是纯操作日志
- 新一轮结论应覆盖旧判断，但关键变更原因要保留在“本轮变化点”或“复写记录”
- 事实、推断、建议不得混写
- 评审结果和修正规则必须同步写入

## 5. 系统记忆卡模型

系统记忆卡用于沉淀跨项目知识，必须弱化项目特定说法，强化系统边界和可复用事实。

建议模板：

```md
# 系统记忆卡：<系统名>

## 1. 系统定位
- 系统职责：
- 服务对象：
- 上下游关系：

## 2. 模块结构
- 模块：
  - 职责：
  - 不负责什么：
  - 常见改造点：

## 3. 页面与流程线索
- 关键入口：
- 主流程：
- 常见例外：

## 4. 角色与权限
- 角色：
  - 可见范围：
  - 核心动作：
  - 特殊限制：

## 5. 数据与接口约束
- 关键数据对象：
- 对外接口：
- 依赖系统：
- 常见同步问题：

## 6. 存量兼容约束
- 历史包袱：
- 不能轻易改动的地方：
- 常见冲突点：

## 7. 已知风险与坑点
- ...

## 8. 证据来源
- 文档：
- 截图：
- 会议：
- 项目记忆回写：

## 9. 最近更新
- 更新时间：
- 更新原因：
```

### 写入原则

- 只写可复用信息，不写某个项目的一次性讨论细节
- 没有证据支持的推断必须显式标注
- 若系统知识被新项目推翻，必须回写并注明依据

## 6. 三类文件的边界

### `ohmypm-status.json` 负责

- 能不能继续
- 当前在什么阶段
- 当前稳定基线是什么
- 当前阻塞和待确认项是什么
- 当前是第几轮回应/校验
- 当前轮次的历史摘要是什么
- 当前门禁不通过时的回退类型是什么
- 当前变更分类初判是什么

### `ohmypm-memory.md` 负责

- 这个项目目前到底理解成什么了
- 哪些已确认，哪些未确认
- 当前方案、模块、粗估、评审、回写记录是什么
- `需求任务`
- `当前版本号`
- `已确认事实`
- `未确认事实`
- `未澄清问题`
- `未澄清原因`
- `当前版本方案`
- `本轮变化点`
- `当前建议`
- `当前模块清单`
- `当前方案预估工时`
- `排期影响判断`
- `系统记忆引用`
- `新增资料记录`

### `D:\work\PMsyscard\wiki\systems\*.md` 负责

- 某个系统长期稳定的知识是什么
- 哪些边界、权限、兼容性和坑点可跨项目复用

## 7. 回写关系

### 常规回写

- 阶段型 skill 完成后：更新 `ohmypm-status.json`
- 当前轮次有实质性认知变化后：更新 `ohmypm-memory.md`
- 新获取到可复用系统知识后：更新对应系统记忆卡

### 评审回写

- 评审结论写入 `ohmypm-status.json.review_state`
- 评审摘要写入 `ohmypm-memory.md`
- 与系统边界相关的新结论，按需回写系统记忆卡

### 下游复写回写

- 若下游修正上游成立：同步更新上游产物路径、状态基线和复写记录
- 若复写影响系统认知：同步更新系统记忆卡

## 8. 版本与基线规则

- `current_version` 记录当前正在处理的方案版本
- `stable_baselines` 只记录已被确认可继续引用的稳定版本
- 下游生成时不得混用旧基线和新版本
- 版本关系未判清时，必须阻断推进

## 9. 与 ShitPM 的关系

可直接参考的部分：

- `ohmypm-status.json` 的状态驱动思路
- `blockers`、`pending_confirmations`、`stable_baselines` 的运行时作用
- `context_summary` 作为跨会话摘要入口

需要新增的部分：

- `ohmypm-memory.md` 作为项目语义主存
- `D:\work\PMsyscard\wiki\` 作为跨项目知识主存
- `overwrite_queue` 和复写记录，用于管理下游修正上游

