import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

void main() {
  group('EMMessage JSON contract', () {
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
          EMMessage.createTxtSendMessage(targetId: 'receiver', content: 'hello')
            ..attributes = <String, Object>{'trace': 'unit'}
            ..deliverOnlineOnly = true;

      final decoded = EMMessage.fromJson(message.toJson());

      expect(decoded.to, 'receiver');
      expect(decoded.conversationId, 'receiver');
      expect(decoded.direction, MessageDirection.SEND);
      expect(decoded.body, isA<EMTextMessageBody>());
      expect((decoded.body as EMTextMessageBody).content, 'hello');
      expect(decoded.attributes, <String, Object>{'trace': 'unit'});
      expect(decoded.deliverOnlineOnly, isTrue);
    });

    test('all locally constructible message types keep their body type', () {
      final messages = <EMMessage>[
        EMMessage.createTxtSendMessage(targetId: 'u', content: 'text'),
        EMMessage.createLocationSendMessage(
          targetId: 'u',
          latitude: 1.5,
          longitude: 2.5,
          address: 'address',
        ),
        EMMessage.createCmdSendMessage(action: 'action', targetId: 'u'),
        EMMessage.createCustomSendMessage(
          targetId: 'u',
          event: 'event',
          params: <String, String>{'key': 'value'},
        ),
        EMMessage.createFileSendMessage(targetId: 'u', filePath: '/tmp/a'),
        EMMessage.createImageSendMessage(targetId: 'u', filePath: '/tmp/a'),
        EMMessage.createVoiceSendMessage(
          targetId: 'u',
          filePath: '/tmp/a',
          duration: 2,
        ),
        EMMessage.createVideoSendMessage(
          targetId: 'u',
          filePath: '/tmp/a',
          duration: 3,
        ),
        EMMessage.createCombineSendMessage(
          targetId: 'u',
          title: 'title',
          summary: 'summary',
          compatibleText: 'fallback',
          msgIds: <String>['m1'],
        ),
      ];

      for (final message in messages) {
        final decoded = EMMessage.fromJson(message.toJson());
        expect(decoded.body.runtimeType, message.body.runtimeType);
        expect(decoded.chatType, ChatType.Chat);
        expect(decoded.direction, MessageDirection.SEND);
      }
    });

    test('received message round trip preserves unread state and sender', () {
      final message = EMMessage.createReceiveMessage(
        body: EMTextMessageBody(content: 'incoming'),
      )
        ..from = 'sender'
        ..to = 'current-user'
        ..conversationId = 'sender';

      final decoded = EMMessage.fromJson(message.toJson());

      expect(decoded.from, 'sender');
      expect(decoded.to, 'current-user');
      expect(decoded.conversationId, 'sender');
      expect(decoded.direction, MessageDirection.RECEIVE);
      expect(decoded.isRead, isFalse);
    });
  });
}
