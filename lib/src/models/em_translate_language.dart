///
///  The translation language class, which contains the information of the translation languages.
///
class EMTranslateLanguage {
  final String languageCode;
  final String languageName;
  final String languageNativeName;

  EMTranslateLanguage._private({
    /// The code of a target language. For example, the code for simplified Chinese is "zh-Hans".
    required this.languageCode,

    /// The language name. For example, the code for simplified Chinese is "Chinese Simplified".
    required this.languageName,

    /// The native name of the language. For example, the native name of simplified Chinese is "Chinese (Simplified)".
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
