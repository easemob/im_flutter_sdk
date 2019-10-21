import "em_domain_terms.dart";

abstract class EMConnectionListener {
  void onConnected();
  void onDisconnected();
}

abstract class EMMultiDeviceListener {
  void onContactEvent(EMContactGroupEvent event, String target, String ext);
  void onGroupEvent(
      EMContactGroupEvent event, String target, List<String> usernames);
}

enum EMContactGroupEvent {
  //TODO: confirm enumeration value sorted correctly
  CONTACT_REMOV,
  CONTACT_ACCEP,
  CONTACT_DECLIN,
  CONTACT_BA,
  CONTACT_ALLO,
  GROUP_CREATE,
  GROUP_DESTROY,
  GROUP_JOIN,
  GROUP_LEAVE,
  GROUP_APPLY,
  GROUP_APPLY_ACCEPT,
  GROUP_APPLY_DECLINE,
  GROUP_INVITE,
  GROUP_INVITE_ACCEPT,
  GROUP_INVITE_DECLINE,
  GROUP_KICK,
  GROUP_BAN,
  GROUP_ALLOW,
  GROUP_BLOCK,
  GROUP_UNBLOCK,
  GROUP_ASSIGN_OWNER,
  GROUP_ADD_ADMIN,
  GROUP_REMOVE_ADMIN,
  GROUP_ADD_MUTE,
  GROUP_REMOVE_MUTE
}

abstract class EMContactEventListener {
  void onContactAdded(String userName);
  void onContactDeleted(String userName);
  void onContactInvited(String userName, String reason);
  void onFriendRequestAccepted(String userName);
  void onFriendRequestDeclined(String userName);
}

enum EMContactChangeEvent {
  CONTACT_ADD,
  CONTACT_DELETE,
  INVITED,
  INVITATION_ACCEPTED,
  INVITATION_DECLINED,
}

abstract class EMMessageListener {
  void onMessageReceived(List<EMMessage> messages);
  void onCmdMessageReceived(List<EMMessage> messages);
  void onMessageRead(List<EMMessage> messages);
  void onMessageDelivered(List<EMMessage> messages);
  void onMessageRecalled(List<EMMessage> messages);
  void onMessageChanged(EMMessage message, Object change);
}

abstract class EMGroupChangeListener {
  void onInvitationReceived(String groupId, String groupName, String inviter, String reason);
  void onRequestToJoinReceived(String groupId, String groupName, String applicant, String reason);
  void onRequestToJoinAccepted(String groupId, String groupName, String accepter);
  void onRequestToJoinDeclined(String groupId, String groupName, String decliner, String reason);
  void onInvitationAccepted(String groupId, String invitee, String reason);
  void onInvitationDeclined(String groupId, String invitee, String reason);
  void onUserRemoved(String groupId, String groupName);
  void onGroupDestroyed(String groupId, String groupName);
  void onAutoAcceptInvitationFromGroup(String groupId, String inviter, String inviteMessage);
  void onMuteListAdded(String groupId, List<String> mutes, int muteExpire);
  void onMuteListRemoved(String groupId, List<String> mutes);
  void onAdminAdded(String groupId, String administrator);
  void onAdminRemoved(String groupId, String administrator);
  void onOwnerChanged(String groupId, String newOwner, String oldOwner);
  void onMemberJoined(String groupId, String member);
  void onMemberExited(String groupId,  String member);
  void onAnnouncementChanged(String groupId, String announcement);
  void onSharedFileAdded(String groupId, EMMucSharedFile sharedFile);
  void onSharedFileDeleted(String groupId, String fileId);
}
