import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';


class EMCallSession {

  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _sessionChannel = const MethodChannel('$_channelPrefix/em_call_session', JSONMethodCodec());
  static const MethodChannel _channel = const MethodChannel('$_channelPrefix/em_call_manager', JSONMethodCodec());
  EMCallSession._private() {
    _sessionChannel.setMethodCallHandler((MethodCall call) {
      Map argMap = call.arguments;
      if (argMap['callId'] == _callId) {
        if(call.method == EMSDKMethod.onCallSessionDidAccept) {
          listener?.onCallSessionDidAccept();
        }else if(call.method == EMSDKMethod.onCallSessionDidAccept) {
          listener?.onCallSessionDidAccept();
        }else if(call.method == EMSDKMethod.onCallSessionStateDidChange) {
          listener?.onCallSessionStateDidChange(EMCallStreamingStatus.values[argMap['status']]);
        }else if(call.method == EMSDKMethod.onCallSessionNetworkDidChange) {
          listener?.onCallSessionNetworkDidChange(argMap['status']);
        }else if(call.method == EMSDKMethod.onCallSessionDidEnd) {
          // 挂断时还需要释放持有view
          listener?.onCallSessionDidEnd(argMap['reason'], EMError.fromJson(argMap['error']));
        }
      }
      return null;
    });
  }

  String _callId;
  String _localName;
  EMCallType _callType;
  bool _isCaller;
  String _remoteName;
  EMCallSessionStatus _status;
  EMCallConnectType _connectType;
  int _videoLatency = -1;
  int _localVideoFrameRate = -1;
  int _remoteVideoFrameRate = -1;
  int _localVideoBitrate = -1;
  int _remoteVideoBitrate = -1;
  int _localVideoLostRateInPercent = -1;
  int _remoteVideoLostRateInPercent = -1;
  Size _remoteVideoResolution = Size(-1.0, -1.0);
  String _serverVideoId;
  bool _willRecord;
  String _ext;
  EMRTCView _localView;
  EMRTCView _remoteView;

  EMCallSessionListener listener;

  /// 会话标识符
  String get callId => _callId;
  /// 通话本地的username
  String get localName => _localName;
  /// 通话的类型
  EMCallType get callType => _callType;
  /// 是否为主叫方
  bool get isCaller => _isCaller;
  /// 对方的username
  String get remoteName => _remoteName;
  /// 通话的状态
  EMCallSessionStatus get status => _status;
  /// 连接类型
  EMCallConnectType get connectType => _connectType;
  /// 视频的延迟时间，单位是毫秒，实时变化, 默认值为-1
  int get videoLatency => _videoLatency;
  /// 本地视频的帧率，实时变化
  int get localVideoFrameRate => _localVideoFrameRate;
  /// 对方视频的帧率，实时变化
  int get remoteVideoFrameRate => _remoteVideoFrameRate;
  /// 本地视频通话对方的比特率kbps，实时变化
  int get localVideoBitrate => _localVideoBitrate;
  /// 对方视频通话对方的比特率kbps，实时变化
  int get remoteVideoBitrate => _remoteVideoBitrate;
  /// 本地视频丢包率，实时变化
  int get localVideoLostRateInPercent => _localVideoLostRateInPercent;
  /// 对方视频丢包率，实时变化
  int get remoteVideoLostRateInPercent => _remoteVideoLostRateInPercent;
  /// 对方视频分辨率
  Size get remoteVideoResolution => _remoteVideoResolution;
  /// 服务端录制文件的id
  String get serverVideoId => _serverVideoId;
  /// 是否启用服务器录制
  bool get willRecord => _willRecord;
  /// 消息扩展
  String get ext => _ext;
  /// 视频通话时自己的图像显示区域
  EMRTCView get localVideoView => _localView;
  /// 视频通话时对方的图像显示区域
  EMRTCView get remoteVideoView => _remoteView;

  factory EMCallSession.fromJson(Map map) {
    if(map == null) return null;

    return EMCallSession._private()
      .._callId = map['callId']
      .._localName = map['localName']
      .._callType = EMCallType.values[map['callType']]
      .._isCaller = map.boolValue('isCaller')
      .._remoteName = map['remoteName']
      .._status = EMCallSessionStatus.values[map['status']]
      .._connectType = EMCallConnectType.values[map['connectType']]
      .._videoLatency = map['videoLatency']
      .._localVideoFrameRate = map['localVideoFrameRate']
      .._remoteVideoFrameRate = map['remoteVideoFrameRate']
      .._localVideoBitrate = map['localVideoBitrate']
      .._remoteVideoBitrate = map['remoteVideoBitrate']
      .._localVideoLostRateInPercent = map['localVideoLostRateInPercent']
      .._remoteVideoLostRateInPercent = map['remoteVideoLostRateInPercent']
      .._remoteVideoResolution = Size(double.parse(map['remoteVideoResolution.width'].toString()), double.parse(map['remoteVideoResolution.height'].toString()))
      .._serverVideoId = map['serverVideoId']
      .._willRecord = map.boolValue('willRecord')
      .._ext = map['ext'];
  }

