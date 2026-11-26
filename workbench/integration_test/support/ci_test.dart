import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

// integration_test defaults to no timeout; every case must finish or fail.
void ciTestWidgets(
  String description,
  Future<void> Function(WidgetTester) body,
) {
  testWidgets(description, body, timeout: const Timeout(Duration(minutes: 2)));
}

Future<void> expectCiError(Future<Object?> Function() operation, int code) =>
    expectLater(
      () => operation().timeout(const Duration(seconds: 30)),
      throwsA(isA<ChatError>().having((error) => error.code, 'code', code)),
    );
