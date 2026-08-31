# Web 5.0 字段差异记录

## Chat / Message

以下字段在 Android/iOS 消息对象中存在，但 Web 5.0 原生 `Message` 和对应消息事件中缺失。

| 缺失字段 | Web 5.0 API | Web 5.0 事件 | 当前问题 |
|---|---|---|---|
| `hasDeliverAck` | `sendMessage`、`getHistoryMessages`、`searchMessages`、`modifyMessage` | `onMessage`、`onMessageDelivered`、`onMessageUpdated` | API 返回消息和事件消息均缺失 |
| `hasRead` | `sendMessage`、`getHistoryMessages`、`searchMessages`、`modifyMessage` | `onMessage`、`onMessageDelivered`、`onMessageUpdated` | API 返回消息和事件消息均缺失 |
| `localTime` | `sendMessage`、`getHistoryMessages`、`searchMessages`、`modifyMessage` | `onMessage`、`onMessageDelivered`、`onMessageUpdated` | API 返回消息和事件消息均缺失；仅有 `timestamp` |
| `fileStatus` | `createImageMessage`、`createVideoMessage`、`createVoiceMessage`、`createFileMessage`、`sendMessage`、`getHistoryMessages` | `onMessage` | API 返回消息和事件消息均缺失 |
| `thumbnailStatus` | `createImageMessage`、`createVideoMessage`、`sendMessage`、`getHistoryMessages` | `onMessage`、`onMessageDelivered`、`onMessageUpdated` | API 返回消息和事件消息均缺失 |

## Push / Silent Mode

以下字段在 Web 5.0 静默模式结果中缺失。

| 缺失字段 | Web 5.0 API | 当前问题 |
|---|---|---|
| `convId`、`conversationType` | `fetchSilentModeForAll` | 全局静默模式结果没有会话标识 |
| `expireTs`、`startTime`、`endTime` | `fetchSilentModeForAll`、`fetchConversationSilentMode` | `paramType=0` 结果中缺失 |
| `expireTs` | `fetchConversationSilentMode` | `paramType=2` 结果中缺失 |
| `startTime`、`endTime` | `fetchConversationSilentMode` | `paramType=1` 结果中缺失 |
