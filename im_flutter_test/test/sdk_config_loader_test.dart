import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_test/env_config.dart';

const String _sampleEnv = '''
app:
  appkey: "easemob#test"
  server:
    base_url: "https://a1.easemob.com/"
  sdk:
    rest_host: ""
    msync:
      protocol: websocket
      tcp_host: ""
      websocket_host: ""
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('固定开关在初始化时写入 EMOptions', () {
    final result = EnvConfigLoader.parseOptions(_sampleEnv);
    expect(result.ok, isTrue);
    final options = result.options!;
    expect(options.autoLogin, isTrue);
    expect(options.debugMode, isTrue);
    expect(options.requireAck, isTrue);
    expect(options.requireDeliveryAck, isTrue);
    expect(options.enableAutoSyncContacts, isFalse);
    expect(options.enableUserInfo, isTrue);
  });

  test('打包 asset 为无凭据占位：加载时不抛出，仅返回失败原因', () async {
    final result = await EnvConfigLoader.loadOptions();
    expect(result.options, isNull);
    expect(result.reason, isNotNull);
    // 无外部文件时应回退到打包 asset，并标明来源。
    expect(result.source, 'asset:assets/config.yaml');
  });
}
