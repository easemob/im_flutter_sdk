import '../tools/em_extension.dart';
import '../em_push_manager.dart';

/// The push configuration class.
class EMPushConfigs {
  EMPushConfigs._private({
    this.displayStyle = DisplayStyle.Simple,
    this.noDisturb = false,
    this.noDisturbStartHour = -1,
    this.noDisturbEndHour = -1,
  });

  ///
  /// The display type of push notifications.
  ///
  final DisplayStyle displayStyle;

  ///
  /// Whether to enable the do-not-disturb mode for push notifications.
  /// - `true`: Yes.
  /// - `false`: No.
  ///  Sets it by {@link EMPushManager#disableOfflinePush(int, int)}.
  ///
  final bool noDisturb;

  ///
  /// The start hour of the do-not-disturb mode for push notifications.
  ///
  final int noDisturbStartHour;

  ///
  /// The end hour of the do-not-disturb mode for push notifications.
  ///
  final int noDisturbEndHour;

  // ignore: unused_field
  DisplayStyle? _displayStyle;
  // ignore: unused_field
  bool? _noDisturb;
  // ignore: unused_field
  int? _noDisturbStartHour;
  // ignore: unused_field
  int? _noDisturbEndHour;
  // ignore: unused_field
  List<String>? _noDisturbGroups = [];

  /// @nodoc
  factory EMPushConfigs.fromJson(Map map) {
    return EMPushConfigs._private(
      displayStyle:
          map['pushStyle'] == 0 ? DisplayStyle.Simple : DisplayStyle.Summary,
      noDisturb: map.boolValue('noDisturb'),
      noDisturbStartHour: map['noDisturbStartHour'],
      noDisturbEndHour: map['noDisturbEndHour'],
    );
  }
}
