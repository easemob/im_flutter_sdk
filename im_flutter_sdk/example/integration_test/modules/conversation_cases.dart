import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../support/ci_test.dart';
import '../support/rest_fixture.dart';

void registerConversationCases({
  required ChatClient client,
  required String userId,
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
    // last received, and by ID, then clear the zero unread count twice.
    // Expected: Reads match the seeded messages, latest is the sent message,
    // last received is the second received message, and unread stays zero.
    // This covers the zero boundary, not clearing a nonzero unread count.
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

        // Local insertion does not increment unread count. These assertions
        // cover only the zero boundary and idempotence, not nonzero clearing.
        expect(await conversation.unreadCount(), 0);
        for (var attempt = 0; attempt < 2; attempt++) {
          await client.chatManager.clearConversationUnreadMessageCount(
            conversation.id,
          );
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
        final remainingCount = await conversation.messagesCount();
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

        await client.chatManager.deleteConversations([
          first.conversation.id,
          second.conversation.id,
          '${first.conversation.id}_absent',
        ]);
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
    // Test: Read three uniquely seeded conversations with omitted, enabled,
    // and disabled sorting. Ignore unrelated account history in assertions.
    // Expected: Default/true return this subset newest-first; false preserves
    // the exact subset without imposing an order or requiring a different one.
    ciTestWidgets(
      'FL-CONV-010 positive conversation sorting and unsorted membership',
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
        for (final isSort in <bool?>[null, true, false]) {
          final results = isSort == null
              ? await client.chatManager.loadAllConversations()
              : await client.chatManager.loadAllConversations(isSort: isSort);
          final own = results.where((item) => ids.contains(item.id)).toList();
          expect(own.every((item) => !item.isPinned), isTrue);
          expect(
              own.map((item) => item.id),
              isSort == false
                  ? unorderedEquals(expected)
                  : orderedEquals(expected),
              reason: 'isSort=$isSort must retain all test conversations');
        }
      },
    );

    // Test: Pin and unpin a newly seeded conversation, rereading native state
    // after each operation. The unrelated control conversation stays unpinned.
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
          await client.chatManager.getConversationsFromDB(pageSize: 2);
      final emptyCursor = await client.chatManager.getConversationsFromDB(
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
        page = await client.chatManager.getConversationsFromDB(
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
