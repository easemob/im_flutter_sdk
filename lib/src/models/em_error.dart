/// ~english
/// The error class defined by the SDK.
/// ~end
///
/// ~chinese
/// SDK 定义的错误类。
/// ~end
class EMError {
  EMError._private(this.code, this.description);

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

  factory EMError.fromJson(Map map) {
    return EMError._private(map['code'], map['description']);
  }

  static hasErrorFromResult(Map map) {
    if (map['error'] == null) {
      return;
    } else {
      try {
        throw (EMError.fromJson(map['error']));
      } on Exception {}
    }
  }

  @override
  String toString() {
    return "code: " + code.toString() + " desc: " + description;
  }
}
