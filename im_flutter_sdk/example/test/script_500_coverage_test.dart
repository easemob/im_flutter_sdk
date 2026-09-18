import 'dart:convert';
import 'dart:io';

import 'package:example/auto/step_dependencies.dart';
import 'package:example/auto/step_expectation.dart';
import 'package:example/registry/apis/chat_apis.dart';
import 'package:example/registry/registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

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

  test('dependent steps are skipped only after a referenced step fails', () {
    final params = <String, dynamic>{
      'message': r'$step.group_message',
      'groupId': r'$step.group.groupId',
    };

    expect(stepReferenceIds(params), <String>{'group_message', 'group'});
    expect(
      failedStepDependency(params, <String, bool>{
        'group_message': false,
        'group': true,
      }),
      'group_message',
    );
    expect(
      failedStepDependency(params, <String, bool>{
        'group_message': true,
        'group': true,
      }),
      isNull,
    );
    expect(skippedStepResult('group_message'), {
      'success': false,
      'skipped': true,
      'blockedBy': 'group_message',
      'error': {
        'code': -3,
        'message': 'Skipped because step "group_message" did not succeed',
      },
    });
  });

  test('conversation output exposes 5.0.0 metadata as structured JSON', () {
    final conversation = ChatConversation.fromJson(<String, dynamic>{
      'convId': 'group-id',
      'type': ChatConversationType.GroupChat.index,
      'name': 'Group name',
      'avatar': 'https://example.invalid/avatar.png',
    });

    expect(conversationToScriptJson(conversation), <String, Object?>{
      'id': 'group-id',
      'type': ChatConversationType.GroupChat.index,
      'name': 'Group name',
      'avatar': 'https://example.invalid/avatar.png',
    });
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
