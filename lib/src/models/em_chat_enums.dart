/// ~english
/// The enumeration of group types.
/// ~end
///
/// ~chinese
/// 群组类型枚举。
/// ~end
enum EMGroupStyle {
  /// ~english
  /// Private groups where only the the group owner can invite users to join.
  /// ~end
  ///
  /// ~chinese
  /// 私有群组，创建完成后，只允许群主邀请用户加入。
  /// ~end
  PrivateOnlyOwnerInvite,

  /// ~english
  /// Private groups where all group members can invite users to join.
  /// ~end
  ///
  /// ~chinese
  /// 私有群组，创建完成后，只允许群主和群成员邀请用户加入。
  /// ~end
  PrivateMemberCanInvite,

  /// ~english
  /// Public groups where users can join only after receiving an invitation from the group owner(admin) or the joining request being approved by the  group owner(admin).
  /// ~end
  ///
  /// ~chinese
  /// 公开群组，创建完成后，只允许群主邀请用户加入；非群成员用户需发送入群申请，群主同意后才能入群。
  /// ~end
  PublicJoinNeedApproval,

  /// ~english
  /// Public groups where users can join freely.
  /// ~end
  ///
  /// ~chinese
  /// 公开群组，创建完成后，允许非群组成员加入，无需群主同意。
  /// ~end
  PublicOpenJoin,
}

/// ~english
/// The conversation types.
/// ~end
///
/// ~chinese
/// 会话类型枚举。
/// ~end
enum EMConversationType {
  /// ~english
  /// One-to-one chat.
  /// ~end
  ///
  /// ~chinese
  /// 单聊。
  /// ~end
  Chat,

  /// ~english
  /// Group chat.
  /// ~end
  ///
  /// ~chinese
  /// 群聊。
  /// ~end
  GroupChat,

  /// ~english
  /// Chat room.
  /// ~end
  ///
  /// ~chinese
  /// 聊天室。
  /// ~end
  ChatRoom,
}

/// ~english
/// The enumeration of chat types.
///
/// There are three chat types: one-to-one chat, group chat, and chat room.
/// ~end
///
/// ~chinese
/// 会话类型枚举。
/// ~end
enum ChatType {
  /// ~english
  /// One-to-one chat.
  /// ~end
  ///
  /// ~chinese
  ///  单聊。
  /// ~end
  Chat,

  /// ~english
  /// Group chat.
  /// ~end
  ///
  /// ~chinese
  /// 群聊。
  /// ~end
  GroupChat,

  /// ~english
  /// Chat room.
  /// ~end
  ///
  /// ~chinese
  /// 聊天室。
  /// ~end
  ChatRoom,
}

/// ~english
/// The enumeration of the message directions.
///
/// Whether the message is sent or received.
/// ~end
///
/// ~chinese
/// 消息的方向类型枚举类。
///
/// 区分是发送消息还是接收到的消息。
/// ~end
enum MessageDirection {
  /// ~english
  /// This message is sent from the local user.
  /// ~end
  ///
  /// ~chinese
  /// 该消息是当前用户发送出去的。
  /// ~end
  SEND,

  /// ~english
  /// The message is received by the local user.
  /// ~end
  ///
  /// ~chinese
  /// 该消息是当前用户接收到的。
  /// ~end
  RECEIVE,
}

/// ~english
/// The enumeration of the message sending/reception status.
/// ~end
///
/// ~chinese
/// 消息的发送/接收状态枚举类。
/// ~end
enum MessageStatus {
  /// ~english
  /// The message is created.
  /// ~end
  ///
  /// ~chinese
  /// 消息已创建待发送。
  /// ~end
  CREATE,

  /// ~english
  /// The message is being delivered/received.
  /// ~end
  ///
  /// ~chinese
  /// 正在发送/接收。
  /// ~end
  PROGRESS,

  /// ~english
  /// The message is successfully delivered/received.
  /// ~end
  ///
  /// ~chinese
  /// 发送/接收成功。
  /// ~end
  SUCCESS,

