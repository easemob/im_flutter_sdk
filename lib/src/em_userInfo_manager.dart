import 'dart:async';
import 'package:flutter/services.dart';

import 'internal/chat_method_keys.dart';
import 'em_client.dart';
import 'models/em_error.dart';
import 'models/em_userInfo.dart';

///
/// The user information manager for updating and getting user properties.
///
class EMUserInfoManager {
  static const _channelPrefix = 'com.chat.im';
  static const MethodChannel _channel = const MethodChannel(
      '$_channelPrefix/chat_userInfo_manager', JSONMethodCodec());

  EMUserInfo? _ownUserInfo;

  //有效的联系人map
  Map<String, EMUserInfo> _effectiveUserInfoMap = Map();

  ///
  /// Modifies the current user's information.
  ///
  /// Param [userInfo] userInfo The user information to be modified.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> updateOwnUserInfo(EMUserInfo userInfo) async {
    Map req = {'userInfo': userInfo.toJson()};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.updateOwnUserInfo, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  @Deprecated("")
  Future<EMUserInfo?> updateOwnUserInfoWithType(
      EMUserInfoType type, String userInfoValue) async {
    Map req = {
      'userInfoType': _userInfoTypeToInt(type),
      'userInfoValue': userInfoValue
    };
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.updateOwnUserInfoWithType, req);
    try {
      EMError.hasErrorFromResult(result);
      if (result[ChatMethodKeys.updateOwnUserInfoWithType] != null) {
        _ownUserInfo = EMUserInfo.fromJson(
            result[ChatMethodKeys.updateOwnUserInfoWithType]);
        _effectiveUserInfoMap[_ownUserInfo!.userId] = _ownUserInfo!;
      }

      return _ownUserInfo;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Get the current user's information from server.
  ///
  /// Param [expireTime] expire time, Units are seconds. If the last fetch is less than the expiration time, it is directly fetched from the local cache;
  /// otherwise, it is fetched from the server.
  ///
  /// **return**  user properties. See {@link EMUserInfo}
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<EMUserInfo?> fetchOwnInfo({int expireTime = 0}) async {
    String? currentUser = await EMClient.getInstance.getCurrentUsername();
    if (currentUser != null) {
      try {
        Map<String, EMUserInfo> ret = await fetchUserInfoById(
          [currentUser],
          expireTime: expireTime,
        );
        _ownUserInfo = ret.values.first;
      } on EMError catch (e) {
        throw e;
      }
    }
    return _ownUserInfo;
  }

  ///
  /// Gets user information with user ID.
  ///
  /// Param [userIds] The user ID array.
  ///
  /// Param [expireTime] expire time, Units are seconds. If the last fetch is less than the expiration time, it is directly fetched from the local cache;
  /// otherwise, it is fetched from the server.
  ///
  /// **return** Map of User ids and user properties. key is user id and value is user properties.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<Map<String, EMUserInfo>> fetchUserInfoById(
    List<String> userIds, {
    int expireTime = 0,
  }) async {
    List<String> needReqIds = userIds
        .where((element) =>
            !_effectiveUserInfoMap.containsKey(element) ||
            (_effectiveUserInfoMap.containsKey(element) &&
                DateTime.now().millisecondsSinceEpoch -
                        _effectiveUserInfoMap[element]!.expireTime >
                    expireTime * 1000))
        .toList();
    Map<String, EMUserInfo> resultMap = Map();

    userIds.forEach((element) {
      if (_effectiveUserInfoMap.containsKey(element)) {
        resultMap[element] = _effectiveUserInfoMap[element]!;
      }
    });
    if (needReqIds.length == 0) {
      return resultMap;
    }

    Map req = {'userIds': needReqIds};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.fetchUserInfoById, req);

    try {
      EMError.hasErrorFromResult(result);
      result[ChatMethodKeys.fetchUserInfoById]?.forEach((key, value) {
        EMUserInfo eUserInfo = EMUserInfo.fromJson(value);
        resultMap[key] = eUserInfo;
        _effectiveUserInfoMap[key] = eUserInfo;
      });
      return resultMap;
    } on EMError catch (e) {
      throw e;
    }
  }

  @Deprecated(
      'Use userInfoManager.fetchUserInfoByIdWithExpireTime() method instead.')
  Future<Map<String, EMUserInfo>> fetchUserInfoByIdWithType(
      List<String> userIds, List<EMUserInfoType> types,
      {int expireTime = 3600}) async {
    List<int> userInfoTypes = [];
    types.forEach((element) {
      int type = _userInfoTypeToInt(element);
      userInfoTypes.add(type);
    });

    List<String> reqIds = userIds
        .where((element) =>
            !_effectiveUserInfoMap.containsKey(element) ||
            (_effectiveUserInfoMap.containsKey(element) &&
                DateTime.now().millisecondsSinceEpoch -
                        _effectiveUserInfoMap[element]!.expireTime >
                    expireTime * 1000))
        .toList();
    Map resultMap = Map();

    Map req = {'userIds': reqIds, 'userInfoTypes': userInfoTypes};
    Map result = await _channel.invokeMethod(
        ChatMethodKeys.fetchUserInfoByIdWithType, req);

    try {
      EMError.hasErrorFromResult(result);
      result[ChatMethodKeys.fetchUserInfoByIdWithType].forEach((key, value) {
        EMUserInfo eUserInfo = EMUserInfo.fromJson(value);
        resultMap[key] = eUserInfo;

        _effectiveUserInfoMap[key] = eUserInfo;
      });

      return resultMap as FutureOr<Map<String, EMUserInfo>>;
    } on EMError catch (e) {
      throw e;
    }
  }

  static int _userInfoTypeToInt(EMUserInfoType type) {
    int ret = 0;
    switch (type) {
      case EMUserInfoType.NickName:
        {
          ret = 0;
        }
        break;
      case EMUserInfoType.AvatarURL:
        {
          ret = 1;
        }
        break;
      case EMUserInfoType.Phone:
        {
          ret = 2;
        }
        break;
      case EMUserInfoType.Mail:
        {
          ret = 3;
        }
        break;
      case EMUserInfoType.Gender:
        {
          ret = 4;
        }
        break;
      case EMUserInfoType.Sign:
        {
          ret = 5;
        }
        break;
      case EMUserInfoType.Birth:
        {
          ret = 6;
        }
        break;
      case EMUserInfoType.Ext:
        {
          ret = 7;
        }
    }
    return ret;
  }

  void clearUserInfoCache() {
    _ownUserInfo = null;
    _effectiveUserInfoMap.clear();
  }
}
