import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../support/ci_test.dart';
import '../support/rest_fixture.dart';

void registerConversationCases({
  required ChatClient client,
  required String userId,
  required String peerId,
  required CiRestFixture rest,
}) {
  Future<_ConversationFixture> prepare() =>
      _prepareConversation(client, userId);

  group('positive conversation cases', () {
    // Test: Create a local conversation with a seed message, replace its ext
    // twice, then delete it with deleteMessages=true and recreate it.
    // Expected: Rereads preserve ID/type and exactly the latest ext; the list
    // includes the conversation before deletion and excludes it afterward;
    // deletion returns true and recreating the conversation returns no messages.
    ciTestWidgets(
      'FL-CONV-001 positive conversation lifecycle and persisted extensions',
      (tester) async {
        final fixture = await prepare();
        final conversation = fixture.conversation;
        final seed =
            fixture.text('conversation lifecycle seed', timestamp: 1000);
        await conversation.insertMessage(seed);

        for (final extension in <Map<String, String>>[
          {'owner': 'flutter-ci', 'run': conversation.id},
          {'replacement': 'second value'},
        ]) {
          await conversation.setExt(extension);
          final reloaded = await client.chatManager.getConversation(
            conversation.id,
            createIfNeed: false,
          );
          expect(reloaded, isNotNull);
          expect(reloaded!.id, conversation.id);
          expect(reloaded.type, ChatConversationType.Chat);
          expect(reloaded.ext, extension);
        }

        expect(
          (await client.chatManager.loadAllConversations())
              .map((item) => item.id),
          contains(conversation.id),
        );
        expect(
          await client.chatManager.deleteConversation(
            conversation.id,
            deleteMessages: true,
          ),
          isTrue,
        );
        expect(
          await client.chatManager.getConversation(
            conversation.id,
            createIfNeed: false,
          ),
          isNull,
        );
        expect(
          (await client.chatManager.loadAllConversations())
              .map((item) => item.id),
          isNot(contains(conversation.id)),
        );
        final recreated = await client.chatManager.getConversation(
          conversation.id,
          createIfNeed: true,
        );
        await _expectMessages(recreated!, const []);
      },
    );

    // Test: Insert two received messages and a newer sent message, query latest,
    // last received, and by ID, then clear the unread count twice.
    // Expected: Reads match the seeded messages, latest is the sent message,
    // last received is the second received message. The 4.25.0 native counts
    // locally inserted received messages as unread (unlike 5.x, where local
    // insertion leaves the count untouched), so the count starts at 2 and
    // markAllMessagesAsRead brings it to zero idempotently.
    ciTestWidgets(
      'FL-CONV-002 positive latest and received messages with zero unread state',
      (tester) async {
        final fixture = await prepare();
        final conversation = fixture.conversation;
        final first = fixture.text('first received', timestamp: 1000);
        final received = fixture.text('last received', timestamp: 2000);
        final sent =
            fixture.text('latest sent', timestamp: 3000, outgoing: true);
        for (final message in [first, received, sent]) {
          await conversation.insertMessage(message);
        }

        await _expectMessages(conversation, [first, received, sent]);
        _expectStoredMessage(await conversation.latestMessage(), sent);
        _expectStoredMessage(
            await conversation.lastReceivedMessage(), received);
        _expectStoredMessage(
            await conversation.loadMessage(first.msgId), first);

        // 4.25.0 native semantics: locally inserted received messages are
        // unread until read. These assertions also cover nonzero clearing
        // and its idempotence through markAllMessagesAsRead.
        expect(await conversation.unreadCount(), 2);
        for (var attempt = 0; attempt < 2; attempt++) {
          await conversation.markAllMessagesAsRead();
          expect(await conversation.unreadCount(), 0);
        }
      },
    );

    // Test: Append two local messages, update one message's body/attributes,
    // reread it, and delete it by ID.
    // Expected: The update keeps the ID and persists the new fields; deletion
    // leaves exactly the untouched control message with its original content.
    ciTestWidgets(
      'FL-CONV-003 positive append update and selective message deletion',
      (tester) async {
        final fixture = await prepare();
        final conversation = fixture.conversation;
        final message = fixture.text('before update', timestamp: 1000);
        final control = fixture.text('keep this message', timestamp: 2000);
        await conversation.appendMessage(message);
        await conversation.appendMessage(control);
        _expectStoredMessage(
            await conversation.loadMessage(message.msgId), message);
        final originalId = message.msgId;

        message
          ..body = ChatTextMessageBody(content: 'after update')
          // Submit the complete map; deletion by omission has no public contract.
          ..attributes = <String, dynamic>{
            ...?message.attributes,
            'timestamp': 1001,
            'updated': true,
            'version': 2,
          };
        await conversation.updateMessage(message);
        final updated = await conversation.loadMessage(originalId);
        _expectStoredMessage(updated, message);
        expect(updated!.msgId, originalId);
        expect((updated.body as ChatTextMessageBody).content, 'after update');
        expect(updated.attributes, message.attributes);

        await conversation.deleteMessage(originalId);
        await _expectMessages(conversation, [control]);
        _expectStoredMessage(
            await conversation.loadMessage(control.msgId), control);
      },
    );

    // Test: Page through five local messages with known timestamps in Up and
    // Down directions, including queries beyond the first/last message.
    // Expected: Up pages contain messages {4,5}, {2,3}, {1}; Down pages contain
    // {2,3,4}, {5}, excluding cursors. Queries past either end return empty.
    ciTestWidgets(
      'FL-CONV-004 positive pagination excludes cursors and reaches both ends',
      (tester) async {
        final fixture = await prepare();
        final conversation = fixture.conversation;
        final seeds = [
          for (var index = 1; index <= 5; index++)
            fixture.text('page $index', timestamp: index * 1000),
        ];
        for (final message in seeds) {
          await conversation.insertMessage(message);
        }

        final upPages = <List<ChatMessage>>[
          await conversation.loadMessages(loadCount: 2),
          await conversation.loadMessages(
              startMsgId: seeds[3].msgId, loadCount: 2),
          await conversation.loadMessages(
              startMsgId: seeds[1].msgId, loadCount: 2),
        ];
        debugPrint('FL-CONV-004 Up page timestamps: '
            '${upPages.map((page) => page.map((message) => message.serverTime).toList()).toList()}');
        _expectMessageIds(upPages[0], [seeds[3], seeds[4]]);
        _expectMessageIds(upPages[1], [seeds[1], seeds[2]]);
        _expectMessageIds(upPages[2], [seeds[0]]);
        _expectMessageIds(upPages.expand((page) => page), seeds);
        expect(
          await conversation.loadMessages(
              startMsgId: seeds.first.msgId, loadCount: 2),
          isEmpty,
        );

        final downFirst = await conversation.loadMessages(
          startMsgId: seeds.first.msgId,
          loadCount: 3,
          direction: ChatSearchDirection.Down,
        );
        final downLast = await conversation.loadMessages(
          startMsgId: seeds[3].msgId,
          loadCount: 3,
          direction: ChatSearchDirection.Down,
        );
        debugPrint('FL-CONV-004 Down page timestamps: '
            '${[
          downFirst,
          downLast
        ].map((page) => page.map((message) => message.serverTime).toList()).toList()}');
        _expectMessageIds(downFirst, [seeds[1], seeds[2], seeds[3]]);
        _expectMessageIds(downLast, [seeds[4]]);
        _expectMessageIds([...downFirst, ...downLast], seeds.skip(1));
        expect(
          await conversation.loadMessages(
            startMsgId: seeds.last.msgId,
            loadCount: 3,
            direction: ChatSearchDirection.Down,
          ),
          isEmpty,
        );
      },
    );

    // Test: Seed text/location messages with known senders and timestamps;
    // query keyword, type, search options, time ranges, and local counts.
    // Expected: Each query returns exactly the matching IDs; absent keywords,
    // types, and time ranges return empty lists, and range counts are 2 or 0.
    ciTestWidgets(
      'FL-CONV-005 positive local filters exclude nonmatching messages',
      (tester) async {
        final fixture = await prepare();
        final conversation = fixture.conversation;
        final first = fixture.text('needle alpha', timestamp: 1000);
        final ordinary = fixture.text('ordinary beta', timestamp: 2000);
        final outgoing =
            fixture.text('needle own', timestamp: 3000, outgoing: true);
        final location = fixture.message(
          ChatLocationMessageBody(
              latitude: 39.9, longitude: 116.4, address: 'ci place'),
          timestamp: 4000,
        );
        final last = fixture.text('needle later', timestamp: 5000);
        for (final message in [first, ordinary, outgoing, location, last]) {
          await conversation.insertMessage(message);
        }

        _expectMessageIds(
          await conversation.loadMessagesWithKeyword('needle', count: 10),
          [first, outgoing, last],
        );
        _expectMessageIds(
          await conversation.loadMessagesWithKeyword(
            'needle',
            senders: [conversation.id],
            count: 10,
          ),
          [first, last],
        );
        expect(await conversation.loadMessagesWithKeyword('absent_keyword'),
            isEmpty);
        _expectMessageIds(
          await conversation.loadMessagesWithMsgType(
              type: MessageType.TXT, count: 10),
          [first, ordinary, outgoing, last],
        );
        _expectMessageIds(
          await conversation.loadMessagesWithMsgType(
              type: MessageType.LOCATION, count: 10),
          [location],
        );
        _expectMessageIds(
          await conversation.loadMessagesWithMsgType(
            type: MessageType.TXT,
            sender: conversation.id,
            count: 10,
          ),
          [first, ordinary, last],
        );
        _expectMessageIds(
          await conversation.searchMsgsByOptions(
            MessageSearchOptions(
              types: const [MessageType.TXT],
              from: conversation.id,
              ts: 3500,
              count: 10,
            ),
          ),
          [first, ordinary],
        );
        expect(
          await conversation.searchMsgsByOptions(
            const MessageSearchOptions(types: [MessageType.VOICE], count: 10),
          ),
          isEmpty,
        );
        _expectMessageIds(
          await conversation.loadMessagesFromTime(
              startTime: 500, endTime: 3500, count: 10),
          [first, ordinary, outgoing],
        );
        expect(
          await conversation.loadMessagesFromTime(
              startTime: 6000, endTime: 7000, count: 10),
          isEmpty,
        );
        expect(
            await conversation.getLocalMessageCount(startMs: 500, endMs: 2500),
            2);
        expect(
            await conversation.getLocalMessageCount(startMs: 6000, endMs: 7000),
            0);
      },
    );

    // Test: Seed four local messages, delete the first/third by ID, delete the
    // second by its timestamp range, then delete all remaining messages.
    // Expected: Lists and counts contain exactly the survivors after each step;
    // the fourth message retains its content until the final deletion leaves none.
    // Note: the final clear is verified by polling, because the native layer
    // removes the rows asynchronously after deleteAllMessages returns
    // (HIM-24174, accepted as a known issue on the native side).
    ciTestWidgets(
      'FL-CONV-006 positive deletions preserve each remaining message set',
      (tester) async {
        final fixture = await prepare();
        final conversation = fixture.conversation;
        final seeds = [
          for (var index = 1; index <= 4; index++)
            fixture.text('delete $index', timestamp: index * 1000),
        ];
        for (final message in seeds) {
          await conversation.insertMessage(message);
        }
        await _expectMessages(conversation, seeds);

        await conversation.deleteMessageByIds([seeds[0].msgId, seeds[2].msgId]);
        await _expectMessages(conversation, [seeds[1], seeds[3]]);
        await conversation.deleteMessagesWithTs(1500, 2500);
        await _expectMessages(conversation, [seeds[3]]);
        _expectStoredMessage(
            await conversation.loadMessage(seeds[3].msgId), seeds[3]);
        await conversation.deleteAllMessages();
        // HIM-24174 (native known issue, decided not to fix): a successful
        // deleteAllMessages() return does not mean the DB rows are gone yet,
        // so an immediate messagesCount() can still observe the old rows.
        // Poll until the async deletion lands rather than sleeping a fixed
        // delay; remove this wait if the native side ever makes it synchronous.
        final remainingCount = await waitForCi(
          'FL-CONV-006 deleteAllMessages eventually clears all message rows',
          () => conversation.messagesCount(),
          (count) => count == 0,
          timeout: const Duration(seconds: 5),
        );
        final remainingMessages =
            await conversation.loadMessages(loadCount: 20);
        Object? remainingLast;
        try {
          remainingLast =
              (await conversation.loadMessage(seeds.last.msgId))?.msgId;
        } on ChatError catch (error) {
          // Missing-message lookup differs by platform; this is diagnostic only.
          remainingLast = 'error:${error.code}';
        }
        debugPrint('CI FL-CONV-006 after deleteAllMessages: '
            'autoLoad=${client.options!.autoLoadConversations} '
            'count=$remainingCount '
            'ids=${remainingMessages.map((item) => item.msgId).toList()} '
            'lastLookup=$remainingLast');
        expect(remainingCount, 0);
        expect(remainingMessages, isEmpty);
      },
    );

    // Test: Delete a seeded local conversation with deleteMessages=false,
    // load its message directly, then reopen the conversation.
    // Expected: Deletion returns true and removes the conversation from the
    // list; the message remains readable and reopening returns exactly that ID.
    ciTestWidgets(
      'FL-CONV-007 positive conversation deletion can retain local messages',
      (tester) async {
        final fixture = await prepare();
        final conversation = fixture.conversation;
        final seed = fixture.text('retained history', timestamp: 1000);
        await conversation.insertMessage(seed);
        expect(
          await client.chatManager
              .deleteConversation(conversation.id, deleteMessages: false),
          isTrue,
        );
        expect(
          (await client.chatManager.loadAllConversations())
              .map((item) => item.id),
          isNot(contains(conversation.id)),
        );
        _expectStoredMessage(
            await client.chatManager.loadMessage(seed.msgId), seed);
        final reopened = await client.chatManager.getConversation(
          conversation.id,
          createIfNeed: true,
        );
        await _expectMessages(reopened!, [seed]);
      },
    );

    // Test: Seed three local conversations; batch-delete two plus an absent ID.
    // Expected: The selected conversations disappear and reopen empty; the
    // unselected conversation and its original message remain intact.
    ciTestWidgets(
      'FL-CONV-008 positive batch deletion preserves unselected conversations',
      (tester) async {
        final first = await prepare();
        final second = await prepare();
        final control = await prepare();
        final fixtures = [first, second, control];
        final seeds = <ChatMessage>[];
        for (final fixture in fixtures) {
          final seed = fixture.text('batch deletion seed', timestamp: 1000);
          seeds.add(seed);
          await fixture.conversation.insertMessage(seed);
        }

        for (final id in [
          first.conversation.id,
          second.conversation.id,
          '${first.conversation.id}_absent',
        ]) {
          await client.chatManager.deleteConversation(id);
        }
        final remainingIds = (await client.chatManager.loadAllConversations())
            .map((item) => item.id)
            .toSet();
        expect(remainingIds, isNot(contains(first.conversation.id)));
        expect(remainingIds, isNot(contains(second.conversation.id)));
        expect(remainingIds, contains(control.conversation.id));
        await _expectMessages(control.conversation, [seeds[2]]);
        _expectStoredMessage(
            await control.conversation.loadMessage(seeds[2].msgId), seeds[2]);
        for (final fixture in [first, second]) {
          expect(
            await client.chatManager
                .getConversation(fixture.conversation.id, createIfNeed: false),
            isNull,
          );
          final reopened = await client.chatManager.getConversation(
            fixture.conversation.id,
            createIfNeed: true,
          );
          await _expectMessages(reopened!, const []);
        }
      },
    );
    // Test: Read three uniquely seeded conversations. Ignore unrelated account
    // history in assertions.
    // Expected: The default read returns this subset newest-first.
    ciTestWidgets(
      'FL-CONV-010 positive conversation sorting and membership',
      (_) async {
        final fixtures = [await prepare(), await prepare(), await prepare()];
        for (var index = 0; index < fixtures.length; index++) {
          final fixture = fixtures[index];
          await fixture.conversation.insertMessage(
            fixture.text('sort seed', timestamp: (index + 1) * 1000),
          );
        }
        final ids = fixtures.map((item) => item.conversation.id).toSet();
        final expected =
            fixtures.reversed.map((item) => item.conversation.id).toList();
        final results = await client.chatManager.loadAllConversations();
        final own = results.where((item) => ids.contains(item.id)).toList();
        expect(own.every((item) => !item.isPinned), isTrue);
        expect(
          own.map((item) => item.id),
          orderedEquals(expected),
          reason: 'loadAllConversations must retain all test conversations',
        );
      },
    );

    // Test: Pin and unpin a newly seeded conversation, rereading native state
    // after each operation alongside a separately seeded control conversation.
    // Expected: getConversation and loadAllConversations reflect each requested
    // isPinned value; the control stays unpinned and both messages are unchanged.
    // Cleanup unpins the target and deletes both local fixtures.
    ciTestWidgets(
      'FL-CONV-014 positive pin and unpin persist without changing a control',
      (_) async {
        final fixture = await prepare();
        final control = await prepare();
        final seed = fixture.text('pin fixture', timestamp: 1000);
        final controlSeed = control.text('pin control', timestamp: 2000);
        await fixture.conversation.insertMessage(seed);
        await control.conversation.insertMessage(controlSeed);
        final manager = client.chatManager;
        final id = fixture.conversation.id;
        var pinAttempted = false;
        // Registered after local cleanup, so unpin runs before deletion.
        addTearDown(() async {
          if (!pinAttempted) return;
          await manager.pinConversation(conversationId: id, isPinned: false);
          final restored =
              await manager.getConversation(id, createIfNeed: false);
          expect(restored, isNotNull);
          expect(restored!.isPinned, isFalse);
        });
        for (final pinned in [true, false]) {
          pinAttempted = true;
          await manager.pinConversation(conversationId: id, isPinned: pinned);
          final reread = await manager.getConversation(id, createIfNeed: false);
          expect(reread, isNotNull);
          expect(reread!.isPinned, pinned);
          final all = await manager.loadAllConversations();
          expect(all.where((item) => item.id == id).single.isPinned, pinned);
          expect(
              all
                  .where((item) => item.id == control.conversation.id)
                  .single
                  .isPinned,
              isFalse);
          await _expectMessages(fixture.conversation, [seed]);
          await _expectMessages(control.conversation, [controlSeed]);
        }
      },
    );

    // Test: Make the prepared peer a friend, clear this conversation's unread
    // count (a fresh account may have no such conversation yet, which already
    // satisfies the clean baseline), then deliver two real one-to-one messages
    // through REST.
    // Expected: unreadCount reaches exactly 2 and the account total rises by 2;
    // clearing this conversation returns the conversation to zero and the
    // account total to its baseline without deleting account history.
    // Cleanup restores friendship and clears unread.
    ciTestWidgets(
      'FL-CONV-016 positive real inbound messages update unread counts',
      (_) async {
        final manager = client.chatManager;
        // Clears the peer conversation's unread count for a clean baseline.
        // A fresh account has no conversation with the peer yet; the native
        // SDK then fails with code 110 (conversation not found), which
        // already satisfies the no-unread precondition, so only that code
        // is ignored.
        Future<void> clearPeerUnread() async {
          final conversation =
              await manager.getConversation(peerId, createIfNeed: false);
          // A fresh account has no conversation with the peer yet, which
          // already satisfies the no-unread precondition.
          if (conversation == null) return;
          await conversation
              .markAllMessagesAsRead()
              .timeout(const Duration(seconds: 15));
        }

        final snapshot = await rest.snapshotContacts(userId, peerId);
        addTearDown(() => rest.restoreContacts(userId, peerId, snapshot));
        addTearDown(clearPeerUnread);
        await rest.setContacts(userId, peerId, true);
        await clearPeerUnread();
        final baseline = await manager.getUnreadMessageCount();
        final run = 'ci_unread_${DateTime.now().microsecondsSinceEpoch}';
        for (final text in ['$run first', '$run second']) {
          await rest.sendTextMessage(from: peerId, to: userId, text: text);
        }
        final unread = await waitForCi(
          'conversation $peerId unread reaches 2',
          () async {
            final conversation = await manager.getConversation(
              peerId,
              createIfNeed: false,
            );
            return conversation == null ? -1 : conversation.unreadCount();
          },
          (value) => value == 2,
        );
        expect(unread, 2);
        expect(
          await manager.getUnreadMessageCount(),
          greaterThanOrEqualTo(baseline + 2),
        );
        final conversationToClear =
            await manager.getConversation(peerId, createIfNeed: false);
        expect(conversationToClear, isNotNull);
        await conversationToClear!.markAllMessagesAsRead();
        final cleared =
            await manager.getConversation(peerId, createIfNeed: false);
        expect(cleared, isNotNull);
        expect(await cleared!.unreadCount(), 0);
        await waitForCi(
          'account unread total returns to the baseline',
          manager.getUnreadMessageCount,
          (value) => value == baseline,
        );
      },
    );

    // Test: Send one real message to the prepared peer, confirm it through the
    // final callback and server history, then delete it from local and server.
    // Expected: The message is readable locally and present in server history
    // before the call; neither read path returns it afterward. Only this
    // message is reclaimed; account history and friendship stay untouched.
    ciTestWidgets(
      'FL-CONV-017 positive deletes a message from local and server',
      (_) async {
        final manager = client.chatManager;
        final run =
            'ci_conv_server_delete_${DateTime.now().microsecondsSinceEpoch}';
        final handlerId = '${run}_event';
        final completion = Completer<ChatMessage>();
        final draft =
            ChatMessage.createTxtSendMessage(targetId: peerId, content: run);
        final localId = draft.msgId;
        manager.addMessageEvent(
          handlerId,
          ChatMessageEvent(
            onSuccess: (messageId, message) {
              if (messageId == localId && !completion.isCompleted) {
                completion.complete(message);
              }
            },
            onError: (messageId, message, error) {
              if (messageId == localId && !completion.isCompleted) {
                completion.completeError(error);
              }
            },
          ),
        );
        addTearDown(() => manager.removeMessageEvent(handlerId));
        await manager.sendMessage(draft).timeout(const Duration(seconds: 30));
        final confirmed =
            await completion.future.timeout(const Duration(seconds: 30));
        expect(confirmed.status, MessageStatus.SUCCESS);
        expect(confirmed.msgId, isNotEmpty);

        Future<bool> inServerHistory() async {
          final page = await manager.fetchHistoryMessagesByOption(
            peerId,
            ChatConversationType.Chat,
            pageSize: 50,
          );
          return page.data.any((message) => message.msgId == confirmed.msgId);
        }

        await waitForCi(
          'server history contains the ready message',
          inServerHistory,
          (value) => value,
        );
        expect(await manager.loadMessage(confirmed.msgId), isNotNull);
        final conversation =
            await manager.getConversation(peerId, createIfNeed: false);
        expect(conversation, isNotNull);
        await conversation!
            .deleteLocalAndServerMessages(msgIds: [confirmed.msgId]);
        await waitForCi(
          'local message is removed',
          () => manager.loadMessage(confirmed.msgId),
          (value) => value == null,
        );
        await waitForCi(
          'server history drops the message',
          inServerHistory,
          (value) => !value,
        );
      },
    );

    // Test: Mark and unmark the prepared peer conversation through the SDK.
    // Expected: The local conversation reports the mark after adding it and no
    // longer reports it after removal; the conversation itself is untouched.
    // Teardown removes any leftover mark and restores the friendship snapshot.
    ciTestWidgets(
      'FL-CONV-018 positive adds and removes a conversation mark',
      (_) async {
        const mark = ConversationMarkType.Type0;
        final manager = client.chatManager;
        final snapshot = await rest.snapshotContacts(userId, peerId);
        addTearDown(() => rest.restoreContacts(userId, peerId, snapshot));
        addTearDown(() async {
          try {
            await manager.deleteRemoteAndLocalConversationsMark(
              conversationIds: [peerId],
              mark: mark,
            );
          } catch (_) {
            // Best effort; the assertion below still proves the main path.
          }
        });
        await rest.setContacts(userId, peerId, true);
        final run = 'ci_mark_${DateTime.now().microsecondsSinceEpoch}';
        await rest.sendTextMessage(from: peerId, to: userId, text: run);
        await waitForCi(
          'peer conversation exists locally',
          () async =>
              (await manager.getConversation(peerId, createIfNeed: false))?.id,
          (id) => id == peerId,
        );
        final before =
            await manager.getConversation(peerId, createIfNeed: false);
        expect(before, isNotNull);
        expect(before!.marks ?? const <ConversationMarkType>[],
            isNot(contains(mark)));
        await manager.addRemoteAndLocalConversationsMark(
          conversationIds: [peerId],
          mark: mark,
        );
        final marked = await waitForCi(
          'local conversation reports the added mark',
          () async =>
              (await manager.getConversation(peerId, createIfNeed: false))
                  ?.marks ??
              const <ConversationMarkType>[],
          (marks) => marks.contains(mark),
        );
        expect(marked, contains(mark));
        await manager.deleteRemoteAndLocalConversationsMark(
          conversationIds: [peerId],
          mark: mark,
        );
        await waitForCi(
          'local conversation drops the removed mark',
          () async =>
              (await manager.getConversation(peerId, createIfNeed: false))
                  ?.marks ??
              const <ConversationMarkType>[],
          (marks) => !marks.contains(mark),
        );
      },
    );

    registerChatroomConversationCases(
      client: client,
      userId: userId,
      rest: rest,
    );
  });
}

