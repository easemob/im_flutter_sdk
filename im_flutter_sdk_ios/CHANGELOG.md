## 4.22.0
- iOS依赖 SDK 升级到 4.22.1；
- 新增图片消息原图（大图）下载、语音转文字、群名片、联系人同步、用户属性订阅等新 API 的原生实现；

## 4.19.2
- 新增 iOS Swift Package Manager 集成支持；

## 4.19.1

## 4.19.0
- iOS依赖 SDK 升级到 4.19.1；
- 支持接收流式消息；

## 4.18.0
- iOS依赖 SDK 升级到 4.18.1；
- 底层支持安全 DNS 解析 DoH，提高连通性；

## 4.17.0
- iOS依赖 SDK 升级到 4.17.1；
- 长连接支持 WebSocket 协议；
- 私有化部署底层链路支持 TCP 和 WebSocket 之间切换；

## 4.16.0
- iOS依赖 SDK 升级到 4.16.2；
- 新增 `loadMessagesWithIds` API；
- 修复 当修改文本和自定义消息之外的消息时，`EEMChatEventHandler#onMessageContentChanged` 回调中不返回修改的信息的问题；
- 修复 拉取漫游消息时，设置为不保存消息 `FetchMessageOptions#needSave 设置为 false`，也会生成新的本地会话的问题；
- 修复 群组或聊天室解散后，成员收到回调后，仍然会从服务器获取群组或聊天室详情的问题；
- 修复 更新群组属性时影响群组头像问题；
- 更新 `AOSL` 库版本为 1.3.0；
- 支持私有部署时设置 `IPv6` 格式的 REST 地址；

## 4.15.2
- 修复 `fetchReactionDetail` 获取不存在的Reaction时崩溃的问题;
- 新增 `getCurrentDeviceId` API ;
- 新增 `loadConversationMessagesWithKeyword` API ;

## 4.15.1

## 4.15.0

## 4.13.0+1

- 修复收到 `onAnnouncementChangedFromChatRoom` 回调时，`announcement` 为空导致的崩溃问题。
- 修复收到 `onAnnouncementChangedFromGroup` 回调时，`announcement` 为空导致的崩溃问题。

## 4.13.0

* 更新原生sdk为 4.13.0
