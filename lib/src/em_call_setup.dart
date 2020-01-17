

class EMCallOptions{

  EMCallOptions()
      : _isSendPushIfOffline = false,
        _userSetAutoResizing = true,
        _pingInterval = 30,
        _maxVideoKbps = 0,
        _minVideoKbps = 0,
        _maxVideoFrameRate = 0,
        _maxAudioKbps = 32;

  /// 开启或关闭自动调节分辨率
  bool _userSetAutoResizing;
  /// 被叫方不在线时，是否推送来电通知
  bool _isSendPushIfOffline;
  /// 发送ping包的时间间隔，单位秒，默认30s，最小10s
  int _pingInterval;
  /// 最大视频码率
  int _maxVideoKbps;
  /// 最小视频码率
  int _minVideoKbps;
  /// 最大的视频帧率
  int _maxVideoFrameRate;
  /// 最大音频比特率
  int _maxAudioKbps;


  /// 设置最小的网络带宽
  void setMinVideoKbps(int minVideoKbps){
    this._minVideoKbps = minVideoKbps;
  }
  /// 设置最大的网络带宽
  void setMaxVideoKbps(int maxVideoKbps){
    this._maxAudioKbps = maxVideoKbps;
  }

  /// 设置最大的视频帧率
  void setMaxVideoFrameRate(int frameRate){
    this._maxVideoFrameRate = frameRate;
  }


  /// 设置ping 间隔，默认为30s，最小为10s
  void setPingInterval(int interval){
    this._pingInterval = interval;
  }

}

Map convertToMap(EMCallOptions options) {
  var map = Map();
  map.putIfAbsent("userSetAutoResizing", () => options._userSetAutoResizing);
  map.putIfAbsent("isSendPushIfOffline", () => options._isSendPushIfOffline);
  map.putIfAbsent("pingInterval", () => options._pingInterval);
  map.putIfAbsent("maxVideoKbps", () => options._maxVideoKbps);
  map.putIfAbsent("minVideoKbps", () => options._minVideoKbps);
  map.putIfAbsent("maxVideoFrameRate", () => options._maxVideoFrameRate);
  map.putIfAbsent("maxAudioKbps", () => options._maxAudioKbps);
  return map;
}

toEMCallType(EMCallType type) {
  if(type == EMCallType.Voice) {
    return 0;
  } else {
    return 1;
  }
}

enum callStatus {
  DISCONNECTED,               //Disconnected, initial value
  CONNECTING,                 //Connecting
  CONNECTED,                  //Connected
  ACCEPTED,                   //Accepted
}

enum ConnectTypes
{
  NONE,       //Initial value
  DIRECT,     //direct
  RELAY,      //relay
}

// ignore: missing_return
fromConnectTypes(int type){
  switch(type){
    case 0:
      return ConnectTypes.NONE;
    case 1:
      return ConnectTypes.DIRECT;
    case 2:
      return ConnectTypes.RELAY;
  }
}

/// @nodoc EMCallType -  通话枚举的类型。
enum EMCallType {
  Voice,
  Video
}

fromCallType(int type){
  switch(type){
    case 0:
      return EMCallType.Voice;
    case 1:
      return EMCallType.Video;
  }
}

class EMCallEvent{
  static const String ON_CONNECTING  = "connecting";
  static const String ON_CONNECTED  = "connected";
  static const String ON_ACCEPTED  = "accepted";
  static const String ON_NET_WORK_DISCONNECTED  = "netWorkDisconnected";
  static const String ON_NET_WORK_UNSTABLE  = "networkUnstable";
  static const String ON_NET_WORK_NORMAL  = "netWorkNormal";
  static const String ON_NET_VIDEO_PAUSE  = "netVideoPause";
  static const String ON_NET_VIDEO_RESUME  = "netVideoResume";
  static const String ON_NET_VOICE_PAUSE  = "netVoicePause";
  static const String ON_NET_VOICE_RESUME  = "netVoiceResume";
  static const String ON_DISCONNECTED  = "disconnected";
}

abstract class EMCallStateChangeListener{
  void onConnecting();
  void onConnected();
  void onAccepted();
  void onNetWorkDisconnected();
  void onNetworkUnstable();
  void onNetWorkNormal();
  void onNetVideoPause();
  void onNetVideoResume();
  void onNetVoicePause();
  void onNetVoiceResume();
  void onDisconnected(CallReason reason);
}


 fromEndReason(int type){
  switch(type){
    case 0:
      return CallReason.REASON_HANGUP;
    case 1:
      return CallReason.REASON_NO_RESPONSE;
    case 2:
      return CallReason.REASON_DECLINE;
    case 3:
      return CallReason.REASON_BUSY;
    case 4:
      return CallReason.REASON_FILE;
    case 5:
      return CallReason.REASON_REMOTE_OFFLINE;
    case 101:
      return CallReason.REASON_SERVICE_NOT_ENABLE;
    case 102:
      return CallReason.REASON_SERVICE_ARREARAGES;
    case 103:
      return CallReason.REASON_SERVICE_FORBIDDEN;
  }
}

fromCallReason(int reason){
  switch(reason){
    case 0:
      return CallReason.REASON_HANGUP;
    case 1:
      return CallReason.REASON_NO_RESPONSE;
    case 2:
      return CallReason.REASON_DECLINE;
    case 3:
      return CallReason.REASON_BUSY;
    case 4:
      return CallReason.REASON_FILE;
    case 5:
      return CallReason.REASON_REMOTE_OFFLINE;
    case 101:
      return CallReason.REASON_SERVICE_NOT_ENABLE;
    case 102:
      return CallReason.REASON_SERVICE_ARREARAGES;
    case 103:
      return CallReason.REASON_SERVICE_FORBIDDEN;
  }
}

enum CallReason {
  /// 挂断 0
  REASON_HANGUP,
  /// 对方没有响应 1
  REASON_NO_RESPONSE,
  /// 对方拒接 2
  REASON_DECLINE,
  /// 忙碌 3
  REASON_BUSY,
  /// 失败 4
  REASON_FILE,
  /// 对方不在线 5
  REASON_REMOTE_OFFLINE,
  /// 未启用 101
  REASON_SERVICE_NOT_ENABLE,
  /// 欠费  102
  REASON_SERVICE_ARREARAGES,
  /// 禁用  103
  REASON_SERVICE_FORBIDDEN,
}