  /// ~english
  /// The message fails to be delivered/received.
  /// ~end
  ///
  /// ~chinese
  /// 发送/接收失败。
  /// ~end
  FAIL,
}

/// ~english
/// The download status of the attachment file.
/// ~end
///
/// ~chinese
/// 消息附件的下载状态。
/// ~end
enum DownloadStatus {
  /// ~english
  /// The file message download is pending.
  /// ~end
  ///
  /// ~chinese
  /// 等待下载。
  /// ~end
  PENDING,

  /// ~english
  /// The file message is being downloaded.
  /// ~end
  ///
  /// ~chinese
  /// 正在下载。
  /// ~end
  DOWNLOADING,

  /// ~english
  /// The file message download succeeds.
  /// ~end
  ///
  /// ~chinese
  /// 下载成功。
  /// ~end
  SUCCESS,

  /// ~english
  /// The file message download fails.
  /// ~end
  ///
  /// ~chinese
  /// 下载失败。
  /// ~end
  FAILED,
}

/// ~english
/// The enumeration of message types.
/// ~end
///
/// ~chinese
/// 消息类型枚举。
/// ~end
enum MessageType {
  /// ~english
  /// The text message.
  /// ~end
  ///
  /// ~chinese
  /// 文本消息。
  /// ~end
  TXT,

  /// ~english
  /// The image message.
  /// ~end
  ///
  /// ~chinese
  /// 图片消息。
  /// ~end
  IMAGE,

  /// ~english
  /// The video message.
  /// ~end
  ///
  /// ~chinese
  /// 视频消息。
  /// ~end
  VIDEO,

  /// ~english
  /// The location message.
  /// ~end
  ///
  /// ~chinese
  /// 位置消息。
  /// ~end
  LOCATION,

  /// ~english
  /// The voice message.
  /// ~end
  ///
  /// ~chinese
  /// 语音消息。
  /// ~end
  VOICE,

  /// ~english
  /// The file message.
  /// ~end
  ///
  /// ~chinese
  /// 文件消息。
  /// ~end
  FILE,

  /// ~english
  /// The command message.
  /// ~end
  ///
  /// ~chinese
  /// 命令消息。
  /// ~end
  CMD,

  /// ~english
  /// The custom message.
  /// ~end
  ///
  /// ~chinese
  /// 自定义消息。
  /// ~end
  CUSTOM,

  /// ~english
  /// The combine message.
  /// ~end
  ///
  /// ~chinese
  /// 合并消息。
  /// ~end
  COMBINE,
}

/// ~english
/// The enumeration of group permission types.
/// ~end
///
/// ~chinese
/// 群组角色类型枚举。
/// ~end
enum EMGroupPermissionType {
  /// ~english
  /// Unknown.
  /// ~end
  ///
  /// ~chinese
  /// 未知类型。
  /// ~end
  None,

  /// ~english
  /// The group member.
  /// ~end
  ///
  /// ~chinese
  /// 群组成员。
  /// ~end
  Member,

  /// ~english
  /// The group admin.
  /// ~end
  ///
  /// ~chinese
  /// 群管理员。
  /// ~end
  Admin,

  /// ~english
  /// The group owner.
  /// ~end
  ///
  /// ~chinese
  /// 群主。
  /// ~end
  Owner,
}

/// ~english
/// The enumeration of chat room role types.
/// ~end
///
/// ~chinese
/// 聊天室角色类型枚举。
/// ~end
enum EMChatRoomPermissionType {
  /// ~english
  /// Unknown.
  /// ~end
  ///
  /// ~chinese
  /// 未知类型。
  /// ~end
  None,

  /// ~english
  /// The chat room member.
  /// ~end
  ///
  /// ~chinese
  /// 普通成员。
  /// ~end
  Member,

  /// ~english
  /// The chat room admin.
  /// ~end
  ///
  /// ~chinese
  /// 聊天室管理员。
  /// ~end
  Admin,

  /// ~english
  /// The chat room owner.
  /// ~end
  ///
  /// ~chinese
  /// 聊天室所有者。
  /// ~end
  Owner,
}

