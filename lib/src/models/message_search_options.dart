import '../internal/inner_headers.dart';

class MessageSearchOptions {
  const MessageSearchOptions({
    required this.types,
    this.from,
    this.ts = -1,
    this.count = 10,
    this.direction = EMSearchDirection.Up,
  });

  /// ~english
  /// Message types list
  /// ~end
  /// ~chinese
  /// 消息类型列表
  /// ~end
  final List<MessageType> types;

  /// ~english
  /// The message sender.
  /// ~end
  /// ~chinese
  /// 消息发送方。
  /// ~end
  final String? from;

  /// ~english
  /// The message timestamp threshold for loading.
  /// ~end
  /// ~chinese
  /// 参考时间戳。
  /// ~end
  final int ts;

  /// ~english
  /// The number of messages to load， max 400.
  /// ~end
  /// ~chinese
  /// 获取的消息条数。最大为400。
  /// ~end
  final int count;

  /// ~english
  ///  The message search direction.
  /// ~end
  /// ~chinese
  /// 消息搜索方向。
  /// ~end
  final EMSearchDirection direction;
}
