import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_test/env_config.dart';

String _env({
  String appkey = '"easemob#test"',
  String serverBase = '"https://a1.easemob.com"',
  String restHost = '""',
  String tcpHost = '""',
  String tcpPort = '',
  String wsHost = '""',
  String wsPort = '',
  String? msyncSsl,
  String datasyncSsl = '',
  String datasyncHost = '""',
  String datasyncPort = '',
}) {
  return '''
app:
  appkey: $appkey
  server:
    base_url: $serverBase
  sdk:
    rest_host: $restHost
    msync:
      protocol: websocket
      tcp_host: $tcpHost
      tcp_port: $tcpPort
      websocket_host: $wsHost
      websocket_port: $wsPort
${msyncSsl == null ? "" : "      use_ssl: $msyncSsl"}
  datasync:
    websocket_host: $datasyncHost
    websocket_port: $datasyncPort
    use_ssl: $datasyncSsl
''';
}

void main() {
  group('固定开关', () {
    test('无论环境如何，固定开关都写入 EMOptions', () {
      final options = EnvConfigLoader.parseOptions(_env()).options!;
      expect(options.autoLogin, isTrue);
      expect(options.debugMode, isTrue);
      expect(options.requireAck, isTrue);
      expect(options.requireDeliveryAck, isTrue);
      expect(options.enableAutoSyncContacts, isFalse);
      expect(options.enableUserInfo, isTrue);
    });
  });

  group('enableDNSConfig 派生', () {
    test('tcp_host 非空 -> 关闭 DNS', () {
      final options = EnvConfigLoader.parseOptions(
              _env(tcpHost: '"1.2.3.4"', tcpPort: '6717'))
          .options!;
      expect(options.enableDNSConfig, isFalse);
    });

    test('websocket_host 非空 -> 关闭 DNS', () {
      final options = EnvConfigLoader.parseOptions(
              _env(wsHost: '"im-api.example.com"', wsPort: '"443"'))
          .options!;
      expect(options.enableDNSConfig, isFalse);
    });

    test('msync 主机都为空 -> 开启 DNS', () {
      final options = EnvConfigLoader.parseOptions(_env()).options!;
      expect(options.enableDNSConfig, isTrue);
    });

    test('仅 rest_host 不影响 DNS 判定', () {
      final options = EnvConfigLoader.parseOptions(
              _env(restHost: '"https://rest.example.com"'))
          .options!;
      expect(options.enableDNSConfig, isTrue);
    });

    test('仅 datasync 主机不影响 DNS 判定', () {
      final options = EnvConfigLoader.parseOptions(
        _env(datasyncHost: '"140.143.132.6"', datasyncPort: '8086'),
      ).options!;
      expect(options.enableDNSConfig, isTrue);
    });
  });

  group('地址映射', () {
    test('rest_host 优先，缺失时回退 server.base_url', () {
      final withRest = EnvConfigLoader.parseOptions(
        _env(restHost: '"https://rest.example.com"'),
      ).options!;
      expect(withRest.restServer, 'https://rest.example.com');

      final fallback = EnvConfigLoader.parseOptions(_env()).options!;
      expect(fallback.restServer, 'https://a1.easemob.com');
    });

    test('msync 与 datasync 映射到对应 EMOptions 字段', () {
      final options = EnvConfigLoader.parseOptions(_env(
        tcpHost: '"tcp.example.com"',
        tcpPort: '6717',
        wsHost: '"ws.example.com"',
        wsPort: '"443"',
        datasyncHost: '"140.143.132.6"',
        datasyncPort: '8086',
      )).options!;
      expect(options.imServer, 'tcp.example.com');
      expect(options.imPort, 6717);
      expect(options.webSocketServer, 'ws.example.com');
      expect(options.webSocketPort, 443);
      expect(options.syncDataWebSocketServer, '140.143.132.6');
      expect(options.syncDataWebSocketPort, 8086);
    });

    test('空字符串映射为 null，不传空串', () {
      final options = EnvConfigLoader.parseOptions(_env()).options!;
      expect(options.imServer, isNull);
      expect(options.imPort, isNull);
      expect(options.webSocketServer, isNull);
      expect(options.webSocketPort, isNull);
      expect(options.syncDataWebSocketServer, isNull);
      expect(options.syncDataWebSocketPort, isNull);
    });

    test('端口接受整数与数字字符串，非法值视为未提供', () {
      final numeric = EnvConfigLoader.parseOptions(
        _env(tcpHost: '"h"', tcpPort: '6717'),
      ).options!;
      expect(numeric.imPort, 6717);

      final invalid = EnvConfigLoader.parseOptions(
        _env(tcpHost: '"h"', tcpPort: '"not-a-port"'),
      ).options!;
      expect(invalid.imPort, isNull);
    });
  });

  group('MSync TLS 初始化', () {
    for (final value in ['true', '1', '"1"', '" TRUE "']) {
      test('use_ssl=$value 开启原生初始化 TLS 参数', () {
        final result = EnvConfigLoader.parseOptions(_env(
          wsHost: '"ws.example.com"',
          wsPort: '"8443"',
          msyncSsl: value,
        ));
        expect(result.ok, isTrue);
        expect(result.options!.toJson()['enableTLS'], isTrue);
      });
    }
    for (final value in [
      null,
      '',
      'null',
      '""',
      'false',
      '0',
      '"0"',
      '" FALSE "'
    ]) {
      test('use_ssl=$value 不被 REST HTTPS、端口和 DataSync TLS 覆盖', () {
        final result = EnvConfigLoader.parseOptions(_env(
          wsHost: '"ws.example.com"',
          wsPort: '"8443"',
          msyncSsl: value,
          datasyncSsl: '"1"',
        ));
        expect(result.ok, isTrue);
        expect(result.options!.toJson()['enableTLS'], isFalse);
      });
    }
    for (final value in ['"private-invalid-value"', '2', '[]', '{}']) {
      test('非法 use_ssl=$value 拒绝配置且不回显原值', () {
        final result = EnvConfigLoader.parseOptions(_env(msyncSsl: value));
        expect(result.ok, isFalse);
        expect(result.options, isNull);
        expect(
            result.reason, '环境配置 app.sdk.msync.use_ssl 必须为 true/false 或 1/0');
      });
    }
    test('TCP 转发未指定 TLS 时保留非 TLS 初始化参数', () {
      final result = EnvConfigLoader.parseOptions(_env(
        tcpHost: '"10.0.2.2"',
        tcpPort: '14300',
      ));
      expect(result.ok, isTrue);
      final json = result.options!.toJson();
      expect(json['imServer'], '10.0.2.2');
      expect(json['imPort'], 14300);
      expect(json['enableTLS'], isFalse);
      expect(json['enableDNSConfig'], isFalse);
    });
  });

  group('异常输入', () {
    test('缺少 app 节返回失败结果', () {
      final result = EnvConfigLoader.parseOptions('foo: bar\n');
      expect(result.ok, isFalse);
      expect(result.reason, isNotNull);
    });

    test('appkey 为空返回失败结果', () {
      final result = EnvConfigLoader.parseOptions(_env(appkey: '""'));
      expect(result.ok, isFalse);
      expect(result.reason, contains('appkey'));
    });

    test('非法 YAML 返回失败结果而不抛异常', () {
      final result = EnvConfigLoader.parseOptions('not: [valid');
      expect(result.ok, isFalse);
      expect(result.reason, isNotNull);
    });
  });
}
