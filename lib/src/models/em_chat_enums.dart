enum EMGroupStyle {
  PrivateOnlyOwnerInvite, // 私有群，只有群主能邀请他人进群，被邀请人会收到邀请信息，同意后可入群；
  PrivateMemberCanInvite, // 私有群，所有人都可以邀请他人进群，被邀请人会收到邀请信息，同意后可入群；
  PublicJoinNeedApproval, // 公开群，可以通过获取公开群列表api取的，申请加入时需要管理员以上权限用户同意；
  PublicOpenJoin, // 公开群，可以通过获取公开群列表api取的，可以直接进入；
}

enum EMChatRoomPermissionType {
  None,
  Member,
  Admin,
  Owner,
}
enum EMConversationType {
  Chat, // 单聊消息
  GroupChat, // 群聊消息
  ChatRoom, // 聊天室消息
}

enum EMPushStyle {
  Simple,
  Summary,
}
