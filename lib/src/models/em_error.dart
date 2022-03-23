class EMError {
  EMError._private([int? code, String? desc])
      : _code = code ?? 0,
        _description = desc ?? "";

  late int _code;
  late String _description;

  int get code {
    return _code;
  }

  String get description {
    return _description;
  }

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
