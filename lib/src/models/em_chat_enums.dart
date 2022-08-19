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
  /// 按消息中的时间戳的倒序搜索。
  Up,

  /// 按消息中的时间戳的顺序搜索。
  Down,
}

///
/// 多设备登录事件类型。
///
/// 本枚举类以用户 A 同时登录设备 A1 和 设备 A2 为例，描述多设备登录各事件的触发时机。
///
enum EMMultiDevicesEvent {
  /// 用户 A 在设备 A1 上删除了好友，则设备 A2 上会收到该事件。
  CONTACT_REMOVE,

  /// 用户 A 在设备 A1 上同意了好友请求，则设备 A2 上会收到该事件。
  CONTACT_ACCEPT,

  /// 用户 A 在设备 A1 上拒绝了好友请求，则设备 A2 上会收到该事件。
  CONTACT_DECLINE,

  /// 用户 A 在设备 A1 上将其他用户加入了黑名单，则设备 A2 上会收到该事件。
  CONTACT_BAN,

  /// 用户 A 在设备 A1 上将其他用户移出了黑名单，则设备 A2 上会收到该事件。
  CONTACT_ALLOW,

  /// 用户 A 在设备 A1 上创建了群组，则设备 A2 上会收到该事件。
  GROUP_CREATE,

  /// 用户 A 在设备 A1 上销毁了群组，则设备 A2 上会收到该事件。
  GROUP_DESTROY,

  /// 用户 A 在设备 A1 上加入了群组，则设备 A2 会收到该事件。
  GROUP_JOIN,

  /// 用户 A 在设备 A1 上退出群组，则设备 A2 会收到该事件。
  GROUP_LEAVE,

  /// 用户 A 在设备 A1 上申请加入群组，则设备 A2 会收到该事件。
  GROUP_APPLY,

  /// 用户 A 在设备 A1 上收到了入群申请，则设备 A2 会收到该事件。
  GROUP_APPLY_ACCEPT,

  /// 用户 A 在设备 A1 上拒绝了入群申请，设备 A2 上会收到该事件。
  GROUP_APPLY_DECLINE,

  /// 用户 A 在设备 A1 上邀请了其他用户进入群组，则设备 A2 上会收到该事件。
  GROUP_INVITE,

  /// 用户 A 在设备 A1 上同意了其他用户的群组邀请，则设备 A2 上会收到该事件。
  GROUP_INVITE_ACCEPT,

  /// 用户 A 在设备 A1 上拒绝了其他用户的群组邀请，则设备 A2 上会收到该事件。
  GROUP_INVITE_DECLINE,

  /// 用户 A 在设备 A1 上将其他用户踢出群组，则设备 A2 上会收到该事件。
  GROUP_KICK,

  /// 用户 A 在设备 A1 上被加入黑名单，则设备 A2 上会收到该事件。
  GROUP_BAN,

  /// 用户 A 在设备 A1 上将其他用户移出群组，则设备 A2 上会收到该事件。
  GROUP_ALLOW,

  /// 用户 A 在设备 A1 上屏蔽了某个群组的消息，设备 A2 上会收到该事件。
  GROUP_BLOCK,

  /// 用户 A 在设备 A1 上取消屏蔽了某个群组的消息，设备 A2 上会收到该事件。
  GROUP_UNBLOCK,

  /// 用户 A 在设备 A1 上更新了群主，则设备 A2 上会收到该事件。
  GROUP_ASSIGN_OWNER,

  /// 用户 A 在设备 A1 上添加了群组管理员，则设备 A2 上会收到该事件。
  GROUP_ADD_ADMIN,

  /// 用户 A 在设备 A1 上移除了群组管理员，则设备 A2 上会收到该事件。
  GROUP_REMOVE_ADMIN,

  /// 用户 A 在设备 A1 上禁言了群成员，则设备 A2 上会收到该事件。
  GROUP_ADD_MUTE,

  /// 用户 A 在设备 A1 上取消禁言了群成员，则设备 A2 上会收到该事件。
  GROUP_REMOVE_MUTE,

  /// 用户 A 在设备 A1 上将其他成员添加到群组白名单中，则设备 A2 上会收到该事件。
  GROUP_ADD_USER_WHITE_LIST,

  /// 用户 A 在设备 A1 上将其他成员移除群组白名单，则设备 A2 上会收到该事件。
  GROUP_REMOVE_USER_WHITE_LIST,

  /// 用户 A 在设备 A1 上将所有其他群组成员添加到群组禁言列表，则设备 A2 上会收到该事件。
  GROUP_ALL_BAN,

  /// 用户 A 在设备 A1 上将所有其他群组成员移除群组禁言列表，则设备 A2 上会收到该事件。
  GROUP_REMOVE_ALL_BAN,

  /// 当前用户的群组功能被关闭事件。
  GROUP_DISABLED,

  /// 当前用户的群组功能开启事件。
  GROUP_ABLE,

  /// 用户 A 在设备 A1 上创建了子区，则设备 A2 上会收到该事件。
  CHAT_THREAD_CREATE,

  /// 用户 A 在设备 A1 上移除了子区，则设备 A2 上会收到该事件。
  CHAT_THREAD_DESTROY,

  /// 用户 A 在设备 A1 上加入了子区，则设备 A2 上会收到该事件。
  CHAT_THREAD_JOIN,

  /// 用户 A 在设备 A1 上离开了子区，则设备 A2 上会收到该事件。
  CHAT_THREAD_LEAVE,

  /// 用户 A 在设备 A1 上更新了子区信息，则设备 A2 上会收到该事件。
  CHAT_THREAD_UPDATE,

  /// 用户 A 在设备 A1 上将其他用户踢出子区，则设备 A2 上会收到该事件。
  CHAT_THREAD_KICK,
}

///

/// 子区事件类型枚举。
///
enum EMChatThreadOperation {
  /// 未知类型。
  UnKnown,

  /// 子区创建。
  Create,

  /// 子区更新。
  Update,

  /// 子区删除。
  Delete,

  /// 更新子区最新一条消息。
  Update_Msg,
}

///
/// 推送通知展示方式。
///
enum DisplayStyle {
  /// 显示通用标题，如 “您有一条新消息”。
  Simple,

  /// 显示离线消息的内容。
  Summary,
}

///
/// 离线消息推送参数枚举
///
enum ChatSilentModeParamType {
  /// 免打扰类型
  REMIND_TYPE,

  /// 免打扰持续时间
  SILENT_MODE_DURATION,

  /// 免打扰时间段
  SILENT_MODE_INTERVAL,
}

/// 离线消息推送通知枚举
enum ChatPushRemindType {
  /// 所有消息都有推送
  ALL,

  /// 只有@我的消息才推送
  MENTION_ONLY,

  /// 所有消息都不推送
  NONE,
}
