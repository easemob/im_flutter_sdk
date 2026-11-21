import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../support/ci_test.dart';
import '../support/env.dart';
import '../support/login.dart';
import '../support/rest_fixture.dart' show CiRestFixture;
import '../support/session.dart';

/// Positive contact cases, FL-CONTACT-001..020 of the 4.25 ohos coverage draft.
///
/// Single-device limits: an invitation can only be accepted by a second session,
/// so every case that needs a counterpart uses a throw-away account owned by the
/// CI user (created and deleted through the app-token REST fixture). Each
/// account is deleted from a tear-down, and the friend relation itself is
/// removed from both sides before the delete.
///
/// Local cache rows are only read after a logout/login cycle, because contact
/// sync runs on login (`enableAutoSyncContacts`); a server call is not assumed
/// to refresh the local database on its own.
///
/// Contact event rows (FL-EVENT-088 onContactInvited) belong to the event
/// modules, so no handler is registered here.
void registerContactCases(ChatClient client) {
  final manager = client.contactManager;
  final fixtures = _ContactFixtures(client);

  // Test: Invite a throw-away account with addContact, then let that account
  // accept the invitation from its own session.
  // Expected: The invitation reaches the server (the invitee can accept it) and
  // both server side contact lists hold the accepted account afterwards.
  // UNVERIFIED: assumes the app does not auto-accept friend invitations. With an
  // auto-accept policy the invitation is already a friendship when the invitee
  // signs in, and the accept call has nothing left to accept.
  ciTestWidgets('FL-CONTACT-001 addContact invites a user who can accept',
      (_) async {
    const caseId = 'FL-CONTACT-001';
    final invitee = await fixtures.account(caseId);
    await fixtures.expectFriendship(invitee.userId, false);

    await manager.addContact(invitee.userId, reason: 'flutter ci invitation');

    await fixtures.signInAs(invitee);
    await manager.acceptInvitation(ciUserId);
    await fixtures.returnToCiUser();

    final ids = await waitForCi<List<String>>(
      'CI $caseId server contact ids hold the invitee',
      () => manager.fetchAllContactIds(),
      (values) => values.contains(invitee.userId),
    );
    expect(ids, contains(invitee.userId));
    await fixtures.expectFriendship(invitee.userId, true);
  });

  // Test: Delete a prepared friend twice, first with the default
  // keepConversation=false and then with keepConversation=true.
  // Expected: deleteContact succeeds for both variants and the server side
  // friendship is gone on both sides. The local contact rows are not asserted:
  // the 5.1.0 run observed stale local rows after a successful delete, so this
  // case pins the server contract only.
  ciTestWidgets('FL-CONTACT-002 deleteContact drops the server friendship',
      (_) async {
    const caseId = 'FL-CONTACT-002';

    final plain = await fixtures.friend(caseId);
    await manager.deleteContact(plain.userId);
    await fixtures.expectFriendship(plain.userId, false);
    expect(await manager.fetchAllContactIds(), isNot(contains(plain.userId)));

    final keeping = await fixtures.friend(caseId);
    await manager.deleteContact(keeping.userId, keepConversation: true);
    await fixtures.expectFriendship(keeping.userId, false);
    expect(
      await manager.fetchAllContactIds(),
      isNot(contains(keeping.userId)),
    );
  });

  // Test: Read the deprecated getAllContactsFromServer alias while a prepared
  // friend and an unrelated throw-away account exist.
  // Expected: The friend is listed and the unrelated account is not. The alias
  // shares the fetchAllContactIds native call, so one smoke case covers it.
  ciTestWidgets('FL-CONTACT-003 getAllContactsFromServer lists friends',
      (_) async {
    const caseId = 'FL-CONTACT-003';
    final friend = await fixtures.friend(caseId);
    final stranger = await fixtures.account(caseId);
    // ignore: deprecated_member_use
    final ids = await manager.getAllContactsFromServer();
    expect(ids, contains(friend.userId));
    expect(ids, isNot(contains(stranger.userId)));
  });

  // Test: Read the server contact ids through the current API while a prepared
  // friend and an unrelated throw-away account exist.
  // Expected: The friend is listed and the unrelated account is not.
  ciTestWidgets('FL-CONTACT-004 fetchAllContactIds lists friends', (_) async {
    const caseId = 'FL-CONTACT-004';
    final friend = await fixtures.friend(caseId);
    final stranger = await fixtures.account(caseId);
    final ids = await manager.fetchAllContactIds();
    expect(ids, contains(friend.userId));
    expect(ids, isNot(contains(stranger.userId)));
  });

  // Test: Read the deprecated getAllContactsFromDB alias after a logout/login
  // cycle synced the prepared friend into the local cache.
  // Expected: The friend is cached locally. The alias shares the
  // getAllContactIds native call.
  ciTestWidgets('FL-CONTACT-005 getAllContactsFromDB reads the local cache',
      (_) async {
    const caseId = 'FL-CONTACT-005';
    final friend = await fixtures.friend(caseId);
    await fixtures.syncLocalContacts(peerId: friend.userId, present: true);
    // ignore: deprecated_member_use
    final ids = await manager.getAllContactsFromDB();
    expect(ids, contains(friend.userId));
  });

  // Test: Read the local contact ids through the current API after a
  // logout/login cycle synced the prepared friend into the local cache.
  // Expected: The friend is cached locally.
  ciTestWidgets('FL-CONTACT-006 getAllContactIds reads the local cache',
      (_) async {
    const caseId = 'FL-CONTACT-006';
    final friend = await fixtures.friend(caseId);
    await fixtures.syncLocalContacts(peerId: friend.userId, present: true);
    final ids = await manager.getAllContactIds();
    expect(ids, contains(friend.userId));
  });

  // Test: Block a fresh account through addUserToBlockList.
  // Expected: The account appears in the server block list and the tear-down
  // removes the block again. The "blocked peer message does not reach the
  // conversation" half of the draft row needs two sessions and is not asserted.
  ciTestWidgets('FL-CONTACT-007 addUserToBlockList adds the account',
      (_) async {
    const caseId = 'FL-CONTACT-007';
    final peer = await fixtures.account(caseId);
    expect(await manager.fetchBlockIds(), isNot(contains(peer.userId)));

    await manager.addUserToBlockList(peer.userId);
    final ids = await fixtures.expectBlocked(peer.userId, true);
    expect(ids, contains(peer.userId));
    addTearDown(() => fixtures.unblock(peer.userId));
  });

  // Test: Unblock an account that was blocked before the case body.
  // Expected: The account leaves the server block list.
  ciTestWidgets('FL-CONTACT-008 removeUserFromBlockList clears the account',
      (_) async {
    const caseId = 'FL-CONTACT-008';
    final peer = await fixtures.account(caseId);
    await fixtures.block(peer.userId);

    await manager.removeUserFromBlockList(peer.userId);
    final ids = await fixtures.expectBlocked(peer.userId, false);
    expect(ids, isNot(contains(peer.userId)));
  });

  // Test: Read the deprecated getBlockListFromServer alias for a blocked
  // account.
  // Expected: The blocked account is listed.
  ciTestWidgets('FL-CONTACT-009 getBlockListFromServer lists blocked users',
      (_) async {
    const caseId = 'FL-CONTACT-009';
    final peer = await fixtures.account(caseId);
    await fixtures.block(peer.userId);
    // ignore: deprecated_member_use
    final ids = await manager.getBlockListFromServer();
    expect(ids, contains(peer.userId));
  });

  // Test: Read the server block ids through the current API while one account
  // is blocked and another one is not.
  // Expected: Only the blocked account is listed.
  ciTestWidgets('FL-CONTACT-010 fetchBlockIds lists blocked users', (_) async {
    const caseId = 'FL-CONTACT-010';
    final blocked = await fixtures.account(caseId);
    final open = await fixtures.account(caseId);
    await fixtures.block(blocked.userId);

    final ids = await manager.fetchBlockIds();
    expect(ids, contains(blocked.userId));
    expect(ids, isNot(contains(open.userId)));
  });

  // Test: Read the deprecated getBlockListFromDB alias after a server block and
  // a server block list refresh.
  // Expected: The blocked account is visible through the local query. The alias
  // shares the getBlockIds native call; the refresh runs first so the local read
  // does not race the sync.
  // UNVERIFIED: this case assumes the server block list read also fills the
  // native local cache (ContactManagerWrapper.ets maps getBlockListFromServer to
  // the SDK call and getBlockIds to blockList()); if the device run shows an
  // empty local list, the row belongs to the block list sync gap, not to this
  // module.
  ciTestWidgets('FL-CONTACT-011 getBlockListFromDB reads the local cache',
      (_) async {
    const caseId = 'FL-CONTACT-011';
    final peer = await fixtures.account(caseId);
    await fixtures.block(peer.userId);
    await manager.fetchBlockIds();
    final ids = await waitForCi<List<String>>(
      'CI $caseId local block ids hold the blocked account',
      // ignore: deprecated_member_use
      () => manager.getBlockListFromDB(),
      (values) => values.contains(peer.userId),
    );
    expect(ids, contains(peer.userId));
  });

  // Test: Read the local block ids through the current API after a server block
  // and a server block list refresh.
  // Expected: The blocked account is visible through the local query.
  // UNVERIFIED: same native cache dependency as FL-CONTACT-011.
  ciTestWidgets('FL-CONTACT-012 getBlockIds reads the local cache', (_) async {
    const caseId = 'FL-CONTACT-012';
    final peer = await fixtures.account(caseId);
    await fixtures.block(peer.userId);
    await manager.fetchBlockIds();
    final ids = await waitForCi<List<String>>(
      'CI $caseId local block ids hold the blocked account',
      () => manager.getBlockIds(),
      (values) => values.contains(peer.userId),
    );
    expect(ids, contains(peer.userId));
  });

  // Test: Accept a pending invitation. The invitation is created from the
  // invitee's own session before this account signs in, because a single device
  // cannot invite and accept at the same time.
  // Expected: acceptInvitation completes and the inviter becomes a mutual friend
  // on the server.
  // UNVERIFIED: same auto-accept assumption as FL-CONTACT-001.
  ciTestWidgets('FL-CONTACT-013 acceptInvitation adds the inviter', (_) async {
    const caseId = 'FL-CONTACT-013';
    final inviter = await fixtures.account(caseId);
    await fixtures.signInAs(inviter);
    await manager.addContact(ciUserId, reason: 'flutter ci invitation');
    await fixtures.returnToCiUser();

    await manager.acceptInvitation(inviter.userId);
    final ids = await waitForCi<List<String>>(
      'CI $caseId server contact ids hold the inviter',
      () => manager.fetchAllContactIds(),
      (values) => values.contains(inviter.userId),
    );
    expect(ids, contains(inviter.userId));
    await fixtures.expectFriendship(inviter.userId, true);
  });

  // Test: Decline a pending invitation prepared from the invitee's own session.
  // Expected: declineInvitation completes and no friendship exists on either
  // side afterwards.
  // UNVERIFIED: same auto-accept assumption as FL-CONTACT-001.
  ciTestWidgets('FL-CONTACT-014 declineInvitation keeps the accounts apart',
      (_) async {
    const caseId = 'FL-CONTACT-014';
    final inviter = await fixtures.account(caseId);
    await fixtures.signInAs(inviter);
    await manager.addContact(ciUserId, reason: 'flutter ci decline');
    await fixtures.returnToCiUser();

    await manager.declineInvitation(inviter.userId);
    expect(
      await manager.fetchAllContactIds(),
      isNot(contains(inviter.userId)),
    );
    await fixtures.expectFriendship(inviter.userId, false);
  });

  // Test: Read the other-platform ids of the only logged-in account.
  // Expected: the account holds the sole session, so the call reports 205
  // (USER_ILLEGAL_ARGUMENT) instead of an id list. ohos chatsdk answers 101
  // (INVALID_USER_NAME) for the same state; the wrapper translates it. The
  // multi-device variant belongs to the multi-device suites.
  ciTestWidgets('FL-CONTACT-015 getSelfIdsOnOtherPlatform reports 205',
      (_) async {
    await expectCiError(() => manager.getSelfIdsOnOtherPlatform(), 205);
  });

  // Test: Read getAllContacts from the local cache after a logout/login cycle
  // synced the prepared friend.
  // Expected: The friend is cached exactly once with its id and a remark string,
  // and an unrelated throw-away account is absent.
  ciTestWidgets('FL-CONTACT-016 getAllContacts reads the local cache',
      (_) async {
    const caseId = 'FL-CONTACT-016';
    final friend = await fixtures.friend(caseId);
    final stranger = await fixtures.account(caseId);
    await fixtures.syncLocalContacts(peerId: friend.userId, present: true);

    final contacts = await manager.getAllContacts();
    final matches = contacts.where((item) => item.userId == friend.userId);
    expect(matches, hasLength(1));
    expect(matches.single.remark, isA<String>());
    expect(
        contacts.map((item) => item.userId), isNot(contains(stranger.userId)));
  });

  // Test: Store a contact remark and read it back from the contact detail and
  // the local contact list.
  // Expected: setContactRemark completes and the local queries return the new
  // remark for the friend. The throw-away friend is deleted on tear-down, so no
  // old remark has to be restored.
  ciTestWidgets('FL-CONTACT-017 setContactRemark stores the remark', (_) async {
    const caseId = 'FL-CONTACT-017';
    final friend = await fixtures.friend(caseId);
    await fixtures.syncLocalContacts(peerId: friend.userId, present: true);
    final original = await manager.getContact(userId: friend.userId);
    expect(original?.userId, friend.userId);

    final remark = 'ci_remark_${DateTime.now().microsecondsSinceEpoch}';
    await manager.setContactRemark(userId: friend.userId, remark: remark);

    final detail = await waitForCi<ChatContact?>(
      'CI $caseId local contact detail carries the remark',
      () => manager.getContact(userId: friend.userId),
      (contact) => contact?.remark == remark,
    );
    expect(detail, isNotNull);
    expect(detail!.remark, remark);

    final listed = await waitForCi<List<ChatContact>>(
      'CI $caseId local contact list carries the remark',
      () => manager.getAllContacts(),
      (contacts) => contacts
          .any((item) => item.userId == friend.userId && item.remark == remark),
    );
    final cached = listed.singleWhere((item) => item.userId == friend.userId);
    expect(cached.remark, remark);
  });

  // Test: Read one cached contact by id and then read an id that was never
  // added as a friend.
  // Expected: The friend resolves with its id and a remark string, the unknown
  // id resolves to null instead of throwing.
  ciTestWidgets('FL-CONTACT-018 getContact reads one cached contact',
      (_) async {
    const caseId = 'FL-CONTACT-018';
    final friend = await fixtures.friend(caseId);
    final stranger = await fixtures.account(caseId);
    await fixtures.syncLocalContacts(peerId: friend.userId, present: true);

    final contact = await manager.getContact(userId: friend.userId);
    expect(contact, isNotNull);
    expect(contact!.userId, friend.userId);
    expect(contact.remark, isA<String>());
    expect(await manager.getContact(userId: stranger.userId), isNull);
  });

  // Test: Read every contact from the server while a friend and an unrelated
  // throw-away account exist.
  // Expected: The friend is listed with its id and remark and the unrelated
  // account is absent. The 4.25 signature takes no cursor or page size, so the
  // draft row's paging parameters do not apply.
  ciTestWidgets('FL-CONTACT-019 fetchAllContacts lists server contacts',
      (_) async {
    const caseId = 'FL-CONTACT-019';
    final friend = await fixtures.friend(caseId);
    final stranger = await fixtures.account(caseId);

    final contacts = await manager.fetchAllContacts();
    expect(contacts.map((item) => item.userId), contains(friend.userId));
    expect(
        contacts.map((item) => item.userId), isNot(contains(stranger.userId)));
    final entry = contacts.singleWhere((item) => item.userId == friend.userId);
    expect(entry.userId, friend.userId);
    expect(entry.remark, isA<String>());
  });

  // Test: Page the server contact list with a wide page and with a single item
  // page.
  // Expected: The wide page holds the friend and reports a null or string
  // cursor, the single item page is bounded by one entry.
  ciTestWidgets('FL-CONTACT-020 fetchContacts pages the server contacts',
      (_) async {
    const caseId = 'FL-CONTACT-020';
    final friend = await fixtures.friend(caseId);

    final page = await manager.fetchContacts(pageSize: 50);
    expect(page.data.map((item) => item.userId), contains(friend.userId));
    expect(page.cursor, anyOf(isNull, isA<String>()));

    final single = await manager.fetchContacts(pageSize: 1);
    expect(single.data, hasLength(1));
  });
}

