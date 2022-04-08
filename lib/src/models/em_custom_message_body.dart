import '../tools/em_extension.dart';

import 'em_chat_enums.dart';
import 'em_message_body.dart';

///
/// The custom message body.
///
class EMCustomMessageBody extends EMMessageBody {
  ///
  /// Creates a custom message.
  ///
  EMCustomMessageBody({
    required this.event,
    this.params,
  }) : super(type: MessageType.CUSTOM);
  EMCustomMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: MessageType.CUSTOM) {
    this.event = map["event"];
    this.params = map["params"]?.cast<String, String>();
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.setValueWithOutNull("event", event);
    data.setValueWithOutNull("params", params);

    return data;
  }

  /// The event.
  late final String event;

  /// The custom params map.
  Map<String, String>? params;
}
