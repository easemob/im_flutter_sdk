import '../internal/inner_headers.dart';

/// 推送设置类。
class EMPushConfigs {
  EMPushConfigs._private({
    this.displayStyle = DisplayStyle.Simple,
    this.displayName,
    this.noDisturb = false,
    this.noDisturbStartHour = -1,
    this.noDisturbEndHour = -1,
  });

  /// 获取推送显示类型。
  final DisplayStyle displayStyle;

  ///
  /// 用户设置的离线推送昵称。
  ///
  final String? displayName;

  ///
  /// 获取是否开启离线推送的免打扰模式。
  /// - `true`: Yes.
  /// - `false`: No.
  ///  Sets it by [EMPushManager.disableOfflinePush].
  ///
  @Deprecated(
      "Use ChatSilentModeResult property remindType, expireTimestamp and silentModeTime determine whether to enable")
  final bool noDisturb;

  ///
  /// 获取离线推送免打扰的开始时间。该时间为 24 小时制，取值范围为 0-23。
  ///
  @Deprecated("Use ChatSilentModeResult property startTime instead")
  final int noDisturbStartHour;

  ///
  /// 获取离线推送免打扰结束的时间。该时间为 24 小时制，取值范围为 0-23。
  ///
  @Deprecated("Use ChatSilentModeResult property endTime instead")
  final int noDisturbEndHour;

  /// @nodoc
  factory EMPushConfigs.fromJson(Map map) {
    return EMPushConfigs._private(
      displayStyle:
          map['pushStyle'] == 0 ? DisplayStyle.Simple : DisplayStyle.Summary,
      noDisturb: map.boolValue('noDisturb'),
      noDisturbStartHour: map['noDisturbStartHour'],
      noDisturbEndHour: map['noDisturbEndHour'],
      displayName: map["displayName"],
    );
  }
}
