/// ~english
/// The group types.
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
/// The chat types.
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
/// The message directions.
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
/// The message sending/reception status.
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

  /// ~english
  /// The file message download is pending.
  /// ~end
  ///
  /// ~chinese
  /// 等待下载。
  /// ~end
  PENDING,
}

/// ~english
/// The message types.
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
/// The group roles.
/// ~end
///
/// ~chinese
/// 群组角色类型枚举。
/// ~end
enum EMGroupPermissionType {
  /// ~english
  /// The regular group member.
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

  /// ~english
  /// Unknown.
  /// ~end
  ///
  /// ~chinese
  /// 未知类型。
  /// ~end
  None,
}

/// ~english
/// The chat room roles.
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
  /// The regular chat room member.
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
/// The message search directions.
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
/// This enumeration takes user A logged into both Device A1 and Device A2 as an example to illustrate the various multi-device event types and when these events are triggered.
/// ~end
///
/// ~chinese
/// 多设备登录事件类型。
///
/// 本枚举类以用户 A 同时登录设备 A1 和 设备 A2 为例，描述多设备登录各事件的触发时机。
/// ~end

enum EMMultiDevicesEvent {
  /// ~english
  /// If user A deletes a contact on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上删除了好友，则设备 A2 上会收到该事件。
  /// ~end
  CONTACT_REMOVE,

  /// ~english
  /// If user A accepts a friend request on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上同意了好友请求，则设备 A2 上会收到该事件。
  /// ~end
  CONTACT_ACCEPT,

  /// ~english
  /// If user A declines a friend request on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上拒绝了好友请求，则设备 A2 上会收到该事件。
  /// ~end
  CONTACT_DECLINE,

  /// ~english
  /// If user A adds another user to the block list on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上将其他用户加入了黑名单，则设备 A2 上会收到该事件。
  /// ~end
  CONTACT_BAN,

  /// ~english
  ///  If user A removes another user from the block list on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上将其他用户移出了黑名单，则设备 A2 上会收到该事件。
  /// ~end
  CONTACT_ALLOW,

  /// ~english
  /// If user A creates a chat group on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上创建了群组，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_CREATE,

  /// ~english
  /// If user A destroys a chat group on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上解散了群组，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_DESTROY,

  /// ~english
  /// If user A joins a chat group on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上加入了群组，则设备 A2 会收到该事件。
  /// ~end
  GROUP_JOIN,

  /// ~english
  /// If user A leaves a chat group on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上退出群组，则设备 A2 会收到该事件。
  /// ~end
  GROUP_LEAVE,

  /// ~english
  /// If user A requests to join a chat group on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上申请加入群组，则设备 A2 会收到该事件。
  /// ~end
  GROUP_APPLY,

  /// ~english
  /// If user A accepts a request to join the chat group on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上接受了入群申请，则设备 A2 会收到该事件。
  /// ~end
  GROUP_APPLY_ACCEPT,

  /// ~english
  /// If user A declines a request to join the chat group on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上拒绝了入群申请，设备 A2 上会收到该事件。
  /// ~end
  GROUP_APPLY_DECLINE,

  /// ~english
  /// If user A invites a user to join the chat group on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上邀请了其他用户进入群组，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_INVITE,

  /// ~english
  /// If user A accepts a group invitation on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上同意了其他用户的群组邀请，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_INVITE_ACCEPT,

  /// ~english
  /// If user A declines a group invitation on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上拒绝了其他用户的群组邀请，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_INVITE_DECLINE,

  /// ~english
  /// If user A declines a group invitation on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上将其他用户踢出群组，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_KICK,

  /// ~english
  /// If user A adds a member to a group block list on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 当前用户在其他设备上将成员加入群组黑名单。用户 A 在设备 A1 上将其他用户加入黑名单，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_BAN,

  /// ~english
  /// If user A removes a member from a group block list on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上将其他用户移出群组黑名单，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_ALLOW,

  /// ~english
  /// If user A blocks messages from a chat group on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上屏蔽了某个群组的消息，设备 A2 上会收到该事件。
  /// ~end
  GROUP_BLOCK,

  /// ~english
  /// If user A unblocks messages from a chat group on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上取消屏蔽了某个群组的消息，设备 A2 上会收到该事件。
  /// ~end
  GROUP_UNBLOCK,

