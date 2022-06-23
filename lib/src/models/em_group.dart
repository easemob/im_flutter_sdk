import '../internal/em_transform_tools.dart';

import '../tools/em_extension.dart';
import 'em_chat_enums.dart';
import 'em_group_options.dart';

///
/// 群组信息类，包含内存中的群组相关信息。
///
/// **Note**
/// 如需最新数据，需先从服务器获取：{@link EMGroupManager#fetchGroupInfoFromServer(String)}。
///
class EMGroup {
  EMGroup._private({
    required this.groupId,
    this.name,
    this.description,
    this.owner,
    this.announcement,
    this.memberCount,
    this.memberList,
    this.adminList,
    this.blockList,
    this.muteList,
    this.noticeEnable,
    this.messageBlocked,
    this.isAllMemberMuted,
    this.permissionType,
    this.maxUserCount,
    this.isMemberOnly,
    this.isMemberAllowToInvite,
    this.extension,
  });

  /// 群组 ID。
  final String groupId;

  /// 从内存中获取群组名称。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取：{@link EMGroupManager#fetchGroupInfoFromServer(String)}。
  ///
  /// **Return** 群组名称。
  ///
  final String? name;

  /// 从内存中获取群组描述。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取：{@link EMGroupManager#fetchGroupInfoFromServer(String)}。
  ///
  /// **Return** 群组描述。
  ///
  final String? description;

  /// 从内存中获取群主用户名。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取：{@link EMGroupManager#fetchGroupInfoFromServer(String)}。
  ///
  /// **Return** 群主用户名。
  ///
  final String? owner;

  /// 从内存中获取群公告内容。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取：{@link EMGroupManager#fetchGroupInfoFromServer(String)}。
  ///
  final String? announcement;

  /// 从内存中获取群组成员数量。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取：{@link EMGroupManager#fetchGroupInfoFromServer(String)}。
  ///
  /// **Return** 群组成员数量。
  ///
  final int? memberCount;

  /// 从内存中获取群组成员列表。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取：{@link #fetchMemberListFromServer(String, int?, String?)}.。
  ///
  /// **Return** 群组成员列表。
  ///
  final List<String>? memberList;

  ///
  /// 从内存中获取群组管理员列表。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取：{@link EMGroupManager#fetchGroupInfoFromServer(String)}。
  ///
  /// **Return** 群组管理员列表。
  ///
  final List<String>? adminList;

  ///
  /// 从内存中获取群组黑名单。
  ///
  /// 如果没有找到会返回空列表。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取：{@link EMGroupManager#fetchBlockListFromServer(String, int?, int?)}。
  ///
  /// 只有群主和管理员可以调用该方法。
  ///
  /// **Return** 群组黑名单。
  ///
  final List<String>? blockList;

  ///
  /// 从内存中获取群组禁言名单。
  ///
  /// 只有群主和管理员可以调用该方法。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取：{@link EMGroupManager# fetchMuteListFromServer(String, int?, int?)}。
  ///
  /// **Return** 群组禁言名单。
  ///
  final List<String>? muteList;

  @Deprecated("Switch to using EMPushManager#getNoPushGroupsFromCache instead.")
  final bool? noticeEnable;

  ///
  /// 从内存中获取消息是否被屏蔽。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取： {@link EMGroupManager#fetchGroupInfoFromServer(String)}。
  ///
  /// **Return** 消息是否被屏蔽。
  /// - `true`: 是；
  /// - `false`: 否。
  ///
  final bool? messageBlocked;

  ///
  /// 从内存中获取是否已经全员禁言。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取： {@link EMGroupManager#fetchGroupInfoFromServer(String)}。
  ///
  /// **Return** 是否全员禁言。
  /// - `true`: 是；
  /// - `false`: 否。
  ///
  final bool? isAllMemberMuted;

  ///
  EMGroupOptions? _options;

  /// 从内存中获取当前用户在群组中的角色。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取： {@link EMGroupManager#fetchGroupInfoFromServer(String)}。
  ///
  /// **Return** 当前用户在群组中的角色。
  ///
  final EMGroupPermissionType? permissionType;

