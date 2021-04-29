import 'dart:async';
import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'em_sdk_method.dart';
import 'models/em_userInfo.dart';

enum EMUserInfoType {
  EMUserInfoTypeNickName,
  EMUserInfoTypeAvatarURL,
  EMUserInfoTypePhone,
  EMUserInfoTypeMail,
  EMUserInfoTypeGender,
  EMUserInfoTypeSign,
  EMUserInfoTypeBirth,
  EMUserInfoTypeExt,
}

class EMUserInfoManager {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _channel = const MethodChannel(
      '$_channelPrefix/em_userInfo_manager', JSONMethodCodec());

  EMUserInfo _ownUserInfo;

  EMUserInfoManager() {
    _channel.setMethodCallHandler((MethodCall call) {
      Map aMap = call.arguments;
      if (call.method == EMSDKMethod.updateOwnUserInfo) {
        updateOwnUserInfo(aMap);
      }

      if (call.method == EMSDKMethod.updateOwnUserInfoWithType) {
        EMUserInfoType key = aMap['userInfoType'];
        String value = aMap['userInfoValue'];
        updateOwnUserInfoWithType(key, value);
      }

      if (call.method == EMSDKMethod.fetchUserInfoById) {
        List<String> userIds = aMap['userIds'];
        fetchUserInfoById(userIds);
      }

      if (call.method == EMSDKMethod.fetchUserInfoByIdWithType) {}

      return null;
    });
  }

  Future<EMUserInfo> updateOwnUserInfo(Map aMap) async {
    Map req = {'userInfo': aMap};
    Map result =
        await _channel.invokeMethod(EMSDKMethod.updateOwnUserInfo, req);
    EMError.hasErrorFromResult(result);
    return EMUserInfo.fromJson(result[EMSDKMethod.updateOwnUserInfo]);
  }

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

  Future<Map> fetchUserInfoById(List<String> userIds) async {
    Map req = {'userIds': userIds};
    Map result =
        await _channel.invokeMethod(EMSDKMethod.fetchUserInfoById, req);

    EMError.hasErrorFromResult(result);
    Map tempMap = Map();
    result[EMSDKMethod.fetchUserInfoById].forEach((key, value) {
      tempMap[key] = EMUserInfo.fromJson(value);
    });

    return tempMap;
  }

  Future<Map> fetchUserInfoByIdWithType(
      List<String> userIds, List<EMUserInfoType> types) async {
    List<int> userInfoTypes = List();
    types.forEach((element) {
      int type = userInfoTypeToInt(element);
      userInfoTypes.add(type);
    });

    Map req = {'userIds': userIds, 'userInfoTypes': userInfoTypes};
    Map result =
        await _channel.invokeMethod(EMSDKMethod.fetchUserInfoByIdWithType, req);
    EMError.hasErrorFromResult(result);

    Map tempMap = Map();
    result[EMSDKMethod.fetchUserInfoByIdWithType].forEach((key, value) {
      tempMap[key] = EMUserInfo.fromJson(value);
    });

    return tempMap;
  }

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
}
