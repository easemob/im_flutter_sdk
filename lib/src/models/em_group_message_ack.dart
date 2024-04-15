import '../internal/inner_headers.dart';

/// ~english
/// The class for group message read receipts.
///
/// To get the chat group message receipts, call [EMChatManager.fetchGroupAcks].
///
/// ```dart
///   EMCursorResult<EMGroupMessageAck> result = await EMClient.getInstance.chatManager.fetchGroupAcks("msgId");
/// ```
/// ~end
///
/// ~chinese
/// 群组消息回执类。
///
/// 调用 [EMChatManager.fetchGroupAcks] 方法，示例代码如下：
///
/// ```dart
///   EMCursorResult<EMGroupMessageAck> result = await EMClient.getInstance.chatManager.fetchGroupAcks("msgId");
/// ```
/// ~end
class EMGroupMessageAck {
  /// ~english
  /// Gets the group message ID.
  ///
  /// **Return** The group message ID.
  /// ~end
  ///
  /// ~chinese
  /// 群组消息 ID。
  /// ~end
  final String messageId;

  /// ~english
  /// Gets the ID of the  group message read receipt.
  ///
  /// **Return** The read receipt ID.
  /// ~end
  ///
  /// ~chinese
  /// 群组消息已读回执 ID。
  /// ~end
  final String? ackId;

  /// ~english
  /// Gets the username of the user who sends the read receipt.
  ///
  /// **Return** The username of the read receipt sender.
  /// ~end
  ///
  /// ~chinese
  /// 发送已读回执的用户 ID。
  /// ~end
  final String from;

  /// ~english
  /// Gets the read receipt extension.
  ///
  /// For how to set the extension, see [EMChatManager.sendGroupMessageReadAck].
  ///
  /// **Return** The read receipt extension.
  /// ~end
  ///
  /// ~chinese
  /// 已读回执扩展内容。
  ///
  /// 设定该扩展内容详见 [EMChatManager.sendGroupMessageReadAck].。
  /// ~end
  final String? content;

  /// ~english
  /// Gets the number read receipts of group messages.
  ///
  /// **Return** The count in which read receipts of group messages are sent.
  /// ~end
  ///
  /// ~chinese
  /// 群组消息已读回执数量。
  /// ~end
  final int readCount;

  /// ~english
  /// Gets the timestamp of sending read receipts of group messages.
  ///
  /// **Return** The timestamp of sending read receipts of group messages.
  /// ~end
  ///
  /// ~chinese
  /// 发送已读回执的时间戳。
  /// ~end
  final int timestamp;

  factory EMGroupMessageAck.fromJson(Map map) {
    EMGroupMessageAck ack = EMGroupMessageAck._private(
      ackId: map["ack_id"],
      messageId: map["msg_id"] as String,
      from: map["from"] as String,
      content: map["content"],
      readCount: map["count"] ?? 0,
      timestamp: map["timestamp"] ?? 0,
    );

    return ack;
  }

  EMGroupMessageAck._private({
    this.ackId,
    required this.messageId,
    required this.from,
    required this.content,
    required this.readCount,
    required this.timestamp,
  });
}
