import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

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
///   EMClient.getInstance.addConnectionEventHandler(UNIQUE_HANDLER_ID, EMConnectionEventHandler());
/// ```
///
/// Remove a connection event handler:
/// ```dart
///   EMClient.getInstance.removeConnectionEventHandler(UNIQUE_HANDLER_ID);
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
///   EMClient.getInstance.addConnectionEventHandler(UNIQUE_HANDLER_ID, EMConnectionEventHandler());
/// ```
///
/// 移除 connection event handler:
/// ```dart
///   EMClient.getInstance.removeConnectionEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
class EMConnectionEventHandler {
  /// ~english
  /// Occurs when the SDK connects to the chat server successfully.
  /// ~end
  ///
  /// ~chinese
  /// 成功连接到 chat 服务器时触发的回调。
  /// ~end
  final VoidCallback? onConnected;

  /// ~english
  /// Occurs when the SDK disconnect from the chat server.
  ///
  /// Note that the logout may not be performed at the bottom level when the SDK is disconnected.
  /// ~end
  ///
  /// ~chinese
  /// 与 chat 服务器断开连接时触发的回调。
  /// ~end
  final VoidCallback? onDisconnected;

  /// ~english
  /// Occurs when the current user account is logged in to another device.
  /// ~end
  ///
  /// ~chinese
  /// 其他设备登录回调。
  /// ~end
  final VoidCallback? onUserDidLoginFromOtherDevice;

  /// ~english
  /// Occurs when the current chat user is removed from the server.
  /// ~end
  ///
  /// ~chinese
  /// 被服务器移除回调。
  /// ~end
  final VoidCallback? onUserDidRemoveFromServer;

  /// ~english
  /// Occurs when the current chat user is forbid from the server.
  /// ~end
  ///
  /// ~chinese
  /// 被服务器禁止连接回调。
  /// ~end
  final VoidCallback? onUserDidForbidByServer;

  /// ~english
  /// Occurs when the current chat user is changed password.
  /// ~end
  ///
  /// ~chinese
  /// 用户密码变更回调。
  /// ~end
  final VoidCallback? onUserDidChangePassword;

  /// ~english
  /// Occurs when the current chat user logged to many devices.
  /// ~end
  ///
  /// ~chinese
  /// 登录设备过多回调。
  /// ~end
  final VoidCallback? onUserDidLoginTooManyDevice;

  /// ~english
  /// Occurs when the current chat user kicked by other device.
  /// ~end
  ///
  /// ~chinese
  /// 被其他设备踢掉回调。
  /// ~end
  final VoidCallback? onUserKickedByOtherDevice;

  /// ~english
  /// Occurs when the current chat user authentication failed.
  /// ~end
  ///
  /// ~chinese
  /// 鉴权失败回调。
  /// ~end
  final VoidCallback? onUserAuthenticationFailed;

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
  /// ~end
  ///
  /// ~chinese
  /// Agora token 已过期时触发。
  /// ~end
  final VoidCallback? onTokenDidExpire;

  /// ~english
  /// The chat connection listener callback.
  ///
  /// Param [onConnected] The SDK connects to the chat server successfully callback.
  ///
  /// Param [onDisconnected] The SDK disconnect from the chat server callback.
  ///
  /// Param [onUserDidLoginFromOtherDevice] Current user account is logged in to another device callback.
  ///
  /// Param [onUserDidRemoveFromServer] Current chat user is removed from the server callback.
  ///
  /// Param [onUserDidForbidByServer] Current chat user is forbid from the server callback.
  ///
  /// Param [onUserDidChangePassword] Current chat user is changed password callback.
  ///
  /// Param [onUserDidLoginTooManyDevice] Current chat user logged to many devices callback.
  ///
  /// Param [onUserKickedByOtherDevice] Current chat user kicked by other device callback.
  ///
  /// Param [onUserAuthenticationFailed] Current chat user authentication failed callback.
  ///
  /// Param [onTokenWillExpire] The token is about to expire callback.
  ///
  /// Param [onTokenDidExpire] The token has expired callback.
  /// ~end
  ///
  /// ~chinese
  /// 连接状态监听。
  ///
  /// Param [onConnected] 成功连接到 chat 服务器时触发的回调。
  ///
  /// Param [onDisconnected] 和 chat 服务器断开连接时触发的回调。
  ///
  /// Param [onUserDidLoginFromOtherDevice] 其他设备登录回调。
  ///
  /// Param [onUserDidRemoveFromServer] 被服务器移除回调。
  ///
  /// Param [onUserDidForbidByServer] 被服务器禁止连接回调。
  ///
  /// Param [onUserDidChangePassword] 用户密码变更回调。
  ///
  /// Param [onUserDidLoginTooManyDevice] 登录设备过多回调。
  ///
  /// Param [onUserKickedByOtherDevice] 被其他设备踢掉回调。
  ///
  /// Param [onUserAuthenticationFailed] 鉴权失败回调。
  ///
  /// Param [onTokenWillExpire] Agora token 即将过期时回调。
  ///
  /// Param [onTokenDidExpire] Agora token 已过期时回调。
  /// ~end
  EMConnectionEventHandler({
    this.onConnected,
    this.onDisconnected,
    this.onUserDidLoginFromOtherDevice,
    this.onUserDidRemoveFromServer,
    this.onUserDidForbidByServer,
    this.onUserDidChangePassword,
    this.onUserDidLoginTooManyDevice,
    this.onUserKickedByOtherDevice,
    this.onUserAuthenticationFailed,
    this.onTokenWillExpire,
    this.onTokenDidExpire,
  });
}

