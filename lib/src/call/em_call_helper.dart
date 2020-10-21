enum EMCallStreamingStatus {
  VoicePause, VoiceResume, VideoPause, VideoResume
}

enum EMCallNetworkStatus {
  /// 正常
  Normal,
  /// 不稳定
  Unstable,
  /// 没有数据
  NoData
}

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

class EMCallEndReason {
  /// 挂断
  static const int Hangup = 0;
  /// 无响应
  static const int NoResponse = 1;
  /// 拒绝
  static const int Decline = 2;
  /// 忙
  static const int Busy = 3;
  /// 失败
  static const int Failed = 4;
  /// 不支持
  static const int Unsupported = 5;
  /// 对方不在线
  static const int RemoteOffline = 6;
  /// 在其他设备登录
  static const int LoginOtherDevice = 7;
  /// 通话被销毁
  static const int Destroy = 8;
  /// 被踢出
  static const int BeenKicked = 9;
  /// 服务未开启
  static const int NotEnable = 101;
  /// 服务欠费
  static const int ServiceArrears = 102;
  /// 服务被拒绝
  static const int ServiceForbidden = 103;
}