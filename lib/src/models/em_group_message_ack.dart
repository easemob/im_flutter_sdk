import '../tools/em_extension.dart';

///
/// 群组消息回执类。
///
/// 调用 {@link EMChatManager#fetchGroupAcks(String, String?, int)} 方法，示例代码如下：
///
/// ```dart
///   EMCursorResult<EMGroupMessageAck> result = await EMClient.getInstance.chatManager.fetchGroupAcks("msgId");
/// ```
///
class EMGroupMessageAck {
  /// 群组消息 ID。
  final String messageId;

  /// 群组消息已读回执 ID。
  final String ackId;

  /// 发送已读回执的用户 ID。
  final String from;

  ///
  /// 获取已读回执扩展内容。
  ///
  /// 设定该扩展内容详见 {@link EMChatManager#sendGroupMessageReadAck(String, String, String?)}。
  ///
  final String? content;

  ///
  /// 群组消息已读回执数量。
  ///
  final int readCount;

  /// 发送已读回执的时间戳。
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
