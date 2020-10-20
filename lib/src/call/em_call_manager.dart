import "dart:async";

import 'package:flutter/services.dart';
import '../models/em_domain_terms.dart';
import '../em_sdk_method.dart';
import 'em_call_setups.dart';

class EMCallManager {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emCallManagerChannel = const MethodChannel('$_channelPrefix/em_call_manager', JSONMethodCodec());

  EMCallManager(){
    _emCallManagerChannel.setMethodCallHandler((MethodCall call) {
      Map argMap = call.arguments;
      if(call.method == EMSDKMethod.onCallReceived) {
        _onCallReceived(argMap);
      }else if(call.method == EMSDKMethod.onCallDidEnd) {
        _onCallDidEnd(argMap);
      }
      return null;
    });
  }

  final List<EMCallManagerListener> _callManagerListener =  List<EMCallManagerListener>();

  void addCallManagerListener(EMCallManagerListener listener) {
    if(!_callManagerListener.contains(listener)) {
      _callManagerListener.add(listener);
    }
  }

  void removeCallManagerListener(EMCallManagerListener listener) => _callManagerListener.remove(listener);

  /// 获取EMCallOptions;
  Future<EMCallOptions>getCallOptions() async {
    Map result = await _emCallManagerChannel.invokeMethod(EMSDKMethod.getCallOptions);
    EMError.hasErrorFromResult(result);
    return EMCallOptions.fromJson(result[EMSDKMethod.getCallOptions]);
  }

  /// 设置EMCallOptions;
  Future<bool>setCallOptions(EMCallOptions options) async {
    Map req = options.toJson();
    Map result = await _emCallManagerChannel.invokeMethod(EMSDKMethod.setCallOptions,req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(result[EMSDKMethod.setCallOptions]);
  }

  /// 发起1v1实时会话
  /// 通话类型[type], 被叫方环信id[remote], 是否开启服务器录制[isRecord], 服务器端是否合并流[isMerge], 带给对方的其他信息[ext]
  Future<EMCallSession> startCall(EMCallType type, String remote, [bool isRecord = false, isMerge = false, String ext = '']) async {
    Map req = {"type": type.index ,"remote": remote ,"record": isRecord ,"merge": isMerge ,"ext": ext};
    Map result = await _emCallManagerChannel.invokeMethod(EMSDKMethod.startCall, req);
    EMError.hasErrorFromResult(result);
    return EMCallSession.fromJson(result[EMSDKMethod.startCall]);
  }

  /// 根据通话id[callId] 接听1v1通话，
  Future<bool> answerIncomingCall(String callId) async {
    Map req = {"callId": callId};
    Map result = await _emCallManagerChannel.invokeMethod(EMSDKMethod.answerComingCall, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.answerComingCall);
  }

  /// 根据通话id[callId], [reason] 结束1v1通话，
  Future<bool> endCall(String callId, [EMCallEndReason reason = EMCallEndReason.Hangup]) async {
    Map req = {"callId": callId, 'reason': reason.index};
    Map result = await _emCallManagerChannel.invokeMethod(EMSDKMethod.endCall, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.endCall);
  }

  /// 删除再使用的view[viewId]
  Future<bool> releaseVideoView(int viewId) async {
    Map req = {"viewId": viewId};
    Map result = await _emCallManagerChannel.invokeMethod(EMSDKMethod.releaseView, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.releaseView);
  }

  // 收到呼叫回调
  Future<Null> _onCallReceived(Map event) async {
    _callManagerListener.forEach((element) {
      element.onCallReceived(EMCallSession.fromJson(event['callSession']));
    });
  }

  // 结束呼叫回调
  Future<Null> _onCallDidEnd(Map event) async {
    _callManagerListener.forEach((element) {
      element.onCallDidEnd(
        EMCallSession.fromJson(event['callSession']),
        EMCallEndReason.values[event['reason']],
        EMError.fromJson(event['error']),
      );
    });
  }
}


/// CallManager listener
abstract class EMCallManagerListener{

  /// 收到被叫邀请[session]
  void onCallReceived(EMCallSession session) {}

  /// 收到通话[session]结束, 结束原因[reason]
  void onCallDidEnd(EMCallSession session, EMCallEndReason reason, [EMError error]) {}
}
