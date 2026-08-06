# Android 基线：iOS 差异记录

基准：Android SDK 4.23.0。只记录当前已实测的 iOS SDK 4.24.0 差异。

## 2026-08-06

| 类型 | Android 基线 | iOS 实测差异 | 涉及事件/接口 | 处理 |
|---|---|---|---|---|
| 缺少字段 | Android 有时序列化 `body.translations` | iOS `translations == nil` 时不输出该键 | `onMessagesRecalledInfo`、消息同步事件 | 不写入跨平台公共 expected |
| 多出字段 | Android `EMHelper.toJson` 未输出 `groupAckCount` | iOS `MessageHelper.toJson` 输出 `groupAckCount` | 消息事件、`ChatManager.getMessage` | 事件允许额外字段；response 按白名单处理 |
| 多出字段 | Android 基线未声明 `receiverList` | iOS `MessageHelper.toJson` 输出 `receiverList` | `ChatManager.getMessage` | 仅忽略已确认的端侧附加字段 |
| 回调缺失 | 实测可收到 `onMessagesRecalled` | iOS 4.24 撤回流程未收到 `onMessagesRecalled` | 撤回回调 | 公共 case 只验证 `onMessagesRecalledInfo` |

代码依据：

- Android：`im_flutter_sdk_android/android/src/main/java/com/easemob/im_flutter_sdk/EMHelper.java`
- iOS：`im_flutter_sdk_ios/ios/Classes/MessageHelper.m`

这些差异主要是两端 `toJson` 序列化实现不同，不代表业务语义一定是 iOS 独有。

## 断言规则

- Android 字段是公共契约的基准。
- iOS 缺少的非业务字段：从公共 expected 移除。
- iOS 多出的非业务字段：事件允许额外字段；response 仅按白名单忽略。
- 核心业务字段缺失或值错误：仍然失败。
- iOS 特有能力或旧回调：单独建立 iOS case，不修改 Android 基线。
