import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

///
/// 服务器连接监听器
///
/// 在网络不稳定的情况下出现onDisconnected时，不需要手动重新连接，聊天SDK将自动重连。
///
/// 添加监听器
/// ```dart
///   EMClient.getInstance.addConnectionEventHandler(UNIQUE_HANDLER_ID, EMConnectionEventHandler());
/// ```
///
/// 移除监听器
/// ```dart
///   EMClient.getInstance.removeConnectionEventHandler(UNIQUE_HANDLER_ID);
/// ```
///
class EMConnectionEventHandler {
  ///
  /// SDK连接聊天服务器成功事件。
  ///
  final VoidCallback? onConnected;

  ///
  /// SDK与聊天服务器断开事件。
  ///
  final VoidCallback? onDisconnected;

  ///
  /// 当前用户账号登录到其他设备事件。
  ///
  final VoidCallback? onUserDidLoginFromOtherDevice;

  ///
  /// 当前聊天用户从服务器删除时回调。
  ///
  final VoidCallback? onUserDidRemoveFromServer;

  ///
  /// 当服务器禁止当前聊天用户访问事件。
  ///
  final VoidCallback? onUserDidForbidByServer;

  ///
  /// 当前用户密码变更事件。
  ///
  final VoidCallback? onUserDidChangePassword;

  ///
  /// 当前聊天用户登录到超过限制数量的设备事件。
  ///
  final VoidCallback? onUserDidLoginTooManyDevice;

  ///
  /// 当前聊天用户被其他设备踢出事件。
  ///
  final VoidCallback? onUserKickedByOtherDevice;

  ///
  /// 当前聊天用户身份验证失败事件。
  ///
  final VoidCallback? onUserAuthenticationFailed;

  ///
  /// token 即将过期事件。
  ///
  final VoidCallback? onTokenWillExpire;

  ///
  /// token 过期事件。
  ///
  final VoidCallback? onTokenDidExpire;

  ///
  /// 聊天连接侦听器回调。
  ///
  /// Param [onConnected] SDK连接聊天服务器成功。
  ///
  /// Param [onDisconnected] SDK与聊天服务器断开。
  ///
  /// Param [onUserDidLoginFromOtherDevice] 当前用户账号已登录到其他设备。
  ///
  /// Param [onUserDidRemoveFromServer] 当前聊天用户已从服务器中删除。
  ///
  /// Param [onUserDidForbidByServer] 当前聊天用户被禁止从服务器。
  ///
  /// Param [onUserDidChangePassword] 当前有用户密码变更。
  ///
  /// Param [onUserDidLoginTooManyDevice] 当前聊天用户登录了过多设备。
  ///
  /// Param [onUserKickedByOtherDevice] 当前聊天用户被其他设备踢出。
  ///
  /// Param [onUserAuthenticationFailed] 当前聊天用户认证失败。
  ///
  /// Param [onTokenWillExpire] token即将过期。
  ///
  /// Param [onTokenDidExpire] token已过期。
  ///
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

///
/// 多设备事件监听器。
/// 监听当前用户在其他设备上操作的回调，包括联系人更改,群组更改和子区更改。
///
/// 添加多设备监听器：
/// ```dart
///   EMClient.getInstance.addMultiDeviceEventHandler((UNIQUE_HANDLER_ID, EMMultiDeviceEventHandler());
/// ```
///
/// 移除多设备监听器：
/// ```dart
///   EMClient.getInstance.removeMultiDeviceEventHandler(UNIQUE_HANDLER_ID);
/// ```
///
class EMMultiDeviceEventHandler {
  /// 联系人多设备事件。
  final void Function(
    EMMultiDevicesEvent event,
    String userId,
    String? ext,
  )? onContactEvent;

  /// 群组多设备事件。
  final void Function(
    EMMultiDevicesEvent event,
    String groupId,
    List<String>? userIds,
  )? onGroupEvent;

  /// 子区多设备事件。
  final void Function(
    EMMultiDevicesEvent event,
    String chatThreadId,
    List<String> userIds,
  )? onChatThreadEvent;

  /// 多设备事件监听器
  ///
  /// Param [onContactEvent] 联系人多设备事件。
  ///
  /// Param [onGroupEvent] 群组多设备事件。
  ///
  /// Param [onChatThreadEvent] 子区多设备事件。
  ///
  EMMultiDeviceEventHandler({
    this.onContactEvent,
    this.onGroupEvent,
    this.onChatThreadEvent,
  });
}

///
/// 聊天事件监听器。
///
/// 添加聊天事件监听器
/// ```dart
///   EMClient.getInstance.chatManager.addEventHandler(UNIQUE_HANDLER_ID, EMChatEventHandler());
/// ```
///
/// 移除聊天事件监听器
/// ```dart
///   EMClient.getInstance.chatManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
///
class EMChatEventHandler {
  /// 接收消息事件。
  final void Function(List<EMMessage> messages)? onMessagesReceived;

