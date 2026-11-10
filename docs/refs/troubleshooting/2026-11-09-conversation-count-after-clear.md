# 清空会话后消息列表为空，但消息计数仍为 1

- 日期：2026-11-09。
- 状态：双端实际复现；用户决定先记录、跳过，不修改 SDK 或放宽断言。
- 触发仓库：`im_flutter_sdk`，5.1.0 worktree，基线 `adf9764b`。
- 适用环境：Flutter 3.47.0，Android/iOS native 5.1.0，Android Pixel_9、iOS 18.2 模拟器。

## 结论

`deleteAllMessages()` 后，列表和单条读取均不再返回该消息，`messagesCount()` 却仍返回 1。当前证据指向 SDK 的消息计数与可查询内容不一致，不能误写成“消息没有删除”。初次排查未确定 JNI/core 根因；2026-11-10 已在 core tag 源码中确认异步删除提前返回的竞争窗口，见下文补充。

## 现象与证据

`FL-CONV-006` 创建独有本地会话，插入四条消息，通过按 ID 和时间删除留下最后一条，再 `await deleteAllMessages()`；最后计数应为 0。

| 运行 | 删除后实际观察 | 结果 |
|---|---|---|
| Android nightly 首轮 | count=1 | 原计数断言失败 |
| Android 独立 autoLoad=false | 原断言通过一次 | 不能用单次成功覆盖全量失败 |
| Android 独立 autoLoad=true | count=1 | 不能归因于本轮关闭自动加载 |
| Android nightly-r2 | count=1，列表 `[]`，直接读取末条=null | 数量与内容不一致 |
| iOS 独立诊断 | count=1，列表 `[]`，末条读取抛 code=3 | 原计数断言失败；末条查询仅作诊断，不额外要求与 Android 相同返回 |

日志位于 `reports/5.1.0/test-coverage/`：`nightly-android.log`、`conv006-android-autoload-{false,true}.log`、`nightly-android-r2.log`、`conv006-ios-diagnostic.log`。iOS 首轮 nightly 的临时诊断未捕获缺失消息错误，曾提前中断；已修正诊断代码并独立复验，不把该次中断冒充 SDK 计数断言结果。

## 已确认边界

- Dart 公开契约要求删除内存和数据库中的全部消息。wrapper 在 native `clearAllMessages()` 返回后才回传成功，未发现用例漏等异步完成。
- Android `EMConversation.clearAllMessages()` 是同步 void；JNI 返回的 boolean 被 native Java API 本身丢弃，Flutter 无可用公开返回值可补检查。
- 计数来自 native `getAllMsgCount()`，不是 Dart 本地缓存。相关 Java 方法在 5.0.0→5.1.0 无 diff，不能据此认定 core 没有问题。
- 测试使用本轮独有会话和消息；未借助清历史、固定延时或重试掩盖失败。

## 处理与排查备忘

保留计数和列表断言，诊断输出不改变判据。用户于本轮明确要求该问题与发送回调状态问题先记录、跳过；暂不继续修复或深挖，也不计入通过。

```bash
rg -n 'FL-CONV-006 after|Expected:|Actual:' reports/5.1.0/test-coverage/*006*.log reports/5.1.0/test-coverage/nightly-android-r2.log
```

## 2026-11-10 源码定位及 Jira

