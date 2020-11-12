import 'package:im_flutter_sdk/im_flutter_sdk.dart';


/// CallSession listener
abstract class EMCallSessionListener{

  /// 对方已同意
  void onCallSessionDidAccept();

  /// 呼叫已连接
  void onCallSessionDidConnect();

  /// 收到通话状态变化
  void onCallSessionStateDidChange(EMCallStreamingStatus status);

  /// 通话网络状态变化
  void onCallSessionNetworkDidChange(EMCallNetworkStatus status);

  /// 通话结束
  void onCallSessionDidEnd(int reason, [EMError error]);
}

/// CallManager listener
abstract class EMCallManagerListener{

  /// 收到被叫邀请
  void onCallReceived(EMCallType type, String from) {}

  /// 呼叫被接起
  void onCallAccepted() {}

  /// 呼叫被拒绝
  void onCallRejected() {}

  /// 呼叫被挂断
  void onCallHangup() {}

  /// 对方忙
  void onCallBusy() {}

  /// 对方暂停发送视频流
  void onCallVideoPause() {}

  /// 对方恢复发送视频流
  void onCallVideoResume() {}

  /// 对方暂停发送音频流
  void onCallVoicePause() {}

  /// 对方恢复发送音频流
  void onCallVoiceResume() {}

  /// 网络链接不稳定
  void onCallNetworkUnStable() {}

  /// 网络链接正常
  void onCallNetworkNormal() {}

  /// 网络链接断开
  void onCallNetworkDisconnect() {}

}