  /// 接收命令消息事件。
  final void Function(List<EMMessage> messages)? onCmdMessagesReceived;

  ///
  /// 接收消息已读事件。
  ///
  final void Function(List<EMMessage> messages)? onMessagesRead;

  ///
  /// 接收群已读时事件。
  ///
  final void Function(List<EMGroupMessageAck> groupMessageAcks)?
      onGroupMessageRead;

  ///
  /// 接收群已读数量变更事件。
  ///
  final VoidCallback? onReadAckForGroupMessageUpdated;

  ///
  /// 接收消息已送达事件。
  ///
  final void Function(List<EMMessage> messages)? onMessagesDelivered;

  ///
  /// 接收消息被撤回事件。
  ///
  final void Function(List<EMMessage> messages)? onMessagesRecalled;

  ///
  /// 接收会话列表数量变更事件。
  ///
  final VoidCallback? onConversationsUpdate;

  ///
  /// 接收会话已读事件。
  ///
  /// 收到会话已读是，会话中的消息也将会变为收到已读状态 [EMMessage.hasReadAck]。
  ///
  final void Function(String from, String to)? onConversationRead;

  ///
  /// Reaction 变更事件。
  ///
  final void Function(List<EMMessageReactionEvent> events)?
      onMessageReactionDidChange;

  ///
  /// 聊天事件监听器。
  ///
  /// Param [onMessagesReceived] 收消息事件。
  ///
  /// Param [onCmdMessagesReceived] 收Cmd消息事件。
  ///
  /// Param [onMessagesRead] 收消息已读事件。
  ///
  /// Param [onGroupMessageRead] 收群消息已读事件。
  ///
  /// Param [onReadAckForGroupMessageUpdated] 群已读数量变更事件。
  ///
  /// Param [onMessagesDelivered] 消息已送达事件。
  ///
  /// Param [onMessagesRecalled] 消息撤回事件。
  ///
  /// Param [onConversationsUpdate] 会话列表更新事件。
  ///
  /// Param [onConversationRead] 会话已读事件。
  ///
  /// Param [onMessageReactionDidChange] Reaction 变更事件。
  ///
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

///
/// 聊天室时间监听器
///
/// 添加聊天室事件监听
/// ```dart
///   EMClient.getInstance.chatRoomManager.addEventHandler(UNIQUE_HANDLER_ID, EMChatRoomEventHandler());
/// ```
///
/// 移除聊天室事件监听
/// ```dart
///   EMClient.getInstance.chatRoomManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
///
class EMChatRoomEventHandler {
  ///
  /// 添加管理员事件。
  ///
  final void Function(
    String roomId,
    String admin,
  )? onAdminAddedFromChatRoom;

  ///
  /// 移除管理员事件。
  ///
  final void Function(
    String roomId,
    String admin,
  )? onAdminRemovedFromChatRoom;

  ///
  /// 全员禁言变化事件。
  ///
  final void Function(
    String roomId,
    bool isAllMuted,
  )? onAllChatRoomMemberMuteStateChanged;

  ///
  /// 白名单成员增加事件。
  ///
  final void Function(
    String roomId,
    List<String> members,
  )? onAllowListAddedFromChatRoom;

  ///
  /// 白名单成员减少事件。
  ///
  final void Function(
    String roomId,
    List<String> members,
  )? onAllowListRemovedFromChatRoom;

  ///
  /// 公告变更事件。
  ///
  final void Function(
    String roomId,
    String announcement,
  )? onAnnouncementChangedFromChatRoom;

  ///
  /// 聊天室销毁事件。
  ///
  final void Function(
    String roomId,
    String? roomName,
  )? onChatRoomDestroyed;

  ///
  /// 聊天室成员离开事件。
  ///
  final void Function(
    String roomId,
    String? roomName,
    String participant,
  )? onMemberExitedFromChatRoom;

  ///
  /// 聊天室成员加入事件。
  ///
  final void Function(String roomId, String participant)?
      onMemberJoinedFromChatRoom;

  ///
  /// 禁言列表增加事件。
  ///
  final void Function(
    String roomId,
    List<String> mutes,
    String? expireTime,
  )? onMuteListAddedFromChatRoom;

