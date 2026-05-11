// ignore_for_file: constant_identifier_names

/// ~english
/// The stream message chunk status.
/// ~end
///
/// ~chinese
/// 流式消息块状态。
/// ~end
enum EMStreamStatus {
  /// ~english
  /// Stream started.
  /// ~end
  ///
  /// ~chinese
  /// 流式消息开始。
  /// ~end
  START,

  /// ~english
  /// Stream started and completed in one chunk (single fragment).
  /// ~end
  ///
  /// ~chinese
  /// 流式消息开始即完成（单片流式消息）。
  /// ~end
  START_AND_COMPLETE,

  /// ~english
  /// Stream in progress.
  /// ~end
  ///
  /// ~chinese
  /// 流式消息进行中。
  /// ~end
  PROGRESS,

  /// ~english
  /// Stream completed.
  /// ~end
  ///
  /// ~chinese
  /// 流式消息完成。
  /// ~end
  COMPLETE,

  /// ~english
  /// Stream ended with error.
  /// ~end
  ///
  /// ~chinese
  /// 流式消息错误。
  /// ~end
  ERROR,
}

/// ~english
/// The stream message chunk.
/// ~end
///
/// ~chinese
/// 流式消息块。
/// ~end
class EMStreamChunk {
  /// ~english
  /// The stream status.
  /// ~end
  ///
  /// ~chinese
  /// 流式消息状态。
  /// ~end
  final EMStreamStatus status;

  /// ~english
  /// The error code.
  /// ~end
  ///
  /// ~chinese
  /// 错误码。
  /// ~end
  final int errorCode;

  /// ~english
  /// The finish reason.
  /// ~end
  ///
  /// ~chinese
  /// 完成原因。
  /// ~end
  final int finishReason;

  /// ~english
  /// The text content of the stream chunk.
  /// ~end
  ///
  /// ~chinese
  /// 流式消息块的文本内容。
  /// ~end
  final String chunk;

  /// ~english
  /// The custom type.
  /// ~end
  ///
  /// ~chinese
  /// 自定义类型。
  /// ~end
  final String? customType;

  EMStreamChunk._private({
    required this.status,
    required this.errorCode,
    required this.finishReason,
    required this.chunk,
    this.customType,
  });

  /// ~english
  /// Creates a stream chunk from a JSON map.
  ///
  /// Param [map] The JSON map.
  ///
  /// **Return** The stream chunk instance.
  /// ~end
  ///
  /// ~chinese
  /// 从 JSON map 创建流式消息块。
  ///
  /// Param [map] JSON map。
  ///
  /// **Return** 流式消息块实例。
  /// ~end
  factory EMStreamChunk.fromJson(Map<String, dynamic> map) {
    return EMStreamChunk._private(
      status: _streamStatusFromInt(map['status'] ?? 3),
      errorCode: map['errorCode'] ?? 0,
      finishReason: map['finishReason'] ?? 0,
      chunk: map['text'] ?? '',
      customType: map['customType'],
    );
  }

  static EMStreamStatus _streamStatusFromInt(int status) {
    switch (status) {
      case 0:
        return EMStreamStatus.START;
      case 1:
        return EMStreamStatus.START_AND_COMPLETE;
      case 2:
        return EMStreamStatus.PROGRESS;
      case 3:
        return EMStreamStatus.COMPLETE;
      case 4:
        return EMStreamStatus.ERROR;
      default:
        return EMStreamStatus.COMPLETE;
    }
  }
}