  ///
  /// 从内存中获取群组最大人数限制，创建时确定。
  //
  /// **Note**
  /// 如需最新数据，需先从服务器获取： {@link EMGroupManager#fetchGroupInfoFromServer(String)}。
  ///
  /// **Return** 群组最大人数限制。
  ///
  final int? maxUserCount;

  ///
  /// 从内存中获取群组类型：成员是否能自由加入，还是需要申请或者被邀请。
  ///
  /// 群组有四个类型属性，`isMemberOnly`是除了 {@link EMGroupManager.EMGroupStyle#EMGroupStylePublicOpenJoin} 之外的三种属性，表示该群不是自由加入的群组。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取： {@link EMGroupManager#fetchGroupInfoFromServer(String)}。
  ///
  /// **Return**
  ///  - `true`：进群需要群主邀请，群成员邀请，或者群主和管理员同意入群申请；
  /// - `false`：意味着用户可以自由加入群，不需要申请和被邀请。
  ///
  final bool? isMemberOnly;

  ///
  /// 从内存中获取是否允许成员邀请他人进群。
  ///
  /// **Note**
  /// 如需最新数据，需先从服务器获取： {@link EMGroupManager#fetchGroupInfoFromServer(String)}。
  ///
  /// **Return**
  /// - `true`: 允许;
  /// - `false`: 不允许。
  ///
  final bool? isMemberAllowToInvite;

  ///
  /// 群组ext
  ///
  final String? extension;

  /// @nodoc
  factory EMGroup.fromJson(Map map) {
    String groupId = map['groupId'];
    String? name = map.stringValue("name");
    String? description = map.stringValue("desc");
    String? owner = map.stringValue("owner");
    String? announcement = map.stringValue("announcement");
    int? memberCount = map["memberCount"];
    List<String>? memberList = map.listValue<String>("memberList");
    List<String>? adminList = map.listValue<String>("adminList");
    List<String>? blockList = map.listValue<String>("blockList");
    List<String>? muteList = map.listValue<String>("muteList");
    bool? messageBlocked = map.getBoolValue('messageBlocked');
    bool? isAllMemberMuted = map.getBoolValue('isAllMemberMuted');
    EMGroupPermissionType? permissionType =
        permissionTypeFromInt(map['permissionType']);
    int? maxUserCount = map.intValue("maxUserCount");
    bool? isMemberOnly = map.getBoolValue('isMemberOnly');
    bool? isMemberAllowToInvite = map.getBoolValue('isMemberAllowToInvite');
    String? extension = map.getStringValue("ext");

    return EMGroup._private(
      groupId: groupId,
      name: name,
      description: description,
      owner: owner,
      announcement: announcement,
      memberCount: memberCount,
      memberList: memberList,
      adminList: adminList,
      blockList: blockList,
      muteList: muteList,
      messageBlocked: messageBlocked,
      isAllMemberMuted: isAllMemberMuted,
      permissionType: permissionType,
      maxUserCount: maxUserCount,
      isMemberOnly: isMemberOnly,
      isMemberAllowToInvite: isMemberAllowToInvite,
      extension: extension,
    );
  }

  /// @nodoc
  Map toJson() {
    Map data = Map();
    data.setValueWithOutNull("groupId", groupId);
    data.setValueWithOutNull("name", name);
    data.setValueWithOutNull("desc", description);
    data.setValueWithOutNull("owner", owner);
    data.setValueWithOutNull("announcement", announcement);
    data.setValueWithOutNull("memberCount", memberCount);
    data.setValueWithOutNull("memberList", memberList);
    data.setValueWithOutNull("adminList", adminList);
    data.setValueWithOutNull("blockList", blockList);
    data.setValueWithOutNull("muteList", muteList);
    data.setValueWithOutNull("messageBlocked", messageBlocked);
    data.setValueWithOutNull("isAllMemberMuted", isAllMemberMuted);
    data.setValueWithOutNull("options", _options?.toJson());
    data.setValueWithOutNull(
        "permissionType", permissionTypeToInt(permissionType));
    return data;
  }

  @override
  String toString() {
    return this.toJson().toString();
  }
}
