import "em_domain_terms.dart";

abstract class EMConnectionListener {
  void onConnected();
  void onDisconnected(int errorCode);
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


class EMChatRoomEvent{
  static const String ON_CHAT_ROOM_DESTROYED  = "onChatRoomDestroyed";
  static const String ON_MEMBER_JOINED  = "onMemberJoined";
  static const String ON_MEMBER_EXITED  = "onMemberExited";
  static const String ON_REMOVED_FROM_CHAT_ROOM  = "onRemovedFromChatRoom";
  static const String ON_MUTE_LIST_ADDED  = "onMuteListAdded";
  static const String ON_MUTE_LIST_REMOVED  = "onMuteListRemoved";
  static const String ON_ADMIN_ADDED  = "onAdminAdded";
  static const String ON_ADMIN_REMOVED  = "onAdminRemoved";
  static const String ON_OWNER_CHANGED  = "onOwnerChanged";
  static const String ON_ANNOUNCEMENT_CHANGED  = "onAnnouncementChanged";
}

abstract class EMChatRoomEventListener{
  void onChatRoomDestroyed(String roomId, String roomName);
  void onMemberJoined(String roomId, String participant);
  void onMemberExited(String roomId, String roomName, String participant);
  void onRemovedFromChatRoom(int reason, String roomId, String roomName, String participant);
  void onMuteListAdded(String chatRoomId, List mutes, String expireTime);
  void onMuteListRemoved(String chatRoomId, List mutes);
  void onAdminAdded(String chatRoomId, String admin);
  void onAdminRemoved(String chatRoomId, String admin);
  void onOwnerChanged(String chatRoomId, String newOwner, String oldOwner);
  void onAnnouncementChanged(String chatRoomId, String announcement);
}

class EMGroupChangeEvent {
  static const String ON_INVITATION_RECEIVED = "onInvitationReceived";
  static const String ON_INVITATION_ACCEPTED = "onInvitationAccepted";
  static const String ON_INVITATION_DECLINED = "onInvitationDeclined";
  static const String ON_AUTO_ACCEPT_INVITATION = "onAutoAcceptInvitationFromGroup";
  static const String ON_USER_REMOVED = "onUserRemoved";
  static const String ON_REQUEST_TO_JOIN_RECEIVED = "onRequestToJoinReceived";
  static const String ON_REQUEST_TO_JOIN_DECLINED = "onRequestToJoinDeclined";
  static const String ON_REQUEST_TO_JOIN_ACCEPTED = "onRequestToJoinAccepted";
  static const String ON_GROUP_DESTROYED = "onGroupDestroyed";
  static const String ON_MUTE_LIST_ADDED = "onMuteListAdded";
  static const String ON_MUTE_LIST_REMOVED = "onMuteListRemoved";
  static const String ON_ADMIN_ADDED = "onAdminAdded";
  static const String ON_ADMIN_REMOVED = "onAdminRemoved";
  static const String ON_OWNER_CHANGED = "onOwnerChanged";
  static const String ON_MEMBER_JOINED = "onMemberJoined";
  static const String ON_MEMBER_EXITED = "onMemberExited";
  static const String ON_ANNOUNCEMENT_CHANGED = "onAnnouncementChanged";
  static const String ON_SHARED_FILE_ADDED = "onSharedFileAdded";
  static const String ON_SHARED_FILE__DELETED = "onSharedFileDeleted";
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
  void onMuteListAdded(String groupId, List mutes, int muteExpire);
  void onMuteListRemoved(String groupId, List mutes);
  void onAdminAdded(String groupId, String administrator);
  void onAdminRemoved(String groupId, String administrator);
  void onOwnerChanged(String groupId, String newOwner, String oldOwner);
  void onMemberJoined(String groupId, String member);
  void onMemberExited(String groupId,  String member);
  void onAnnouncementChanged(String groupId, String announcement);
  void onSharedFileAdded(String groupId, EMMucSharedFile sharedFile);
  void onSharedFileDeleted(String groupId, String fileId);
}

