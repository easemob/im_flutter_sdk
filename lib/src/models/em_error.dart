import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class EMError {
  EMError._private([this._code, this._description]);

  int _code;
  String _description;

  get code {
    return _code;
  }

  get description {
    return _description;
  }

  factory EMError.fromJson(Map map) {
    if (map == null) return null;
    return EMError._private()
      .._code = map['code']
      .._description = map['description'];
  }

//  static EMError hasErrorFromResult(Map map) {
//    EMError error = EMError.fromJson(map['error']);
//    return error;
//  }

  static hasErrorFromResult(Map map) {
    EMError error = EMError.fromJson(map['error']);
    if (error != null) {
      EMLog.v('error - ' + error.toString());
      throw (error);
    }
  }

  @override
  String toString() {
    return "code: " + _code.toString() + " desc: " + _description;
  }
}
