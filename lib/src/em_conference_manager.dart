import "dart:async";

import 'package:flutter/services.dart';
import 'em_sdk_method.dart';
import 'em_domain_terms.dart';

class EMConferenceManager {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emConferenceManagerChannel = const MethodChannel(
      '$_channelPrefix/em_conference_manager', JSONMethodCodec());

  /// @nodoc
  static EMConferenceManager _instance;

  /// @nodoc
  factory EMConferenceManager.getInstance() {
    return _instance = _instance ?? EMConferenceManager._internal();
  }

  /// @nodoc
  EMConferenceManager._internal() {
    _addNativeMethodCallHandler();
  }

  /// @nodoc
  void _addNativeMethodCallHandler() {
    _emConferenceManagerChannel.setMethodCallHandler((MethodCall call) {
      Map argMap = call.arguments;
      if (call.method == EMSDKMethod.onCallChanged) {
        return _onConferenceChanged(argMap);
      }
      return null;
    });
  }

  Future<void> _onConferenceChanged(Map event) async {}

  /// @nodoc 创建并加入会议
  /// @nodoc [aType] 会议类型，[password ] 会议密码，[isRecord ] 是否开启服务端录制，[isMerge ] 录制时是否合并数据流
  /// @nodoc 如果创建并加入会议成成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void createAndJoinConference(EMConferenceType conferenceType, String password,
      bool isRecord, bool isMerge,
      {onSuccess(EMConference conf), onError(int code, String desc)}) {
    Future<Map> result = _emConferenceManagerChannel
        .invokeMethod(EMSDKMethod.createAndJoinConference, {
      "conferenceType": toEMConferenceType(conferenceType),
      "password": password,
      "record": isRecord,
      "merge": isMerge
    });
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) {
          onSuccess(EMConference.from(response['value']));
        }
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  /// @nodoc 加入已有会议
  /// @nodoc [ConfId] 会议ID，[password ] 会议密码
  /// @nodoc 如果加入已有会议成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void joinConference(String confId, String password,
      {onSuccess(EMConference conf), onError(int code, String desc)}) {
    Future<Map> result = _emConferenceManagerChannel.invokeMethod(
        EMSDKMethod.joinConference, {"confId": confId, "password": password});
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess(EMConference.from(response['value']));
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///iOS端用来初始化会议通话单例，监听相关回调
  void registerConferenceSharedManager(){
    _emConferenceManagerChannel.invokeMethod(EMSDKMethod.registerConferenceSharedManager);
  }
}
