import '../internal/inner_headers.dart';

///
/// The class for group message read receipts.
///
/// To get the chat group message receipts, call [EMChatManager.fetchGroupAcks].
///
/// ```dart
///   EMCursorResult<EMGroupMessageAck> result = await EMClient.getInstance.chatManager.fetchGroupAcks("msgId");
/// ```
///
class EMGroupMessageAck {
  ///
  /// Gets the group message ID.
  ///
  /// **Return** The group message ID.
  ///
  final String messageId;

  ///
  /// Gets the ID of the  group message read receipt.
  ///
  /// **Return** The read receipt ID.
  ///
  final String ackId;

  ///
  /// Gets the username of the user who sends the read receipt.
  ///
  /// **Return** The username of the read receipt sender.
  ///
  final String from;

  ///
  /// Gets the read receipt extension.
  ///
  /// For how to set the extension, see [EMChatManager.sendGroupMessageReadAck].
  ///
  /// **Return** The read receipt extension.
  ///
  final String? content;

  ///
  /// Gets the number read receipts of group messages.
  ///
  /// **Return** The count in which read receipts of group messages are sent.
  ///
  final int readCount;

  ///
  /// Gets the timestamp of sending read receipts of group messages.
  ///
  /// **Return** The timestamp of sending read receipts of group messages.
  final int timestamp;

  /// @nodoc
  factory EMGroupMessageAck.fromJson(Map map) {
    EMGroupMessageAck ack = EMGroupMessageAck._private(
      ackId: map["ack_id"] as String,
      messageId: map["msg_id"] as String,
      from: map["from"] as String,
      content: map["content"],
      readCount: map.getIntValue("count", defaultValue: 0)!,
      timestamp: map.getIntValue("timestamp", defaultValue: 0)!,
    );

    return ack;
  }

  EMGroupMessageAck._private({
    required this.ackId,
    required this.messageId,
    required this.from,
    required this.content,
    required this.readCount,
    required this.timestamp,
  });
}
