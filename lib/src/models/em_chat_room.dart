import '../internal/inner_headers.dart';

/// ~english
/// The chat room instance class.
///
/// **Note**
/// To get the correct value, ensure that you call [EMChatRoomManager.fetchChatRoomInfoFromServer] before calling this method.
/// ~end
///
/// ~chinese
/// 聊天室信息类，包含内存中的聊天室信息。
///
/// **Note**
/// 如需最新数据，需从服务器获取：[EMChatRoomManager.fetchChatRoomInfoFromServer]。
/// ~end
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
    this.isInWhitelist = false,
    this.createTimestamp = 0,
    this.muteExpireTimestamp = 0,
  });

  String toString() => toJson().toString();

  factory EMChatRoom.fromJson(Map<String, dynamic> map) {
    return EMChatRoom._private(
      roomId: map["roomId"],
      name: map["name"],
      description: map["desc"],
      owner: map["owner"],
      memberCount: map["memberCount"],
      maxUsers: map["maxUsers"],
      adminList: map.getList("adminList"),
      memberList: map.getList("memberList"),
      blockList: map.getList("blockList"),
      muteList: map.getList("muteList"),
      announcement: map["announcement"],
      permissionType: _ChatRoomPermissionType.values(map["permissionType"]),
      isAllMemberMuted: map.boolValue("isAllMemberMuted"),
      createTimestamp: map["createTimestamp"],
      isInWhitelist: map.boolValue("isInWhitelist"),
      muteExpireTimestamp: map["muteExpireTimestamp"],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['roomId'] = roomId;
    data.putIfNotNull("name", name);
    data.putIfNotNull("desc", description);
    data.putIfNotNull("owner", owner);
    data.putIfNotNull("memberCount", memberCount);
    data.putIfNotNull("maxUsers", maxUsers);
    data.putIfNotNull("adminList", adminList);
    data.putIfNotNull("memberList", memberList);
    data.putIfNotNull("blockList", blockList);
    data.putIfNotNull("muteList", muteList);
    data.putIfNotNull("announcement", announcement);
    data.putIfNotNull("isAllMemberMuted", isAllMemberMuted);
    data['permissionType'] = permissionType.index;
    data.putIfNotNull("isInWhitelist", isInWhitelist);
    data['createTimestamp'] = createTimestamp;
    data['muteExpireTimestamp'] = muteExpireTimestamp;

    return data;
  }

  /// ~english
  /// Gets the chat room ID.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMChatRoomManager.fetchChatRoomInfoFromServer] before calling this method.
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取聊天室 ID。
  ///
  /// **Note**
  /// 如需最新数据，需从服务器获取：[EMChatRoomManager.fetchChatRoomInfoFromServer]。
  /// ~end
  final String roomId;

  /// ~english
  /// Gets the chat room name from the memory.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMChatRoomManager.fetchChatRoomInfoFromServer] before calling this method.
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取聊天室名称。
  ///
  /// **Note**
  /// 如需最新数据，需从服务器获取：[EMChatRoomManager.fetchChatRoomInfoFromServer]。
  /// ~end
  final String? name;

  /// ~english
  /// Gets the chat room description from the memory.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMChatRoomManager.fetchChatRoomInfoFromServer] before calling this method.
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取聊天室描述。
  ///
  /// **Note**
  /// 如需最新数据，需从服务器获取：[EMChatRoomManager.fetchChatRoomInfoFromServer]。
  /// ~end
  final String? description;

  /// ~english
  /// Gets the chat room owner ID. If this method returns an empty string, the SDK fails to get chat room details.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMChatRoomManager.fetchChatRoomInfoFromServer] before calling this method.
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取聊天室所有者 ID。
  ///
  /// **Note**
  /// 如需最新数据，需从服务器获取：[EMChatRoomManager.fetchChatRoomInfoFromServer]。
  /// ~end
  final String? owner;

  /// ~english
  /// Gets the chat room announcement in the chat room from the memory.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMChatRoomManager.fetchChatRoomAnnouncement] before calling this method. Otherwise, the return value may not be correct.
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取聊天室公告。
  ///
  /// **Note**
  /// 如需最新数据，需从服务器获取：[EMChatRoomManager.fetchChatRoomInfoFromServer]。
  /// ~end
  final String? announcement;

  /// ~english
  /// This includes the chat room owner, administrators, and regular members.
  /// You can get this information after joining the chat room.
  /// This property is updated when members join or leave the chat room.
  /// ~end
  ///
  /// ~chinese
  /// 聊天室的当前人数
  /// 包括聊天室所有者、管理员与普通成员
  /// 加入聊天室即可获取
  /// 当聊天室有成员进出时，此属性会更新。
  /// ~end
  final int? memberCount;

  /// ~english
  /// Gets the maximum number of members in the chat room from the memory, which is set/specified when the chat room is created.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMChatRoomManager.fetchChatRoomInfoFromServer] before calling this method.
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取聊天室最大人数限制，在创建聊天室时设置。
  ///
  /// **Note**
  /// 如需最新数据，需从服务器获取：{[EMChatRoomManager.fetchChatRoomInfoFromServer]。
  /// ~end
  final int? maxUsers;

  /// ~english
  /// Gets the chat room admin list.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMChatRoomManager.fetchChatRoomInfoFromServer] before calling this method.
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取聊天室管理员列表。
  ///
  /// **Note**
  /// 如需最新数据，需从服务器获取：[EMChatRoomManager.fetchChatRoomInfoFromServer]。
  /// ~end
  final List<String>? adminList;

  /// ~english
  /// Gets the member list.
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMChatRoomManager.fetchChatRoomMembers].
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取聊天室成员列表。
  ///
  /// **Note**
  /// 如需最新数据，需从服务器获取：[EMChatRoomManager.fetchChatRoomMembers]。
  /// ~end
  final List<String>? memberList;

  /// ~english
  /// Gets the chat room block list.
  ///
  /// **Note**
  /// To get the block list, you can call [EMChatRoomManager.fetchChatRoomBlockList].
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取聊天室黑名单列表。
  ///
  /// **Note**
  /// 如果需要获取最新值，请调用：[EMChatRoomManager.fetchChatRoomBlockList]。
  /// ~end
  final List<String>? blockList;

  /// ~english
  /// Gets the mute list of the chat room.
  ///
  /// **Note**
  /// To get the mute list, you can call [EMChatRoomManager.fetchChatRoomMuteList].
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取禁言列表。
  ///
  /// **Note**
  /// 如果需要获取最新值，请调用 [EMChatRoomManager.fetchChatRoomMuteList]。
  /// ~end
  final List<String>? muteList;

  /// ~english
  /// Checks whether all members are muted,This property is available once join the chat room.
  /// After joining the chat room, when you receive a callback for muting or unmuting all members, this property will be updated.
  /// ~end
  ///
  /// ~chinese
  /// 聊天室成员是否全部被禁言。
  /// 聊天室成员是否全部被禁言,加入聊天室即可获取。
  /// 加入聊天室后，收到一键禁言/取消禁言的回调时，该状态会更新。
  /// ~end
  final bool? isAllMemberMuted;

  /// ~english
  /// Gets the current user's role in the chat room. The role types: [EMChatRoomPermissionType].
  ///
  /// **Note**
  /// To get the correct value, ensure that you call [EMChatRoomManager.fetchChatRoomInfoFromServer] before calling this method.
  /// ~end
  ///
  /// ~chinese
  /// 从内存中获取当前用户在聊天室角色，详见 [EMChatRoomPermissionType]。
  ///
  /// **Note**
  /// 如果需要获取最新值，请调用 [EMChatRoomManager.fetchChatRoomInfoFromServer]。
  /// ~end
  final EMChatRoomPermissionType permissionType;

  /// ~english
  /// Gets the timestamp(ms) when the chat room was created.
  /// This property is available once join the chat room.
  /// ~end
  ///
  /// ~chinese
  /// 获取聊天室创建时间戳（毫秒）。
  /// 只有加入聊天室后可获取。
  /// ~end
  final int createTimestamp;

  /// ~english
  /// Current user is in allow list or not.
  /// This property is available once join the chat room.
  /// This property will be updated when current user is added or removed from the white list.
  /// - `true`: In white list.
  /// - `false`: Not in white list.
  /// ~end
  ///
  /// ~chinese
  /// 当前登录用户是否在白名单中。
  /// 加入聊天室后可获取。
  /// 当前用户被加入或者被移除白名单时，此属性会发生变化。
  /// - `true`: 在白名单中。
  /// - `false`: 不在白名单中。
  /// ~end
  final bool isInWhitelist;

  ///
  /// ~english
  /// Gets the timestamp(ms) when Current user will be unmuted.
  ///
  /// This property is available once join the chat room.
  /// This property will be updated when current use is muted or unmuted.
  ///
  /// - Current use is not muted if it is zero.
  /// - Means cannot get MuteUntilTimeStamp correctly if it is be set with -1;
  /// ~end
  /// ~chinese
  /// 获取当前被禁言截止时间戳（毫秒）。
  ///
  /// 加入聊天室后可获取。
  /// 当前用户被禁言或者被解除禁言时，此属性会被更新。
  ///
  /// - 当取值为0，表示当前用户未被禁言。
  /// - 当取值为-1，表示未能获取到用户被禁言时间戳。
  /// ~end
  final int muteExpireTimestamp;
}

extension _ChatRoomPermissionType on EMChatRoomPermissionType {
  static EMChatRoomPermissionType values(int iValue) {
    return EMChatRoomPermissionType.values[iValue + 1];
  }
}
