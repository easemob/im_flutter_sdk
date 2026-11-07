import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../support/ci_test.dart';

Future<void> _expectSendError(
    ChatClient client, ChatMessage message, int code) async {
  final manager = client.chatManager;
  final localId = message.msgId;
  final handlerId = 'ci_negative_send_${DateTime.now().microsecondsSinceEpoch}';
  final completion = Completer<({ChatMessage message, ChatError? error})>();
  manager.addMessageEvent(
    handlerId,
    ChatMessageEvent(
      onSuccess: (id, sent) {
        if (id == localId && !completion.isCompleted) {
          completion.complete((message: sent, error: null));
        }
      },
      onError: (id, failed, error) {
        if (id == localId && !completion.isCompleted) {
          completion.complete((message: failed, error: error));
        }
      },
    ),
  );
  addTearDown(() => manager.removeMessageEvent(handlerId));
  // The method return only acknowledges submission. A missing callback or a
  // synchronous method error does not satisfy this callback contract.
  await manager.sendMessage(message).timeout(const Duration(seconds: 30));
  final result = await completion.future.timeout(const Duration(seconds: 30));
  debugPrint('CI negative send callback: localId=$localId '
      'errorCode=${result.error?.code} status=${result.message.status.name}');
  expect(result.error,
      isA<ChatError>().having((error) => error.code, 'code', code));
  expect(result.message.status, MessageStatus.FAIL);
  expect(result.message.to, message.to);
}

void registerLoggedOutMessageNegativeCases({required ChatClient client}) {
  ciTestWidgets(
      'FL-MSG-006 negative send reports not logged in through callback',
      (_) async {
    expect(await client.getCurrentUserId(), isNull);
    await _expectSendError(
      client,
      ChatMessage.createTxtSendMessage(
          targetId: 'flutter-ci-peer', content: 'must not be sent'),
      201,
    );
  });
}

void registerMessageNegativeCases({
  required ChatClient client,
  required String userId,
}) {
  final manager = client.chatManager;

  Future<(ChatConversation, ChatMessage, ChatMessage)> prepare() async {
    final id = 'ci_msg_negative_${DateTime.now().microsecondsSinceEpoch}';
    addTearDown(() async {
      await manager.deleteConversation(id, deleteMessages: true);
      expect(await manager.getConversation(id, createIfNeed: false), isNull);
    });
    ChatMessage message(String suffix) {
      final draft =
          ChatMessage.createTxtSendMessage(targetId: id, content: suffix)
            ..from = userId
            ..conversationId = id
            ..status = MessageStatus.SUCCESS
            ..localTime = 1000
            ..serverTime = 1000;
      return ChatMessage.fromJson(
          {...draft.toJson(), 'msgId': '${id}_$suffix'});
    }

    final stored = message('stored');
    final absent = message('absent');
    final conversation = await manager.getConversation(id, createIfNeed: true);
    expect(conversation, isNotNull);
    await conversation!.insertMessage(stored);
    expect((await manager.loadMessage(stored.msgId))?.msgId, stored.msgId);
    expect(await conversation.messagesCount(), 1);
    return (conversation, stored, absent);
  }

  ciTestWidgets(
      'FL-MSG-007 negative send rejects an empty recipient in callback',
      (_) async {
    expect(await client.getCurrentUserId(), userId);
    await _expectSendError(
      client,
      ChatMessage.createTxtSendMessage(
          targetId: '', content: 'must not be sent'),
      500,
    );
  });

  ciTestWidgets(
      'FL-MSG-008 negative missing IDs do not return unrelated messages',
      (_) async {
    final (conversation, stored, absent) = await prepare();
    expect(await manager.loadMessage(absent.msgId), isNull);
    expect(await manager.loadMessagesWithIds([absent.msgId], conversation.id),
        isEmpty);
    final mixed = await manager
        .loadMessagesWithIds([absent.msgId, stored.msgId], conversation.id);
    expect(mixed.map((message) => message.msgId), [stored.msgId]);
    expect((mixed.single.body as ChatTextMessageBody).content, 'stored');
    expect(await conversation.messagesCount(), 1);
  });

  ciTestWidgets('FL-MSG-009 negative update cannot insert a missing message',
      (_) async {
    final (conversation, stored, absent) = await prepare();
    expect(await manager.loadMessage(absent.msgId), isNull);
    await expectCiError(() => manager.updateMessage(absent), 500);
    expect(await manager.loadMessage(absent.msgId), isNull);
    expect(await conversation.messagesCount(), 1);
    final remaining = await manager.loadMessage(stored.msgId);
    expect(remaining?.msgId, stored.msgId);
    expect((remaining!.body as ChatTextMessageBody).content, 'stored');
  });
}
