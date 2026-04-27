# OhMyPm 追溯元数据契约

## 1. 原则

- 元数据是门禁输入
- 元数据属于内部追溯约束，不进入正式正文
- 下游产物生成前后都要回看元数据

## 2. 最小结构

OMP 的最小强追溯元数据固定分三部分：

### 2.1 全局元数据 `meta`

至少包含：

- `version`
- `scope_summary`
- `business_goal`
- `in_scope`
- `out_of_scope`
- `open_questions`
- `confirmed_facts`
- `can_progress`

### 2.2 内容锚点 `anchors`

至少包含三级：

- 模块锚点
- 页面锚点
- 流程 / 动作锚点

内部锚点必须支持组合追溯：

- 模块内部编号：`Mxx`
- 页面内部编号：`Pxx`
- 动作内部编号：`Axx`
- 动作级组合锚点：`Mxx-Pxx-Axx`

组合锚点只属于 `.ohmypm` 内部追溯元数据，不进入 PRD 正文标题、原型可见文案或评审对外结论。

### 2.3 产物承接 `artifact_contract`

至少包含：

- `prototype_covers`
- `prd_covers`
- `shared_refs`
- `must_not_repeat`

## 3. 全局元数据要求

### 3.1 `version`

- 标识当前方案版本
- 新旧版本关系未判清时，不得继续推进更重阶段

### 3.2 `scope_summary`

- 必须是一句话范围摘要
- 用于判断当前产物是否超范围

### 3.3 `business_goal`

- 必须说明本次到底想解决什么问题

### 3.4 `in_scope` / `out_of_scope`

- 必须同时存在
- 不能只写做什么，不写不做什么

### 3.5 `open_questions`

- 必须只记录会影响推进判断的问题
- 不得把普通优化建议塞进这里

### 3.6 `confirmed_facts`

- 只记录已确认事实
- 推断和待确认项不得混写进来

### 3.7 `can_progress`

- 只要 `open_questions` 会推翻当前主判断，则必须为 `false`

## 4. 模块 / 页面 / 流程锚点要求

## 4.1 模块锚点

每个模块至少回答：

- 模块名
- 本次角色：`primary / affected / reference`
- 本次模块目标
- 是否在范围内

## 4.2 页面锚点

每个页面至少回答：

- 页面名
- 所属模块
- 页面角色：`new / changed / affected / reference`
- 页面目标
- 入口位置

## 4.3 流程 / 动作锚点

每个流程至少回答：

- 流程名
- 流程角色：`main / branch / exception`
- 触发条件
- 参与角色
- 动作清单
- 异常清单
- 验收点

每个动作至少回答：

- `anchor_id`
- 动作名
- 发起角色
- 动作结果
- `rules_ref`
- `prototype_ref`

`rules_ref` 与 `prototype_ref` 应优先保存为内部定位信息：

- PRD 使用章节路径或标题路径定位
- 原型使用文件、页面编号和标注编号定位
- 人读产物中只保留自然标题、页面编号和页面内小数字标注

## 5. 产物承接要求

### 5.1 原型负责

- 页面落点
- 主流程
- 关键状态
- 关键动作
- 标注编号

### 5.2 PRD 负责

- 规则
- 异常
- 权限
- 数据影响
- 验收口径

### 5.3 强制规则

- 原型和 PRD 的边界必须写清
- 两者共享引用必须可对齐
- 不得整段重复

## 6. 阻断规则

出现以下情况时，必须阻断推进：

- 没有模块锚点却写模块内容
- 没有页面锚点却写页面说明
- 没有流程 / 动作锚点却写规则正文
- `prototype_ref` 和 `rules_ref` 无法对齐
- `open_questions` 会影响主判断但 `can_progress=true`
- 当前产物引用了旧版本范围或旧锚点

## 7. 正文边界

- 追溯元数据不进入正式正文主体
- 可进入状态、附录、隐藏区、review pack
- 不得把“元数据说明”写成用户要看的业务内容
