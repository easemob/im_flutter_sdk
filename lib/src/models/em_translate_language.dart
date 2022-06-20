class EMTranslateLanguage {
  final String languageCode;
  final String languageName;
  final String languageNativeName;

  ///
  /// The language class, used for encapsulation of language information.
  ///
  EMTranslateLanguage._private({
    /// The language code.
    required this.languageCode,

    /// The language name.
    required this.languageName,

    /// The display name of the language on the device.
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
