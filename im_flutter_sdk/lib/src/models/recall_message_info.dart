import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk/src/tools/chat_extension.dart';

class RecallMessageInfo {
  factory RecallMessageInfo.fromJson(Map map) {
    return RecallMessageInfo(
      recallMessageId: map['recallMsgId'],
      recallBy: map['recallBy'],
      conversationId: map['convId'],
      recallMessage: map.getValue<ChatMessage>(
        "msg",
        callback: (map) {
          if (map == null) {
            return null;
          }
          return ChatMessage.fromJson(map);
        },
      ),
      ext: map.getValue('ext', callback: (ext) => ext as String?),
    );
  }

  const RecallMessageInfo({
    required this.recallBy,
    required this.recallMessageId,
    this.recallMessage,
    this.conversationId,
    this.ext,
  });

  // 5.0.0
  /// ~english
  /// Converts this recall information to a JSON map using the keys accepted by [RecallMessageInfo.fromJson].
  /// Nullable fields retain null values; the original message is serialized under `msg`.
  /// ~end
  ///
  /// ~chinese
  /// 将当前撤回信息转换为 JSON Map，字段名与 [RecallMessageInfo.fromJson] 一致。
  /// 可空字段保留 null，原消息序列化后放入 `msg` 字段。
  /// ~end
  Map<String, dynamic> toJson() {
    return {
      'recallMsgId': recallMessageId,
      'recallBy': recallBy,
      'convId': conversationId,
      'msg': recallMessage?.toJson(),
      'ext': ext,
    };
  }

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
  final ChatMessage? recallMessage;

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
