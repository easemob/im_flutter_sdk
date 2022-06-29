import '../internal/inner_headers.dart';

///
/// 子区详情类。
///
class EMChatThread {
  /// 子区 ID。
  final String threadId;

  /// 子区名称。
  final String? threadName;

  /// 子区创建者的用户 ID。
  final String owner;

  /// 子区父消息 ID。
  final String messageId;

  /// 子区所属的群组 ID。
  final String parentId;

  /// 子区成员数量。
  final int membersCount;

  /// 子区消息数量。
  final int messageCount;

  /// 子区创建的 Unix 时间戳。单位为毫秒。
  final int createAt;

  /// 子区最新一条消息。如果为空，表明最新一条消息被撤回。
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
/// 子区通知类。
///
class EMChatThreadEvent {
  /// 子区事件类型。
  final EMChatThreadOperation type;

  // 子区操作者。
  final String from;

  /// 子区实例。
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
