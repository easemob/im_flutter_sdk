import 'package:flutter/material.dart';

import '../internal/inner_headers.dart';

/// ~english
/// The connection event handler.
///
/// For the occasion of onDisconnected during unstable network condition, you don't need to reconnect manually,
/// the chat SDK will handle it automatically.
///
/// Note: We recommend not to update UI based on those methods, because this method is called on worker thread. If you update UI in those methods, other UI errors might be invoked.
/// Also do not insert heavy computation work here, which might invoke other listeners to handle this connection event.
///
/// Adds connection event handler:
/// ```dart
///   ChatClient.getInstance.addConnectionEventHandler(UNIQUE_HANDLER_ID, ConnectionEventHandler());
/// ```
///
/// Remove a connection event handler:
/// ```dart
///   ChatClient.getInstance.removeConnectionEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
///
/// ~chinese
/// 服务器连接监听类。
///
/// 对于不稳定网络条件下的onDisconnected情况，您不需要手动重新连接，
/// SDK会自动处理。
///
/// 添加 connection event handler:
/// ```dart
///   ChatClient.getInstance.addConnectionEventHandler(UNIQUE_HANDLER_ID, ConnectionEventHandler());
/// ```
///
/// 移除 connection event handler:
/// ```dart
///   ChatClient.getInstance.removeConnectionEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
class ConnectionEventHandler {
  /// ~english
  /// Occurs when the SDK connects to the chat server successfully.
  /// ~end
  ///
  /// ~chinese
  /// 成功连接到 chat 服务器时触发的回调。
  /// ~end
  final VoidCallback? onConnected;

  /// ~english
  /// Occurs when the SDK disconnects from the chat server.
  ///
  /// Param [errorCode] The reason code, whose value is identical to the platform SDK
  /// error code. See [ChatDisconnectErrorCode] for the codes this version can receive.
  /// It is `null` when the platform reports no reason, which currently happens on iOS.
  ///
  /// Param [info] Present only when [errorCode] is
  /// [ChatDisconnectErrorCode.USER_LOGIN_ANOTHER_DEVICE]: it carries the name and the
  /// extension information of the device that logged in.
  ///
  /// There are two kinds of reasons:
  /// - A reason listed in [ChatDisconnectErrorCode] as a logout reason means the user has
  ///   been logged out and has to log in again.
  /// - Any other reason, including `null`, only means the connection broke. The user stays
  ///   logged in and the SDK reconnects automatically.
  ///
  /// Note: an expired token does not trigger this callback, see [onTokenDidExpire].
  /// ~end
  ///
  /// ~chinese
  /// 与 chat 服务器断开连接时触发的回调。
  ///
  /// Param [errorCode] 断开原因码，数值与平台 SDK 错误码一致。本版本可能收到的原因码见
  /// [ChatDisconnectErrorCode]。平台未给出原因时为 `null`，当前仅 iOS 会出现。
  ///
  /// Param [info] 仅当 [errorCode] 为 [ChatDisconnectErrorCode.USER_LOGIN_ANOTHER_DEVICE]
  /// 时携带，包含登录设备的名称与扩展信息。
  ///
  /// 原因分两类：
  /// - [ChatDisconnectErrorCode] 中列为「退出原因」的原因码表示用户已被登出，需要重新登录；
  /// - 其它原因（含 `null`）只表示连接中断，用户仍处于登录态，SDK 会自动重连。
  ///
  /// 注意：token 过期不会触发该回调，请见 [onTokenDidExpire]。
  /// ~end
  final void Function(int? errorCode, LoginExtensionInfo? info)? onDisconnected;

  /// ~english
  /// Occurs when the token is about to expire.
  /// ~end
  ///
  /// ~chinese
  /// Agora token 即将过期时触发。
  /// ~end
  final VoidCallback? onTokenWillExpire;

  /// ~english
  /// Occurs when the token has expired.
  ///
  /// The user has been logged out and has to log in again.
  /// ~end
  ///
  /// ~chinese
  /// Agora token 已过期时触发。
  ///
  /// 用户已被登出，需要重新登录。
  /// ~end
  final VoidCallback? onTokenDidExpire;

  /// ~english
  /// Occurs when synchronization of a data type starts.
  /// ~end
  ///
  /// ~chinese
  /// 指定类型的数据开始同步时触发。
  /// ~end
  final void Function(int type)? onDataSyncStart;

  /// ~english
  /// Occurs when synchronization of a data type finishes.
  /// ~end
  ///
  /// ~chinese
  /// 指定类型的数据同步结束时触发。
  /// ~end
  final void Function(int type, ChatError? error)? onDataSyncFinish;

  /// ~english
  /// Occurs when the local database for a user is opened.
  /// ~end
  ///
  /// ~chinese
  /// 指定用户的本地数据库打开时触发。
  /// ~end
  final void Function(String username, ChatError? error)? onDatabaseOpened;

  /// ~english
  /// Occurs when the SDK starts pulling offline messages from the server.
  /// ~end
  ///
  /// ~chinese
  /// 开始从服务器拉取离线消息时触发。
  /// ~end
  final VoidCallback? onOfflineMessageSyncStart;

  /// ~english
  /// Occurs when the SDK finishes pulling offline messages from the server.
  /// ~end
  ///
  /// ~chinese
  /// 从服务器拉取离线消息结束时触发。
  /// ~end
  final VoidCallback? onOfflineMessageSyncFinish;

  /// ~english
  /// The chat connection listener callback.
  ///
  /// Param [onConnected] The SDK connects to the chat server successfully.
  ///
  /// Param [onDisconnected] The SDK disconnects from the chat server, with the reason code and, for a login on another device, the device information.
  ///
  /// Param [onTokenWillExpire] The token is about to expire.
  ///
  /// Param [onTokenDidExpire] The token has expired, and the user has been logged out.
  ///
  /// Param [onOfflineMessageSyncStart] Occurs when the SDK starts pulling offline messages from the server.
  ///
  /// Param [onOfflineMessageSyncFinish] Occurs when the SDK finishes pulling offline messages from the server.
  ///
  /// ~end
  ///
  /// ~chinese
  /// 连接状态监听。
  ///
  /// Param [onConnected] 成功连接到 chat 服务器时触发的回调。
  ///
  /// Param [onDisconnected] 和 chat 服务器断开连接时触发的回调，携带断开原因码，其他设备登录时还携带设备信息。
  ///
  /// Param [onTokenWillExpire] Agora token 即将过期时回调。
  ///
  /// Param [onTokenDidExpire] Agora token 已过期时回调，此时用户已被登出。
  ///
  /// Param [onOfflineMessageSyncStart] 开始从服务器拉取离线消息时触发。
  ///
  /// Param [onOfflineMessageSyncFinish] 从服务器拉取离线消息结束时触发。
  ///
  /// ~end
  ConnectionEventHandler({
    this.onConnected,
    this.onDisconnected,
    this.onTokenWillExpire,
    this.onTokenDidExpire,
    this.onDataSyncStart,
    this.onDataSyncFinish,
    this.onDatabaseOpened,
    this.onOfflineMessageSyncStart,
    this.onOfflineMessageSyncFinish,
  });
}

