/// @nodoc
class EMContactChangeEvent {
  static const String CONTACT_ADD = 'onContactAdded';
  static const String CONTACT_DELETE = 'onContactDeleted';
  static const String INVITED = 'onContactInvited';
  static const String INVITATION_ACCEPTED = 'onFriendRequestAccepted';
  static const String INVITATION_DECLINED = 'onFriendRequestDeclined';
}

/// @nodoc
class EMChatRoomEvent {
  static const String ON_CHAT_ROOM_DESTROYED = "chatroomDestroyed";
  static const String ON_MEMBER_JOINED = "chatroomMemberJoined";
  static const String ON_MEMBER_EXITED = "chatroomMemberExited";
  static const String ON_REMOVED_FROM_CHAT_ROOM = "chatroomRemoved";
  static const String ON_MUTE_LIST_ADDED = "chatroomMuteListAdded";
  static const String ON_MUTE_LIST_REMOVED = "chatroomMuteListRemoved";
  static const String ON_ADMIN_ADDED = "chatroomAdminAdded";
  static const String ON_ADMIN_REMOVED = "chatroomAdminRemoved";
  static const String ON_OWNER_CHANGED = "chatroomOwnerChanged";
  static const String ON_ANNOUNCEMENT_CHANGED = "chatroomAnnouncementChanged";
  static const String ON_WHITE_LIST_REMOVED = "chatroomWhiteListRemoved";
  static const String ON_WHITE_LIST_ADDED = "chatroomWhiteListAdded";
  static const String ON_ALL_MEMBER_MUTE_STATE_CHANGED =
      "chatroomAllMemberMuteStateChanged";
  static const String ON_SPECIFICATION_CHANGED = "chatroomSpecificationChanged";
  static const String ON_ATTRIBUTES_UPDATED = "chatroomAttributesDidUpdated";
  static const String ON_ATTRIBUTES_REMOVED = "chatroomAttributesDidRemoved";
}

/// @nodoc
class EMGroupChangeEvent {
  static const String ON_INVITATION_RECEIVED = "groupInvitationReceived";
  static const String ON_INVITATION_ACCEPTED = "groupInvitationAccepted";
  static const String ON_INVITATION_DECLINED = "groupInvitationDeclined";
  static const String ON_AUTO_ACCEPT_INVITATION = "groupAutoAcceptInvitation";
  static const String ON_USER_REMOVED = "groupUserRemoved";
  static const String ON_REQUEST_TO_JOIN_RECEIVED =
      "groupRequestToJoinReceived";
  static const String ON_REQUEST_TO_JOIN_DECLINED =
      "groupRequestToJoinDeclined";
  static const String ON_REQUEST_TO_JOIN_ACCEPTED =
      "groupRequestToJoinAccepted";
  static const String ON_GROUP_DESTROYED = "groupDestroyed";
  static const String ON_MUTE_LIST_ADDED = "groupMuteListAdded";
  static const String ON_MUTE_LIST_REMOVED = "groupMuteListRemoved";
  static const String ON_ADMIN_ADDED = "groupAdminAdded";
  static const String ON_ADMIN_REMOVED = "groupAdminRemoved";
  static const String ON_OWNER_CHANGED = "groupOwnerChanged";
  static const String ON_MEMBER_JOINED = "groupMemberJoined";
  static const String ON_MEMBER_EXITED = "groupMemberExited";
  static const String ON_ANNOUNCEMENT_CHANGED = "groupAnnouncementChanged";
  static const String ON_SHARED_FILE_ADDED = "groupSharedFileAdded";
  static const String ON_SHARED_FILE__DELETED = "groupSharedFileDeleted";
  static const String ON_WHITE_LIST_REMOVED = "groupWhiteListRemoved";
  static const String ON_WHITE_LIST_ADDED = "groupWhiteListAdded";
  static const String ON_ALL_MEMBER_MUTE_STATE_CHANGED =
      "groupAllMemberMuteStateChanged";
  static const String ON_SPECIFICATION_DID_UPDATE =
      "groupSpecificationDidUpdate";
  static const String ON_STATE_CHANGED = "groupStateChanged";
}
