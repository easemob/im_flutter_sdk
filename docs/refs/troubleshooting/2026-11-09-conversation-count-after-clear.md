# 清空会话后消息列表为空，但消息计数仍为 1

- 日期：2026-11-09。
- 状态：双端实际复现；用户决定先记录、跳过，不修改 SDK 或放宽断言。
- 触发仓库：`im_flutter_sdk`，5.1.0 worktree，基线 `adf9764b`。
- 适用环境：Flutter 3.47.0，Android/iOS native 5.1.0，Android Pixel_9、iOS 18.2 模拟器。

## 结论

`deleteAllMessages()` 后，列表和单条读取均不再返回该消息，`messagesCount()` 却仍返回 1。当前证据指向 SDK 的消息计数与可查询内容不一致，不能误写成“消息没有删除”。具体 JNI/core 根因尚未确定。

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
