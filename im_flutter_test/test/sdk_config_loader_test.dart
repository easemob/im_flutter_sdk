import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_test/sdk_config_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads native option maps from the shared config asset', () async {
    final config = await SdkConfigLoader.load();

    expect(config.sdkOptions['requireDeliveryAck'], isTrue);
    expect(config.sdkOptions['appKey'], isNotEmpty);
    expect(config.topicFor('deviceA'), isNotEmpty);
  });
}
