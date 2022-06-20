import '../tools/em_extension.dart';

import 'em_chat_enums.dart';
import 'em_message_body.dart';

///
/// The text message class.
///
class EMTextMessageBody extends EMMessageBody {
  ///
  /// Creates a text message.
  ///
  /// Param [content] The text content.
  ///
  EMTextMessageBody({
    required this.content,
    this.targetLanguages,
  }) : super(type: MessageType.TXT);

  /// @nodoc
  EMTextMessageBody.fromJson({required Map map})
      : super.fromJson(
          map: map,
          type: MessageType.TXT,
        ) {
    this.content = map.getStringValue("content", defaultValue: "")!;
    this.targetLanguages = map.getList<String>(
      "targetLanguages",
      valueCallback: (item) {
        return item;
      },
    );
    if (map.containsKey("translations")) {
      this.translations = map["translations"]?.cast<String, String>();
    }
  }

  @override

  ///@nodoc
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['content'] = this.content;
    data.setValueWithOutNull("targetLanguages", this.targetLanguages);
    data.setValueWithOutNull("translations", this.translations);
    return data;
  }

  /// The text content.
  late final String content;

  /// The target languages to translate
  List<String>? targetLanguages;

  /// It is Map, key is target language, value is translated content
  Map<String, String>? translations;
}
