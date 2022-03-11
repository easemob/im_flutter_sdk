class EMDeviceInfo {
  EMDeviceInfo._private();

  Map toJson() {
    Map data = Map();
    data['resource'] = _resource;
    data['deviceUUID'] = _deviceUUID;
    data['deviceName'] = _deviceName;
    return data;
  }

  factory EMDeviceInfo.fromJson(Map map) {
    return EMDeviceInfo._private()
      .._resource = map['resource']
      .._deviceUUID = map['deviceUUID']
      .._deviceName = map['deviceName'];
  }

  /// 设备资源描述
  String? get resource => _resource;

  /// 设备的UUID
  String? get deviceUUID => _deviceUUID;

  /// 设备名称
  String? get deviceName => _deviceName;

  String? _resource;
  String? _deviceUUID;
  String? _deviceName;
}
