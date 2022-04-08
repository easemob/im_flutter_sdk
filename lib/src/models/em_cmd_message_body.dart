import '../tools/em_extension.dart';

import 'em_chat_enums.dart';
import 'em_message_body.dart';

///
/// The command message body.
///
class EMCmdMessageBody extends EMMessageBody {
  ///
  /// Creates a command message.
  ///
  EMCmdMessageBody({required this.action, this.deliverOnlineOnly = false})
      : super(type: MessageType.CMD);

  EMCmdMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: MessageType.CMD) {
    this.action = map["action"];
    this.deliverOnlineOnly =
        map.getBoolValue("deliverOnlineOnly", defaultValue: false)!;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.setValueWithOutNull("action", action);
    data.setValueWithOutNull("deliverOnlineOnly", deliverOnlineOnly);

    return data;
  }

  /// The command action content.
  late final String action;

  ///
  /// Checks whether this command message is only delivered to online users.
  ///
  /// - `true`: Yes.
  /// - `false`: No.
  ///
  bool deliverOnlineOnly = false;
}
