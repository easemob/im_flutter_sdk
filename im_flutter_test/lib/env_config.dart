import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:yaml/yaml.dart';

/// 外部环境配置文件路径（adb push 到 App 的 external files dir）。
/// 运行时不改配置即可切换环境：把环境文件推到该路径后重启 App。
const String kExternalEnvConfigPath =
    '/sdcard/Android/data/com.easemob.im_flutter_test/files/config.yaml';

/// 测试 App 固定的 SDK 初始化开关（不来自配置文件，不改变发布 SDK 默认值）。
const bool kFixedAutoLogin = true;
const bool kFixedDebugMode = true;
const bool kFixedRequireAck = true;
const bool kFixedRequireDeliveryAck = true;
const bool kFixedEnableAutoSyncContacts = false;
const bool kFixedEnableUserInfo = true;

/// 环境配置加载结果：成功时 [options] 非空，失败时 [reason] 说明原因。
class EnvConfigResult {
  const EnvConfigResult(this.options, this.reason, {this.source = ''});

  final EMOptions? options;
  final String? reason;

  /// 配置来源标签，如 `external:/sdcard/.../config.yaml` 或 `asset:assets/config.yaml`。
  final String source;

  bool get ok => options != null;
}

/// 解析 `app:` schema 的环境配置并构建 [EMOptions]。
///
/// 映射（见 .doc/specs/shared-runtime-config/design.md）：
/// - appkey -> appKey
/// - sdk.rest_host（空则 server.base_url）-> restServer
/// - sdk.msync.tcp_host/tcp_port -> imServer/imPort
/// - sdk.msync.websocket_host/websocket_port -> webSocketServer/webSocketPort
/// - datasync.websocket_host/websocket_port -> syncDataWebSocketServer/syncDataWebSocketPort
/// - enableDNSConfig 由 msync 是否给出 tcp/websocket 主机派生
class EnvConfigLoader {
  EnvConfigLoader._();

  /// 读取环境文件内容：优先外部文件，缺失/失败回退打包 asset。
  /// 返回内容与来源标签（用于失败原因定位）。
  static Future<({String content, String source})?> readRaw() async {
    final file = File(kExternalEnvConfigPath);
    try {
      if (await file.exists()) {
        return (
          content: await file.readAsString(),
          source: 'external:$kExternalEnvConfigPath',
        );
      }
    } catch (_) {
      // 外部文件读取失败，回退 asset。
    }
    try {
      return (
        content: await rootBundle.loadString('assets/config.yaml'),
        source: 'asset:assets/config.yaml',
      );
    } catch (_) {
      return null;
    }
  }

  /// 加载并构建 EMOptions；缺 appkey 或解析失败时返回带原因的失败结果。
  static Future<EnvConfigResult> loadOptions() async {
    final raw = await readRaw();
    if (raw == null || raw.content.trim().isEmpty) {
      return const EnvConfigResult(null, '未找到环境配置（外部文件与打包 asset 均缺失）');
    }
    final result = parseOptions(raw.content);
    if (result.ok) {
      return EnvConfigResult(result.options, null, source: raw.source);
    }
    return EnvConfigResult(null, '${result.reason}（来源: ${raw.source}）', source: raw.source);
  }

  /// 纯函数：从环境文件内容构建 [EMOptions]，便于单元测试。
  static EnvConfigResult parseOptions(String content) {
    final YamlMap root;
    try {
      final parsed = loadYaml(content);
      if (parsed is! YamlMap) {
        return const EnvConfigResult(null, '环境配置根节点必须是映射');
      }
      root = parsed;
    } catch (e) {
      return EnvConfigResult(null, '环境配置 YAML 解析失败: $e');
    }

    final app = root['app'];
    if (app is! YamlMap) {
      return const EnvConfigResult(null, '环境配置缺少 app 节');
    }

    final appkey = _str(app, 'appkey') ?? '';
    if (appkey.isEmpty) {
      return const EnvConfigResult(null, '环境配置 app.appkey 为空');
    }

    final server = app['server'] is YamlMap ? app['server'] as YamlMap : null;
    final sdk = app['sdk'] is YamlMap ? app['sdk'] as YamlMap : null;
    final msync = (sdk?['msync'] is YamlMap) ? sdk!['msync'] as YamlMap : null;
    final datasync =
        app['datasync'] is YamlMap ? app['datasync'] as YamlMap : null;

    final restServer = _firstNonEmpty(
      _str(sdk, 'rest_host'),
      _str(server, 'base_url'),
    );
    final tcpHost = _str(msync, 'tcp_host');
    final wsHost = _str(msync, 'websocket_host');

    // DNS 派生：msync 显式给出 tcp 或 websocket 主机时关闭 DNS 自动发现。
    final enableDNSConfig = !(_nonEmpty(tcpHost) || _nonEmpty(wsHost));

    final options = EMOptions.withAppKey(
      appkey,
      restServer: restServer,
      imServer: tcpHost,
      imPort: _int(msync, 'tcp_port'),
      webSocketServer: wsHost,
      webSocketPort: _int(msync, 'websocket_port'),
      syncDataWebSocketServer: _str(datasync, 'websocket_host'),
      syncDataWebSocketPort: _int(datasync, 'websocket_port'),
      // 固定测试开关，不读取配置。
      autoLogin: kFixedAutoLogin,
      debugMode: kFixedDebugMode,
      requireAck: kFixedRequireAck,
      requireDeliveryAck: kFixedRequireDeliveryAck,
      enableAutoSyncContacts: kFixedEnableAutoSyncContacts,
      enableUserInfo: kFixedEnableUserInfo,
      enableDNSConfig: enableDNSConfig,
    );
    return EnvConfigResult(options, null);
  }

  static String? _str(YamlMap? map, String key) {
    if (map == null) return null;
    final value = map[key];
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int? _int(YamlMap? map, String key) {
    if (map == null) return null;
    final value = map[key];
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString().trim());
  }

  static bool _nonEmpty(String? value) => value != null && value.isNotEmpty;

  static String? _firstNonEmpty(String? a, String? b) {
    if (_nonEmpty(a)) return a;
    if (_nonEmpty(b)) return b;
    return null;
  }
}
