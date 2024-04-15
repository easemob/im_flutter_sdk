import '../internal/inner_headers.dart';

/// ~english
/// The EMDeviceInfo class, which contains the multi-device information.
/// ~end
///
/// ~chinese
/// 多设备登录信息类。
/// ~end
class EMDeviceInfo {
  EMDeviceInfo._private(
    this.resource,
    this.deviceUUID,
    this.deviceName,
  );

  Map toJson() {
    Map data = Map();
    data.putIfNotNull("resource", resource);
    data.putIfNotNull("deviceUUID", deviceUUID);
    data.putIfNotNull("deviceName", deviceName);

    return data;
  }

  factory EMDeviceInfo.fromJson(Map map) {
    return EMDeviceInfo._private(
      map["resource"],
      map["deviceUUID"],
      map["deviceName"],
    );
  }

  /// ~english
  /// The information of other login devices.
  /// ~end
  ///
  /// ~chinese
  /// 登录的其他设备的信息。
  /// ~end
  final String? resource;

  /// ~english
  /// The UUID of the device.
  /// ~end
  ///
  /// ~chinese
  /// 设备的 UUID（唯一标识码）。
  /// ~end
  final String? deviceUUID;

  /// ~english
  /// The device type. For example: "Pixel 6 Pro".
  /// ~end
  ///
  /// ~chinese
  /// 设备型号，如 "Pixel 6 Pro"。
  /// ~end
  final String? deviceName;
}
