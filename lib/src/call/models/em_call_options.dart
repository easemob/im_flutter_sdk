import 'package:im_flutter_sdk/im_flutter_sdk.dart';

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