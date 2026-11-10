import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../support/ci_test.dart';

void registerLoggedOutPresenceCases({required ChatClient client}) {
  Future<void> expectNotLoggedIn(Future<void> Function() operation) async {
    await expectLater(
      operation,
      throwsA(isA<ChatError>().having((error) => error.code, 'code', 201)),
    );
  }

  // Test: While logged out, publish a nonempty presence description.
  // Expected: ChatError 201 (not logged in).
  ciTestWidgets('FL-PRESENCE-001 rejects publish while logged out', (
    tester,
  ) async {
    await expectNotLoggedIn(
      () => client.presenceManager.publishPresence('flutter-ci'),
    );
  });

  // Test: While logged out, fetch presence for a nonempty peer ID.
  // Expected: ChatError 201 (not logged in).
  ciTestWidgets('FL-PRESENCE-002 rejects status fetch while logged out', (
    tester,
  ) async {
    await expectNotLoggedIn(
      () => client.presenceManager.fetchPresenceStatus(
        members: const <String>['flutter-ci-peer'],
      ),
    );
  });

  // Test: While logged out, subscribe to a peer's presence for 60 seconds.
  // Expected: ChatError 201 (not logged in).
  ciTestWidgets('FL-PRESENCE-003 rejects subscribe while logged out', (
    tester,
  ) async {
    await expectNotLoggedIn(
      () => client.presenceManager.subscribe(
        members: const <String>['flutter-ci-peer'],
        expiry: 60,
      ),
    );
  });

  // Test: While logged out, unsubscribe from a nonempty peer ID's presence.
  // Expected: ChatError 201 (not logged in).
  ciTestWidgets('FL-PRESENCE-004 rejects unsubscribe while logged out', (
    tester,
  ) async {
    await expectNotLoggedIn(
      () => client.presenceManager.unsubscribe(
        members: const <String>['flutter-ci-peer'],
      ),
    );
  });

  // Test: While logged out, fetch the first subscription page with size 20.
  // Expected: ChatError 201 (not logged in).
  ciTestWidgets('FL-PRESENCE-005 rejects subscription query while logged out', (
    tester,
  ) async {
    await expectNotLoggedIn(
      () => client.presenceManager.fetchSubscribedMembers(
        pageNum: 1,
        pageSize: 20,
      ),
    );
  });
}
