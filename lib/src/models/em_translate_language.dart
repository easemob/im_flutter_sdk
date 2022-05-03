class EMTranslateLanguage {
  final String languageCode;
  final String languageName;
  final String languageNativeName;

  ///
  /// 翻译语言类。
  ///
  EMTranslateLanguage._private({
    /// 语言代码，如中文简体为"zh-Hans"
    required this.languageCode,

    /// 语言名称，如中文简体为"Chinese Simplified"
    required this.languageName,

    /// 语言的原生名称，如中文简体为"中文 (简体)"
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
