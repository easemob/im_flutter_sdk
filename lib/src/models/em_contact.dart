import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'em_userInfo.dart';

class EMContact {
  EMContact(this.userId);

  String _markName;

  /// 用户id
  String userId;

  /// 从缓存中获取用户属性，只有使用[EMUserInfoManager]从服务器获取过该用户属性才生效
  EMUserInfo get userInfo =>
      EMClient.getInstance.userInfoManager.getCacheInfo(userId);

  /// 获取用户昵称或者id。当对方设置过昵称并使用[EMUserInfoManager]从服务器获取过该用户属性才会返回昵称，否则返回用户id
  String get nickNameOfUserId => userInfo.nickName ?? userId;

  /// 获取备注名缓存
  @Deprecated("Use nickNameOfUserId")
  String get markName => _markName ?? userInfo.nickName ?? userId;

  /// 设置备注名缓存，应用重启后失效
  @Deprecated("")
  Future<void> setMarkName(String markName) async {
    _markName = markName;
  }
}
