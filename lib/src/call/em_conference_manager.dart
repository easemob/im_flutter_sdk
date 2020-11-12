import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class EMConferenceManager {

  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _channel = const MethodChannel('$_channelPrefix/em_conference_manager', JSONMethodCodec());

  EMConferenceManager(){
    _registerCallHandler();
  }

  void _registerCallHandler() {
    _channel.setMethodCallHandler((MethodCall call) {
      Map argMap = call.arguments;
      print(argMap);
      return null;
    });
  }

  /// 设置会议使用的[appKey], [username], [token]
  Future<bool>setConference(String appKey, String username, String token) async {
    Map req = {'appKey': appKey, 'username': username, 'token': token};
    Map result = await _channel.invokeMethod(EMSDKMethod.setConferenceAppKey, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.setConferenceAppKey);
  }

  /// 根据[conferenceId], [password] 判断会议是否存在
  Future<bool> conferenceHasExists (String conferenceId, String password) async {
    Map req = {'conf_id':conferenceId, 'pwd': password};
    Map result = await _channel.invokeMethod(EMSDKMethod.conferenceHasExists, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.conferenceHasExists);
  }

  /// 根据[conferenceId], [password] 加入Conference
  Future<EMConference> joinConference (String conferenceId, String password) async {
    Map req = {'conf_id':conferenceId, 'pwd': password};
    Map result = await _channel.invokeMethod(EMSDKMethod.joinConference, req);
    EMError.hasErrorFromResult(result);
    return EMConference.fromJson(result[EMSDKMethod.joinConference]);
  }

  /// 根据[房间名], [password] 加入Conference
  Future<EMConference> joinRoom (String roomName, String password, [int conferenceRole = 0]) async {
    Map req = {'roomName':roomName, 'pwd': password, 'role': conferenceRole};
    Map result = await _channel.invokeMethod(EMSDKMethod.joinRoom, req);
    EMError.hasErrorFromResult(result);
    return EMConference.fromJson(result[EMSDKMethod.joinRoom]);
  }

}