/// ~english
/// The multi-device event handler.
/// Listens for callback for the current user's actions on other devices, including contact changes and group changes.
///
/// Adds multi-device event handler:
/// ```dart
///   EMClient.getInstance.addMultiDeviceEventHandler((UNIQUE_HANDLER_ID, EMMultiDeviceEventHandler());
/// ```
///
/// Remove a multi-device event handler:
/// ```dart
///   EMClient.getInstance.removeMultiDeviceEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
///
/// ~chinese
/// 多设备事件监听
/// 监听当前用户在其他设备上的操作的回调，包括联系人更改和组，thread等更改。
///
/// 添加监听:
/// ```dart
///   EMClient.getInstance.addMultiDeviceEventHandler((UNIQUE_HANDLER_ID, EMMultiDeviceEventHandler());
/// ```
///
/// 移除监听:
/// ```dart
///   EMClient.getInstance.removeMultiDeviceEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
class EMMultiDeviceEventHandler {
  /// ~english
  /// The multi-device event of contact.
  /// ~end
  ///
  /// ~chinese
  /// 多设备联系人事件。
  /// ~end
  final void Function(
    EMMultiDevicesEvent event,
    String userId,
    String? ext,
  )? onContactEvent;

  /// ~english
  /// The multi-device event of group.
  /// ~end
  ///
  /// ~chinese
  /// 多设备群组事件。
  /// ~end
  final void Function(
    EMMultiDevicesEvent event,
    String groupId,
    List<String>? userIds,
  )? onGroupEvent;

  /// ~english
  /// The multi-device event of thread.
  /// ~end
  ///
  /// ~chinese
  /// 多设备Thread 事件。
  /// ~end
  final void Function(
    EMMultiDevicesEvent event,
    String chatThreadId,
    List<String> userIds,
  )? onChatThreadEvent;

  /// ~english
  /// The multi-device event handler.
  ///
  /// Param [onContactEvent] The multi-device event of contact.
  ///
  /// Param [onGroupEvent] The multi-device event of group.
  ///
  /// Param [onChatThreadEvent] The multi-device event of thread.
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
  /// ~end
  EMMultiDeviceEventHandler({
    this.onContactEvent,
    this.onGroupEvent,
    this.onChatThreadEvent,
  });
}

/// ~english
/// The chat event handler.
///
/// This handler is used to check whether messages are received. If messages are sent successfully, a delivery receipt will be returned (delivery receipt needs to be enabled: [EMOptions.requireDeliveryAck].
/// If the peer reads the received message, a read receipt will be returned (read receipt needs to be enabled: [EMOptions.requireAck]).
/// This API should be implemented in the app to listen for message status changes.
///
/// Adds chat event handler:
/// ```dart
///   EMClient.getInstance.chatManager.addEventHandler(UNIQUE_HANDLER_ID, EMChatEventHandler());
/// ```
///
/// Remove a chat event handler:
/// ```dart
///   EMClient.getInstance.chatManager.removeEventHandler(UNIQUE_HANDLER_ID);
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
///   EMClient.getInstance.chatManager.addEventHandler(UNIQUE_HANDLER_ID, EMChatEventHandler());
/// ```
///
/// 移除监听：
/// ```dart
///   EMClient.getInstance.chatManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
class EMChatEventHandler {
  /// ~english
  /// Occurs when a message is received callback.
  ///
  /// This callback is triggered to notify the user when a message such as texts or an image, video, voice, location, or file is received.
  /// ~end
  ///
  /// ~chinese
  /// 收到消息回调。
  /// 在收到文本、图片、视频、语音、地理位置和文件等消息时，通过此回调通知用户。
  /// ~end
  final void Function(List<EMMessage> messages)? onMessagesReceived;

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
  final void Function(List<EMMessage> messages)? onCmdMessagesReceived;

