import 'package:flutter/foundation.dart';

import 'internal/inner_headers.dart';

/// 消息状态回调。
class MessageStatusCallBack {
  /// 进度回调，取值范围为 [0,100]。
  final void Function(int progress)? onProgress;

  /// 失败回调。
  final void Function(EMError error)? onError;

  /// 成功回调。
  final VoidCallback? onSuccess;

  /// 消息已读回调。
  final VoidCallback? onReadAck;

  /// 消息已送达回调。
  final VoidCallback? onDeliveryAck;

  /// 消息内容变化回调。
  final VoidCallback? onStatusChanged;

  ///
  /// 创建消息状态监听。
  ///
  MessageStatusCallBack({
    this.onProgress,
    this.onError,
    this.onSuccess,
    this.onReadAck,
    this.onDeliveryAck,
    this.onStatusChanged,
  });
}
