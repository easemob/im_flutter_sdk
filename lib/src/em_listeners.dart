import "models/em_domain_terms.dart";

abstract class EMConnectionListener {
  /// 网络已连接
  void onConnected();

  /// 连接失败，原因是[errorCode]
  void onDisconnected(int? errorCode);
}

/// @nodoc
abstract class EMMultiDeviceListener {
  /// @nodoc
  void onContactEvent(EMContactGroupEvent? event, String? target, String? ext);

  /// @nodoc
  void onGroupEvent(
      EMContactGroupEvent? event, String? target, List<String>? usernames);
}

/// @nodoc
enum EMContactGroupEvent {
  CONTACT_REMOVE,
  CONTACT_ACCEPT,
  CONTACT_DECLINE,
  CONTACT_BAN,
  CONTACT_ALLOW,
  GROUP_CREATE,
  GROUP_DESTROY,
  GROUP_JOIN,
  GROUP_LEAVE,
  GROUP_APPLY,
  GROUP_APPLY_ACCEPT,
  GROUP_APPLY_DECLINE,
  GROUP_INVITE,
  GROUP_INVITE_ACCEPT,
  GROUP_INVITE_DECLINE,
  GROUP_KICK,
  GROUP_BAN,
  GROUP_ALLOW,
  GROUP_BLOCK,
  GROUP_UNBLOCK,
  GROUP_ASSIGN_OWNER,
  GROUP_ADD_ADMIN,
  GROUP_REMOVE_ADMIN,
  GROUP_ADD_MUTE,
  GROUP_REMOVE_MUTE,
}

abstract class EMContactEventListener {
  /// 被[userName]添加为好友
  void onContactAdded(String? userName);

  /// 被[userName]从好友中删除
  void onContactDeleted(String? userName);

  /// 收到[userName]的好友申请，原因是[reason]
  void onContactInvited(String? userName, String? reason);

  /// 发出的好友申请被[userName]同意
  void onFriendRequestAccepted(String? userName);

  /// 发出的好友申请被[userName]拒绝
  ///
  void onFriendRequestDeclined(String? userName);
}

abstract class EMConversationListener {
  void onConversationUpdate();
}

/// @nodoc
class EMChatRoomEvent {
  static const String ON_CHAT_ROOM_DESTROYED = "onChatRoomDestroyed";
  static const String ON_MEMBER_JOINED = "onMemberJoined";
  static const String ON_MEMBER_EXITED = "onMemberExited";
  static const String ON_REMOVED_FROM_CHAT_ROOM = "onRemovedFromChatRoom";
  static const String ON_MUTE_LIST_ADDED = "onMuteListAdded";
  static const String ON_MUTE_LIST_REMOVED = "onMuteListRemoved";
  static const String ON_ADMIN_ADDED = "onAdminAdded";
  static const String ON_ADMIN_REMOVED = "onAdminRemoved";
  static const String ON_OWNER_CHANGED = "onOwnerChanged";
  static const String ON_ANNOUNCEMENT_CHANGED = "onAnnouncementChanged";
}

abstract class EMChatRoomEventListener {
  /// id是[roomId],名称是[roomName]的聊天室被销毁
  void onChatRoomDestroyed(String? roomId, String? roomName);

  /// 有用户[participant]加入id是[roomId]的聊天室
  void onMemberJoinedFromChatRoom(String? roomId, String? participant);

  /// 有用户[participant]离开id是[roomId]，名字是[roomName]的聊天室
  void onMemberExitedFromChatRoom(
      String? roomId, String? roomName, String? participant);

  /// 用户[participant]被id是[roomId],名称[roomName]的聊天室删除
  void onRemovedFromChatRoom(
      String? roomId, String? roomName, String? participant);

  /// @nodoc id是[roomId]的聊天室禁言列表[mutes]有增加
  void onMuteListAddedFromChatRoom(
      String? roomId, List? mutes, String? expireTime);

  /// @nodoc id是[roomId]的聊天室禁言列表[mutes]有减少
  void onMuteListRemovedFromChatRoom(String? roomId, List? mutes);

  /// @nodoc id是[roomId]的聊天室增加id是[admin]管理员
  void onAdminAddedFromChatRoom(String? roomId, String? admin);

  /// @nodoc id是[roomId]的聊天室移除id是[admin]管理员
  void onAdminRemovedFromChatRoom(String? roomId, String? admin);

