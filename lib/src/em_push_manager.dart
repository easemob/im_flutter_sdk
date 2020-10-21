import 'package:flutter/services.dart';

import 'em_sdk_method.dart';
import 'models/em_domain_terms.dart';


class EMPushManager{
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _channel = const MethodChannel('$_channelPrefix/em_push_manager', JSONMethodCodec());

  /// 从本地获取ImPushConfigs
  Future<EMImPushConfigs> getImPushConfigs() async {
    Map result = await _channel.invokeMethod(EMSDKMethod.getImPushConfigs);
    EMError.hasErrorFromResult(result);
    return EMImPushConfigs.fromJson(result[EMSDKMethod.getImPushConfigs]);
  }

  /// 从服务器获取ImPushConfigs
  Future<EMImPushConfigs> getImPushConfigsFromServer() async{
    Map result = await _channel.invokeMethod(EMSDKMethod.getImPushConfigsFromServer);
    EMError.hasErrorFromResult(result);
    return EMImPushConfigs.fromJson(result[EMSDKMethod.getImPushConfigsFromServer]);
  }

  /// 更新当前用户的[nickname],这样离线消息推送的时候可以显示用户昵称而不是id，需要登录环信服务器成功后调用才生效
  Future<bool> updatePushNickname (String nickname) async{
    Map req = {'nickname' : nickname};
    Map result = await _channel.invokeMethod(EMSDKMethod.updatePushNickname, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.updatePushNickname);
  }
}