import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../support/ci_test.dart';
import '../support/rest_fixture.dart';
import '../support/user_info_peer_fixture.dart';

void registerUserInfoCases({
  required ChatClient client,
  required String restApi,
  required String appKey,
  required String appToken,
}) {
  // Test: Subscribe to a fresh offline non-friend, query the actual user list,
  // unsubscribe, and verify that the target disappears. Never edit user info
  // or use this historically defective query to snapshot existing relations.
  ciTestWidgets(
    'FL-USERINFO-001 subscribed user list includes and removes a fresh peer',
    (_) async {
      final peer = UserInfoPeerFixture(
          restApi: restApi, appKey: appKey, appToken: appToken);
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
