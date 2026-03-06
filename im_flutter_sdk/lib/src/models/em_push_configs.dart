import 'package:im_flutter_sdk/im_flutter_sdk.dart';

/// ~english
/// The push configuration class.
/// ~end
///
/// ~chinese
/// 推送设置类。
/// ~end
class EMPushConfigs {
  EMPushConfigs({
    this.displayStyle = DisplayStyle.Simple,
    this.displayName,
  });

  /// ~english
  /// The display type of push notifications.
  /// ~end
  ///
  /// ~chinese
  /// 获取推送显示类型。
  /// ~end
  final DisplayStyle displayStyle;

  /// ~english
  /// The user's nickname to be displayed in the notification.
  /// ~end
  ///
  /// ~chinese
  /// 通知中显示的用户昵称。
  /// ~end
  final String? displayName;

  factory EMPushConfigs.fromJson(Map map) {
    return EMPushConfigs(
      displayStyle:
          map['pushStyle'] == 0 ? DisplayStyle.Simple : DisplayStyle.Summary,
      displayName: map["displayName"],
    );
  }

  Map toJson() {
    Map data = {};
    data["pushStyle"] = displayStyle == DisplayStyle.Simple ? 0 : 1;
    data["displayName"] = displayName;
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
