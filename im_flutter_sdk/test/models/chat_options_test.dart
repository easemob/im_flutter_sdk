import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

void main() {
  test('all public constructors keep the native conversation defaults', () {
    final options = [
      ChatOptions.withAppKey('org#app'),
      ChatOptions.withAppId('app-id'),
      // ignore: deprecated_member_use_from_same_package
      ChatOptions(appKey: 'org#app'),
    ];
    for (final option in options) {
      expect(option.autoLoadConversations, isTrue);
      expect(option.enableChatroomConversation, isFalse);
      expect(option.toJson()['autoLoadConversations'], isTrue);
      expect(option.toJson()['enableChatroomConversation'], isFalse);
      // Omission must preserve the native default, not force a Dart mask.
      expect(option.dataSyncType, isNull);
      expect(option.toJson().containsKey('dataSyncType'), isFalse);
    }
  });

  test('all public constructors carry explicit conversation options to native',
      () {
    final options = [
      ChatOptions.withAppKey('org#app',
          autoLoadConversations: false, enableChatroomConversation: true),
      ChatOptions.withAppId('app-id',
          autoLoadConversations: false, enableChatroomConversation: true),
      // ignore: deprecated_member_use_from_same_package
      ChatOptions(
          appKey: 'org#app',
          autoLoadConversations: false,
          enableChatroomConversation: true),
    ];
    for (final option in options) {
      expect(option.autoLoadConversations, isFalse);
      expect(option.enableChatroomConversation, isTrue);
      expect(option.toJson()['autoLoadConversations'], isFalse);
      expect(option.toJson()['enableChatroomConversation'], isTrue);
    }
  });

  test('copyWith preserves and explicitly replaces both conversation options',
      () {
    final original = ChatOptions.withAppKey('org#app',
        autoLoadConversations: false, enableChatroomConversation: true);
    final preserved = original.copyWith();
    expect(preserved.autoLoadConversations, isFalse);
    expect(preserved.enableChatroomConversation, isTrue);
    final replaced = original.copyWith(
        autoLoadConversations: true, enableChatroomConversation: false);
    expect(replaced.toJson()['autoLoadConversations'], isTrue);
    expect(replaced.toJson()['enableChatroomConversation'], isFalse);
    expect(replaced.appKey, 'org#app');
    final restored = replaced.copyWith(
        autoLoadConversations: false, enableChatroomConversation: true);
    expect(restored.toJson()['autoLoadConversations'], isFalse);
    expect(restored.toJson()['enableChatroomConversation'], isTrue);
    expect(original.autoLoadConversations, isFalse);
    expect(original.enableChatroomConversation, isTrue);
  });

  test('explicit data sync masks including none reach native unchanged', () {
    for (final mask in [
      ChatDataSyncType.none,
      ChatDataSyncType.conversations | ChatDataSyncType.contacts,
    ]) {
      final options = ChatOptions.withAppKey('org#app', dataSyncType: mask);
      expect(options.toJson()['dataSyncType'], mask);
      expect(options.copyWith().toJson()['dataSyncType'], mask);
    }
  });
}