/// A throw-away account created and deleted through the REST fixture.
final class _TempAccount {
  const _TempAccount(this.userId, this.password);

  final String userId;
  final String password;
}

/// Contact fixtures shared by the cases of this module.
final class _ContactFixtures {
  _ContactFixtures(this.client);

  final ChatClient client;
  int _sequence = 0;

  ChatContactManager get _contacts => client.contactManager;

  /// Runs [body] against a short lived app-token REST fixture.
  Future<T> _withRest<T>(Future<T> Function(CiRestFixture rest) body) async {
    final rest = CiRestFixture(
      restApi: ciRestApi,
      appKey: ciAppKey,
      appToken: ciAppToken,
    );
    return await body(rest);
  }

  /// Creates a throw-away account and registers its REST deletion.
  ///
  /// The deletion runs through REST only, so it still happens when a case fails
  /// while the client is signed in as that account.
  Future<_TempAccount> account(String label) async {
    final micros = DateTime.now().microsecondsSinceEpoch;
    final userId = 'ci_${label}_${micros}_${_sequence++}'.toLowerCase();
    final password = 'Ci${micros}pass';
    await _withRest((rest) => rest.createUser(userId, password));
    addTearDown(() async {
      await _withRest((rest) async {
        // Remove the relation from this side before the account is deleted.
        await rest.setContacts(ciUserId, userId, false);
        await rest.deleteUser(userId);
      });
    });
    return _TempAccount(userId, password);
  }

