import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

void main() {
  group('RecallMessageInfo JSON contract', () {
    test('native field names and nested message survive a JSON round trip', () {
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

      final encoded = jsonDecode(jsonEncode(info)) as Map;
      expect(encoded.keys,
          unorderedEquals(['recallMsgId', 'recallBy', 'convId', 'msg', 'ext']));
      expect(encoded['recallMsgId'], 'server-message');
      expect(encoded['recallBy'], 'alice');
      expect(encoded['convId'], 'alice');
      expect(encoded['ext'], 'recall-this-run');
      expect(encoded['msg']['msgId'], 'server-message');
      expect(encoded['msg']['body']['content'], 'original text');

      final restored = RecallMessageInfo.fromJson(encoded);
      expect(restored.recallMessageId, 'server-message');
      expect(restored.recallBy, 'alice');
      expect(restored.conversationId, 'alice');
      expect(restored.ext, 'recall-this-run');
      expect(restored.recallMessage!.msgId, 'server-message');
      expect(restored.recallMessage!.from, 'alice');
      expect(restored.recallMessage!.to, 'bob');
      expect(restored.recallMessage!.attributes, {'marker': 'this-run'});
      expect((restored.recallMessage!.body as ChatTextMessageBody).content,
          'original text');
    });

    test('offline recall without an original message retains null fields', () {
      final info = RecallMessageInfo.fromJson({
        'recallMsgId': 'server-message',
        'recallBy': 'alice',
      });
      final encoded = jsonDecode(jsonEncode(info)) as Map;
      expect(encoded, {
        'recallMsgId': 'server-message',
        'recallBy': 'alice',
        'convId': null,
        'msg': null,
        'ext': null,
      });
      final restored = RecallMessageInfo.fromJson(encoded);
      expect(restored.recallMessage, isNull);
      expect(restored.conversationId, isNull);
      expect(restored.ext, isNull);
    });

    test('empty extension and conversation ID are not converted to null', () {
      const info = RecallMessageInfo(
        recallMessageId: 'server-message',
        recallBy: 'alice',
        conversationId: '',
        ext: '',
      );
      final restored = RecallMessageInfo.fromJson(
        jsonDecode(jsonEncode(info)) as Map,
      );
      expect(restored.conversationId, '');
      expect(restored.ext, '');
    });
  });
}
