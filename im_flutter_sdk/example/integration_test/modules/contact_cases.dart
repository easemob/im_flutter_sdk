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

  Future<ContactRelationSnapshot> prepareRelation(String caseId) async {
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
      await reloadRelation(caseId, snapshot.userIds.contains(peerId),
          restoring: true);
      debugPrint('CI $caseId cleanup verified: friendship $userId / $peerId');
    });
    await rest.setBlocked(userId, peerId, false);
    await rest.setBlocked(peerId, userId, false);
    await client.contactManager.fetchBlockIds();
    return snapshot;
  }

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

  for (final keep in [true, false]) {
    final id = keep ? 'FL-CONTACT-002' : 'FL-CONTACT-003';
    ciTestWidgets('$id positive deletes friendship with keepConversation=$keep',
        (tester) async {
      final original = await prepareRelation(id);
      await rest.setContacts(userId, peerId, true);
      debugPrint(
          'CI $id prepare verified: bilateral friendship $userId / $peerId');
      await reloadRelation(id, true);
      final existing = await client.chatManager.getConversation(
        peerId,
        createIfNeed: false,
      );
      if (existing != null && await existing.messagesCount() != 0) {
        final messages = await existing.loadMessages(loadCount: 5);
        debugPrint('CI $id existing peer conversation: '
            'count=${await existing.messagesCount()} samples=${messages.map((message) => {
                  'id': message.msgId,
                  'direction': message.direction.name,
                  'serverTime': message.serverTime,
                  'ciCase': message.attributes?['ciCase'],
                }).toList()}');
        throw StateError('$id preparation: refusing to delete an existing '
            'nonempty conversation for $peerId');
      }
      final controlId =
          'ci_contact_control_${DateTime.now().microsecondsSinceEpoch}';
      for (final conversationId in [peerId, controlId]) {
        addTearDown(() async {
          await client.chatManager
              .deleteConversation(conversationId, deleteMessages: true);
          expect(
              await client.chatManager
                  .getConversation(conversationId, createIfNeed: false),
              isNull);
          debugPrint(
              'CI $id cleanup verified: local conversation $conversationId');
        });
      }
      final conversation = (await client.chatManager.getConversation(peerId))!;
      final control = (await client.chatManager.getConversation(controlId))!;
      final seed = _message(peerId, userId, '$id seed');
      final controlSeed = _message(controlId, userId, '$id untouched');
      await conversation.insertMessage(seed);
      await control.insertMessage(controlSeed);
      expect(await conversation.messagesCount(), 1);
      expect((await conversation.loadMessage(seed.msgId))?.msgId, seed.msgId);

      debugPrint('CI $id verify: deleteContact keepConversation=$keep');
      await client.contactManager.deleteContact(peerId, keepConversation: keep);
      await rest.verifyContacts(userId, peerId, false);
      expect(await rest.contactIds(userId),
          unorderedEquals(original.userIds.where((value) => value != peerId)));
      expect(await rest.contactIds(peerId),
          unorderedEquals(original.peerIds.where((value) => value != userId)));
      final observedConversation =
          await client.chatManager.getConversation(peerId, createIfNeed: false);
      debugPrint('CI $id after SDK delete: keepConversation=$keep '
          'conversationExists=${observedConversation != null} '
          'messageCount=${await observedConversation?.messagesCount()}');
      await observeContact(false);
      final after = await waitForCi(
        'conversation $peerId retained = $keep after deleteContact',
        () => client.chatManager.getConversation(peerId, createIfNeed: false),
        (value) => (value != null) == keep,
      );
      if (keep) {
        expect(await after!.messagesCount(), 1);
        expect((await after.loadMessage(seed.msgId))?.msgId, seed.msgId);
      } else {
        expect(after, isNull);
      }
      final untouched = await client.chatManager
          .getConversation(controlId, createIfNeed: false);
      expect(untouched, isNotNull);
      expect(await untouched!.messagesCount(), 1);
      expect((await untouched.loadMessage(controlSeed.msgId))?.msgId,
          controlSeed.msgId);
      debugPrint('CI $id verify passed');
    });
  }

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

ChatMessage _message(String from, String userId, String content) {
  final time = DateTime.now().millisecondsSinceEpoch;
  return ChatMessage.createReceiveMessage(
      body: ChatTextMessageBody(content: content))
    ..from = from
    ..to = userId
    ..conversationId = from
    ..localTime = time
    ..serverTime = time
    ..status = MessageStatus.SUCCESS;
}
