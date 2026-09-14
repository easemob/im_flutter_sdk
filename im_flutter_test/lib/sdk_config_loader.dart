import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'bridge_config.dart';
import 'env_config.dart';

/// 外部环境配置文件路径（保留旧常量名，便于调用点与文档引用）。
const String kExternalConfigPath = kExternalEnvConfigPath;

/// 兼容层：把旧的 [SdkConfigLoader] 调用转发到新的环境/桥接 loader。
///
/// - 环境配置（`app:` schema，EMOptions）见 [EnvConfigLoader]。
/// - 桥接配置（`websocket`/`topics`）见 [BridgeConfigLoader]。
class SdkConfigLoader {
  SdkConfigLoader._();

  /// 加载环境配置并构建 [EMOptions]；缺 appkey 或解析失败时返回 null。
  static Future<EMOptions?> loadOptions() async {
    final result = await EnvConfigLoader.loadOptions();
    return result.options;
  }

  /// 加载环境配置并返回完整结果（含失败原因），供启动流程记录日志。
  static Future<EnvConfigResult> loadOptionsResult() =>
      EnvConfigLoader.loadOptions();

  /// 从桥接文件读取 `websocket` 节。
  static Future<({String? baseUrl, String? topic})> loadWebSocketConfig() =>
      BridgeConfigLoader.loadWebSocketConfig();

  /// 从桥接文件 topics 节读取指定设备的 topic。
  static Future<String?> loadTopicForDevice(String device) =>
      BridgeConfigLoader.loadTopicForDevice(device);

  /// 纯函数：解析 `websocket` 节，便于单元测试。
  static ({String? baseUrl, String? topic}) parseWebSocketConfig(
          String content) =>
      BridgeConfigLoader.parseWebSocketConfig(content);

  /// 纯函数：解析 `topics.<device>`，便于单元测试。
  static String? parseTopicForDevice(String content, String device) =>
      BridgeConfigLoader.parseTopicForDevice(content, device);
}
