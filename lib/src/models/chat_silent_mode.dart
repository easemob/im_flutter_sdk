import '../internal/inner_headers.dart';

///
/// 离线推送参数类
///
class ChatSilentModeParam {
  final ChatSilentModeParamType _paramType;

  /// 免打扰类型
  final ChatPushRemindType? remindType;

  /// 免打扰开始时间
  final ChatSilentModeTime? startTime;

  /// 免打扰结束时间
  final ChatSilentModeTime? endTime;

  /// 免打扰持续时间
  final int? silentDuration;

  ///
  /// 设置提醒类型
  ///
  /// Param [remindType] 提醒类型
  ///
  ChatSilentModeParam.remindType(
    this.remindType,
  )   : this.silentDuration = null,
        this.startTime = null,
        this.endTime = null,
        this._paramType = ChatSilentModeParamType.REMIND_TYPE;

  ///
  /// 设置免打扰持续时间
  ///
  /// Param [silentDuration] 免打扰持续时间，单位为分钟。
  ///
  ChatSilentModeParam.silentDuration(this.silentDuration)
      : this.startTime = null,
        this.endTime = null,
        this.remindType = null,
        this._paramType = ChatSilentModeParamType.SILENT_MODE_DURATION;

  ///
  /// 设置免打扰起始时间
  ///
  /// Param [startTime] 免打扰开始时间
  ///
  /// Param [endTime] 免打扰结束时间
  ///
  ChatSilentModeParam.silentModeInterval({
    required this.startTime,
    required this.endTime,
  })  : this.silentDuration = null,
        this.remindType = null,
        this._paramType = ChatSilentModeParamType.SILENT_MODE_INTERVAL;

  Map toJson() {
    Map data = Map();
    data.setValueWithOutNull(
        "paramType", chatSilentModeParamTypeToInt(_paramType));
    data.setValueWithOutNull("remindType", chatPushRemindTypeToInt(remindType));
    data.setValueWithOutNull("startTime", startTime?.toJson());
    data.setValueWithOutNull("endTime", endTime?.toJson());
    data.setValueWithOutNull("duration", silentDuration);
    return data;
  }
}

///
/// 免打扰时间类
///
class ChatSilentModeTime {
  /// 小时
  final int hour;

  /// 分钟.
  final int minute;

  ///
  /// 免打扰时间
  ///
  /// Param [hour] 小时
  ///
  /// Param [minute] 分钟
  ///
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

///
/// 免打扰返回类
///
class ChatSilentModeResult {
  /// 消息免打扰过期时间戳。
  final int? expireTimestamp;

  /// 会话类型。
  final EMConversationType conversationType;

  /// 会话ID。
  final String conversationId;

  ///  离线推送提醒类型。
  final ChatPushRemindType? remindType;

  /// 消息免打扰时段的开始时间。
  final ChatSilentModeTime? startTime;

  /// 消息免打扰时段的结束时间。
  final ChatSilentModeTime? endTime;

  /// @nodoc
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
        chatPushRemindTypeFromInt(map["remindType"]);
    String conversationId = map["conversationId"];
    EMConversationType conversationType =
        conversationTypeFromInt(map["conversationType"]);
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
