import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../support/ci_test.dart';
import '../support/login.dart';
import '../support/rest_fixture.dart';

void registerContactCases({
  required ChatClient client,
  required String userId,
  required String token,
  required String peerId,
  required CiRestFixture rest,
}) {
  Future<void> observeContact(bool present) async {
    String? previous;
    await waitForCi(
      'SDK contact lists contain $peerId = $present',
      () async {
        final ids = await client.contactManager.getAllContactIds();
        final records = await client.contactManager.getAllContacts();
        final observation =
            'ids=$ids records=${records.map((item) => item.userId).toList()}';
        if (observation != previous) {
          debugPrint('CI contacts observe: $observation');
          previous = observation;
        }
        return [
          ids.contains(peerId),
          records.any((item) => item.userId == peerId)
        ];
      },
      (values) => values.every((value) => value == present),
    );
  }

  Future<void> reloadRelation(String caseId, bool present,
      {bool restoring = false}) async {
    final phase = restoring ? 'cleanup' : 'prepare';
    debugPrint('CI $caseId $phase: login sync after REST relation change');
    await client.logout(false).timeout(const Duration(seconds: 30));
    await loginForCi(client, userId, token);
    debugPrint('CI $caseId ${restoring ? 'cleanup' : 'verify'}: '
        'local contacts after completed login sync, peerPresent=$present');
    await observeContact(present);
  }

  Future<void> prepareRelation(String caseId,
      {bool syncLocalOnRestore = true}) async {
    final snapshot = await rest.snapshotContacts(userId, peerId);
    final userBlocks = await rest.blockIds(userId);
    final peerBlocks = await rest.blockIds(peerId);
    // Register separate callbacks so one cleanup failure cannot prevent another.
    addTearDown(() async {
      await rest.setBlocked(userId, peerId, userBlocks.contains(peerId));
      expect(await rest.blockIds(userId), unorderedEquals(userBlocks));
      await client.contactManager.fetchBlockIds();
      debugPrint('CI $caseId cleanup verified: original blacklist for $userId');
    });
    addTearDown(() async {
      await rest.setBlocked(peerId, userId, peerBlocks.contains(userId));
      expect(await rest.blockIds(peerId), unorderedEquals(peerBlocks));
      debugPrint('CI $caseId cleanup verified: original blacklist for $peerId');
    });
    addTearDown(() async {
      await rest.restoreContacts(userId, peerId, snapshot);
      if (syncLocalOnRestore) {
        await reloadRelation(caseId, snapshot.userIds.contains(peerId),
            restoring: true);
      }
      debugPrint('CI $caseId cleanup verified: friendship $userId / $peerId');
    });
    await rest.setBlocked(userId, peerId, false);
    await rest.setBlocked(peerId, userId, false);
    await client.contactManager.fetchBlockIds();
  }

  // Test: Prepare nonfriend/friend states through REST and relogin to sync,
  // then query getAllContactIds, getAllContacts, and getContact.
  // Expected: Both lists exclude the nonfriend; after adding the friend, each
  // list contains the peer exactly once and the detail has the peer's user ID.
  // Cleanup restores the original friendship and both blacklists.
  ciTestWidgets(
      'FL-CONTACT-001 positive queries prepared contacts and excludes nonfriends',
      (tester) async {
    const id = 'FL-CONTACT-001';
    await prepareRelation(id);
    await rest.setContacts(userId, peerId, false);
    debugPrint('CI $id prepare verified: $peerId is not a friend');
    debugPrint('CI $id verify: nonfriend exclusion');
    await reloadRelation(id, false);

    await rest.setContacts(userId, peerId, true);
    debugPrint(
        'CI $id prepare verified: bilateral friendship $userId / $peerId');
    debugPrint('CI $id verify: contact IDs, records, and detail');
    await reloadRelation(id, true);
    final contact = await waitForCi(
      'SDK contact detail for $peerId',
      () => client.contactManager.getContact(userId: peerId),
      (value) => value?.userId == peerId,
    );
    expect(contact?.userId, peerId);
    expect(
        (await client.contactManager.getAllContactIds())
            .where((value) => value == peerId),
        hasLength(1));
    expect(
        (await client.contactManager.getAllContacts())
            .where((value) => value.userId == peerId),
        hasLength(1));
    debugPrint('CI $id verify passed');
  });

  // Test: Update a prepared contact's remark and verify the local detail and
  // list. Restore the old remark before restoring the original relationship.
  // Expected: getContact returns the peer with the new remark; getAllContacts
  // contains that peer exactly once with the same remark. Cleanup verifies the
  // restored remark before the relationship is restored.
  ciTestWidgets('FL-CONTACT-011 positive sets and reads a contact remark',
      (_) async {
    const id = 'FL-CONTACT-011';
    await prepareRelation(id);
    await rest.setContacts(userId, peerId, true);
    await reloadRelation(id, true);
    final original = await client.contactManager
        .getContact(userId: peerId)
        .timeout(const Duration(seconds: 20));
    expect(original?.userId, peerId);
    final originalRemark = original!.remark;

    Future<void> verifyRemark(String expected) async {
      final detail = await waitForCi(
        'Contact $peerId detail has the expected remark',
        () => client.contactManager.getContact(userId: peerId),
        (value) => value?.userId == peerId && value?.remark == expected,
      );
      expect(detail?.remark, expected);
      final records = await waitForCi(
        'Contact $peerId list has the expected remark',
        () => client.contactManager.getAllContacts(),
        (values) => values
            .any((value) => value.userId == peerId && value.remark == expected),
      );
      expect(records.where((value) => value.userId == peerId), hasLength(1));
      expect(records.singleWhere((value) => value.userId == peerId).remark,
          expected);
    }

    addTearDown(() async {
      await client.contactManager
          .setContactRemark(userId: peerId, remark: originalRemark)
          .timeout(const Duration(seconds: 20));
      await verifyRemark(originalRemark);
      debugPrint('CI $id cleanup verified: original contact remark');
    });
    final remark = 'ci_remark_${DateTime.now().microsecondsSinceEpoch}';
    await client.contactManager
        .setContactRemark(userId: peerId, remark: remark)
        .timeout(const Duration(seconds: 20));
    await verifyRemark(remark);
    debugPrint('CI $id verify passed');
  });

  for (final keep in [true, false]) {
    final id = keep ? 'FL-CONTACT-002' : 'FL-CONTACT-003';
    // Test: Delete a prepared friend with keepConversation=true (002) or
    // false (003), then restore the original friendship and blacklists.
    // Expected: deleteContact completes successfully within 30 seconds.
    // Local contact sync, notifications, and conversation state are not checked.
    ciTestWidgets(
        '$id positive deleteContact succeeds with keepConversation=$keep',
        (tester) async {
      await prepareRelation(id, syncLocalOnRestore: false);
      await rest.setContacts(userId, peerId, true);
      debugPrint(
          'CI $id prepare verified: bilateral friendship $userId / $peerId');

      debugPrint('CI $id verify: deleteContact keepConversation=$keep');
      await client.contactManager
          .deleteContact(peerId, keepConversation: keep)
          .timeout(const Duration(seconds: 30));
      debugPrint('CI $id verify passed');
    });
  }

  // Test: Start with the peer unblocked, add it to the blacklist, then remove it.
  // Expected: REST, fetchBlockIds, and getBlockIds match the exact member set
  // after each operation, preserving unrelated entries. Cleanup restores and
  // verifies the original blacklist.
  ciTestWidgets(
      'FL-CONTACT-004 positive adds, queries, and removes blacklist membership',
      (tester) async {
    const id = 'FL-CONTACT-004';
    final original = await rest.blockIds(userId);
    addTearDown(() async {
      await rest.setBlocked(userId, peerId, original.contains(peerId));
      expect(await rest.blockIds(userId), unorderedEquals(original));
      expect(await client.contactManager.fetchBlockIds(),
          unorderedEquals(original));
      await waitForCi(
          'restored local blacklist',
          () => client.contactManager.getBlockIds(),
          (values) => setEquals(values.toSet(), original.toSet()));
      debugPrint('CI $id cleanup verified: original blacklist for $userId');
    });

    await rest.setBlocked(userId, peerId, false);
    final withoutPeer = original.where((value) => value != peerId).toSet();
    expect(await client.contactManager.fetchBlockIds(),
        unorderedEquals(withoutPeer));
    debugPrint('CI $id prepare verified: target absent from blacklist');

    Future<void> verify(Set<String> expected) async {
      await waitForCi(
          'REST blacklist exact members',
          () => rest.blockIds(userId),
          (values) => setEquals(values.toSet(), expected));
      expect(await client.contactManager.fetchBlockIds(),
          unorderedEquals(expected));
      final local = await waitForCi(
          'SDK local blacklist exact members',
          () => client.contactManager.getBlockIds(),
          (values) => setEquals(values.toSet(), expected));
      expect(local, unorderedEquals(expected));
    }

    debugPrint('CI $id verify: add and query $peerId');
    await client.contactManager.addUserToBlockList(peerId);
    await verify({...withoutPeer, peerId});
    debugPrint('CI $id verify: remove and query $peerId');
    await client.contactManager.removeUserFromBlockList(peerId);
    await verify(withoutPeer);
    debugPrint('CI $id verify passed');
  });
}
