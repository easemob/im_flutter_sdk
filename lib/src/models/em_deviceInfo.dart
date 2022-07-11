import '../internal/inner_headers.dart';

///
/// The EMDeviceInfo class, which contains the multi-device information.
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

  /// The information of other login devices.
  final String? resource;

  /// The UUID of the device.
  final String? deviceUUID;

  /// The device type. For example: "Pixel 6 Pro".
  final String? deviceName;
}
