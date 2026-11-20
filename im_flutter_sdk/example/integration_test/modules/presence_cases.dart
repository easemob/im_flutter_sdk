import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../support/ci_test.dart';
import '../support/rest_fixture.dart';
import '../support/user_info_peer_fixture.dart';

void registerLoggedInPresenceCases({
  required ChatClient client,
  required String userId,
  required String restApi,
  required String appKey,
  required String appToken,
}) {
  // Test: Snapshot our own description, publish a unique value, and fetch it.
  // Expected: The returned publisher and description match; cleanup restores
  // the original description. This does not assert delivery to another client.
  ciTestWidgets(
    'FL-PRESENCE-006 published own description is returned by status fetch',
    (_) async {
      final manager = client.presenceManager;
      final original = await _ownPresence(manager, userId);
      addTearDown(() async {
        await manager
            .publishPresence(original.statusDescription)
            .timeout(const Duration(seconds: 20));
        await _expectOwnDescription(
            manager, userId, original.statusDescription);
        debugPrint('CI FL-PRESENCE-006 cleanup: original description restored');
      });

      final description =
          'ci_presence_${DateTime.now().microsecondsSinceEpoch}';
      await manager
          .publishPresence(description)
          .timeout(const Duration(seconds: 20));
      await _expectOwnDescription(manager, userId, description);
    },
  );

  // Test: Subscribe to a fresh offline account, query the complete paged list,
  // then unsubscribe and query again. No second logged-in client is required.
  // Expected: Subscribe returns exactly the requested publisher; the target
  // appears once in the subscription list and disappears after unsubscribe.
  ciTestWidgets(
    'FL-PRESENCE-007 subscription list includes and removes a fresh offline peer',
    (_) async {
      final manager = client.presenceManager;
      final peer = UserInfoPeerFixture(
          restApi: restApi, appKey: appKey, appToken: appToken);
      var subscriptionAttempted = false;
      var subscriptionRemoved = false;
      addTearDown(() async {
        try {
          if (subscriptionAttempted && !subscriptionRemoved) {
            await manager.unsubscribe(
                members: [peer.userId]).timeout(const Duration(seconds: 20));
            await _expectSubscription(manager, peer.userId, false);
          }
        } finally {
          try {
            await peer.delete();
            debugPrint('CI FL-PRESENCE-007 cleanup: fresh peer deleted');
          } finally {
            peer.close();
          }
        }
      });

      await peer.create();
      await _expectSubscription(manager, peer.userId, false);
      subscriptionAttempted = true;
      final subscribed = await manager.subscribe(
        members: [peer.userId],
        expiry: 3600,
      ).timeout(const Duration(seconds: 20));
      expect(subscribed.map((presence) => presence.publisher),
          orderedEquals([peer.userId]));
      await _expectSubscription(manager, peer.userId, true);

      await manager.unsubscribe(
          members: [peer.userId]).timeout(const Duration(seconds: 20));
      await _expectSubscription(manager, peer.userId, false);
      subscriptionRemoved = true;
    },
  );
}

Future<ChatPresence> _ownPresence(
    ChatPresenceManager manager, String userId) async {
  final presences = await manager.fetchPresenceStatus(
      members: [userId]).timeout(const Duration(seconds: 20));
  expect(
      presences.map((presence) => presence.publisher), orderedEquals([userId]));
  return presences.single;
}

Future<void> _expectOwnDescription(
    ChatPresenceManager manager, String userId, String description) async {
  final actual = await waitForCi(
    'Own presence description matches the published value',
    () => _ownPresence(manager, userId),
    (presence) => presence.statusDescription == description,
    timeout: const Duration(seconds: 20),
  );
  expect(actual.statusDescription, description);
}

Future<void> _expectSubscription(
    ChatPresenceManager manager, String peerId, bool present) async {
  final actual = await waitForCi(
    'Presence subscription contains fresh peer = $present',
    () => _subscribedMembers(manager),
    (ids) => ids.contains(peerId) == present,
    timeout: const Duration(seconds: 20),
  );
  expect(actual.where((id) => id == peerId), hasLength(present ? 1 : 0));
}

Future<List<String>> _subscribedMembers(ChatPresenceManager manager) async {
  const pageSize = 100;
  final ids = <String>[];
  // Bound pagination even if a faulty implementation ignores pageNum.
  for (var pageNum = 1; pageNum <= 50; pageNum++) {
    final page = await manager
        .fetchSubscribedMembers(pageNum: pageNum, pageSize: pageSize)
        .timeout(const Duration(seconds: 10));
    expect(page.length, lessThanOrEqualTo(pageSize));
    ids.addAll(page);
    expect(ids.toSet().length, ids.length,
        reason: 'Presence subscription pages must not duplicate user IDs');
    if (page.length < pageSize) return ids;
  }
  throw StateError(
      'Presence subscription list exceeded the CI pagination bound');
}
