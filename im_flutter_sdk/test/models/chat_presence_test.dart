import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

void main() {
  group('ChatPresence JSON contract', () {
    test('native payload decodes into the typed fields', () {
      final restored = ChatPresence.fromJson({
        'publisher': 'user-b',
        'statusDescription': 'busy',
        'lastTime': 1700000000,
        'expiryTime': 1700003600,
        'statusDetails': {'android': 1, 'ios': 0},
      });

      expect(restored.publisher, 'user-b');
      expect(restored.statusDescription, 'busy');
      expect(restored.lastTime, 1700000000);
      expect(restored.expiryTime, 1700003600);
      expect(restored.statusDetails, {'android': 1, 'ios': 0});
    });

    test('absent status details remain null', () {
      final presence = ChatPresence.fromJson({'publisher': 'user-b'});

      expect(presence.publisher, 'user-b');
      expect(presence.statusDescription, '');
      expect(presence.lastTime, 0);
      expect(presence.expiryTime, 0);
      expect(presence.statusDetails, isNull);
    });

    test('empty status details are preserved separately from null', () {
      final presence = ChatPresence('user-b', '', {}, 0, 0);

      expect(presence.statusDetails, isEmpty);
      expect(presence.statusDescription, '');
    });
  });
}
