import 'package:agora_chat_sdk/agora_chat_sdk.dart';

class GroupMemberInfo {
  final String userId;
  final int joinedTs;
  final ChatGroupPermissionType role;
  GroupMemberInfo(
    this.userId,
    this.joinedTs,
    this.role,
  );

  GroupMemberInfo.fromJson(Map<String, dynamic> map)
      : userId = map["userId"],
        joinedTs = map["joinedTs"],
        role = ChatGroupPermissionTypeExtension.values(map["role"]);
}
