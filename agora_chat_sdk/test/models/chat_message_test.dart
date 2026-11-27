import 'package:flutter_test/flutter_test.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';

void main() {
  group('ChatMessage JSON contract', () {
    test('image round trip uses secret and drops legacy thumbnailSecret', () {
      final message = ChatMessage.fromJson({
        'msgId': 'image-secret-contract',
        'from': 'sender',
        'to': 'receiver',
        'chatType': ChatType.Chat.index,
        'direction': MessageDirection.RECEIVE.index,
        'body': {
          'type': MessageType.IMAGE.index,
          'localPath': '/tmp/image.png',
          'secret': 'image-original-secret',
          'thumbnailSecret': 'obsolete-image-thumbnail-secret',
        },
      });

      expect((message.body as ChatImageMessageBody).secret,
          'image-original-secret');
      final bodyJson = message.toJson()['body'] as Map;
      expect(bodyJson['secret'], 'image-original-secret');
      expect(bodyJson.containsKey('thumbnailSecret'), isFalse);
      final decoded = ChatMessage.fromJson(message.toJson());
      expect((decoded.body as ChatImageMessageBody).secret,
          'image-original-secret');
    });

    test('video round trip keeps distinct original and thumbnail secrets', () {
      final message = ChatMessage.fromJson({
        'msgId': 'video-secret-contract',
        'from': 'sender',
        'to': 'receiver',
        'chatType': ChatType.Chat.index,
        'direction': MessageDirection.RECEIVE.index,
        'body': {
          'type': MessageType.VIDEO.index,
          'localPath': '/tmp/video.mp4',
          'duration': 1,
          'secret': 'video-original-secret',
          'thumbnailSecret': 'video-thumbnail-secret',
        },
      });

      final bodyJson = message.toJson()['body'] as Map;
      expect(bodyJson['secret'], 'video-original-secret');
      expect(bodyJson['thumbnailSecret'], 'video-thumbnail-secret');
      final decoded = ChatMessage.fromJson(message.toJson());
      final body = decoded.body as ChatVideoMessageBody;
      expect(body.secret, 'video-original-secret');
      expect(body.thumbnailSecret, 'video-thumbnail-secret');
    });

    test('text message round trip preserves routing and content', () {
      final message =
          ChatMessage.createTxtSendMessage(targetId: 'receiver', content: 'hello')
            ..attributes = <String, Object>{'trace': 'unit'}
            ..deliverOnlineOnly = true;

      final decoded = ChatMessage.fromJson(message.toJson());

      expect(decoded.to, 'receiver');
      expect(decoded.conversationId, 'receiver');
      expect(decoded.direction, MessageDirection.SEND);
      expect(decoded.body, isA<ChatTextMessageBody>());
      expect((decoded.body as ChatTextMessageBody).content, 'hello');
      expect(decoded.attributes, <String, Object>{'trace': 'unit'});
      expect(decoded.deliverOnlineOnly, isTrue);
    });

    test('all locally constructible message types keep their body type', () {
      final messages = <ChatMessage>[
        ChatMessage.createTxtSendMessage(targetId: 'u', content: 'text'),
        ChatMessage.createLocationSendMessage(
          targetId: 'u',
          latitude: 1.5,
          longitude: 2.5,
          address: 'address',
        ),
        ChatMessage.createCmdSendMessage(action: 'action', targetId: 'u'),
        ChatMessage.createCustomSendMessage(
          targetId: 'u',
          event: 'event',
          params: <String, String>{'key': 'value'},
        ),
        ChatMessage.createFileSendMessage(targetId: 'u', filePath: '/tmp/a'),
        ChatMessage.createImageSendMessage(targetId: 'u', filePath: '/tmp/a'),
        ChatMessage.createVoiceSendMessage(
          targetId: 'u',
          filePath: '/tmp/a',
          duration: 2,
        ),
        ChatMessage.createVideoSendMessage(
          targetId: 'u',
          filePath: '/tmp/a',
          duration: 3,
        ),
        ChatMessage.createCombineSendMessage(
          targetId: 'u',
          title: 'title',
          summary: 'summary',
          compatibleText: 'fallback',
          msgIds: <String>['m1'],
        ),
      ];

      for (final message in messages) {
        final decoded = ChatMessage.fromJson(message.toJson());
        expect(decoded.body.runtimeType, message.body.runtimeType);
        expect(decoded.chatType, ChatType.Chat);
        expect(decoded.direction, MessageDirection.SEND);
      }
    });

    test('received message round trip preserves unread state and sender', () {
      final message = ChatMessage.createReceiveMessage(
        body: ChatTextMessageBody(content: 'incoming'),
      )
        ..from = 'sender'
        ..to = 'current-user'
        ..conversationId = 'sender';

      final decoded = ChatMessage.fromJson(message.toJson());

      expect(decoded.from, 'sender');
      expect(decoded.to, 'current-user');
      expect(decoded.conversationId, 'sender');
      expect(decoded.direction, MessageDirection.RECEIVE);
      expect(decoded.isRead, isFalse);
    });
  });
}
