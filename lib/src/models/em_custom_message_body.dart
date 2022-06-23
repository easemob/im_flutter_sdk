import '../tools/em_extension.dart';

import 'em_chat_enums.dart';
import 'em_message_body.dart';

///
/// The custom message body.
///
class EMCustomMessageBody extends EMMessageBody {
  ///
  /// 自定义消息体类。
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

  /// @nodoc
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.setValueWithOutNull("event", event);
    data.setValueWithOutNull("params", params);

    return data;
  }

  /// 自定义事件内容。
  late final String event;

  /// 自定义消息的键值对 Map 列表。
  Map<String, String>? params;
}