  /// @nodoc id是[roomId]的聊天室所有者由[oldOwner]变更为[newOwner]
  void onOwnerChangedFromChatRoom(
      String? roomId, String? newOwner, String? oldOwner);

  /// @nodoc id是[roomId]的聊天室公告变为[announcement]
  void onAnnouncementChangedFromChatRoom(String? roomId, String? announcement);
}

/// @nodoc
class EMGroupChangeEvent {
  static const String ON_INVITATION_RECEIVED = "onInvitationReceived";
  static const String ON_INVITATION_ACCEPTED = "onInvitationAccepted";
  static const String ON_INVITATION_DECLINED = "onInvitationDeclined";
  static const String ON_AUTO_ACCEPT_INVITATION =
      "onAutoAcceptInvitationFromGroup";
  static const String ON_USER_REMOVED = "onUserRemoved";
  static const String ON_REQUEST_TO_JOIN_RECEIVED = "onRequestToJoinReceived";
  static const String ON_REQUEST_TO_JOIN_DECLINED = "onRequestToJoinDeclined";
  static const String ON_REQUEST_TO_JOIN_ACCEPTED = "onRequestToJoinAccepted";
  static const String ON_GROUP_DESTROYED = "onGroupDestroyed";
  static const String ON_MUTE_LIST_ADDED = "onMuteListAdded";
  static const String ON_MUTE_LIST_REMOVED = "onMuteListRemoved";
  static const String ON_ADMIN_ADDED = "onAdminAdded";
  static const String ON_ADMIN_REMOVED = "onAdminRemoved";
  static const String ON_OWNER_CHANGED = "onOwnerChanged";
  static const String ON_MEMBER_JOINED = "onMemberJoined";
  static const String ON_MEMBER_EXITED = "onMemberExited";
  static const String ON_ANNOUNCEMENT_CHANGED = "onAnnouncementChanged";
  static const String ON_SHARED_FILE_ADDED = "onSharedFileAdded";
  static const String ON_SHARED_FILE__DELETED = "onSharedFileDeleted";
}

abstract class EMGroupChangeListener {
  /// id是[groupId], 名称是[groupName]的群邀请被[inviter]拒绝,理由是[reason]
  void onInvitationReceivedFromGroup(
      String? groupId, String? groupName, String? inviter, String? reason);

  /// 收到用户[applicant]申请加入id是[groupId], 名称是[groupName]的群，原因是[reason]
  void onRequestToJoinReceivedFromGroup(
      String? groupId, String? groupName, String? applicant, String? reason);

  /// 入群申请被同意
  void onRequestToJoinAcceptedFromGroup(
      String? groupId, String? groupName, String? accepter);

  /// 入群申请被拒绝
  void onRequestToJoinDeclinedFromGroup(
      String? groupId, String? groupName, String? decliner, String? reason);

  /// 入群邀请被同意
  void onInvitationAcceptedFromGroup(
      String? groupId, String? invitee, String? reason);

  /// 入群邀请被拒绝
  void onInvitationDeclinedFromGroup(
      String? groupId, String? invitee, String? reason);

  /// 被移出群组
  void onUserRemovedFromGroup(String? groupId, String? groupName);

  /// 群组解散
  void onGroupDestroyed(String? groupId, String? groupName);

  /// @nodoc 自动同意加群
  void onAutoAcceptInvitationFromGroup(
      String? groupId, String? inviter, String? inviteMessage);

  /// 群禁言列表增加
  void onMuteListAddedFromGroup(String? groupId, List? mutes, int? muteExpire);

  /// 群禁言列表减少
  void onMuteListRemovedFromGroup(String? groupId, List? mutes);

  /// 群管理增加
  void onAdminAddedFromGroup(String? groupId, String? administrator);

  /// 群管理被移除
  void onAdminRemovedFromGroup(String? groupId, String? administrator);

  /// 群所有者变更
  void onOwnerChangedFromGroup(
      String? groupId, String? newOwner, String? oldOwner);

  /// 有用户加入群
  void onMemberJoinedFromGroup(String? groupId, String? member);

  /// 有用户离开群
  void onMemberExitedFromGroup(String? groupId, String? member);

  /// 群公告变更
  void onAnnouncementChangedFromGroup(String? groupId, String? announcement);

  /// 群共享文件增加
  void onSharedFileAddedFromGroup(
      String? groupId, EMGroupSharedFile sharedFile);

  /// 群共享文件被删除
  void onSharedFileDeletedFromGroup(String? groupId, String? fileId);
}
