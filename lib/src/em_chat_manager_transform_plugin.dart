import 'em_chat_manager.dart';
import 'internal/chat_method_keys.dart';
import 'internal/em_channel_manager.dart';
import 'models/em_error.dart';
import 'models/em_message.dart';
import 'models/em_translate_language.dart';

extension EMTransformPlugin on EMChatManager {
  ///
  /// Translate a message.
  ///
  /// Param [msg] The message object
  ///
  /// Param [languages] The target languages to translate
  ///
  /// **Return** Translated Message
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<EMMessage> translateMessage({
    required EMMessage msg,
    required List<String> languages,
  }) async {
    Map req = {};
    req["message"] = msg.toJson();
    req["languages"] = languages;
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.translateMessage, req);
    try {
      EMError.hasErrorFromResult(result);
      return EMMessage.fromJson(result["message"]);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Fetch all languages what the translate service support
  ///
  /// **Return** Supported languages
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<List<EMTranslateLanguage>?> fetchSupportedLanguages() async {
    Map result = await EMMethodChannel.ChatManager.invokeMethod(
        ChatMethodKeys.fetchSupportLanguages);
    try {
      EMError.hasErrorFromResult(result);
      List<EMTranslateLanguage>? list = [];
      result[ChatMethodKeys.fetchSupportLanguages]?.forEach((element) {
        list.add(EMTranslateLanguage.fromJson(element));
      });
      return list.length > 0 ? list : null;
    } on EMError catch (e) {
      throw e;
    }
  }
}