  /// ~english
  /// Occurs when a read receipt is received for a message.
  /// ~end
  ///
  /// ~chinese
  /// 收到单聊消息已读回执的回调。
  /// ~end
  final void Function(List<EMMessage> messages)? onMessagesRead;

  /// ~english
  /// Occurs when a read receipt is received for a group message.
  /// ~end
  ///
  /// ~chinese
  /// 收到群组消息的已读回执的回调。
  /// ~end
  final void Function(List<EMGroupMessageAck> groupMessageAcks)?
      onGroupMessageRead;

  /// ~english
  /// Occurs when the update for the group message read status is received.
  /// ~end
  ///
  /// ~chinese
  /// 群消息已读变更。
  /// ~end
  final VoidCallback? onReadAckForGroupMessageUpdated;

  /// ~english
  /// Occurs when a delivery receipt is received.
  /// ~end
  ///
  /// ~chinese
  /// 收到消息已送达回执的回调。
  /// ~end
  final void Function(List<EMMessage> messages)? onMessagesDelivered;

  /// ~english
  /// Occurs when a received message is recalled.
  /// ~end
  ///
  /// ~chinese
  /// 已收到的消息被撤回的回调。
  /// ~end
  final void Function(List<EMMessage> messages)? onMessagesRecalled;

  /// ~english
  /// Occurs when the conversation updated.
  /// ~end
  ///
  /// ~chinese
  /// 会话更新事件回调。
  /// ~end
  final VoidCallback? onConversationsUpdate;

  /// ~english
  /// Occurs when a conversation read receipt is received.
  ///
  /// Occurs in the following scenarios:
  /// (1) The message is read by the receiver (The conversation receipt is sent).
  /// Upon receiving this event, the SDK sets the [EMMessage.hasReadAck] property of the message in the conversation to `true` in the local database.
  /// (2) In the multi-device login scenario, when one device sends a Conversation receipt,
  /// the server will set the number of unread messages to 0, and the callback occurs on the other devices.
  /// and sets the [EMMessage.hasReadAck] property of the message in the conversation to `true` in the local database.
  /// ~end
  ///
  /// ~chinese
  /// 收到会话已读回执的回调。
  ///
  /// 回调此方法的场景：
  /// （1）消息被接收方阅读，即接收方发送了会话已读回执。
  /// SDK 在接收到此事件时，会将本地数据库中该会话中消息的 `isAcked` 属性置为 `true`。
  /// （2）多端多设备登录场景下，一端发送会话已读回执，服务器端会将会话的未读消息数置为 0，
  /// 同时其他端会回调此方法，并将本地数据库中该会话中消息的 `isRead` 属性置为 `true`。
  /// ~end
  final void Function(String from, String to)? onConversationRead;

  /// ~english
  /// Occurs when the Reaction data changes.
  /// ~end
  ///
  /// ~chinese
  /// 消息表情回复（Reaction）变化监听器。
  /// ~end
  final void Function(List<EMMessageReactionEvent> events)?
      onMessageReactionDidChange;

  /// ~english
  /// The chat event handler.
  ///
  /// Param [onMessagesReceived] Message is received callback.
  ///
  /// Param [onCmdMessagesReceived] Command message is received callback.
  ///
  /// Param [onMessagesRead] Read receipt is received for a message callback.
  ///
  /// Param [onGroupMessageRead] Read receipt is received for a group message callback.
  ///
  /// Param [onReadAckForGroupMessageUpdated] Group message read status is received callback.
  ///
  /// Param [onMessagesDelivered] Delivery receipt is received callback.
  ///
  /// Param [onMessagesRecalled] Received message is recalled callback.
  ///
  /// Param [onConversationsUpdate] Conversation updated callback.
  ///
  /// Param [onConversationRead] Conversation read receipt is received callback.
  ///
  /// Param [onMessageReactionDidChange] Reaction data changes callback.
  /// ~end
  ///
  /// ~chinese
  /// 消息事件监听。
  ///
  /// Param [onMessagesReceived] 在收到文本、图片、视频、语音、地理位置和文件等消息时，通过此回调通知用户。
  ///
  /// Param [onCmdMessagesReceived] 收到命令消息回调。
  ///
  /// Param [onMessagesRead] 收到单聊消息已读回执的回调。
  ///
  /// Param [onGroupMessageRead] 收到群组消息的已读回执的回调。
  ///
  /// Param [onReadAckForGroupMessageUpdated] 群消息已读变更。
  ///
  /// Param [onMessagesDelivered] 收到消息已送达回执的回调。
  ///
  /// Param [onMessagesRecalled] 已收到的消息被撤回的回调。
  ///
  /// Param [onConversationsUpdate] 会话更新事件回调。
  ///
  /// Param [onConversationRead] 收到会话已读回执的回调。
  ///
  /// Param [onMessageReactionDidChange] 消息表情回复（Reaction）变化监听器。
  /// ~end
  EMChatEventHandler({
    this.onMessagesReceived,
    this.onCmdMessagesReceived,
    this.onMessagesRead,
    this.onGroupMessageRead,
    this.onReadAckForGroupMessageUpdated,
    this.onMessagesDelivered,
    this.onMessagesRecalled,
    this.onConversationsUpdate,
    this.onConversationRead,
    this.onMessageReactionDidChange,
  });
}

