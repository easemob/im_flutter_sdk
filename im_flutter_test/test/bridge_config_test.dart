import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_test/bridge_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('parseWebSocketConfig', () {
    test('解析正常 base_url 与 default_topic', () {
      final cfg = BridgeConfigLoader.parseWebSocketConfig('''
websocket:
  base_url: "ws://127.0.0.1:4000/iov/websocket/dual"
  default_topic: "adc"
''');
      expect(cfg.baseUrl, 'ws://127.0.0.1:4000/iov/websocket/dual');
      expect(cfg.topic, 'adc');
    });

    test('缺失 websocket 节时返回空字段', () {
      final cfg = BridgeConfigLoader.parseWebSocketConfig('app:\n  appkey: "x#y"');
      expect(cfg.baseUrl, isNull);
      expect(cfg.topic, isNull);
    });

    test('空字符串时返回空字段', () {
      final cfg = BridgeConfigLoader.parseWebSocketConfig('''
websocket:
  base_url: ""
  default_topic: ""
''');
      expect(cfg.baseUrl, isNull);
      expect(cfg.topic, isNull);
    });

    test('非法 yaml 时返回空字段而不抛异常', () {
      final cfg = BridgeConfigLoader.parseWebSocketConfig('not: [valid');
      expect(cfg.baseUrl, isNull);
      expect(cfg.topic, isNull);
    });

    test('值带首尾空白时去除空白', () {
      final cfg = BridgeConfigLoader.parseWebSocketConfig('''
websocket:
  base_url: "  ws://127.0.0.1:4000/iov/websocket/dual  "
  default_topic: "  adc  "
''');
      expect(cfg.baseUrl, 'ws://127.0.0.1:4000/iov/websocket/dual');
      expect(cfg.topic, 'adc');
    });
  });

  group('parseTopicForDevice', () {
    const content = '''
topics:
  deviceA: adc
  deviceB: adc01
''';

    test('按设备名解析 topic', () {
      expect(BridgeConfigLoader.parseTopicForDevice(content, 'deviceA'), 'adc');
      expect(BridgeConfigLoader.parseTopicForDevice(content, 'deviceB'), 'adc01');
    });

    test('设备不存在时返回 null', () {
      expect(BridgeConfigLoader.parseTopicForDevice(content, 'deviceC'), isNull);
    });

    test('缺失 topics 节时返回 null', () {
      expect(
        BridgeConfigLoader.parseTopicForDevice('app:\n  appkey: "x#y"', 'deviceA'),
        isNull,
      );
    });

    test('topic 为空字符串时返回 null', () {
      expect(
        BridgeConfigLoader.parseTopicForDevice('topics:\n  deviceA: ""', 'deviceA'),
        isNull,
      );
    });

    test('非法 yaml 时返回 null 而不抛异常', () {
      expect(
        BridgeConfigLoader.parseTopicForDevice('not: [valid', 'deviceA'),
        isNull,
      );
    });

    test('值带首尾空白时去除空白', () {
      expect(
        BridgeConfigLoader.parseTopicForDevice(
            'topics:\n  deviceA: "  adc  "', 'deviceA'),
        'adc',
      );
    });
  });

  group('asset 回退', () {
    test('从打包 bridge.yaml 读取非空 base_url/topic', () async {
      final cfg = await BridgeConfigLoader.loadWebSocketConfig();
      expect(cfg.baseUrl, isNotNull);
      expect(cfg.baseUrl, isNotEmpty);
      expect(cfg.topic, isNotNull);
      expect(cfg.topic, isNotEmpty);
    });
  });
}
