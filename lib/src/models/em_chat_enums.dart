///
/// The group styles.
///
enum EMGroupStyle {
  /// Private groups. Only the group owner can invite users to join.
  PrivateOnlyOwnerInvite,

  /// Private groups. Both the group owner and group members can invite users to join.
  PrivateMemberCanInvite,

  /// Public groups. Only the owner can invite users to join.
  /// A user can join a group only after the owner approves the user's group request;
  PublicJoinNeedApproval,

  /// Public groups. A user can join a group without the group owner approving user's group request.
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
/// The enumeration of the chat type.
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
/// The enumeration of the message MessageDirection.
///
/// Whether the message is sent or received.
///
enum MessageDirection {
  /// This message is sent from the local client.
  SEND,

  /// The message is received by the local client.
  RECEIVE,
}

///
/// The enumeration of the message sending/reception status.
///
/// The states include success, failure, being sent/being received, and created to be sent.
///
enum MessageStatus {
  /// The message is created to be sent.
  CREATE,

  /// The message is being delivered/receiving.
  PROGRESS,

  /// The message is successfully delivered/received.
  SUCCESS,

  /// The message fails to be delivered/received.
  FAIL,
}

///
/// The download status of the attachment file .
///
enum DownloadStatus {
  /// File message download is pending.
  PENDING,

  /// The SDK is downloading the file message.
  DOWNLOADING,

  /// The SDK successfully downloads the file message.
  SUCCESS,

  /// The SDK fails to download the file message.
  FAILED,
}

///
/// The enumeration of the message type.
///
enum MessageType {
  /// Text message.
  TXT,

  /// Image message.
  IMAGE,

  /// Video message.
  VIDEO,

  /// Location message.
  LOCATION,

  /// Voice message.
  VOICE,

  /// File message.
  FILE,

  /// Command message.
  CMD,

  /// Customized message.
  CUSTOM,
}

///
/// The enum of the group permission types.
///
enum EMGroupPermissionType {
  /// The unknown type.
  None,

  /// The group member.
  Member,

  /// The group admin.
  Admin,

  /// The group owner.
  Owner,
}

///
/// Chat room role types.
///
enum EMChatRoomPermissionType {
  /// Unknown type.
  None,

  /// Regular member.
  Member,

  /// Chat room admin.
  Admin,

  /// Chat room owner.
  Owner,
}

///
/// The message search direction type.
///
enum EMSearchDirection {
  /// The search older messages type
  Up,

  /// The search newer messages type.
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
}