/// ~english
/// The enumeration of message search directions.
/// ~end
///
/// ~chinese
/// 消息检索方向类型枚举。
/// ~end
enum EMSearchDirection {
  /// ~english
  /// Messages are retrieved in the reverse chronological order of when the server receives the message.
  /// ~end
  ///
  /// ~chinese
  /// 按消息中的时间戳的倒序搜索。
  /// ~end
  Up,

  /// ~english
  /// Messages are retrieved in the chronological order of when the server receives the message.
  /// ~end
  ///
  /// ~chinese
  /// 按消息中的时间戳的顺序搜索。
  /// ~end
  Down,
}

/// ~english
/// Multi-device event types.
///
/// This enumeration takes user A logged into both DeviceA1 and DeviceA2 as an example to illustrate the various multi-device event types and when these events are triggered.
/// ~end
///
/// ~chinese
/// 多设备登录事件类型。
///
/// 本枚举类以用户 A 同时登录设备 A1 和 设备 A2 为例，描述多设备登录各事件的触发时机。
/// ~end

enum EMMultiDevicesEvent {
  /// ~english
  /// The current user removed a contact on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上删除了好友，则设备 A2 上会收到该事件。
  /// ~end
  CONTACT_REMOVE,

  /// ~english
  /// The current user accepted a friend request on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上同意了好友请求，则设备 A2 上会收到该事件。
  /// ~end
  CONTACT_ACCEPT,

  /// ~english
  /// The current user declined a friend request on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上拒绝了好友请求，则设备 A2 上会收到该事件。
  /// ~end
  CONTACT_DECLINE,

  /// ~english
  /// The current user added a contact to the block list on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上将其他用户加入了黑名单，则设备 A2 上会收到该事件。
  /// ~end
  CONTACT_BAN,

  /// ~english
  /// The current user removed a contact from the block list on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上将其他用户移出了黑名单，则设备 A2 上会收到该事件。
  /// ~end
  CONTACT_ALLOW,

  /// ~english
  /// The current user created a group on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上创建了群组，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_CREATE,

  /// ~english
  /// The current user destroyed a group on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上销毁了群组，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_DESTROY,

  /// ~english
  /// The current user joined a group on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上加入了群组，则设备 A2 会收到该事件。
  /// ~end
  GROUP_JOIN,

  /// ~english
  /// The current user left a group on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上退出群组，则设备 A2 会收到该事件。
  /// ~end
  GROUP_LEAVE,

  /// ~english
  /// The current user requested to join a group on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上申请加入群组，则设备 A2 会收到该事件。
  /// ~end
  GROUP_APPLY,

  /// ~english
  /// The current user accepted a group request on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上收到了入群申请，则设备 A2 会收到该事件。
  /// ~end
  GROUP_APPLY_ACCEPT,

  /// ~english
  /// The current user declined a group request on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上拒绝了入群申请，设备 A2 上会收到该事件。
  /// ~end
  GROUP_APPLY_DECLINE,

  /// ~english
  /// The current user invited a user to join the group on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上邀请了其他用户进入群组，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_INVITE,

  /// ~english
  /// The current user accepted a group invitation on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上同意了其他用户的群组邀请，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_INVITE_ACCEPT,

  /// ~english
  /// The current user declined a group invitation on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上拒绝了其他用户的群组邀请，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_INVITE_DECLINE,

  /// ~english
  /// The current user kicked a member out of a group on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上将其他用户踢出群组，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_KICK,

  /// ~english
  /// The current user added a member to a group block list on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上被加入黑名单，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_BAN,

  /// ~english
  /// The current user removed a member from a group block list on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上将其他用户移出群组，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_ALLOW,

  /// ~english
  /// The current user blocked a group on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上屏蔽了某个群组的消息，设备 A2 上会收到该事件。
  /// ~end
  GROUP_BLOCK,

  /// ~english
  /// The current user unblocked a group on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上取消屏蔽了某个群组的消息，设备 A2 上会收到该事件。
  /// ~end
  GROUP_UNBLOCK,

