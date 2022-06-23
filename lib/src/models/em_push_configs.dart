import '../tools/em_extension.dart';
import '../em_push_manager.dart';

/// 推送设置类。
class EMPushConfigs {
  EMPushConfigs._private({
    this.displayStyle = DisplayStyle.Simple,
    this.noDisturb = false,
    this.noDisturbStartHour = -1,
    this.noDisturbEndHour = -1,
  });

  /// 获取推送显示类型。
  final DisplayStyle displayStyle;

  /// 获取是否开启离线推送的免打扰模式。
  /// - `true`: 开启；
  /// - `false`：关闭。
  final bool noDisturb;

  /// 获取离线推送免打扰的开始时间。该时间为 24 小时制，取值范围为 0-24。
  final int noDisturbStartHour;

  /// 获取离线推送免打扰结束的时间。该时间为 24 小时制，取值范围为 0-23。
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
