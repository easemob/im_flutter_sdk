import 'package:example/options_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('conversation options preserve SDK defaults when omitted', () {
    final options = emOptionsFromJson({'appKey': 'test#app'});
    expect(options.autoLoadConversations, isTrue);
    expect(options.enableChatroomConversation, isFalse);
    expect(options.toJson().containsKey('dataSyncType'), isFalse);
  });

  test('environment options reach initialization without losing false', () {
    final json = chatOptionsJsonFromEnvironment({
      'appKey': 'test#app',
      'autoLoadConversations': false,
      'enableChatroomConversation': true,
      'accounts': [],
    });
    expect(json.containsKey('accounts'), isFalse);
    final options = emOptionsFromJson(json);
    expect(options.toJson()['autoLoadConversations'], isFalse);
    expect(options.toJson()['enableChatroomConversation'], isTrue);
  });
}
