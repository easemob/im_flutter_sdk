import 'em_message.dart';
import '../tools/em_extension.dart';

class EMChatThreadEvent {
  /// Sub-zone id
  final String threadId;

  /// Sub-zone name
  final String? threadName;

  /// Received the operation type of the sub-area from others
  final String threadOperation;

  /// The message id of the message on which the subarea was created
  final String messageId;

  /// Number of messages in subsection
  final int messageCount;

  /// The session id of the message on which the subarea was created
  final String channelId;

  /// User id of the operation sub-area
  final String from;

  /// The user id of the sub-area that accepts the operation notification, currently all group members
  final String to;

  /// The timestamp of the operation when the user of the subarea was operated
  final int timestamp;

  /// The last message in the sub-area, if it is empty, it means the last message is withdrawn. If it is not empty, it means a new message.
  final EMMessage? lastMessage;

  EMChatThreadEvent._private({
    required this.threadId,
    required this.threadOperation,
    required this.messageId,
    required this.messageCount,
    required this.channelId,
    required this.from,
    required this.to,
    required this.timestamp,
    this.lastMessage,
    this.threadName,
  });

  factory EMChatThreadEvent.fromJson(Map map) {
    String threadId = map["threadId"];
    String operation = map["operation"];
    String messageId = map["msgId"];
    String channelId = map["channelId"];
    int count = map["count"];
    String from = map["from"];
    String to = map["to"];
    int ts = map["ts"];
    EMMessage? msg = map.getValueWithKey<EMMessage>(
      "message",
      callback: (map) {
        if (map == null) {
          return null;
        }
        return EMMessage.fromJson(map);
      },
    );
    String? threadName = map["threadName"];
    return EMChatThreadEvent._private(
      threadId: threadId,
      threadOperation: operation,
      messageId: messageId,
      messageCount: count,
      channelId: channelId,
      from: from,
      to: to,
      timestamp: ts,
      lastMessage: msg,
      threadName: threadName,
    );
  }
}
