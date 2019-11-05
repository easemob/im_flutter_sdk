import "em_domain_terms.dart";

abstract class EMConnectionListener {
  void onConnected();
  void onDisconnected(int errorCode);
}

abstract class EMMultiDeviceListener {
  void onContactEvent(int event, String target, String ext);
  void onGroupEvent(
      int event, String target, List<String> usernames);
}

class EMContactGroupEvent {
  static const int  CONTACT_REMOVE = 2;
  static const int	CONTACT_ACCEPT = 3;
  static const int 	CONTACT_DECLINE = 4;
  static const int 	CONTACT_BAN = 5;
  static const int 	CONTACT_ALLOW = 6;
  static const int 	GROUP_CREATE = 10;
  static const int 	GROUP_DESTROY = 11;
  static const int 	GROUP_JOIN = 12;
  static const int 	GROUP_LEAVE = 13;
  static const int 	GROUP_APPLY = 14;
  static const int 	GROUP_APPLY_ACCEPT = 15;
  static const int 	GROUP_APPLY_DECLINE = 16;
  static const int 	GROUP_INVITE = 17;
  static const int 	GROUP_INVITE_ACCEPT = 18;
  static const int 	GROUP_INVITE_DECLINE = 19;
  static const int 	GROUP_KICK = 20;
  static const int 	GROUP_BAN = 21;
  static const int 	GROUP_ALLOW = 22;
  static const int 	GROUP_BLOCK = 23;
  static const int 	GROUP_UNBLOCK = 24;
  static const int 	GROUP_ASSIGN_OWNER = 25;
  static const int 	GROUP_ADD_ADMIN = 26;
  static const int 	GROUP_REMOVE_ADMIN = 27;
  static const int 	GROUP_ADD_MUTE = 28;
  static const int 	GROUP_REMOVE_MUTE = 29;
}

abstract class EMContactEventListener {
  void onContactAdded(String userName);
  void onContactDeleted(String userName);
  void onContactInvited(String userName, String reason);
  void onFriendRequestAccepted(String userName);
  void onFriendRequestDeclined(String userName);
}

class EMContactChangeEvent {

  static const String CONTACT_ADD = "onContactAdded";
  static const String CONTACT_DELETE = "onContactDeleted";
  static const String INVITED = "onContactInvited";
  static const String INVITATION_ACCEPTED = "onFriendRequestAccepted";
  static const String INVITATION_DECLINED = "onFriendRequestDeclined";
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
class EMGroupChangeEvent {
  static const String ON_INVITATION_RECEIVED = "onInvitationReceived";
  static const String ON_INVITATION_ACCEPTED = "onInvitationAccepted";
  static const String ON_INVITATION_DECLINED = "onInvitationDeclined";
  static const String ON_AUTO_ACCEPT_INVITATION = "onAutoAcceptInvitationFromGroup";
  static const String ON_USER_REMOVED = "onUserRemoved";
  static const String ON_REQUEST_TO_JOIN_RECEIVED = "onRequestToJoinReceived";
  static const String ON_REQUEST_TO_JOIN_DECLINED = "onRequestToJoinAccepted";
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
