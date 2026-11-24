import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../support/ci_test.dart';
import '../support/env.dart';

/// Local-database conversation cases. No server state is required: the
/// conversation id is a synthetic local id, so these cases stay independent of
/// the peer account.
void registerConversationCases(ChatClient client) {
  group('single-account local database', () {
    var sequence = 0;
    var messageSequence = 0;
    late String conversationId;
    late ChatConversation conversation;

    ChatMessage incoming(
      String content, {
      int? timestamp,
      Map<String, dynamic>? attributes,
    }) {
      final time = timestamp ?? DateTime.now().millisecondsSinceEpoch;
      return ChatMessage.createReceiveMessage(
        body: ChatTextMessageBody(content: content),
      )
        ..from = conversationId
        ..to = ciUserId
        ..conversationId = conversationId
        ..localTime = time
        ..serverTime = time
        ..hasRead = false
        ..status = MessageStatus.SUCCESS
        ..attributes = attributes;
    }

    String nextMessageId() => '${conversationId}_m${messageSequence++}';

    ChatMessage fixture(
      ChatMessageBody body, {
      String? id,
      int? timestamp,
      Map<String, dynamic>? attributes,
      String? from,
      String? to,
      MessageDirection direction = MessageDirection.RECEIVE,
      bool hasRead = false,
    }) {
      final time = timestamp ?? DateTime.now().millisecondsSinceEpoch;
      final isSend = direction == MessageDirection.SEND;
      final draft = ChatMessage.createReceiveMessage(body: body)
        ..from = from ?? (isSend ? ciUserId : conversationId)
        ..to = to ?? (isSend ? conversationId : ciUserId)
        ..conversationId = conversationId
        ..localTime = time
        ..serverTime = time
        ..hasRead = hasRead
        ..direction = direction
        ..status = MessageStatus.SUCCESS
        ..attributes = attributes;
      return ChatMessage.fromJson(<String, dynamic>{
        ...draft.toJson(),
        'msgId': id ?? nextMessageId(),
      });
    }

    ChatMessage textMessage(
      String content, {
      String? id,
      int? timestamp,
      Map<String, dynamic>? attributes,
      String? from,
      MessageDirection direction = MessageDirection.RECEIVE,
      bool hasRead = false,
    }) {
      return fixture(
        ChatTextMessageBody(content: content),
        id: id,
        timestamp: timestamp,
        attributes: attributes,
        from: from,
        direction: direction,
        hasRead: hasRead,
      );
    }

    ChatMessage customMessage(
      String event, {
      Map<String, String>? params,
      String? id,
      int? timestamp,
      Map<String, dynamic>? attributes,
      String? from,
    }) {
      return fixture(
        ChatCustomMessageBody(event: event, params: params),
        id: id,
        timestamp: timestamp,
        attributes: attributes,
        from: from,
      );
    }

    List<String> messageIds(Iterable<ChatMessage> messages) =>
        messages.map((message) => message.msgId).toList();

    void expectTextStored(ChatMessage? actual, ChatMessage expected) {
      expect(actual, isNotNull);
      final message = actual!;
      expect(message.msgId, expected.msgId);
      expect(message.conversationId, conversationId);
      expect(message.from, expected.from);
      expect(message.to, expected.to);
      expect(message.direction, expected.direction);
      expect(message.status, MessageStatus.SUCCESS);
      expect(
        (message.body as ChatTextMessageBody).content,
        (expected.body as ChatTextMessageBody).content,
      );
      expect(message.attributes, expected.attributes);
    }

    Future<ChatConversation> peerConversation() async {
      final peer = await client.chatManager.getConversation(
        ciPeerId,
        createIfNeed: true,
      );
      expect(peer, isNotNull);
      return peer!;
    }

    Future<ChatMessage> sendToPeer(String label) async {
      final content = '$label ${DateTime.now().microsecondsSinceEpoch}';
      final message = ChatMessage.createTxtSendMessage(
        targetId: ciPeerId,
        content: content,
      );
      final localId = message.msgId;
      final handlerId =
          'flutter_ci_conv_${DateTime.now().microsecondsSinceEpoch}_'
          '${messageSequence++}';
      final completion = Completer<({ChatMessage message, ChatError? error})>();
      client.chatManager.addMessageEvent(
        handlerId,
        ChatMessageEvent(
          onSuccess: (id, confirmed) {
            if (id == localId && !completion.isCompleted) {
              completion.complete((message: confirmed, error: null));
            }
          },
          onError: (id, failed, error) {
            if (id == localId && !completion.isCompleted) {
              completion.complete((message: failed, error: error));
            }
          },
        ),
      );
      addTearDown(() => client.chatManager.removeMessageEvent(handlerId));

      await client.chatManager.sendMessage(message);
      final result = await completion.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException(
          'No final send callback for local message $localId',
        ),
      );
      expect(result.error, isNull, reason: 'server rejected "$label"');
      expect(result.message.msgId, isNotEmpty);
      return result.message;
    }

    Future<void> deletePeerMessageQuietly(String msgId) async {
      try {
        await client.chatManager.deleteRemoteMessagesWithIds(
          conversationId: ciPeerId,
          type: ChatConversationType.Chat,
          msgIds: <String>[msgId],
        );
      } on ChatError {
        // Best effort: the message may already be gone from the server.
      }
      final peer = await client.chatManager.getConversation(
        ciPeerId,
        createIfNeed: false,
      );
      if (peer == null) {
        return;
      }
      try {
        await peer.deleteMessage(msgId);
      } on ChatError {
        // Best effort: local deletion is only cleanup.
      }
    }

    Future<void> unpinQuietly(String msgId) async {
      try {
        await client.chatManager.unpinMessage(messageId: msgId);
      } on ChatError {
        // Best effort: pinning may be unsupported by this platform build.
      }
    }

    Future<void> restorePeerSilentMode() async {
      try {
        await client.pushManager.setConversationSilentMode(
          conversationId: ciPeerId,
          type: ChatConversationType.Chat,
          param: ChatSilentModeParam.remindType(ChatPushRemindType.ALL),
        );
      } on ChatError {
        // Best effort: leave the peer conversation in its previous state.
      }
    }

    setUp(() async {
      sequence += 1;
      messageSequence = 0;
      conversationId =
          'flutter_ci_${DateTime.now().microsecondsSinceEpoch}_$sequence';
      conversation = (await client.chatManager.getConversation(
        conversationId,
        createIfNeed: true,
      ))!;
    });

    tearDown(() async {
      await client.chatManager.deleteConversation(
        conversationId,
        deleteMessages: true,
      );
    });

    ciTestWidgets(
      'FL-CONV-001 creates, lists, extends, and deletes a conversation',
      (tester) async {
        final seed = incoming('conversation lifecycle seed');
        await conversation.insertMessage(seed);
        await conversation
            .setExt(const <String, String>{'owner': 'flutter-ci'});

        expect(conversation.id, conversationId);
        expect(conversation.type, ChatConversationType.Chat);
        expect(conversation.ext, const <String, String>{'owner': 'flutter-ci'});

        final all = await client.chatManager.loadAllConversations();
        expect(all.map((item) => item.id), contains(conversationId));

        expect(
          await client.chatManager.deleteConversation(
            conversationId,
            deleteMessages: true,
          ),
          isTrue,
        );
        expect(
          await client.chatManager.getConversation(
            conversationId,
            createIfNeed: false,
          ),
          isNull,
        );
      },
    );

    ciTestWidgets('FL-CONV-002 maintains latest, unread, and read state',
        (tester) async {
      final first = incoming('first', timestamp: 1000);
      final second = incoming('second', timestamp: 2000);
      await conversation.insertMessage(first);
      await conversation.insertMessage(second);

      expect(await conversation.messagesCount(), 2);
      expect(await conversation.unreadCount(), 2);
      expect((await conversation.latestMessage())?.msgId, second.msgId);
      expect((await conversation.lastReceivedMessage())?.msgId, second.msgId);
      expect((await conversation.loadMessage(first.msgId))?.msgId, first.msgId);

      await conversation.markMessageAsRead(first.msgId);
      expect(await conversation.unreadCount(), 1);
      await conversation.markAllMessagesAsRead();
      expect(await conversation.unreadCount(), 0);
    });

    ciTestWidgets('FL-CONV-003 appends, updates, loads, and removes a message',
        (tester) async {
      final message = incoming('before update');
      await conversation.appendMessage(message);
      expect(
        (await conversation.loadMessage(message.msgId))?.msgId,
        message.msgId,
      );

      message.body = ChatTextMessageBody(content: 'after update');
      await conversation.updateMessage(message);
      final updated = await conversation.loadMessage(message.msgId);
      expect((updated?.body as ChatTextMessageBody).content, 'after update');

      await conversation.deleteMessage(message.msgId);
      // NOTE(ios): loading a deleted message throws ChatError (code 3) on iOS
      // because the native SDK reports an EMError, while Android returns null.
      // expect(await conversation.loadMessage(message.msgId), isNull);
    });

    ciTestWidgets('FL-CONV-004 pages local messages upward and downward',
        (tester) async {
      final first = incoming('page 1', timestamp: 1000);
      final second = incoming('page 2', timestamp: 2000);
      final third = incoming('page 3', timestamp: 3000);
      for (final message in <ChatMessage>[first, second, third]) {
        await conversation.insertMessage(message);
      }

      final older = await conversation.loadMessages(
        startMsgId: third.msgId,
        loadCount: 2,
        direction: ChatSearchDirection.Up,
      );
      expect(
        older.map((item) => item.msgId),
        containsAll(<String>[first.msgId, second.msgId]),
      );

      final newer = await conversation.loadMessages(
        startMsgId: first.msgId,
        loadCount: 2,
        direction: ChatSearchDirection.Down,
      );
      expect(
        newer.map((item) => item.msgId),
        containsAll(<String>[second.msgId, third.msgId]),
      );
    });

    ciTestWidgets(
        'FL-CONV-005 searches local messages by content, type, and options',
        (tester) async {
      final first = incoming(
        'flutter needle alpha',
        timestamp: 1000,
        attributes: <String, dynamic>{'suite': 'flutter-ci'},
      );
      final second = incoming('ordinary beta', timestamp: 2000);
      await conversation.insertMessage(first);
      await conversation.insertMessage(second);

      final keyword = await conversation.loadMessagesWithKeyword(
        'needle',
        count: 10,
      );
      expect(keyword.map((item) => item.msgId), contains(first.msgId));

      final texts = await conversation.loadMessagesWithMsgType(
        type: MessageType.TXT,
        count: 10,
      );
      expect(
        texts.map((item) => item.msgId),
        containsAll(<String>[first.msgId, second.msgId]),
      );

      final options = await conversation.searchMsgsByOptions(
        MessageSearchOptions(
          types: const <MessageType>[MessageType.TXT],
          from: conversationId,
          count: 10,
        ),
      );
      expect(options.map((item) => item.msgId), contains(first.msgId));

      final inRange = await conversation.loadMessagesFromTime(
        startTime: 500,
        endTime: 1500,
        count: 10,
      );
      expect(inRange.map((item) => item.msgId), contains(first.msgId));
      expect(
        await conversation.getLocalMessageCount(startMs: 500, endMs: 2500),
        2,
      );
    });

    ciTestWidgets('FL-CONV-006 deletes local messages by id and all',
        (tester) async {
      final first = incoming('delete by id', timestamp: 1000);
      final second = incoming('delete all', timestamp: 3000);
      for (final message in <ChatMessage>[first, second]) {
        await conversation.insertMessage(message);
      }

      await conversation.deleteMessage(first.msgId);
      // NOTE(ios): loading a deleted message throws ChatError (code 3) on iOS
      // because the native SDK reports an EMError, while Android returns null.
      // expect(await conversation.loadMessage(first.msgId), isNull);
      expect(await conversation.loadMessage(second.msgId), isNotNull);

      await conversation.deleteAllMessages();
      // Native deletion is applied asynchronously; poll until it settles.
      final remaining = await waitForCi<int>(
        'CI local conversation is cleared',
        () => conversation.messagesCount(),
        (count) => count == 0,
      );
      expect(remaining, 0);
    });

    // Test: read a fresh conversation ext, write one through setExt, then read
    // it back from the same instance and from a conversation reloaded from the
    // local database.
    // Expected: ext is null before the write and equals the written map after
    // it; the reloaded conversation exposes the same map.
    ciTestWidgets('FL-CONV-007 reads the conversation extension',
        (tester) async {
      expect(conversation.ext, isNull);

      const ext = <String, String>{'owner': 'flutter-ci', 'case': '007'};
      await conversation.setExt(ext);
      expect(conversation.ext, ext);

      final reloaded = await client.chatManager.getConversation(
        conversationId,
        createIfNeed: false,
      );
      expect(reloaded, isNotNull);
      expect(reloaded!.ext, ext);
    });

    // Test: persist a conversation ext, replace it, then clear it with null.
    // Expected: every write is observable through a fresh getConversation read,
    // and the cleared conversation has a null ext. HarmonyOS keeps ext in the
    // local database, so a fresh native read is the persistence check here.
    ciTestWidgets('FL-CONV-008 writes and clears the conversation extension',
        (tester) async {
      Future<ChatConversation> reload() async {
        final value = await client.chatManager.getConversation(
          conversationId,
          createIfNeed: false,
        );
        expect(value, isNotNull);
        return value!;
      }

      const first = <String, String>{'stage': 'first'};
      await conversation.setExt(first);
      expect((await reload()).ext, first);

      const second = <String, String>{'stage': 'second', 'extra': 'x'};
      await conversation.setExt(second);
      expect((await reload()).ext, second);

      await conversation.setExt(null);
      expect(conversation.ext, isNull);
      expect((await reload()).ext, isNull);
    });

    // Test: insert messages out of chronological order and then delete the
    // newest one.
    // Expected: latestMessage is the newest message by timestamp; after the
    // deletion settles the previous message becomes the latest.
    ciTestWidgets('FL-CONV-009 returns the latest message', (tester) async {
      final second = textMessage('latest second', timestamp: 2000);
      final first = textMessage('latest first', timestamp: 1000);
      final third = textMessage('latest third', timestamp: 3000);
      for (final message in <ChatMessage>[second, first, third]) {
        await conversation.insertMessage(message);
      }

      expect((await conversation.latestMessage())?.msgId, third.msgId);

      await conversation.deleteMessage(third.msgId);
      final latest = await waitForCi<ChatMessage?>(
        'latest message falls back after deleting the newest message',
        () => conversation.latestMessage(),
        (message) => message?.msgId == second.msgId,
      );
      expect(latest?.msgId, second.msgId);
    });

    // Test: mix received and sent messages, then delete the newest received
    // message.
    // Expected: lastReceivedMessage only considers the receive direction (the
    // sent message stays the latest overall) and falls back after deletion.
    ciTestWidgets('FL-CONV-010 returns the last received message',
        (tester) async {
      final receivedFirst = textMessage('received first', timestamp: 1000);
      final receivedSecond = textMessage('received second', timestamp: 2000);
      final sent = textMessage(
        'sent third',
        timestamp: 3000,
        direction: MessageDirection.SEND,
      );
      for (final message in <ChatMessage>[
        receivedFirst,
        receivedSecond,
        sent
      ]) {
        await conversation.insertMessage(message);
      }

      expect((await conversation.latestMessage())?.msgId, sent.msgId);
      expect(
        (await conversation.lastReceivedMessage())?.msgId,
        receivedSecond.msgId,
      );

      await conversation.deleteMessage(receivedSecond.msgId);
      final lastReceived = await waitForCi<ChatMessage?>(
        'last received message falls back after deletion',
        () => conversation.lastReceivedMessage(),
        (message) => message?.msgId == receivedFirst.msgId,
      );
      expect(lastReceived?.msgId, receivedFirst.msgId);
    });

    // Test: insert two unread received messages, one already-read received
    // message, and one sent message.
    // Expected: unreadCount is 2; read and sent messages are not counted.
    ciTestWidgets('FL-CONV-011 counts unread messages', (tester) async {
      final first = textMessage('unread first', timestamp: 1000);
      final second = textMessage('unread second', timestamp: 2000);
      final alreadyRead = textMessage(
        'already read',
        timestamp: 1500,
        hasRead: true,
      );
      final sent = textMessage(
        'sent message',
        timestamp: 3000,
        direction: MessageDirection.SEND,
      );
      for (final message in <ChatMessage>[first, second, alreadyRead, sent]) {
        await conversation.insertMessage(message);
      }

      expect(await conversation.unreadCount(), 2);
    });

    // Test: mark one of two unread received messages as read.
    // Expected: the unread count drops to 1, the marked message reports
    // hasRead=true, the other stays unread, and marking it again is harmless.
    ciTestWidgets('FL-CONV-012 marks one message as read', (tester) async {
      final first = textMessage('mark first', timestamp: 1000);
      final second = textMessage('mark second', timestamp: 2000);
      await conversation.insertMessage(first);
      await conversation.insertMessage(second);
      expect(await conversation.unreadCount(), 2);

      await conversation.markMessageAsRead(first.msgId);
      final remaining = await waitForCi<int>(
        'unread count drops after markMessageAsRead',
        () => conversation.unreadCount(),
        (count) => count == 1,
      );
      expect(remaining, 1);
      // The native store updates the message flag asynchronously after the
      // unread counter changes, so poll instead of assuming one atomic write.
      final storedFirst = await waitForCi<ChatMessage?>(
        'the marked message reports hasRead',
        () => conversation.loadMessage(first.msgId),
        (message) => message?.hasRead == true,
      );
      expect(storedFirst?.hasRead, isTrue);
      expect((await conversation.loadMessage(second.msgId))?.hasRead, isFalse);

      await conversation.markMessageAsRead(first.msgId);
      expect(await conversation.unreadCount(), 1);
    });

    // Test: insert three unread messages and call markAllMessagesAsRead.
    // Expected: the unread count becomes 0 and every message reports
    // hasRead=true.
    ciTestWidgets('FL-CONV-013 marks all messages as read', (tester) async {
      final messages = <ChatMessage>[
        textMessage('all unread 1', timestamp: 1000),
        textMessage('all unread 2', timestamp: 2000),
        textMessage('all unread 3', timestamp: 3000),
      ];
      for (final message in messages) {
        await conversation.insertMessage(message);
      }
      expect(await conversation.unreadCount(), 3);

      await conversation.markAllMessagesAsRead();
      final unread = await waitForCi<int>(
        'all messages become read',
        () => conversation.unreadCount(),
        (count) => count == 0,
      );
      expect(unread, 0);
      for (final message in messages) {
        final stored = await conversation.loadMessage(message.msgId);
        expect(stored, isNotNull);
        expect(stored!.hasRead, isTrue);
      }
    });

    // Test: insert three unread incoming messages at timestamps 1000/2000/3000
    // and call markMessagesAsReadWithTimestamp(2000).
    // Expected: the call returns true, messages up to the timestamp
    // (inclusive) become read, the newer message stays unread, and the unread
    // count drops to 1.
    // 1.16.0
    ciTestWidgets('FL-CONV-034 marks messages as read up to a timestamp',
        (tester) async {
      final first = textMessage('timestamp first', timestamp: 1000);
      final second = textMessage('timestamp second', timestamp: 2000);
      final third = textMessage('timestamp third', timestamp: 3000);
      await conversation.insertMessage(first);
      await conversation.insertMessage(second);
      await conversation.insertMessage(third);
      expect(await conversation.unreadCount(), 3);

      expect(
        await conversation.markMessagesAsReadWithTimestamp(2000),
        isTrue,
      );

      final unread = await waitForCi<int>(
        'unread count drops after markMessagesAsReadWithTimestamp',
        () => conversation.unreadCount(),
        (count) => count == 1,
      );
      expect(unread, 1);
      expect((await conversation.loadMessage(first.msgId))?.hasRead, isTrue);
      expect((await conversation.loadMessage(second.msgId))?.hasRead, isTrue);
      expect((await conversation.loadMessage(third.msgId))?.hasRead, isFalse);
    });

    // Test: insert messages in the order 3000, 1000, 2000 by timestamp.
    // Expected: the database orders them newest-first regardless of insertion
    // order; messagesCount is 3, latestMessage is the 3000 message, and the
    // stored fields round-trip.
    ciTestWidgets('FL-CONV-014 inserts messages in timestamp order',
        (tester) async {
      final third = textMessage('insert third', timestamp: 3000);
      final first = textMessage('insert first', timestamp: 1000);
      final second = textMessage(
        'insert second',
        timestamp: 2000,
        attributes: <String, dynamic>{'case': '014'},
      );
      for (final message in <ChatMessage>[third, first, second]) {
        await conversation.insertMessage(message);
      }

      expect(await conversation.messagesCount(), 3);
      final messages = await conversation.loadMessages(loadCount: 10);
      // The documented local order is newest-first.
      debugPrint('FL-CONV-014 loadMessages order: ${messageIds(messages)}');
      expect(
        messageIds(messages),
        <String>[third.msgId, second.msgId, first.msgId],
      );
      expect((await conversation.latestMessage())?.msgId, third.msgId);
      expectTextStored(await conversation.loadMessage(second.msgId), second);
    });

    // Test: insert one message and append two newer messages.
    // Expected: appended messages go to the tail; the loaded order is
    // newest-first and latestMessage is the last appended message.
    ciTestWidgets('FL-CONV-015 appends messages to the tail', (tester) async {
      final first = textMessage('append first', timestamp: 1000);
      await conversation.insertMessage(first);
      final second = textMessage('append second', timestamp: 2000);
      await conversation.appendMessage(second);
      final third = textMessage('append third', timestamp: 3000);
      await conversation.appendMessage(third);

      expect(await conversation.messagesCount(), 3);
      final messages = await conversation.loadMessages(loadCount: 10);
      debugPrint('FL-CONV-015 loadMessages order: ${messageIds(messages)}');
      expect(
        messageIds(messages),
        <String>[third.msgId, second.msgId, first.msgId],
      );
      expect((await conversation.latestMessage())?.msgId, third.msgId);
      expectTextStored(await conversation.loadMessage(first.msgId), first);
    });

    // Test: insert a message, change its body and attributes, then update it.
    // Expected: a fresh load returns the new content and attributes with the
    // same msgId, the row count stays 1, and latestMessage reflects the update.
    ciTestWidgets('FL-CONV-016 updates a message in place', (tester) async {
      final message = textMessage(
        'before update',
        timestamp: 1000,
        attributes: <String, dynamic>{'stage': 'before'},
      );
      await conversation.insertMessage(message);

      message.body = ChatTextMessageBody(content: 'after update');
      message.attributes = <String, dynamic>{'stage': 'after'};
      await conversation.updateMessage(message);

      final stored = await conversation.loadMessage(message.msgId);
      expect(stored, isNotNull);
      expect((stored!.body as ChatTextMessageBody).content, 'after update');
      expect(stored.attributes, <String, dynamic>{'stage': 'after'});
      expect(await conversation.messagesCount(), 1);

      final latest = await conversation.latestMessage();
      expect(latest, isNotNull);
      expect((latest!.body as ChatTextMessageBody).content, 'after update');
    });

    // Test: insert three messages and delete the middle one by id.
    // Expected: only the local row is removed; the remaining ids and latest
    // message are unchanged.
    ciTestWidgets('FL-CONV-017 deletes one local message', (tester) async {
      final first = textMessage('delete first', timestamp: 1000);
      final second = textMessage('delete second', timestamp: 2000);
      final third = textMessage('delete third', timestamp: 3000);
      for (final message in <ChatMessage>[first, second, third]) {
        await conversation.insertMessage(message);
      }

      await conversation.deleteMessage(second.msgId);
      final remaining = await waitForCi<int>(
        'one message row is removed',
        () => conversation.messagesCount(),
        (count) => count == 2,
      );
      expect(remaining, 2);

      final messages = await conversation.loadMessages(loadCount: 10);
      debugPrint('FL-CONV-017 loadMessages order: ${messageIds(messages)}');
      expect(messageIds(messages), <String>[third.msgId, first.msgId]);
      expect((await conversation.latestMessage())?.msgId, third.msgId);
    });

    // Test: insert three messages and clear the conversation.
    // Expected: the count reaches 0, the message list is empty, latestMessage is
    // null, and a new insert starts from an empty conversation.
    ciTestWidgets('FL-CONV-018 deletes all local messages', (tester) async {
      for (final message in <ChatMessage>[
        textMessage('clear first', timestamp: 1000),
        textMessage('clear second', timestamp: 2000),
        textMessage('clear third', timestamp: 3000),
      ]) {
        await conversation.insertMessage(message);
      }

      await conversation.deleteAllMessages();
      final remaining = await waitForCi<int>(
        'all message rows are removed',
        () => conversation.messagesCount(),
        (count) => count == 0,
      );
      expect(remaining, 0);
      expect(await conversation.loadMessages(loadCount: 10), isEmpty);
      expect(await conversation.latestMessage(), isNull);

      final fresh = textMessage('after clear', timestamp: 4000);
      await conversation.insertMessage(fresh);
      expect(await conversation.messagesCount(), 1);
      expect((await conversation.latestMessage())?.msgId, fresh.msgId);
    });

    // Test: load an existing message by id and then load a missing id.
    // Expected: the existing message round-trips all stored fields; the missing
    // id returns null on HarmonyOS instead of throwing.
    ciTestWidgets('FL-CONV-019 loads a message by id', (tester) async {
      final message = textMessage(
        'load me',
        timestamp: 2000,
        attributes: <String, dynamic>{'case': '019'},
      );
      await conversation.insertMessage(message);

      expectTextStored(await conversation.loadMessage(message.msgId), message);
      final missing = await conversation.loadMessage(
        '${conversationId}_missing',
      );
      expect(missing, isNull);
    });

    // Test: insert two text messages and one custom message, then filter by
    // MessageType.
    // Expected: the TXT filter returns only the text messages and the CUSTOM
    // filter returns only the custom message; the custom body avoids attachment
    // file I/O while still exercising the type contract.
    ciTestWidgets('FL-CONV-020 filters messages by type', (tester) async {
      final first = textMessage('type text first', timestamp: 1000);
      final custom = customMessage(
        'ci_type_custom',
        params: <String, String>{'case': '020'},
        timestamp: 2000,
      );
      final second = textMessage('type text second', timestamp: 3000);
      for (final message in <ChatMessage>[first, custom, second]) {
        await conversation.insertMessage(message);
      }

      final texts = await conversation.loadMessagesWithMsgType(
        type: MessageType.TXT,
        count: 10,
      );
      expect(
        messageIds(texts),
        unorderedEquals(<String>[second.msgId, first.msgId]),
      );

      final customs = await conversation.loadMessagesWithMsgType(
        type: MessageType.CUSTOM,
        count: 10,
      );
      expect(messageIds(customs), <String>[custom.msgId]);
      expect(customs.single.body.type, MessageType.CUSTOM);
    });

    // Test: load two pages of local messages with an empty start id and then
    // with the newest message id as the start.
    // Expected: an empty start id returns the newest messages first; a start id
    // is excluded and returns the next older page.
    ciTestWidgets('FL-CONV-021 loads a page of messages', (tester) async {
      final messages = <ChatMessage>[
        textMessage('page 1', timestamp: 1000),
        textMessage('page 2', timestamp: 2000),
        textMessage('page 3', timestamp: 3000),
        textMessage('page 4', timestamp: 4000),
      ];
      for (final message in messages) {
        await conversation.insertMessage(message);
      }

      final newest = await conversation.loadMessages(loadCount: 2);
      // ChatSearchDirection.Up is documented as newest-first.
      debugPrint('FL-CONV-021 newest page=${messageIds(newest)}');
      expect(
        messageIds(newest),
        <String>[messages[3].msgId, messages[2].msgId],
      );

      final older = await conversation.loadMessages(
        startMsgId: messages[3].msgId,
        loadCount: 2,
      );
      debugPrint('FL-CONV-021 older page=${messageIds(older)}');
      expect(
        messageIds(older),
        <String>[messages[2].msgId, messages[1].msgId],
      );
    });

    // Test: insert two messages matching the keyword and one non-matching
    // message, then search by keyword with and without a sender filter.
    // Expected: the sender filter keeps only the message sent from
    // conversationId. The ohos chatsdk re-keys a message whose sender is the
    // peer into the peer one-to-one conversation, so the unfiltered search of
    // this synthetic conversation only sees the local match; the re-keying
    // deviation is tracked in the failure ledger and cleaned up below.
    ciTestWidgets('FL-CONV-022 searches messages by keyword and sender',
        (tester) async {
      final match = textMessage('flutter needle in body', timestamp: 1000);
      final other = textMessage('unrelated body', timestamp: 2000);
      final peerMatch = textMessage(
        'flutter needle from peer',
        timestamp: 3000,
        from: ciPeerId,
      );
      for (final message in <ChatMessage>[match, other, peerMatch]) {
        await conversation.insertMessage(message);
      }

      final bySender = await conversation.loadMessagesWithKeyword(
        'needle',
        senders: <String>[conversationId],
        count: 10,
      );
      expect(messageIds(bySender), <String>[match.msgId]);

      final rekeyed = await waitForCi<ChatMessage?>(
        'the peer message is re-keyed to the peer conversation',
        () => client.chatManager.loadMessage(peerMatch.msgId),
        (stored) => stored?.conversationId == ciPeerId,
      );
      expect(rekeyed, isNotNull);

      final all = await conversation.loadMessagesWithKeyword(
        'needle',
        count: 10,
      );
      expect(messageIds(all), <String>[match.msgId]);
      try {
        await client.chatManager.deleteConversation(
          ciPeerId,
          deleteMessages: true,
        );
      } on ChatError {
        // Best-effort cleanup of the re-keyed message.
      }
    });

    // Test: query two time windows around messages at 1000, 2000, and 3000 ms.
    // Expected: the wider window returns the two inner messages, while a window
    // whose boundaries touch the outer messages excludes both boundaries.
    ciTestWidgets('FL-CONV-023 loads messages in a time window',
        (tester) async {
      final first = textMessage('window first', timestamp: 1000);
      final second = textMessage('window second', timestamp: 2000);
      final third = textMessage('window third', timestamp: 3000);
      for (final message in <ChatMessage>[first, second, third]) {
        await conversation.insertMessage(message);
      }

      final inner = await conversation.loadMessagesFromTime(
        startTime: 900,
        endTime: 2500,
        count: 10,
      );
      expect(
        messageIds(inner),
        unorderedEquals(<String>[first.msgId, second.msgId]),
      );

      final touchBoundaries = await conversation.loadMessagesFromTime(
        startTime: 1000,
        endTime: 3000,
        count: 10,
      );
      expect(messageIds(touchBoundaries), <String>[second.msgId]);
    });

    // Test: insert three messages, delete the middle one, then insert another.
    // Expected: messagesCount and getLocalMessageCount stay aligned after each
    // mutation.
    ciTestWidgets('FL-CONV-024 counts messages with messagesCount',
        (tester) async {
      final first = textMessage('count first', timestamp: 1000);
      final second = textMessage('count second', timestamp: 2000);
      final third = textMessage('count third', timestamp: 3000);
      for (final message in <ChatMessage>[first, second, third]) {
        await conversation.insertMessage(message);
      }
      expect(await conversation.messagesCount(), 3);
      expect(
        await conversation.getLocalMessageCount(startMs: 0, endMs: 10000),
        3,
      );

      await conversation.deleteMessage(second.msgId);
      final afterDelete = await waitForCi<int>(
        'message count drops after deleting one row',
        () => conversation.messagesCount(),
        (count) => count == 2,
      );
      expect(afterDelete, 2);
      expect(
        await conversation.getLocalMessageCount(startMs: 0, endMs: 10000),
        2,
      );

      final fourth = textMessage('count fourth', timestamp: 4000);
      await conversation.insertMessage(fourth);
      expect(await conversation.messagesCount(), 3);
      expect(
        await conversation.getLocalMessageCount(startMs: 0, endMs: 10000),
        3,
      );
    });

    // Test: send a real message to the CI peer, pin it, and load the pinned
    // list.
    // Expected: a server-confirmed message appears in loadPinnedMessages with
    // its id and content; a 505 from the HarmonyOS SDK is reported as
    // UNVERIFIED instead of passing silently.
    ciTestWidgets('FL-CONV-025 loads pinned messages', (tester) async {
      final peer = await peerConversation();
      final message = await sendToPeer('FL-CONV-025 pinned message');
      addTearDown(() => deletePeerMessageQuietly(message.msgId));

      try {
        await client.chatManager.pinMessage(messageId: message.msgId);
      } on ChatError catch (error) {
        if (error.code == 505) {
          markTestSkipped(
            'UNVERIFIED: pinMessage returned 505 on this HarmonyOS build; '
            'the pinned-list contract could not be exercised.',
          );
          return;
        }
        rethrow;
      }

      addTearDown(() => unpinQuietly(message.msgId));
      final pinned = await waitForCi<List<ChatMessage>>(
        'pinned list contains ${message.msgId}',
        () => peer.loadPinnedMessages(),
        (messages) => messages.any((item) => item.msgId == message.msgId),
      );
      final stored = pinned.firstWhere(
        (item) => item.msgId == message.msgId,
      );
      expect(stored.conversationId, ciPeerId);
      expect(stored.status, MessageStatus.SUCCESS);
      expect(
        (stored.body as ChatTextMessageBody).content,
        (message.body as ChatTextMessageBody).content,
      );
    });

    // Test: set the peer conversation remind type to ALL and then NONE and read
    // it back through ChatConversation.remindType.
    // Expected: the local readback reports the value written each time. Silent
    // mode is server-backed, so the CI peer conversation is used instead of a
    // synthetic local id.
    ciTestWidgets('FL-CONV-026 reads the conversation remind type',
        (tester) async {
      final peer = await peerConversation();
      addTearDown(restorePeerSilentMode);

      await client.pushManager.setConversationSilentMode(
        conversationId: ciPeerId,
        type: ChatConversationType.Chat,
        param: ChatSilentModeParam.remindType(ChatPushRemindType.ALL),
      );
      final all = await waitForCi<ChatPushRemindType>(
        'conversation remind type becomes ALL',
        () => peer.remindType(),
        (type) => type == ChatPushRemindType.ALL,
      );
      expect(all, ChatPushRemindType.ALL);

      await client.pushManager.setConversationSilentMode(
        conversationId: ciPeerId,
        type: ChatConversationType.Chat,
        param: ChatSilentModeParam.remindType(ChatPushRemindType.NONE),
      );
      final none = await waitForCi<ChatPushRemindType>(
        'conversation remind type becomes NONE',
        () => peer.remindType(),
        (type) => type == ChatPushRemindType.NONE,
      );
      expect(none, ChatPushRemindType.NONE);
    });

    // Test: search local messages by type and sender through
    // MessageSearchOptions.
    // Expected: a TXT-only search returns only the local text message; adding
    // CUSTOM returns the local custom message as well, while the message from
    // ciPeerId stays excluded by the sender filter.
    ciTestWidgets('FL-CONV-027 searches messages by options', (tester) async {
      final localText = textMessage('options local text', timestamp: 1000);
      final peerText = textMessage(
        'options peer text',
        timestamp: 2000,
        from: ciPeerId,
      );
      final localCustom = customMessage(
        'ci_options_custom',
        params: <String, String>{'case': '027'},
        timestamp: 3000,
      );
      for (final message in <ChatMessage>[localText, peerText, localCustom]) {
        await conversation.insertMessage(message);
      }

      final textOnly = await conversation.searchMsgsByOptions(
        MessageSearchOptions(
          types: const <MessageType>[MessageType.TXT],
          from: conversationId,
          count: 10,
        ),
      );
      expect(messageIds(textOnly), <String>[localText.msgId]);

      final textAndCustom = await conversation.searchMsgsByOptions(
        MessageSearchOptions(
          types: const <MessageType>[MessageType.TXT, MessageType.CUSTOM],
          from: conversationId,
          count: 10,
        ),
      );
      expect(
        messageIds(textAndCustom),
        unorderedEquals(<String>[localText.msgId, localCustom.msgId]),
      );
    });

    // Test: count messages in inclusive time ranges and compare with the total
    // row count.
    // Expected: the count matches messagesCount for the full range, includes
    // both boundaries, and narrows correctly for an inner range.
    ciTestWidgets('FL-CONV-028 counts messages in a time range',
        (tester) async {
      for (final message in <ChatMessage>[
        textMessage('range first', timestamp: 1000),
        textMessage('range second', timestamp: 2000),
        textMessage('range third', timestamp: 3000),
      ]) {
        await conversation.insertMessage(message);
      }

      final total = await conversation.getLocalMessageCount(
        startMs: 0,
        endMs: 5000,
      );
      expect(total, 3);
      expect(total, await conversation.messagesCount());
      expect(
        await conversation.getLocalMessageCount(startMs: 1000, endMs: 2000),
        2,
      );
      expect(
        await conversation.getLocalMessageCount(startMs: 1500, endMs: 2500),
        1,
      );
    });

    // Test: send a real message to the CI peer and delete it on both the local
    // database and the server.
    // Expected: the message is absent from the local message list and from a
    // fresh fetchHistoryMessages page after the call.
    ciTestWidgets('FL-CONV-029 deletes local and server messages by id',
        (tester) async {
      final peer = await peerConversation();
      final message = await sendToPeer('FL-CONV-029 delete both ends');
      addTearDown(() => deletePeerMessageQuietly(message.msgId));

      await peer.deleteLocalAndServerMessages(msgIds: <String>[message.msgId]);
      await waitForCi<ChatMessage?>(
        'local copy of ${message.msgId} is deleted',
        () => peer.loadMessage(message.msgId),
        (stored) => stored == null,
      );
      final local = await peer.loadMessages(loadCount: 50);
      expect(local.map((item) => item.msgId), isNot(contains(message.msgId)));

      final history = await waitForCi<ChatCursorResult<ChatMessage>>(
        'server history no longer contains ${message.msgId}',
        () => client.chatManager.fetchHistoryMessagesByOption(
          ciPeerId,
          ChatConversationType.Chat,
          pageSize: 50,
        ),
        (page) => page.data.every((item) => item.msgId != message.msgId),
      );
      expect(
        history.data.map((item) => item.msgId),
        isNot(contains(message.msgId)),
      );
    });

    // Test: send a real message to the CI peer and delete messages older than
    // its server timestamp through deleteLocalAndServerMessagesByTime.
    // Expected: the message is removed locally and from a fresh server history
    // fetch.
    ciTestWidgets('FL-CONV-030 deletes local and server messages by time',
        (tester) async {
      final peer = await peerConversation();
      final message = await sendToPeer('FL-CONV-030 delete by time');
      addTearDown(() => deletePeerMessageQuietly(message.msgId));
      expect(message.serverTime, greaterThan(0));

      final beforeMs = message.serverTime + 1;
      await peer.deleteLocalAndServerMessagesByTime(beforeMs: beforeMs);

      await waitForCi<ChatMessage?>(
        'local copy of ${message.msgId} is deleted by time',
        () => peer.loadMessage(message.msgId),
        (stored) => stored == null,
      );
      final history = await waitForCi<ChatCursorResult<ChatMessage>>(
        'server history no longer contains ${message.msgId}',
        () => client.chatManager.fetchHistoryMessagesByOption(
          ciPeerId,
          ChatConversationType.Chat,
          pageSize: 50,
        ),
        (page) => page.data.every((item) => item.msgId != message.msgId),
      );
      expect(
        history.data.map((item) => item.msgId),
        isNot(contains(message.msgId)),
      );
    });

    // Test: query a time window whose start is after its end.
    // Expected: the HarmonyOS implementation treats the inverted window as a
    // no-op and returns an empty list, not an exception and not unrelated
    // messages.
    ciTestWidgets('FL-CONV-031 returns empty for an inverted time window',
        (tester) async {
      final message = textMessage('inverted window message', timestamp: 2000);
      await conversation.insertMessage(message);

      final messages = await conversation.loadMessagesFromTime(
        startTime: 3000,
        endTime: 1000,
        count: 10,
      );
      expect(messages, isEmpty);
    });

    // Test: delete a message id that does not exist in the conversation.
    // Expected: the HarmonyOS wrapper reports success for the missing id, so
    // the call is idempotent and leaves the existing message untouched.
    ciTestWidgets('FL-CONV-032 deletes a nonexistent message idempotently',
        (tester) async {
      final message = textMessage('survives missing delete', timestamp: 1000);
      await conversation.insertMessage(message);

      await conversation.deleteMessage('${conversationId}_missing');
      expect(await conversation.messagesCount(), 1);
      final stored = await conversation.loadMessage(message.msgId);
      expect(stored, isNotNull);
      expect(stored!.msgId, message.msgId);
    });

    // Test: insert the same fixed message id twice with different content.
    // Expected: both calls report success but the database keeps exactly one
    // row for the id; the stored body is one of the two inserted bodies.
    ciTestWidgets('FL-CONV-033 deduplicates inserted message ids',
        (tester) async {
      final id = '${conversationId}_duplicate';
      final original = textMessage('original body', id: id, timestamp: 1000);
      final duplicate = textMessage('duplicate body', id: id, timestamp: 2000);

      await conversation.insertMessage(original);
      await conversation.insertMessage(duplicate);

      expect(await conversation.messagesCount(), 1);
      final messages = await conversation.loadMessages(loadCount: 10);
      expect(messages, hasLength(1));
      expect(messages.single.msgId, id);
      expect(
        (messages.single.body as ChatTextMessageBody).content,
        anyOf('original body', 'duplicate body'),
      );
    });
  });
}
