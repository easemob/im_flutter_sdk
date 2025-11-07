## 4.15.2
- 修复被登出时,返回220的错误码无法触发回调的问题;
- 修复 `fetchReactionDetail` 获取不存在的Reaction时崩溃的问题;
- 新增 `getCurrentDeviceId` API ;
- 新增 `loadConversationMessagesWithKeyword` API ;
- 修复频繁调用会话API时, 导致的ANR问题;

## 4.15.1

## 4.15.0

## 4.13.0+1

- 修复收到 `onAnnouncementChangedFromChatRoom` 回调时，`announcement` 为空导致的崩溃问题。
- 修复收到 `onAnnouncementChangedFromGroup` 回调时，`announcement` 为空导致的崩溃问题。

## 4.13.0

* 更新原生sdk为 4.13.0
