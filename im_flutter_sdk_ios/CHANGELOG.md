## 5.0.0
- iOS 依赖 SDK 升级到 5.0.0，CocoaPods 与 SPM 保持一致；
- 适配 Token 登录、数据同步、批量已读回执和群组配置重构；
- 适配会话独立 delegate 及 native 5.0.0 删除项；
- 修复分页获取群回执时未返回 `totalCount` 的问题；
- 断开事件统一为 `onDisconnected`：各断开 delegate 折算为平台原因码后统一派发，强制退出回调改为原样透传原因码（补上活跃数达到上限）；
- 删除 5.0.0 已不存在的 `activeNumbersReachLimitation` 与不再使用的 `LoginExtensionInfoHelper`；
- 聊天室信息中的禁言列表改用 native 5.0.0 的 `muteMembers`（取用户 ID 列表）替换已废弃的 `muteList`，对外 JSON 结构不变；
- 批量已读回执移除 wrapper 预校验：无法解析为本地消息的 messageId 跳过而不是整批返回 500，是否受理由 native 判定（整批不可解析时返回 110）；
- 删除服务端拉取历史消息选项中不可达的 `from` 赋值：Dart 侧已只下发 `senders`，native `from` 已废弃且由 `fromIds` 取代；
- 新增 `deleteConversations` 批量删除本地会话的原生实现：经 `getConversationWithConvId` 逐个解析会话、跳过不存在的 ID 后调用 `deleteConversations:isDeleteMessages:completion:`；
- 修复 `onRequestToJoinDeclined` 事件在 `reason`/`decliner` 为 nil 时构造事件字典直接崩溃的问题，事件现在始终携带 `decliner`（nil 时为空字符串）；
- 删除无监听方的 `onMessageDeliveryAck` 逐条下发、`messagesDidRecall:` 死 delegate 方法与相关常量；
- 删除会话内关键词搜索（`loadMsgWithKeywords`）中不可达的 `sender` 兜底分支：Dart 侧已只下发 `senders`；
- 移除图片消息 body 的 `thumbnailSecret` 透传（与 RN 对齐删除，视频 body 保留）；

## 4.24.0
- iOS依赖 SDK 升级到 4.24.1；
- 新增服务端消息搜索的原生实现；

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
