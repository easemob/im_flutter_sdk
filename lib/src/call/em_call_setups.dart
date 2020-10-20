import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk/src/call/views/em_call_view.dart';

import '../tools/em_extension.dart';

/// 当前通话连接类型
enum EMCallConnectType {
  /// 无连接
  None,
  /// P2P直连
  Direct,
  /// 通过媒体服务器连接
  Relay,
}

/// 通话状态
enum EMCallSessionStatus {
  /// 未开始或已断开
  Disconnected,
  /// 正在连接
  Connecting,
  /// 已经连接，等待接听
  Connected,
  /// 双方同意协商，准备接通
  Accepted
}

/// 通话类型。
enum EMCallType {
  /// 语音通话
  Voice,
  /// 视频通话
  Video
}

/// 视频分辨率
enum EMCallVideoResolution{
  /// 默认分辨率
  ResolutionDefault,
  /// 默认分辨率
  Resolution352x288,
  /// 默认分辨率
  Resolution640x480,
  /// 默认分辨率
  Resolution1280x720,
  /// 自定义分辨率
  ResolutionCustom,
}

/// 视频通话结束原因
enum EMCallEndReason {
  Hangup,
  NoResponse,
  Decline,
  Busy,
  Failed,
  Unsupported,
  RemoteOffline,
  LoginOtherDevice,
  Destroy,
  BeenKicked,
  ServiceArrearages,
  ServiceForbidden,
}

enum EMCallStreamingStatus {
  VoicePause, VoiceResume, VideoPause, VideoResume
}

enum EMCallNetworkStatus {
  Normal, Unstable, NoData
}

class EMCallOptions {
  EMCallOptions.private();

  /// 接收方不在线时是否发送推送提醒
  bool sendPushWhenOffline = true;

  /// 提醒的内容
  String offlineMessageText;

  /// 发送ping包的时间间隔，单位秒，默认30s，最小10s
  int pingInterval = 30;

  /// 是否监听通话质量
  bool isReportQuality;

  /// 视频传输场景，是否清晰度优先
  bool isClarityFirst = false;

  /// 视频分辨率, 默认是自适应
  EMCallVideoResolution videoResolution = EMCallVideoResolution.ResolutionDefault;

  /// [maxVideoKbps]，最大视频码率, 范围 50 < videoKbps < 5000, 默认0, 0为自适应;
  /// [minVideoKbps]，最小视频码率;
  /// [maxVideoFrameRate], 最大视频帧率;
  int maxVideoKbps = 0, minVideoKbps, maxVideoFrameRate;

  /// 是否自定义视频数据
  bool isCustomizeVideoData = false;

  /// maxAudioKbps, 最大音频码率;
  int maxAudioKbps;

  /// 是否自定义音频数据
  bool isCustomAudioData = false;

  /// audioCustomSamples, 自定义音频数据的采样率，默认48000;
  int audioCustomSamples = 48000;

  /// audioCustomChannels, 自定义音频数据的通道数，当前只支持单通道，必须为1
  final int audioCustomChannels = 1;

  factory EMCallOptions.fromJson(Map map ){
    return EMCallOptions.private()
      ..pingInterval = map['pingInterval']
      ..isClarityFirst = map.boolValue('isClarityFirst')
      ..isReportQuality = map.boolValue('isReportQuality')
      ..videoResolution = EMCallVideoResolution.values[map['videoResolution']]
      ..maxVideoKbps = map['maxVideoKbps']
      ..minVideoKbps = map['minVideoKbps']
      ..maxVideoFrameRate = map['maxVideoFrameRate']
      ..isCustomizeVideoData = map.boolValue('isCustomizeVideoData')
      ..maxAudioKbps = map['maxAudioKbps']
      ..isCustomAudioData = map.boolValue('isCustomAudioData')
      ..audioCustomSamples = map['audioCustomSamples'];
  }

  Map toJson() {
    Map data = Map();
    data['pingInterval'] = pingInterval;
    data['isClarityFirst'] = isClarityFirst;
    data['isReportQuality'] = isReportQuality;
    data['videoResolution'] = videoResolution.index;
    data['maxVideoKbps'] = maxVideoKbps;
    data['minVideoKbps'] = minVideoKbps;
    data['maxVideoFrameRate'] = maxVideoFrameRate;
    data['isCustomizeVideoData'] = isCustomizeVideoData;
    data['maxAudioKbps'] = maxAudioKbps;
    data['isCustomAudioData'] = isCustomAudioData;
    data['audioCustomSamples'] = audioCustomSamples;
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class EMCallSession {

  static const _channelPrefix = 'com.easemob.im';
  static const MethodChannel _emCallSessionChannel = const MethodChannel('$_channelPrefix/em_call_session', JSONMethodCodec());
  static const MethodChannel _emCallManagerChannel = const MethodChannel('$_channelPrefix/em_call_manager', JSONMethodCodec());
  EMCallSession._private() {
    _emCallSessionChannel.setMethodCallHandler((MethodCall call) {
      Map argMap = call.arguments;
      if (argMap['callId'] == _callId) {
        if(call.method == EMSDKMethod.onCallDidAccept) {
          listener?.onCallDidAccept();
        }else if(call.method == EMSDKMethod.onCallDidAccept) {
          listener?.callDidConnect();
        }else if(call.method == EMSDKMethod.onCallStateDidChange) {
          listener?.onCallStateDidChange(EMCallStreamingStatus.values[argMap['status']]);
        }else if(call.method == EMSDKMethod.onCallNetworkDidChange) {
          listener?.onCallNetworkDidChange(EMCallNetworkStatus.values[argMap['status']]);
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
    Map result = await _emCallManagerChannel.invokeMethod(EMSDKMethod.pauseVoice, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.pauseVoice);
  }

  /// 暂停/恢复 视频传输
  Future<bool> pauseVideo(bool isPause) async {
    Map req = {'pause': isPause};
    Map result = await _emCallManagerChannel.invokeMethod(EMSDKMethod.pauseVideo, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.pauseVideo);
  }

  /// 切换前置摄像头
  Future<bool> switchCameraPosition(bool isFrontCamera) async {
    Map req = {'isFront': isFrontCamera};
    Map result = await _emCallManagerChannel.invokeMethod(EMSDKMethod.switchCameraPosition, req);
    EMError.hasErrorFromResult(result);
    return result.boolValue(EMSDKMethod.switchCameraPosition);
  }

  Future<bool> setLocalView(EMRTCView view) async {
    Map req = {'viewId': view.id, 'callId': _callId, 'type': view.viewType.index};
    Map result = await _emCallManagerChannel.invokeMethod(EMSDKMethod.setLocalView, req);
    EMError.hasErrorFromResult(result);
    _localView = view;
    return result.boolValue(EMSDKMethod.setLocalView);
  }

  Future<bool> setRemoteView(EMRTCView view) async {
    Map req = {'viewId': view.id, 'callId': _callId, 'type': view.viewType.index};
    Map result = await _emCallManagerChannel.invokeMethod(EMSDKMethod.setRemoteView, req);
    EMError.hasErrorFromResult(result);
    _remoteView = view;
    return result.boolValue(EMSDKMethod.setRemoteView);
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

/// CallSession listener
abstract class EMCallSessionListener{

  /// 对方已同意
  void onCallDidAccept();

  /// 呼叫已连接
  void callDidConnect();

  /// 收到通话状态变化
  void onCallStateDidChange(EMCallStreamingStatus status);

  /// 通话网络状态变化
  void onCallNetworkDidChange(EMCallNetworkStatus status);
}