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

  ciTestWidgets('FL-PRESENCE-001 rejects publish while logged out', (
    tester,
  ) async {
    await expectNotLoggedIn(
      () => client.presenceManager.publishPresence('flutter-ci'),
    );
  });

  ciTestWidgets('FL-PRESENCE-002 rejects status fetch while logged out', (
    tester,
  ) async {
    await expectNotLoggedIn(
      () => client.presenceManager.fetchPresenceStatus(
        members: const <String>['flutter-ci-peer'],
      ),
    );
  });

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

  ciTestWidgets('FL-PRESENCE-004 rejects unsubscribe while logged out', (
    tester,
  ) async {
    await expectNotLoggedIn(
      () => client.presenceManager.unsubscribe(
        members: const <String>['flutter-ci-peer'],
      ),
    );
  });

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
