/// ~english
/// The message pinning information.
/// ~end
///
/// ~chinese
/// 消息置顶信息。
/// ~end
class MessagePinInfo {
  /// ~english
  /// The pin time.
  /// ~end
  /// ~chinese
  /// 置顶时间。
  /// ~end
  final int pinTime;

  /// ~english
  /// The operator id.
  /// ~end
  /// ~chinese
  /// 操作者id。
  /// ~end
  final String operatorId;

  /// ~english
  /// Constructor of MessagePinInfo.
  ///
  /// param [pinTime] The pin time.
  /// param [operatorId] The operator id.
  /// ~end
  ///
  /// ~chinese
  /// MessagePinInfo 的构造函数。
  ///
  /// 参数 [pinTime] 置顶时间。
  /// 参数 [operatorId] 操作者id。
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
