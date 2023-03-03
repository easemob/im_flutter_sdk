import '../internal/inner_headers.dart';

///
/// The chat room instance class.
///
/// **Note**
/// To get the correct value, ensure that you call [EMChatRoomManager.fetchChatRoomInfoFromServer] before calling this method.
///
class EMChatRoom {
  EMChatRoom._private({
    required this.roomId,
    this.name = '',
    this.description = '',
    this.owner = '',
    this.announcement = '',
    this.memberCount = 0,
    this.maxUsers = 0,
    required this.adminList,
    required this.memberList,
    required this.blockList,
    required this.muteList,
    this.isAllMemberMuted = false,
    this.permissionType = EMChatRoomPermissionType.None,
  });

  String toString() => toJson().toString();

  /// @nodoc
  factory EMChatRoom.fromJson(Map<String, dynamic> map) {
    return EMChatRoom._private(
        roomId: map["roomId"],
        name: map["name"] ?? '',
        description: map["desc"] ?? '',
        owner: map["owner"] ?? '',
        memberCount: map["memberCount"] ?? 0,
        maxUsers: map["maxUsers"] ?? 0,
        adminList: List.from(map["adminList"] ?? []),
        memberList: List.from(map["memberList"] ?? []),
        blockList: List.from(map["blockList"] ?? []),
        muteList: List.from(map["muteList"] ?? []),
        announcement: map["announcement"] ?? '',
        permissionType: chatRoomPermissionTypeFromInt(map["permissionType"]),
        isAllMemberMuted: map.boolValue("isAllMemberMuted"));
  }

  /// @nodoc
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['roomId'] = roomId;
    data.add("name", name);
    data.add("desc", description);
    data.add("owner", owner);
    data.add("memberCount", memberCount);
    data.add("maxUsers", maxUsers);
    data.add("adminList", adminList);
    data.add("memberList", memberList);
    data.add("blockList", blockList);
    data.add("muteList", muteList);
    data.add("announcement", announcement);
    data.add("isAllMemberMuted", isAllMemberMuted);
    data['permissionType'] = chatRoomPermissionTypeToInt(permissionType);

    return data;
  }

  ///
  /// Gets the chat room ID.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMChatRoomManager.fetchChatRoomInfoFromServer] before calling this method.
  ///
  final String roomId;

  ///
  /// Gets the chat room name from the memory.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMChatRoomManager.fetchChatRoomInfoFromServer] before calling this method.
  ///
  final String name;

  ///
  /// Gets the chat room description from the memory.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMChatRoomManager.fetchChatRoomInfoFromServer] before calling this method.
  ///
  final String description;

  ///
  /// Gets the chat room owner ID. If this method returns an empty string, the SDK fails to get chat room details.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMChatRoomManager.fetchChatRoomInfoFromServer] before calling this method.
  ///
  final String owner;

  ///
  /// Gets the chat room announcement in the chat room from the memory.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMChatRoomManager.fetchChatRoomAnnouncement] before calling this method. Otherwise, the return value may not be correct.
  ///
  final String announcement;

  ///
  /// Gets the number of online members from the memory.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMChatRoomManager.fetchChatRoomInfoFromServer] before calling this method.
  ///
  final int memberCount;

  ///
  /// Gets the maximum number of members in the chat room from the memory, which is set/specified when the chat room is created.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMChatRoomManager.fetchChatRoomInfoFromServer] before calling this method.
  ///
  final int maxUsers;

  ///
  /// Gets the chat room admin list.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMChatRoomManager.fetchChatRoomInfoFromServer] before calling this method.
  ///
  final List<String> adminList;

  ///
  /// Gets the member list.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMChatRoomManager.fetchChatRoomMembers].
  ///
  final List<String> memberList;

  ///
  /// Gets the chat room block list.
  ///
  /// **Note**
  /// To get the block list, you can call [EMChatRoomManager.fetchChatRoomBlockList].
  ///
  final List<String> blockList;

  ///
  /// Gets the mute list of the chat room.
  ///
  /// **Note**
  /// To get the mute list, you can call [EMChatRoomManager.fetchChatRoomMuteList].
  ///
  final List<String> muteList;

  ///
  /// Checks whether all members are muted in the chat room from the memory.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMChatRoomManager.fetchChatRoomInfoFromServer] before calling this method.
  ///
  final bool isAllMemberMuted;

  ///
  /// Gets the current user's role in the chat room. The role types: [EMChatRoomPermissionType].
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMChatRoomManager.fetchChatRoomInfoFromServer] before calling this method.
  ///
  final EMChatRoomPermissionType permissionType;
}
