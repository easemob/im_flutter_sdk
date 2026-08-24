import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_test/bridge/event_router.dart';

void main() {
  group('EventRouter native list normalization', () {
    test('names recalled messages as messages', () {
      final event = EventRouter.normalizeNativeEvent('onMessagesRecalled', [
        {
          'msgId': 'message-1',
          'body': {'type': 0, 'content': 'recalled'},
        },
      ]);

      expect(event['eventType'], 'onMessagesRecalled');
      expect((event['data'] as Map<String, dynamic>)['messages'], hasLength(1));
    });

    test('names recalled metadata as infos', () {
      final event = EventRouter.normalizeNativeEvent('onMessagesRecalledInfo', [
        {'recallMsgId': 'message-1', 'recallBy': 'alice'},
      ]);

      expect(event['eventType'], 'onMessagesRecalledInfo');
      expect((event['data'] as Map<String, dynamic>)['infos'], [
        {'recallMsgId': 'message-1', 'recallBy': 'alice'},
      ]);
    });

    test('names reaction changes as events', () {
      final event =
          EventRouter.normalizeNativeEvent('messageReactionDidChange', [
        {'msgId': 'message-1', 'operations': []},
      ]);

      expect((event['data'] as Map<String, dynamic>)['events'], hasLength(1));
    });

    test('names group read receipts as acks', () {
      final event = EventRouter.normalizeNativeEvent('onGroupMessageRead', [
        {'msgId': 'message-1', 'from': 'alice'},
      ]);

      expect((event['data'] as Map<String, dynamic>)['acks'], hasLength(1));
    });
  });
}
