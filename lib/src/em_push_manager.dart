import 'dart:io';

import 'package:flutter/services.dart';

import 'em_sdk_method.dart';
import 'models/em_domain_terms.dart';

class EMPushManager {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _channel = const MethodChannel('$_channelPrefix/em_push_manager', JSONMethodCodec());

  /// 从本地获取ImPushConfig
  Future<EMImPushConfig> getImPushConfig() async {
    Map result = await _channel.invokeMethod(EMSDKMethod.getImPushConfig);
    EMError.hasErrorFromResult(result);
    return EMImPushConfig.fromJson(result[EMSDKMethod.getImPushConfig]);
  }

  /// 从服务器获取ImPushConfig
  Future<EMImPushConfig> getImPushConfigFromServer() async {
    Map result = await _channel.invokeMethod(EMSDKMethod.getImPushConfigFromServer);
    EMError.hasErrorFromResult(result);
    return EMImPushConfig.fromJson(result[EMSDKMethod.getImPushConfigFromServer]);
  }

  /// 更新当前用户的[nickname],这样离线消息推送的时候可以显示用户昵称而不是id，需要登录环信服务器成功后调用才生效
  Future<bool?> updatePushNickname(String nickname) async {
    Map req = {'nickname': nickname};
    Map result = await _channel.invokeMethod(EMSDKMethod.updatePushNickname, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.updatePushNickname);
  }

  /// 上传华为推送token, 需要确保登录成功后再调用(可以是进入home页面后)
  Future<bool?> updateHMSPushToken(String token) async {
    if (Platform.isAndroid) {
      Map req = {'token': token};
      Map result = await _channel.invokeMethod(EMSDKMethod.updateHMSPushToken, req);
      EMError.hasErrorFromResult(result);
      return result.boolValue(EMSDKMethod.updateHMSPushToken);
    }
    return true;
  }

  /// 上传FCM推送token, 需要确保登录成功后再调用(可以是进入home页面后)
  Future<bool?> updateFCMPushToken(String token) async {
    if (Platform.isAndroid) {
      Map req = {'token': token};
      Map result = await _channel.invokeMethod(EMSDKMethod.updateFCMPushToken, req);
      EMError.hasErrorFromResult(result);
      return result.boolValue(EMSDKMethod.updateFCMPushToken);
    }
    return true;
  }

  /// 上传iOS推送deviceToken
  Future<bool> updateAPNsDeviceToken(String token) async {
    if (Platform.isIOS) {
      Map req = {'token': token};
      Map result = await _channel.invokeMethod(EMSDKMethod.updateAPNsPushToken, req);
      EMError.hasErrorFromResult(result);
      return true;
    }
    return true;
  }
}
