import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../support/ci_test.dart';

import '../support/rest_fixture.dart';

void registerGroupCases({
  required ChatClient client,
  required String userId,
  required String peerId,
  required CiRestFixture rest,
}) {
  Future<ChatGroup> createOwnedGroup(String caseId,
      {String phase = 'prepare'}) async {
    final tag = '${caseId}_${DateTime.now().microsecondsSinceEpoch}';
    final name = 'ci_$tag';
    final description = 'CI basic API fixture $tag';
    String? groupId;
    addTearDown(() async {
      if (groupId == null) {
        debugPrint('CI $caseId cleanup: creation outcome unconfirmed; '
            'owner=$userId name=$name description=$description');
      }
      final ids = groupId == null
          ? await rest.groupIdsNamed(owner: userId, name: name)
          : [groupId];
      if (groupId == null && ids.isEmpty) {
        throw StateError('$caseId cleanup unresolved: creation outcome '
            'unconfirmed; owner=$userId name=$name');
      }
      for (final id in ids) {
        final existing = await rest.group(id);
        if (existing == null) {
          debugPrint('CI $caseId cleanup verified: group $id already absent');
          continue;
        }
        // An ID returned by this case's create call already proves ownership.
        // Discovery after an interrupted create needs additional verification.
        if (groupId == null) {
          if (existing['owner'] != userId ||
              existing['name'] != name ||
              existing['description'] != description) {
            throw StateError('$caseId cleanup: ownership mismatch for $id');
          }
        }
        debugPrint('CI $caseId cleanup: deleting owned group $id');
        await rest.deleteGroup(id);
        await rest.verifyGroupAbsent(id);
        debugPrint('CI $caseId cleanup verified: group $id absent');
      }
    });
    debugPrint('CI $caseId $phase: create owned group $name');
    final created = await client.groupManager.createGroup(
      groupName: name,
      desc: description,
      inviteMembers: [peerId],
      configs: ChatGroupConfigs(
        maxCount: 100,
        allowInvites: true,
        ext: tag,
      ),
    );
    groupId = created.groupId;
    debugPrint(
        'CI $caseId resource: groupId=$groupId owner=$userId peer=$peerId');
    expect(groupId, isNotEmpty);
    final observed = await rest.group(groupId);
    expect(observed, isNotNull);
    expect(observed!['owner'], userId);
    expect(observed['name'], name);
    expect(observed['description'], description);
    await waitForCi(
        'REST group $groupId exact owner/member set',
        () => rest.groupMembers(groupId!),
        (members) => setEquals(members, {userId, peerId}));

    final detail = await client.groupManager.fetchGroupInfoFromServer(groupId);
    expect(detail.groupId, groupId);
    expect(detail.groupName, name);
    expect(detail.desc, description);
    expect(detail.owner, userId);
    expect(detail.memberCount, 2);
    expect(detail.configs, isNotNull);
    expect(detail.configs!.maxCount, 100);
    expect(detail.configs!.isPublic, isFalse);
    expect(detail.configs!.joinApprovalRequired, isFalse);
    expect(detail.configs!.allowInvites, isTrue);
    expect(detail.configs!.inviteNeedConfirm, isFalse);
    expect(detail.configs!.ext, tag);
    // This is a member-readiness check, not an independent pagination case.
    final members = await client.groupManager.fetchMemberListFromServer(
      groupId,
      pageSize: 20,
    );
    expect(members.data, contains(peerId));
    expect(members.data.toSet().difference({userId, peerId}), isEmpty);
    expect(members.data.toSet().length, members.data.length);
    expect(members.cursor == null || members.cursor!.isEmpty, isTrue);
    debugPrint('CI $caseId $phase verified: remote group detail and members');
    return detail;
  }

  ciTestWidgets(
      'FL-GROUP-001 positive creates, reads, and destroys an owned group',
      (tester) async {
    const id = 'FL-GROUP-001';
    debugPrint('CI $id verify: SDK create and remote detail');
    final group = await createOwnedGroup(id, phase: 'verify');
    debugPrint('CI $id verify: SDK destroy ${group.groupId}');
    await client.groupManager.destroyGroup(group.groupId);
    await rest.verifyGroupAbsent(group.groupId);
    debugPrint('CI $id verify passed: group ${group.groupId} absent');
  });

  ciTestWidgets(
      'FL-GROUP-002 positive reads the created group from local SDK state',
      (tester) async {
    const id = 'FL-GROUP-002';
    // Each case creates its own group. Awaited SDK creation and remote detail
    // fetching populate native group state before the local reads under test.
    final prepared = await createOwnedGroup(id);
    debugPrint('CI $id verify: local group detail and joined list');
    final local = await client.groupManager.getGroupWithId(prepared.groupId);
    expect(local, isNotNull);
    expect(local!.groupId, prepared.groupId);
    expect(local.groupName, prepared.groupName);
    expect(local.desc, prepared.desc);
    expect(local.owner, userId);
    final joined = await client.groupManager.getJoinedGroups();
    final matches = joined.where((group) => group.groupId == prepared.groupId);
    expect(matches, hasLength(1));
    expect(matches.single.groupName, prepared.groupName);
    debugPrint('CI $id verify passed');
  });
}
