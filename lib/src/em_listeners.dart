import 'internal/inner_headers.dart';

///
/// 服务器连接监听
///
/// 注册监听:
///   ```dart
///     EMClient.getInstance.addConnectionListener(mConnectionListener);
///   ```
///
/// 移除监听:
///   ```dart
///     EMClient.getInstance.removeConnectionListener(mConnectionListener);
///   ```
///
abstract class EMConnectionListener {
  ///
  /// 成功连接到 chat 服务器时触发的回调。
  ///
  void onConnected();

  ///
  ///  和 chat 服务器断开连接时触发的回调。
  ///
  void onDisconnected();

  ///
  /// 其他设备登录回调。
  ///
  void onUserDidLoginFromOtherDevice();

  ///
  /// 被服务器移除回调。
  ///
  void onUserDidRemoveFromServer();

  ///
  /// 被服务器禁止回调。
  ///
  void onUserDidForbidByServer();

  ///
  /// 用户密码变更回调。
  ///
  void onUserDidChangePassword();

  ///
  /// 登录设备过多回调。
  ///
  void onUserDidLoginTooManyDevice();

  ///
  /// 被其他设备踢掉回调。
  ///
  void onUserKickedByOtherDevice();

  ///
  /// 鉴权失败回调。
  ///
  void onUserAuthenticationFailed();

  ///
  /// Agora token 即将过期时触发。
  ///
  void onTokenWillExpire();

  ///
  /// Agora token 已过期时触发。
  ///
  void onTokenDidExpire();
}

///
/// 多设备事件监听器。
///
/// 该监听器监听联系人事件和群组事件。
///
abstract class EMMultiDeviceListener {
  ///
  /// 联系人事件监听回调。
  ///
  /// Param [event] 事件类型。
  ///
  /// Param [username]用户 ID。
  ///
  /// Param [ext] 用户相关的扩展信息。
  ///
  void onContactEvent(
    EMMultiDevicesEvent event,
    String username,
    String? ext,
  );

  ///
  /// 群组事件监听回调。
  ///
  /// Param [event] 事件类型。
  ///
  /// Param [groupId]  群组 ID。
  ///
  /// Param [usernames] 用户 ID 数组。
  ///
  void onGroupEvent(
    EMMultiDevicesEvent event,
    String groupId,
    List<String>? usernames,
  );

  ///
  /// 子区事件监听回调。
  ///
  /// Param [event] 事件类型。
  ///
  /// Param [chatThreadId] 子区 id
  ///
  /// Param [usernames] 用户 ID 数组。
  ///
  void onChatThreadEvent(
    EMMultiDevicesEvent event,
    String chatThreadId,
    List<String> usernames,
  );
}

///
///   自定义事件监听器。
///
abstract class EMCustomListener {
  void onDataReceived(Map map);
}

///
/// 联系人更新监听。
///
/// 监听联系人变化，包括添加好友，移除好友，同意好友请求和拒绝好友请求等。
///
/// 添加监听：
/// ```dart
///   EMClient.getInstance.contactManager.addContactManagerListener(contactListener);
/// ```
///
/// 移除监听：
/// ```dart
///   EMClient.getInstance.contactManager.removeContactManagerListener(contactListener);
/// ```
///
abstract class EMContactManagerListener {
  ///
  /// 添加好友回调。
  ///
  /// Param [userName] 新添加的好友。
  ///
  void onContactAdded(String userName);

  ///
  /// 删除好友回调。
  ///
  /// Param [userName] 删除的好友。
  ///
  void onContactDeleted(String userName);

  ///
  /// 好友申请回调
  ///
  /// Param [userName] 申请用户id。
  ///
  /// Param [reason] 申请原因。
  ///
  void onContactInvited(String userName, String? reason);

  ///
  /// 发出的好友申请被对方同意。
  ///
  /// Param [userName] 对方id。
  ///
  void onFriendRequestAccepted(String userName);

