import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_test/sdk_config_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads requireDeliveryAck from the shared SDK options asset', () async {
    final options = await SdkConfigLoader.loadOptions();

    expect(options.requireDeliveryAck, isTrue);
  });
}
