import '../tools/em_extension.dart';

import 'em_chat_enums.dart';
import 'em_message_body.dart';

///
/// 命令消息体类。
///
class EMCmdMessageBody extends EMMessageBody {
  ///
  /// 创建一个命令消息。
  ///
  EMCmdMessageBody({required this.action, this.deliverOnlineOnly = false})
      : super(type: MessageType.CMD);

  /// @nodoc
  EMCmdMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: MessageType.CMD) {
    this.action = map["action"];
    this.deliverOnlineOnly =
        map.getBoolValue("deliverOnlineOnly", defaultValue: false)!;
  }

  /// @nodoc
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.setValueWithOutNull("action", action);
    data.setValueWithOutNull("deliverOnlineOnly", deliverOnlineOnly);

    return data;
  }

  /// 命令内容。
  late final String action;

  ///
  /// 判断当前 CMD 类型消息是否只投递在线用户。
  ///
  /// - `true`：是；
  /// - `false`：否。
  ///
  bool deliverOnlineOnly = false;
}