  ///
  /// 禁言列表减少事件。
  ///
  final void Function(
    String roomId,
    List<String> mutes,
  )? onMuteListRemovedFromChatRoom;

  ///
  ///  聊天室拥有者变更事件。
  ///
  final void Function(
    String roomId,
    String newOwner,
    String oldOwner,
  )? onOwnerChangedFromChatRoom;

  ///
  /// 被移出聊天室事件。
  ///
  final void Function(
    String roomId,
    String? roomName,
    String? participant,
  )? onRemovedFromChatRoom;

  /// Occurs when the chat room specifications changes. All chat room members receive this event.
  final void Function(EMChatRoom room)? onSpecificationChanged;

  /// Occurs when the custom chat room attributes (key-value) are updated.
  final void Function(
    String roomId,
    Map<String, String> attributes,
    String from,
  )? onAttributesUpdated;

  /// Occurs when the custom chat room attributes (key-value) are removed.
  final void Function(
    String roomId,
    List<String> removedKeys,
    String from,
  )? onAttributesRemoved;

  ///
  /// 聊天室事件监听器。
  ///
  /// Param [onAdminAddedFromChatRoom] 管理员列表增加事件。
  ///
  /// Param [onAdminRemovedFromChatRoom] 管理员列表减少事件。
  ///
  /// Param [onAllChatRoomMemberMuteStateChanged] 群员禁言变化事件。
  ///
  /// Param [onAllowListAddedFromChatRoom] 白名单列表增加事件。
  ///
  /// Param [onAllowListRemovedFromChatRoom] 白名单列表减少事件。
  ///
  /// Param [onAnnouncementChangedFromChatRoom] 聊天室公告变更事件。
  ///
  /// Param [onChatRoomDestroyed] 聊天室销毁事件。
  ///
  /// Param [onMemberExitedFromChatRoom] 聊天室成员离开事件。
  ///
  /// Param [onMemberJoinedFromChatRoom] 聊天室成员加入事件。
  ///
  /// Param [onMuteListAddedFromChatRoom] 禁言列表增加事件。
  ///
  /// Param [onMuteListRemovedFromChatRoom] 禁言列表减少事件。
  ///
  /// Param [onOwnerChangedFromChatRoom] 聊天室拥有人变更事件。
  ///
  /// Param [onRemovedFromChatRoom] 被移出聊天室事件。
  ///
  /// Param [onSpecificationChanged] The chat room specification changed callback.
  ///
  /// Param [onAttributesUpdated] The chat room attributes updated callback.
  ///
  /// Param [onAttributesRemoved] The chat room attributes removed callback.
  ///
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

///
/// 子区事件监听器。
///
/// 添加子区事件监听器。
/// ```dart
///   EMClient.getInstance.chatThreadManager.addEventHandler(UNIQUE_HANDLER_ID, EMChatThreadEventHandler());
/// ```
///
/// 移除子区事件监听器。
/// ```dart
/// EMClient.getInstance.chatThreadManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
///
class EMChatThreadEventHandler {
  ///
  /// 子区创建事件。
  ///
  /// 子区所在群组所有成员都可以收到。
  ///
  final void Function(
    EMChatThreadEvent event,
  )? onChatThreadCreate;

  ///
  /// 子区销毁事件。
  ///
  /// 子区所在群组所有成员都可以收到。
  ///
  final void Function(
    EMChatThreadEvent event,
  )? onChatThreadDestroy;

  ///
  /// 子群更新事件。
  ///
  /// 子区名称变更，或者子区中消息增加或者被撤回时回调。
  ///
  /// 子区所在群组所有成员都可以收到。
  ///
  final void Function(
    EMChatThreadEvent event,
  )? onChatThreadUpdate;

  ///
  /// 当前用户被子区移除事件。
  ///
  final void Function(
    EMChatThreadEvent event,
  )? onUserKickOutOfChatThread;

  ///
  /// 子区事件监听器。
  ///
  /// Param [onChatThreadCreate] 子区创建事件。
  ///
  /// Param [onChatThreadDestroy] 子区销毁事件。
  ///
  /// Param [onChatThreadUpdate] 子区变更事件。
  ///
  /// Param [onUserKickOutOfChatThread] 被子区移除事件。
  ///
  EMChatThreadEventHandler({
    this.onChatThreadCreate,
    this.onChatThreadDestroy,
    this.onChatThreadUpdate,
    this.onUserKickOutOfChatThread,
  });
}

///
/// 联系人事件监听器
///
/// 添加联系人事件监听器:
/// ```dart
///   EMClient.getInstance.contactManager.addEventHandler(UNIQUE_HANDLER_ID, EMContactEventHandler());
/// ```
///
/// 移除联系人事件监听器:
/// ```dart
///   EMClient.getInstance.contactManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
///
class EMContactEventHandler {
  ///
  /// 被其他用户添加事件。
  ///
  final void Function(
    String userId,
  )? onContactAdded;

