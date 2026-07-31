import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml/yaml.dart';

class RunnerConfiguration {
  const RunnerConfiguration({
    required this.sdkOptions,
    required this.webSocketBaseUrl,
    required this.defaultTopic,
    required this.topics,
  });

  final Map<String, dynamic> sdkOptions;
  final String webSocketBaseUrl;
  final String defaultTopic;
  final Map<String, String> topics;

  String topicFor(String deviceName) => topics[deviceName] ?? defaultTopic;
}

class SdkConfigLoader {
  const SdkConfigLoader._();

  static Future<RunnerConfiguration> load() async {
    final content = await rootBundle.loadString('assets/config.yaml');
    final yaml = loadYaml(content) as YamlMap;
    final sdk = yaml['sdk_options'] as YamlMap?;
    if (sdk == null) {
      throw StateError('config.yaml 中未找到 sdk_options 节');
    }
    final appKey = _string(sdk, 'app_key') ?? '';
    if (appKey.isEmpty) {
      throw StateError('config.yaml sdk_options.app_key 为空');
    }

    final ws = yaml['websocket'] as YamlMap? ?? YamlMap();
    final topicsYaml = yaml['topics'] as YamlMap? ?? YamlMap();
    final topics = <String, String>{
      for (final entry in topicsYaml.entries)
        entry.key.toString(): entry.value.toString(),
    };

    return RunnerConfiguration(
      sdkOptions: {
        'appKey': appKey,
        'autoLogin': _boolean(sdk, 'auto_login', false),
        'debugModel': _boolean(sdk, 'debug_mode', true),
        'enableDNSConfig': _boolean(sdk, 'enable_dns_config', true),
        'requireAck': _boolean(sdk, 'require_ack', true),
        'requireDeliveryAck': _boolean(sdk, 'require_delivery_ack', false),
        'acceptInvitationAlways':
            _boolean(sdk, 'accept_invitation_always', false),
        'autoAcceptGroupInvitation':
            _boolean(sdk, 'auto_accept_group_invitation', false),
        'deleteMessagesAsExitGroup':
            _boolean(sdk, 'delete_messages_as_exit_group', true),
        'deleteMessagesAsExitChatRoom':
            _boolean(sdk, 'delete_messages_as_exit_chat_room', true),
        'isAutoDownload':
            _boolean(sdk, 'auto_download_thumbnail', true),
        'isChatRoomOwnerLeaveAllowed':
            _boolean(sdk, 'chat_room_owner_leave_allowed', true),
        'serverTransfer':
            _boolean(sdk, 'server_transfer', true),
        'sortMessageByServerTime':
            _boolean(sdk, 'sort_message_by_server_time', true),
        'usingHttpsOnly': _boolean(sdk, 'using_https_only', true),
        'areaCode': _integer(sdk, 'area_code') ?? -1,
        'enableUserInfo': _boolean(sdk, 'enable_user_info', true),
        if (_string(sdk, 'rest_server') case final value?) 'restServer': value,
        if (_string(sdk, 'im_server') case final value?) 'imServer': value,
        if (_integer(sdk, 'im_port') case final value?) 'imPort': value,
      },
      webSocketBaseUrl: _string(ws, 'base_url') ??
          'ws://140.143.132.6:2000/iov/websocket/dual',
      defaultTopic: _string(ws, 'default_topic') ?? 'adc',
      topics: topics,
    );
  }

  static String? _string(YamlMap map, String key) {
    final value = map[key];
    return value?.toString();
  }

  static int? _integer(YamlMap map, String key) {
    final value = map[key];
    if (value is int) return value;
    return value == null ? null : int.tryParse(value.toString());
  }

  static bool _boolean(YamlMap map, String key, bool fallback) {
    final value = map[key];
    if (value is bool) return value;
    if (value == null) return fallback;
    return value.toString().toLowerCase() == 'true';
  }
}