void registerConversationPaginationCases({
  required ChatClient client,
  required String userId,
}) {
  Future<_ConversationFixture> prepare() =>
      _prepareConversation(client, userId);

  // Test: Page through a real database containing three owned conversations,
  // including two tied timestamps. Follow each native cursor to the last page.
  // Expected: Null/empty initial cursors agree; pages respect the limit,
  // cursors and IDs never repeat, and the owned subset is complete and sorted
  // by time then case-insensitive ID descending. Never delete account history.
  ciTestWidgets(
    'FL-CONV-011 positive database pagination preserves continuity and order',
    (_) async {
      expect(client.options!.autoLoadConversations, isFalse);
      final fixtures = [await prepare(), await prepare(), await prepare()];
      final timestamps = <String, int>{};
      for (var index = 0; index < fixtures.length; index++) {
        final fixture = fixtures[index];
        final timestamp = index == 1 ? 1000 : 2000;
        timestamps[fixture.conversation.id] = timestamp;
        await fixture.conversation.insertMessage(
          fixture.text('database page seed', timestamp: timestamp),
        );
      }
      final first =
          await client.chatManager.fetchConversationsFromDB(pageSize: 2);
      final emptyCursor = await client.chatManager.fetchConversationsFromDB(
        cursor: '',
        pageSize: 2,
      );
      expect(emptyCursor.data.map((item) => item.id),
          orderedEquals(first.data.map((item) => item.id)));

      final seenIds = <String>{};
      final seenCursors = <String>{};
      final owned = <ChatConversation>[];
      var page = first;
      var reachedEnd = false;
      for (var pageIndex = 0; pageIndex < 200; pageIndex++) {
        expect(page.data.length, lessThanOrEqualTo(2));
        for (final conversation in page.data) {
          expect(seenIds.add(conversation.id), isTrue,
              reason: 'Database pagination repeated ${conversation.id}');
          if (timestamps.containsKey(conversation.id)) {
            owned.add(conversation);
          }
        }
        final cursor = page.cursor;
        expect(cursor, isNotNull,
            reason: 'Native contract uses an empty string for the last page');
        if (cursor!.isEmpty) {
          reachedEnd = true;
          break;
        }
        expect(seenCursors.add(cursor), isTrue,
            reason: 'Database pagination repeated a nonterminal cursor');
        page = await client.chatManager.fetchConversationsFromDB(
          cursor: cursor,
          pageSize: 2,
        );
      }
      expect(reachedEnd, isTrue,
          reason: 'Fixture/account exceeds the bounded 200-page budget or '
              'pagination does not terminate; inspect the database');
      final expectedIds = timestamps.keys.toList()
        ..sort((a, b) {
          final byTime = timestamps[b]!.compareTo(timestamps[a]!);
          return byTime != 0
              ? byTime
              : b.toLowerCase().compareTo(a.toLowerCase());
        });
      expect(owned.map((item) => item.id), orderedEquals(expectedIds));
      expect(owned.every((item) => !item.isPinned), isTrue);
    },
  );

  // Test: Pin the oldest of three owned conversations (the two newer ones tie
  // on message time) and page the real database before and after unpinning.
  // Expected: The pinned conversation sorts first regardless of message time;
  // the remaining conversations keep time-then-ID descending order, and
  // unpinning restores pure time order. Existing cases exclude pinned
  // conversations through the inverse premise, so this is the only
  // pinned-first ordering assertion.
  ciTestWidgets(
    'FL-CONV-015 positive pinned conversation sorts first across pages',
    (_) async {
      expect(client.options!.autoLoadConversations, isFalse);
      final fixtures = [await prepare(), await prepare(), await prepare()];
      final timestamps = <String, int>{};
      for (var index = 0; index < fixtures.length; index++) {
        final fixture = fixtures[index];
        final timestamp = index == 0 ? 1000 : 2000;
        timestamps[fixture.conversation.id] = timestamp;
        await fixture.conversation.insertMessage(
          fixture.text('pinned page seed', timestamp: timestamp),
        );
      }
      final pinnedId = fixtures.first.conversation.id;
      final manager = client.chatManager;

      List<String> timeOrder() {
        final ids = timestamps.keys.toList()
          ..sort((a, b) {
            final byTime = timestamps[b]!.compareTo(timestamps[a]!);
            return byTime != 0
                ? byTime
                : b.toLowerCase().compareTo(a.toLowerCase());
          });
        return ids;
      }

      Future<List<ChatConversation>> orderedOwned() async {
        final seen = <String>{};
        final owned = <ChatConversation>[];
        var page = await manager.fetchConversationsFromDB(pageSize: 2);
        for (var index = 0; index < 200; index++) {
          for (final conversation in page.data) {
            expect(seen.add(conversation.id), isTrue,
                reason: 'Database pagination repeated ${conversation.id}');
            if (timestamps.containsKey(conversation.id)) {
              owned.add(conversation);
            }
          }
          final cursor = page.cursor;
          if (cursor == null || cursor.isEmpty) {
            return owned;
          }
          page = await manager.fetchConversationsFromDB(
            cursor: cursor,
            pageSize: 2,
          );
        }
        throw StateError(
            'Database pagination did not terminate within 200 pages');
      }

      var pinAttempted = false;
      addTearDown(() async {
        if (!pinAttempted) return;
        await manager
            .pinConversation(conversationId: pinnedId, isPinned: false)
            .timeout(const Duration(seconds: 15));
      });
      pinAttempted = true;
      await manager
          .pinConversation(conversationId: pinnedId, isPinned: true)
          .timeout(const Duration(seconds: 15));

      final pinnedExpected = [
        pinnedId,
        ...timeOrder().where((id) => id != pinnedId),
      ];
      final pinnedOrder = await waitForCi(
        'pinned conversation sorts first',
        orderedOwned,
        (list) => list.length == timestamps.length && list.first.id == pinnedId,
      );
      expect(pinnedOrder.map((item) => item.id), orderedEquals(pinnedExpected));
      expect(pinnedOrder.first.isPinned, isTrue);
      expect(pinnedOrder.skip(1).every((item) => !item.isPinned), isTrue);

      await manager
          .pinConversation(conversationId: pinnedId, isPinned: false)
          .timeout(const Duration(seconds: 15));
      final restoredOrder = timeOrder();
      final restored = await waitForCi(
        'unpinned conversation returns to time order',
        orderedOwned,
        (list) =>
            list.length == timestamps.length &&
            list.map((item) => item.id).join(',') == restoredOrder.join(','),
      );
      expect(restored.every((item) => !item.isPinned), isTrue);
    },
  );
}

