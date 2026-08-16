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

  /// ~english
  /// The timestamp when the user joined the group.
  /// ~end
  ///
  /// ~chinese
  /// 用户加入群组的时间戳。
  /// ~end
  final int joinedTs;

  /// ~english
  /// The role of the group member.
  /// ~end
  ///
  /// ~chinese
  /// 群成员角色。
  /// ~end
  final EMGroupPermissionType role;

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
  );

  GroupMemberInfo.fromJson(Map<String, dynamic> map)
      : userId = map["userId"],
        joinedTs = map["joinedTs"],
        role = EMGroupPermissionTypeExtension.values(map["role"]);
}
