import 'package:flutter_test/flutter_test.dart';

import '../lib/im_flutter_sdk.dart';

void main() {
  // setup EMClient
  EMOptions options = EMOptions(appKey: 'easemob#im_demo');
  EMClient client = EMClient.getInstance();

  setUp(() {
    client.init(options);
  });

  test('client login with callback invoked correctly', () async {
    final dynamic onSuccess = expectAsync1((String userName) {
      expect(userName == 'user1', 'Wrong user name returned.');
    });
    client.login('user1', 'passw0rd', onSuccess: onSuccess);
    final dynamic onError = expectAsync2((int code, String reason) {
      expect(code == 1, "Incorrect error code.");
      expect(reason == "reason", "Incorrect error reason.");
    });
    client.login('user2', 'passw0rd', onError: onError);
  });

  tearDown(() {});
}