/// ~english
/// The multi-device event handler.
/// Listens for the callback for the current user's actions on other devices, including contact changes, group changes, and thread changes.
///
/// Adds a multi-device event handler:
/// ```dart
///   ChatClient.getInstance.addMultiDeviceEventHandler((UNIQUE_HANDLER_ID, ChatMultiDeviceEventHandler());
/// ```
///
/// Removes a multi-device event handler:
/// ```dart
///   ChatClient.getInstance.removeMultiDeviceEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
///
/// ~chinese
/// 多设备事件监听
/// 监听当前用户在其他设备上的操作的回调，包括联系人更改、群组和 thread 等更改。
///
/// 添加监听:
/// ```dart
///   ChatClient.getInstance.addMultiDeviceEventHandler((UNIQUE_HANDLER_ID, ChatMultiDeviceEventHandler());
/// ```
///
/// 移除监听:
/// ```dart
///   ChatClient.getInstance.removeMultiDeviceEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
class ChatMultiDeviceEventHandler {
  /// ~english
  /// The multi-device event of contact.
  /// ~end
  ///
  /// ~chinese
  /// 多设备联系人事件。
  /// ~end
  final void Function(ChatMultiDevicesEvent event, String userId, String? ext)?
      onContactEvent;

  /// ~english
  /// The multi-device event of group.
  /// ~end
  ///
  /// ~chinese
  /// 多设备群组事件。
  /// ~end
  final void Function(
    ChatMultiDevicesEvent event,
    String groupId,
    List<String>? userIds,
  )? onGroupEvent;

  /// ~english
  /// The multi-device event of thread.
  /// ~end
  ///
  /// ~chinese
  /// 多设备 Thread 事件。
  /// ~end
  final void Function(
    ChatMultiDevicesEvent event,
    String chatThreadId,
    List<String> userIds,
  )? onChatThreadEvent;

  /// ~english
  /// Callback received by other devices after historical messages in a conversation are removed from the server in a multi-device login scenario.
  /// ~end
  ///
  /// ~chinese
  /// 开启多设备后对单个会话删除漫游消息后对其他设备的回调。
  /// ~end
  final void Function(String conversationId, String deviceId)?
      onRemoteMessagesRemoved;

  /// ~english
  /// The multi-device event callback for the operation of a conversation.
  /// ~end
  ///
  /// ~chinese
  /// 开启多设备后单个会话操作的多设备事件回调。
  /// ~end
  final void Function(
    ChatMultiDevicesEvent event,
    String conversationId,
    ChatConversationType type,
  )? onConversationEvent;

  /// ~english
  /// The multi-device event handler.
  ///
  /// Param [onContactEvent] The multi-device event of contact.
  ///
  /// Param [onGroupEvent] The multi-device event of group.
  ///
  /// Param [onChatThreadEvent] The multi-device event of thread.
  ///
  /// Param [onRemoteMessagesRemoved] The multi-device event of historical messages removed from the server.
  ///
  /// Param [onConversationEvent] The multi-device event callback for the operation of a conversation.
  ///
  /// ~end
  ///
  /// ~chinese
  /// 多设备事件。
  ///
  /// Param [onContactEvent] 多设备联系人事件。
  ///
  /// Param [onGroupEvent] 多设备群组事件。
  ///
  /// Param [onChatThreadEvent] 多设备 Thread 事件。
  ///
  /// Param [onRemoteMessagesRemoved] 多设备漫游消息删除事件。
  ///
  /// Param [onConversationEvent] 多设备单个会话操作事件。
  ///
  /// ~end
  ChatMultiDeviceEventHandler({
    this.onContactEvent,
    this.onGroupEvent,
    this.onChatThreadEvent,
    this.onRemoteMessagesRemoved,
    this.onConversationEvent,
  });
}

/// ~english
/// The chat event handler.
///
/// This handler is used to check whether messages are received. If messages are sent successfully, a delivery receipt will be returned (delivery receipt needs to be enabled: [ChatOptions.requireDeliveryAck].
/// If the peer user reads a message that requests a read receipt, a read receipt is returned.
/// This API should be implemented in the app to listen for message status changes.
///
/// Adds chat event handler:
/// ```dart
///   ChatClient.getInstance.chatManager.addEventHandler(UNIQUE_HANDLER_ID, ChatEventHandler());
/// ```
///
/// Removes a chat event handler:
/// ```dart
///   ChatClient.getInstance.chatManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
///
/// ~chinese
/// Chat 事件监听。
///
/// 用于监听收消息，已读回执，等回调。
///
/// 添加监听：
/// ```dart
///   ChatClient.getInstance.chatManager.addEventHandler(UNIQUE_HANDLER_ID, ChatEventHandler());
/// ```
///
/// 移除监听：
/// ```dart
///   ChatClient.getInstance.chatManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
class ChatEventHandler {
  /// ~english
  /// Occurs when a message is received.
  ///
  /// This callback is triggered to notify the user when a message such as texts or an image, video, voice, location, or file is received.
  /// ~end
  ///
  /// ~chinese
  /// 收到消息回调。
  /// 在收到文本、图片、视频、语音、地理位置和文件等消息时，通过此回调通知用户。
  /// ~end
  final void Function(List<ChatMessage> messages)? onMessagesReceived;

  /// ~english
  /// Occurs when a stream message is received.
  ///
  /// This callback is triggered to notify the user when a stream message is received.
  /// ~end
  ///
  /// ~chinese
  /// 收到流式消息回调。
  /// 在收到流式消息时，通过此回调通知用户。
  /// ~end
  final void Function(List<ChatMessage> messages)? onStreamMessagesReceived;

  /// ~english
  /// Occurs when a command message is received.
  ///
  /// This callback only contains a command message body that is usually invisible to users.
  /// ~end
  ///
  /// ~chinese
  /// 收到命令消息回调。
  /// 与 [onMessagesReceived] 不同, 这个回调只包含命令的消息，命令消息通常不对用户展示。
  /// ~end
  final void Function(List<ChatMessage> messages)? onCmdMessagesReceived;

  /// ~english
  /// Occurs when message read receipts are received.
  /// ~end
  ///
  /// ~chinese
  /// 收到消息已读回执时触发。
  /// ~end
  final void Function(List<ChatMessageReadReceipt> receipts)?
      onMessageReadReceipts;

  /// ~english
  /// Occurs when a delivery receipt is received.
  /// ~end
  ///
  /// ~chinese
  /// 收到消息已送达回执的回调。
  /// ~end
  final void Function(List<ChatMessage> messages)? onMessagesDelivered;

  @Deprecated('Use [onMessagesRecalledInfo] instead')

  /// ~english
  /// Occurs when a received message is recalled.
  /// ~end
  ///
  /// ~chinese
  /// 已收到的消息被撤回的回调。
  /// ~end
  final void Function(List<ChatMessage> messages)? onMessagesRecalled;

  /// ~english
  /// Occurs when a received message is recalled.
  /// ~end
  ///
  /// ~chinese
  /// 已收到的消息被撤回的回调。
  /// ~end
  final void Function(List<RecallMessageInfo>)? onMessagesRecalledInfo;

  /// ~english
  /// Occurs when the conversation updated.
  /// ~end
  ///
  /// ~chinese
  /// 会话更新事件回调。
  /// ~end
  final VoidCallback? onConversationsUpdate;