/// ~english
/// The chat room event handler.
///
/// Adds chat event handler:
/// ```dart
///   EMClient.getInstance.chatRoomManager.addEventHandler(UNIQUE_HANDLER_ID, EMChatRoomEventHandler());
/// ```
///
/// Remove a chat room event handler:
/// ```dart
///   EMClient.getInstance.chatRoomManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
///
/// ~chinese
/// 聊天室事件监听。
///
/// 添加监听:
/// ```dart
///   EMClient.getInstance.chatRoomManager.addEventHandler(UNIQUE_HANDLER_ID, EMChatRoomEventHandler());
/// ```
///
/// Remove a chat room event handler:
/// ```dart
///   EMClient.getInstance.chatRoomManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
class EMChatRoomEventHandler {
  /// ~english
  /// Occurs when a member has been changed to an admin.
  /// ~end
  ///
  /// ~chinese
  /// 有成员设置为聊天室管理员的回调。
  /// ~end
  final void Function(
    String roomId,
    String admin,
  )? onAdminAddedFromChatRoom;

  /// ~english
  /// Occurs when an admin is been removed.
  /// ~end
  ///
  /// ~chinese
  /// 移除聊天室管理员权限的回调。
  /// ~end
  final void Function(
    String roomId,
    String admin,
  )? onAdminRemovedFromChatRoom;

  /// ~english
  /// Occurs when all members in the chat room are muted or unmuted.
  /// ~end
  ///
  /// ~chinese
  /// 聊天室全员禁言状态变化回调。
  /// ~end
  final void Function(
    String roomId,
    bool isAllMuted,
  )? onAllChatRoomMemberMuteStateChanged;

  /// ~english
  /// Occurs when the chat room member(s) is added to the allowlist.
  /// ~end
  ///
  /// ~chinese
  /// 有成员被加入聊天室白名单的回调。
  /// ~end
  final void Function(
    String roomId,
    List<String> members,
  )? onAllowListAddedFromChatRoom;

  /// ~english
  /// Occurs when the chat room member(s) is removed from the allowlist.
  /// ~end
  ///
  /// ~chinese
  /// 有成员被移出聊天室白名单的回调。
  /// ~end
  final void Function(
    String roomId,
    List<String> members,
  )? onAllowListRemovedFromChatRoom;

  /// ~english
  /// Occurs when the announcement changed.
  /// ~end
  ///
  /// ~chinese
  /// 聊天室公告更新回调。
  /// ~end
  final void Function(
    String roomId,
    String announcement,
  )? onAnnouncementChangedFromChatRoom;

  /// ~english
  /// Occurs when the chat room is destroyed.
  /// ~end
  ///
  /// ~chinese
  /// 聊天室解散的回调。
  /// ~end
  final void Function(
    String roomId,
    String? roomName,
  )? onChatRoomDestroyed;

  /// ~english
  /// Occurs when a member leaves the chatroom.
  /// ~end
  ///
  /// ~chinese
  /// 聊天室成员主动退出回调。
  /// ~end
  final void Function(
    String roomId,
    String? roomName,
    String participant,
  )? onMemberExitedFromChatRoom;

  /// ~english
  /// Occurs when a member join the chatroom.
  /// ~end
  ///
  /// ~chinese
  /// 聊天室加入新成员回调。
  /// ~end
  final void Function(String roomId, String participant)?
      onMemberJoinedFromChatRoom;

  /// ~english
  /// Occurs when there are chat room member(s) muted (added to mute list),
  /// ~end
  ///
  /// ~chinese
  /// 有成员被禁言回调。
  /// ~end
  final void Function(
    String roomId,
    List<String> mutes,
    String? expireTime,
  )? onMuteListAddedFromChatRoom;

  /// ~english
  /// Occurs when there are chat room member(s) unmuted (removed from mute list).
  /// ~end
  ///
  /// ~chinese
  /// 有成员从禁言列表中移除回调。
  /// ~end
  final void Function(
    String roomId,
    List<String> mutes,
  )? onMuteListRemovedFromChatRoom;

  /// ~english
  /// Occurs when the chat room ownership has been transferred.
  /// ~end
  ///
  /// ~chinese
  /// 转移聊天室的所有权的回调。
  /// ~end
  final void Function(
    String roomId,
    String newOwner,
    String oldOwner,
  )? onOwnerChangedFromChatRoom;

