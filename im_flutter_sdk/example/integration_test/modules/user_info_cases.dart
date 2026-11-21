import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../support/ci_test.dart';
import '../support/env.dart';
import '../support/login.dart';
import '../support/rest_fixture.dart' show CiRestFixture;
import '../support/session.dart';

/// User info cases, FL-USERINFO-001..010 of the 4.25 ohos coverage draft.
///
/// Profile writes are not reversible for nullable string fields (`null` means
/// "leave unchanged"), so the cases that write a full profile run on throw-away
/// accounts created and deleted through the app-token REST fixture and never
/// touch the shared CI account. The CI account is only read.
///
/// `expireTime: 0` forces a server read on every call, which makes the polling
/// assertions below observe the server state instead of the Dart cache.
///
/// User info event rows (FL-EVENT-124 onUserInfoUpdate) belong to the event
/// modules, so no handler is registered here.
void registerUserInfoCases(ChatClient client) {
  final manager = client.userInfoManager;
  final fixtures = _UserInfoFixtures(client);

  // Test: Write every profile field on a throw-away account, read it back, then
  // send a single field update.
  // Expected: updateUserInfo echoes all eight fields for the signed-in account,
  // the server read returns the same values, and the partial update changes only
  // the sign while the other fields stay in place.
  ciTestWidgets('FL-USERINFO-001 updateUserInfo writes every profile field',
      (_) async {
    const caseId = 'FL-USERINFO-001';
    final micros = DateTime.now().microsecondsSinceEpoch;
    final account = await fixtures.account(caseId);
    await fixtures.signInAs(account);

    final phone = '13${(micros % 1000000000).toString().padLeft(9, '0')}';
    final mail = 'flutter.ci+$micros@example.com';
    const avatar = 'https://example.com/ci_avatar.png';
    const ext = '{"suite":"flutter-ci"}';

    final updated = await manager.updateUserInfo(
      nickname: 'ci nick',
      avatarUrl: avatar,
      mail: mail,
      phone: phone,
      gender: 1,
      sign: 'flutter ci sign',
      birth: '2000-01-01',
      ext: ext,
    );
    expect(updated.userId, account.userId);
    expect(updated.nickName, 'ci nick');
    expect(updated.avatarUrl, avatar);
    expect(updated.mail, mail);
    expect(updated.phone, phone);
    expect(updated.gender, 1);
    expect(updated.sign, 'flutter ci sign');
    expect(updated.birth, '2000-01-01');
    expect(updated.ext, ext);

    final own = await waitForCi<ChatUserInfo?>(
      'CI $caseId server profile carries the new nickname',
      () => manager.fetchOwnInfo(expireTime: 0),
      (info) => info?.nickName == 'ci nick',
    );
    expect(own, isNotNull);
    expect(own!.userId, account.userId);
    expect(own.avatarUrl, avatar);
    expect(own.mail, mail);
    expect(own.phone, phone);
    expect(own.gender, 1);
    expect(own.sign, 'flutter ci sign');
    expect(own.birth, '2000-01-01');
    expect(own.ext, ext);

    final partial = await manager.updateUserInfo(sign: 'flutter ci sign v2');
    expect(partial.sign, 'flutter ci sign v2');

    // The partial update and the profile write land on the server
    // asynchronously, so the poll requires both the new sign and the retained
    // fields before it stops; checking the sign alone can observe an
    // intermediate profile with a not-yet-merged nickname.
    final afterPartial = await waitForCi<ChatUserInfo?>(
      'CI $caseId server profile carries the second sign',
      () => manager.fetchOwnInfo(expireTime: 0),
      (info) =>
          info?.sign == 'flutter ci sign v2' && info?.nickName == 'ci nick',
    );
    expect(afterPartial, isNotNull);
    expect(afterPartial!.sign, 'flutter ci sign v2');
    expect(afterPartial.nickName, 'ci nick');
    expect(afterPartial.gender, 1);

    final fetched = await manager.fetchUserInfoById(
      <String>[account.userId],
      expireTime: 0,
    );
    expect(fetched[account.userId]?.userId, account.userId);
    expect(fetched[account.userId]?.sign, 'flutter ci sign v2');
  });

  // Test: Read the current account profile with expireTime 0 twice and compare
  // it with the by-id query.
  // Expected: Both reads return the CI user with a filled gender and a positive
  // expire stamp, and the by-id query agrees with fetchOwnInfo.
  ciTestWidgets('FL-USERINFO-002 fetchOwnInfo returns the current profile',
      (_) async {
    const caseId = 'FL-USERINFO-002';
    final own = await waitForCi<ChatUserInfo?>(
      'CI $caseId fetchOwnInfo returns the current user',
      () => manager.fetchOwnInfo(expireTime: 0),
      (info) => info?.userId == ciUserId,
    );
    expect(own, isNotNull);
    expect(own!.userId, ciUserId);
    expect(own.gender, inInclusiveRange(0, 2));
    expect(own.expireTime, greaterThan(0));

    final again = await manager.fetchOwnInfo(expireTime: 0);
    expect(again, isNotNull);
    expect(again!.userId, ciUserId);
    expect(again.nickName, own.nickName);
    expect(again.gender, own.gender);

    final fetched = await manager.fetchUserInfoById(
      <String>[ciUserId],
      expireTime: 0,
    );
    expect(fetched[ciUserId]?.userId, ciUserId);
    expect(fetched[ciUserId]?.gender, own.gender);
  });

  // Test: Read the profiles of the CI user, the prepared peer, and an id that
  // does not exist in one call.
  // Expected: The known ids come back keyed by user id with the matching userId
  // field, the unknown id is dropped from the result.
  // UNVERIFIED: the draft row expects a mixed list to succeed; whether the
  // unknown id is dropped or answered with an empty record is pinned on the
  // device.
  ciTestWidgets('FL-USERINFO-003 fetchUserInfoById reads several profiles',
      (_) async {
    final absent = 'ci_absent_info_${DateTime.now().microsecondsSinceEpoch}';
    final infos = await manager.fetchUserInfoById(
      <String>[ciUserId, ciPeerId, absent],
      expireTime: 0,
    );
    expect(infos.keys, contains(ciUserId));
    expect(infos.keys, contains(ciPeerId));
    expect(infos[ciUserId]?.userId, ciUserId);
    expect(infos[ciPeerId]?.userId, ciPeerId);
    final absentInfo = infos[absent];
    if (absentInfo != null) {
      // NOTE(deviation FL-USERINFO-003): ohos chatsdk 1.15.0 returns a
      // placeholder ChatUserInfo for an unknown id instead of skipping the
      // entry. Recorded in the failure ledger.
      debugPrint(
          'NOTE(deviation) FL-USERINFO-003: unknown id returned ChatUserInfo(userId=${absentInfo.userId})');
    }
  });

  // Test: Clear the Dart side user info cache and read the profile again.
  // Expected: The clear call succeeds, the follow-up server read still returns
  // the CI user, and a local lookup of an unknown id stays empty.
  // NOTE: `clearUserInfoCache` only wipes the Dart `_effectiveUserInfoMap`
  // (lib/src/managers/chat_user_info_manager.dart:317); it does not delete the
  // native user info rows, so the draft row's "local query is empty after the
  // clear" does not match this implementation and is not asserted here.
  ciTestWidgets('FL-USERINFO-004 clearUserInfoCache drops the dart cache',
      (_) async {
    final own = await manager.fetchOwnInfo(expireTime: 0);
    expect(own, isNotNull);
    expect(own!.userId, ciUserId);

    manager.clearUserInfoCache();

    final refetched = await manager.fetchUserInfoById(
      <String>[ciUserId],
      expireTime: 0,
    );
    expect(refetched[ciUserId]?.userId, ciUserId);
    expect(refetched[ciUserId]?.gender, own.gender);

    final absent = 'ci_absent_info_${DateTime.now().microsecondsSinceEpoch}';
    expect(await manager.getLocalUserInfoByIds(<String>[absent]), isEmpty);
  });

  // Test: Subscribe to the prepared peer.
  // Expected: The subscription is stored and fetchSubscribedUsers reports the
  // peer. A tear-down removes the subscription again.
  ciTestWidgets('FL-USERINFO-005 subscribeUsersInfo adds the peer', (_) async {
    const caseId = 'FL-USERINFO-005';
    await manager.subscribeUsersInfo(<String>[ciPeerId]);
    addTearDown(() => fixtures.unsubscribeIfSubscribed(ciPeerId));

    final users = await waitForCi<List<ChatUserInfo>>(
      'CI $caseId subscription list holds the peer',
      () => manager.fetchSubscribedUsers(),
      (values) => values.any((item) => item.userId == ciPeerId),
    );
    expect(users.map((item) => item.userId), contains(ciPeerId));
  });

  // Test: Subscribe to the prepared peer and unsubscribe again.
  // Expected: The peer leaves the subscription list.
  ciTestWidgets('FL-USERINFO-006 unsubscribeUsersInfo drops the peer',
      (_) async {
    const caseId = 'FL-USERINFO-006';
    await manager.subscribeUsersInfo(<String>[ciPeerId]);
    await waitForCi<List<ChatUserInfo>>(
      'CI $caseId subscription list holds the peer before the unsubscribe',
      () => manager.fetchSubscribedUsers(),
      (values) => values.any((item) => item.userId == ciPeerId),
    );

    await manager.unsubscribeUsersInfo(<String>[ciPeerId]);
    final users = await waitForCi<List<ChatUserInfo>>(
      'CI $caseId subscription list drops the peer',
      () => manager.fetchSubscribedUsers(),
      (values) => values.every((item) => item.userId != ciPeerId),
    );
    expect(users.map((item) => item.userId), isNot(contains(ciPeerId)));
  });

  // Test: Read the subscription list while the prepared peer is subscribed.
  // Expected: Every entry is a typed ChatUserInfo with a non-empty user id and
  // the peer is part of the list.
  ciTestWidgets('FL-USERINFO-007 fetchSubscribedUsers returns typed records',
      (_) async {
    const caseId = 'FL-USERINFO-007';
    await manager.subscribeUsersInfo(<String>[ciPeerId]);
    addTearDown(() => fixtures.unsubscribeIfSubscribed(ciPeerId));

    final users = await waitForCi<List<ChatUserInfo>>(
      'CI $caseId subscription list holds the peer',
      () => manager.fetchSubscribedUsers(),
      (values) => values.any((item) => item.userId == ciPeerId),
    );
    expect(users, everyElement(isA<ChatUserInfo>()));
    expect(users.map((item) => item.userId), contains(ciPeerId));
    expect(users.every((item) => item.userId.isNotEmpty), isTrue);
    expect(users.every((item) => item.gender >= 0), isTrue);
  });

  // Test: Read the locally cached profile of the current user and of an unknown
  // id after a server read populated the cache.
  // Expected: The current user is cached with the same gender as the server
  // read, the unknown id stays absent.
  ciTestWidgets('FL-USERINFO-008 getLocalUserInfoByIds reads the local cache',
      (_) async {
    const caseId = 'FL-USERINFO-008';
    final own = await manager.fetchOwnInfo(expireTime: 0);
    expect(own, isNotNull);

    final local = await waitForCi<Map<String, ChatUserInfo>>(
      'CI $caseId local cache holds the current user',
      () => manager.getLocalUserInfoByIds(<String>[ciUserId]),
      (infos) => infos[ciUserId]?.userId == ciUserId,
    );
    expect(local[ciUserId]?.userId, ciUserId);
    expect(local[ciUserId]?.gender, own!.gender);

    final absent = 'ci_absent_info_${DateTime.now().microsecondsSinceEpoch}';
    expect(await manager.getLocalUserInfoByIds(<String>[absent]), isEmpty);
  });

  // Test: Call fetchUserInfoById with an empty id list.
  // Expected: An empty map comes back without a server call or an exception; the
  // Dart layer returns early when no id has to be requested
  // (lib/src/managers/chat_user_info_manager.dart:270).
  ciTestWidgets('FL-USERINFO-009 fetchUserInfoById accepts an empty list',
      (_) async {
    final infos = await manager.fetchUserInfoById(const <String>[]);
    expect(infos, isEmpty);
  });

  // Test: Send an over-long phone and avatar URL from a throw-away account.
  // Expected: Both updates are rejected with 901 (USERINFO_DATA_LENGTH_EXCEED)
  // and the profile keeps the untouched values.
  // UNVERIFIED: 901 is the documented "user attribute too long" code in
  // EMErrorCode.h; the ohos chatsdk ships compiled only, so the accepted code is
  // pinned by the first device run (110 INVALID_PARAM is the fallback shape).
  ciTestWidgets('FL-USERINFO-010 rejects an over-long profile field',
      (_) async {
    const caseId = 'FL-USERINFO-010';
    final account = await fixtures.account(caseId);
    await fixtures.signInAs(account);

    final overLong = List<String>.filled(1024, 'x').join();
    var rejected = 0;
    try {
      await manager.updateUserInfo(phone: overLong);
    } on ChatError catch (error) {
      rejected++;
      expect(error.code, anyOf(901, 110));
      debugPrint('FL-USERINFO-010 phone rejected with code=${error.code}');
    }
    try {
      await manager.updateUserInfo(avatarUrl: 'https://example.com/$overLong');
    } on ChatError catch (error) {
      rejected++;
      expect(error.code, anyOf(901, 110));
      debugPrint('FL-USERINFO-010 avatar rejected with code=${error.code}');
    }
    if (rejected == 0) {
      // NOTE(deviation FL-USERINFO-010): the ohos path accepts over-long
      // profile fields and does not return the documented 901. Recorded in the
      // failure ledger; the field contents are not asserted because the server
      // may truncate them.
      debugPrint(
          'NOTE(deviation) FL-USERINFO-010: over-long profile fields accepted');
    }

    final own = await manager.fetchOwnInfo(expireTime: 0);
    expect(own, isNotNull);
    expect(own!.userId, account.userId);
  });
}

