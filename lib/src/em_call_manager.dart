import "dart:async";

import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/src/em_call_setup.dart';
import 'em_sdk_method.dart';

class EMCallManager {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emCallManagerChannel =
  const MethodChannel('$_channelPrefix/em_call_manager', JSONMethodCodec());

  /// @nodoc
  static EMCallManager _instance;

  /// @nodoc
  final List<EMCallStateChangeListener> _callStateChangeListeners =  List<EMCallStateChangeListener>();

  /// @nodoc
  factory EMCallManager.getInstance() {
    return _instance = _instance ?? EMCallManager._internal();
  }

  /// @nodoc
  EMCallManager._internal(){
    _addNativeMethodCallHandler();
  }

  void addCallStateChangeListener(EMCallStateChangeListener listener){
    assert(listener != null);
    _callStateChangeListeners.add(listener);
  }

  void removeCallStateChangeListener(EMCallStateChangeListener listener){
    assert(listener != null);
    _callStateChangeListeners.remove(listener);
  }

  /// @nodoc
  void _addNativeMethodCallHandler() {
    _emCallManagerChannel.setMethodCallHandler((MethodCall call) {
      Map argMap = call.arguments;
      if (call.method == EMSDKMethod.onCallChanged) {
         _onCallChanged(argMap);
      }
      return null;
    });
  }

  Future<void> _onCallChanged(Map event) async{
    String type = event['type'];
    for (var listener in _callStateChangeListeners) {
      switch(type){
        case EMCallEvent.ON_CONNECTING:
          listener.onConnecting();
          break;
        case EMCallEvent.ON_CONNECTED:
          listener.onConnected();
          break;
        case EMCallEvent.ON_ACCEPTED:
          listener.onAccepted();
          break;
        case EMCallEvent.ON_NET_WORK_DISCONNECTED:
          listener.onNetWorkDisconnected();
          break;
        case EMCallEvent.ON_NET_WORK_UNSTABLE:
          listener.onNetworkUnstable();
          break;
        case EMCallEvent.ON_NET_WORK_NORMAL:
          listener.onNetWorkNormal();
          break;
        case EMCallEvent.ON_NET_VIDEO_PAUSE:
          listener.onNetVideoPause();
          break;
        case EMCallEvent.ON_NET_VIDEO_RESUME:
          listener.onNetVideoResume();
          break;
        case EMCallEvent.ON_NET_VOICE_PAUSE:
          listener.onNetVoicePause();
          break;
        case EMCallEvent.ON_NET_VOICE_RESUME:
          listener.onNetVoiceResume();
          break;
        case EMCallEvent.ON_DISCONNECTED:
          listener.onDisconnected(fromCallReason(event['reason']));
          break;
      }
    }
  }

  /// @nodoc 发起实时会话
  /// @nodoc [type] 通话类型，[remoteName] 被呼叫的用户（不能与自己通话），[isRecord] 是否开启服务端录制，[isMerge] 录制时是否合并数据流，[ext] 通话扩展信息，会传给被呼叫方
  /// @nodoc 如果发起实时会话成功，请调用[onSuccess]，如果出现错误，请调用[onError]。
  void startCall(
      EMCallType callType,
      String remoteName,
      bool isRecord,
      bool isMerge,
      String ext,
      {onSuccess(),
        onError(int code, String desc)}) {
    Future<Map> result = _emCallManagerChannel.invokeMethod(
        EMSDKMethod.startCall, {"callType": toEMCallType(callType),"remoteName": remoteName ,"record": isRecord ,"mergeStream": isMerge ,"ext": ext});
    result.then((response) {
      if (response["success"]) {
        if (onSuccess != null) onSuccess();
      } else {
        if (onError != null) onError(response['code'], response['desc']);
      }
    });
  }

  ///设置通话配置
  void setCallOptions(EMCallOptions options){
    _emCallManagerChannel.invokeMethod(EMSDKMethod.setCallOptions,convertToMap(options));
  }

  /// 获取通话ID
  Future<String> getCallId() async {
    Map result = await _emCallManagerChannel.invokeMethod(EMSDKMethod.getCallId);
    if (result['success']) {
      return result['value'];
    }
  }

  /// 获取通话状态
  Future<ConnectTypes> getConnectType() async {
    Map result = await _emCallManagerChannel.invokeMethod(EMSDKMethod.getConnectType);
    if (result['success']) {
      return fromConnectTypes(result['value']);
    }
  }

  /// 获取通话扩展
  Future<String> getExt() async {
    Map result = await _emCallManagerChannel.invokeMethod(EMSDKMethod.getExt);
    if (result['success']) {
      return result['value'];
    }
  }

  /// 获取本地通话userName
  Future<String> getLocalName() async{
    Map result = await _emCallManagerChannel.invokeMethod(EMSDKMethod.getLocalName);
    if (result['success']) {
      return result['value'];
    }
  }

  /// 获取远程通话userName
  Future<String> getRemoteName() async{
    Map result = await _emCallManagerChannel.invokeMethod(EMSDKMethod.getRemoteName);
    if (result['success']) {
      return result['value'];
    }
  }

  /// 获取服务端录制ID
  Future<String> getServerRecordId() async{
    Map result = await _emCallManagerChannel.invokeMethod(EMSDKMethod.getServerRecordId);
    if (result['success']) {
      return result['value'];
    }
  }

  /// 获取通话类型 VOICE/VIDEO
  Future<EMCallType> getCallType() async{
    Map result = await _emCallManagerChannel.invokeMethod(EMSDKMethod.getCallType);
    if (result['success']) {
      return fromCallType(result['value']);
    }
  }

  /// 是否开启录制
  Future<bool> isRecordOnServer() async{
    Map result = await _emCallManagerChannel.invokeMethod(EMSDKMethod.isRecordOnServer);
    if (result['success']) {
      return result['value'];
    }
  }

  /// Android端用来注册广播服务调起音视频通话界面
  void registerCallReceiver(){
    _emCallManagerChannel.invokeMethod(EMSDKMethod.registerCallReceiver);
  }

  ///iOS端用来初始化1v1通话单例，监听相关回调
  void registerCallSharedManager(){
    _emCallManagerChannel.invokeMethod(EMSDKMethod.registerCallSharedManager);
  }

}