  /// ~english
  /// Occurs when a member is dismissed from a chat room.
  /// ~end
  ///
  /// ~chinese
  /// 聊天室成员被移出聊天室回调。
  /// ~end
  final void Function(
    String roomId,
    String? roomName,
    String? participant,
  )? onRemovedFromChatRoom;

  /// ~english
  /// Occurs when the chat room specifications changes. All chat room members receive this event.
  /// ~end
  ///
  /// ~chinese
  /// 聊天室详情变更。
  /// ~end
  final void Function(EMChatRoom room)? onSpecificationChanged;

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
  final void Function(
    String roomId,
    List<String> removedKeys,
    String from,
  )? onAttributesRemoved;

  /// ~english
  /// The chat room manager listener callback.
  ///
  /// Param [onAdminAddedFromChatRoom] A member has been changed to an admin callback.
  ///
  /// Param [onAdminRemovedFromChatRoom] An admin is been removed callback callback.
  ///
  /// Param [onAllChatRoomMemberMuteStateChanged] All members in the chat room are muted or unmuted callback.
  ///
  /// Param [onAllowListAddedFromChatRoom] The chat room member(s) is added to the allowlist callback.
  ///
  /// Param [onAllowListRemovedFromChatRoom] The chat room member(s) is removed from the allowlist callback.
  ///
  /// Param [onAnnouncementChangedFromChatRoom] The announcement changed callback.
  ///
  /// Param [onChatRoomDestroyed] The chat room is destroyed callback.
  ///
  /// Param [onMemberExitedFromChatRoom] A member leaves the chatroom callback.
  ///
  /// Param [onMemberJoinedFromChatRoom] A member join the chatroom callback.
  ///
  /// Param [onMuteListAddedFromChatRoom] The chat room member(s) muted (added to mute list) callback.
  ///
  /// Param [onMuteListRemovedFromChatRoom] The chat room member(s) unmuted (removed from mute list) callback.
  ///
  /// Param [onOwnerChangedFromChatRoom] The chat room ownership has been transferred callback.
  ///
  /// Param [onRemovedFromChatRoom] The chat room member(s) is removed from the allowlist callback.
  ///
  /// Param [onSpecificationChanged] The chat room specification changed callback.
  ///
  /// Param [onAttributesUpdated] The chat room attributes updated callback.
  ///
  /// Param [onAttributesRemoved] The chat room attributes removed callback.
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
  EMChatRoomEventHandler({
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
/// The message thread event handler. which handle for message thread events such as creating or leaving a message thread.
///
/// Adds a message thread event handler:
/// ```dart
///   EMClient.getInstance.chatThreadManager.addEventHandler(UNIQUE_HANDLER_ID, EMChatThreadEventHandler());
/// ```
///
/// Remove a chat event handler:
/// ```dart
/// EMClient.getInstance.chatThreadManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
///
/// ~chinese
/// Thread 事件监听
///
/// 添加监听:
/// ```dart
///   EMClient.getInstance.chatThreadManager.addEventHandler(UNIQUE_HANDLER_ID, EMChatThreadEventHandler());
/// ```
///
/// 移除监听:
/// ```dart
/// EMClient.getInstance.chatThreadManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
class EMChatThreadEventHandler {
  /// ~english
  /// Occurs when a message thread is created.
  ///
  /// Each member of the group to which the message thread belongs can receive the callback.
  /// ~end
  ///
  /// ~chinese
  /// 子区创建回调。
  /// ~end
  final void Function(
    EMChatThreadEvent event,
  )? onChatThreadCreate;

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
  final void Function(
    EMChatThreadEvent event,
  )? onChatThreadDestroy;

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
  final void Function(
    EMChatThreadEvent event,
  )? onChatThreadUpdate;

  /// ~english
  /// Occurs when the current user is removed from the message thread by the group owner or a group admin to which the message thread belongs.
  /// ~end
  ///
  /// ~chinese
  /// 管理员移除子区用户的回调。
  /// ~end
  final void Function(
    EMChatThreadEvent event,
  )? onUserKickOutOfChatThread;

  /// ~english
  /// The message thread listener callback
  ///
  /// Param [onChatThreadCreate] A message thread is created callback.
  ///
  /// Param [onChatThreadDestroy] A message thread is destroyed callback.
  ///
  /// Param [onChatThreadUpdate] A message thread is updated callback.
  ///
  /// Param [onUserKickOutOfChatThread] Current user is removed from the message thread by the group owner or a group admin to which the message thread belongs callback.
  /// ~end
  ///
  /// ~chinese
  /// Thread 事件监听
  ///
  /// Param [onChatThreadCreate] 子区创建回调。
  ///
  /// Param [onChatThreadDestroy] 子区解散事件, 子区所属群组的所有成员均可调用该方法。
  ///
  /// Param [onChatThreadUpdate] 子区更新回调, 子区所属群组的所有成员均可调用该方法。
  ///
  /// Param [onUserKickOutOfChatThread] 管理员移除子区用户的回调。
  /// ~end
  EMChatThreadEventHandler({
    this.onChatThreadCreate,
    this.onChatThreadDestroy,
    this.onChatThreadUpdate,
    this.onUserKickOutOfChatThread,
  });
}

/// ~english
/// The contact event handler.
///
/// Occurs when the contact changes, including requests to add friends, notifications to delete friends,
/// requests to accept friends, and requests to reject friends.
///
/// Adds a contact event handler:
/// ```dart
///   EMClient.getInstance.contactManager.addEventHandler(UNIQUE_HANDLER_ID, EMContactEventHandler());
/// ```
///
/// Remove a contact event handler:
/// ```dart
///   EMClient.getInstance.contactManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
///
/// ~chinese
/// 联系人事件监听
///
/// 添加监听:
/// ```dart
///   EMClient.getInstance.contactManager.addEventHandler(UNIQUE_HANDLER_ID, EMContactEventHandler());
/// ```
///
/// 移除监听:
/// ```dart
///   EMClient.getInstance.contactManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
class EMContactEventHandler {
  /// ~english
  /// Occurs when user is added as a contact by another user.
  /// ~end
  ///
  /// ~chinese
  /// 添加好友回调。
  /// ~end
  final void Function(
    String userId,
  )? onContactAdded;

  /// ~english
  /// Occurs when a user is removed from the contact list by another user.
  /// ~end
  ///
  /// ~chinese
  /// 删除好友回调。
  /// ~end
  final void Function(
    String userId,
  )? onContactDeleted;

  /// ~english
  /// Occurs when a user receives a friend request.
  /// ~end
  ///
  /// ~chinese
  /// 好友申请回调。
  /// ~end
  final void Function(
    String userId,
    String? reason,
  )? onContactInvited;

  /// ~english
  /// Occurs when a friend request is approved.
  /// ~end
  ///
  /// ~chinese
  /// 发出的好友申请被对方同意。
  /// ~end
  final void Function(
    String userId,
  )? onFriendRequestAccepted;

  /// ~english
  /// Occurs when a friend request is declined.
  /// ~end
  ///
  /// ~chinese
  /// 发出的好友申请被对方拒绝。
  /// ~end
  final void Function(
    String userId,
  )? onFriendRequestDeclined;

  /// ~english
  /// The contact updates listener callback.
  ///
  /// Param [onContactAdded] Current user is added as a contact by another user callback.
  ///
  /// Param [onContactDeleted] Current user is removed from the contact list by another user callback.
  ///
  /// Param [onContactInvited] Current user receives a friend request callback.
  ///
  /// Param [onFriendRequestAccepted] A friend request is approved callback.
  ///
  /// Param [onFriendRequestDeclined] A friend request is declined callback.
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
  /// ~end
  EMContactEventHandler({
    this.onContactAdded,
    this.onContactDeleted,
    this.onContactInvited,
    this.onFriendRequestAccepted,
    this.onFriendRequestDeclined,
  });
}

/// ~english
/// The group event handler.
///
/// Occurs when the following group events happens: requesting to join a group, approving or declining a group request, and kicking a user out of a group.
///
/// Adds a group event handler:
/// ```dart
///   EMClient.getInstance.groupManager.addEventHandler(UNIQUE_HANDLER_ID, EMGroupEventHandler());
/// ```
///
/// Remove a group event handler:
/// ```dart
///   EMClient.getInstance.groupManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
///
/// ~chinese
/// 群组事件监听
///
/// 添加监听:
/// ```dart
///   EMClient.getInstance.groupManager.addEventHandler(UNIQUE_HANDLER_ID, EMGroupEventHandler());
/// ```
///
/// 移除监听:
/// ```dart
///   EMClient.getInstance.groupManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
class EMGroupEventHandler {
  /// ~english
  /// Occurs when a member is set as an admin.
  /// ~end
  ///
  /// ~chinese
  /// 成员设置为管理员的回调。
  /// ~end
  final void Function(
    String groupId,
    String admin,
  )? onAdminAddedFromGroup;

  /// ~english
  /// Occurs when a member's admin privileges are removed.
  /// ~end
  ///
  /// ~chinese
  /// 取消成员的管理员权限的回调。
  /// ~end
  final void Function(
    String groupId,
    String admin,
  )? onAdminRemovedFromGroup;

  /// ~english
  /// Occurs when all group members are muted or unmuted.
  /// ~end
  ///
  /// ~chinese
  /// 全员禁言状态变化回调。
  /// ~end
  final void Function(
    String groupId,
    bool isAllMuted,
  )? onAllGroupMemberMuteStateChanged;

  /// ~english
  /// Occurs when one or more group members are added to the allowlist.
  /// ~end
  ///
  /// ~chinese
  /// 成员加入群组白名单回调。
  /// ~end
  final void Function(
    String groupId,
    List<String> members,
  )? onAllowListAddedFromGroup;

  /// ~english
  /// Occurs when one or more members are removed from the allowlist.
  /// ~end
  ///
  /// ~chinese
  /// 成员移出群组白名单回调。
  /// ~end
  final void Function(
    String groupId,
    List<String> members,
  )? onAllowListRemovedFromGroup;

  /// ~english
  /// Occurs when the announcement is updated.
  /// ~end
  ///
  /// ~chinese
  /// 群公告更新回调。
  /// ~end
  final void Function(
    String groupId,
    String announcement,
  )? onAnnouncementChangedFromGroup;

  /// ~english
  /// Occurs when the group invitation is accepted automatically.
  /// For settings, See [EMOptions.autoAcceptGroupInvitation].
  /// The SDK will join the group before notifying the app of the acceptance of the group invitation.
  /// ~end
  ///
  /// ~chinese
  /// 当前用户自动同意入群邀请的回调。
  /// 设置请见 [EMOptions.autoAcceptGroupInvitation].
  /// ~end
  final void Function(
    String groupId,
    String inviter,
    String? inviteMessage,
  )? onAutoAcceptInvitationFromGroup;

  /// ~english
  /// Occurs when a group is destroyed.
  /// ~end
  ///
  /// ~chinese
  /// 当前用户收到群组被解散的回调。
  /// ~end
  final void Function(
    String groupId,
    String? groupName,
  )? onGroupDestroyed;

  /// ~english
  /// Occurs when a group invitation is accepted.
  /// ~end
  ///
  /// ~chinese
  /// 当前用户收到对端用户同意入群邀请触发的回调。
  /// ~end
  final void Function(
    String groupId,
    String invitee,
    String? reason,
  )? onInvitationAcceptedFromGroup;

  /// ~english
  /// Occurs when a group invitation is declined.
  /// ~end
  ///
  /// ~chinese
  /// 当前用户收到群组邀请被拒绝的回调。
  /// 该回调是由当前用户收到对端用户拒绝入群邀请触发的。例如，用户 B 拒绝了用户 A 的群组邀请，用户 A 会收到该回调。
  /// ~end
  final void Function(
    String groupId,
    String invitee,
    String? reason,
  )? onInvitationDeclinedFromGroup;

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
  final void Function(
    String groupId,
    String member,
  )? onMemberExitedFromGroup;

  /// ~english
  /// Occurs when a member joins a group.
  /// ~end
  ///
  /// ~chinese
  /// 新成员加入群组的回调。
  /// ~end
  final void Function(
    String groupId,
    String member,
  )? onMemberJoinedFromGroup;

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
  final void Function(
    String groupId,
    List<String> mutes,
    int? muteExpire,
  )? onMuteListAddedFromGroup;

  /// ~english
  /// Occurs when one or more group members are unmuted.
  /// ~end
  ///
  /// ~chinese
  /// 有成员被解除禁言的回调。
  /// ~end
  final void Function(
    String groupId,
    List<String> mutes,
  )? onMuteListRemovedFromGroup;

  /// ~english
  /// Occurs when the group ownership is transferred.
  /// ~end
  ///
  /// ~chinese
  /// 转移群主权限的回调。
  /// ~end
  final void Function(
    String groupId,
    String newOwner,
    String oldOwner,
  )? onOwnerChangedFromGroup;

  /// ~english
  /// Occurs when a group request is accepted.
  /// ~end
  ///
  /// ~chinese
  /// 对端用户接受当前用户发送的群组申请的回调。
  /// ~end
  final void Function(
    String groupId,
    String? groupName,
    String accepter,
  )? onRequestToJoinAcceptedFromGroup;

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
    String decliner,
    String? reason,
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
  final void Function(
    String groupId,
    EMGroupSharedFile sharedFile,
  )? onSharedFileAddedFromGroup;

  /// ~english
  /// Occurs when the group detail information is updated.
  /// ~end
  ///
  /// ~chinese
  /// 群详情变更回调。
  /// ~end
  final void Function(
    EMGroup group,
  )? onSpecificationDidUpdate;

  /// ~english
  /// Occurs when the group is enabled or disabled.
  /// ~end
  ///
  /// ~chinese
  /// 群是禁用状态变更。
  /// ~end
  final void Function(
    String groupId,
    bool isDisable,
  )? onDisableChanged;

  /// ~english
  /// Occurs when a shared file is removed from a group.
  /// ~end
  ///
  /// ~chinese
  /// 群组删除共享文件回调。
  /// ~end
  final void Function(
    String groupId,
    String fileId,
  )? onSharedFileDeletedFromGroup;

  /// ~english
  /// Occurs when the current user is removed from the group by the group admin.
  /// ~end
  ///
  /// ~chinese
  /// 当前用户被移出群组时的回调。
  /// ~end
  final void Function(
    String groupId,
    String? groupName,
  )? onUserRemovedFromGroup;

  /// ~english
  /// The group manager listener callback.
  ///
  /// Param [onAdminAddedFromGroup] A member is set as an admin callback.
  ///
  /// Param [onAdminRemovedFromGroup] A member's admin privileges are removed callback.
  ///
  /// Param [onAllGroupMemberMuteStateChanged] All group members are muted or unmuted callback.
  ///
  /// Param [onAllowListAddedFromGroup] One or more group members are muted callback.
  ///
  /// Param [onAllowListRemovedFromGroup] One or more group members are unmuted callback.
  ///
  /// Param [onAnnouncementChangedFromGroup] The announcement is updated callback.
  ///
  /// Param [onAutoAcceptInvitationFromGroup] The group invitation is accepted automatically callback.
  ///
  /// Param [onGroupDestroyed] A group is destroyed callback.
  ///
  /// Param [onInvitationAcceptedFromGroup] A group invitation is accepted callback.
  ///
  /// Param [onInvitationDeclinedFromGroup] A group invitation is declined callback.
  ///
  /// Param [onInvitationReceivedFromGroup] The user receives a group invitation callback.
  ///
  /// Param [onMemberExitedFromGroup] A member proactively leaves the group callback.
  ///
  /// Param [onMemberJoinedFromGroup] A member joins a group callback.
  ///
  /// Param [onMuteListAddedFromGroup] One or more group members are muted callback.
  ///
  /// Param [onMuteListRemovedFromGroup] One or more group members are unmuted callback.
  ///
  /// Param [onOwnerChangedFromGroup] The group ownership is transferred callback.
  ///
  /// Param [onRequestToJoinAcceptedFromGroup] A group request is accepted callback.
  ///
  /// Param [onRequestToJoinDeclinedFromGroup] A group request is declined callback.
  ///
  /// Param [onRequestToJoinReceivedFromGroup] The group owner or administrator receives a group request from a user callback.
  ///
  /// Param [onSharedFileAddedFromGroup] A shared file is added to a group callback.
  ///
  /// Param [onSharedFileDeletedFromGroup] A shared file is removed from a group callback.
  ///
  /// Param [onUserRemovedFromGroup] Current user is removed from the group by the group admin callback.
  ///
  /// Param [onSpecificationDidUpdate] Occurs when the group detail information is updated.
  ///
  /// Param [onDisableChanged] Occurs when the group is enabled or disabled.
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
  /// Param [onAutoAcceptInvitationFromGroup] 当前用户自动同意入群邀请的回调, 设置请见 [EMOptions.autoAcceptGroupInvitation]。
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
  /// ~end
  EMGroupEventHandler({
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
    this.onMemberExitedFromGroup,
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
  });
}

/// ~english
/// The presence event handler.
///
/// Occurs when the following presence events happens: presence status changed.
///
/// Adds a presence event handler:
/// ```dart
///   EMClient.getInstance.presenceManager.addEventHandler(UNIQUE_HANDLER_ID, EMPresenceEventHandler());
/// ```
///
/// Remove a presence event handler:
/// ```dart
///   EMClient.getInstance.presenceManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
///
/// ~chinese
/// 订阅用户状态变更监听
///
/// 添加监听:
/// ```dart
///   EMClient.getInstance.presenceManager.addEventHandler(UNIQUE_HANDLER_ID, EMPresenceEventHandler());
/// ```
///
/// 移除监听:
/// ```dart
///   EMClient.getInstance.presenceManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
/// ~end
class EMPresenceEventHandler {
  /// ~english
  /// Occurs when the presence state of a subscribed user changes.
  /// ~end
  ///
  /// ~chinese
  /// 收到被订阅用户的在线状态发生变化。
  /// ~end
  final Function(List<EMPresence> list)? onPresenceStatusChanged;

  /// ~english
  /// The presence manager listener callback.
  ///
  /// Param [onPresenceStatusChanged] The presence state of a subscribed user changes callback.
  /// ~end
  ///
  /// ~chinese
  /// 订阅用户状态变更监听。
  /// ~end
  EMPresenceEventHandler({
    this.onPresenceStatusChanged,
  });
}
