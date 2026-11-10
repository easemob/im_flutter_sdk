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
  // Expected: With user-info support enabled, fetchSubscribedUsers contains
  // the peer exactly once after subscription and excludes it after removal.
  // Cleanup removes any remaining subscription and deletes the fresh peer.
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

  // Test: Change one reversible own attribute, then read it through the own,
  // ID-based, and native local APIs. Clear only the Dart cache before remote
  // reads so updateUserInfo's cached return cannot satisfy these assertions.
  // Expected: With user-info support enabled, the update result, fetchOwnInfo,
  // fetchUserInfoById, and getLocalUserInfoByIds return our ID and new gender;
  // ID-based query results contain only our ID. Cleanup restores and verifies
  // the original gender, then clears the Dart cache.
  ciTestWidgets(
    'FL-USERINFO-002 own attribute update is returned by remote and local queries',
    (_) async {
      final manager = client.userInfoManager;
      final userId = await client.getCurrentUserId();
      expect(userId, isNotNull);
      manager.clearUserInfoCache();
      final original = await manager
          .fetchOwnInfo(expireTime: 0)
          .timeout(const Duration(seconds: 20));
      expect(original?.userId, userId);
      final originalGender = original!.gender;
      // Gender always has a concrete value; nullable string attributes cannot
      // be restored by passing null because null means "leave unchanged".
      final changedGender = originalGender == 1 ? 2 : 1;
      addTearDown(() async {
        try {
          await manager
              .updateUserInfo(gender: originalGender)
              .timeout(const Duration(seconds: 20));
          manager.clearUserInfoCache();
          final restored = await manager
              .fetchOwnInfo(expireTime: 0)
              .timeout(const Duration(seconds: 20));
          expect(restored?.userId, userId);
          expect(restored?.gender, originalGender);
          debugPrint('CI FL-USERINFO-002 cleanup verified: original gender');
        } finally {
          manager.clearUserInfoCache();
        }
      });

      final updated = await manager
          .updateUserInfo(gender: changedGender)
          .timeout(const Duration(seconds: 20));
      expect(updated.userId, userId);
      expect(updated.gender, changedGender);

      manager.clearUserInfoCache();
      final own = await manager
          .fetchOwnInfo(expireTime: 0)
          .timeout(const Duration(seconds: 20));
      expect(own?.userId, userId);
      expect(own?.gender, changedGender);

      manager.clearUserInfoCache();
      final fetched = await manager.fetchUserInfoById([userId!],
          expireTime: 0).timeout(const Duration(seconds: 20));
      expect(fetched.keys, unorderedEquals([userId]));
      expect(fetched[userId]?.userId, userId);
      expect(fetched[userId]?.gender, changedGender);

      manager.clearUserInfoCache();
      final local = await waitForCi(
        'Native local user attributes contain the updated own gender',
        () => manager.getLocalUserInfoByIds([userId]),
        (values) =>
            values[userId]?.userId == userId &&
            values[userId]?.gender == changedGender,
        timeout: const Duration(seconds: 20),
      );
      expect(local.keys, unorderedEquals([userId]));
      expect(local[userId]?.gender, changedGender);
      debugPrint('CI FL-USERINFO-002 verify passed');
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
