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
    client.login(
        userName: 'user1',
        password: 'passw0rd',
<<<<<<< HEAD
        onSuccess: (String username) {
=======
        onSuccess: (username) {
>>>>>>> upstream/dev
          print('login success');
        });
    client.login(
        userName: 'user2',
        password: 'passw0rd',
        onError: (int code, String status) {
          print('login error with code: $code, status: $status');
        });
  });

  tearDown(() {});
}
