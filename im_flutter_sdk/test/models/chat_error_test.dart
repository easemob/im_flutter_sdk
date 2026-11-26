import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

void main() {
  test('EMError preserves the native code and description', () {
    final error = EMError.fromJson(<String, Object>{
      'code': 201,
      'description': 'User is not logged in',
    });

    expect(error.code, 201);
    expect(error.description, 'User is not logged in');
  });

  test('hasErrorFromResult throws the native EMError', () {
    expect(
      () => EMError.hasErrorFromResult(<String, Object>{
        'error': <String, Object>{
          'code': 201,
          'description': 'platform-specific text',
        },
      }),
      throwsA(
        isA<EMError>().having((error) => error.code, 'code', 201).having(
              (error) => error.description,
              'description',
              'platform-specific text',
            ),
      ),
    );
  });

  test('hasErrorFromResult accepts a successful result', () {
    expect(
      () => EMError.hasErrorFromResult(<String, Object>{'result': true}),
      returnsNormally,
    );
  });
}
