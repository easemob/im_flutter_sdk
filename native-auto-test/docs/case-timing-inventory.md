# Cases 语义时间配置词汇表

本文件取代原 430 个迁移参数/调用点长表，只说明配置契约；任务状态以 `.doc/specs/shared-runtime-config/tasks.md` 第 13 节为准。业务边界证据见 `case-dependency-audit.md`，不是第二份默认值来源。

## 调用与覆盖

```python
seconds('timeout.event', module='contact')
pause('step.interval', module='group')
wait_until(probe, predicate, key='settle.offline', module='group', reason='...')
```

预算是**上限**，不是必须等满的时长（见 `.doc/specs/bounded-wait-early-exit`）：

- `pause(key, module=)`：固定等待，用于没有只读探针的边界；语义不变。
- `wait_until(probe, predicate, *, key, module, interval='poll.interval', reason)`：立即首探，条件满足即返回，间隔 sleep 夹在剩余预算内，上限耗尽仍未满足则抛 AssertionError（只报语义名/上限/探测次数，不回显探针返回值）。`probe` 必须只读幂等，禁止用发送、已读回执、历史拉取、下载类命令。
- `drain_events(timeout=)`：`timeout` 是上限，接收队列连续空闲 `DRAIN_IDLE_SECONDS`（算法常量 0.3，不可配置）即提前返回；队列一直有货则到上限返回，不报错。
- 负向观察窗口（`observe.*`）与时间戳间隔（`settle.sort_spacing`、`settle.cursor_order`）必须等满，不引入提前返回：它们的成功条件就是"整个窗口内没有响应"或"时间真实流逝"。

配置来自当前环境文件 `app.case_timing`，单位秒。所有段统一：**模块语义值 > 全局语义值 > 模块 default > 全局 default > 内置默认**。default 只填未明确指定的语义值。

```yaml
app:
  case_timing:
    step: 1
    settle: {offline: 3, normal: 5, slow: 15}
    timeout:
      event: 10
      contact:
        event: 20
        default: 40
      default: 60
    drain: {offline: 0.5}
```

模块：chat/group/chatroom/contact/client/presence/push/user_info/session/shared。session 用于 session fixture，shared 用于通用发送工具；offline helper 必须从业务调用者显式接收 module。模块标量是 module.default 简写，step 标量是 step.interval 简写。未填写字段使用内置值，无需抄全表。

零值规则：step/settle/drain/retry 允许 0；timeout/observe/poll 必须正数。数值必须有限、非布尔。所有 timing 配置分支均校验，拼错或过期字段直接报错，不打印原始配置/凭据。

## 迁移与边界

- 442 个使用中的旧键（包含 430 个迁移键）收敛为 59 个语义键；本轮不为了达到 30 键而改变有效默认预算。
- 原 1232 处时间表达式中 50 处读取下限改为算法常量，其余 1182 处使用显式模块语义配置。101 个含时间调用文件在把时间值还原、移除新增 module 参数后，全文件 AST 与迁移前一致：没有移动 sleep、删断言或改变默认预算。
- 移除 SETTLE_CLASSES、键名前缀模块推断和旧 *_SETTLE_SECONDS 环境变量读取。旧文件/函数长键、offline_after_logout/offline_before_login/offline_after_login、旧 step 模块键调用不再支持。旧 YAML 字段报错；旧时间环境变量不再生效。IM_TEST_CONFIG 仍负责选择环境文件。
- 配置旧 `step: {group: 2}` 仍有效（模块 default），新调用为 `pause('step.interval', module='group')`。旧 `step: {interval: 1}` 仍有效；`settle.offline/normal/slow` 仍有效。
- 父消息 `parent_message=5` 是独立语义，不再经 normal 别名覆盖；排序 1/1.1/1.5、缩略图 30、离线回放 60 秒均保持。
- `drain.offline` 现在被离线 flow 与业务前置/恢复清理共同使用；正向 onMessageSuccess/onMessagesReceived 等待已改用 timeout.event，不受 drain.default 控制。
- `poll.receive*` 是阻塞读取切片，`poll.interval/server_state/member_state` 是查询间隔。RECEIVE_TIMEOUT_FLOOR=0.1、POSITIVE_TIMEOUT_EPSILON=1e-6 是算法保护常量，不允许 YAML 改变；本次仅取消其可调性，不重写既有 deadline 算法。
- 特殊预算按用途拆分；timeout.message/message_delivery/online_delivery 等保留现有不同层次的预算 profile，不表示轮询次数。后续统一这些预算是单独的行为变更。
- 同次操作回调连续收集；无事件观察保留完整窗口；稳定等待不 drain。app.wait、桥接传输超时、业务时间戳/禁言期限/订阅 expiry 不受影响。

## 词汇与默认值

### step

| 语义键 | 默认秒 | 用途 |
|---|---:|---|
| `step.interval` | 1 | 普通依赖操作间隔；不是回调之间的间隔 |

### settle