  /// ~english
  /// Occurs when the Reaction data changes.
  /// ~end
  ///
  /// ~chinese
  /// 消息表情回复（Reaction）变化监听器。
  /// ~end
  final void Function(List<ChatMessageReactionEvent> events)?
      onMessageReactionDidChange;

  /// ~english
  /// Occurs when the message content is modified.
  /// ~end
  ///
  /// ~chinese
  /// 收到消息内容变化。
  /// ~end
  final void Function(
    ChatMessage message,
    String operatorId,
    int operationTime,
  )? onMessageContentChanged;

  /// ~english
  /// Occurs when the message pinning status changes.
  ///
  /// This callback is triggered when the message pinning status changes.
  /// ~end
  ///
  /// ~chinese
  /// 消息置顶状态变化。
  ///
  /// 当消息置顶状态发生变化时触发此回调。
  /// ~end
  final void Function(
    String messageId,
    String conversationId,
    MessagePinOperation pinOperation,
    MessagePinInfo pinInfo,
  )? onMessagePinChanged;

  /// ~english
  /// The chat event handler.
  ///
  /// Param [onMessagesReceived] Occurs when a message is received.
  ///
  /// Param [onStreamMessagesReceived] Occurs when a stream message is received.
  ///
  /// Param [onCmdMessagesReceived] Occurs when a command message is received.
  ///
  /// Param [onMessageReadReceipts] Occurs when message read receipts are received.
  ///
  /// Param [onMessagesDelivered] Occurs when a delivery receipt is received.
  ///
  /// Param [onMessagesRecalled] Occurs when a received message is recalled.
  ///
  /// Param [onConversationsUpdate] Occurs when a conversation is updated.
  ///
  /// Param [onMessageReactionDidChange] Occurs when the Reaction data changes.
  ///
  /// Param [onMessageContentChanged] Occurs when the message content is modified.
  ///
  /// Param [onMessagePinChanged] Occurs when the message pinning status changes.
  ///
  /// Param [onMessagesRecalledInfo] Occurs when a received message is recalled.
  /// ~end
  ///
  /// ~chinese
  /// 消息事件监听。
  ///
  /// Param [onMessagesReceived] 在收到文本、图片、视频、语音、地理位置和文件等消息时，通过此回调通知用户。
  ///
  /// Param [onStreamMessagesReceived] 收到流式消息回调。
  ///
  /// Param [onCmdMessagesReceived] 收到命令消息回调。
  ///
  /// Param [onMessageReadReceipts] 收到消息已读回执的回调。
  ///
  /// Param [onMessagesDelivered] 收到消息已送达回执的回调。
  ///
  /// Param [onMessagesRecalled] 已收到的消息被撤回的回调。
  ///
  /// Param [onConversationsUpdate] 会话更新事件回调。
  ///
  /// Param [onMessageReactionDidChange] 消息表情回复（Reaction）变化监听器。
  ///
  /// Param [onMessageContentChanged] 收到消息内容变化。
  ///
  /// Param [onMessagePinChanged] 消息置顶状态变化。
  ///
  /// Param [onMessagesRecalledInfo] 已收到的消息被撤回的回调。
  /// ~end
  ChatEventHandler({
    this.onMessagesReceived,
    this.onStreamMessagesReceived,
    this.onCmdMessagesReceived,
    this.onMessageReadReceipts,
    this.onMessagesDelivered,
    this.onMessagesRecalled,
    this.onConversationsUpdate,
    this.onMessageReactionDidChange,
    this.onMessageContentChanged,
    this.onMessagePinChanged,
    this.onMessagesRecalledInfo,
  });
}

/// ~english
/// The chat room event handler.
///
/// Adds a chat event handler:
/// ```dart
///   ChatClient.getInstance.chatRoomManager.addEventHandler(UNIQUE_HANDLER_ID, ChatRoomEventHandler());
/// ```
///
/// Removes a chat room event handler:
/// ```dart
///   ChatClient.getInstance.chatRoomManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
///
/// ~chinese
/// 聊天室事件监听。
///
/// 添加监听:
/// ```dart
///   ChatClient.getInstance.chatRoomManager.addEventHandler(UNIQUE_HANDLER_ID, ChatRoomEventHandler());
/// ```
///
/// Removes a chat room event handler:
/// ```dart
///   ChatClient.getInstance.chatRoomManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
class ChatRoomEventHandler {
  /// ~english
  /// Occurs when a member is changed to be an admin.
  /// ~end
  ///
  /// ~chinese
  /// 有成员设置为聊天室管理员的回调。
  /// ~end
  final void Function(String roomId, String admin)? onAdminAddedFromChatRoom;

  /// ~english
  /// Occurs when an admin is removed.
  /// ~end
  ///
  /// ~chinese
  /// 移除聊天室管理员权限的回调。
  /// ~end
  final void Function(String roomId, String admin)? onAdminRemovedFromChatRoom;

  /// ~english
  /// Occurs when all members in the chat room are muted or unmuted.
  /// ~end
  ///
  /// ~chinese
  /// 聊天室全员禁言状态变化回调。
  /// ~end
  final void Function(String roomId, bool isAllMuted)?
      onAllChatRoomMemberMuteStateChanged;

  /// ~english
  /// Occurs when the chat room member(s) is/are added to the allowlist.
  /// ~end
  ///
  /// ~chinese
  /// 有成员被加入聊天室白名单的回调。
  /// ~end
  final void Function(String roomId, List<String> members)?
      onAllowListAddedFromChatRoom;

  /// ~english
  /// Occurs when the chat room member(s) is/are removed from the allowlist.
  /// ~end
  ///
  /// ~chinese
  /// 有成员被移出聊天室白名单的回调。
  /// ~end
  final void Function(String roomId, List<String> members)?
      onAllowListRemovedFromChatRoom;

  /// ~english
  /// Occurs when the announcement changed.
  /// ~end
  ///
  /// ~chinese
  /// 聊天室公告更新回调。
  /// ~end
  final void Function(String roomId, String? announcement)?
      onAnnouncementChangedFromChatRoom;

  /// ~english
  /// Occurs when the chat room is destroyed.
  /// ~end
  ///
  /// ~chinese
  /// 聊天室解散的回调。
  /// ~end
  final void Function(String roomId, String? roomName)? onChatRoomDestroyed;

  /// ~english
  /// Occurs when a member leaves the chat room.
  /// ~end
  ///
  /// ~chinese
  /// 聊天室成员主动退出回调。
  /// ~end
  final void Function(String roomId, String? roomName, String participant)?
      onMemberExitedFromChatRoom;

  /// ~english
  /// Occurs when a user joins the chat room.
  /// ~end
  ///
  /// ~chinese
  /// 聊天室加入新成员回调。
  /// ~end
  final void Function(String roomId, String participant, String? ext)?
      onMemberJoinedFromChatRoom;

  /// ~english
  /// Occurs when a chat room member(s) is/are added to mute list.
  /// ~end
  ///
  /// ~chinese
  /// 有成员被禁言回调。
  /// ~end
  final void Function(String roomId, Map<String, int> mutes)?
      onMuteListAddedFromChatRoom;

