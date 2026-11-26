import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../support/ci_test.dart';

void registerLoggedOutGroupNegativeCases({required ChatClient client}) {
  final manager = client.groupManager;
  // Test: Call createGroup with valid group parameters while logged out.
  // Expected: ChatError 201 (not logged in); unexpected creation fails the case
  // and registers an attempt to destroy the returned group.
  ciTestWidgets('FL-GROUP-003 negative rejects group creation while logged out',
      (_) async {
    expect(await client.getCurrentUserId(), isNull);
    await expectCiError(() async {
      final created = await manager.createGroup(
        groupName: 'ci_negative_${DateTime.now().microsecondsSinceEpoch}',
        configs: ChatGroupConfigs(maxCount: 100),
      );
      // An unexpected success still fails the assertion. Retain its ID and
      // attempt cleanup instead of silently leaking the created resource.
      debugPrint(
          'CI FL-GROUP-003 unexpected created group: ${created.groupId}');
      addTearDown(() => manager.destroyGroup(created.groupId));
      return created;
    }, 201);
  });

  final cases = <(String, String, Future<Object?> Function())>[
    // Test: Fetch remote group detail with a nonempty ID while logged out.
    // Expected: ChatError 201 for authentication, regardless of group existence.
    (
      'FL-GROUP-004',
      'fetchGroupInfoFromServer',
      () => manager.fetchGroupInfoFromServer('123456789012345')
    ),
    // Test: Call destroyGroup with a nonempty ID while logged out.
    // Expected: ChatError 201 (not logged in).
    (
      'FL-GROUP-005',
      'destroyGroup',
      () => manager.destroyGroup('123456789012345')
    ),
  ];
  for (final (id, name, operation) in cases) {
    ciTestWidgets('$id negative rejects $name while logged out', (_) async {
      expect(await client.getCurrentUserId(), isNull);
      await expectCiError(operation, 201);
    });
  }
}

void registerGroupNegativeCases({required ChatClient client}) {
  final cases = <(String, String, Future<Object?> Function())>[
    // Test: Fetch remote group detail with an empty ID while logged in.
    // Expected: ChatError 600 (invalid group ID).
    (
      'FL-GROUP-006',
      'fetchGroupInfoFromServer',
      () => client.groupManager.fetchGroupInfoFromServer('')
    ),
    // Test: Call destroyGroup with an empty ID while logged in.
    // Expected: ChatError 600 (invalid group ID).
    (
      'FL-GROUP-007',
      'destroyGroup',
      () => client.groupManager.destroyGroup('')
    ),
  ];
  for (final (id, name, operation) in cases) {
    ciTestWidgets('$id negative rejects an empty group ID in $name', (_) async {
      expect(await client.getCurrentUserId(), isNotNull);
      await expectCiError(operation, 600);
    });
  }
}
