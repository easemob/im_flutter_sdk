import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk/src/tools/chat_extension.dart';

/// ~english
/// The result of a message searched from the server.
///
/// This class is returned by [ChatManager.searchMessagesFromServer].
/// ~end
///
/// ~chinese
/// 服务端消息搜索的结果类。
///
/// 该类由 [ChatManager.searchMessagesFromServer] 返回。
/// ~end
class ChatSearchServerMessageResult {
  ChatSearchServerMessageResult._private();

  factory ChatSearchServerMessageResult.fromJson(Map map) {
    return ChatSearchServerMessageResult._private()
      ..msgId = map['msgId'] ?? ''
      ..body = map['body'] is Map ? _bodyFromMap(map['body']) : null
      ..attributes = map.getMapValue('attributes')
      ..from = map['from'] ?? ''
      ..to = map['to'] ?? ''
      ..convId = map['convId'] ?? ''
      ..chatType = ChatType.values[map['chatType'] ?? ChatType.Chat.index]
      ..timestamp = map['timestamp'] ?? 0
      ..highlightTexts = (map['highlightTexts'] as List?)?.cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msgId'] = msgId;
    data.putIfNotNull('body', body?.toJson());
    data.putIfNotNull('attributes', attributes);
    data['from'] = from;
    data['to'] = to;
    data['convId'] = convId;
    data['chatType'] = chatType.index;
    data['timestamp'] = timestamp;
    data.putIfNotNull('highlightTexts', highlightTexts);
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }

  // Same body dispatch as ChatMessage.fromJson.
  static ChatMessageBody? _bodyFromMap(Map map) {
    ChatMessageBody? body;
    MessageType type = MessageType.values[map['type']];
    switch (type) {
      case MessageType.TXT:
        body = ChatTextMessageBody.fromJson(map: map);
        break;
      case MessageType.LOCATION:
        body = ChatLocationMessageBody.fromJson(map: map);
        break;
      case MessageType.CMD:
        body = ChatCmdMessageBody.fromJson(map: map);
        break;
      case MessageType.CUSTOM:
        body = ChatCustomMessageBody.fromJson(map: map);
        break;
      case MessageType.FILE:
        body = ChatFileMessageBody.fromJson(map: map);
        break;
      case MessageType.IMAGE:
        body = ChatImageMessageBody.fromJson(map: map);
        break;
      case MessageType.VIDEO:
        body = ChatVideoMessageBody.fromJson(map: map);
        break;
      case MessageType.VOICE:
        body = ChatVoiceMessageBody.fromJson(map: map);
        break;
      case MessageType.COMBINE:
        body = CombineMessageBody.fromJson(map: map);
        break;
    }

    return body;
  }

  /// ~english
  /// The message ID.
  /// ~end
  ///
  /// ~chinese
  /// 消息 ID。
  /// ~end
  String msgId = '';

  /// ~english
  /// The message body.
  /// ~end
  ///
  /// ~chinese
  /// 消息体。
  /// ~end
  ChatMessageBody? body;

  /// ~english
  /// The extension attributes of the message.
  /// ~end
  ///
  /// ~chinese
  /// 消息扩展属性。
  /// ~end
  Map<String, dynamic>? attributes;

  /// ~english
  /// The user ID of the message sender.
  /// ~end
  ///
  /// ~chinese
  /// 消息发送方的用户 ID。
  /// ~end
  String from = '';

  /// ~english
  /// The message recipient.
  /// - For a one-to-one chat, it is the user ID of the peer user.
  /// - For a group chat, it is the group ID.
  /// - For a chat room, it is the chat room ID.
  /// ~end
  ///
  /// ~chinese
  /// 消息接收方，可以是：
  /// - 单聊：用户 ID；
  /// - 群组：群组 ID；
  /// - 聊天室：聊天室 ID。
  /// ~end
  String to = '';

  /// ~english
  /// The conversation ID.
  /// ~end
  ///
  /// ~chinese
  /// 会话 ID。
  /// ~end
  String convId = '';

  /// ~english
  /// The chat type. See [ChatType].
  /// ~end
  ///
  /// ~chinese
  /// 聊天类型，详见 [ChatType]。
  /// ~end
  ChatType chatType = ChatType.Chat;

  /// ~english
  /// The message timestamp, in milliseconds.
  /// ~end
  ///
  /// ~chinese
  /// 消息时间戳，单位为毫秒。
  /// ~end
  int timestamp = 0;

  /// ~english
  /// The highlighted texts matched by the search keywords.
  /// ~end
  ///
  /// ~chinese
  /// 搜索关键词命中的高亮文本。
  /// ~end
  List<String>? highlightTexts;
}