| 语义键 | 默认秒 | 用途 |
|---|---:|---|
| `settle.offline` | 3 | 退出后、对端操作完成至重登前、startCallback 后共用稳定窗口 |
| `settle.normal` | 5 | 常规业务传播：历史、修改/撤回、成员和配置稳定 |
| `settle.slow` | 15 | 好友建立及 reaction 写入后的慢稳定窗口 |
| `settle.parent_message` | 5 | 子区创建前父消息可见性；独立于 normal |
| `settle.local_projection` | 2 | 本地会话/消息/置顶投影传播 |
| `settle.history_projection` | 2 | 历史查询之间的存储投影稳定 |
| `settle.ack_projection` | 2 | 群已读计数服务端投影稳定 |
| `settle.cursor_order` | 1.1 | 确保服务端秒级排序跨刻度（不可随普通 step 归零） |
| `settle.sort_spacing` | 1 | 会话排序用消息发送间距 |
| `settle.sort_projection` | 1.5 | 排序结果读取前投影稳定 |
| `settle.thumbnail_completion` | 30 | 缩略图完成状态专用稳定时间 |

### timeout

| 语义键 | 默认秒 | 用途 |
|---|---:|---|
| `timeout.event` | 10 | 普通即时回调/入群/好友 flow 确认 |
| `timeout.message` | 20 | 在线消息操作回调预算（基础 profile） |
| `timeout.message_delivery` | 30 | 关联 msgId/content 的消息投递回调预算 |
| `timeout.message_change` | 30 | 修改/撤回/置顶关联回调 |
| `timeout.online_delivery` | 60 | 在线扩展发送/群消息完整投递预算 |
| `timeout.send_terminal` | 30 | 发送成功或失败终态预算 |
| `timeout.send_completion` | 60 | 完整发送成功确认预算（含扩展消息） |
| `timeout.replay` | 60 | 离线消息/操作回放整体预算 |
| `timeout.read_ack` | 60 | 会话已读确认回调 |
| `timeout.reaction` | 60 | reaction 操作关联回调 |
| `timeout.delivery_confirmation` | 3 | 登录后的快速送达确认 |
| `timeout.download` | 60 | 附件下载回调整体预算 |
| `timeout.contact_change` | 20 | 好友申请处理及关系变更回调 |
| `timeout.friend_invitation` | 5 | 建立聊天前置关系时的邀请回调 |
| `timeout.friend_probe` | 6 | 首次已有好友关系探测 |
| `timeout.friend_recovery` | 10 | 前置调用超时后的既有恢复探测 |
| `timeout.friend_ready` | 30 | 完整双端好友列表就绪预算 |
| `timeout.friend_sync_start` | 10 | 好友同步开始事件 |
| `timeout.friend_sync_finish` | 20 | 好友同步完成事件 |
| `timeout.offline_sync` | 15 | Client 离线同步开始或完成事件 |
| `timeout.group_event` | 30 | 离线群成员/角色/配置关联事件 |
| `timeout.thread_event` | 20 | 子区事件及成员变更确认 |
| `timeout.member_state` | 8 | 聊天室成员状态就绪 |
| `timeout.pending_operations` | 15 | 置顶前待处理消息操作完成 |
| `timeout.state_projection` | 30 | 标记/索引/成员等状态投影查询预算 |
| `timeout.server_state` | 60 | 会话可见性及历史存储等服务端就绪预算 |

### observe

| 语义键 | 默认秒 | 用途 |
|---|---:|---|
| `observe.no_event` | 3 | 常规负向事件观察完整窗口 |
| `observe.no_membership_event` | 2 | 群成员类负向观察完整窗口 |
| `observe.no_delivery` | 5 | online-only/非成员等不应投递的完整观察窗口 |
| `observe.collect` | 10 | 常规回调组收集；保留 helper 原有提前返回/整窗语义 |
| `observe.moderation` | 5 | 全员禁言回调收集预算 |
| `observe.file_transfer` | 20 | 群文件上传事件组收集预算 |
| `observe.incremental` | 0.5 | 聊天室 ext 逐次事件收集窗口 |
| `observe.optional_progress` | 5 | 可选消息进度事件观察窗口 |

### poll

| 语义键 | 默认秒 | 用途 |
|---|---:|---|
| `poll.interval` | 1 | 一般状态查询之间的 sleep（含既有 ack 重试） |
| `poll.server_state` | 2 | 服务端状态查询之间的 sleep |
| `poll.member_state` | 0.5 | 聊天室成员状态查询之间的 sleep |
| `poll.receive` | 2 | 单次关联事件阻塞读取上限 |
| `poll.receive_batch` | 1 | 回调组/双终态/负向观察的单次读取上限 |
| `poll.receive_progress` | 5 | 进度/错误回调的单次读取上限 |
| `poll.receive_probe` | 0.5 | 入群负向/通用发送 helper 的短读取上限 |
| `poll.buffered_receive` | 0.001 | 过滤清理缓存事件时单次非长阻塞读取上限 |

### drain

| 语义键 | 默认秒 | 用途 |
|---|---:|---|
| `drain.offline` | 0.5 | 离线前置/恢复中短旧事件清理；不清理待断言回放 |
| `drain.generic` | 2 | session 通用事件清理窗口 |
| `drain.sync` | 1 | 好友信息同步前旧事件清理窗口 |
| `drain.buffered` | 0.5 | Contact flow 按事件类型过滤清理的总预算 |

### retry

| 语义键 | 默认秒 | 用途 |
|---|---:|---|
| `retry.backoff` | 1 | 已有登录/前置/建子区重试退避；不增加次数 |
