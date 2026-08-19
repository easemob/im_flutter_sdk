/// ~english
/// The error class defined by the SDK.
/// ~end
///
/// ~chinese
/// SDK 定义的错误类。
/// ~end
class ChatError {
  ChatError(this.code, this.description);

  /// ~english
  /// The error code.
  /// ~end
  ///
  /// ~chinese
  /// 错误码。
  /// ~end
  final int code;

  /// ~english
  /// The error description.
  /// ~end
  ///
  /// ~chinese
  /// 错误描述。
  /// ~end
  final String description;

  factory ChatError.fromJson(Map map) {
    return ChatError(map['code'], map['description']);
  }

  static hasErrorFromResult(Map map) {
    if (map['error'] == null) {
      return;
    } else {
      try {
        throw (ChatError.fromJson(map['error']));
        // ignore: empty_catches
      } on Exception {}
    }
  }

  @override
  String toString() {
    return "code: $code desc: $description";
  }
}