  /// ~english
  /// The current user transferred the group ownership on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上更新了群主，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_ASSIGN_OWNER,

  /// ~english
  /// The current user added an admin on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上添加了群组管理员，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_ADD_ADMIN,

  /// ~english
  /// The current user removed an admin on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上移除了群组管理员，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_REMOVE_ADMIN,

  /// ~english
  /// The current user muted a member on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上禁言了群成员，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_ADD_MUTE,

  /// ~english
  /// The current user unmuted a member on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上取消禁言了群成员，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_REMOVE_MUTE,

  /// ~english
  /// The current user added on allow list on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上将其他成员添加到群组白名单中，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_ADD_USER_ALLOW_LIST,

  /// ~english
  /// The current user removed on allow list on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上将其他成员移除群组白名单，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_REMOVE_USER_ALLOW_LIST,

  /// ~english
  /// The current user are group ban on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上将所有其他群组成员添加到群组禁言列表，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_ALL_BAN,

  /// ~english
  /// The current user are remove group ban on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上将所有其他群组成员移除群组禁言列表，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_REMOVE_ALL_BAN,

  /// ~english
  /// The current user are group disable on another device.
  /// ~end
  ///
  /// ~chinese
  /// 用户的群组功能被关闭事件。
  /// ~end
  GROUP_DISABLED,

  /// ~english
  /// The current user are group able on another device.
  /// ~end
  ///
  /// ~chinese
  /// 当前用户的群组功能开启事件。
  /// ~end
  GROUP_ABLE,

  /// ~english
  /// User A creates an event in the sub-area of device A1, and other devices logged in to this account will receive this event
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上创建了子区，则设备 A2 上会收到该事件。
  /// ~end
  CHAT_THREAD_CREATE,

  /// ~english
  /// User A destroys the event in the sub-area of device A1, and all other devices logged in to this account will receive this event
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上移除了子区，则设备 A2 上会收到该事件。
  /// ~end
  CHAT_THREAD_DESTROY,

  /// ~english
  /// User A joins the event in the sub-area of device A1, and other devices logged in to this account will receive this event
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上加入了子区，则设备 A2 上会收到该事件。
  /// ~end
  CHAT_THREAD_JOIN,

  /// ~english
  /// User A leaves the event in the sub-area of device A1, and other devices logged in to this account will receive this event
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上离开了子区，则设备 A2 上会收到该事件。
  /// ~end
  CHAT_THREAD_LEAVE,

  /// ~english
  /// User A updates the event in the sub-area of device A1, and other devices logged in to this account will receive this event
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上更新了子区信息，则设备 A2 上会收到该事件。
  /// ~end
  CHAT_THREAD_UPDATE,

  /// ~english
  /// User A is kicked in the sub-area of device A1, and all other devices that log in to this account will receive this event
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上将其他用户踢出子区，则设备 A2 上会收到该事件。
  /// ~end
  CHAT_THREAD_KICK,

  /// ~english
  /// If user A modifies a custom member attribute on device A1,
  /// this event is triggered on another device that the user logs in with the same account.
  /// ~end
  ///
  /// ~chinese
  /// 若用户 A 在设备 A1 上修改群成员自定义属性，该事件会在登录该账号的其他设备触发。
  /// ~end
  GROUP_MEMBER_ATTRIBUTES_CHANGED,

  /// ~english
  /// If user A pins a conversation on device A1, this event is triggered on device A2
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 置顶会话，则设备 A2 上会收到该事件。
  /// ~end
  CONVERSATION_PINNED,

  /// ~english
  /// If user A unpins a conversation on device A1, this event is triggered on device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1取消置顶会话，则设备 A2 上会收到该事件。
  /// ~end
  CONVERSATION_UNPINNED,

  /// ~english
  /// If user A deletes a conversation on device A1, this event is triggered on device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 删除会话，则设备 A2 上会收到该事件。
  /// ~end
  CONVERSATION_DELETE,
}