  /// ~english
  /// If user A transfers the group ownership on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上转移群组所有权，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_ASSIGN_OWNER,

  /// ~english
  /// If user A adds a group admin on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上添加了群组管理员，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_ADD_ADMIN,

  /// ~english
  /// If user A removes a group admin on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上移除了群组管理员，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_REMOVE_ADMIN,

  /// ~english
  /// If user A mutes a group member on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上禁言了群成员，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_ADD_MUTE,

  /// ~english
  /// If user A unmutes a group member on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  ///用户 A 在设备 A1 上取消禁言了群成员，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_REMOVE_MUTE,

  /// ~english
  /// If user A adds other members to the allow list of the chat group on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上将其他成员添加到群组白名单中，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_ADD_USER_ALLOW_LIST,

  /// ~english
  /// If user A removes other members from the allow list of the chat group on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上将其他成员移除群组白名单，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_REMOVE_USER_ALLOW_LIST,

  /// ~english
  /// If user A adds all other chat group members to the group mute list on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上将所有其他群组成员添加到群组禁言列表，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_ALL_BAN,

  /// ~english
  /// If user A removes all other chat group members from the group mute list on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上将所有其他群组成员移除群组禁言列表，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_REMOVE_ALL_BAN,

  /// ~english
  /// If the group function is disabled for user A on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 的群组功能在设备 A1 上被关闭，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_DISABLED,

  /// ~english
  /// If the group function is enabled for user A on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 的群组功能在设备 A1 上被开启，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_ABLE,

  /// ~english
  /// If user A modifies custom attributes of a group member on Device A1, this event is triggered on Device A2.
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上修改群组成员属性，则设备 A2 上会收到该事件。
  /// ~end
  GROUP_MEMBER_ATTRIBUTES_CHANGED,

  /// ~english
  /// If user A creates a message thread on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上创建了子区，则设备 A2 上会收到该事件。
  /// ~end
  CHAT_THREAD_CREATE,

  /// ~english
  /// If user A destroys a message thread on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上移除了子区，则设备 A2 上会收到该事件。
  /// ~end
  CHAT_THREAD_DESTROY,

  /// ~english
  /// If user A joins a message thread on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上加入了子区，则设备 A2 上会收到该事件。
  /// ~end
  CHAT_THREAD_JOIN,

  /// ~english
  /// If user A leaves a message thread on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上离开了子区，则设备 A2 上会收到该事件。
  /// ~end
  CHAT_THREAD_LEAVE,

  /// ~english
  /// If user A updates the message thread name, or sends or recalls a message in thread on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上更新了子区信息，则设备 A2 上会收到该事件。
  /// ~end
  CHAT_THREAD_UPDATE,

  /// ~english
  /// If user A kicks a user from a message thread on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 上将其他用户踢出子区，则设备 A2 上会收到该事件。
  /// ~end
  CHAT_THREAD_KICK,

  /// ~english
  /// If user A pins a conversation on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 置顶会话，则设备 A2 上会收到该事件。
  /// ~end
  CONVERSATION_PINNED,

  /// ~english
  /// If user A unpins a conversation on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 取消置顶会话，则设备 A2 上会收到该事件。
  /// ~end
  CONVERSATION_UNPINNED,

  /// ~english
  /// If user A deletes a conversation on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 删除会话，则设备 A2 上会收到该事件。
  /// ~end
  CONVERSATION_DELETE,

  /// ~english
  /// If user A updates a conversation mark on Device A1, this event is triggered on Device A2.
  /// ~end
  ///
  /// ~chinese
  /// 用户 A 在设备 A1 更新会话标记，则设备 A2 上会收到该事件。
  /// ~end
  CONVERSATION_UPDATE_MARK,

  /// ~english
  /// If user A sets the Do Not Disturb mode for a conversation on device A1, this event is triggered on device A2.
  /// ~end
  ///
  /// ~chinese
  ///  用户 A 在设备 A1 设置会话免打扰，则设备 A2 上会收到该事件。
  /// ~end
  CONVERSATION_MUTE_INFO_CHANGED,
}

