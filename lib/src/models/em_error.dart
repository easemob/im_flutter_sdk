class EMError {
  EMError._private([this._code, this._description]);

  int? _code = 0;
  String? _description;

  get code {
    return _code;
  }

  get description {
    return _description;
  }

  factory EMError.fromJson(Map map) {
    return EMError._private()
      .._code = map['code']
      .._description = map['description'];
  }

//  static EMError hasErrorFromResult(Map map) {
//    EMError error = EMError.fromJson(map['error']);
//    return error;
//  }

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
    return "code: " + _code.toString() + " desc: " + _description!;
  }
}
