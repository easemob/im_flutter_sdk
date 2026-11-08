import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

void main() {
  group('ChatPresence JSON contract', () {
    test('native payload survives JSON encoding and decoding', () {
      final native = {
        'publisher': 'user-b',
        'statusDescription': 'busy',
        'lastTime': 1700000000,
        'expiryTime': 1700003600,
        'statusDetails': {'android': 1, 'ios': 0},
      };

      final encoded = jsonDecode(jsonEncode(ChatPresence.fromJson(native)));
      expect(encoded, native);
      final restored = ChatPresence.fromJson(encoded as Map);
      expect(restored.publisher, 'user-b');
      expect(restored.statusDescription, 'busy');
      expect(restored.lastTime, 1700000000);
      expect(restored.expiryTime, 1700003600);
      expect(restored.statusDetails, {'android': 1, 'ios': 0});
    });

    test('absent status details remain null after a round trip', () {
      final presence = ChatPresence.fromJson({'publisher': 'user-b'});
      final encoded = jsonDecode(jsonEncode(presence)) as Map;
      expect(encoded, {
        'publisher': 'user-b',
        'statusDescription': '',
        'lastTime': 0,
        'expiryTime': 0,
        'statusDetails': null,
      });
      expect(ChatPresence.fromJson(encoded).statusDetails, isNull);
    });

    test('empty status details are preserved separately from null', () {
      final presence = ChatPresence('user-b', '', {}, 0, 0);
      final restored = ChatPresence.fromJson(
        jsonDecode(jsonEncode(presence)) as Map,
      );
      expect(restored.statusDetails, isEmpty);
      expect(restored.statusDescription, '');
    });
  });
}