  /// ~english
  /// Occurs when the a chat room member(s) is/are removed from mute list.
  /// ~end
  ///
  /// ~chinese
  /// 有成员从禁言列表中移除回调。
  /// ~end
  final void Function(String roomId, List<String> mutes)?
      onMuteListRemovedFromChatRoom;

  /// ~english
  /// Occurs when the chat room ownership is transferred.
  /// ~end
  ///
  /// ~chinese
  /// 转移聊天室的所有权的回调。
  /// ~end
  final void Function(String roomId, String newOwner, String oldOwner)?
      onOwnerChangedFromChatRoom;

  /// ~english
  /// Occurs when a user is removed from a chat room.
  /// ~end
  ///
  /// ~chinese
  /// 当前用户被移出聊天室回调。
  /// ~end
  final void Function(
    String roomId,
    String? roomName,
    String? participant,
    LeaveReason? reason,
  )? onRemovedFromChatRoom;

  /// ~english
  /// Occurs when the chat room specifications changes. All chat room members receive this event.
  /// ~end
  ///
  /// ~chinese
  /// 聊天室详情变更。
  /// ~end
  final void Function(ChatRoom room)? onSpecificationChanged;

  /// ~english
  /// Occurs when the custom chat room attributes (key-value) are updated.
  /// ~end
  ///
  /// ~chinese
  /// 聊天室属性变更。
  /// ~end
  final void Function(
    String roomId,
    Map<String, String> attributes,
    String from,
  )? onAttributesUpdated;

  /// ~english
  /// Occurs when the custom chat room attributes (key-value) are removed.
  /// ~end
  ///
  /// ~chinese
  /// 聊天室属性被删除。
  /// ~end
  final void Function(String roomId, List<String> removedKeys, String from)?
      onAttributesRemoved;

  /// ~english
  /// The chat room manager listener callback.
  ///
  /// Param [onAdminAddedFromChatRoom] A member is changed to be an admin.
  ///
  /// Param [onAdminRemovedFromChatRoom] An admin is been removed.
  ///
  /// Param [onAllChatRoomMemberMuteStateChanged] All members in the chat room are muted or unmuted.
  ///
  /// Param [onAllowListAddedFromChatRoom] The chat room member(s) is/are added to the allowlist.
  ///
  /// Param [onAllowListRemovedFromChatRoom] The chat room member(s) is/are removed from the allowlist.
  ///
  /// Param [onAnnouncementChangedFromChatRoom] The announcement is changed.
  ///
  /// Param [onChatRoomDestroyed] The chat room is destroyed.
  ///
  /// Param [onMemberExitedFromChatRoom] A member leaves the chat room.
  ///
  /// Param [onMemberJoinedFromChatRoom] A user joins the chat room.
  ///
  /// Param [onMuteListAddedFromChatRoom] The chat room member(s) is/are added to mute list.
  ///
  /// Param [onMuteListRemovedFromChatRoom] The chat room member(s) is/are removed from mute list.
  ///
  /// Param [onOwnerChangedFromChatRoom] The chat room ownership is transferred.
  ///
  /// Param [onRemovedFromChatRoom] The chat room member(s) is/are removed from the allowlist.
  ///
  /// Param [onSpecificationChanged] The chat room specification changed.
  ///
  /// Param [onAttributesUpdated] The chat room attribute(s) is/are updated.
  ///
  /// Param [onAttributesRemoved] The chat room attribute(s) is/are removed.
  /// ~end
  ///
  /// ~chinese
  /// 聊天室事件监听。
  ///
  /// Param [onAdminAddedFromChatRoom] 有成员设置为聊天室管理员的回调。
  ///
  /// Param [onAdminRemovedFromChatRoom] 移除聊天室管理员权限的回调。
  ///
  /// Param [onAllChatRoomMemberMuteStateChanged] 聊天室全员禁言状态变化回调。
  ///
  /// Param [onAllowListAddedFromChatRoom] 有成员被加入聊天室白名单的回调。
  ///
  /// Param [onAllowListRemovedFromChatRoom] 有成员被移出聊天室白名单的回调。
  ///
  /// Param [onAnnouncementChangedFromChatRoom] 聊天室公告更新回调。
  ///
  /// Param [onChatRoomDestroyed] 聊天室解散的回调。
  ///
  /// Param [onMemberExitedFromChatRoom] 聊天室成员主动退出回调。
  ///
  /// Param [onMemberJoinedFromChatRoom] 聊天室加入新成员回调。
  ///
  /// Param [onMuteListAddedFromChatRoom] 有成员被禁言回调。
  ///
  /// Param [onMuteListRemovedFromChatRoom] 有成员从禁言列表中移除回调。
  ///
  /// Param [onOwnerChangedFromChatRoom] 转移聊天室的所有权的回调。
  ///
  /// Param [onRemovedFromChatRoom] 聊天室成员被移出聊天室回调。
  ///
  /// Param [onSpecificationChanged] 聊天室详情变更。
  ///
  /// Param [onAttributesUpdated] 聊天室属性变更。
  ///
  /// Param [onAttributesRemoved] 聊天室属性被删除。
  /// ~end
  ChatRoomEventHandler({
    this.onAdminAddedFromChatRoom,
    this.onAdminRemovedFromChatRoom,
    this.onAllChatRoomMemberMuteStateChanged,
    this.onAllowListAddedFromChatRoom,
    this.onAllowListRemovedFromChatRoom,
    this.onAnnouncementChangedFromChatRoom,
    this.onChatRoomDestroyed,
    this.onMemberExitedFromChatRoom,
    this.onMemberJoinedFromChatRoom,
    this.onMuteListAddedFromChatRoom,
    this.onMuteListRemovedFromChatRoom,
    this.onOwnerChangedFromChatRoom,
    this.onRemovedFromChatRoom,
    this.onSpecificationChanged,
    this.onAttributesUpdated,
    this.onAttributesRemoved,
  });
}

/// ~english
/// The message thread event handler, which handles message thread events such as creating or leaving a message thread.
///
/// Adds a message thread event handler:
/// ```dart
///   ChatClient.getInstance.chatThreadManager.addEventHandler(UNIQUE_HANDLER_ID, ChatThreadEventHandler());
/// ```
///
/// Removes a chat event handler:
/// ```dart
/// ChatClient.getInstance.chatThreadManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
///
/// ~chinese
/// Thread 事件监听
///
/// 添加监听:
/// ```dart
///   ChatClient.getInstance.chatThreadManager.addEventHandler(UNIQUE_HANDLER_ID, ChatThreadEventHandler());
/// ```
///
/// 移除监听:
/// ```dart
/// ChatClient.getInstance.chatThreadManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
class ChatThreadEventHandler {
  /// ~english
  /// Occurs when a message thread is created.
  ///
  /// Each member of the group to which the message thread belongs can receive the callback.
  /// ~end
  ///
  /// ~chinese
  /// 子区创建回调。
  /// ~end
  final void Function(ChatThreadEvent event)? onChatThreadCreate;

  /// ~english
  /// Occurs when a message thread is destroyed.
  ///
  /// Each member of the group to which the message thread belongs can receive the callback.
  /// ~end
  ///
  /// ~chinese
  /// 子区解散事件。
  /// 子区所属群组的所有成员均可调用该方法。
  /// ~end
  final void Function(ChatThreadEvent event)? onChatThreadDestroy;

