import 'dart:io';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:yaml/yaml.dart';

/// 从 native-auto-test/config.yaml 的 sdk_options 节直接读取配置，构建 EMOptions。
/// 运行时读取，无需代码生成。
class SdkConfigLoader {
  SdkConfigLoader._();

  /// 定位 config.yaml：从当前可执行文件位置向上查找仓库根目录下的 native-auto-test/config.yaml。
  static File? _findConfigFile() {
    // 尝试多种可能的相对路径（适配 flutter run 在 example 目录、仓库根等场景）
    final candidates = <String>[
      // 从仓库根运行
      'native-auto-test/config.yaml',
      // 从 im_flutter_sdk/example 运行
      '../../native-auto-test/config.yaml',
      // 从 im_flutter_sdk 运行
      '../native-auto-test/config.yaml',
    ];

    // 再从 Platform.script 或 Platform.resolvedExecutable 向上搜索
    Directory? dir;
    try {
      dir = File(Platform.script.toFilePath()).parent;
    } catch (_) {
      dir = Directory.current;
    }

    // 从 dir 向上最多 5 层寻找包含 native-auto-test/config.yaml 的目录
    Directory? searchDir = dir;
    for (int i = 0; i < 6; i++) {
      if (searchDir == null) break;
      final f = File('${searchDir.path}/native-auto-test/config.yaml');
      if (f.existsSync()) return f;
      final parent = searchDir.parent;
      if (parent.path == searchDir.path) break;
      searchDir = parent;
    }

    // 兜底：尝试固定候选路径
    for (final p in candidates) {
      final f = File(p);
      if (f.existsSync()) return f;
    }

    return null;
  }

  /// 读取 config.yaml 并构建 EMOptions。
  /// 找不到文件时抛出异常，便于排查。
  static EMOptions loadOptions() {
    final file = _findConfigFile();
    if (file == null || !file.existsSync()) {
      throw StateError(
        '找不到 native-auto-test/config.yaml，'
        '请确认从仓库根目录运行或 config.yaml 存在。\n'
        '当前目录: ${Directory.current.path}',
      );
    }

    final content = file.readAsStringSync();
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
