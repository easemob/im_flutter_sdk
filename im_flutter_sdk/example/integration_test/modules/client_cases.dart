import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../support/ci_test.dart';
import '../support/login.dart';

void registerClientCases({
  required ChatClient client,
  required String userId,
  required String token,
}) {
  group('client positive', () {
    // Test: Read client state after the entry point logs in the configured user.
    // Expected: Cached/native user IDs match, the connection becomes active,
    // and getAccessToken returns a nonempty token.
    ciTestWidgets('FL-AUTH-001 positive login exposes the configured user', (
      tester,
    ) async {
      // The native getter refreshes the Dart cache; inspect the cache first.
      expect(client.currentUserId, userId);
      expect(await client.getCurrentUserId(), userId);
      await _waitForConnection(client, connected: true);
      expect((await client.getAccessToken()).isNotEmpty, isTrue);
    });

    // Test: Call getCurrentDeviceId twice during the same logged-in session.
    // Expected: Both calls return the same nonempty device ID.
    ciTestWidgets('FL-AUTH-002 positive device ID is stable within the session',
        (
      tester,
    ) async {
      final deviceId = await client.getCurrentDeviceId();
      expect(deviceId, isNotEmpty);
      expect(await client.getCurrentDeviceId(), deviceId);
    });

    // Test: Log out, then log in again with the configured user and token.
    // Expected: Logout clears both user IDs and disconnects; relogin restores
    // the user IDs, an active connection, and a nonempty access token.
    // Cleanup restores the login state even if an intermediate assertion fails.
    ciTestWidgets(
        'FL-AUTH-003 positive logout clears state and permits relogin', (
      tester,
    ) async {
      // A failed assertion after logout must not leave subsequent cases logged
      // out. This cleanup does not replace or suppress the original failure.
      addTearDown(() async {
        final current = await client.getCurrentUserId();
        if (current == null) {
          await loginForCi(client, userId, token);
        } else {
          expect(current, userId, reason: 'Unexpected user during restoration');
          await client.startCallback();
          await _waitForConnection(client, connected: true);
        }
      });

      await client.logout(false);
      expect(client.currentUserId, isNull);
      expect(await client.getCurrentUserId(), isNull);
      await _waitForConnection(client, connected: false);

      await loginForCi(client, userId, token);
      expect(client.currentUserId, userId);
      expect(await client.getCurrentUserId(), userId);
      await _waitForConnection(client, connected: true);
      expect((await client.getAccessToken()).isNotEmpty, isTrue);
    });
  });
}

Future<void> _waitForConnection(
  ChatClient client, {
  required bool connected,
}) async {
  const budget = Duration(seconds: 20);
  final elapsed = Stopwatch()..start();
  bool? actual;
  while (elapsed.elapsed < budget) {
    actual = await client.isConnected().timeout(budget - elapsed.elapsed);
    if (actual == connected) return;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  fail('Connection did not become $connected within $budget; last: $actual');
}

void registerLoggedOutClientCases({required ChatClient client}) {
  ciTestWidgets('FL-APP-001 initializes the native SDK while logged out', (
    tester,
  ) async {
    // Assumes a cold install. The Android SDK reports its persisted last-login
    // user (SharedPreferences `easemob.chat.loginuser`) after a restart without
    // logout, so a login left on the device by an earlier run makes this fail
    // even though the SDK has no session. tool/ci/run_{android,ios}_*_test.sh
    // clear the app before running, and CI starts from a fresh device.
    expect(client.currentUserId, isNull);
  });
}
