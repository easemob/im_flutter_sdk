import '../tools/em_extension.dart';

import 'em_chat_enums.dart';
import 'em_message_body.dart';

///
/// Text message body.
///
class EMTextMessageBody extends EMMessageBody {
  ///
  /// Creates a text message body.
  ///
  /// Param [content] The text content.
  ///
  EMTextMessageBody({required this.content}) : super(type: MessageType.TXT);

  EMTextMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: MessageType.TXT) {
    this.content = map.getValueWithOutNull("content", "");
  }

  @override

  ///@nodoc
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['content'] = this.content;
    return data;
  }

  /// The text content.
  late final String content;
}
