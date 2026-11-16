import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../support/ci_test.dart';
import '../support/env.dart';

/// Logged-out entry cases: SDK initialization, the client facade, and the
/// negative login contract.
void registerLoggedOutClientCases(ChatClient client) {
  ciTestWidgets(
    'FL-APP-001 initializes the native SDK while logged out',
    (tester) async {
      expect(await client.isConnected(), isFalse);
      expect(client.currentUserId, isNull);
      expect(await client.getCurrentUserId(), isNull);
    },
  );

  group('ChatClient facade', () {
    ciTestWidgets('FL-CLIENT-001 keeps a singleton instance', (tester) async {
      expect(identical(ChatClient.getInstance, client), isTrue);
    });

    ciTestWidgets('FL-CLIENT-002 exposes the chat manager', (tester) async {
      expect(client.chatManager, isNotNull);
    });

    ciTestWidgets('FL-CLIENT-003 exposes the contact manager', (tester) async {
      expect(client.contactManager, isNotNull);
    });

    ciTestWidgets('FL-CLIENT-004 exposes the chat room manager',
        (tester) async {
      expect(client.chatRoomManager, isNotNull);
    });

    ciTestWidgets('FL-CLIENT-005 exposes the group manager', (tester) async {
      expect(client.groupManager, isNotNull);
    });

    ciTestWidgets('FL-CLIENT-006 exposes the push manager', (tester) async {
      expect(client.pushManager, isNotNull);
    });

    ciTestWidgets('FL-CLIENT-007 exposes the presence manager', (tester) async {
      expect(client.presenceManager, isNotNull);
    });

    ciTestWidgets('FL-CLIENT-008 exposes the user info manager',
        (tester) async {
      expect(client.userInfoManager, isNotNull);
    });

    ciTestWidgets('FL-CLIENT-010 keeps the configured app key', (tester) async {
      expect(client.options?.appKey, ciAppKey);
    });
  });

  // 1.16.0
  ciTestWidgets('FL-CLIENT-018 reports a disconnected state while logged out',
      (tester) async {
    expect(await client.getConnectionState(), ChatConnectionState.disconnected);
  });

  ciTestWidgets('FL-CLIENT-040 reports a token only when logged in',
      (tester) async {
    try {
      final token = await client.getAccessToken();
      // The 4.25 contract is not fixed on HarmonyOS yet: while logged out the
      // native side may return an empty token instead of throwing.
      expect(token, isEmpty);
    } on ChatError catch (error) {
      debugPrint('FL-CLIENT-040 getAccessToken while logged out '
          'threw code=${error.code}');
    }
  });

  ciTestWidgets('FL-AUTH-020 rejects an invalid token login', (tester) async {
    await expectLater(
      () => client
          .loginWithToken(ciUserId, 'ci-invalid-token')
          .timeout(const Duration(seconds: 30)),
      throwsA(isA<ChatError>()),
    );
    expect(await client.isConnected(), isFalse);
  });
}