/// ~english
/// The message thread event types.
/// ~end
///
/// ~chinese
/// 子区事件类型枚举。
/// ~end
enum EMChatThreadOperation {
  /// ~english
  /// The unknown type of message thread event.
  /// ~end
  ///
  /// ~chinese
  /// 未知类型。
  /// ~end
  UnKnown,

  /// ~english
  /// The message thread is created.
  /// ~end
  ///
  /// ~chinese
  /// 子区创建。
  /// ~end
  Create,

  /// ~english
  /// The message thread is updated.
  /// ~end
  ///
  /// ~chinese
  /// 子区更新。
  /// ~end
  Update,

  /// ~english
  /// The message thread is destroyed.
  /// ~end
  ///
  /// ~chinese
  /// 子区删除。
  /// ~end
  Delete,

  /// ~english
  /// The last reply in the message thread is updated.
  /// ~end
  ///
  /// ~chinese
  /// 更新子区最新一条消息。
  /// ~end
  Update_Msg,
}

/// ~english
/// The push styles.
/// ~end
///
/// ~chinese
/// 推送通知展示方式。
/// ~end
enum DisplayStyle {
  /// ~english
  /// The push message presentation style: SimpleBanner represents the presentation of a simple message.
  /// ~end
  ///
  /// ~chinese
  /// 显示通用标题，如 “您有一条新消息”。
  /// ~end
  Simple,

  /// ~english
  /// The push message presentation style: MessageSummary represents the presentation of message content.
  /// ~end
  ///
  /// ~chinese
  /// 显示离线消息的内容。
  /// ~end
  Summary,
}

/// ~english
/// Offline push DND parameter type Enumeration class.
/// ~end
///
/// ~chinese
/// 离线推送免打扰参数类型枚举类。
/// ~end
enum ChatSilentModeParamType {
  /// ~english
  /// Offline push notification type.
  /// ~end
  ///
  /// ~chinese
  /// 离线推送通知类型。
  /// ~end
  REMIND_TYPE,

  /// ~english
  /// Offline push DND duration.
  /// ~end
  ///
  /// ~chinese
  /// 离线推送免打扰时长。
  /// ~end
  SILENT_MODE_DURATION,

  /// ~english
  /// Offline push DND period.
  /// ~end
  ///
  /// ~chinese
  /// 离线推送免打扰时间段。
  /// ~end
  SILENT_MODE_INTERVAL,
}

/// ~english
/// Offline push notification type enumeration class.
/// ~end
///
/// ~chinese
/// 离线推送通知类型枚举类。
/// ~end
enum ChatPushRemindType {
  /// ~english
  /// Collect all offline push.
  /// ~end
  ///
  /// ~chinese
  /// 所有离线推送。
  /// ~end
  ALL,

  /// ~english
  /// Only receive @me offline push.
  /// ~end
  ///
  /// ~chinese
  /// 只有@我的离线推送
  /// ~end
  MENTION_ONLY,

  /// ~english
  /// Offline push is not collected.
  /// ~end
  ///
  /// ~chinese
  /// 不接收离线推送。
  /// ~end
  NONE,
}

/// ~english
/// Chat room message priorities.
/// ~end
///
/// ~chinese
/// 聊天室消息优先级。
/// ~end
enum ChatRoomMessagePriority {
  /// ~english
  /// High
  /// ~end
  ///
  /// ~chinese
  /// 高
  /// ~end
  High,

  /// ~english
  /// Normal
  /// ~end
  ///
  /// ~chinese
  /// 中
  /// ~end
  Normal,

  /// ~english
  /// Low
  /// ~end
  ///
  /// ~chinese
  /// 低
  /// ~end
  Low,
}

/// ~english
/// Operation type of reaction.
/// ~end
///
/// ~chinese
/// reaction 操作种类。
/// ~end
enum ReactionOperate {
  /// ~english
  /// Remove
  /// ~end
  ///
  /// ~chinese
  /// 删除
  /// ~end
  Remove,

  /// ~english
  /// Add
  /// ~end
  ///
  /// ~chinese
  /// 添加
  /// ~end
  Add,
}

enum LeaveReason {
  Kicked,
  Offline,
}
