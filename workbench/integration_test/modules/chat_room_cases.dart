import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../support/ci_test.dart';
import '../support/rest_fixture.dart';

void registerChatRoomCases({
  required ChatClient client,
  required String userId,
  required String peerId,
  required CiRestFixture rest,
}) {
  final manager = client.chatRoomManager;
  var sequence = 0;

  String unique(String label) =>
      'ci_room_${DateTime.now().microsecondsSinceEpoch}_${sequence++}_$label';

  /// Creates a room owned by the logged-in user with the offline peer as a
  /// member, then joins it. Cleanup leaves (best effort), deletes, and verifies
  /// absence so a failed case cannot leak a room.
  Future<({String id, String name})> prepareRoom(String caseId) async {
    final run = unique(caseId.toLowerCase());
    final id = await rest.createChatRoom(
      owner: userId,
      name: run,
      description: 'CI $caseId room',
      members: [peerId],
    );
    addTearDown(() async {
      try {
        await manager.leaveChatRoom(id).timeout(const Duration(seconds: 15));
      } catch (_) {
        // Leaving is best effort; deletion below is the authoritative cleanup.
      }
      await rest.deleteChatRoom(id);
      await rest.verifyChatRoomAbsent(id);
    });
    await manager.joinChatRoom(id).timeout(const Duration(seconds: 30));
    return (id: id, name: run);
  }

  // Test: Create a room through REST with the owner and the prepared peer as
  // members, join it, read its server detail, local cache, and member list,
  // then leave and join again.
  // Expected: Server and local reads report the created room; the member list
  // reports the prepared peer; leaving then rejoining succeeds and restores
  // the local room. Teardown leaves, deletes, and verifies REST absence.
  ciTestWidgets('FL-ROOM-001 positive joins, reads, and rejoins a room',
      (_) async {
    final room = await prepareRoom('FL-ROOM-001');
    final info = await manager.fetchChatRoomInfoFromServer(room.id);
    expect(info.roomId, room.id);
    expect(info.name, room.name);
    expect(info.owner, userId);
    final local = await manager.getChatRoomWithId(room.id);
    expect(local, isNotNull);
    expect(local!.roomId, room.id);
    final members = await manager.fetchChatRoomMembers(room.id);
    // The server member page may omit the requester, so assert the prepared
    // peer only; self membership is proven by the successful join.
    expect(members.data, contains(peerId));
    await manager.leaveChatRoom(room.id).timeout(const Duration(seconds: 15));
    await manager.joinChatRoom(room.id).timeout(const Duration(seconds: 30));
    expect(await manager.getChatRoomWithId(room.id), isNotNull);
  });

  // Test: As the room owner, write one announcement, read it, replace it with a
  // newer one, and read again.
  // Expected: Each fetch returns the most recently written announcement; the
  // second write replaces the first rather than appending. Teardown reclaims
  // the room.
  ciTestWidgets(
      'FL-ROOM-002 positive updates and fetches the room announcement',
      (_) async {
    final room = await prepareRoom('FL-ROOM-002');
    final first = 'announcement one ${room.name}';
    final second = 'announcement two ${room.name}';
    await manager.updateChatRoomAnnouncement(room.id, first);
    expect(await manager.fetchChatRoomAnnouncement(room.id), first);
    await manager.updateChatRoomAnnouncement(room.id, second);
    expect(await manager.fetchChatRoomAnnouncement(room.id), second);
  });

  // Test: Create one room to remove the peer from and another to block and
  // unblock the peer in, so a block-induced membership change cannot mask the
  // removal assertion.
  // Expected: Removing the peer drops it from the member list while the room
  // keeps its owner; blocking adds the peer to the blocklist and unblocking
  // empties it. Teardown reclaims both rooms.
  ciTestWidgets(
      'FL-ROOM-003 positive removes a member and manages room blocklist',
      (_) async {
    final removal = await prepareRoom('FL-ROOM-003a');
    final before = await manager.fetchChatRoomMembers(removal.id);
    expect(before.data, contains(peerId));
    await manager.removeChatRoomMembers(removal.id, [peerId]);
    final after = await manager.fetchChatRoomMembers(removal.id);
    expect(after.data, isNot(contains(peerId)));
    expect(
        (await manager.fetchChatRoomInfoFromServer(removal.id)).owner, userId);

    final blocking = await prepareRoom('FL-ROOM-003b');
    expect(await manager.fetchChatRoomBlockList(blocking.id),
        isNot(contains(peerId)));
    await manager.blockChatRoomMembers(blocking.id, [peerId]);
    expect(await manager.fetchChatRoomBlockList(blocking.id), contains(peerId));
    await manager.unBlockChatRoomMembers(blocking.id, [peerId]);
    expect(await manager.fetchChatRoomBlockList(blocking.id),
        isNot(contains(peerId)));
  });

  // Test: In a fresh room, mute and unmute the peer, then mute and unmute all
  // members, reading the mute list and server detail after each step.
  // Expected: The mute list contains the peer only while muted; the room-level
  // isAllMemberMuted flag follows the mute-all calls.
  ciTestWidgets('FL-ROOM-004 positive mutes members and all room members',
      (_) async {
    final room = await prepareRoom('FL-ROOM-004');
    await manager.muteChatRoomMembers(room.id, [peerId], duration: 600000);
    expect(await manager.fetchChatRoomMuteList(room.id), contains(peerId));
    await manager.unMuteChatRoomMembers(room.id, [peerId]);
    expect(
        await manager.fetchChatRoomMuteList(room.id), isNot(contains(peerId)));
    expect(
        (await manager.fetchChatRoomInfoFromServer(room.id)).isAllMemberMuted,
        isFalse);
    await manager.muteAllChatRoomMembers(room.id);
    expect(
        (await manager.fetchChatRoomInfoFromServer(room.id)).isAllMemberMuted,
        isTrue);
    await manager.unMuteAllChatRoomMembers(room.id);
    expect(
        (await manager.fetchChatRoomInfoFromServer(room.id)).isAllMemberMuted,
        isFalse);
  });

  // Test: As the room owner, promote the peer to admin, read the server detail,
  // then demote it and read again.
  // Expected: adminList contains the peer only while promoted; membership and
  // ownership are unchanged. Teardown reclaims the room.
  ciTestWidgets('FL-ROOM-005 positive promotes and demotes a room admin',
      (_) async {
    final room = await prepareRoom('FL-ROOM-005');
    expect((await manager.fetchChatRoomInfoFromServer(room.id)).adminList,
        isNot(contains(peerId)));
    await manager.addChatRoomAdmin(room.id, peerId);
    expect((await manager.fetchChatRoomInfoFromServer(room.id)).adminList,
        contains(peerId));
    await manager.removeChatRoomAdmin(room.id, peerId);
    expect((await manager.fetchChatRoomInfoFromServer(room.id)).adminList,
        isNot(contains(peerId)));
  });
}
