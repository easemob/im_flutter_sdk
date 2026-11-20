import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

void main() {
  group('ChatThread JSON contract', () {
    test('reads all native fields including the nested last message', () {
      final thread = ChatThread.fromJson(<String, dynamic>{
        'threadId': 'thread-id',
        'threadName': 'topic',
        'owner': 'owner-id',
        'msgId': 'message-id',
        'parentId': 'group-id',
        'memberCount': 2,
        'messageCount': 3,
        'createAt': 1234,
        'lastMessage': <String, dynamic>{
          'msgId': 'message-id',
          'from': 'owner-id',
          'to': 'group-id',
          'body': <String, dynamic>{'type': 0, 'content': 'reply'},
        },
      });

      expect(thread.threadId, 'thread-id');
      expect(thread.threadName, 'topic');
      expect(thread.owner, 'owner-id');
      expect(thread.messageId, 'message-id');
      expect(thread.parentId, 'group-id');
      expect(thread.membersCount, 2);
      expect(thread.messageCount, 3);
      expect(thread.createAt, 1234);
      expect(
        (thread.lastMessage!.body as ChatTextMessageBody).content,
        'reply',
      );
    });

    test('optional fields stay null when native omits them', () {
      final thread = ChatThread.fromJson(<String, dynamic>{
        'threadId': 'thread-id',
        'owner': 'owner-id',
        'msgId': 'message-id',
        'parentId': 'group-id',
        'memberCount': 0,
        'messageCount': 0,
        'createAt': 1234,
      });

      expect(thread.threadName, isNull);
      expect(thread.lastMessage, isNull);
    });
  });
}
