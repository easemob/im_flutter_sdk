import 'em_chat_thread.dart';
import 'em_chat_enums.dart';
import '../tools/em_extension.dart';

///
/// 子区通知类
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