  /// ~english
  /// Occurs when a message thread is updated.
  ///
  /// This callback is triggered when the message thread name is changed or a threaded reply is added or recalled.
  ///
  /// Each member of the group to which the message thread belongs can receive the callback.
  /// ~end
  ///
  /// ~chinese
  /// 子区更新回调。
  /// 子区所属群组的所有成员均可调用该方法。
  /// ~end
  final void Function(ChatThreadEvent event)? onChatThreadUpdate;

  /// ~english
  /// Occurs when the current user is removed from the message thread by the group owner or a group admin to which the message thread belongs.
  /// ~end
  ///
  /// ~chinese
  /// 管理员移除子区用户的回调。
  /// ~end
  final void Function(ChatThreadEvent event)? onUserKickOutOfChatThread;

  /// ~english
  /// The message thread listener callback.
  ///
  /// Param [onChatThreadCreate] A message thread is created. All members in the group to which the thread belongs receive this callback.
  ///
  /// Param [onChatThreadDestroy] A message thread is destroyed. All members in the group to which the destroyed thread belongs receive this callback.
  ///
  /// Param [onChatThreadUpdate] A message thread is updated. All members in the group to which the updated thread belongs receive this callback.
  ///
  /// Param [onUserKickOutOfChatThread]  The current user is removed from the message thread by the group owner or a group admin to which the message thread belongs. The current user removed from the thread receives the callback.
  /// ~end
  ///
  /// ~chinese
  /// Thread 事件监听。
  ///
  /// Param [onChatThreadCreate] 子区创建回调。
  ///
  /// Param [onChatThreadDestroy] 子区解散事件, 子区所属群组的所有成员均可调用该方法。
  ///
  /// Param [onChatThreadUpdate] 子区更新回调, 子区所属群组的所有成员均可调用该方法。
  ///
  /// Param [onUserKickOutOfChatThread] 管理员移除子区用户的回调。
  /// ~end
  ChatThreadEventHandler({
    this.onChatThreadCreate,
    this.onChatThreadDestroy,
    this.onChatThreadUpdate,
    this.onUserKickOutOfChatThread,
  });
}

/// ~english
/// The contact event handler.
///
/// Occurs when the contact changes, including adding or deleting contacts and accept or rejecting friend requests.
///
/// Adds a contact event handler:
/// ```dart
///   ChatClient.getInstance.contactManager.addEventHandler(UNIQUE_HANDLER_ID, ChatContactEventHandler());
/// ```
///
/// Removes a contact event handler:
/// ```dart
///   ChatClient.getInstance.contactManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
///
/// ~chinese
/// 联系人事件监听
///
/// 添加监听:
/// ```dart
///   ChatClient.getInstance.contactManager.addEventHandler(UNIQUE_HANDLER_ID, ChatContactEventHandler());
/// ```
///
/// 移除监听:
/// ```dart
///   ChatClient.getInstance.contactManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
class ChatContactEventHandler {
  /// ~english
  /// Occurs when user is added as a contact by another user.
  /// ~end
  ///
  /// ~chinese
  /// 添加好友回调。
  /// ~end
  final void Function(String userId)? onContactAdded;

  /// ~english
  /// Occurs when a user is removed from the contact list by another user.
  /// ~end
  ///
  /// ~chinese
  /// 删除好友回调。
  /// ~end
  final void Function(String userId)? onContactDeleted;

  /// ~english
  /// Occurs when a user receives a friend request.
  /// ~end
  ///
  /// ~chinese
  /// 好友申请回调。
  /// ~end
  final void Function(String userId, String? reason)? onContactInvited;

  /// ~english
  /// Occurs when a friend request is approved.
  /// ~end
  ///
  /// ~chinese
  /// 发出的好友申请被对方同意。
  /// ~end
  final void Function(String userId)? onFriendRequestAccepted;

  /// ~english
  /// Occurs when a friend request is declined.
  /// ~end
  ///
  /// ~chinese
  /// 发出的好友申请被对方拒绝。
  /// ~end
  final void Function(String userId)? onFriendRequestDeclined;

  /// ~english
  /// Occurs when the information of a contact is updated.
  ///
  /// Param [contact] The updated contact.
  /// ~end
  ///
  /// ~chinese
  /// 联系人信息更新时触发的回调。
  ///
  /// Param [contact] 更新后的联系人。
  /// ~end
  final void Function(ChatContact contact)? onContactInfoUpdate;

  /// ~english
  /// The contact updates listener callback.
  ///
  /// Param [onContactAdded] Current user is added as a contact by another user.
  ///
  /// Param [onContactDeleted] Current user is removed from the contact list by another user.
  ///
  /// Param [onContactInvited] Current user receives a friend request.
  ///
  /// Param [onFriendRequestAccepted] A friend request is approved.
  ///
  /// Param [onFriendRequestDeclined] A friend request is declined.
  ///
  /// Param [onContactInfoUpdate] The information of a contact is updated.
  /// ~end
  ///
  /// ~chinese
  /// 联系人事件监听。
  ///
  /// Param [onContactAdded] 添加好友回调。
  ///
  /// Param [onContactDeleted] 删除好友回调。
  ///
  /// Param [onContactInvited] 好友申请回调。
  ///
  /// Param [onFriendRequestAccepted] 发出的好友申请被对方同意。
  ///
  /// Param [onFriendRequestDeclined] 发出的好友申请被对方拒绝。
  ///
  /// Param [onContactInfoUpdate] 联系人信息更新回调。
  /// ~end
  ChatContactEventHandler({
    this.onContactAdded,
    this.onContactDeleted,
    this.onContactInvited,
    this.onFriendRequestAccepted,
    this.onFriendRequestDeclined,
    this.onContactInfoUpdate,
  });
}

/// ~english
/// The group event handler.
///
/// Occurs when the following group events happens: joining a group, approving or declining a group request, and kicking a user out of a group.
///
/// Adds a group event handler:
/// ```dart
///   ChatClient.getInstance.groupManager.addEventHandler(UNIQUE_HANDLER_ID, ChatGroupEventHandler());
/// ```
///
/// Removes a group event handler:
/// ```dart
///   ChatClient.getInstance.groupManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
///
/// ~chinese
/// 群组事件监听
///
/// 添加监听:
/// ```dart
///   ChatClient.getInstance.groupManager.addEventHandler(UNIQUE_HANDLER_ID, ChatGroupEventHandler());
/// ```
///
/// 移除监听:
/// ```dart
///   ChatClient.getInstance.groupManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
class ChatGroupEventHandler {
  /// ~english
  /// Occurs when a member is set as an admin.
  /// ~end
  ///
  /// ~chinese
  /// 成员设置为管理员的回调。
  /// ~end
  final void Function(String groupId, String admin)? onAdminAddedFromGroup;

  /// ~english
  /// Occurs when a member's admin privileges are removed.
  /// ~end
  ///
  /// ~chinese
  /// 取消成员的管理员权限的回调。
  /// ~end
  final void Function(String groupId, String admin)? onAdminRemovedFromGroup;

