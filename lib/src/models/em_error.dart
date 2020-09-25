import 'package:flutter/foundation.dart';

class EMError {

  EMError();

  int _code;
  String _description;

  get code {
    return _code;
  }

  get description {
    return _description;
  }

  factory EMError.fromJson(Map map) {
    if(map == null) return null;
    return EMError()
      .._code = map['code']
      .._description = map['description'];
  }

  static bool hasErrorFromResult(Map map) {
    EMError error = EMError.fromJson(map['error']);
    if(error == null) {
      return false;
    }
    throw(error);
  }
}