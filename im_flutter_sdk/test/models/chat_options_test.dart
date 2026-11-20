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
}
