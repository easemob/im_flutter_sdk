import '../internal/inner_headers.dart';

///
/// Offline push Settings parameter entity class
///
class ChatSilentModeParam {
  final ChatSilentModeParamType paramType;

  /// The offline push notification type.
  final ChatPushRemindType? remindType;

  /// The start time of offline push DND.
  final ChatSilentModeTime? startTime;

  /// The end time of offline push DND.
  final ChatSilentModeTime? endTime;

  /// The offline push DND duration.
  final int? silentDuration;

  ///
  /// Set the offline push notification type.
  ///
  /// Param [remindType] Offline push notification type.
  ///
  ChatSilentModeParam.remindType(
    this.remindType,
  )   : this.silentDuration = null,
        this.startTime = null,
        this.endTime = null,
        this.paramType = ChatSilentModeParamType.REMIND_TYPE;

  ///
  /// Set the offline push DND duration.
  ///
  /// Param [silentDuration] Offline push DND duration, units of minutes.
  ///
  ChatSilentModeParam.silentDuration(this.silentDuration)
      : this.startTime = null,
        this.endTime = null,
        this.remindType = null,
        this.paramType = ChatSilentModeParamType.SILENT_MODE_DURATION;

  ///
  /// Set the start time of offline push DND, you need to create the start time and end time together.
  ///
  /// Param [startTime] Do not disturb start time.
  ///
  /// Param [endTime] Do not disturb end time.
  ///
  ChatSilentModeParam.silentModeInterval({
    required this.startTime,
    required this.endTime,
  })  : this.silentDuration = null,
        this.remindType = null,
        this.paramType = ChatSilentModeParamType.SILENT_MODE_DURATION;

  Map toJson() {
    Map data = Map();
    data.setValueWithOutNull(
        "paramType", chatSilentModeParamTypeToInt(paramType));
    data.setValueWithOutNull("remindType", chatPushRemindTypeToInt(remindType));
    data.setValueWithOutNull("startTime", startTime?.toJson());
    data.setValueWithOutNull("endTime", endTime?.toJson());
    data.setValueWithOutNull("duration", silentDuration);
    return data;
  }
}

///
/// For offline push DND time class.
///
class ChatSilentModeTime {
  /// Number of hours.
  final int hour;

  /// Minutes.
  final int minute;

  ///
  /// For offline push DND time.
  ///
  /// Param [hour] Set the number of hours to 24 hours.
  ///
  /// Param [minute] Set minutes.
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

class ChatSilentModeResult {
  final int? expireTimestamp;
  final EMConversationType conversationType;
  final String conversationId;
  final ChatPushRemindType? remindType;
  final ChatSilentModeTime? startTime;
  final ChatSilentModeTime? endTime;

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
