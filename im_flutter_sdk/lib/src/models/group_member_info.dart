import 'package:im_flutter_sdk/im_flutter_sdk.dart';

/// ~english
/// The group member info class, which contains the group member information.
/// ~end
///
/// ~chinese
/// 群成员信息类，包含群成员信息。
/// ~end
class GroupMemberInfo {
  /// ~english
  /// The user ID of the group member.
  /// ~end
  ///
  /// ~chinese
  /// 群成员用户 ID。
  /// ~end
  final String userId;

  final String memberId;

  /// ~english
  /// The timestamp when the user joined the group.
  /// ~end
  ///
  /// ~chinese
  /// 用户加入群组的时间戳。
  /// ~end
  final int joinedTs;

  final int joinTime;

  /// ~english
  /// The role of the group member.
  /// ~end
  ///
  /// ~chinese
  /// 群成员角色。
  /// ~end
  final EMGroupPermissionType role;

  final String? namecard;
  final String? nickname;
  final String? avatarUrl;
  final String? string;

  /// ~english
  /// Creates a group member info.
  /// ~end
  ///
  /// ~chinese
  /// 创建群成员信息。
  /// ~end
  GroupMemberInfo(
    this.userId,
    this.joinedTs,
    this.role,
  )   : memberId = userId,
        joinTime = joinedTs,
        namecard = null,
        nickname = null,
        avatarUrl = null,
        string = null;

  GroupMemberInfo.fromJson(Map<String, dynamic> map)
      : userId = map["userId"],
        memberId = map["memberId"] ?? map["userId"],
        joinedTs = map["joinedTs"] ?? map["joinTime"],
        joinTime = map["joinTime"] ?? map["joinedTs"],
        namecard = map["namecard"],
        nickname = map["nickname"],
        avatarUrl = map["avatarUrl"],
        role = EMGroupPermissionTypeExtension.values(map["role"]),
        string = map["string"];

  Map toJson() {
    Map data = {};
    data["userId"] = userId;
    data["memberId"] = memberId;
    data["joinedTs"] = joinedTs;
    data["joinTime"] = joinTime;
    data["namecard"] = namecard;
    data["nickname"] = nickname;
    data["avatarUrl"] = avatarUrl;
    data["role"] = role.index;
    data["string"] = string;
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
