import 'package:flutter/foundation.dart';

class EMError {

  EMError();

  int code;
  String description;

  factory EMError.fromJson(Map map) {
    if(map == null) return null;
    return EMError()
      ..code = map['code']
      ..description = map['description'];
  }

  static bool hasErrorFromResult(Map map) {
    EMError error = EMError.fromJson(map['error']);
    if(error == null) {
      return false;
    }
    throw(error);
  }
}