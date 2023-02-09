import '../internal/inner_headers.dart';

///
/// Offline push Settings parameter entity class
///
class ChatSilentModeParam {
  final ChatSilentModeParamType _paramType;

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
        this._paramType = ChatSilentModeParamType.REMIND_TYPE;

  ///
  /// Set the offline push DND duration.
  ///
  /// Param [silentDuration] Offline push DND duration, units of minutes.
  ///
  ChatSilentModeParam.silentDuration(this.silentDuration)
      : this.startTime = null,
        this.endTime = null,
        this.remindType = null,
        this._paramType = ChatSilentModeParamType.SILENT_MODE_DURATION;

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
        this._paramType = ChatSilentModeParamType.SILENT_MODE_INTERVAL;

  Map toJson() {
    Map data = Map();
    data.add("paramType", chatSilentModeParamTypeToInt(_paramType));
    data.add("remindType", chatPushRemindTypeToInt(remindType));
    data.add("startTime", startTime?.toJson());
    data.add("endTime", endTime?.toJson());
    data.add("duration", silentDuration);
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

///
/// Offline push DND result class.
///
class ChatSilentModeResult {
  /// Obtain the offline push DND expiration timestamp.
  final int? expireTimestamp;

  /// The Conversation Type.
  final EMConversationType conversationType;

  /// The Conversation ID.
  final String conversationId;

  /// The offline push notification type.
  final ChatPushRemindType? remindType;

  /// The start time of offline push DND.
  final ChatSilentModeTime? startTime;

  /// The end time of offline push DND.
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