  /// ~english
  /// Occurs when all group members are muted or unmuted.
  /// ~end
  ///
  /// ~chinese
  /// 全员禁言状态变化回调。
  /// ~end
  final void Function(String groupId, bool isAllMuted)?
      onAllGroupMemberMuteStateChanged;

  /// ~english
  /// Occurs when one or more group members are added to the allowlist.
  /// ~end
  ///
  /// ~chinese
  /// 成员加入群组白名单回调。
  /// ~end
  final void Function(String groupId, List<String> members)?
      onAllowListAddedFromGroup;

  /// ~english
  /// Occurs when one or more members are removed from the allowlist.
  /// ~end
  ///
  /// ~chinese
  /// 成员移出群组白名单回调。
  /// ~end
  final void Function(String groupId, List<String> members)?
      onAllowListRemovedFromGroup;

  /// ~english
  /// Occurs when the announcement is updated.
  /// ~end
  ///
  /// ~chinese
  /// 群公告更新回调。
  /// ~end
  final void Function(String groupId, String? announcement)?
      onAnnouncementChangedFromGroup;

  /// ~english
  /// Occurs when the group invitation is accepted automatically.
  /// For settings, See [ChatOptions.autoAcceptGroupInvitation].
  /// The SDK will join the group before notifying the app of the acceptance of the group invitation.
  /// ~end
  ///
  /// ~chinese
  /// 当前用户自动同意入群邀请的回调。
  /// 设置请见 [ChatOptions.autoAcceptGroupInvitation].
  /// ~end
  final void Function(String groupId, String inviter, String? inviteMessage)?
      onAutoAcceptInvitationFromGroup;

  /// ~english
  /// Occurs when a group is destroyed.
  /// ~end
  ///
  /// ~chinese
  /// 当前用户收到群组被解散的回调。
  /// ~end
  final void Function(String groupId, String? groupName)? onGroupDestroyed;

  /// ~english
  /// Occurs when a group invitation is accepted.
  /// ~end
  ///
  /// ~chinese
  /// 当前用户收到对端用户同意入群邀请触发的回调。
  /// ~end
  final void Function(String groupId, String invitee, String? reason)?
      onInvitationAcceptedFromGroup;

  /// ~english
  /// Occurs when a group invitation is declined.
  /// ~end
  ///
  /// ~chinese
  /// 当前用户收到群组邀请被拒绝的回调。
  /// 该回调是由当前用户收到对端用户拒绝入群邀请触发的。例如，用户 B 拒绝了用户 A 的群组邀请，用户 A 会收到该回调。
  /// ~end
  final void Function(String groupId, String invitee, String? reason)?
      onInvitationDeclinedFromGroup;

  /// ~english
  /// Occurs when the user receives a group invitation.
  /// ~end
  ///
  /// ~chinese
  /// 当前用户收到入群邀请的回调。
  /// ~end
  final void Function(
    String groupId,
    String? groupName,
    String inviter,
    String? reason,
  )? onInvitationReceivedFromGroup;

  /// ~english
  /// Occurs when a member proactively leaves the group.
  /// ~end
  ///
  /// ~chinese
  /// 群组成员主动退出回调。
  /// ~end
  final void Function(String groupId, String member)? onMemberExitedFromGroup;

  /// ~english
  /// Occurs when a user joins a group.
  /// ~end
  ///
  /// ~chinese
  /// 新成员加入群组的回调。
  /// ~end
  final void Function(String groupId, String member)? onMemberJoinedFromGroup;

  /// ~english
  /// Occurs when one or more group members are muted.
  ///
  /// Note: The mute function is different from a block list.
  /// A user, when muted, can still see group messages, but cannot send messages in the group.
  /// However, a user on the block list can neither see nor send group messages.
  /// ~end
  ///
  /// ~chinese
  /// 有成员被禁言回调。
  /// 用户禁言后，将无法在群中发送消息，但可查看群组中的消息，而黑名单中的用户无法查看和发送群组消息。
  /// ~end
  final void Function(String groupId, List<String> mutes, int? muteExpire)?
      onMuteListAddedFromGroup;

  /// ~english
  /// Occurs when one or more group members are unmuted.
  /// ~end
  ///
  /// ~chinese
  /// 有成员被解除禁言的回调。
  /// ~end
  final void Function(String groupId, List<String> mutes)?
      onMuteListRemovedFromGroup;

  /// ~english
  /// Occurs when the group ownership is transferred.
  /// ~end
  ///
  /// ~chinese
  /// 转移群主权限的回调。
  /// ~end
  final void Function(String groupId, String newOwner, String oldOwner)?
      onOwnerChangedFromGroup;

  /// ~english
  /// Occurs when a group request is accepted.
  /// ~end
  ///
  /// ~chinese
  /// 对端用户接受当前用户发送的群组申请的回调。
  /// ~end
  final void Function(String groupId, String? groupName, String accepter)?
      onRequestToJoinAcceptedFromGroup;

  /// ~english
  /// Occurs when a group request is declined.
  /// ~end
  ///
  /// ~chinese
  /// 对端用户拒绝群组申请的回调。
  /// ~end
  final void Function(
    String groupId,
    String? groupName,
    String? decliner,
    String? reason,
    String? applicant,
  )? onRequestToJoinDeclinedFromGroup;

  /// ~english
  /// Occurs when the group owner or administrator receives a group request from a user.
  /// ~end
  ///
  /// ~chinese
  /// 对端用户接收群组申请的回调。
  /// ~end
  final void Function(
    String groupId,
    String? groupName,
    String applicant,
    String? reason,
  )? onRequestToJoinReceivedFromGroup;

  /// ~english
  /// Occurs when a shared file is added to a group.
  /// ~end
  ///
  /// ~chinese
  /// 群组添加共享文件回调。
  /// ~end
  final void Function(String groupId, ChatGroupSharedFile sharedFile)?
      onSharedFileAddedFromGroup;

  /// ~english
  /// Occurs when the group detail information is updated.
  /// ~end
  ///
  /// ~chinese
  /// 群详情变更回调。
  /// ~end
  final void Function(ChatGroup group)? onSpecificationDidUpdate;

  /// ~english
  /// Occurs when the group is enabled or disabled.
  /// ~end
  ///
  /// ~chinese
  /// 群是禁用状态变更。
  /// ~end
  final void Function(String groupId, bool isDisable)? onDisableChanged;

  /// ~english
  /// Occurs when a shared file is removed from a group.
  /// ~end
  ///
  /// ~chinese
  /// 群组删除共享文件回调。
  /// ~end
  final void Function(String groupId, String fileId)?
      onSharedFileDeletedFromGroup;

  /// ~english
  /// Occurs when the current user is removed from the group by the group admin.
  /// ~end
  ///
  /// ~chinese
  /// 当前用户被移出群组时的回调。
  /// ~end
  final void Function(String groupId, String? groupName)?
      onUserRemovedFromGroup;