  ///
  /// 发出的好友申请被对方拒绝。
  ///
  /// Param [userName] 对方id。
  ///
  void onFriendRequestDeclined(String userName);
}

///
/// 聊天室监听。
///
/// 添加监听：
/// ```dart
///   EMClient.getInstance.chatRoomManager.addChatRoomManagerListener(listener);
/// ```
///
/// 移除监听：
/// ```dart
///   EMClient.getInstance.chatRoomManager.removeChatRoomManagerListener(listener);
/// ```
///
/// Register the listener：
/// ```dart
///   EMClient.getInstance.chatRoomManager.addChatRoomManagerListener(listener);
/// ```
///
/// Unregister the listener：
/// ```dart
///   EMClient.getInstance.chatRoomManager.removeChatRoomManagerListener(listener);
/// ```
///

abstract class EMChatRoomManagerListener {
  ///
  /// 聊天室解散的回调。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [roomName] 聊天室名称。
  ///
  void onChatRoomDestroyed(String roomId, String? roomName);

  ///
  /// 聊天室加入新成员回调。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [participant] 新成员用户 ID。
  ///
  void onMemberJoinedFromChatRoom(String roomId, String participant);

  ///
  /// 聊天室成员主动退出回调。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [participant] 离开聊天室的用户 ID。
  ///
  void onMemberExitedFromChatRoom(
    String roomId,
    String? roomName,
    String participant,
  );

  ///
  /// 聊天室成员被移出聊天室回调。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [roomName] 聊天室名称。
  ///
  /// Param [participant] 被移出聊天室的用户 ID。
  ///
  void onRemovedFromChatRoom(
    String roomId,
    String? roomName,
    String? participant,
  );

  ///
  /// 有成员被禁言回调。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [mutes] 被禁言成员的用户 ID。
  ///
  /// Param [expireTime] 禁言过期时间戳。
  ///
  void onMuteListAddedFromChatRoom(
    String roomId,
    List<String> mutes,
    String? expireTime,
  );

  ///
  /// 有成员从禁言列表中移除回调。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [mutes] 被移出禁言列表的用户 ID 列表。
  ///
  void onMuteListRemovedFromChatRoom(
    String roomId,
    List<String> mutes,
  );

  ///
  /// 有成员设置为聊天室管理员的回调。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [admin] 设置为管理员的成员的用户 ID。
  ///
  void onAdminAddedFromChatRoom(String roomId, String admin);

  ///
  /// 移除聊天室管理员权限的回调。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [admin] 被移出管理员权限的成员的用户 ID。
  ///
  void onAdminRemovedFromChatRoom(String roomId, String admin);

  ///
  /// 转移聊天室的所有权的回调。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [newOwner] 新聊天室所有者的用户 ID。
  ///
  /// Param [oldOwner] 原来的聊天室所有者的用户 ID。
  ///
  void onOwnerChangedFromChatRoom(
      String roomId, String newOwner, String oldOwner);

  ///
  /// 聊天室公告更新回调。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [announcement] 更新后的聊天室公告。
  ///
  void onAnnouncementChangedFromChatRoom(String roomId, String announcement);

  ///
  /// 有成员被加入聊天室白名单的回调。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [members] 被加入白名单的聊天室成员的用户 ID。
  ///
  void onAllowListAddedFromChatRoom(String roomId, List<String> members);

  ///
  /// 有成员被移出聊天室白名单的回调。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [members] 被移出聊天室白名单列表的成员的用户 ID。
  ///
  void onAllowListRemovedFromChatRoom(String roomId, List<String> members);

  ///
  /// 聊天室全员禁言状态变化回调。
  ///
  /// Param [roomId] 聊天室 ID。
  ///
  /// Param [isAllMuted] 是否所有聊天室成员被禁言。
  /// - `true`: 是；
  /// - `false`: 否。
  ///
  void onAllChatRoomMemberMuteStateChanged(String roomId, bool isAllMuted);
}

