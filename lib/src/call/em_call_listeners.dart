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

  /// 收到被叫邀请[session]
  void onCallReceived(EMCallSession session) {}

  /// 收到通话[session]结束, 结束原因[reason]
  void onCallDidEnd(String sessionId, int reason, [EMError error]) {}
}
