class EMContactChangeEvent {
  static const String CONTACT_ADD = 'onContactAdded';
  static const String CONTACT_DELETE = 'onContactDeleted';
  static const String INVITED = 'onContactInvited';
  static const String INVITATION_ACCEPTED = 'onFriendRequestAccepted';
  static const String INVITATION_DECLINED = 'onFriendRequestDeclined';
}

class EMChatRoomEvent {
  static const String ON_CHAT_ROOM_DESTROYED = "onChatRoomDestroyed";
  static const String ON_MEMBER_JOINED = "onMemberJoined";
  static const String ON_MEMBER_EXITED = "onMemberExited";
  static const String ON_REMOVED_FROM_CHAT_ROOM = "onRemovedFromChatRoom";
  static const String ON_MUTE_LIST_ADDED = "onMuteListAdded";
  static const String ON_MUTE_LIST_REMOVED = "onMuteListRemoved";
  static const String ON_ADMIN_ADDED = "onAdminAdded";
  static const String ON_ADMIN_REMOVED = "onAdminRemoved";
  static const String ON_OWNER_CHANGED = "onOwnerChanged";
  static const String ON_ANNOUNCEMENT_CHANGED = "onAnnouncementChanged";
  static const String ON_WHITE_LIST_REMOVED = "onWhiteListRemoved";
  static const String ON_WHITE_LIST_ADDED = "onWhiteListAdded";
  static const String ON_ALL_MEMBER_MUTE_STATE_CHANGED =
      "onAllMemberMuteStateChanged";
}

class EMGroupChangeEvent {
  static const String ON_INVITATION_RECEIVED = "onInvitationReceived";
  static const String ON_INVITATION_ACCEPTED = "onInvitationAccepted";
  static const String ON_INVITATION_DECLINED = "onInvitationDeclined";
  static const String ON_AUTO_ACCEPT_INVITATION =
      "onAutoAcceptInvitationFromGroup";
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
  static const String ON_WHITE_LIST_REMOVED = "onWhiteListRemoved";
  static const String ON_WHITE_LIST_ADDED = "onWhiteListAdded";
  static const String ON_ALL_MEMBER_MUTE_STATE_CHANGED =
      "onAllMemberMuteStateChanged";
}