  ///
  /// 被其他用户删除事件。
  ///
  final void Function(
    String userId,
  )? onContactDeleted;

  ///
  /// 收到好友请求事件。
  ///
  final void Function(
    String userId,
    String? reason,
  )? onContactInvited;

  ///
  /// 发出的好友请求被对方同意事件。
  ///
  final void Function(
    String userId,
  )? onFriendRequestAccepted;

  ///
  /// 发出的好友请求被对方拒绝事件。
  ///
  final void Function(
    String userId,
  )? onFriendRequestDeclined;

  ///
  /// 联系人事件监听器。
  ///
  /// Param [onContactAdded] 被他人添加事件。
  ///
  /// Param [onContactDeleted] 被他人删除事件。
  ///
  /// Param [onContactInvited] 收到好友申请事件。
  ///
  /// Param [onFriendRequestAccepted] 发出的好友申请被同意事件。
  ///
  /// Param [onFriendRequestDeclined] 发出的好友申请被拒绝事件。
  ///
  EMContactEventHandler({
    this.onContactAdded,
    this.onContactDeleted,
    this.onContactInvited,
    this.onFriendRequestAccepted,
    this.onFriendRequestDeclined,
  });
}

///
/// 群组事件监听器
///
/// 添加群组事件监听器
/// ```dart
///   EMClient.getInstance.groupManager.addEventHandler(UNIQUE_HANDLER_ID, EMGroupEventHandler());
/// ```
///
/// 移除群组事件监听器
/// ```dart
///   EMClient.getInstance.groupManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
///
class EMGroupEventHandler {
  ///
  /// 管理员添加事件。
  ///
  final void Function(
    String groupId,
    String admin,
  )? onAdminAddedFromGroup;

  ///
  /// 管理员移除事件。
  ///
  final void Function(
    String groupId,
    String admin,
  )? onAdminRemovedFromGroup;

  ///
  /// 全员禁言状态变更事件。
  ///
  final void Function(
    String groupId,
    bool isAllMuted,
  )? onAllGroupMemberMuteStateChanged;

  ///
  /// 白名单列表增加事件。
  ///
  final void Function(
    String groupId,
    List<String> members,
  )? onAllowListAddedFromGroup;

  ///
  /// 白名单列表移除事件。
  ///
  final void Function(
    String groupId,
    List<String> members,
  )? onAllowListRemovedFromGroup;

  ///
  /// 公告变更事件。
  ///
  final void Function(
    String groupId,
    String announcement,
  )? onAnnouncementChangedFromGroup;

  ///
  /// 自动同意加入群组事件。
  ///
  /// 具体设置详见 [EMOptions.autoAcceptGroupInvitation].
  /// SDK将加入群组，然后通知应用程序接受群组邀请。
  ///
  final void Function(
    String groupId,
    String inviter,
    String? inviteMessage,
  )? onAutoAcceptInvitationFromGroup;

  ///
  /// 群组被销毁事件。
  ///
  final void Function(
    String groupId,
    String? groupName,
  )? onGroupDestroyed;

  ///
  /// (群主和管理员)收到用户同意进群事件。
  ///
  final void Function(
    String groupId,
    String invitee,
    String? reason,
  )? onInvitationAcceptedFromGroup;

  ///
  /// (群主和管理员)收到用户拒绝进群事件。
  ///
  final void Function(
    String groupId,
    String invitee,
    String? reason,
  )? onInvitationDeclinedFromGroup;

  ///
  /// (群主和管理员)收到用户申请入群事件。
  ///
  final void Function(
    String groupId,
    String? groupName,
    String inviter,
    String? reason,
  )? onInvitationReceivedFromGroup;

  ///
  /// 群成员离开事件。
  ///
  final void Function(
    String groupId,
    String member,
  )? onMemberExitedFromGroup;

  ///
  /// 群成员加入事件。
  ///
  final void Function(
    String groupId,
    String member,
  )? onMemberJoinedFromGroup;

  ///
  /// 禁言列表增加事件。
  ///
  final void Function(
    String groupId,
    List<String> mutes,
    int? muteExpire,
  )? onMuteListAddedFromGroup;

  ///
  /// 禁言列表移除事件。
  ///
  final void Function(
    String groupId,
    List<String> mutes,
  )? onMuteListRemovedFromGroup;

