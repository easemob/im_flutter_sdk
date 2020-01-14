import "dart:async";

import 'package:flutter/services.dart';
import 'em_sdk_method.dart';

class EMCallManager {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emCallManagerChannel =
  const MethodChannel('$_channelPrefix/em_call_manager', JSONMethodCodec());

  /// @nodoc
  static EMCallManager _instance;

  /// @nodoc
//  final List<EMCallEventListener> _callEventListeners =  List<EMCallEventListener>();

  /// @nodoc
  factory EMCallManager.getInstance() {
    return _instance = _instance ?? EMCallManager._internal();
  }

  /// @nodoc
  EMCallManager._internal(){
    _addNativeMethodCallHandler();
  }

  /// @nodoc
  void _addNativeMethodCallHandler() {
    _emCallManagerChannel.setMethodCallHandler((MethodCall call) {
      Map argMap = call.arguments;

      return null;
    });
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

  toEMCallType(EMCallType type) {
    if(type == EMCallType.Voice) {
      return 0;
    } else {
      return 1;
    }
  }
}

/// @nodoc EMCallType -  通话枚举的类型。
enum EMCallType {
  Voice,
  Video
}