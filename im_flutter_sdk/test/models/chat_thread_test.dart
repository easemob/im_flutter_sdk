import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

void main() {
  group('ChatThread JSON contract', () {
    test('round trip preserves all fields', () {
      final lastMessage = ChatMessage.createTxtSendMessage(
        targetId: 'group-id',
        content: 'reply',
      );
      final thread = ChatThread(
        threadId: 'thread-id',
        threadName: 'topic',
        owner: 'owner-id',
        messageId: 'message-id',
        parentId: 'group-id',
        membersCount: 2,
        messageCount: 3,
        createAt: 1234,
        lastMessage: lastMessage,
      );

      final json = thread.toJson();
      expect(json, <String, dynamic>{
        'threadId': 'thread-id',
        'threadName': 'topic',
        'owner': 'owner-id',
        'msgId': 'message-id',
        'parentId': 'group-id',
        'memberCount': 2,
        'messageCount': 3,
        'createAt': 1234,
        'lastMessage': lastMessage.toJson(),
      });

      final decoded = ChatThread.fromJson(json);
      expect(decoded.threadId, thread.threadId);
      expect(decoded.threadName, thread.threadName);
      expect(decoded.owner, thread.owner);
      expect(decoded.messageId, thread.messageId);
      expect(decoded.parentId, thread.parentId);
      expect(decoded.membersCount, thread.membersCount);
      expect(decoded.messageCount, thread.messageCount);
      expect(decoded.createAt, thread.createAt);
      expect(
        (decoded.lastMessage!.body as ChatTextMessageBody).content,
        'reply',
      );
    });

    test('omits null optional fields and remains decodable', () {
      final thread = ChatThread(
        threadId: 'thread-id',
        owner: null,
        messageId: 'message-id',
        parentId: 'group-id',
        membersCount: 0,
        messageCount: 0,
        createAt: 1234,
      );

      final json = thread.toJson();
      expect(json, isNot(contains('threadName')));
      expect(json, isNot(contains('owner')));
      expect(json, isNot(contains('lastMessage')));
      expect(ChatThread.fromJson(json).owner, isNull);
    });
  });
}
