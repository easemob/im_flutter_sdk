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
    this.action = map.getValue("action");
    this.deliverOnlineOnly =
        map.getValueWithOutNull("deliverOnlineOnly", false);
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
  /// Checks whether this cmd message is only delivered to online users.
  ///
  /// `true`: Only delivers to online users.
  /// `false`: Delivers to all users.
  ///
  bool deliverOnlineOnly = false;
}
