import 'models/em_error.dart';

@Deprecated("Switch to using MessageStatusCallBack instead.")
abstract class StatusListener {
  /// The status of a message.
  void onProgress(int progress) {}

  /// The message fails to be delivered.
  void onError(EMError error) {}

  /// The message is successfully delivered.
  void onSuccess() {}

  /// The message is read.
  void onReadAck() {}

  /// The message is delivered.
  void onDeliveryAck() {}

  /// Occurs when the status of the message changes.
  void onStatusChanged() {}
}
