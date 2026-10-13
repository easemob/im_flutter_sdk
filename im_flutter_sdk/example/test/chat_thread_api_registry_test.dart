import 'dart:convert';

import 'package:example/registry/apis/chat_thread_apis.dart';
import 'package:example/registry/registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers the required ChatThread APIs', () {
    const expectedParameters = <String, Set<String>>{
      'ChatThreadManager.createChatThread': {
        'name',
        'messageId',
        'parentId',
      },
      'ChatThreadManager.destroyChatThread': {'chatThreadId'},
      'ChatThreadManager.joinChatThread': {'chatThreadId'},
      'ChatThreadManager.leaveChatThread': {'chatThreadId'},
      'ChatThreadManager.fetchJoinedChatThreadsWithParentId': {
        'parentId',
        'cursor',
        'limit',
      },
    };

    for (final entry in expectedParameters.entries) {
      final api = findApi(entry.key);
      expect(api, isNotNull, reason: '${entry.key} is not registered');
      expect(api, isIn(chatThreadApis));

      final parameters = Map<String, dynamic>.from(
        jsonDecode(api!.paramsTemplate) as Map,
      );
      expect(parameters.keys.toSet(), entry.value);
    }
  });

  test('does not register duplicate ChatThread API names', () {
    final names = chatThreadApis.map((entry) => entry.name).toList();
    expect(names.toSet(), hasLength(names.length));
  });
}
