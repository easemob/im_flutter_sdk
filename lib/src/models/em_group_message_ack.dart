import '../tools/em_extension.dart';

///
/// Returns read recipients for group messages.
///
/// Calls {@link EMChatManager#fetchGroupAcks(String, String?, int)} to return the requested result, for example:
///
/// ```dart
///   EMCursorResult<EMGroupMessageAck?> result = await EMClient.getInstance.chatManager.fetchGroupAcks("msgId");
/// ```
///
class EMGroupMessageAck {
  ///
  /// Gets the group message ID.
  ///
  /// **return** The group message ID.
  ///
  final String messageId;

  ///
  /// Gets the read receipt ID of group messages.
  ///
  /// **return** The read receipt ID.
  ///
  final String ackId;

  ///
  /// Gets the ID of user who sends the read receipt.
  ///
  /// **return** The read receipt sender ID.
  ///
  final String from;

  ///
  /// Gets the read receipt extension.
  ///
  /// Sends the read receipt passed as the third parameter in {@link EMChatManager#sendGroupMessageReadAck(String, String, String?)}.
  ///
  /// **return** The read receipt extension.
  ///
  final String? content;

  ///
  /// Gets the count in which read receipts of group messages are sent.
  ///
  /// **return** The count in which read receipts of group messages are sent.
  ///
  final int readCount;

  ///
  /// Gets the timestamp of sending read receipts of group messages.
  ///
  /// **return** The timestamp of sending read receipts of group messages.
  final int timestamp;

  /// @nodoc
  factory EMGroupMessageAck.fromJson(Map map) {
    EMGroupMessageAck ack = EMGroupMessageAck._private(
      ackId: map["ack_id"] as String,
      messageId: map["msg_id"] as String,
      from: map["from"] as String,
      content: map.getValue("content"),
      readCount: map.getValueWithOutNull("count", 0),
      timestamp: map.getValueWithOutNull("timestamp", 0),
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
