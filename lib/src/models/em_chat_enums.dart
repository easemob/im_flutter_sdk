///
/// 群组类型枚举。
///
enum EMGroupStyle {
  /// 私有群组，创建完成后，只允许群主邀请用户加入。
  PrivateOnlyOwnerInvite,

  /// 私有群组，创建完成后，只允许群主和群成员邀请用户加入。
  PrivateMemberCanInvite,

  /// 公开群组，创建完成后，只允许群主邀请用户加入；非群成员用户需发送入群申请，群主同意后才能入群。
  PublicJoinNeedApproval,

  /// 公开群组，创建完成后，允许非群组成员加入，无需群主同意。
  PublicOpenJoin,
}

/// 会话类型枚举。
enum EMConversationType {
  /// 单聊。
  Chat,

  /// 群聊。
  GroupChat,

  /// 聊天室。
  ChatRoom,
}

@Deprecated('Switch to using EMPushManager#DisplayStyle instead')
enum EMPushStyle {
  Simple,
  Summary,
}

///
/// 会话类型枚举。
///
enum ChatType {
  /// 单聊。
  Chat,

  /// 群聊。
  GroupChat,

  /// 聊天室。
  ChatRoom,
}

///
/// 消息的方向类型枚举类。
///
/// 区分是发送消息还是接收到的消息。
///
enum MessageDirection {
  /// 该消息是当前用户发送出去的。
  SEND,

  /// 该消息是当前用户接收到的。
  RECEIVE,
}

///
/// 消息的发送/接收状态枚举类。
///
enum MessageStatus {
  /// 消息已创建待发送。
  CREATE,

  /// 正在发送/接收。
  PROGRESS,

  /// 发送/接收成功。
  SUCCESS,

  /// 发送/接收失败。
  FAIL,
}

///
/// 消息附件的下载状态。
///
enum DownloadStatus {
  /// 等待下载。
  PENDING,

  /// 正在下载。
  DOWNLOADING,

  /// 下载成功。
  SUCCESS,

  /// 下载失败。
  FAILED,
}

///
/// 消息类型枚举。
///
enum MessageType {
  /// 文本消息。
  TXT,

  /// 图片消息。
  IMAGE,

  /// 视频消息。
  VIDEO,

  /// 位置消息。
  LOCATION,

  /// 语音消息。
  VOICE,

  /// 文件消息。
  FILE,

  /// 命令消息。
  CMD,

  /// 自定义消息。
  CUSTOM,
}

///
/// 群组角色类型枚举。
///
enum EMGroupPermissionType {
  /// 未知类型。
  None,

  /// 群组成员。
  Member,

  /// 群管理员。
  Admin,

  /// 群主。
  Owner,
}

///
/// 聊天室角色类型枚举。
///
enum EMChatRoomPermissionType {
  /// 未知类型。
  None,

  /// 普通成员。
  Member,

  /// 聊天室管理员。
  Admin,

  /// 聊天室所有者。
  Owner,
}

///
/// 消息检索方向类型枚举。
///
enum EMSearchDirection {
  /// 从新往旧检索（一般是根据消息的服务器时间）。
  Up,

  /// 从旧往新检索（一般是根据消息的服务器时间）。
  Down,
}

///
/// Multi-device event types.
///
/// This enumeration takes user A logged into both DeviceA1 and DeviceA2 as an example to illustrate the various multi-device event types and when these events are triggered.
///
enum EMMultiDevicesEvent {
  /// The current user removed a contact on another device.
  CONTACT_REMOVE,

  /// The current user accepted a friend request on another device.
  CONTACT_ACCEPT,

  /// The current user declined a friend request on another device.
  CONTACT_DECLINE,

  /// The current user added a contact to the block list on another device.
  CONTACT_BAN,

  /// The current user removed a contact from the block list on another device.
  CONTACT_ALLOW,

  /// The current user created a group on another device.
  GROUP_CREATE,

  /// The current user destroyed a group on another device.
  GROUP_DESTROY,

  /// The current user joined a group on another device.
  GROUP_JOIN,

  /// The current user left a group on another device.
  GROUP_LEAVE,

  /// The current user requested to join a group on another device.
  GROUP_APPLY,

  /// The current user accepted a group request on another device.
  GROUP_APPLY_ACCEPT,

  /// The current user declined a group request on another device.
  GROUP_APPLY_DECLINE,

  /// The current user invited a user to join the group on another device.
  GROUP_INVITE,

  /// The current user accepted a group invitation on another device.
  GROUP_INVITE_ACCEPT,

  /// The current user declined a group invitation on another device.
  GROUP_INVITE_DECLINE,

  /// The current user kicked a member out of a group on another device.
  GROUP_KICK,

  /// The current user added a member to a group block list on another device.
  GROUP_BAN,

  /// The current user removed a member from a group block list on another device.
  GROUP_ALLOW,

  /// The current user blocked a group on another device.
  GROUP_BLOCK,

  /// The current user unblocked a group on another device.
  GROUP_UNBLOCK,

  /// The current user transferred the group ownership on another device.
  GROUP_ASSIGN_OWNER,

  /// The current user added an admin on another device.
  GROUP_ADD_ADMIN,

  /// The current user removed an admin on another device.
  GROUP_REMOVE_ADMIN,

  /// The current user muted a member on another device.
  GROUP_ADD_MUTE,

  /// The current user unmuted a member on another device.
  GROUP_REMOVE_MUTE,

  /// User A creates an event in the sub-area of device A1, and other devices logged in to this account will receive this event
  CHAT_THREAD_CREATE,

  /// User A destroys the event in the sub-area of device A1, and all other devices logged in to this account will receive this event
  CHAT_THREAD_DESTROY,

  /// User A joins the event in the sub-area of device A1, and other devices logged in to this account will receive this event
  CHAT_THREAD_JOIN,

  /// User A leaves the event in the sub-area of device A1, and other devices logged in to this account will receive this event
  CHAT_THREAD_LEAVE,

  /// User A is kicked in the sub-area of device A1, and all other devices that log in to this account will receive this event
  CHAT_THREAD_KICK,

  /// User A updates the event in the sub-area of device A1, and other devices logged in to this account will receive this event
  CHAT_THREAD_UPDATE,
}
enum EMChatThreadOperation {
  UnKnown,
  Create,
  Update,
  Delete,
  Update_Msg,
}
