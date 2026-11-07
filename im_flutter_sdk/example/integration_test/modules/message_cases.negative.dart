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
  // Test: Send text to a nonempty recipient while logged out, with the message
  // listener registered before sending and correlated by the local message ID.
  // Expected: onError reports ChatError 201 and preserves the recipient.
  // The retained FAIL status assertion is pending contract confirmation;
  // SDK 5.0.0 was observed to return PROGRESS on both Android and iOS.
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

  // Test: Send text to an empty recipient while logged in, with a listener
  // registered before sending and correlated by the local message ID.
  // Expected: onError reports ChatError 500 and preserves the empty recipient.
  // The retained FAIL status assertion is pending contract confirmation;
  // SDK 5.0.0 was observed to return PROGRESS on both Android and iOS.
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

  // Test: In a conversation with one stored message, read a missing ID alone
  // and mixed with the stored ID using loadMessage/loadMessagesWithIds.
  // Expected: Missing-only reads return null/empty; the mixed read returns only
  // the stored ID/content, and the conversation still contains one message.
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

  // Test: With one stored local message, call ChatManager.updateMessage for a
  // different message that has never been persisted.
  // Expected: ChatError 500; the missing ID remains absent, the count stays one,
  // and the stored message keeps its original ID/content.
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
