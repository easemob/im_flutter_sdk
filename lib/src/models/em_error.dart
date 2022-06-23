///
/// SDK 定义的错误类。
///
class EMError {
  EMError._private(this.code, this.description);

  ///
  /// 错误码。
  ///
  final int code;

  ///
  /// 错误描述。
  ///
  final String description;

  /// @nodoc
  factory EMError.fromJson(Map map) {
    return EMError._private(map['code'], map['description']);
  }

  /// @nodoc
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
