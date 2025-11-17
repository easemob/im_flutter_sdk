import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class GroupMemberInfo {
  final String userId;
  final int joinedTs;
  final EMGroupPermissionType role;
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