///
/// 群组事件监听器。
///
/// 添加监听器:
/// ```dart
///   EMClient.getInstance.groupManager.addGroupManagerListener(listener);
/// ```
///
/// 移除监听器:
/// ```dart
///   EMClient.getInstance.groupManager.removeGroupManagerListener(listener);
/// ```
///
abstract class EMGroupManagerListener {
  ///
  /// 当前用户收到入群邀请的回调。
  ///
  /// 例如，用户 B 邀请用户 A 入群，则用户 A 会收到该回调。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [groupName] 群组名称。
  ///
  /// Param [inviter] 邀请人的用户 ID。
  ///
  /// Param [reason] 邀请理由。
  ///
  void onInvitationReceivedFromGroup(
      String groupId, String? groupName, String inviter, String? reason);

  ///
  /// 对端用户接收群组申请的回调。
  ///
  /// 该回调是由对端用户接收当前用户发送的群组申请触发的。如，用户 A 向用户 B 发送群组申请，用户 B 收到该回调。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [groupName] 群组名称。
  ///
  /// Param [applicant] 申请人的用户 ID。
  ///
  /// Param [reason] 申请加入原因。
  ///
  void onRequestToJoinReceivedFromGroup(
      String groupId, String? groupName, String applicant, String? reason);

  ///
  /// 对端用户接受当前用户发送的群组申请的回调。
  ///
  /// 若群组类型为 `PublicJoinNeedApproval`，用户 B 接受用户 A 的群组申请后，用户 A 会收到该回调。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [groupName] 群组名称。
  ///
  /// Param [accepter] 接受人的用户 ID。
  ///
  void onRequestToJoinAcceptedFromGroup(
      String groupId, String? groupName, String accepter);

  ///
  /// 对端用户拒绝群组申请的回调。
  ///
  /// 该回调是由对端用户拒绝当前用户发送的群组申请触发的。例如，用户 B 拒绝用户 A 的群组申请后，用户 A 会收到该回调。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [groupName] 群组名称。
  ///
  /// Param [decliner] 拒绝人的用户 ID。
  ///
  /// Param [reason] 拒绝理由。
  ///
  void onRequestToJoinDeclinedFromGroup(
    String groupId,
    String? groupName,
    String decliner,
    String? reason,
  );

  ///
  /// 当前用户收到对端用户同意入群邀请触发的回调。
  ///
  /// 例如，用户 B 同意了用户 A 的群组邀请，用户 A 会收到该回调。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [invitee] 受邀人的用户 ID。
  ///
  /// Param [reason] 接受理由。
  ///
  void onInvitationAcceptedFromGroup(
    String groupId,
    String invitee,
    String? reason,
  );

  ///
  /// 当前用户收到群组邀请被拒绝的回调。
  ///
  /// 该回调是由当前用户收到对端用户拒绝入群邀请触发的。例如，用户 B 拒绝了用户 A 的群组邀请，用户 A 会收到该回调。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [invitee] 受邀人的用户 ID。
  ///
  /// Param [reason] 拒绝理由。
  ///
  void onInvitationDeclinedFromGroup(
      String groupId, String invitee, String? reason);

  ///
  /// 当前用户被移出群组时的回调。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [groupName] 群组名称。
  ///
  void onUserRemovedFromGroup(String groupId, String? groupName);

  ///
  /// 当前用户收到群组被解散的回调。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [groupName] 群组名称。
  ///
  void onGroupDestroyed(String groupId, String? groupName);

  ///
  /// 当前用户自动同意入群邀请的回调。
  /// 具体配置,参考 {@link EMOptions#autoAcceptGroupInvitation(boolean value)}.
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [inviter] 邀请人 ID。
  ///
  /// Param [inviteMessage] 邀请信息。
  ///
  void onAutoAcceptInvitationFromGroup(
      String groupId, String inviter, String? inviteMessage);