void registerChatroomConversationCases({
  required ChatClient client,
  required String userId,
  required CiRestFixture rest,
}) {
  // Test: Send a real message in an independently created chatroom without
  // explicitly creating its local conversation. Run in separate processes
  // with explicit enableChatroomConversation=false and true.
  // Expected: The correlated final send callback succeeds; the local list
  // contains this room exactly once only when conversation creation is enabled.
  ciTestWidgets(
    'FL-CONV-013 positive chatroom send obeys conversation creation option',
    (_) async {
      final enabled = client.options!.enableChatroomConversation;
      final run = 'ci_room_${DateTime.now().microsecondsSinceEpoch}';
      final manager = client.chatManager;
      String? roomId;
      // Independent teardown callbacks allow later cleanup after one fails.
      addTearDown(() async {
        final id = roomId;
        if (id == null) return;
        await manager.deleteConversation(id, deleteMessages: true);
        expect((await manager.loadAllConversations()).map((item) => item.id),
            isNot(contains(id)));
        debugPrint('CI FL-CONV-013 cleanup verified: local room absent');
      });
      addTearDown(() async {
        final id = roomId;
        if (id == null) {
          throw StateError('FL-CONV-013 room creation outcome unconfirmed; '
              'owner=$userId name=$run; verify REST resources');
        }
        await rest.deleteChatRoom(id);
        await rest.verifyChatRoomAbsent(id);
        debugPrint('CI FL-CONV-013 cleanup verified: REST room $id absent');
      });
      roomId = await rest.createChatRoom(
        owner: userId,
        name: run,
        description: run,
      );
      final id = roomId;
      debugPrint('CI FL-CONV-013 resource: room=$id enable=$enabled');
      final remote = await rest.chatRoom(id);
      expect(remote, isNotNull);
      expect(remote!['owner'], userId);
      expect(remote['name'], run);
      // Register before join so an interrupted join still attempts to leave.
      addTearDown(() => client.chatRoomManager
          .leaveChatRoom(id)
          .timeout(const Duration(seconds: 15)));
      await client.chatRoomManager
          .joinChatRoom(id)
          .timeout(const Duration(seconds: 30));

      final message = ChatMessage.createTxtSendMessage(
        targetId: id,
        content: run,
        chatType: ChatType.ChatRoom,
      );
      final localId = message.msgId;
      final completion = Completer<({ChatMessage message, ChatError? error})>();
      manager.addMessageEvent(
          run,
          ChatMessageEvent(
            onSuccess: (messageId, confirmed) {
              if (messageId == localId && !completion.isCompleted) {
                completion.complete((message: confirmed, error: null));
              }
            },
            onError: (messageId, failed, error) {
              if (messageId == localId && !completion.isCompleted) {
                completion.complete((message: failed, error: error));
              }
            },
          ));
      addTearDown(() => manager.removeMessageEvent(run));
      await manager.sendMessage(message).timeout(const Duration(seconds: 30));
      final result =
          await completion.future.timeout(const Duration(seconds: 30));
      expect(result.error, isNull,
          reason: 'Chatroom send must finish successfully');
      expect(result.message.status, MessageStatus.SUCCESS);
      expect(result.message.msgId, isNotEmpty);
      expect(result.message.to, id);
      expect(result.message.chatType, ChatType.ChatRoom);
      expect((result.message.body as ChatTextMessageBody).content, run);
      final rooms = (await manager.loadAllConversations())
          .where((conversation) => conversation.id == id)
          .toList();
      expect(rooms, hasLength(enabled ? 1 : 0));
      if (enabled) expect(rooms.single.type, ChatConversationType.ChatRoom);
      debugPrint('CI FL-CONV-013 verify passed: enable=$enabled room=$id');
    },
  );
}

