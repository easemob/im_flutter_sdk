import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:integration_test/integration_test.dart';

import 'support/ci_test.dart';
import 'support/login.dart';
import 'support/rest_fixture.dart';
import 'support/user_info_peer_fixture.dart';

const _appKey = String.fromEnvironment('E2E_APP_KEY');
const _userId = String.fromEnvironment('E2E_USER_ID');
const _token = String.fromEnvironment('E2E_USER_TOKEN');
const _restApi = String.fromEnvironment('E2E_REST_API');
const _appToken = String.fromEnvironment('E2E_APP_TOKEN');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final required = <String, String>{
    'E2E_APP_KEY': _appKey,
    'E2E_USER_ID': _userId,
    'E2E_USER_TOKEN': _token,
    'E2E_REST_API': _restApi,
    'E2E_APP_TOKEN': _appToken,
  };
  final missing = required.entries
      .where((entry) => entry.value.isEmpty)
      .map((entry) => entry.key);
  if (missing.isNotEmpty) {
    throw StateError('Missing dart-defines: ${missing.join(', ')}');
  }
  final client = ChatClient.getInstance;
  var initialized = false;

  setUpAll(() async {
    await client
        .init(ChatOptions.withAppKey(
          _appKey,
          debugMode: false,
          enableUserInfo: true,
          autoLoadConversations: true,
          enableChatroomConversation: false,
          dataSyncType:
              ChatDataSyncType.contacts | ChatDataSyncType.joinedGroups,
        ))
        .timeout(const Duration(seconds: 30));
    initialized = true;
    await loginForCi(client, _userId, _token);
  });

  tearDownAll(() async {
    if (initialized) {
      await client.logout(false).timeout(const Duration(seconds: 30));
      expect(await client.getCurrentUserId(), isNull);
      await waitForCi('User info suite disconnected after logout',
          client.isConnected, (connected) => !connected);
    }
  });

  // Test: Subscribe to a fresh offline non-friend, query the actual user list,
  // unsubscribe, and verify that the target disappears. Never edit user info
  // or use this historically defective query to snapshot existing relations.
  ciTestWidgets(
    'FL-USERINFO-001 subscribed user list includes and removes a fresh peer',
    (_) async {
      final peer = UserInfoPeerFixture(
          restApi: _restApi, appKey: _appKey, appToken: _appToken);
      final manager = client.userInfoManager;
      var subscriptionAttempted = false;
      var subscriptionRemoved = false;
      addTearDown(() async {
        try {
          if (subscriptionAttempted && !subscriptionRemoved) {
            await manager.unsubscribeUsersInfo([peer.userId]).timeout(
                const Duration(seconds: 20));
            await _expectMembership(manager, peer.userId, false);
          }
        } finally {
          try {
            await peer.delete();
            debugPrint('CI FL-USERINFO-001 cleanup: fixture cleanup complete');
          } finally {
            peer.close();
          }
        }
      });

      debugPrint(
          'CI FL-USERINFO-001 prepare: fresh offline peer ${peer.userId}');
      await peer.create();
      subscriptionAttempted = true;
      await manager.subscribeUsersInfo([peer.userId]).timeout(
          const Duration(seconds: 20));
      await _expectMembership(manager, peer.userId, true);
      debugPrint('CI FL-USERINFO-001 verify: subscribed peer present');
      await manager.unsubscribeUsersInfo([peer.userId]).timeout(
          const Duration(seconds: 20));
      await _expectMembership(manager, peer.userId, false);
      subscriptionRemoved = true;
      debugPrint('CI FL-USERINFO-001 verify: unsubscribed peer absent');
    },
  );
}

Future<void> _expectMembership(
    ChatUserInfoManager manager, String peerId, bool present) async {
  final ids = await waitForCi(
    'Subscribed user list contains fresh peer = $present',
    () async => (await manager.fetchSubscribedUsers())
        .map((info) => info.userId)
        .toList(),
    (ids) => ids.contains(peerId) == present,
    timeout: const Duration(seconds: 20),
  );
  expect(ids.where((id) => id == peerId), hasLength(present ? 1 : 0));
}
