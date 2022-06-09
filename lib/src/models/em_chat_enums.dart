///
/// The enumeration of group types.
///
enum EMGroupStyle {
  /// Private groups where only the the group owner can invite users to join.
  PrivateOnlyOwnerInvite,

  /// Private groups where all group members can invite users to join.
  PrivateMemberCanInvite,

  /// Public groups where users can join only after receiving an invitation from the group owner(admin) or the joining request being approved by the  group owner(admin).
  PublicJoinNeedApproval,

  /// Public groups where users can join freely.
  PublicOpenJoin,
}

/// The conversation types.
enum EMConversationType {
  /// One-to-one chat.
  Chat,

  /// Group chat.
  GroupChat,

  /// Chat room.
  ChatRoom,
}

@Deprecated('Switch to using EMPushManager#DisplayStyle instead')
enum EMPushStyle {
  Simple,
  Summary,
}

///
/// The enumeration of chat types.
///
/// There are three chat types: one-to-one chat, group chat, and chat room.
///
enum ChatType {
  /// One-to-one chat.
  Chat,

  /// Group chat.
  GroupChat,

  /// Chat room.
  ChatRoom,
}

///
/// The enumeration of the message directions.
///
/// Whether the message is sent or received.
///
enum MessageDirection {
  /// This message is sent from the local user.
  SEND,

  /// The message is received by the local user.
  RECEIVE,
}

///
/// The enumeration of the message sending/reception status.
///
enum MessageStatus {
  /// The message is created.
  CREATE,

  /// The message is being delivered/received.
  PROGRESS,

  /// The message is successfully delivered/received.
  SUCCESS,

  /// The message fails to be delivered/received.
  FAIL,
}

///
/// The download status of the attachment file.
///
enum DownloadStatus {
  /// The file message download is pending.
  PENDING,

  /// The file message is being downloaded.
  DOWNLOADING,

  /// The file message download succeeds.
  SUCCESS,

  /// The file message download fails.
  FAILED,
}

///
/// The enumeration of message types.
///
enum MessageType {
  /// The text message.
  TXT,

  /// The image message.
  IMAGE,

  /// The video message.
  VIDEO,

  /// The location message.
  LOCATION,

  /// The voice message.
  VOICE,

  /// The file message.
  FILE,

  /// The command message.
  CMD,

  /// The custom message.
  CUSTOM,
}

///
/// The enumeration of group permission types.
///
enum EMGroupPermissionType {
  /// Unknown.
  None,

  /// The group member.
  Member,

  /// The group admin.
  Admin,

  /// The group owner.
  Owner,
}

///
/// The enumeration of chat room role types.
///
enum EMChatRoomPermissionType {
  /// Unknown.
  None,

  /// The chat room member.
  Member,

  /// The chat room admin.
  Admin,

  /// The chat room owner.
  Owner,
}

///
/// The enumeration of message search directions.
///
enum EMSearchDirection {
  /// Messages are retrieved in the reverse chronological order of when the server receives the message.
  Up,

  /// Messages are retrieved in the chronological order of when the server receives the message.
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