var _fixtureSequence = 0;

Future<_ConversationFixture> _prepareConversation(
  ChatClient client,
  String userId,
) async {
  final id =
      'flutter_ci_conv_${DateTime.now().microsecondsSinceEpoch}_${++_fixtureSequence}';
  addTearDown(() async {
    // Reopen this test's conversation to also reclaim messages retained by
    // deleteMessages:false, including when the assertion failed midway.
    await client.chatManager.getConversation(id, createIfNeed: true);
    await client.chatManager.deleteConversation(id, deleteMessages: true);
    expect(
      await client.chatManager.getConversation(id, createIfNeed: false),
      isNull,
      reason: 'Cleanup must remove the test conversation $id',
    );
  });
  expect(
    await client.chatManager.getConversation(id, createIfNeed: false),
    isNull,
    reason: 'Reading an absent conversation must not create it',
  );
  final conversation = await client.chatManager.getConversation(
    id,
    createIfNeed: true,
  );
  expect(conversation, isNotNull);
  return _ConversationFixture(conversation!, userId);
}

final class _ConversationFixture {
  _ConversationFixture(this.conversation, this.userId);

  final ChatConversation conversation;
  final String userId;
  var _messageSequence = 0;

  ChatMessage text(String content,
          {required int timestamp, bool outgoing = false}) =>
      message(ChatTextMessageBody(content: content),
          timestamp: timestamp, outgoing: outgoing);

