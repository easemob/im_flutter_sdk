import '../internal/inner_headers.dart';

///
/// 多设备登录信息类。
///
class EMDeviceInfo {
  EMDeviceInfo._private(
    this.resource,
    this.deviceUUID,
    this.deviceName,
  );

  /// @nodoc
  Map toJson() {
    Map data = Map();
    data.setValueWithOutNull("resource", resource);
    data.setValueWithOutNull("deviceUUID", deviceUUID);
    data.setValueWithOutNull("deviceName", deviceName);

    return data;
  }

  /// @nodoc
  factory EMDeviceInfo.fromJson(Map map) {
    return EMDeviceInfo._private(
      map.getStringValue("resource"),
      map.getStringValue("deviceUUID"),
      map.getStringValue("deviceName"),
    );
  }

  /// 登录的其他设备的信息。
  final String? resource;

  /// 设备的 UUID（唯一标识码）。
  final String? deviceUUID;

  /// 设备型号，如 "Pixel 6 Pro"。
  final String? deviceName;
}
