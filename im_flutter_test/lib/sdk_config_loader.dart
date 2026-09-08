import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:yaml/yaml.dart';

/// 外部配置文件路径（adb push 到 App 的 external files dir）。
/// 用于“启动传入配置”：改配置无需重新打包 APK，直接把 config.yaml 推入该路径即可。
const String kExternalConfigPath =
    '/sdcard/Android/data/com.easemob.im_flutter_test/files/config.yaml';

/// 读取 config.yaml 配置并构建 EMOptions。
///
/// 优先级：外部文件（启动传入） > 打包 asset（assets/config.yaml）。
/// 这样 release APK 可复用，配置由运行时推入，无需重新编译。
class SdkConfigLoader {
  SdkConfigLoader._();

  /// 读取 config.yaml 内容：优先外部文件，缺失/失败回退打包 asset。
  static Future<String> _loadConfigContent() async {
    final file = File(kExternalConfigPath);
    try {
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (_) {
      // 外部文件读取失败，回退 asset。
    }
    return rootBundle.loadString('assets/config.yaml');
  }

  /// 异步加载 config.yaml 并构建 EMOptions。
  static Future<EMOptions> loadOptions() async {
    final content = await _loadConfigContent();
    final yaml = loadYaml(content) as YamlMap;
    final sdkOpts = yaml['sdk_options'] as YamlMap?;

    if (sdkOpts == null) {
      throw StateError('config.yaml 中未找到 sdk_options 节');
    }

    final appKey = sdkOpts['app_key']?.toString() ?? '';
    if (appKey.isEmpty) {
      throw StateError('config.yaml sdk_options.app_key 为空');
    }

    return EMOptions.withAppKey(
      appKey,
      restServer: _str(sdkOpts, 'rest_server'),
      imServer: _str(sdkOpts, 'im_server'),
      imPort: _int(sdkOpts, 'im_port'),
      webSocketServer: _str(sdkOpts, 'web_socket_server'),
      webSocketPort: _int(sdkOpts, 'web_socket_port'),
      autoLogin: _bool(sdkOpts, 'auto_login', true),
      debugMode: _bool(sdkOpts, 'debug_mode', false),
      enableDNSConfig: _bool(sdkOpts, 'enable_dns_config', true),
      syncDataWebSocketServer: _str(sdkOpts, 'sync_data_web_socket_server'),
      syncDataWebSocketPort: _int(sdkOpts, 'sync_data_web_socket_port'),
      requireAck: _bool(sdkOpts, 'require_ack', true),
      requireDeliveryAck: _bool(sdkOpts, 'require_delivery_ack', false),
      enableAutoSyncContacts: _bool(sdkOpts, 'enable_auto_sync_contacts', false),
      enableUserInfo: _boolNullable(sdkOpts, 'enable_user_info'),
    );
  }

  /// 从 config.yaml 的 websocket 节读取桥接配置。
  /// 返回可空字段：缺失/空/解析失败时返回 null，由调用方回退默认值。
  static Future<({String? baseUrl, String? topic})> loadWebSocketConfig() async {
    final content = await _loadConfigContent();
    return parseWebSocketConfig(content);
  }

  /// 纯函数：从 yaml 内容解析 websocket 配置，便于单元测试。
  static ({String? baseUrl, String? topic}) parseWebSocketConfig(String content) {
    try {
      final yaml = loadYaml(content) as YamlMap;
      final ws = yaml['websocket'] as YamlMap?;
      return (
        baseUrl: ws?['base_url']?.toString().trim(),
        topic: ws?['default_topic']?.toString().trim(),
      );
    } catch (_) {
      return (baseUrl: null, topic: null);
    }
  }

  /// 从 config.yaml 的 topics 节读取指定设备的 topic；缺失/空/解析失败返回 null。
  static Future<String?> loadTopicForDevice(String device) async {
    final content = await _loadConfigContent();
    return parseTopicForDevice(content, device);
  }

  /// 纯函数：从 yaml 内容的 topics 节解析指定设备的 topic，便于单元测试。
  static String? parseTopicForDevice(String content, String device) {
    try {
      final yaml = loadYaml(content) as YamlMap;
      final topics = yaml['topics'] as YamlMap?;
      final topic = topics?[device]?.toString().trim();
      return (topic == null || topic.isEmpty) ? null : topic;
    } catch (_) {
      return null;
    }
  }

  static String? _str(YamlMap m, String key) {
    final v = m[key];
    if (v == null) return null;
    return v.toString();
  }

  static int? _int(YamlMap m, String key) {
    final v = m[key];
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static bool _bool(YamlMap m, String key, bool defaultValue) {
    final v = m[key];
    if (v == null) return defaultValue;
    if (v is bool) return v;
    return v.toString().toLowerCase() == 'true';
  }

  static bool? _boolNullable(YamlMap m, String key) {
    final v = m[key];
    if (v == null) return null;
    if (v is bool) return v;
    return v.toString().toLowerCase() == 'true';
  }
}
