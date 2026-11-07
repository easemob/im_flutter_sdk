import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../support/ci_test.dart';

void registerConversationCases({
  required ChatClient client,
  required String userId,
}) {
  var sequence = 0;

  Future<_ConversationFixture> prepare() async {
    final id =
        'flutter_ci_conv_${DateTime.now().microsecondsSinceEpoch}_${++sequence}';
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

  group('positive conversation cases', () {
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
        await _expectMessages(conversation, const []);
      },
    );

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
  });
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
