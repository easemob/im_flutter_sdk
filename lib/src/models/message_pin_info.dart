/// ~english
/// The message pinning information.
/// ~end
///
/// ~chinese
/// 消息置顶信息。
/// ~end
class MessagePinInfo {
  /// ~english
  /// The time when the message is pinned.
  /// ~end
  /// ~chinese
  /// 置顶时间。
  /// ~end
  final int pinTime;

  /// ~english
  /// The user ID of the operator that pins the message.
  /// ~end
  /// ~chinese
  /// 置顶的操作者的用户 ID。
  /// ~end
  final String operatorId;

  /// ~english
  /// Constructor of MessagePinInfo.
  ///
  /// param [pinTime] The time when the message is pinned.
  /// param [operatorId] The user ID of the operator that pins the message.
  /// ~end
  ///
  /// ~chinese
  /// MessagePinInfo 的构造函数。
  ///
  /// 参数 [pinTime] 消息置顶时间。
  /// 参数 [operatorId] 置顶的操作者的用户 ID。
  /// ~end
  MessagePinInfo({
    required this.pinTime,
    required this.operatorId,
  });

  factory MessagePinInfo.fromJson(Map<String, dynamic> map) {
    return MessagePinInfo(
      pinTime: map['pinTime'] as int,
      operatorId: map['operatorId'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pinTime': pinTime,
      'operatorId': operatorId,
    };
  }
}
