import 'package:flutter_test/flutter_test.dart';

import '../lib/im_flutter_sdk.dart';

void main() {
  // setup EMClient
  EMOptions options = EMOptions(appKey: 'easemob#im_demo');
  EMClient client = EMClient.getInstance();

  setUp(() {
    client.init(options);
  });

  test('client listeners get called once migrate to 2x', () {});

  test('client login with callback invoked correctly', () {
    client.login('user1', 'passw0rd', onSuccess: () {
      print('login success');
    });
    client.login('user2', 'passw0rd', onError: (int code, String status) {
      print('login error with code: $code, status: $status');
    });
  });

  tearDown(() {});
}
