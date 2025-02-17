import '../internal/inner_headers.dart';

class RecallMessageInfo {
  factory RecallMessageInfo.fromJson(Map map) {
    return RecallMessageInfo._(
      recallMessageId: map['recallMsgId'],
      recallBy: map['recallBy'],
      conversationId: map['conversationId'],
      recallMessage: map.getValue<EMMessage>(
        "msg",
        callback: (map) {
          if (map == null) {
            return null;
          }
          return EMMessage.fromJson(map);
        },
      ),
      ext: map.getValue('ext', callback: (ext) => ext as String?),
    );
  }

  const RecallMessageInfo._({
    required this.recallBy,
    required this.recallMessageId,
    this.recallMessage,
    this.conversationId,
    this.ext,
  });

  /// ~english
  /// The ID of the recalled message.
  /// ~end
  /// ~chinese
  /// 撤回消息的id
  /// ~end
  final String recallMessageId;

  /// ~english
  /// The recalled message.
  ///
  /// The value of this property is nil if the recipient is offline during message recall.
  /// ~end
  /// ~chinese
  /// 撤回的消息，离线撤回会为空。
  /// ~end
  final EMMessage? recallMessage;

  /// ~english
  /// The extension field of the recalled message.
  /// ~end
  /// ~chinese
  /// 撤回消息时要透传的信息。
  /// ~end
  final String? ext;

  /// ~english
  /// The user who recalled the message.
  /// ~end
  /// ~chinese
  /// 撤回消息的用户。
  /// ~end
  final String recallBy;

  /// ~english
  /// The conversation ID of the recalled message.
  /// ~end
  ///
  /// ~chinese
  /// 撤回消息的会话ID。
  /// ~end
  final String? conversationId;
}
