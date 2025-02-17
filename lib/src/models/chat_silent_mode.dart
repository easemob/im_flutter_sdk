import '../internal/inner_headers.dart';

/// ~english
/// Offline push Settings parameter entity class.
/// ~end
///
/// ~chinese
/// 离线推送设置参数类。
/// ~end
class ChatSilentModeParam {
  final ChatSilentModeParamType _paramType;

  /// ~english
  /// The offline push notification type.
  /// ~end
  ///
  /// ~chinese
  /// 离线推送通知类型。
  /// ~end
  final ChatPushRemindType? remindType;

  /// ~english
  /// The start time of offline push DND.
  /// ~end
  ///
  /// ~chinese
  /// 离线推送免打扰的开始时间。
  /// ~end
  final ChatSilentModeTime? startTime;

  /// ~english
  /// The end time of offline push DND.
  /// ~end
  ///
  /// ~chinese
  /// 离线推送免打扰结束时间。
  /// ~end
  final ChatSilentModeTime? endTime;

  /// ~english
  /// The offline push DND duration.
  /// ~end
  ///
  /// ~chinese
  /// 离线push免打扰时长。
  /// ~end
  final int? silentDuration;

  /// ~english
  /// Set the offline push notification type.
  ///
  /// Param [remindType] Offline push notification type.
  /// ~end
  ///
  /// ~chinese
  /// 设置离线推送通知类型。
  ///
  /// Param [remindType] 离线推送通知类型。
  /// ~end
  ChatSilentModeParam.remindType(
    this.remindType,
  )   : this.silentDuration = null,
        this.startTime = null,
        this.endTime = null,
        this._paramType = ChatSilentModeParamType.REMIND_TYPE;

  /// ~english
  /// Set the offline push DND duration.
  ///
  /// Param [silentDuration] Offline push DND duration, units of minutes.
  /// ~end
  ///
  /// ~chinese
  /// 设置离线推免打扰时长。
  /// Param [silentDuration] 离线推送免打扰时长，单位为分钟。
  /// ~end
  ChatSilentModeParam.silentDuration(this.silentDuration)
      : this.startTime = null,
        this.endTime = null,
        this.remindType = null,
        this._paramType = ChatSilentModeParamType.SILENT_MODE_DURATION;

  /// ~english
  /// Set the start time of offline push DND, you need to create the start time and end time together.
  ///
  /// Param [startTime] Do not disturb start time.
  ///
  /// Param [endTime] Do not disturb end time.
  /// ~end
  ///
  /// ~chinese
  /// 设置离线推送免打扰的开始时间，需要同时创建开始时间和结束时间。
  ///
  /// Param [startTime] 免扰乱开始时间。
  ///
  /// Param [endTime] 免扰乱结束时间。
  /// ~end
  ChatSilentModeParam.silentModeInterval({
    required this.startTime,
    required this.endTime,
  })  : this.silentDuration = null,
        this.remindType = null,
        this._paramType = ChatSilentModeParamType.SILENT_MODE_INTERVAL;

  Map toJson() {
    Map data = Map();
    data.putIfNotNull("paramType", _paramType.index);
    data.putIfNotNull("remindType", remindType?.index);
    data.putIfNotNull("startTime", startTime?.toJson());
    data.putIfNotNull("endTime", endTime?.toJson());
    data.putIfNotNull("duration", silentDuration);
    return data;
  }
}

/// ~english
/// For offline push DND time class.
/// ~end
///
/// ~chinese
/// 用于离线推送免打扰时间类。
/// ~end
class ChatSilentModeTime {
  /// ~english
  /// Number of hours.
  /// ~end
  ///
  /// ~chinese
  /// 小时数。
  /// ~end
  final int hour;

  /// ~english
  /// Minutes.
  /// ~end
  ///
  /// ~chinese
  /// 分钟
  /// ~end
  final int minute;

  /// ~english
  /// For offline push DND time.
  ///
  /// Param [hour] Set the number of hours to 24 hours.
  ///
  /// Param [minute] Set minutes.
  /// ~end
  ///
  /// ~chinese
  /// 用于离线推送免打扰时间。
  ///
  /// Param [hour] 设置小时数，为24小时制。
  ///
  /// Param [minute] 设置分钟数。
  /// ~end
  ChatSilentModeTime({
    this.minute = 0,
    this.hour = 0,
  });

  Map toJson() {
    Map data = Map();
    data["minute"] = minute;
    data["hour"] = hour;
    return data;
  }

  factory ChatSilentModeTime.fromJson(Map map) {
    return ChatSilentModeTime(
      hour: map["hour"],
      minute: map["minute"],
    );
  }
}

/// ~english
/// Offline push DND result class.
/// ~end
///
/// ~chinese
/// 离线推送免打扰结果。
/// ~end
class ChatSilentModeResult {
  /// ~english
  /// Obtain the offline push DND expiration timestamp.
  /// ~end
  ///
  /// ~chinese
  /// 获取离线推送免打扰到期时间戳。
  /// ~end
  final int? expireTimestamp;

  /// ~english
  /// The Conversation Type.
  /// ~end
  ///
  /// ~chinese
  /// 会话类型
  /// ~end
  final EMConversationType conversationType;

  /// ~english
  /// The Conversation ID.
  /// ~end
  ///
  /// ~chinese
  /// 会话ID
  /// ~end
  final String conversationId;

  /// ~english
  /// The offline push notification type.
  /// ~end
  ///
  /// ~chinese
  /// 离线推送通知类型。
  /// ~end
  final ChatPushRemindType? remindType;

  /// ~english
  /// The start time of offline push DND.
  /// ~end
  ///
  /// ~chinese
  /// 离线推送免打扰的开始时间。
  /// ~end
  final ChatSilentModeTime? startTime;

  /// ~english
  /// The end time of offline push DND.
  /// ~end
  ///
  /// ~chinese
  /// 离线推送免打扰结束时间。
  /// ~end
  final ChatSilentModeTime? endTime;

  /// ~english
  /// Offline push DND result class.
  /// ~end
  ///
  /// ~chinese
  /// 离线推送免打扰结果类。
  /// ~end
  ChatSilentModeResult(
    this.expireTimestamp,
    this.conversationType,
    this.conversationId,
    this.remindType,
    this.startTime,
    this.endTime,
  );

  factory ChatSilentModeResult.fromJson(Map map) {
    int expireTimestamp = map["expireTs"];
    ChatSilentModeTime startTime =
        ChatSilentModeTime.fromJson(map["startTime"]);
    ChatSilentModeTime endTime = ChatSilentModeTime.fromJson(map["endTime"]);
    ChatPushRemindType remindType =
        ChatPushRemindType.values[map["remindType"]];
    String conversationId = map["conversationId"];
    EMConversationType conversationType =
        EMConversationType.values[map["conversationType"]];
    return ChatSilentModeResult(
      expireTimestamp,
      conversationType,
      conversationId,
      remindType,
      startTime,
      endTime,
    );
  }
}
