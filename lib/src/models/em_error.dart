///
/// The error class defined by the SDK.
///
class EMError {
  EMError._private(this.code, this.description);

  ///
  /// The error code.
  ///
  final int code;

  ///
  /// The error description.
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
