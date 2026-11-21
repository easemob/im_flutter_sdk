import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../support/ci_test.dart';
import '../support/env.dart';
import '../support/rest_fixture.dart' show CiRestFixture;

String _unique(String prefix) =>
    '${prefix}_${DateTime.now().microsecondsSinceEpoch}';

/// Asserts that [operation] fails with a [ChatError] and records the code.
Future<void> _expectRoomError(
  String label,
  Future<Object?> Function() operation,
) async {
  try {
    await operation();
  } on ChatError catch (error) {
    // ignore: avoid_print
    print(
        'CI room negative "$label" code=${error.code} desc=${error.description}');
    return;
  }
  fail('CI room negative "$label": expected ChatError but the call succeeded');
}

/// Makes sure [userId] is an explicit member of the room; blocking or
/// removing members leaves the fixture room in a modified state otherwise.
Future<void> _ensureRoomMember(
  CiRestFixture rest,
  String roomId,
  String userId,
) async {
  final members = await rest.chatRoomMembers(roomId);
  if (!members.contains(userId)) {
    await rest.addChatRoomMembers(roomId, <String>[userId]);
  }
}

/// Chat room cases (FL-ROOM-001..031) running on the dedicated special entry.
///
/// The 4.25 ohos line has no public create-chat-room API, so [rest] creates
/// the fixture room owned by [ciUserId] before setup and deletes it after the
/// suite. All mutations are verified through the REST detail endpoint.
class CiRoomFixture {
  CiRoomFixture(this.rest);

  final CiRestFixture rest;
  late String roomId;
}