工单：[HIM-24174](https://j1.private.easemob.com/browse/HIM-24174)。Android/iOS 历史日志摘录已上传并回读核验。

只读核查 core `SDK_5.1.0`（`e5d925cb5589e2c7be304d47b0eafc5c7c2b1c60`），使用 `git show` 排除 native 工作区未提交改动：

- `src/emconversationprivate.cpp:711` 的 `clearAllMessages()` 清理最新消息引用和未读数后，将数据库删除加入 `mTaskQueue`，立即返回 `true`；后台删除失败只 `reload()`，不回传原调用者。
- `src/emtaskqueue.cpp:247` / `:115` 仅入队并唤醒工作线程，不等待删除完成。
- `src/emconversationprivate.cpp:306` 的 `messagesCount()` 直接查询数据库；`src/emdatabase.cpp:2274` 执行 `SELECT count(*)`，删除则由 `:1885` 执行。
- Android JNI 和 iOS native 均转发至这些 core 方法。Dart 正确 await，两端 Flutter wrapper 在 native 方法返回后回传；未发现 Flutter 计数缓存或参数映射错误。

**更准确的解释**：清空入队后提前返回，计数查询可能先读到 1；随后后台完成删除，再执行的列表/单条查询为空。这些查询先后执行，不能认定计数永久不更新。该竞争机制与双端历史现象、偶发通过一致，但未对历史二进制进行线程/SQL 打点，实际故障执行顺序仍需 native 复现确认。

修复建议：由 core 维护者确认线程/锁约束，使成功返回代表数据库删除完成，或提供真实完成/失败回调供上层等待；验证入队失败和删除失败的错误传播，不盲目阻塞队列或添加固定延时。已有正确断言保留，未修改 SDK、未重新运行设备测试。

## 2026-11-10 最小场景与延迟读取复验

用户要求验证“直接插入 4 条 → 清空 → 立即读取总数”，并对照延迟几秒是否恢复。使用既有 `logged_in_base_test.dart` 入口，仅临时替换 FL-CONV-006 的模块内容；测试后逐字节恢复原源码，未改 SDK、入口或初始化配置。

环境：iOS 18.2 iPhone 16 Pro 模拟器，Flutter 3.47.0 / Dart 3.13.0；`Podfile.lock` HyphenateChat 5.1.0；代码基线 `c0fc7a9c`，`autoLoadConversations=true`，仅会话列表同步。Android 本轮未测。

| 场景 | 清空前数量 | 清空返回后立即数量 | 再等 3 秒后的数量 | 延迟后的列表 |
|---|---:|---:|---:|---|
| 最小：插入 4 条，直接清空 | 4 | 4 | 0 | `[]` |
| 原流程：按 ID/时间先删到 1 条，再清空 | 1 | 1 | 0 | `[]` |

从调用清空开始计时：最小场景返回耗时 578 微秒，立即计数返回于 743 微秒，延迟计数返回于 3003994 微秒；原流程对应 466 / 686 / 3003632 微秒。这是 Dart 侧观测耗时，不是 core SQL 执行时间。

结论：前置的按 ID/时间删除不是复现必要条件；本轮两场景均观察到旧计数随后恢复为 0，支持“清空提前返回、后续读取与后台删除竞争”的源码分析，不是计数永久不更新。3 秒只是本次观察点，不是必要延迟阈值或稳定修复方案。未对 core 线程/SQL 打点，不把 Dart 观察冒充数据库精确调度证据。

统计：执行 2 项，0 通过 / 2 失败，均因立即计数不为 0；延迟计数和空列表断言均通过，夹具清理、退出登录通过。不将延迟恢复作为原契约通过。

- 正式报告：`artifacts/ci/20261110-155329-ios-iiqmuzaw/summary.md`
- 原始日志：同目录 `attempt-1.log`，结构化事件 `attempt-1.events.jsonl`
- 临时诊断源码与恢复校验：`artifacts/diagnostics/20261110-155251-conv006-minimal/`
- 命令：`CI_TEST_NAME='FL-CONV-006 diagnostic' MAX_ATTEMPTS=1 E2E_CONFIG_PATH=<临时凭据文件> bash tool/ci/run_ios_simulator_test.sh integration_test/logged_in_base_test.dart conv006-minimal-ios.log`；凭据文件已删除。

HIM-24174 的长流程仍是有效复现；本轮获得了可替换它的最小复现和延迟对照证据。随后按用户要求更新 HIM-24174 的 `description`，加入最小步骤、iOS 实测数据及证据边界；回读正文完全一致，其他字段未修改。
