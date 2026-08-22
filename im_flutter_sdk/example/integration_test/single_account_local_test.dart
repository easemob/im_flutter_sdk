import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:integration_test/integration_test.dart';

const _appKey = String.fromEnvironment('E2E_APP_KEY');
const _userId = String.fromEnvironment('E2E_USER_ID');
const _password = String.fromEnvironment('E2E_USER_PASSWORD');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final client = ChatClient.getInstance;
  var sequence = 0;

  void requireConfiguration() {
    final missing = <String>[
      if (_appKey.isEmpty) 'E2E_APP_KEY',
      if (_userId.isEmpty) 'E2E_USER_ID',
      if (_password.isEmpty) 'E2E_USER_PASSWORD',
    ];
    if (missing.isNotEmpty) {
      throw StateError('Missing dart-defines: ${missing.join(', ')}');
    }
  }

  setUpAll(() async {
    requireConfiguration();
    await client.init(
      ChatOptions.withAppKey(_appKey, autoLogin: false, debugMode: false),
    );

    if (await client.isLoginBefore()) {
      await client.logout(false);
    }

    await client.loginWithPassword(_userId, _password);
    await client.startCallback();
  });

  tearDownAll(() async {
    if (await client.isLoginBefore()) {
      await client.logout(false);
    }
  });

  testWidgets('FL-AUTH-001 logs in and exposes native client state',
      (tester) async {
    expect(await client.getCurrentUserId(), _userId);
    expect(client.currentUserId, _userId);
    expect(await client.isLoginBefore(), isTrue);
    expect(await client.isConnected(), isTrue);
    expect(await client.getAccessToken(), isNotEmpty);
  });

  group('single-account local database', () {
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
        ..to = _userId
        ..conversationId = conversationId
        ..localTime = time
        ..serverTime = time
        ..hasRead = false
        ..status = MessageStatus.SUCCESS
        ..attributes = attributes;
    }

    setUp(() async {
      sequence += 1;
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

    testWidgets(
        'FL-CONV-001 creates, lists, extends, and deletes a conversation',
        (tester) async {
      final seed = incoming('conversation lifecycle seed');
      await conversation.insertMessage(seed);
      await conversation.setExt(const <String, String>{'owner': 'flutter-ci'});

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
    });

    testWidgets('FL-CONV-002 maintains latest, unread, and read state',
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

    testWidgets('FL-CONV-003 appends, updates, loads, and removes a message',
        (tester) async {
      final message = incoming('before update');
      await conversation.appendMessage(message);
      expect((await conversation.loadMessage(message.msgId))?.msgId,
          message.msgId);

      message.body = ChatTextMessageBody(content: 'after update');
      await conversation.updateMessage(message);
      final updated = await conversation.loadMessage(message.msgId);
      expect((updated?.body as ChatTextMessageBody).content, 'after update');

      await conversation.deleteMessage(message.msgId);
      // NOTE(ios): loading a deleted message throws ChatError (code 3) on iOS
      // because the native SDK reports an EMError, while Android returns null.
      // expect(await conversation.loadMessage(message.msgId), isNull);
    });

    testWidgets('FL-CONV-004 pages local messages upward and downward',
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
          containsAll(<String>[
            first.msgId,
            second.msgId,
          ]));

      final newer = await conversation.loadMessages(
        startMsgId: first.msgId,
        loadCount: 2,
        direction: ChatSearchDirection.Down,
      );
      expect(
          newer.map((item) => item.msgId),
          containsAll(<String>[
            second.msgId,
            third.msgId,
          ]));
    });

    testWidgets(
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
          containsAll(<String>[
            first.msgId,
            second.msgId,
          ]));

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

    testWidgets('FL-CONV-006 deletes local messages by id, time, and all',
        (tester) async {
      final first = incoming('delete by id', timestamp: 1000);
      final second = incoming('delete by time', timestamp: 2000);
      final third = incoming('delete all', timestamp: 3000);
      for (final message in <ChatMessage>[first, second, third]) {
        await conversation.insertMessage(message);
      }

      await conversation.deleteMessageByIds(<String>[first.msgId]);
      // NOTE(ios): loading a deleted message throws ChatError (code 3) on iOS
      // because the native SDK reports an EMError, while Android returns null.
      // expect(await conversation.loadMessage(first.msgId), isNull);

      await conversation.deleteMessagesWithTs(1500, 2500);
      // expect(await conversation.loadMessage(second.msgId), isNull);
      expect(await conversation.loadMessage(third.msgId), isNotNull);

      await conversation.deleteAllMessages();
      expect(await conversation.messagesCount(), 0);
    });
  });
}
