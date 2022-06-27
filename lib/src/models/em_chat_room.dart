import '../internal/inner_headers.dart';

///
/// 聊天室信息类，包含内存中的聊天室信息。
///
/// **Note**
/// 如需最新数据，需从服务器获取：{@link EMChatRoomManager#fetchChatRoomInfoFromServer}。
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

  /// 从内存中获取聊天室 ID。
  ///
  /// **Note**
  /// 如需最新数据，需从服务器获取：{@link EMChatRoomManager#fetchChatRoomInfoFromServer}。
  ///
  final String roomId;

  /// 从内存中聊天室名称。
  ///
  /// **Note**
  /// 如需最新数据，需从服务器获取：{@link EMChatRoomManager#fetchChatRoomInfoFromServer}。
  ///
  final String? name;

  /// 从内存中聊天室描述。
  ///
  /// **Note**
  /// 如需最新数据，需从服务器获取：{@link EMChatRoomManager#fetchChatRoomInfoFromServer}。
  ///
  final String? description;

  /// 从内存中聊天室所有者 ID。
  ///
  /// **Note**
  /// 如需最新数据，需从服务器获取：{@link EMChatRoomManager#fetchChatRoomInfoFromServer}。
  ///
  final String? owner;

  /// 从内存中聊天室公告。
  ///
  /// **Note**
  /// 如需最新数据，需从服务器获取：{@link EMChatRoomManager#fetchChatRoomInfoFromServer}。
  ///
  final String? announcement;

  ///
  /// 从内存中获取聊天室在线用户数量。
  ///
  /// **Note**
  /// 如需最新数据，需从服务器获取：{@link EMChatRoomManager#fetchChatRoomInfoFromServer}。
  ///
  final int? memberCount;

  ///
  /// 从内存中获取聊天室最大人数限制，在创建聊天室时设置。
  ///
  /// **Note**
  /// 如需最新数据，需从服务器获取：{@link EMChatRoomManager#fetchChatRoomInfoFromServer}。
  ///
  final int? maxUsers;

  ///
  /// 从内存中获取聊天室管理员列表。
  ///
  /// **Note**
  /// 如需最新数据，需从服务器获取：{@link EMChatRoomManager#fetchChatRoomInfoFromServer}。
  ///
  final List<String>? adminList;

  ///
  /// 从内存中获取聊天室成员列表。
  ///
  /// **Note**
  /// 如需最新数据，需从服务器获取：{@link EMChatRoomManager#fetchChatRoomMembers(String, int?, int?)}。
  ///
  final List<String>? memberList;

  ///
  /// 从内存中获取聊天室黑名单列表。
  ///
  /// **Note**
  /// 如果需要获取最新值，请调用：{@link EMChatRoomManager#fetchChatRoomBlockList(String, int?, int?)}。
  ///
  final List<String>? blockList;

  ///
  /// 从内存中获取禁言列表。
  ///
  /// **Note**
  /// 如果需要获取最新值，请调用 {@link EMChatRoomManager#fetchChatRoomMuteList(String, int?, int?)}。
  ///
  final List<String>? muteList;

  ///
  /// 从内存中查看是否在全员禁言状态。
  /// - `true`：开启全员禁言。
  /// - `false`：关闭全员禁言。
  ///
  /// **Note**
  /// 如果需要获取最新值，请调用 {@link EMChatRoomManager#fetchChatRoomInfoFromServer}。
  ///
  final bool? isAllMemberMuted;

  /// 从内存中获取当前用户在聊天室角色，详见 {@link EMChatRoomPermissionType}。
  ///
  /// **Note**
  /// 如果需要获取最新值，请调用 {@link EMChatRoomManager#fetchChatRoomInfoFromServer}。
  ///
  final EMChatRoomPermissionType permissionType;
}
