import 'package:flutter_test/flutter_test.dart';

// integration_test defaults to no timeout; every case must finish or fail.
void ciTestWidgets(
  String description,
  Future<void> Function(WidgetTester) body,
) {
  testWidgets(description, body, timeout: const Timeout(Duration(minutes: 2)));
}