  ///
  /// 有成员被禁言回调
  ///
  /// 用户禁言后，将无法在群中发送消息，但可查看群组中的消息，而黑名单中的用户无法查看和发送群组消息。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [mutes] 被禁言成员的用户 ID。
  ///
  /// Param [muteExpire] 禁言时长。
  ///
  void onMuteListAddedFromGroup(
      String groupId, List<String> mutes, int? muteExpire);

  ///
  /// 有成员被解除禁言的回调。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [mutes] 用户被解除禁言的列表
  ///
  void onMuteListRemovedFromGroup(String groupId, List<String> mutes);

  ///
  /// 成员设置为管理员的回调。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [admin] 设置为管理员的成员的用户 ID。
  ///
  void onAdminAddedFromGroup(String groupId, String admin);

  ///
  /// 取消成员的管理员权限的回调。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [admin] 被移除管理员的成员用户 ID。
  ///
  void onAdminRemovedFromGroup(String groupId, String admin);

  ///
  /// 转移群主权限的回调。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [newOwner] 新群主的用户 ID。
  ///
  /// Param [oldOwner] 原群主的用户 ID。
  ///
  void onOwnerChangedFromGroup(
      String groupId, String newOwner, String oldOwner);

  ///
  /// 新成员加入群组的回调。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [member] 新成员的用户 ID。
  ///
  void onMemberJoinedFromGroup(String groupId, String member);

  ///
  /// 群组成员主动退出回调。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [member] 退群的成员的用户 ID。
  ///
  void onMemberExitedFromGroup(String groupId, String member);

  ///
  /// 群公告更新回调。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [announcement] 新公告。
  ///
  void onAnnouncementChangedFromGroup(String groupId, String announcement);

  ///
  /// 群组添加共享文件回调。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [sharedFile] 添加的共享文件的 ID。
  ///
  void onSharedFileAddedFromGroup(String groupId, EMGroupSharedFile sharedFile);

  ///
  ///  群组删除共享文件回调。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [fileId] 被删除的群共享文件 ID。
  ///
  void onSharedFileDeletedFromGroup(String groupId, String fileId);

  ///
  /// 成员加入群组白名单回调。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [members] 被加入白名单的成员的用户 ID。
  ///
  void onAllowListAddedFromGroup(String groupId, List<String> members);

  ///
  /// 成员移出群组白名单回调。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [members] 移出白名单的成员的用户 ID。
  ///
  void onAllowListRemovedFromGroup(String groupId, List<String> members);

  ///
  /// 全员禁言状态变化回调。
  ///
  /// Param [groupId] 群组 ID。
  ///
  /// Param [isAllMuted] 是否全员禁言。
  /// - `true`：是；
  /// - `false`：否。
  ///
  void onAllGroupMemberMuteStateChanged(String groupId, bool isAllMuted);
}

///
/// 消息事件监听器。
///
/// 该监听器用于监听消息变更：
///
/// - 消息成功发送到对方后，发送方会收到送达回执（需开启送达回执功能，详见 {@link EMOptions#requireDeliveryAck(boolean)}。
///
/// - 对方阅读了这条消息，发送方会收到已读回执（需开启已读回执功能，详见 {@link EMOptions#requireAck(boolean)}。
///
/// 添加消息事件监听器：
/// ```dart
///   EMClient.getInstance.chatManager.addChatManagerListener(listener);
/// ```
///
/// 移除消息事件监听器：
/// ```dart
///   EMClient.getInstance.chatManager.removeChatManagerListener(listener);
/// ```
///
abstract class EMChatManagerListener {
  ///
  /// 收到消息回调。
  ///
  /// 在收到文本、图片、视频、语音、地理位置和文件等消息时，通过此回调通知用户。
  ///
  /// Param [messages] 收到的消息。
  ///
  void onMessagesReceived(List<EMMessage> messages) {}

