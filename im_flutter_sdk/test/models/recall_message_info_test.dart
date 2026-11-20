import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

void main() {
  group('RecallMessageInfo JSON contract', () {
    test('native field names and nested message decode correctly', () {
      final info = RecallMessageInfo.fromJson({
        'recallMsgId': 'server-message',
        'recallBy': 'alice',
        'convId': 'alice',
        'msg': {
          'msgId': 'server-message',
          'from': 'alice',
          'to': 'bob',
          'body': {'type': 0, 'content': 'original text'},
          'attributes': {'marker': 'this-run'},
        },
        'ext': 'recall-this-run',
      });

      expect(info.recallMessageId, 'server-message');
      expect(info.recallBy, 'alice');
      expect(info.conversationId, 'alice');
      expect(info.ext, 'recall-this-run');
      expect(info.recallMessage!.msgId, 'server-message');
      expect(info.recallMessage!.from, 'alice');
      expect(info.recallMessage!.to, 'bob');
      expect(info.recallMessage!.attributes, {'marker': 'this-run'});
      expect((info.recallMessage!.body as ChatTextMessageBody).content,
          'original text');
    });

    test('offline recall without an original message retains null fields', () {
      final info = RecallMessageInfo.fromJson({
        'recallMsgId': 'server-message',
        'recallBy': 'alice',
      });

      expect(info.recallMessage, isNull);
      expect(info.conversationId, isNull);
      expect(info.ext, isNull);
    });

    test('empty extension and conversation ID are not converted to null', () {
      const info = RecallMessageInfo(
        recallMessageId: 'server-message',
        recallBy: 'alice',
        conversationId: '',
        ext: '',
      );

      expect(info.conversationId, '');
      expect(info.ext, '');
    });
  });
}
