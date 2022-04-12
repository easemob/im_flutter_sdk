import '../internal/em_transform_tools.dart';

import '../../src/tools/em_extension.dart';
import 'em_chat_enums.dart';

///
/// The chat room instance class.
///
/// **Note**
/// To get the correct value, ensure that you call {@ link EMChatRoomManager#fetchChatRoomInfoFromServer(String)} before calling this method.
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
        roomId: map["roomId"],
        name: map.getStringValue("name"),
        description: map.getStringValue("desc"),
        owner: map.getStringValue("owner"),
        memberCount: map.getIntValue("memberCount"),
        maxUsers: map.getIntValue("maxUsers"),
        adminList: map.listValue<String>("adminList"),
        memberList: map.listValue<String>("memberList"),
        blockList: map.listValue<String>("blockList"),
        muteList: map.listValue<String>("muteList"),
        announcement: map.getStringValue("announcement"),
        permissionType:
            chatRoomPermissionTypeFromInt(map.getIntValue("permissionType")),
        isAllMemberMuted: map.boolValue("isAllMemberMuted"));
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
  /// Gets the chat room ID.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call {@ link EMChatRoomManager#fetchChatRoomInfoFromServer(String)} before calling this method.
  ///
  final String roomId;

  ///
  /// Gets the chat room name from the memory.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call {@ link EMChatRoomManager#fetchChatRoomInfoFromServer(String)} before calling this method.
  ///
  final String? name;

  ///
  /// Gets the chat room description from the memory.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call {@ link EMChatRoomManager#fetchChatRoomInfoFromServer(String)} before calling this method.
  ///
  final String? description;

  ///
  /// Gets the chat room owner ID. If this method returns an empty string, the SDK fails to get chat room details.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call {@ link EMChatRoomManager#fetchChatRoomInfoFromServer(String)} before calling this method.
  ///
  final String? owner;

  ///
  /// Gets the chat room announcement in the chat room from the memory.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call {@ link EMChatRoomManager#fetchChatRoomAnnouncement(String)} before calling this method. Otherwise, the return value may not be correct.
  ///
  final String? announcement;

  ///
  /// Gets the number of online members from the memory.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call {@ link EMChatRoomManager#fetchChatRoomInfoFromServer(String)} before calling this method.
  ///
  final int? memberCount;

  ///
  /// Gets the maximum number of members in the chat room from the memory, which is set/specified when the chat room is created.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call {@ link EMChatRoomManager#fetchChatRoomInfoFromServer(String)} before calling this method.
  ///
  final int? maxUsers;

  ///
  /// Gets the chat room admin list.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call {@ link EMChatRoomManager#fetchChatRoomInfoFromServer(String)} before calling this method.
  ///
  final List<String>? adminList;

  ///
  /// Gets the member list.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call {@link EMChatRoomManager#fetchChatRoomMembers(String, bool?)}
  ///
  final List<String>? memberList;

  ///
  /// Gets the chat room block list.
  ///
  /// **Note**
  /// To get the block list, you can call {@link EMChatRoomManager#fetchChatRoomBlockList(String, int?, int?)}.
  ///
  final List<String>? blockList;

  ///
  /// Gets the mute list of the chat room.
  ///
  /// **Note**
  /// To get the mute list, you can call {@link EMChatRoomManager#fetchChatRoomMuteList(String, int?, int?)}.
  ///
  final List<String>? muteList;

  ///
  /// Checks whether all members are muted in the chat room from the memory.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call {@link EMChatRoomManager#fetchChatRoomInfoFromServer(String)} before calling this method.
  ///
  final bool? isAllMemberMuted;

  ///
  /// Gets the current user's role in the chat room. The role types: {@link EMChatRoomPermissionType}.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call {@link EMChatRoomManager#fetchChatRoomInfoFromServer(String)} before calling this method.
  ///
  final EMChatRoomPermissionType permissionType;
}
