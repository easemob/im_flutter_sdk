import '../tools/em_extension.dart';

import 'em_chat_enums.dart';
import 'em_message_body.dart';

///
/// 文本消息类。
///
class EMTextMessageBody extends EMMessageBody {
  ///
  /// 创建一条文本消息。
  ///
  /// Param [content] 文本消息内容。
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

  /// 文本消息内容。
  late final String content;

  /// 翻译的目标语言
  List<String>? targetLanguages;

  /// 翻译结果
  Map<String, String>? translations;
}
