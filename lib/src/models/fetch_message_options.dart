import '../internal/inner_headers.dart';

/// ~english
/// The parameter configuration class for pulling historical messages from the server.
/// ~end
///
/// ~chinese
/// 从服务端查询历史消息的参数配置类。
/// ~end
class FetchMessageOptions {
  /// ~english
  /// The parameter configuration class for pulling historical messages from the server.
  ///
  /// Param [direction] The message search direction. The default value is [EMSearchDirection.Up]. See [EMSearchDirection].
  ///
  /// Param [from] The user ID of the message sender in the group conversation.
  ///
  /// Param [msgTypes] The array of message types for query. The default value is `null`, indicating that all types of messages are retrieved.
  ///
  /// Param [startTs] The start time for message query. The time is a UNIX timestamp in milliseconds.
  /// The default value is `-1`, indicating that this parameter is ignored during message query.
  /// If the [startTs] is set to a specific time spot and the [endTs] uses the default value `-1`,
  /// the SDK returns messages that are sent and received in the period that is from the start time to the current time.
  /// If the [startTs] uses the default value `-1` and the [endTs] is set to a specific time spot,
  /// the SDK returns messages that are sent and received in the period that is from the timestamp of the first message to the current time.
  ///
  /// Param [endTs] The end time for message query. The time is a UNIX timestamp in milliseconds.
  /// The default value is -1, indicating that this parameter is ignored during message query.
  /// If the [startTs] is set to a specific time spot and the [endTs] uses the default value -1,
  /// the SDK returns messages that are sent and received in the period that is from the start time to the current time.
  /// If the [startTs] uses the default value -1 and the [endTs] is set to a specific time spot,
  /// the SDK returns messages that are sent and received in the period that is from the timestamp of the first message to the current time.
  ///
  /// Param [needSave] Whether to save the retrieved messages to the database:
  /// - `true`: Yes.
  /// - (Default) `false`：No.
  /// ~end
  ///
  /// ~chinese
  /// 从服务端查询历史消息的参数配置类。
  ///
  /// Param [direction] 消息搜索方向。默认为 [EMSearchDirection.Up] , 详见 [EMSearchDirection]。
  ///
  /// Param [from] 群组会话中的消息发送方的用户 ID。
  ///
  /// Param [msgTypes] 要查询的消息类型数组。默认值为 `null`，表示返回所有类型的消息。
  ///
  /// Param [startTs] 消息查询的起始时间，Unix 时间戳，单位为毫秒。默认为 `-1`，表示消息查询时会忽略该参数。
  /// 若 [startTs] 设置为特定时间点，而 [endTs] 采用默认值 `-1`，则查询起始时间至当前时间的消息。
  /// 若 [startTs] 采用默认值 `-1`，而 [endTs] 设置了特定时间，SDK 返回从会话中最早的消息到结束时间点的消息。
  ///
  /// Param [endTs] 消息查询的结束时间，Unix 时间戳，单位为毫秒。默认为 -1，表示消息查询时会忽略该参数。
  /// 若 [startTs] 设置为特定时间点，而 [endTs] 采用默认值 -1，则查询起始时间至当前时间的消息。
  /// 若 [startTs] 采用默认值 -1，而 [endTs] 设置了特定时间，SDK 返回从会话中最早的消息到结束时间点的消息。
  ///
  /// Param [needSave] 获取的消息是否保存到数据库：
  /// - `true`：保存到数据库；
  /// - `false`（默认）：不保存到数据库。
  /// ~end
  const FetchMessageOptions({
    this.from,
    this.msgTypes,
    this.startTs = -1,
    this.endTs = -1,
    this.needSave = false,
    this.direction = EMSearchDirection.Up,
  });

  /// ~english
  /// The user ID of the message sender in the group conversation.
  /// ~end
  ///
  /// ~chinese
  /// 群组会话中的消息发送方的用户 ID。
  /// ~end
  final String? from;

  /// ~english
  /// The array of message types for query. The default value is `null`, indicating that all types of messages are retrieved.
  /// ~end
  ///
  /// ~chinese
  /// 要查询的消息类型数组。默认值为 `null`，表示返回所有类型的消息。
  /// ~end
  final List<MessageType>? msgTypes;

  /// ~english
  /// The start time for message query. The time is a UNIX time stamp in milliseconds. The default value is -1,
  /// indicating that this parameter is ignored during message query.
  /// If the [startTs] is set to a specific time spot and the [endTs] uses the default value -1,
  /// the SDK returns messages that are sent and received in the period that is from the start time to the current time.
  /// If the [startTs] uses the default value -1 and the [endTs] is set to a specific time spot,
  /// the SDK returns messages that are sent and received in the period that is from the timestamp of the first message to the current time.
  /// ~end
  ///
  /// ~chinese
  /// 消息查询的起始时间，Unix 时间戳，单位为毫秒。默认为 -1，表示消息查询时会忽略该参数。
  /// 若 [startTs] 设置为特定时间点，而 [endTs] 采用默认值 -1，则查询起始时间至当前时间的消息。
  /// 若 [startTs] 采用默认值 -1，而 [endTs] 设置了特定时间，SDK 返回从会话中最早的消息到结束时间点的消息。
  /// ~end
  final int startTs;

  /// ~english
  /// The end time for message query. The time is a UNIX timestamp in milliseconds.
  /// The default value is `-1`, indicating that this parameter is ignored during message query.
  /// If the [startTs] is set to a specific time spot and the [endTs] uses the default value `-1`,
  /// the SDK returns messages that are sent and received in the period that is from the start time to the current time.
  /// If the [startTs] uses the default value `-1` and the [endTs] is set to a specific time spot,
  /// the SDK returns messages that are sent and received in the period that is from the timestamp of the first message to the current time.
  /// ~end
  ///
  /// ~chinese
  /// 消息查询的结束时间，Unix 时间戳，单位为毫秒。默认为 `-1`，表示消息查询时会忽略该参数。
  /// 若 [startTs] 设置为特定时间点，而 [endTs] 采用默认值 `-1`，则查询起始时间至当前时间的消息。
  /// 若 [startTs] 采用默认值 `-1`，而 [endTs] 设置了特定时间，SDK 返回从会话中最早的消息到结束时间点的消息。
  /// ~end
  final int endTs;

  /// ~english
  /// The message search direction. The default value is [EMSearchDirection.Up]. See [EMSearchDirection].
  /// ~end
  ///
  /// ~chinese
  /// 消息搜索方向，默认为[EMSearchDirection.Up]。详见 [EMSearchDirection]。
  /// ~end
  final EMSearchDirection direction;

  /// ~english
  /// Whether to save the retrieved messages to the database:
  /// - `true`: Yes.
  /// - (Default) `false`：No.
  /// ~end
  ///
  /// ~chinese
  /// 获取的消息是否保存到数据库：
  /// - `true`：保存到数据库；
  /// - （默认）`false`：不保存到数据库。
  /// ~end
  final bool needSave;

  Map toJson() {
    Map data = {};
    data.putIfNotNull('direction', direction.index);
    data.putIfNotNull('startTs', startTs);
    data.putIfNotNull('endTs', endTs);
    data.putIfNotNull('from', from);
    data.putIfNotNull('needSave', needSave);
    data.putIfNotNull(
        'msgTypes', msgTypes?.toSet().map<int>((e) => e.index).toList());

    return data;
  }
}
