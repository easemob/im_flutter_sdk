import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_test/sdk_config_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('parseWebSocketConfig', () {
    test('解析正常 base_url 与 default_topic', () {
      final cfg = SdkConfigLoader.parseWebSocketConfig('''
websocket:
  base_url: "ws://127.0.0.1:4000/iov/websocket/dual"
  default_topic: "adc"
''');
      expect(cfg.baseUrl, 'ws://127.0.0.1:4000/iov/websocket/dual');
      expect(cfg.topic, 'adc');
    });

    test('缺失 websocket 节时返回空字段', () {
      final cfg = SdkConfigLoader.parseWebSocketConfig('''
sdk_options:
  app_key: "x#y"
''');
      expect(cfg.baseUrl, isNull);
      expect(cfg.topic, isNull);
    });

    test('base_url 与 default_topic 为空字符串时返回空字段', () {
      final cfg = SdkConfigLoader.parseWebSocketConfig('''
websocket:
  base_url: ""
  default_topic: ""
''');
      expect(cfg.baseUrl, isEmpty);
      expect(cfg.topic, isEmpty);
    });

    test('非法 yaml 时返回空字段而不抛异常', () {
      final cfg = SdkConfigLoader.parseWebSocketConfig('not: [valid');
      expect(cfg.baseUrl, isNull);
      expect(cfg.topic, isNull);
    });

    test('值带首尾空白时去除空白', () {
      final cfg = SdkConfigLoader.parseWebSocketConfig('''
websocket:
  base_url: "  ws://127.0.0.1:4000/iov/websocket/dual  "
  default_topic: "  adc  "
''');
      expect(cfg.baseUrl, 'ws://127.0.0.1:4000/iov/websocket/dual');
      expect(cfg.topic, 'adc');
    });
  });

  test('loads websocket config from the shared asset', () async {
    final cfg = await SdkConfigLoader.loadWebSocketConfig();
    // 当前 config.yaml 生效的 websocket 节为非空值。
    expect(cfg.baseUrl, isNotNull);
    expect(cfg.baseUrl, isNotEmpty);
    expect(cfg.topic, isNotNull);
    expect(cfg.topic, isNotEmpty);
  });

  group('parseTopicForDevice', () {
    const content = '''
topics:
  deviceA: adc
  deviceB: adc01
''';

    test('按设备名解析 topic', () {
      expect(SdkConfigLoader.parseTopicForDevice(content, 'deviceA'), 'adc');
      expect(SdkConfigLoader.parseTopicForDevice(content, 'deviceB'), 'adc01');
    });

    test('设备不存在时返回 null', () {
      expect(SdkConfigLoader.parseTopicForDevice(content, 'deviceC'), isNull);
    });

    test('缺失 topics 节时返回 null', () {
      expect(
        SdkConfigLoader.parseTopicForDevice('sdk_options:\n  app_key: "x#y"', 'deviceA'),
        isNull,
      );
    });

    test('topic 为空字符串时返回 null', () {
      expect(
        SdkConfigLoader.parseTopicForDevice('topics:\n  deviceA: ""', 'deviceA'),
        isNull,
      );
    });

    test('非法 yaml 时返回 null 而不抛异常', () {
      expect(SdkConfigLoader.parseTopicForDevice('not: [valid', 'deviceA'), isNull);
    });

    test('值带首尾空白时去除空白', () {
      expect(
        SdkConfigLoader.parseTopicForDevice('topics:\n  deviceA: "  adc  "', 'deviceA'),
        'adc',
      );
    });
  });
}