/// ~english
/// The message thread events.
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
/// The push display styles.
/// ~end
///
/// ~chinese
/// 推送通知展示方式。
/// ~end
enum DisplayStyle {
  /// ~english
  /// A simple message is shown in the notification bar, for example, "You've got a new message.".
  /// ~end
  ///
  /// ~chinese
  /// 显示通用标题，如 “您有一条新消息”。
  /// ~end
  Simple,

  /// ~english
  /// The message content is shown in the notification bar.
  /// ~end
  ///
  /// ~chinese
  /// 显示离线消息的内容。
  /// ~end
  Summary,
}

/// ~english
/// The offline push settings.
/// ~end
///
/// ~chinese
/// 离线推送参数类型枚举类。
/// ~end
enum ChatSilentModeParamType {
  /// ~english
  /// The push notification mode.
  /// ~end
  ///
  /// ~chinese
  /// 离线推送通知类型。
  /// ~end
  REMIND_TYPE,

  /// ~english
  /// The DND duration.
  /// ~end
  ///
  /// ~chinese
  /// 离线推送免打扰时长。
  /// ~end
  SILENT_MODE_DURATION,

  /// ~english
  /// The DND time frame.
  /// ~end
  ///
  /// ~chinese
  /// 离线推送免打扰时间段。
  /// ~end
  SILENT_MODE_INTERVAL,
}

/// ~english
/// The push notification modes.
/// ~end
///
/// ~chinese
/// 离线推送通知类型枚举类。
/// ~end
enum ChatPushRemindType {
  /// ~english
  /// Receives push notifications for all offline messages.
  /// ~end
  ///
  /// ~chinese
  /// 接收所有离线消息的推送通知。
  /// ~end
  ALL,

  /// ~english
  /// Only receives push notifications for mentioned messages.
  /// ~end
  ///
  /// ~chinese
  /// 仅接收提及某些用户的消息的推送通知。
  /// ~end
  MENTION_ONLY,

  /// ~english
  /// Do not receive push notifications for offline messages.
  /// ~end
  ///
  /// ~chinese
  /// 不接收离线消息的推送通知。
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
/// Reaction operations.
/// ~end
///
/// ~chinese
/// Reaction 操作类型。
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

/// ~english
/// Leave chat room reason
/// ~end
/// ~chinese
/// 离开聊天室原因
/// ~end

enum LeaveReason {
  ///
  /// ~english
  /// Kicked out
  /// ~end
  /// ~chinese
  /// 被移除
  /// ~end
  Kicked,

  /// ~english
  /// offline
  /// ~end
  /// ~chinese
  /// 离线
  /// ~end
  Offline,
}

enum MessagePinOperation {
  /// ~english
  /// Pin
  /// ~end
  ///
  /// ~chinese
  /// 置顶
  /// ~end
  Pin,

  /// ~english
  /// Unpin
  /// ~end
  ///
  /// ~chinese
  /// 取消置顶
  /// ~end
  Unpin,
}

///  ~english
///  The message search scopes.
/// ~end
///
/// ~chinese
///  消息搜索范围枚举类型。
/// ~end
enum MessageSearchScope {
  /// ~english
  /// Search by message content.
  /// ~end
  ///
  /// ~chinese
  /// 按消息内容搜索。
  /// ~end
  Content,

  /// ~english
  /// Search by message extension.
  /// ~end
  ///
  /// ~chinese
  /// 按消息扩展属性搜索。
  /// ~end
  Attribute,

  /// ~english
  /// Search by message content and extension.
  /// ~end
  ///
  /// ~chinese
  /// 按消息内容和扩展属性搜索。
  /// ~end
  All,
}

/// ~english
/// The conversation mark types.
///
/// The mapping between each type of conversation mark and their actual meanings is maintained by the developer.
/// ~end
///
/// ~chinese
/// 会话标记类型枚举。
///
/// 各会话标记类型与实际意义之间的映射由开发者维护
/// ~end
enum ConversationMarkType {
  Type0,
  Type1,
  Type2,
  Type3,
  Type4,
  Type5,
  Type6,
  Type7,
  Type8,
  Type9,
  Type10,
  Type11,
  Type12,
  Type13,
  Type14,
  Type15,
  Type16,
  Type17,
  Type18,
  Type19,
}
