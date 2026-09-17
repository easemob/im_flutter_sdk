import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

void main() {
  group('ChatCursorResult JSON contract', () {
    test('preserves totalCount when native provides it', () {
      final result = ChatCursorResult<String>.fromJson(
        <String, dynamic>{
          'cursor': 'next',
          'list': <String>['a', 'b'],
          'totalCount': 12,
        },
        dataItemCallback: (item) => item as String,
      );

      expect(result.cursor, 'next');
      expect(result.data, <String>['a', 'b']);
      expect(result.totalCount, 12);
    });

    test('keeps totalCount null when native omits it', () {
      final result = ChatCursorResult<String>.fromJson(
        <String, dynamic>{
          'cursor': null,
          'list': <String>[],
        },
        dataItemCallback: (item) => item as String,
      );

      expect(result.totalCount, isNull);
    });
  });
}