  ///
  /// 拥有人变更事件。
  ///
  final void Function(
    String groupId,
    String newOwner,
    String oldOwner,
  )? onOwnerChangedFromGroup;

  ///
  /// (申请人收到)加群申请被同意事件。
  ///
  final void Function(
    String groupId,
    String? groupName,
    String accepter,
  )? onRequestToJoinAcceptedFromGroup;

  ///
  /// (申请人收到)加群申请被拒绝事件。
  ///
  final void Function(
    String groupId,
    String? groupName,
    String decliner,
    String? reason,
  )? onRequestToJoinDeclinedFromGroup;

  ///
  /// (群主和管理员)收到加群申请。
  ///
  final void Function(
    String groupId,
    String? groupName,
    String applicant,
    String? reason,
  )? onRequestToJoinReceivedFromGroup;

  ///
  /// 群文件增加事件。
  ///
  final void Function(
    String groupId,
    EMGroupSharedFile sharedFile,
  )? onSharedFileAddedFromGroup;

  /// Occurs when the group detail information is updated.
  final void Function(
    EMGroup group,
  )? onSpecificationDidUpdate;

  /// Occurs when the group is enabled or disabled.
  final void Function(
    String groupId,
    bool isDisable,
  )? onDisableChanged;

  ///
  /// 群文件被删除事件。
  ///
  final void Function(
    String groupId,
    String fileId,
  )? onSharedFileDeletedFromGroup;

  ///
  /// 当前用户被移出群组事件。
  ///
  final void Function(
    String groupId,
    String? groupName,
  )? onUserRemovedFromGroup;

  ///
  /// 群事件监听器
  ///
  /// Param [onAdminAddedFromGroup] 管理员增加。
  ///
  /// Param [onAdminRemovedFromGroup] 管理员被移除。
  ///
  /// Param [onAllGroupMemberMuteStateChanged] 群禁言状态变更。
  ///
  /// Param [onAllowListAddedFromGroup] 白名单列表增加。
  ///
  /// Param [onAllowListRemovedFromGroup] 白名单列表减少。
  ///
  /// Param [onAnnouncementChangedFromGroup] 群公告变更。
  ///
  /// Param [onAutoAcceptInvitationFromGroup] 自动同意群邀请。
  ///
  /// Param [onGroupDestroyed] 群解散。
  ///
  /// Param [onInvitationAcceptedFromGroup] (群主和管理员)收到用户同意进群。
  ///
  /// Param [onInvitationDeclinedFromGroup] (群主和管理员)收到用户拒绝进群。
  ///
  /// Param [onInvitationReceivedFromGroup] (群主和管理员)收到用户申请入群。
  ///
  /// Param [onMemberExitedFromGroup] 群成员离开。
  ///
  /// Param [onMemberJoinedFromGroup] 群成员加入。
  ///
  /// Param [onMuteListAddedFromGroup] 禁言列表增加。
  ///
  /// Param [onMuteListRemovedFromGroup] 禁言列表移除。
  ///
  /// Param [onOwnerChangedFromGroup] 群拥有人变更。
  ///
  /// Param [onRequestToJoinAcceptedFromGroup] (申请人收到)加群申请被同意。
  ///
  /// Param [onRequestToJoinDeclinedFromGroup] (申请人收到)加群申请被拒绝。
  ///
  /// Param [onRequestToJoinReceivedFromGroup] (群主和管理员)收到加群申请。
  ///
  /// Param [onSharedFileAddedFromGroup] 群文件增加。
  ///
  /// Param [onSharedFileDeletedFromGroup] 群文件被删除。
  ///
  /// Param [onUserRemovedFromGroup] 当前用户被移出群组。
  ///
  /// Param [onSpecificationDidUpdate] Occurs when the group detail information is updated.
  ///
  /// Param [onDisableChanged] /// Occurs when the group is enabled or disabled.
  ///
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

///
/// Presence 事件监听器
///
/// 添加 Presence 事件监听器
/// ```dart
///   EMClient.getInstance.presenceManager.addEventHandler(UNIQUE_HANDLER_ID, EMPresenceEventHandler());
/// ```
///
/// 移除 Presence 事件监听器
/// ```dart
///   EMClient.getInstance.presenceManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
///
class EMPresenceEventHandler {
  ///
  /// 被订阅用户在线状态变更事件。
  ///
  final Function(List<EMPresence> list)? onPresenceStatusChanged;

  ///
  /// Presence 事件监听器。
  ///
  /// Param [onPresenceStatusChanged] 被订阅用户在线状态变更。
  ///
  EMPresenceEventHandler({
    this.onPresenceStatusChanged,
  });
}
