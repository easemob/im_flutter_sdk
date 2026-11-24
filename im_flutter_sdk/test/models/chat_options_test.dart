import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

void main() {
  test('1.16.0 options serialize to the native keys', () {
    final options = ChatOptions.withAppKey(
      'ci-app-key',
      disconnectNotifyThreshold: 20,
      usePushInBackground: true,
    );

    final json = options.toJson();
    expect(json['disconnectNotifyThreshold'], 20);
    expect(json['usePushInBackground'], isTrue);
  });

  test('unset 1.16.0 options keep the native defaults', () {
    final options = ChatOptions.withAppKey('ci-app-key');

    final json = options.toJson();
    // A null threshold is not sent, so the native default (10 seconds) applies.
    expect(json.containsKey('disconnectNotifyThreshold'), isFalse);
    expect(json['usePushInBackground'], isFalse);
  });

  test('copyWith preserves the 1.16.0 options', () {
    final options = ChatOptions.withAppKey(
      'ci-app-key',
      disconnectNotifyThreshold: 5,
      usePushInBackground: true,
    );

    final copy = options.copyWith();
    expect(copy.disconnectNotifyThreshold, 5);
    expect(copy.usePushInBackground, isTrue);
  });
}
