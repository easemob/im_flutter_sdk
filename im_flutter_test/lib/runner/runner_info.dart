class RunnerInfo {
  const RunnerInfo({
    required this.runnerId,
    required this.deviceName,
    required this.platform,
    required this.sdkVersion,
    required this.appVersion,
    required this.capabilities,
    this.runId = '',
    this.logicalDevice = '',
    this.artifactId = '',
    this.wrapperCommit = '',
    this.nativeSdkSha256 = '',
    this.managedWebSocket = false,
    this.topic,
    this.webSocketBaseUrl,
  });

  factory RunnerInfo.fromNative(Map<dynamic, dynamic> raw) {
    return RunnerInfo(
      runnerId: raw['runnerId']?.toString() ?? 'unknown-runner',
      deviceName: raw['deviceName']?.toString() ?? 'deviceA',
      runId: raw['runId']?.toString() ?? '',
      logicalDevice: raw['logicalDevice']?.toString() ??
          raw['deviceName']?.toString() ??
          '',
      artifactId: raw['artifactId']?.toString() ?? '',
      wrapperCommit: raw['wrapperCommit']?.toString() ?? '',
      nativeSdkSha256: raw['nativeSdkSha256']?.toString() ?? '',
      platform: raw['platform']?.toString() ?? 'android',
      sdkVersion: raw['sdkVersion']?.toString() ?? 'unknown',
      appVersion: raw['appVersion']?.toString() ?? 'unknown',
      capabilities: (raw['capabilities'] as Iterable<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toSet(),
      topic: raw['topic']?.toString(),
      webSocketBaseUrl: raw['webSocketBaseUrl']?.toString(),
      managedWebSocket: raw['managedWebSocket'] == true ||
          raw['managedWebSocket']?.toString() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    // capabilities 为空时不输出该字段：CapabilityResolver 把"字段缺失"
    // 视为 Runner 委托 API Matrix，避免与空列表（确实不支持）混淆。
    final json = <String, dynamic>{
      'runnerId': runnerId,
      'deviceName': deviceName,
      'runId': runId,
      'logicalDevice': logicalDevice,
      'artifactId': artifactId,
      'wrapperCommit': wrapperCommit,
      'nativeSdkSha256': nativeSdkSha256,
      'platform': platform,
      'sdkVersion': sdkVersion,
      'appVersion': appVersion,
    };
    if (capabilities.isNotEmpty) {
      json['capabilities'] = capabilities.toList()..sort();
    }
    return json;
  }

  final String runnerId;
  final String deviceName;
  final String runId;
  final String logicalDevice;
  final String artifactId;
  final String wrapperCommit;
  final String nativeSdkSha256;
  final String platform;
  final String sdkVersion;
  final String appVersion;
  final Set<String> capabilities;
  final String? topic;
  final String? webSocketBaseUrl;
  final bool managedWebSocket;
}
