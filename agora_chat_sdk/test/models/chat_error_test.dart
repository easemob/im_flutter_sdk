import 'package:flutter_test/flutter_test.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';

void main() {
  test('ChatError preserves the native code and description', () {
    final error = ChatError.fromJson(<String, Object>{
      'code': 201,
      'description': 'User is not logged in',
    });

    expect(error.code, 201);
    expect(error.description, 'User is not logged in');
  });

  test('hasErrorFromResult throws the native ChatError', () {
    expect(
      () => ChatError.hasErrorFromResult(<String, Object>{
        'error': <String, Object>{
          'code': 201,
          'description': 'platform-specific text',
        },
      }),
      throwsA(
        isA<ChatError>().having((error) => error.code, 'code', 201).having(
              (error) => error.description,
              'description',
              'platform-specific text',
            ),
      ),
    );
  });

  test('hasErrorFromResult accepts a successful result', () {
    expect(
      () => ChatError.hasErrorFromResult(<String, Object>{'result': true}),
      returnsNormally,
    );
  });
}
