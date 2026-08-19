import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:integration_test/integration_test.dart';

const _publicAppKey = String.fromEnvironment(
  'E2E_APP_KEY',
  defaultValue: 'easemob#easeim',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final client = ChatClient.getInstance;

  setUpAll(() async {
    await client.init(
      ChatOptions.withAppKey(_publicAppKey, autoLogin: false, debugMode: false),
    );

    if (await client.isLoginBefore()) {
      await client.logout(false);
    }
  });

  Future<void> expectNotLoggedIn(Future<void> Function() operation) async {
    await expectLater(
      operation,
      throwsA(isA<ChatError>().having((error) => error.code, 'code', 201)),
    );
  }

  testWidgets('FL-APP-001 initializes the native SDK while logged out',
      (tester) async {
    expect(await client.isLoginBefore(), isFalse);
    expect(client.currentUserId, isNull);
  });

  testWidgets('FL-PRESENCE-001 rejects publish while logged out',
      (tester) async {
    await expectNotLoggedIn(
      () => client.presenceManager.publishPresence('flutter-ci'),
    );
  });

  testWidgets('FL-PRESENCE-002 rejects status fetch while logged out',
      (tester) async {
    await expectNotLoggedIn(
      () => client.presenceManager
          .fetchPresenceStatus(members: const <String>['flutter-ci-peer']),
    );
  });

  testWidgets('FL-PRESENCE-003 rejects subscribe while logged out',
      (tester) async {
    await expectNotLoggedIn(
      () => client.presenceManager.subscribe(
        members: const <String>['flutter-ci-peer'],
        expiry: 60,
      ),
    );
  });

  testWidgets('FL-PRESENCE-004 rejects unsubscribe while logged out',
      (tester) async {
    await expectNotLoggedIn(
      () => client.presenceManager
          .unsubscribe(members: const <String>['flutter-ci-peer']),
    );
  });

  testWidgets('FL-PRESENCE-005 rejects subscription query while logged out',
      (tester) async {
    await expectNotLoggedIn(
      () => client.presenceManager.fetchSubscribedMembers(
        pageNum: 1,
        pageSize: 20,
      ),
    );
  });
}
