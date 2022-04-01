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
        permissionType: EMChatRoom.permissionTypeFromInt(map.getValue("key")),
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
    data['permissionType'] = EMChatRoom.permissionTypeToInt(permissionType);

    return data;
  }

  /// The chat room ID.
  final String roomId;

  /// The chat room name.
  final String? name;

  /// The chat room description.
  final String? description;

  /// The chat room owner ID. If this method returns an empty string, the SDK fails to get chat room details.
  final String? owner;

  /// The chat room announcement.
  ///
  /// To get the chat room announcement, you can call {@link EMChatRoomManager#fetchChatRoomAnnouncement(String)}
  ///
  /// **return** The chat room announcement. If this method returns an empty string, the SDK fails to get the chat room announcement.
  ///
  final String? announcement;

  ///
  /// The number of online members.
  ///
  final int? memberCount;

  ///
  /// The maximum number of members in the chat room which is determined during chat room creation.
  ///
  /// This method can return a correct value only after you call EMChatRoomManager#fetchChatRoomInfoFromServer(String) to get chat room details.
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
  /// Checks whether all members are muted.
  ///
  final bool? isAllMemberMuted;
  // 在聊天室中的角色
  final EMChatRoomPermissionType permissionType;

  static EMChatRoomPermissionType permissionTypeFromInt(int? type) {
    EMChatRoomPermissionType ret = EMChatRoomPermissionType.Member;
    switch (type) {
      case -1:
        return EMChatRoomPermissionType.None;
      case 0:
        return EMChatRoomPermissionType.Member;
      case 1:
        return EMChatRoomPermissionType.Admin;
      case 2:
        return EMChatRoomPermissionType.Owner;
    }
    return ret;
  }

  static int permissionTypeToInt(EMChatRoomPermissionType type) {
    int ret = 0;
    switch (type) {
      case EMChatRoomPermissionType.None:
        ret = -1;
        break;
      case EMChatRoomPermissionType.Member:
        ret = 0;
        break;
      case EMChatRoomPermissionType.Admin:
        ret = 1;
        break;
      case EMChatRoomPermissionType.Owner:
        ret = 2;
        break;
    }
    return ret;
  }
}
