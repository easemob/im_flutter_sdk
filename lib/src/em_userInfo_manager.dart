import 'dart:async';
import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'em_sdk_method.dart';
import 'models/em_userInfo.dart';

class EMUserInfoManager {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _channel = const MethodChannel(
      '$_channelPrefix/em_userInfo_manager', JSONMethodCodec());

  EMUserInfo _ownUserInfo;
  //当前登录用户id
  String _currentUserId;

  //有效的联系人map
  Map<String, EMUserInfo> effectiveUserInfoMap;

  EMUserInfoManager() {
    _channel.setMethodCallHandler((MethodCall call) {
      Map aMap = call.arguments;
      if (call.method == EMSDKMethod.updateOwnUserInfo) {}

      if (call.method == EMSDKMethod.updateOwnUserInfoWithType) {}

      if (call.method == EMSDKMethod.fetchUserInfoById) {}

      if (call.method == EMSDKMethod.fetchUserInfoByIdWithType) {}

      return null;
    });

    effectiveUserInfoMap = Map();
  }

  //更新自己的用户属性
  Future<EMUserInfo> updateOwnUserInfo(EMUserInfo userInfo) async {
    Map req = {'userInfo': userInfo.toJson()};
    Map result =
        await _channel.invokeMethod(EMSDKMethod.updateOwnUserInfo, req);
    EMError.hasErrorFromResult(result);
    return EMUserInfo.fromJson(result[EMSDKMethod.updateOwnUserInfo]);
  }

  //更新自己制定类型的用户属性
  Future<EMUserInfo> updateOwnUserInfoWithType(
      EMUserInfoType type, String userInfoValue) async {
    Map req = {
      'userInfoType': userInfoTypeToInt(type),
      'userInfoValue': userInfoValue
    };
    Map result =
        await _channel.invokeMethod(EMSDKMethod.updateOwnUserInfoWithType, req);

    EMError.hasErrorFromResult(result);

    return EMUserInfo.fromJson(result[EMSDKMethod.updateOwnUserInfoWithType]);
  }

  // //获取指定id的用户的用户属性
  // Future<Map> fetchUserInfoById(List<String> userIds) async {
  //   Map req = {'userIds': userIds};
  //   Map result =
  //       await _channel.invokeMethod(EMSDKMethod.fetchUserInfoById, req);

  //   EMError.hasErrorFromResult(result);
  //   Map tempMap = Map();
  //   result[EMSDKMethod.fetchUserInfoById].forEach((key, value) {
  //     tempMap[key] = EMUserInfo.fromJson(value);
  //   });

  //   return tempMap;
  // }

  //获取指定id的用户的用户属性
  Future<Map> fetchUserInfoByIdWithExpireTime(List<String> userIds,
      {int expireTime = 0}) async {
    List<String> reqIds = List();
    Map resultMap = Map();

    if (expireTime == 0) {
      reqIds = userIds;
    } else {
      reqIds = getRequestUserIds(userIds, expireTime);
      if (reqIds.length == 0) {
        userIds.forEach((element) {
          resultMap[element] = effectiveUserInfoMap[element];
        });
        return resultMap;
      } else {
        userIds.forEach((element) {
          if (!reqIds.contains(element)) {
            resultMap[element] = effectiveUserInfoMap[element];
          }
        });
      }
    }
    Map req = {'userIds': reqIds};
    Map result =
        await _channel.invokeMethod(EMSDKMethod.fetchUserInfoById, req);

    EMError.hasErrorFromResult(result);
    result[EMSDKMethod.fetchUserInfoById].forEach((key, value) {
      value['expireTime'] = DateTime.now().millisecondsSinceEpoch;
      EMUserInfo eUserInfo = EMUserInfo.fromJson(value);
      resultMap[key] = eUserInfo;
      //restore userInfos
      effectiveUserInfoMap[key] = eUserInfo;
    });

    return resultMap;
  }

  //获取需要更新的userIds
  List<String> getRequestUserIds(List<String> userIds, int expireTime) {
    List<String> reqIds = List();

    if (effectiveUserInfoMap.isEmpty) {
      reqIds.addAll(userIds);
    } else {
      userIds.forEach((element) {
        EMUserInfo cUserInfo = effectiveUserInfoMap[element];

        if (cUserInfo == null) {
          reqIds.add(element);
        } else {
          int interval = expireTime - cUserInfo.expireTime;
          if (interval > 0) {
            reqIds.add(element);
          }
        }
      });
    }
    return reqIds;
  }

  //获取指定id的用户的指定类型的用户属性
  Future<Map> fetchUserInfoByIdWithType(
      List<String> userIds, List<EMUserInfoType> types,
      {int expireTime = 0}) async {
    List<int> userInfoTypes = List();
    types.forEach((element) {
      int type = userInfoTypeToInt(element);
      userInfoTypes.add(type);
    });

    List<String> reqIds = List();
    Map resultMap = Map();

    if (expireTime == 0) {
      reqIds = userIds;
    } else {
      reqIds = getRequestUserIds(userIds, expireTime);
      if (reqIds.length == 0) {
        userIds.forEach((element) {
          resultMap[element] = effectiveUserInfoMap[element];
        });
        return resultMap;
      } else {
        userIds.forEach((element) {
          if (!reqIds.contains(element)) {
            resultMap[element] = effectiveUserInfoMap[element];
          }
        });
      }
    }

    Map req = {'userIds': reqIds, 'userInfoTypes': userInfoTypes};
    Map result =
        await _channel.invokeMethod(EMSDKMethod.fetchUserInfoByIdWithType, req);

    EMError.hasErrorFromResult(result);
    result[EMSDKMethod.fetchUserInfoByIdWithType].forEach((key, value) {
      value['expireTime'] = DateTime.now().millisecondsSinceEpoch;
      EMUserInfo eUserInfo = EMUserInfo.fromJson(value);
      resultMap[key] = eUserInfo;
      //restore userInfos
      effectiveUserInfoMap[key] = eUserInfo;
    });

    return resultMap;
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
  static int userInfoTypeToInt(EMUserInfoType type) {
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

  EMUserInfo getOwnUserInfo() {
    if (_ownUserInfo == null) {
      _ownUserInfo = EMUserInfo(EMClient.getInstance.currentUsername);
    }
    return _ownUserInfo;
  }

  void clearUserInfoCache() {
    effectiveUserInfoMap.clear();
  }
}