  /// ~english
  /// Occurs when a custom attribute(s) of a group member is/are changed.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [userId] The user ID of the group member whose custom attributes are changed.
  ///
  /// Param [attributes] The modified custom attributes, in key-value format.
  ///
  /// Param [operatorId] The user ID of the operator.
  ///
  /// ~end
  ///
  /// ~chinese
  /// 群组成员自定义属性有变更。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [userId] 自定义属性变更的群成员的用户 ID。
  ///
  /// Param [attributes] 修改后的自定义属性，key-value 格式。
  ///
  /// Param [operatorId] 操作者的用户 ID。
  /// ~end
  final void Function(
    String groupId,
    String userId,
    Map<String, String>? attributes,
    String? operatorId,
  )? onAttributesChangedOfGroupMember;

  /// ~english
  ///
  /// Occurs when members join the group.
  /// ~end
  ///
  /// ~chinese
  /// 成员加入群组的回调。
  /// ~end
  final void Function(String groupId, List<String> userIds)?
      onMembersJoinedFromGroup;

  /// ~english
  /// Occurs when members leave the group.
  /// ~end
  ///
  /// ~chinese
  /// 成员离开群组的回调。
  /// ~end
  final void Function(String groupId, List<String> userIds)?
      onMembersExitedFromGroup;

  /// ~english
  /// Occurs when the group namecard of a user is changed.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [userId] The user ID of the group member whose namecard is changed.
  ///
  /// Param [namecard] The new group namecard, `null` if the namecard is removed.
  /// ~end
  ///
  /// ~chinese
  /// 用户的群名片变更回调。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [userId] 群名片变更的群成员的用户 ID。
  ///
  /// Param [namecard] 新的群名片，名片被移除时为 `null`。
  /// ~end
  final void Function(String groupId, String userId, String? namecard)?
      onUserGroupNamecardChanged;

  /// ~english
  /// The group manager listener callback.
  ///
  /// Param [onAdminAddedFromGroup] A member is set as an admin.
  ///
  /// Param [onAdminRemovedFromGroup] A member's admin privileges are removed.
  ///
  /// Param [onAllGroupMemberMuteStateChanged] All group members are muted or unmuted.
  ///
  /// Param [onAllowListAddedFromGroup] One or more group members are muted.
  ///
  /// Param [onAllowListRemovedFromGroup] One or more group members are unmuted.
  ///
  /// Param [onAnnouncementChangedFromGroup] The announcement is updated.
  ///
  /// Param [onAutoAcceptInvitationFromGroup] The group invitation is accepted automatically.
  ///
  /// Param [onGroupDestroyed] A group is destroyed.
  ///
  /// Param [onInvitationAcceptedFromGroup] A group invitation is accepted.
  ///
  /// Param [onInvitationDeclinedFromGroup] A group invitation is declined.
  ///
  /// Param [onInvitationReceivedFromGroup] The user receives a group invitation.
  ///
  /// Param [onMemberExitedFromGroup] A member proactively leaves the group.
  ///
  /// Param [onMemberJoinedFromGroup] A user joins a group.
  ///
  /// Param [onMuteListAddedFromGroup] One or more group members are muted.
  ///
  /// Param [onMuteListRemovedFromGroup] One or more group members are unmuted.
  ///
  /// Param [onOwnerChangedFromGroup] The group ownership is transferred.
  ///
  /// Param [onRequestToJoinAcceptedFromGroup] A group request is accepted.
  ///
  /// Param [onRequestToJoinDeclinedFromGroup] A group request is declined.
  ///
  /// Param [onRequestToJoinReceivedFromGroup] The group owner or administrator receives a group request from a user.
  ///
  /// Param [onSharedFileAddedFromGroup] A shared file is added to a group.
  ///
  /// Param [onSharedFileDeletedFromGroup] A shared file is removed from a group.
  ///
  /// Param [onUserRemovedFromGroup] Current user is removed from the group by the group admin.
  ///
  /// Param [onSpecificationDidUpdate] The group detail information is updated.
  ///
  /// Param [onDisableChanged] Te group is enabled or disabled.
  ///
  /// Param [onAttributesChangedOfGroupMember] A custom attribute(s) of a group member is/are changed.
  ///
  /// Param [onMembersJoinedFromGroup] members joins ths group.
  ///
  /// Param [onMembersExitedFromGroup] members leaves the group.
  ///
  /// Param [onUserGroupNamecardChanged] The group namecard of a user is changed.
  ///
  /// ~end
  ///
  /// ~chinese
  /// 群组时间监听
  ///
  /// Param [onAdminAddedFromGroup] 成员设置为管理员的回调。
  ///
  /// Param [onAdminRemovedFromGroup] 取消成员的管理员权限的回调。
  ///
  /// Param [onAllGroupMemberMuteStateChanged] 全员禁言状态变化回调。
  ///
  /// Param [onAllowListAddedFromGroup] 成员加入群组白名单回调。
  ///
  /// Param [onAllowListRemovedFromGroup] 成员移出群组白名单回调。
  ///
  /// Param [onAnnouncementChangedFromGroup] 群公告更新回调。
  ///
  /// Param [onAutoAcceptInvitationFromGroup] 当前用户自动同意入群邀请的回调, 设置请见 [ChatOptions.autoAcceptGroupInvitation]。
  ///
  /// Param [onGroupDestroyed] 当前用户收到群组被解散的回调。
  ///
  /// Param [onInvitationAcceptedFromGroup] 当前用户收到对端用户同意入群邀请触发的回调。
  ///
  /// Param [onInvitationDeclinedFromGroup] 当前用户收到群组邀请被拒绝的回调。
  ///
  /// Param [onInvitationReceivedFromGroup] 当前用户收到入群邀请的回调。
  ///
  /// Param [onMemberExitedFromGroup] 群组成员主动退出回调。
  ///
  /// Param [onMemberJoinedFromGroup] 新成员加入群组的回调。
  ///
  /// Param [onMuteListAddedFromGroup] 有成员被禁言回调, 用户禁言后，将无法在群中发送消息，但可查看群组中的消息，而黑名单中的用户无法查看和发送群组消息。
  ///
  /// Param [onMuteListRemovedFromGroup] 有成员被解除禁言的回调。
  ///
  /// Param [onOwnerChangedFromGroup] 转移群主权限的回调。
  ///
  /// Param [onRequestToJoinAcceptedFromGroup] 对端用户接受当前用户发送的群组申请的回调。
  ///
  /// Param [onRequestToJoinDeclinedFromGroup] 对端用户拒绝群组申请的回调。
  ///
  /// Param [onRequestToJoinReceivedFromGroup] 对端用户接收群组申请的回调。
  ///
  /// Param [onSharedFileAddedFromGroup] 群组添加共享文件回调。
  ///
  /// Param [onSharedFileDeletedFromGroup] 群组删除共享文件回调。
  ///
  /// Param [onUserRemovedFromGroup] 当前用户被移出群组时的回调。
  ///
  /// Param [onSpecificationDidUpdate] 群详情变更回调。
  ///
  /// Param [onDisableChanged] 群是禁用状态变更。
  ///
  /// Param [onAttributesChangedOfGroupMember] 群组成员自定义属性有变更。
  ///
  /// Param [onMembersJoinedFromGroup] 成员加入群组。
  ///
  /// Param [onMembersExitedFromGroup] 成员离开群组。
  ///
  /// Param [onUserGroupNamecardChanged] 用户的群名片变更回调。
  /// ~end
  ChatGroupEventHandler({
    this.onAdminAddedFromGroup,
    this.onAdminRemovedFromGroup,
    this.onAllGroupMemberMuteStateChanged,
    this.onAllowListAddedFromGroup,
    this.onAllowListRemovedFromGroup,
    this.onAnnouncementChangedFromGroup,
    this.onAutoAcceptInvitationFromGroup,
    this.onGroupDestroyed,
    this.onInvitationAcceptedFromGroup,
    this.onInvitationDeclinedFromGroup,
    this.onInvitationReceivedFromGroup,
    @Deprecated('Use onMemberExitedFromGroup instead')
    this.onMemberExitedFromGroup,
    @Deprecated('Use onMembersJoinedFromGroup instead')
    this.onMemberJoinedFromGroup,
    this.onMuteListAddedFromGroup,
    this.onMuteListRemovedFromGroup,
    this.onOwnerChangedFromGroup,
    this.onRequestToJoinAcceptedFromGroup,
    this.onRequestToJoinDeclinedFromGroup,
    this.onRequestToJoinReceivedFromGroup,
    this.onSharedFileAddedFromGroup,
    this.onSharedFileDeletedFromGroup,
    this.onUserRemovedFromGroup,
    this.onSpecificationDidUpdate,
    this.onDisableChanged,
    this.onAttributesChangedOfGroupMember,
    this.onMembersJoinedFromGroup,
    this.onMembersExitedFromGroup,
    this.onUserGroupNamecardChanged,
  });
}

