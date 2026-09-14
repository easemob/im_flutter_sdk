import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml/yaml.dart';

/// 外部桥接配置文件路径（run.sh 按 lane 生成后 adb push）。
const String kExternalBridgeConfigPath =
    '/sdcard/Android/data/com.easemob.im_flutter_test/files/bridge.yaml';

/// 桥接运行态配置解析：`websocket` + `topics`。
///
/// 读取优先级：外部 `bridge.yaml` > 打包 `assets/bridge.yaml`。
/// 所有解析均为纯函数/容错：缺失、空值、非法 YAML 时返回 null，由调用方回退默认值。
class BridgeConfigLoader {
  BridgeConfigLoader._();

  /// 读取桥接文件内容：优先外部文件，缺失/失败回退打包 asset。
  static Future<String?> readRaw() async {
    final file = File(kExternalBridgeConfigPath);
    try {
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (_) {
      // 外部文件读取失败，回退 asset。
    }
    try {
      return await rootBundle.loadString('assets/bridge.yaml');
    } catch (_) {
      return null;
    }
  }

  /// 从桥接文件读取 `websocket` 节；失败返回空字段。
  static Future<({String? baseUrl, String? topic})>
      loadWebSocketConfig() async {
    final content = await readRaw();
    if (content == null) {
      return (baseUrl: null, topic: null);
    }
    return parseWebSocketConfig(content);
  }

  /// 从桥接文件读取指定设备的 topic；失败返回 null。
  static Future<String?> loadTopicForDevice(String device) async {
    final content = await readRaw();
    if (content == null) {
      return null;
    }
    return parseTopicForDevice(content, device);
  }

  /// 纯函数：解析 `websocket.base_url` 与 `websocket.default_topic`。
  static ({String? baseUrl, String? topic}) parseWebSocketConfig(
      String content) {
    try {
      final yaml = loadYaml(content) as YamlMap;
      final ws = yaml['websocket'] as YamlMap?;
      return (
        baseUrl: _trimmed(ws?['base_url']),
        topic: _trimmed(ws?['default_topic']),
      );
    } catch (_) {
      return (baseUrl: null, topic: null);
    }
  }

  /// 纯函数：解析 `topics.<device>`；缺失或为空返回 null。
  static String? parseTopicForDevice(String content, String device) {
    try {
      final yaml = loadYaml(content) as YamlMap;
      final topics = yaml['topics'] as YamlMap?;
      return _trimmed(topics?[device]);
    } catch (_) {
      return null;
    }
  }

  static String? _trimmed(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
