

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