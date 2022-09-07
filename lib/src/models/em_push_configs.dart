import '../internal/inner_headers.dart';

/// The push configuration class.
class EMPushConfigs {
  EMPushConfigs._private({
    this.displayStyle = DisplayStyle.Simple,
    this.displayName,
    this.noDisturb = false,
    this.noDisturbStartHour = -1,
    this.noDisturbEndHour = -1,
  });

  ///
  /// The display type of push notifications.
  ///
  final DisplayStyle displayStyle;

  ///
  /// The user's nickname to be displayed in the notification.
  ///
  final String? displayName;

  ///
  /// Whether to enable the do-not-disturb mode for push notifications.
  /// - `true`: Yes.
  /// - `false`: No.
  ///  Sets it by [EMPushManager.disableOfflinePush].
  ///
  @Deprecated(
      "Use ChatSilentModeResult property remindType, expireTimestamp and silentModeTime determine whether to enable")
  final bool noDisturb;

  ///
  /// The start hour of the do-not-disturb mode for push notifications.
  ///
  @Deprecated("Use ChatSilentModeResult property startTime instead")
  final int noDisturbStartHour;

  ///
  /// The end hour of the do-not-disturb mode for push notifications.
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
