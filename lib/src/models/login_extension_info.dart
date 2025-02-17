class LoginExtensionInfo {
  factory LoginExtensionInfo.fromJson(Map<String, dynamic> json) {
    String? ext;
    if (json['ext'] != null) {
      ext = json['ext'] as String;
    }
    return LoginExtensionInfo(json['deviceName'] as String, ext: ext);
  }

  const LoginExtensionInfo(this.deviceName, {this.ext});

  /// ~english
  /// The device name.
  /// ~end
  /// ~chinese
  ///  设备名称。
  /// ~end
  final String deviceName;

  /// ~english
  /// The extension information contained in the notification sent to device A that is kicked offline due to the user's login to device B.
  /// ~end
  /// ~chinese
  /// 设备 B 登录时，将设备 A 踢下线携带的扩展信息。
  /// ~end
  final String? ext;
}
