import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

void main() {
  group('ChatCursorResult JSON contract', () {
    test('preserves cursor and data in native order', () {
      final result = ChatCursorResult<String>.fromJson(
        <String, dynamic>{
          'cursor': 'next',
          'list': <String>['a', 'b'],
        },
        dataItemCallback: (item) => item as String,
      );

      expect(result.cursor, 'next');
      expect(result.data, <String>['a', 'b']);
    });

    test('keeps a null cursor and an empty list', () {
      final result = ChatCursorResult<String>.fromJson(
        <String, dynamic>{
          'cursor': null,
          'list': <String>[],
        },
        dataItemCallback: (item) => item as String,
      );

      expect(result.cursor, isNull);
      expect(result.data, isEmpty);
    });
  });
}
