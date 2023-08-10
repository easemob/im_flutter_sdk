/// ~english
/// The translation language class, which contains the information of the translation languages.
/// ~end
///
/// ~chinese
/// 翻译语言类，包含翻译语言相关信息。
/// ~end
class EMTranslateLanguage {
  /// ~english
  /// The code of a target language. For example, the code for simplified Chinese is "zh-Hans".
  /// ~end
  ///
  /// ~chinese
  /// 目标语言代码，如中文简体为 "zh-Hans"。
  /// ~end
  final String languageCode;

  /// ~english
  /// The language name. For example, the code for simplified Chinese is "Chinese Simplified".
  /// ~end
  ///
  /// ~chinese
  /// 语言名称，如中文简体为 "Chinese Simplified"。
  /// ~end
  final String languageName;

  /// ~english
  /// The native name of the language. For example, the native name of simplified Chinese is "Chinese (Simplified)".
  /// ~end
  ///
  /// ~chinese
  /// 语言的原生名称，如中文简体为 "中文 (简体)"。
  /// ~end
  final String languageNativeName;

  EMTranslateLanguage._private({
    required this.languageCode,
    required this.languageName,
    required this.languageNativeName,
  });

  factory EMTranslateLanguage.fromJson(Map map) {
    String code = map["code"];
    String name = map["name"];
    String nativeName = map["nativeName"];
    return EMTranslateLanguage._private(
      languageCode: code,
      languageName: name,
      languageNativeName: nativeName,
    );
  }
}
