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
      {String phase = 'prepare',
      bool inviteNeedConfirm = false,
      bool invitePeer = true}) async {
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
      inviteMembers: invitePeer ? [peerId] : const [],
      configs: ChatGroupConfigs(
        maxCount: 100,
        allowInvites: true,
        inviteNeedConfirm: inviteNeedConfirm,
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
        (members) => setEquals(members, {userId, if (invitePeer) peerId}));

    final detail = await client.groupManager.fetchGroupInfoFromServer(groupId);
    expect(detail.groupId, groupId);
    expect(detail.groupName, name);
    expect(detail.desc, description);
    expect(detail.owner, userId);
    expect(detail.memberCount, invitePeer ? 2 : 1);
    expect(detail.configs, isNotNull);
    expect(detail.configs!.maxCount, 100);
    expect(detail.configs!.isPublic, isFalse);
    expect(detail.configs!.joinApprovalRequired, isFalse);
    expect(detail.configs!.allowInvites, isTrue);
    expect(detail.configs!.inviteNeedConfirm, inviteNeedConfirm);
    expect(detail.configs!.ext, tag);
    // This is a member-readiness check, not an independent pagination case.
    final members = await client.groupManager.fetchMemberListFromServer(
      groupId,
      pageSize: 20,
    );
    if (invitePeer) expect(members.data, contains(peerId));
    expect(members.data.toSet().difference({userId, if (invitePeer) peerId}),
        isEmpty);
    expect(members.data.toSet().length, members.data.length);
    expect(members.cursor == null || members.cursor!.isEmpty, isTrue);
    debugPrint('CI $caseId $phase verified: remote group detail and members');
    return detail;
  }

  // Test: Create a private group owned by the logged-in user with one prepared
  // peer, read its remote detail/members, then destroy it through the SDK.
  // Expected: The ID is nonempty; name, description, owner, count, and configs
  // match; REST confirms the two members and SDK member results include the peer
  // without outsiders/duplicates. REST confirms absence after destruction.
  // Cleanup reclaims this case's group if execution fails before destruction.
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

  // Test: Create and remotely verify an owned group, then read getGroupWithId
  // and getJoinedGroups from local SDK state.
  // Expected: Local ID/name/description/owner match the prepared group; the
  // joined list contains it exactly once with the same name. Cleanup deletes it.
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

  // Test: Create independent owner-only groups with invitation confirmation
  // enabled and disabled, then fetch their server details and local snapshots.
  // Expected: Both reads retain the requested boolean. No invitee or second
  // online client is needed to test this field; REST teardown reclaims groups.
  ciTestWidgets(
      'FL-GROUP-008 invitation confirmation flag survives server and local reads',
      (_) async {
    for (final required in [true, false]) {
      final group = await createOwnedGroup(
        'FL-GROUP-008',
        phase: 'verify',
        inviteNeedConfirm: required,
        invitePeer: false,
      );
      expect(group.configs!.inviteNeedConfirm, required);
      final local = await client.groupManager.getGroupWithId(group.groupId);
      expect(local, isNotNull);
      expect(local!.configs, isNotNull);
      expect(local.configs!.inviteNeedConfirm, required);
    }
  });

  final manager = client.groupManager;

  // Each metadata case owns a separate group, so failures do not leave shared
  // account state behind or prevent other metadata APIs from being exercised.
  ciTestWidgets('FL-GROUP-009 positive updates the group name', (_) async {
    final group = await createOwnedGroup('FL-GROUP-009', invitePeer: false);
    final name = 'renamed_${group.groupId}';
    await manager.updateGroupName(group.groupId, name);
    final detail = await manager.fetchGroupInfoFromServer(group.groupId);
    expect(detail.groupName, name);
    expect(detail.desc, group.desc);
    expect(detail.owner, userId);
  });

  ciTestWidgets('FL-GROUP-010 positive updates the group description',
      (_) async {
    final group = await createOwnedGroup('FL-GROUP-010', invitePeer: false);
    final description = 'updated description ${group.groupId}';
    await manager.updateGroupDesc(group.groupId, description);
    final detail = await manager.fetchGroupInfoFromServer(group.groupId);
    expect(detail.desc, description);
    expect(detail.groupName, group.groupName);
    expect(detail.owner, userId);
  });

  ciTestWidgets('FL-GROUP-011 positive updates the group extension', (_) async {
    final group = await createOwnedGroup('FL-GROUP-011', invitePeer: false);
    final extension = '{"case":"FL-GROUP-011","group":"${group.groupId}"}';
    await manager.updateGroupExtension(group.groupId, extension);
    final detail = await manager.fetchGroupInfoFromServer(group.groupId);
    debugPrint('CI FL-GROUP-011 observation: extension=${detail.extension} '
        'configs.ext=${detail.configs?.ext}');
    expect(detail.extension, extension);
    expect(detail.groupName, group.groupName);
  });

  // Updating twice distinguishes a current server read from a stale snapshot.
  ciTestWidgets('FL-GROUP-012 positive updates and fetches group announcements',
      (_) async {
    final group = await createOwnedGroup('FL-GROUP-012', invitePeer: false);
    for (final revision in [1, 2]) {
      final announcement = 'announcement ${group.groupId} revision $revision';
      await manager.updateGroupAnnouncement(group.groupId, announcement);
      expect(await manager.fetchAnnouncementFromServer(group.groupId),
          announcement);
    }
  });

  ciTestWidgets('FL-GROUP-013 positive updates and reads the group avatar',
      (_) async {
    final group = await createOwnedGroup('FL-GROUP-013', invitePeer: false);
    final avatar = 'https://example.com/ci/${group.groupId}.png';
    final updated = await manager.updateGroupAvatar(
        groupId: group.groupId, avatarUrl: avatar);
    expect(updated.groupId, group.groupId);
    expect(updated.avatarUrl, avatar);
    final detail = await manager.fetchGroupInfoFromServer(group.groupId);
    expect(detail.avatarUrl, avatar);
    expect(detail.groupName, group.groupName);
  });

  ciTestWidgets('FL-GROUP-014 positive sets, reads, and removes own namecard',
      (_) async {
    final group = await createOwnedGroup('FL-GROUP-014', invitePeer: false);
    final namecard = 'ci_${group.groupId}';
    await manager.updateGroupNamecard(
        groupId: group.groupId, namecard: namecard);
    expect(
        await manager.getGroupNamecard(groupId: group.groupId, userId: userId),
        namecard);
    await manager.updateGroupNamecard(groupId: group.groupId, namecard: null);
    try {
      final removed = await waitForCi(
        'FL-GROUP-014 cleared own namecard',
        () => manager.getGroupNamecard(groupId: group.groupId, userId: userId),
        (namecard) => namecard == null,
        timeout: const Duration(seconds: 5),
      );
      expect(removed, isNull);
    } catch (_) {
      // Observe server member information only after the local assertion has
      // failed; a diagnostic fetch must not make the assertion pass by warming
      // the cache or replace the original failure with its own error.
      try {
        final members = await manager
            .fetchGroupMembersInfo(
                groupId: group.groupId, cursor: null, limit: 20)
            .timeout(const Duration(seconds: 5));
        final own = members.data
            .where((member) => member.userId == userId)
            .map((member) => member.namecard)
            .toList();
        debugPrint('CI FL-GROUP-014 diagnostic: server own namecards=$own '
            'cursor=${members.cursor}');
      } catch (diagnosticError) {
        debugPrint('CI FL-GROUP-014 diagnostic fetch failed: $diagnosticError');
      }
      rethrow;
    }
  });

  // Select only allowInvites; the supplied other fields must not overwrite
  // the original group configuration. This does not test invitee acceptance.
  ciTestWidgets('FL-GROUP-015 positive updates only the selected config field',
      (_) async {
    final group = await createOwnedGroup('FL-GROUP-015', invitePeer: false);
    final updated = await manager.updateGroupConfigs(
      groupId: group.groupId,
      types: ChatGroupConfigsType.allowInvites,
      configs: const ChatGroupConfigs(
        allowInvites: false,
        maxCount: 80,
        inviteNeedConfirm: true,
        isPublic: false,
        joinApprovalRequired: false,
        ext: 'must_not_replace_original_extension',
      ),
    );
    expect(updated.groupId, group.groupId);
    expect(updated.configs, isNotNull);
    expect(updated.configs!.allowInvites, isFalse);
    final detail = await manager.fetchGroupInfoFromServer(group.groupId);
    expect(detail.configs, isNotNull);
    expect(detail.configs!.allowInvites, isFalse);
    expect(detail.configs!.maxCount, group.configs!.maxCount);
    expect(detail.configs!.inviteNeedConfirm, group.configs!.inviteNeedConfirm);
    expect(detail.configs!.ext, group.configs!.ext);
    expect(detail.configs!.isPublic, group.configs!.isPublic);
    expect(detail.configs!.joinApprovalRequired,
        group.configs!.joinApprovalRequired);
  });

  // The group explicitly disables invitation confirmation. The owner's
  // server-side membership operation therefore needs no second live client.
  ciTestWidgets('FL-GROUP-016 positive adds and removes a group member',
      (_) async {
    final group = await createOwnedGroup('FL-GROUP-016', invitePeer: false);
    await manager.addMembers(group.groupId, [peerId], welcome: 'CI member');
    await waitForCi(
        'FL-GROUP-016 member added',
        () => rest.groupMembers(group.groupId),
        (members) => setEquals(members, {userId, peerId}));
    final added = await manager.fetchMemberListFromServer(group.groupId);
    expect(added.data, contains(peerId));
    await manager.removeMembers(group.groupId, [peerId]);
    await waitForCi(
        'FL-GROUP-016 member removed',
        () => rest.groupMembers(group.groupId),
        (members) => setEquals(members, {userId}));
    final removed = await manager.fetchMemberListFromServer(group.groupId);
    expect(removed.data, isNot(contains(peerId)));
  });

  ciTestWidgets('FL-GROUP-017 positive promotes and demotes a group admin',
      (_) async {
    final group = await createOwnedGroup('FL-GROUP-017');
    expect(group.adminList, isNot(contains(peerId)));
    await manager.addAdmin(group.groupId, peerId);
    final promoted = await manager.fetchGroupInfoFromServer(group.groupId);
    expect(promoted.adminList, contains(peerId));
    expect(promoted.owner, userId);
    await manager.removeAdmin(group.groupId, peerId);
    final demoted = await manager.fetchGroupInfoFromServer(group.groupId);
    expect(demoted.adminList, isNot(contains(peerId)));
    expect(demoted.owner, userId);
    expect(await rest.groupMembers(group.groupId), {userId, peerId});
  });

  ciTestWidgets('FL-GROUP-018 positive fetches typed group member information',
      (_) async {
    final group = await createOwnedGroup('FL-GROUP-018');
    final result = await manager.fetchGroupMembersInfo(
        groupId: group.groupId, cursor: null, limit: 20);
    final ids = result.data.map((member) => member.userId).toList();
    expect(ids, contains(peerId));
    expect(ids.toSet().difference({userId, peerId}), isEmpty);
    expect(ids.toSet().length, ids.length);
    final peer = result.data.singleWhere((member) => member.userId == peerId);
    expect(peer.role, ChatGroupPermissionType.Member);
    expect(peer.joinedTs, greaterThan(0));
    expect(result.cursor == null || result.cursor!.isEmpty, isTrue);
  });

  ciTestWidgets(
      'FL-GROUP-019 positive sets, queries, and selectively removes member attributes',
      (_) async {
    final group = await createOwnedGroup('FL-GROUP-019');
    final ownAttributes = {'ci_role': 'owner', 'ci_marker': group.groupId};
    final peerAttributes = {'ci_role': 'peer', 'ci_marker': group.groupId};
    await manager.setMemberAttributes(
        groupId: group.groupId, userId: userId, attributes: ownAttributes);
    await manager.setMemberAttributes(
        groupId: group.groupId, userId: peerId, attributes: peerAttributes);
    expect(
        await manager.fetchMemberAttributes(
            groupId: group.groupId, userId: userId),
        ownAttributes);
    expect(
        await manager.fetchMemberAttributes(
            groupId: group.groupId, userId: peerId),
        peerAttributes);
    final selected = await manager.fetchMembersAttributes(
        groupId: group.groupId, userIds: [userId, peerId], keys: ['ci_role']);
    expect(selected, {
      userId: {'ci_role': 'owner'},
      peerId: {'ci_role': 'peer'},
    });
    await manager.removeMemberAttributes(
        groupId: group.groupId, userId: peerId, keys: ['ci_role']);
    expect(
        await manager.fetchMemberAttributes(
            groupId: group.groupId, userId: peerId),
        {'ci_marker': group.groupId});
    expect(
        await manager.fetchMemberAttributes(
            groupId: group.groupId, userId: userId),
        ownAttributes);
  });

  ciTestWidgets(
      'FL-GROUP-020 positive adds and removes a group blocklist entry',
      (_) async {
    final group = await createOwnedGroup('FL-GROUP-020');
    expect(await manager.fetchBlockListFromServer(group.groupId), isEmpty);
    await manager.blockMembers(group.groupId, [peerId]);
    expect(await manager.fetchBlockListFromServer(group.groupId), [peerId]);
    await waitForCi(
        'FL-GROUP-020 blocked peer removed from group',
        () => rest.groupMembers(group.groupId),
        (members) => setEquals(members, {userId}));
    await manager.unblockMembers(group.groupId, [peerId]);
    expect(await manager.fetchBlockListFromServer(group.groupId), isEmpty);
  });

  ciTestWidgets('FL-GROUP-021 positive adds and removes a group mute entry',
      (_) async {
    final group = await createOwnedGroup('FL-GROUP-021');
    expect(await manager.fetchMuteListFromServer(group.groupId), isEmpty);
    await manager.muteMembers(group.groupId, [peerId], duration: 600000);
    final muted = await manager.fetchMuteListFromServer(group.groupId);
    expect(muted.keys, unorderedEquals([peerId]));
    expect(muted[peerId], greaterThan(0));
    await manager.unMuteMembers(group.groupId, [peerId]);
    expect(await manager.fetchMuteListFromServer(group.groupId), isEmpty);
    expect(await rest.groupMembers(group.groupId), {userId, peerId});
  });

  ciTestWidgets(
      'FL-GROUP-022 positive adds and removes a group allowlist entry',
      (_) async {
    final group = await createOwnedGroup('FL-GROUP-022');
    final original = await manager.fetchAllowListFromServer(group.groupId);
    expect(original, isNot(contains(peerId)));
    await manager.addAllowList(group.groupId, [peerId]);
    final added = await manager.fetchAllowListFromServer(group.groupId);
    expect(added, unorderedEquals({...original, peerId}));
    await manager.removeAllowList(group.groupId, [peerId]);
    expect(await manager.fetchAllowListFromServer(group.groupId),
        unorderedEquals(original));
    expect(await rest.groupMembers(group.groupId), {userId, peerId});
  });
}
