import 'em_message.dart';

class EMChatThread {
  /// sub-zone id
  final String threadId;

  /// Subject of the sub-zone(There will be a list of requested sub-areas and sub-area details)
  final String? threadName;

  /// create  of the sub-zone, require fetch thread's detail first
  final String owner;

  /// A messageId that create sub-zone
  final String messageId;

  /// A channelId that create sub-zone
  final String parentId;

  /// Member list of the sub-zone, require fetch thread's detail first
  final int membersCount;

  /// Number of messages in subsection
  final int messageCount;

  /// Timestamp of subarea creation
  final int createAt;

  /// The last message in the sub-area, if it is empty, it means the last message is withdrawn. If it is not empty, it means a new message.
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