  ///
  /// 收到命令消息回调。
  ///
  /// 与 {@link #onMessagesReceived(List<EMMessage> messages)} 不同, 这个回调只包含命令的消息，命令消息通常不对用户展示。
  ///
  /// Param [messages] 收到的命令消息。
  ///
  void onCmdMessagesReceived(List<EMMessage> messages) {}

  ///
  /// 收到单聊消息已读回执的回调。
  ///
  /// Param [messages] 消息的已读回执。
  ///
  void onMessagesRead(List<EMMessage> messages) {}

  ///
  /// 收到群组消息的已读回执的回调。
  ///
  /// Param [groupMessageAcks] 收到群组消息的已读回执的回调。
  ///
  void onGroupMessageRead(List<EMGroupMessageAck> groupMessageAcks) {}

  ///
  /// 群消息已读变更。
  ///
  void onReadAckForGroupMessageUpdated() {}

  ///
  ///  收到消息已送达回执的回调。
  ///
  /// Param [messages] 送达回执对应的消息。
  ///
  void onMessagesDelivered(List<EMMessage> messages) {}

  ///
  /// 已收到的消息被撤回的回调。
  ///
  /// Param [messages]  撤回的消息。
  ///
  void onMessagesRecalled(List<EMMessage> messages) {}

  ///
  /// 会话更新事件回调。
  ///
  void onConversationsUpdate() {}

  ///
  /// 收到会话已读回执的回调。
  ///
  /// 回调此方法的场景：
  /// （1）消息被接收方阅读，即接收方发送了会话已读回执。
  /// SDK 在接收到此事件时，会将本地数据库中该会话中消息的 `isAcked` 属性置为 `true`。
  /// （2）多端多设备登录场景下，一端发送会话已读回执，服务器端会将会话的未读消息数置为 0，
  /// 同时其他端会回调此方法，并将本地数据库中该会话中消息的 `isRead` 属性置为 `true`。
  ///
  /// Param [from] 发送已读回执的用户 ID。
  ///
  /// Param [to] 收到已读回执的用户 ID。
  ///
  void onConversationRead(String from, String to) {}

  ///
  ///  消息表情回复（Reaction）变化监听器。
  ///
  /// Param [list]  Reaction 变化事件。
  ///
  void onMessageReactionDidChange(List<EMMessageReactionEvent> list) {}
}

///
/// 在线状态订阅监听器接口。
///
class EMPresenceManagerListener {
  ///
  /// 收到被订阅用户的在线状态发生变化。
  ///
  /// Param [list] 被订阅用户更新后的在线状态。
  ///
  void onPresenceStatusChanged(List<EMPresence> list) {}
}

///
/// 子区监听类
///
/// 添加子区监听:
/// EMClient.getInstance.chatThreadManager.addChatThreadManagerListener(listener);
///
/// 移除子区监听:
/// EMClient.getInstance.chatThreadManager.removeChatThreadManagerListener(listener);
///
class EMChatThreadManagerListener {
  ///
  /// 子区创建回调。
  ///
  /// 子区所属群组的所有成员均可调用该方法。
  ///
  /// Param [event] 子区事件。
  ///
  /// Param [event] The event;
  ///
  void onChatThreadCreate(EMChatThreadEvent event) {}

  ///
  /// 子区更新回调。
  ///
  /// 子区所属群组的所有成员均可调用该方法。
  ///
  /// Param [event] 子区事件。
  ///
  /// Param [event] The event;
  ///
  void onChatThreadUpdate(EMChatThreadEvent event) {}

  ///
  /// 子区解散事件。
  ///
  /// 子区所属群组的所有成员均可调用该方法。
  ///
  /// Param [event] 子区事件。
  ///
  /// Param [event] The event;
  ///
  void onChatThreadDestroy(EMChatThreadEvent event) {}

  ///
  /// 管理员移除子区用户的回调。
  ///
  /// Param [event] 子区事件。
  ///
  /// Param [event] The event;
  ///
  void onUserKickOutOfChatThread(EMChatThreadEvent event) {}
}