  // EMCallSession对象在native层无法直接构建，所以基本上用不到这个api，目前只用作打印用。
  Map toJson() {
    Map data = Map();
    data['callId'] = _callId;
    data['localName'] = _localName;
    data['callType'] = _callType.index;
    data['isCaller'] = _isCaller;
    data['remoteName'] = _remoteName;
    data['status'] = _status.index;
    data['connectType'] = _connectType.index;
    data['videoLatency'] = _videoLatency;
    data['localVideoFrameRate'] = _localVideoFrameRate;
    data['remoteVideoFrameRate'] = _remoteVideoFrameRate;
    data['localVideoBitrate'] = _localVideoBitrate;
    data['remoteVideoBitrate'] = _remoteVideoBitrate;
    data['localVideoLostRateInPercent'] = _localVideoLostRateInPercent;
    data['remoteVideoLostRateInPercent'] = _remoteVideoLostRateInPercent;
    data['remoteVideoResolution.width'] = _remoteVideoResolution.width;
    data['remoteVideoResolution.height'] = _remoteVideoResolution.height;
    data['serverVideoId'] = _serverVideoId;
    data['willRecord'] = _willRecord;
    data['ext'] = _ext;
    return data;
  }

  /// 暂停/恢复 音频传输
  Future<bool> pauseVoice(bool isPause) async {
    Map req = {'pause': isPause};
    Map result = await _channel.invokeMethod(EMSDKMethod.pauseVoice, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.pauseVoice);
  }

  /// 暂停/恢复 视频传输
  Future<bool> pauseVideo(bool isPause) async {
    Map req = {'pause': isPause};
    Map result = await _channel.invokeMethod(EMSDKMethod.pauseVideo, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.pauseVideo);
  }

  /// 切换前置摄像头
  Future<bool> switchCameraPosition(bool isFrontCamera) async {
    Map req = {'isFront': isFrontCamera};
    Map result = await _channel.invokeMethod(EMSDKMethod.switchCameraPosition, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.switchCameraPosition);
  }

  /// 设置本地view
  Future<bool> setLocalView(EMRTCView view) async {
    Map req = {'viewId': view.id, 'callId': _callId, 'type': view.viewType.index};
    Map result = await _channel.invokeMethod(EMSDKMethod.setLocalView, req);
    EMError.hasErrorFromResult(result);
    _localView = view;
    return result.boolValue(EMSDKMethod.setLocalView);
  }

  /// 设置对方view
  Future<bool> setRemoteView(EMRTCView view) async {
    Map req = {'viewId': view.id, 'callId': _callId, 'type': view.viewType.index};
    Map result = await _channel.invokeMethod(EMSDKMethod.setRemoteView, req);
    EMError.hasErrorFromResult(result);
    _remoteView = view;
    return result.boolValue(EMSDKMethod.setRemoteView);
  }

  /// 更新session详情
  Future<EMCallSession>fetchInfo() async {
    Map req = {'callId': _callId};
    Map result = await _channel.invokeMethod(EMSDKMethod.fetchCallSessionInfo, req);
    EMError.hasErrorFromResult(result);

    var session = EMCallSession.fromJson(result[EMSDKMethod.fetchCallSessionInfo]);
    _localName = session.localName;
    _ext = session.ext;
    _callType = session.callType;
    _isCaller = session.isCaller;
    _remoteName = session.remoteName;
    _status = session.status;
    _connectType = session.connectType;
    _videoLatency = session.videoLatency;
    _localVideoFrameRate = session.localVideoFrameRate;
    _remoteVideoFrameRate = session.remoteVideoFrameRate;
    _localVideoBitrate = session.localVideoBitrate;
    _remoteVideoBitrate = session.remoteVideoBitrate;
    _localVideoLostRateInPercent = session.localVideoLostRateInPercent;
    _remoteVideoLostRateInPercent = session.remoteVideoLostRateInPercent;
    _serverVideoId = session.serverVideoId;
    _remoteVideoResolution = session.remoteVideoResolution;
    _willRecord = session.willRecord;

    return this;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}