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

  test('5.0.0 positive and negative scripts cover the RN scenario', () {
    final positive = _stepsOf('scripts/script_500_apis_positive.json');
    final negative = _stepsOf('scripts/script_500_apis_negative.json');

    expect(positive, isNotEmpty);
    expect(negative, isNotEmpty);
    for (final step in <Map>[...positive, ...negative]) {
      final api = step['api'] as String;
      expect(findApi(api), isNotNull, reason: '$api is not registered');
    }
    for (final steps in <List<Map>>[positive, negative]) {
      final ids = steps.map((step) => step['id']).toList();
      expect(
        ids.toSet(),
        hasLength(ids.length),
        reason: 'step ids must stay unique for run comparison',
      );
    }

    final positiveApis = positive.map((step) => step['api'] as String).toSet();
    final negativeApis = negative.map((step) => step['api'] as String).toSet();
    expect(
      positiveApis,
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
    for (final api in <String>[
      'ChatGroupManager.createGroup',
      'ChatGroupManager.updateGroupConfigs',
      'ChatManager.modifyMessage',
      'ChatManager.clearConversationUnreadMessageCount',
      'ChatManager.sendMessageReadReceipts',
      'ChatManager.getGroupMessageReadReceipts',
      'ChatClient.fetchLoggedInDevices',
      'ChatClient.renewToken',
      'ChatClient.kickDevice',
      'ChatClient.kickAllDevices',
    ]) {
      expect(positiveApis, contains(api), reason: 'positive path missing $api');
      expect(negativeApis, contains(api), reason: 'negative path missing $api');
    }
    expect(
      negativeApis,
      isNot(contains('ChatManager.fetchGroupMessageReadReceipts')),
      reason: 'the Android-crashing case stays masked in the negative path',
    );
  });

  test('positive steps expect success and negative steps expect an error', () {
    for (final step in _stepsOf('scripts/script_500_apis_positive.json')) {
      final expectation = step['expect'] as Map;
      expect(
        expectation['success'],
        isTrue,
        reason: '${step['id']} must assert the positive contract',
      );
    }
    for (final step in _stepsOf('scripts/script_500_apis_negative.json')) {
      final expectation = step['expect'] as Map;
      expect(
        expectation['success'] == false || expectation['errorCode'] is int,
        isTrue,
        reason: '${step['id']} must assert an error',
      );
    }
  });
}

List<Map> _stepsOf(String path) {
  final script = Map<String, dynamic>.from(
    jsonDecode(File(path).readAsStringSync()) as Map,
  );
  return (script['steps'] as List).cast<Map>();
}
