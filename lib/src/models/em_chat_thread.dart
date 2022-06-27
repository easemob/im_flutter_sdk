import '../internal/inner_headers.dart';

///
/// The message thread class.
///
class EMChatThread {
  /// The message thread ID.
  final String threadId;

  /// The name of the message thread.
  final String? threadName;

  /// The creator of the message thread.
  final String owner;

  /// The ID of the parent message of the message thread.
  final String messageId;

  /// The group ID where the message thread belongs.
  final String parentId;

  /// The count of members in the message thread.
  final int membersCount;

  /// The count of messages in the message thread.
  final int messageCount;

  /// The Unix timestamp when the message thread is created. The unit is millisecond.
  final int createAt;

  /// The last reply in the message thread. If it is empty, the last message is withdrawn.
  final EMMessage? lastMessage;

  /// @nodoc
  EMChatThread._private({
    required this.threadId,
    this.threadName,
    required this.owner,
    required this.messageId,
    required this.parentId,
    required this.membersCount,
    required this.messageCount,
    required this.createAt,
    this.lastMessage,
  });

  factory EMChatThread.fromJson(Map map) {
    String threadId = map["threadId"];
    String owner = map["owner"];
    String messageId = map["msgId"];
    String parentId = map["parentId"];
    int memberCount = map["memberCount"] as int;
    int messageCount = map["messageCount"] as int;
    int createAt = map["createAt"] as int;
    EMMessage? msg;
    if (map.containsKey("lastMessage")) {
      msg = EMMessage.fromJson(map["lastMessage"]);
    }
    String? threadName;
    if (map.containsKey("threadName")) {
      threadName = map["threadName"];
    }

    return EMChatThread._private(
      threadId: threadId,
      owner: owner,
      messageId: messageId,
      parentId: parentId,
      membersCount: memberCount,
      messageCount: messageCount,
      createAt: createAt,
      lastMessage: msg,
      threadName: threadName,
    );
  }
}

///
/// The message thread event class.
///
class EMChatThreadEvent {
  /// Received the operation type of the sub-area from others
  final EMChatThreadOperation type;

  /// User id of the operation sub-area
  final String from;

  /// sub-area
  final EMChatThread? chatThread;

  EMChatThreadEvent._private({
    required this.type,
    required this.from,
    this.chatThread,
  });

  factory EMChatThreadEvent.fromJson(Map map) {
    String from = map["from"];
    int iType = map["type"];
    EMChatThreadOperation type = EMChatThreadOperation.UnKnown;
    switch (iType) {
      case 0:
        type = EMChatThreadOperation.UnKnown;
        break;
      case 1:
        type = EMChatThreadOperation.Create;
        break;
      case 2:
        type = EMChatThreadOperation.Update;
        break;
      case 3:
        type = EMChatThreadOperation.Delete;
        break;
      case 4:
        type = EMChatThreadOperation.Update_Msg;
        break;
    }

    EMChatThread? chatThread = map.getValueWithKey<EMChatThread>(
      "thread",
      callback: (map) {
        if (map == null) {
          return null;
        }
        return EMChatThread.fromJson(map);
      },
    );

    return EMChatThreadEvent._private(
      type: type,
      from: from,
      chatThread: chatThread,
    );
  }
}
