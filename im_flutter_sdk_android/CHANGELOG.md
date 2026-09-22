## 5.0.0
- Android 依赖 SDK 升级到 5.0.0；
- 适配 Token 登录、数据同步、批量已读回执和群组配置重构；
- 移除 native 5.0.0 已删除的旧 wrapper 路由和监听回调；
- 断开事件统一为 `onDisconnected` 并透传平台原因码：`onDisconnected(int)` 的原因码不再按码拆分事件，206 的设备信息由 `onLogout` 合并后随同一事件下发；
- 原因码改用 `EMError` 常量，并按退出原因清理待执行的监听回调；
- 批量已读回执移除 wrapper 预校验：无法解析为本地消息的 messageId 跳过而不是整批返回 1，是否受理由 native 判定（整批不可解析时返回 110）；
- 消息附件与缩略图下载改用带 `EMCallBack` 的重载，替换 native 5.0.0 已废弃的单参重载；
- 删除服务端拉取历史消息选项中不可达的 `from` 兜底分支：Dart 侧已只下发 `senders`，native `setFrom` 已废弃且由 `setFromIds` 取代；
- 新增 `deleteConversations` 批量删除本地会话的原生实现（`asyncDeleteConversations`）；
- 删除无监听方的 `onMessageDeliveryAck` 逐条下发与 `onMessagesRecalled` 残留常量；
- 删除会话内关键词搜索（`loadMsgWithKeywords`）中不可达的 `from` 兜底分支：Dart 侧已只下发 `senders`；
- 移除图片消息 body 的 `thumbnailSecret` 透传（native 5.0.0 已废弃且 RN 已对齐删除，视频 body 保留）；

## 4.24.0
- 安卓依赖 SDK 升级到 4.24.1；
- 新增服务端消息搜索的原生实现；

## 4.22.0
- 安卓依赖 SDK 升级到 4.22.1；
- 新增图片消息原图（大图）下载、语音转文字、群名片、联系人同步、用户属性订阅等新 API 的原生实现；

## 4.19.2
- 安卓依赖 SDK 升级到 4.19.3.1；
- 修复 Flutter Android 上发送视频没有设置首帧缩略图时无法发送的问题；

## 4.19.1
- 安卓依赖 SDK 升级到 4.19.2；
- 修复大文件无法进行分片上传的问题；

## 4.19.0
- 安卓依赖 SDK 升级到 4.19.1；
- 支持接收流式消息；

## 4.18.0
- 安卓依赖 SDK 升级到 4.18.1；
- 底层支持安全 DNS 解析 DoH，提高连通性；

## 4.17.0
- 安卓依赖 SDK 升级到 4.17.1；
- 长连接支持 WebSocket 协议；
- 私有化部署底层链路支持 TCP 和 WebSocket 之间切换；

## 4.16.0
- 安卓依赖 SDK 升级到 4.16.1；
- 新增 `loadMessagesWithIds` API；
- 修复 `Thread` 子区会被加入到 `conversation` 列表中；
- 修复 当修改文本和自定义消息之外的消息时，`EEMChatEventHandler#onMessageContentChanged` 回调中不返回修改的信息的问题；
- 修复 拉取漫游消息时，设置为不保存消息 `FetchMessageOptions#needSave 设置为 false`，也会生成新的本地会话的问题；
- 修复 群组或聊天室解散后，成员收到回调后，仍然会从服务器获取群组或聊天室详情的问题；
- 修复 更新群组属性时影响群组头像问题；
- 更新 `AOSL` 库版本为 1.3.0；
- 支持私有部署时设置 `IPv6` 格式的 REST 地址；

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