void registerRoomCases(
  ChatClient client,
  CiRestFixture rest,
  CiRoomFixture fixture,
) {
  ciTestWidgets('FL-ROOM-001 joins a chat room', (tester) async {
    final roomId = fixture.roomId;
    await client.chatRoomManager.joinChatRoom(
      roomId,
      leaveOtherRooms: false,
      ext: 'flutter-ci',
    );
    final members = await client.chatRoomManager.fetchChatRoomMembers(roomId);
    // chatsdk leaves the room owner out of the member page and its join
    // response carries no owner either, so the wrapper can restore the owner
    // row only after a later room-info call is observed (see FL-ROOM-006,
    // which runs after the name/description updates). The peer added by the
    // fixture is always present on the first page.
    expect(members.data, contains(ciPeerId));
  });

  ciTestWidgets('FL-ROOM-002 leaves a chat room', (tester) async {
    // The room owner cannot leave, so create the room for the peer and join
    // it with the logged-in account.
    final tempRoom = await rest.createChatRoom(
      owner: ciPeerId,
      name: _unique('ci_room_leave'),
      description: 'flutter ci room',
    );
    addTearDown(() => rest.deleteChatRoom(tempRoom));
    await client.chatRoomManager.joinChatRoom(tempRoom);
    expect(
      (await client.chatRoomManager.fetchChatRoomMembers(tempRoom)).data,
      contains(ciUserId),
    );
    await client.chatRoomManager.leaveChatRoom(tempRoom);
    expect(
        await rest.chatRoomMembers(tempRoom), isNot(contains(ciUserId)));
  });

  ciTestWidgets('FL-ROOM-003 fetches public chat rooms', (tester) async {
    final rooms = await client.chatRoomManager.fetchPublicChatRoomsFromServer(
      pageNum: 1,
      pageSize: 50,
    );
    expect(rooms, isA<ChatPageResult<ChatRoom>>());
    expect(rooms.data, isA<List<ChatRoom>>());
  });

  ciTestWidgets('FL-ROOM-004 changes the chat room name', (tester) async {
    final roomId = fixture.roomId;
    final name = _unique('ci_room_name');
    await client.chatRoomManager.changeChatRoomName(roomId, name);
    final detail = await rest.chatRoomDetail(roomId);
    expect(detail['name'], name);
  });

  ciTestWidgets('FL-ROOM-005 changes the chat room description',
      (tester) async {
    final roomId = fixture.roomId;
    final description = _unique('ci_room_desc');
    await client.chatRoomManager.changeChatRoomDescription(roomId, description);
    final detail = await rest.chatRoomDetail(roomId);
    expect(detail['description'], description);
  });

  ciTestWidgets('FL-ROOM-006 fetches chat room members', (tester) async {
    final roomId = fixture.roomId;
    final members = await client.chatRoomManager.fetchChatRoomMembers(
      roomId,
      pageSize: 200,
    );
    // The owner row is restored from the Chatroom that FL-ROOM-001's join
    // cached (chatsdk has no single-room fetch on this line).
    expect(members.data, contains(ciUserId));
    expect(members.data, contains(ciPeerId));
    expect(members.cursor, isA<String>());
  });

  ciTestWidgets('FL-ROOM-007 mutes a chat room member', (tester) async {
    final roomId = fixture.roomId;
    await client.chatRoomManager.muteChatRoomMembers(
      roomId,
      <String>[ciPeerId],
      duration: 60000,
    );
    addTearDown(
      () => client.chatRoomManager.unMuteChatRoomMembers(
        roomId,
        <String>[ciPeerId],
      ),
    );
    final muteList = await client.chatRoomManager.fetchChatRoomMuteList(roomId);
    expect(muteList, contains(ciPeerId));
  });

  ciTestWidgets('FL-ROOM-008 unmutes a chat room member', (tester) async {
    final roomId = fixture.roomId;
    await client.chatRoomManager.muteChatRoomMembers(
      roomId,
      <String>[ciPeerId],
      duration: 60000,
    );
    await client.chatRoomManager
        .unMuteChatRoomMembers(roomId, <String>[ciPeerId]);
    final muteList = await client.chatRoomManager.fetchChatRoomMuteList(roomId);
    expect(muteList, isNot(contains(ciPeerId)));
  });

  ciTestWidgets('FL-ROOM-010 adds a chat room admin', (tester) async {
    final roomId = fixture.roomId;
    await client.chatRoomManager.addChatRoomAdmin(roomId, ciPeerId);
    addTearDown(
      () => client.chatRoomManager.removeChatRoomAdmin(roomId, ciPeerId),
    );
    expect(await rest.chatRoomAdmins(roomId), contains(ciPeerId));
  });

  ciTestWidgets('FL-ROOM-011 removes a chat room admin', (tester) async {
    final roomId = fixture.roomId;
    await client.chatRoomManager.addChatRoomAdmin(roomId, ciPeerId);
    await client.chatRoomManager.removeChatRoomAdmin(roomId, ciPeerId);
    expect(await rest.chatRoomAdmins(roomId), isNot(contains(ciPeerId)));
  });

  ciTestWidgets('FL-ROOM-012 fetches the chat room mute list', (tester) async {
    final roomId = fixture.roomId;
    final muteList = await client.chatRoomManager.fetchChatRoomMuteList(roomId);
    expect(muteList, isA<List<String>>());
  });

  ciTestWidgets('FL-ROOM-013 removes a chat room member', (tester) async {
    final roomId = fixture.roomId;
    await _ensureRoomMember(rest, roomId, ciPeerId);
    await client.chatRoomManager
        .removeChatRoomMembers(roomId, <String>[ciPeerId]);
    addTearDown(() => _ensureRoomMember(rest, roomId, ciPeerId));
    expect(await rest.chatRoomMembers(roomId), isNot(contains(ciPeerId)));
  });

  ciTestWidgets('FL-ROOM-014 blocks chat room members', (tester) async {
    final roomId = fixture.roomId;
    await _ensureRoomMember(rest, roomId, ciPeerId);
    await client.chatRoomManager
        .blockChatRoomMembers(roomId, <String>[ciPeerId]);
    addTearDown(() async {
      await client.chatRoomManager
          .unBlockChatRoomMembers(roomId, <String>[ciPeerId]);
      await _ensureRoomMember(rest, roomId, ciPeerId);
    });
    final blockList =
        await client.chatRoomManager.fetchChatRoomBlockList(roomId);
    expect(blockList, contains(ciPeerId));
  });

  ciTestWidgets('FL-ROOM-015 unblocks chat room members', (tester) async {
    final roomId = fixture.roomId;
    await _ensureRoomMember(rest, roomId, ciPeerId);
    await client.chatRoomManager
        .blockChatRoomMembers(roomId, <String>[ciPeerId]);
    await client.chatRoomManager
        .unBlockChatRoomMembers(roomId, <String>[ciPeerId]);
    addTearDown(() => _ensureRoomMember(rest, roomId, ciPeerId));
    final blockList =
        await client.chatRoomManager.fetchChatRoomBlockList(roomId);
    expect(blockList, isNot(contains(ciPeerId)));
  });

  ciTestWidgets('FL-ROOM-016 fetches the chat room block list', (tester) async {
    final roomId = fixture.roomId;
    final blockList =
        await client.chatRoomManager.fetchChatRoomBlockList(roomId);
    expect(blockList, isA<List<String>>());
  });

  ciTestWidgets('FL-ROOM-017 updates the chat room announcement',
      (tester) async {
    final roomId = fixture.roomId;
    final announcement = _unique('ci_room_announcement');
    await client.chatRoomManager
        .updateChatRoomAnnouncement(roomId, announcement);
    expect(
      await client.chatRoomManager.fetchChatRoomAnnouncement(roomId),
      announcement,
    );
  });

  ciTestWidgets('FL-ROOM-018 fetches the chat room announcement',
      (tester) async {
    final roomId = fixture.roomId;
    final announcement = _unique('ci_room_announcement');
    await client.chatRoomManager
        .updateChatRoomAnnouncement(roomId, announcement);
    expect(
      await client.chatRoomManager.fetchChatRoomAnnouncement(roomId),
      announcement,
    );
    expect(await rest.chatRoomAnnouncement(roomId), announcement);
  });

  ciTestWidgets('FL-ROOM-019 fetches the chat room allow list', (tester) async {
    final roomId = fixture.roomId;
    final allowList =
        await client.chatRoomManager.fetchChatRoomAllowListFromServer(roomId);
    expect(allowList, isA<List<String>>());
  });

  ciTestWidgets('FL-ROOM-020 checks whether the user is in the allow list',
      (tester) async {
    final roomId = fixture.roomId;
    expect(
      await client.chatRoomManager.isMemberInChatRoomAllowList(roomId),
      isA<bool>(),
    );
  });

  ciTestWidgets('FL-ROOM-021 adds members to the chat room allow list',
      (tester) async {
    final roomId = fixture.roomId;
    await _ensureRoomMember(rest, roomId, ciPeerId);
    await client.chatRoomManager
        .addMembersToChatRoomAllowList(roomId, <String>[ciPeerId]);
    addTearDown(
      () => client.chatRoomManager
          .removeMembersFromChatRoomAllowList(roomId, <String>[ciPeerId]),
    );
    final allowList =
        await client.chatRoomManager.fetchChatRoomAllowListFromServer(roomId);
    expect(allowList, contains(ciPeerId));
  });

  ciTestWidgets('FL-ROOM-022 removes members from the chat room allow list',
      (tester) async {
    final roomId = fixture.roomId;
    await _ensureRoomMember(rest, roomId, ciPeerId);
    await client.chatRoomManager
        .addMembersToChatRoomAllowList(roomId, <String>[ciPeerId]);
    await client.chatRoomManager
        .removeMembersFromChatRoomAllowList(roomId, <String>[ciPeerId]);
    final allowList =
        await client.chatRoomManager.fetchChatRoomAllowListFromServer(roomId);
    expect(allowList, isNot(contains(ciPeerId)));
  });

  ciTestWidgets('FL-ROOM-023 mutes all chat room members', (tester) async {
    final roomId = fixture.roomId;
    await client.chatRoomManager.muteAllChatRoomMembers(roomId);
    addTearDown(() => client.chatRoomManager.unMuteAllChatRoomMembers(roomId));
    final detail = await rest.chatRoomDetail(roomId);
    expect(detail['mute'], isTrue);
  });

  ciTestWidgets('FL-ROOM-024 unmutes all chat room members', (tester) async {
    final roomId = fixture.roomId;
    await client.chatRoomManager.muteAllChatRoomMembers(roomId);
    await client.chatRoomManager.unMuteAllChatRoomMembers(roomId);
    final detail = await rest.chatRoomDetail(roomId);
    expect(detail['mute'], isFalse);
  });

  ciTestWidgets('FL-ROOM-025 fetches chat room attributes', (tester) async {
    final roomId = fixture.roomId;
    final attributes = await client.chatRoomManager.fetchChatRoomAttributes(
      roomId: roomId,
      keys: <String>[_unique('ci_missing_attr')],
    );
    expect(attributes == null || attributes.isEmpty, isTrue);
  });

  ciTestWidgets('FL-ROOM-026 adds chat room attributes', (tester) async {
    final roomId = fixture.roomId;
    final key = _unique('ci_room_attr');
    final value = _unique('value');
    final result = await client.chatRoomManager.addAttributes(
      roomId,
      attributes: <String, String>{key: value},
    );
    addTearDown(
      () => client.chatRoomManager.removeAttributes(
        roomId,
        keys: <String>[key],
        force: true,
      ),
    );
    expect(result, isNotNull);
    expect(result, isEmpty);
    final attributes = await client.chatRoomManager.fetchChatRoomAttributes(
      roomId: roomId,
    );
    expect(attributes?[key], value);
  });

  ciTestWidgets('FL-ROOM-027 removes chat room attributes', (tester) async {
    final roomId = fixture.roomId;
    final key = _unique('ci_room_attr_del');
    await client.chatRoomManager.addAttributes(
      roomId,
      attributes: <String, String>{key: _unique('value')},
    );
    final result = await client.chatRoomManager.removeAttributes(
      roomId,
      keys: <String>[key],
      force: true,
    );
    expect(result, isNotNull);
    expect(result, isEmpty);
    final attributes = await client.chatRoomManager.fetchChatRoomAttributes(
      roomId: roomId,
    );
    expect(attributes?.containsKey(key), isNot(isTrue));
  });

  ciTestWidgets('FL-ROOM-028 checks whether the user is muted', (tester) async {
    final roomId = fixture.roomId;
    expect(
      await client.chatRoomManager.isMemberInChatRoomMuteList(roomId),
      isA<bool>(),
    );
  });

  ciTestWidgets('FL-ROOM-029 rejects joining a missing chat room',
      (tester) async {
    await _expectRoomError(
      'join missing room',
      () => client.chatRoomManager.joinChatRoom(_unique('ci_missing_room')),
    );
  });

  ciTestWidgets('FL-ROOM-030 rejects members of a missing chat room',
      (tester) async {
    await _expectRoomError(
      'fetch members of missing room',
      () => client.chatRoomManager
          .fetchChatRoomMembers(_unique('ci_missing_room')),
    );
  });

  ciTestWidgets('FL-ROOM-031 rejects empty chat room attributes',
      (tester) async {
    final roomId = fixture.roomId;
    await _expectRoomError(
      'add empty attributes',
      () => client.chatRoomManager.addAttributes(
        roomId,
        attributes: const <String, String>{},
      ),
    );
  });

  ciTestWidgets('FL-ROOM-009 transfers the chat room ownership',
      (tester) async {
    final roomId = fixture.roomId;
    await client.chatRoomManager.changeOwner(roomId, ciPeerId);
    addTearDown(() => rest.changeChatRoomOwner(roomId, ciUserId));
    final detail = await rest.chatRoomDetail(roomId);
    expect(detail['owner'], ciPeerId);
  });
}
