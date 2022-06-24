///
///  翻译语言类，包含翻译语言相关信息。
///
class EMTranslateLanguage {
  /// 目标语言代码，如中文简体为 "zh-Hans"。
  final String languageCode;

  /// 语言名称，如中文简体为 "Chinese Simplified"。
  final String languageName;

  /// 语言的原生名称，如中文简体为 "中文 (简体)"。
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
