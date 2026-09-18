import 'dart:convert';
import 'dart:io';

import 'package:example/auto/step_expectation.dart';
import 'package:example/registry/registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('step expectations accept success and expected errors', () {
    expect(
      stepResultMatchesExpectation(<String, dynamic>{'success': true}, null),
      isTrue,
    );
    expect(
      stepResultMatchesExpectation(
        <String, dynamic>{'success': false},
        <String, dynamic>{},
      ),
      isFalse,
    );
    expect(
      stepResultMatchesExpectation(
        <String, dynamic>{
          'success': false,
          'error': <String, dynamic>{'code': 305},
        },
        <String, dynamic>{'errorCode': 305},
      ),
      isTrue,
    );
    expect(
      stepResultMatchesExpectation(
        <String, dynamic>{
          'success': false,
          'error': <String, dynamic>{'code': 500},
        },
        <String, dynamic>{'success': false},
      ),
      isTrue,
    );
  });

  test('5.0.0 script covers the RN scenario and all APIs are registered', () {
    final script = Map<String, dynamic>.from(
      jsonDecode(File('scripts/script_500_apis.json').readAsStringSync())
          as Map,
    );
    final steps = (script['steps'] as List).cast<Map>();

    expect(steps, hasLength(21));
    for (final step in steps) {
      final api = step['api'] as String;
      expect(findApi(api), isNotNull, reason: '$api is not registered');
    }

    final names = steps.map((step) => step['api']).toSet();
    expect(
      names,
      containsAll(<String>{
        'ChatManager.getUnreadMessageCount',
        'ChatManager.modifyMessage',
        'ChatManager.clearConversationUnreadMessageCount',
        'ChatManager.clearAllConversationUnreadMessageCount',
        'ChatManager.getGroupMessageReadReceipts',
        'ChatManager.fetchGroupMessageReadReceipts',
        'ChatManager.sendMessageReadReceipts',
        'ChatGroupManager.createGroup',
        'ChatGroupManager.updateGroupConfigs',
        'ChatClient.fetchLoggedInDevices',
        'ChatClient.renewToken',
        'ChatClient.kickDevice',
        'ChatClient.kickAllDevices',
      }),
    );
  });
}
