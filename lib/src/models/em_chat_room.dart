import '../internal/em_transform_tools.dart';

import '../../src/tools/em_extension.dart';
import 'em_chat_enums.dart';

///
/// Chat room types.
///
class EMChatRoom {
  EMChatRoom._private({
    required this.roomId,
    this.name,
    this.description,
    this.owner,
    this.announcement,
    this.memberCount,
    this.maxUsers,
    this.adminList,
    this.memberList,
    this.blockList,
    this.muteList,
    this.isAllMemberMuted,
    this.permissionType = EMChatRoomPermissionType.None,
  });

  String toString() => toJson().toString();

  /// @nodoc
  factory EMChatRoom.fromJson(Map<String, dynamic> map) {
    return EMChatRoom._private(
        roomId: map.getValue('roomId'),
        name: map.getValue("name"),
        description: map.getValue("desc"),
        owner: map.getValue("owner"),
        memberCount: map.getValue("memberCount"),
        maxUsers: map.getValue("maxUsers"),
        adminList: map.listValue<String>("adminList"),
        memberList: map.listValue<String>("memberList"),
        blockList: map.listValue<String>("blockList"),
        muteList: map.listValue<String>("muteList"),
        announcement: map.getValue("announcement"),
        permissionType: chatRoomPermissionTypeFromInt(map.getValue("key")),
        isAllMemberMuted: map.boolValue('isAllMemberMuted'));
  }

  /// @nodoc
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['roomId'] = roomId;
    data.setValueWithOutNull("name", name);
    data.setValueWithOutNull("desc", description);
    data.setValueWithOutNull("owner", owner);
    data.setValueWithOutNull("memberCount", memberCount);
    data.setValueWithOutNull("maxUsers", maxUsers);
    data.setValueWithOutNull("adminList", adminList);
    data.setValueWithOutNull("memberList", memberList);
    data.setValueWithOutNull("blockList", blockList);
    data.setValueWithOutNull("muteList", muteList);
    data.setValueWithOutNull("announcement", announcement);
    data.setValueWithOutNull("isAllMemberMuted", isAllMemberMuted);
    data['permissionType'] = chatRoomPermissionTypeToInt(permissionType);

    return data;
  }

  ///
  /// The chat room ID.
  ///
  final String roomId;

  ///
  /// The chat room name from the memory.
  ///
  /// To get the correct value, ensure that you call {@ link EMChatRoomManager#fetchChatRoomInfoFromServer(String)} before calling this method.
  ///
  final String? name;

  ///
  /// The the chat room description from the memory.
  ///
  /// To get the correct value, ensure that you call {@ link EMChatRoomManager#fetchChatRoomInfoFromServer(String)} before calling this method.
  ///
  final String? description;

  ///
  /// The chat room owner ID. If this method returns an empty string, the SDK fails to get chat room details.
  ///
  /// To get the correct value, ensure that you call {@ link EMChatRoomManager#fetchChatRoomInfoFromServer(String)} before calling this method.
  ///
  final String? owner;

  ///
  /// Get the chat room announcement in the chat room from the memory.
  ///
  /// Ensure that you call {@ link EMChatRoomManager#fetchChatRoomAnnouncement(String)} before calling this method. Otherwise, the return value may not be correct.
  ///
  final String? announcement;

  ///
  /// The number of online members from the memory.
  ///
  /// To get the correct value, ensure that you call {@ link EMChatRoomManager#fetchChatRoomInfoFromServer(String)} before calling this method.
  ///
  final int? memberCount;

  ///
  /// Gets the maximum number of members in the chat room from the memory, which is set/specified when the chat room is created.
  ///
  /// To get the correct value, ensure that you call {@ link EMChatRoomManager#fetchChatRoomInfoFromServer(String)} before calling this method.
  ///
  final int? maxUsers;

  ///
  /// The chat room admin list.
  ///
  final List<String>? adminList;

  ///
  /// The member list.
  ///
  /// You can get the member list in the following ways:
  /// When there are less than 200 members, use {@link EMChatRoomManager#fetchChatRoomInfoFromServer(String, bool?)} to get them.
  /// If true is passed to the second parameter, you can get up to 200 members.
  ///
  final List<String>? memberList;

  ///
  /// The chat room block list.
  ///
  /// To get the block list, you can call {@link EMChatRoomManager#fetchChatRoomBlockList(String, int?, int?)}.
  ///
  final List<String>? blockList;

  ///
  /// The mute list of the chat room.
  ///
  /// To get the mute list, you can call {@link EMChatRoomManager#fetchChatRoomMuteList(String, int?, int?)}.
  ///
  final List<String>? muteList;

  ///
  /// Checks whether all members are muted in the chat room from the memory.
  ///
  /// To get the correct value, ensure that you call {@ link EMChatRoomManager#fetchChatRoomInfoFromServer(String)} before calling this method.
  ///
  final bool? isAllMemberMuted;

  ///
  /// The current user's role in the chat room, see {@link EMChatRoomPermissionType}.
  ///
  /// To get the correct value, ensure that you call {@ link EMChatRoomManager#fetchChatRoomInfoFromServer(String)} before calling this method.
  ///
  final EMChatRoomPermissionType permissionType;
}