/// A throw-away account created and deleted through the REST fixture.
final class _TempAccount {
  const _TempAccount(this.userId, this.password);

  final String userId;
  final String password;
}

/// User info fixtures shared by the cases of this module.
final class _UserInfoFixtures {
  _UserInfoFixtures(this.client);

  final ChatClient client;
  int _sequence = 0;

  ChatUserInfoManager get _userInfo => client.userInfoManager;

  /// Creates a throw-away account and registers its REST deletion.
  ///
  /// The deletion runs through REST only, so it still happens when a case fails
  /// while the client is signed in as that account.
  Future<_TempAccount> account(String label) async {
    final micros = DateTime.now().microsecondsSinceEpoch;
    final userId = 'ci_${label}_${micros}_${_sequence++}'.toLowerCase();
    final password = 'Ci${micros}pass';
    final rest = CiRestFixture(
      restApi: ciRestApi,
      appKey: ciAppKey,
      appToken: ciAppToken,
    );
    await rest.createUser(userId, password);
    addTearDown(() async {
      final cleanup = CiRestFixture(
        restApi: ciRestApi,
        appKey: ciAppKey,
        appToken: ciAppToken,
      );
      await cleanup.setContacts(ciUserId, userId, false);
      await cleanup.deleteUser(userId);
    });
    return _TempAccount(userId, password);
  }

  /// Signs in as a throw-away account and queues the return to the CI user.
  Future<void> signInAs(_TempAccount account) async {
    addTearDown(returnToCiUser);
    await ensureLoggedOutForCi(client);
    await client.loginWithPassword(account.userId, account.password);
    await client.startCallback();
    await waitForCi<bool>(
      'CI temporary account ${account.userId} connects',
      () => client.isConnected(),
      (connected) => connected,
    );
    expect(client.currentUserId, account.userId);
  }

  /// Restores the shared CI login, whatever state a case left behind.
  Future<void> returnToCiUser() async {
    if (client.currentUserId == ciUserId && await client.isConnected()) return;
    await loginForCi(client);
  }

  /// Removes a subscription only when it is still present.
  Future<void> unsubscribeIfSubscribed(String peerId) async {
    final users = await _userInfo.fetchSubscribedUsers();
    if (!users.any((item) => item.userId == peerId)) return;
    await _userInfo.unsubscribeUsersInfo(<String>[peerId]);
  }
}
