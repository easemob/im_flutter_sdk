class EMContactChangeEvent {
  static const String CONTACT_ADD = 'onContactAdded';
  static const String CONTACT_DELETE = 'onContactDeleted';
  static const String INVITED = 'onContactInvited';
  static const String INVITATION_ACCEPTED = 'onFriendRequestAccepted';
  static const String INVITATION_DECLINED = 'onFriendRequestDeclined';
}

class EMChatRoomEvent {
  static const String ON_CHAT_ROOM_DESTROYED = "onRoomDestroyed";
  static const String ON_MEMBER_JOINED = "onRoomMemberJoined";
  static const String ON_MEMBER_EXITED = "onRoomMemberExited";
  static const String ON_REMOVED_FROM_CHAT_ROOM = "onRoomRemoved";
  static const String ON_MUTE_LIST_ADDED = "onRoomMuteListAdded";
  static const String ON_MUTE_LIST_REMOVED = "onRoomMuteListRemoved";
  static const String ON_ADMIN_ADDED = "onRoomAdminAdded";
  static const String ON_ADMIN_REMOVED = "onRoomAdminRemoved";
  static const String ON_OWNER_CHANGED = "onRoomOwnerChanged";
  static const String ON_ANNOUNCEMENT_CHANGED = "onRoomAnnouncementChanged";
  static const String ON_WHITE_LIST_REMOVED = "onRoomWhiteListRemoved";
  static const String ON_WHITE_LIST_ADDED = "onRoomWhiteListAdded";
  static const String ON_ALL_MEMBER_MUTE_STATE_CHANGED =
      "onRoomAllMemberMuteStateChanged";
  static const String ON_SPECIFICATION_CHANGED = "onRoomSpecificationChanged";
  static const String ON_ATTRIBUTES_UPDATED = "onRoomAttributesDidUpdated";
  static const String ON_ATTRIBUTES_REMOVED = "onRoomAttributesDidRemoved";
}

class EMGroupChangeEvent {
  static const String ON_INVITATION_RECEIVED = "onGroupInvitationReceived";
  static const String ON_INVITATION_ACCEPTED = "onGroupInvitationAccepted";
  static const String ON_INVITATION_DECLINED = "onGroupInvitationDeclined";
  static const String ON_AUTO_ACCEPT_INVITATION = "onGroupAutoAcceptInvitation";
  static const String ON_USER_REMOVED = "onGroupUserRemoved";
  static const String ON_REQUEST_TO_JOIN_RECEIVED =
      "onGroupRequestToJoinReceived";
  static const String ON_REQUEST_TO_JOIN_DECLINED =
      "onGroupRequestToJoinDeclined";
  static const String ON_REQUEST_TO_JOIN_ACCEPTED =
      "onGroupRequestToJoinAccepted";
  static const String ON_GROUP_DESTROYED = "onGroupDestroyed";
  static const String ON_MUTE_LIST_ADDED = "onGroupMuteListAdded";
  static const String ON_MUTE_LIST_REMOVED = "onGroupMuteListRemoved";
  static const String ON_ADMIN_ADDED = "onGroupAdminAdded";
  static const String ON_ADMIN_REMOVED = "onGroupAdminRemoved";
  static const String ON_OWNER_CHANGED = "onGroupOwnerChanged";
  static const String ON_MEMBER_JOINED = "onGroupMemberJoined";
  static const String ON_MEMBER_EXITED = "onGroupMemberExited";
  static const String ON_ANNOUNCEMENT_CHANGED = "onGroupAnnouncementChanged";
  static const String ON_SHARED_FILE_ADDED = "onGroupSharedFileAdded";
  static const String ON_SHARED_FILE__DELETED = "onGroupSharedFileDeleted";
  static const String ON_WHITE_LIST_REMOVED = "onGroupWhiteListRemoved";
  static const String ON_WHITE_LIST_ADDED = "onGroupWhiteListAdded";
  static const String ON_ALL_MEMBER_MUTE_STATE_CHANGED =
      "onGroupAllMemberMuteStateChanged";
  static const String ON_SPECIFICATION_DID_UPDATE =
      "onGroupSpecificationDidUpdate";
  static const String ON_STATE_CHANGED = "onGroupStateChanged";
  static const String ON_ATTRIBUTES_CHANGED_OF_MEMBER =
      "onGroupAttributesChangedOfMember";
}
