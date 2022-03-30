import 'models/em_error.dart';

@Deprecated("Switch to using MessageStatusCallBack instead.")
abstract class StatusListener {
  /// 消息进度
  void onProgress(int progress) {}

  /// 消息发送失败
  void onError(EMError error) {}

  /// 消息发送成功
  void onSuccess() {}

  /// 消息已读
  void onReadAck() {}

  /// 消息已送达
  void onDeliveryAck() {}

  /// 消息状态发生改变
  void onStatusChanged() {}
}
