import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../support/ci_test.dart';

void registerLoggedOutContactNegativeCases({required ChatClient client}) {
  final manager = client.contactManager;
  const peer = 'flutter-ci-peer';
  final cases = <(String, String, Future<Object?> Function())>[
    // Test: Delete a contact with keepConversation=true while logged out.
    // Expected: ChatError 201 (not logged in).
    (
      'FL-CONTACT-005',
      'deleteContact keepConversation=true',
      () => manager.deleteContact(peer, keepConversation: true)
    ),
    // Test: Delete a contact with keepConversation=false while logged out.
    // Expected: ChatError 201 (not logged in).
    (
      'FL-CONTACT-006',
      'deleteContact keepConversation=false',
      () => manager.deleteContact(peer, keepConversation: false)
    ),
    // Test: Add a user to the blacklist while logged out.
    // Expected: ChatError 201 (not logged in).
    (
      'FL-CONTACT-007',
      'addUserToBlockList',
      () => manager.addUserToBlockList(peer)
    ),
    // Test: Remove a user from the blacklist while logged out.
    // Expected: ChatError 201 (not logged in).
    (
      'FL-CONTACT-008',
      'removeUserFromBlockList',
      () => manager.removeUserFromBlockList(peer)
    ),
    // Test: Fetch the remote blacklist while logged out.
    // Expected: ChatError 201 (not logged in).
    ('FL-CONTACT-009', 'fetchBlockIds', manager.fetchBlockIds),
  ];
  for (final (id, name, operation) in cases) {
    ciTestWidgets('$id negative rejects $name while logged out', (_) async {
      expect(await client.getCurrentUserId(), isNull);
      await expectCiError(operation, 201);
    });
  }
}

void registerContactNegativeCases({required ChatClient client}) {
  // Test: Query getContact for a unique ID absent from both local contact lists.
  // Expected: The detail is null and neither list gains the queried ID.
  ciTestWidgets('FL-CONTACT-010 negative missing contact has no detail',
      (_) async {
    final manager = client.contactManager;
    final absent = 'ci_contact_absent_${DateTime.now().microsecondsSinceEpoch}';
    expect(await manager.getAllContactIds(), isNot(contains(absent)));
    expect((await manager.getAllContacts()).map((item) => item.userId),
        isNot(contains(absent)));

    expect(await manager.getContact(userId: absent), isNull);

    expect(await manager.getAllContactIds(), isNot(contains(absent)));
    expect((await manager.getAllContacts()).map((item) => item.userId),
        isNot(contains(absent)));
  });
}
