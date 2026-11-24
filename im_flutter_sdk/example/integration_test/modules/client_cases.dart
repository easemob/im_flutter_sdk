import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../support/ci_test.dart';
import '../support/env.dart';

/// Logged-in ChatClient cases (FL-CLIENT-*).
void registerClientCases(ChatClient client) {
  ciTestWidgets('FL-CLIENT-009 tracks the logged-in user id', (tester) async {
    expect(client.currentUserId, ciUserId);
  });

  ciTestWidgets('FL-CLIENT-012 startCallback does not throw or block',
      (tester) async {
    await client.startCallback();
    expect(await client.isConnected(), isTrue);
  });

  ciTestWidgets('FL-CLIENT-013 reports a connected client', (tester) async {
    expect(await client.isConnected(), isTrue);
  });

  ciTestWidgets('FL-CLIENT-014 returns the token login user id',
      (tester) async {
    expect(await client.getCurrentUserId(), ciUserId);
  });

  ciTestWidgets('FL-CLIENT-015 returns the login token', (tester) async {
    expect(await client.getAccessToken(), ciUserToken);
  });

  ciTestWidgets('FL-CLIENT-016 returns a stable device id', (tester) async {
    final first = await client.getCurrentDeviceId();
    expect(first, isNotEmpty);
    expect(await client.getCurrentDeviceId(), first);
  });

  // 1.16.0
  ciTestWidgets('FL-CLIENT-017 reports a connected state', (tester) async {
    expect(await client.getConnectionState(), ChatConnectionState.connected);
  });
}