/// ~english
/// The presence event handler.
///
/// Occurs when the following presence events happens: presence status changed.
///
/// Adds a presence event handler:
/// ```dart
///   ChatClient.getInstance.presenceManager.addEventHandler(UNIQUE_HANDLER_ID, ChatPresenceEventHandler());
/// ```
///
/// Removes a presence event handler:
/// ```dart
///   ChatClient.getInstance.presenceManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
///
/// ~chinese
/// 订阅用户状态变更监听
///
/// 添加监听:
/// ```dart
///   ChatClient.getInstance.presenceManager.addEventHandler(UNIQUE_HANDLER_ID, ChatPresenceEventHandler());
/// ```
///
/// 移除监听:
/// ```dart
///   ChatClient.getInstance.presenceManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
class ChatPresenceEventHandler {
  /// ~english
  /// Occurs when the presence state of a subscribed user changes.
  /// ~end
  ///
  /// ~chinese
  /// 收到被订阅用户的在线状态发生变化。
  /// ~end
  final Function(List<ChatPresence> list)? onPresenceStatusChanged;

  /// ~english
  /// The presence manager listener callback.
  ///
  /// Param [onPresenceStatusChanged] The presence state of a subscribed user changes.
  /// ~end
  ///
  /// ~chinese
  /// 订阅用户状态变更监听。
  /// ~end
  ChatPresenceEventHandler({this.onPresenceStatusChanged});
}

/// ~english
/// The message status event class.
/// During message delivery, the message ID will be changed from a local uuid to a global unique ID that is generated by the server to uniquely identify a message on all devices using the SDK.
/// This API should be implemented in the chat page widget to listen for message status changes.
/// ~end
///
/// ~chinese
/// 消息状态事件类。
/// ~end
class ChatMessageEvent {
  ChatMessageEvent({this.onSuccess, this.onError, this.onProgress});

  /// ~english
  /// Occurs when a message is successfully sent or downloaded.
  ///
  /// Param [msgId] The pre-sending message ID or the ID of the message that is successfully downloaded.
  ///
  /// Param [msg] The message that is successfully sent or downloaded.
  /// ~end
  ///
  /// ~chinese
  /// 消息发送或下载成功回调。
  /// ~end
  final void Function(String msgId, ChatMessage msg)? onSuccess;

  /// ~english
  /// Occurs when a message fails to be sent or downloaded.
  ///
  /// Param [msgId] The pre-sending message ID or the ID of the message that fails to be downloaded.
  ///
  /// Param [msg] The message that fails to be sent or downloaded.
  /// ~end
  ///
  /// ~chinese
  /// 消息发送或下载失败回调。
  ///
  /// Param [msgId] 发送前或下载失败的消息 ID。
  ///
  /// Param [msg] 发送或下载失败的消息。
  /// ~end
  final void Function(String msgId, ChatMessage msg, ChatError error)? onError;

  /// ~english
  /// Occurs when there is a progress for message upload or download. This event is triggered when a message is being uploaded or downloaded.
  ///
  /// Param [msgId] The ID of the message that is being uploaded or downloaded.
  ///
  /// Param [progress] The upload or download progress.
  /// ~end
  ///
  /// ~chinese
  /// 消息上传或下载进度的回调。
  ///
  /// Param [msgId] 正在上传或下载的消息的 ID。
  ///
  /// Param [progress] 上传或下载进度。
  /// ~end
  final void Function(String msgId, int progress)? onProgress;
}

/// ~english
/// The user info event handler.
///
/// Occurs when the user attributes of the current user or subscribed users are updated.
///
/// Adds a user info event handler:
/// ```dart
///   ChatClient.getInstance.userInfoManager.addEventHandler(UNIQUE_HANDLER_ID, ChatUserInfoEventHandler());
/// ```
///
/// Removes a user info event handler:
/// ```dart
///   ChatClient.getInstance.userInfoManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
///
/// ~chinese
/// 用户属性事件监听。
///
/// 当前用户或被订阅用户的用户属性更新时触发。
///
/// 添加监听:
/// ```dart
///   ChatClient.getInstance.userInfoManager.addEventHandler(UNIQUE_HANDLER_ID, ChatUserInfoEventHandler());
/// ```
///
/// 移除监听:
/// ```dart
///   ChatClient.getInstance.userInfoManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
class ChatUserInfoEventHandler {
  /// ~english
  /// Occurs when the user attributes of the current user are updated.
  ///
  /// Param [userInfo] The updated user attributes of the current user.
  /// ~end
  ///
  /// ~chinese
  /// 当前用户的用户属性更新回调。
  ///
  /// Param [userInfo] 更新后的当前用户的用户属性。
  /// ~end
  final void Function(ChatUserInfo userInfo)? onSelfUserInfoUpdate;

  /// ~english
  /// Occurs when the user attributes of subscribed users are updated.
  ///
  /// Param [userInfos] The updated user attributes of subscribed users.
  /// ~end
  ///
  /// ~chinese
  /// 被订阅用户的用户属性更新回调。
  ///
  /// Param [userInfos] 更新后的被订阅用户的用户属性列表。
  /// ~end
  final void Function(List<ChatUserInfo> userInfos)? onUserInfoUpdate;

  /// ~english
  /// The user info event handler.
  ///
  /// Param [onSelfUserInfoUpdate] The user attributes of the current user are updated.
  ///
  /// Param [onUserInfoUpdate] The user attributes of subscribed users are updated.
  /// ~end
  ///
  /// ~chinese
  /// 用户属性事件监听。
  ///
  /// Param [onSelfUserInfoUpdate] 当前用户的用户属性更新回调。
  ///
  /// Param [onUserInfoUpdate] 被订阅用户的用户属性更新回调。
  /// ~end
  ChatUserInfoEventHandler({this.onSelfUserInfoUpdate, this.onUserInfoUpdate});
}
