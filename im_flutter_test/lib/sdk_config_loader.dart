import 'package:flutter/services.dart' show rootBundle;
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:yaml/yaml.dart';

/// 从 assets/config.yaml（软链到 native-auto-test/config.yaml）的 sdk_options 节
/// 读取配置并构建 EMOptions。
///
/// 运行时直接从 asset 读取，无需代码生成步骤。
/// 修改 native-auto-test/config.yaml 后重新编译即可生效。
class SdkConfigLoader {
  SdkConfigLoader._();

  /// 异步加载 config.yaml asset 并构建 EMOptions。
  static Future<EMOptions> loadOptions() async {
    final content = await rootBundle.loadString('assets/config.yaml');
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
