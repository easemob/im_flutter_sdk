import "dart:async";

import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class EMCallManager {
  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _channel = const MethodChannel('$_channelPrefix/em_call_manager', JSONMethodCodec());

  EMCallManager(){
    _channel.setMethodCallHandler((MethodCall call) {
      Map argMap = call.arguments;
      if(call.method == EMSDKMethod.onCallReceived) {
        _onCallReceived(argMap);
      }else if(call.method == EMSDKMethod.onCallAccepted) {
        _onCallAccepted(argMap);
      }else if(call.method == EMSDKMethod.onCallBusy) {
        _onCallBusy(argMap);
      }else if(call.method == EMSDKMethod.onCallHangup) {
        _onCallHangup(argMap);
      }else if(call.method == EMSDKMethod.onCallRejected) {
        _onCallRejected(argMap);
      }else if(call.method == EMSDKMethod.onCallNetworkDisconnect) {
        _onCallNetworkDisconnect(argMap);
      }else if(call.method == EMSDKMethod.onCallNetworkNormal) {
        _onCallNetworkNormal(argMap);
      }else if(call.method == EMSDKMethod.onCallNetworkUnStable) {
        _onCallNetworkUnStable(argMap);
      }else if(call.method == EMSDKMethod.onCallVideoPause) {
        _onCallVideoPause(argMap);
      }else if(call.method == EMSDKMethod.onCallVideoResume) {
        _onCallVideoResume(argMap);
      }else if(call.method == EMSDKMethod.onCallVoicePause) {
        _onCallVoicePause(argMap);
      }else if(call.method == EMSDKMethod.onCallVoiceResume) {
        _onCallVoiceResume(argMap);
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
    Map result = await _channel.invokeMethod(EMSDKMethod.getCallOptions);
    EMError.hasErrorFromResult(result);
    return EMCallOptions.fromJson(result[EMSDKMethod.getCallOptions]);
  }

  /// 设置EMCallOptions;
  Future<bool>setCallOptions(EMCallOptions options) async {
    Map req = options.toJson();
    Map result = await _channel.invokeMethod(EMSDKMethod.setCallOptions,req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(result[EMSDKMethod.setCallOptions]);
  }

  /// 发起1v1实时会话
  /// 通话类型[type], 被叫方环信id[remote], 是否开启服务器录制[isRecord], 服务器端是否合并流[isMerge], 带给对方的其他信息[ext]
  Future<bool> makeCall(EMCallType type, String remote, [bool isRecord = false, isMerge = false, String ext = '']) async {
    Map req = {"type": type.index ,"remote": remote ,"record": isRecord ,"merge": isMerge ,"ext": ext};
    Map result = await _channel.invokeMethod(EMSDKMethod.makeCall, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.makeCall);
  }

  /// 根据通话id[callId] 接听1v1通话，
  Future<bool> answerCall() async {
    Map result = await _channel.invokeMethod(EMSDKMethod.answerCall);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.answerCall);
  }

  Future<bool> rejectCall() async {
    Map result = await _channel.invokeMethod(EMSDKMethod.rejectCall);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.rejectCall);
  }

  /// 根据通话id[callId], [reason] 结束1v1通话，
  Future<bool> endCall() async {
    Map result = await _channel.invokeMethod(EMSDKMethod.endCall);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.endCall);
  }

  /// 打开/关闭音频传输
  Future<bool> enableVoiceTransfer(bool enable) async {
    Map req = {"enable": enable};
    Map result = await _channel.invokeMethod(EMSDKMethod.enableVoiceTransfer, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.enableVoiceTransfer);
  }

  /// 打开/关闭视频传输
  Future<bool> enableVideoTransfer(bool enable) async {
    Map req = {"enable": enable};
    Map result = await _channel.invokeMethod(EMSDKMethod.enableVideoTransfer, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.enableVideoTransfer);
  }

  /// 接收/不接收 对方音频
  Future<bool> muteRemoteAudio(bool mute) async {
    Map req = {"mute": mute};
    Map result = await _channel.invokeMethod(EMSDKMethod.muteRemoteAudio, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.muteRemoteAudio);
  }

  /// 接收/不接收 对方视频
  Future<bool> muteRemoteVideo(bool mute) async {
    Map req = {"mute": mute};
    Map result = await _channel.invokeMethod(EMSDKMethod.muteRemoteVideo, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.muteRemoteVideo);
  }

  /// 切换摄像头
  Future<bool> switchCamera() async {
    Map result = await _channel.invokeMethod(EMSDKMethod.switchCamera);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.switchCamera);
  }

  /// 设置显示视频流的view
  Future<bool> setLocalSurfaceView(EMRTCView view) async {
    Map req = {'view_id': view.id, 'isLocal': true};
    Map result = await _channel.invokeMethod(EMSDKMethod.setSurfaceView, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.setSurfaceView);
  }

  /// 设置显示视频流的view
  Future<bool> setRemoteSurfaceView(EMRTCView view) async {
    Map req = {'view_id': view.id, 'isLocal': false};
    Map result = await _channel.invokeMethod(EMSDKMethod.setSurfaceView, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.setSurfaceView);
  }

  /// 删除再使用的view[viewId]
  Future<bool> releaseVideoView(int viewId, EMRTCViewType type) async {
    Map req = {"view_Id": viewId, "viewType": type.index};
    Map result = await _channel.invokeMethod(EMSDKMethod.releaseView, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.releaseView);
  }

  Future<Null> _onCallReceived(Map event) async {
    _callManagerListener.forEach((element) {
      String from = event['from'];
      EMCallType type = event['type'] == 0 ? EMCallType.Voice : EMCallType.Video;
      element.onCallReceived(type, from);
    });
  }

  Future<Null> _onCallAccepted(Map event) async {
    _callManagerListener.forEach((element) {
      element.onCallAccepted();
    });
  }

  Future<Null> _onCallRejected(Map event) async {
    _callManagerListener.forEach((element) {
      element.onCallRejected();
    });
  }

  Future<Null> _onCallHangup(Map event) async {
    _callManagerListener.forEach((element) {
      element.onCallHangup();
    });
  }

  Future<Null> _onCallBusy(Map event) async {
    _callManagerListener.forEach((element) {
      element.onCallBusy();
    });
  }

  Future<Null> _onCallVideoPause(Map event) async {
    _callManagerListener.forEach((element) {
      element.onCallVideoPause();
    });
  }

  Future<Null> _onCallVideoResume(Map event) async {
    _callManagerListener.forEach((element) {
      element.onCallVideoResume();
    });
  }

  Future<Null> _onCallVoicePause(Map event) async {
    _callManagerListener.forEach((element) {
      element.onCallVoicePause();
    });
  }

  Future<Null> _onCallVoiceResume(Map event) async {
    _callManagerListener.forEach((element) {
      element.onCallVoiceResume();
    });
  }

  Future<Null> _onCallNetworkUnStable(Map event) async {
    _callManagerListener.forEach((element) {
      element.onCallNetworkUnStable();
    });
  }

  Future<Null> _onCallNetworkNormal(Map event) async {
    _callManagerListener.forEach((element) {
      element.onCallNetworkNormal();
    });
  }

  Future<Null> _onCallNetworkDisconnect(Map event) async {
    _callManagerListener.forEach((element) {
      element.onCallNetworkDisconnect();
    });
  }
}