  ChatMessage message(ChatMessageBody body,
      {required int timestamp, bool outgoing = false}) {
    final draft = outgoing
        ? ChatMessage.createSendMessage(body: body, to: conversation.id)
        : ChatMessage.createReceiveMessage(body: body);
    draft
      ..from = outgoing ? userId : conversation.id
      ..to = outgoing ? conversation.id : userId
      ..conversationId = conversation.id
      ..localTime = timestamp
      ..serverTime = timestamp
      ..status = MessageStatus.SUCCESS
      ..attributes = <String, dynamic>{
        'fixture': conversation.id,
        'timestamp': timestamp
      };
    return ChatMessage.fromJson({
      ...draft.toJson(),
      'msgId': '${conversation.id}_${++_messageSequence}',
    });
  }
}

void _expectMessageIds(
    Iterable<ChatMessage> actual, Iterable<ChatMessage> expected) {
  // Exact membership rejects unexpected IDs, missing IDs, and duplicates.
  expect(actual.map((message) => message.msgId),
      unorderedEquals(expected.map((message) => message.msgId)));
}

Future<void> _expectMessages(
    ChatConversation conversation, List<ChatMessage> expected) async {
  expect(await conversation.messagesCount(), expected.length);
  _expectMessageIds(await conversation.loadMessages(loadCount: 20), expected);
}

void _expectStoredMessage(ChatMessage? actual, ChatMessage expected) {
  expect(actual, isNotNull);
  expect(actual!.msgId, expected.msgId);
  expect(actual.conversationId, expected.conversationId);
  expect(actual.from, expected.from);
  expect(actual.to, expected.to);
  expect(actual.direction, expected.direction);
  expect(actual.attributes, expected.attributes);
  if (expected.body is ChatTextMessageBody) {
    expect(actual.body, isA<ChatTextMessageBody>());
    expect((actual.body as ChatTextMessageBody).content,
        (expected.body as ChatTextMessageBody).content);
  }
}
