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

enum EMChatRoomPermissionType {
  None,
  Member,
  Admin,
  Owner,
}
enum EMConversationType {
  Chat, // 单聊消息
  GroupChat, // 群聊消息
  ChatRoom, // 聊天室消息
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

enum EMGroupPermissionType {
  None,
  Member,
  Admin,
  Owner,
}