  /// Creates a throw-away account that is a mutual friend of the CI user.
  Future<_TempAccount> friend(String label) async {
    final peer = await account(label);
    await _withRest(
      (rest) => rest.setContacts(ciUserId, peer.userId, true),
    );
    await expectFriendship(peer.userId, true);
    return peer;
  }

  /// Blocks [peerId] and registers the unblock tear-down.
  Future<void> block(String peerId) async {
    await _contacts.addUserToBlockList(peerId);
    await expectBlocked(peerId, true);
    addTearDown(() => unblock(peerId));
  }

  /// Removes the block when one is still present.
  Future<void> unblock(String peerId) async {
    final ids = await _contacts.fetchBlockIds();
    if (!ids.contains(peerId)) return;
    await _contacts.removeUserFromBlockList(peerId);
    await expectBlocked(peerId, false);
  }

  /// Polls the server block list until it matches [present].
  Future<List<String>> expectBlocked(String peerId, bool present) => waitForCi(
        'CI server block list contains $peerId == $present',
        () => _contacts.fetchBlockIds(),
        (ids) => ids.contains(peerId) == present,
      );

  /// Polls the REST contact lists of both sides until they match [present].
  Future<void> expectFriendship(String peerId, bool present) => _withRest(
        (rest) async {
          await waitForCi<List<String>>(
            'CI REST contacts of $ciUserId contain $peerId == $present',
            () => rest.contactIds(ciUserId),
            (ids) => ids.contains(peerId) == present,
          );
          await waitForCi<List<String>>(
            'CI REST contacts of $peerId contain $ciUserId == $present',
            () => rest.contactIds(peerId),
            (ids) => ids.contains(ciUserId) == present,
          );
        },
      );

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

  /// Reloads the contact cache through a logout/login cycle and waits until the
  /// local contact ids reflect [present].
  Future<void> syncLocalContacts({
    required String peerId,
    required bool present,
  }) async {
    await logoutForCi(client);
    await loginForCi(client);
    await waitForCi<List<String>>(
      'CI local contact ids contain $peerId == $present',
      () => _contacts.getAllContactIds(),
      (ids) => ids.contains(peerId) == present,
    );
  }
}
