import 'em_userInfo.dart';

class EMContact {
  factory EMContact.fromJson(Map map) {
    return EMContact._private().._userInfo = EMUserInfo.fromJson(map);
  }

  Map toJson() {
    Map data = Map();
    data = _userInfo.toJson();
    return data;
  }

  EMContact._private();

  EMUserInfo _userInfo;

  String _markName;

  //用户属性
  EMUserInfo get userInfo => _userInfo;

  /// 备注名称
  String get markName => _markName ?? _userInfo.nickName ?? _userInfo.userId;

  Future<void> setMarkName(String markName) async {
    _markName = markName;
  }
}
