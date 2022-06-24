import '../tools/em_extension.dart';

///
/// 在线状态属性类，包含发布者的用户名、在线设备使用的平台、当前在线状态以及在线状态的扩展信息、更新时间和到期时间。
///
class EMPresence {
  /// 在线状态发布者的用户 ID。
  final String publisher;

  /// 自定义在线状态，例如忙碌、离开和隐身等。
  final String statusDescription;

  /// 在线状态更新 Unix 时间戳，单位为秒。
  final int lastTime;

  /// 在线状态订阅到期 Unix 时间戳，单位为秒。
  final int expiryTime;

  /// 该用户的当前在线状态详情。
  Map<String, int>? statusDetails;

  /// @nodoc
  EMPresence._private(
    this.publisher,
    this.statusDescription,
    this.statusDetails,
    this.lastTime,
    this.expiryTime,
  );

  /// @nodoc
  factory EMPresence.fromJson(Map map) {
    String publisher = map.getStringValue("publisher", defaultValue: "")!;
    String statusDescription =
        map.getStringValue("statusDescription", defaultValue: "")!;
    int latestTime = map.getIntValue("lastTime", defaultValue: 0)!;
    int expiryTime = map.getIntValue("expiryTime", defaultValue: 0)!;
    Map<String, int>? statusDetails = map["statusDetails"]?.cast<String, int>();
    return EMPresence._private(
        publisher, statusDescription, statusDetails, latestTime, expiryTime);
  }
}

///
/// 在线状态详情
///
class EMPresenceStatusDetail {
  ///
  /// 发布在线设备，可能是 "ios", "android", "linux", "windows", "webim".
  ///
  final String device;

  ///
  /// 发布的状态
  ///
  final int status;

  /// @nodoc
  EMPresenceStatusDetail._private(
    this.device,
    this.status,
  );

  /// @nodoc
  factory EMPresenceStatusDetail.fromJson(Map map) {
    String device = map["device"];
    int status = map.getIntValue("status", defaultValue: 0)!;
    return EMPresenceStatusDetail._private(device, status);
  }
}
