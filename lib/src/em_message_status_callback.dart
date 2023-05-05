import 'package:flutter/foundation.dart';

import 'internal/inner_headers.dart';

@Deprecated('Switch [ChatManager.addMessageEvent] to instead.')
class MessageStatusCallBack {
  final void Function(int progress)? onProgress;

  final void Function(EMError error)? onError;

  final VoidCallback? onSuccess;

  final VoidCallback? onReadAck;

  final VoidCallback? onDeliveryAck;

  final VoidCallback? onStatusChanged;

  MessageStatusCallBack({
    this.onProgress,
    this.onError,
    this.onSuccess,
    this.onReadAck,
    this.onDeliveryAck,
    this.onStatusChanged,
  });
}
