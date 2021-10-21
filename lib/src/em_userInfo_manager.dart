import 'dart:async';
import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'em_sdk_method.dart';
import 'models/em_userInfo.dart';

class EMUserInfoManager {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _channel = const MethodChannel(
      '$_channelPrefix/em_userInfo_manager', JSONMethodCodec());

  EMUserInfo? _ownUserInfo;

  //有效的联系人map
  Map<String, EMUserInfo> _effectiveUserInfoMap = Map();

  EMUserInfoManager();

  //更新自己的用户属性
  Future<EMUserInfo?> updateOwnUserInfo(EMUserInfo userInfo) async {
    Map req = {'userInfo': userInfo.toJson()};
    Map result =
        await _channel.invokeMethod(EMSDKMethod.updateOwnUserInfo, req);
    EMError.hasErrorFromResult(result);
    return EMUserInfo.fromJson(result[EMSDKMethod.updateOwnUserInfo]);
  }

  /// 更新自己用户属性
  Future<EMUserInfo?> updateOwnUserInfoWithType(
      EMUserInfoType type, String userInfoValue) async {
    Map req = {
      'userInfoType': _userInfoTypeToInt(type),
      'userInfoValue': userInfoValue
    };
    Map result =
        await _channel.invokeMethod(EMSDKMethod.updateOwnUserInfoWithType, req);
    EMError.hasErrorFromResult(result);
    if (result[EMSDKMethod.updateOwnUserInfoWithType] != null) {
      _ownUserInfo =
          EMUserInfo.fromJson(result[EMSDKMethod.updateOwnUserInfoWithType]);
      _effectiveUserInfoMap[_ownUserInfo!.userId] = _ownUserInfo!;
    }

    return _ownUserInfo;
  }

  Future<EMUserInfo?> fetchOwnInfo({int expireTime = 3600}) async {
    if (EMClient.getInstance.currentUsername != null) {
      Map<String, EMUserInfo> ret = await fetchUserInfoByIdWithExpireTime(
          [EMClient.getInstance.currentUsername!],
          expireTime: expireTime);
      _ownUserInfo = ret.values.first;
    }
    return _ownUserInfo;
  }

  /// 获取指定id的用户的用户属性,
  /// `userIds` 需要获取的环信id;
  /// `expireTime` 过期时间，单位秒。如果之前获取过, 如果距当前时间小于过期时间则不会重复获取
  Future<Map<String, EMUserInfo>> fetchUserInfoByIdWithExpireTime(
      List<String> userIds,
      {int expireTime = 3600}) async {
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
        await _channel.invokeMethod(EMSDKMethod.fetchUserInfoById, req);
    EMError.hasErrorFromResult(result);
    result[EMSDKMethod.fetchUserInfoById]?.forEach((key, value) {
      EMUserInfo eUserInfo = EMUserInfo.fromJson(value);
      resultMap[key] = eUserInfo;
      _effectiveUserInfoMap[key] = eUserInfo;
    });

    return resultMap;
  }

  /// 获取指定id的用户的指定类型的用户属性
  /// `userIds` 需要获取的环信id;
  /// `types` 需要获取的属性
  /// `expireTime` 过期时间，单位秒。如果之前获取过, 如果距当前时间小于过期时间则不会重复获取
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
    Map result =
        await _channel.invokeMethod(EMSDKMethod.fetchUserInfoByIdWithType, req);

    EMError.hasErrorFromResult(result);
    result[EMSDKMethod.fetchUserInfoByIdWithType].forEach((key, value) {
      EMUserInfo eUserInfo = EMUserInfo.fromJson(value);
      resultMap[key] = eUserInfo;

      _effectiveUserInfoMap[key] = eUserInfo;
    });

    return resultMap as FutureOr<Map<String, EMUserInfo>>;
  }

  // 整型转化用户属性类型 【int => EMUserInfoType】
  static EMUserInfoType userInfoTypeFromInt(int type) {
    EMUserInfoType ret = EMUserInfoType.EMUserInfoTypeNickName;
    switch (type) {
      case 0:
        {
          ret = EMUserInfoType.EMUserInfoTypeNickName;
        }
        break;
      case 1:
        {
          ret = EMUserInfoType.EMUserInfoTypeAvatarURL;
        }
        break;
      case 2:
        {
          ret = EMUserInfoType.EMUserInfoTypePhone;
        }
        break;
      case 3:
        {
          ret = EMUserInfoType.EMUserInfoTypeMail;
        }
        break;
      case 4:
        {
          ret = EMUserInfoType.EMUserInfoTypeGender;
        }
        break;
      case 5:
        {
          ret = EMUserInfoType.EMUserInfoTypeSign;
        }
        break;
      case 6:
        {
          ret = EMUserInfoType.EMUserInfoTypeBirth;
        }
        break;
      case 7:
        {
          ret = EMUserInfoType.EMUserInfoTypeExt;
        }
    }
    return ret;
  }

  // 用户属性类型转化整型 【EMUserInfoType => int】
  static int _userInfoTypeToInt(EMUserInfoType type) {
    int ret = 0;
    switch (type) {
      case EMUserInfoType.EMUserInfoTypeNickName:
        {
          ret = 0;
        }
        break;
      case EMUserInfoType.EMUserInfoTypeAvatarURL:
        {
          ret = 1;
        }
        break;
      case EMUserInfoType.EMUserInfoTypePhone:
        {
          ret = 2;
        }
        break;
      case EMUserInfoType.EMUserInfoTypeMail:
        {
          ret = 3;
        }
        break;
      case EMUserInfoType.EMUserInfoTypeGender:
        {
          ret = 4;
        }
        break;
      case EMUserInfoType.EMUserInfoTypeSign:
        {
          ret = 5;
        }
        break;
      case EMUserInfoType.EMUserInfoTypeBirth:
        {
          ret = 6;
        }
        break;
      case EMUserInfoType.EMUserInfoTypeExt:
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
