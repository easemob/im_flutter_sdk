import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class EMChatManagerListenerCallback implements EMChatManagerListener {
  final void Function(List<EMMessage> messages)? onCmdMessagesReceivedCallback;
  final void Function(String from, String to)? onConversationReadCallback;
  final VoidCallback? onConversationsUpdateCallback;
  final void Function(List<EMGroupMessageAck> groupMessageAcks)?
      onGroupMessageReadCallback;
  final void Function(List<EMMessageReactionEvent> events)?
      onMessageReactionDidChangeCallback;
  final void Function(List<EMMessage> messages)? onMessagesDeliveredCallback;
  final void Function(List<EMMessage> messages)? onMessagesReadCallback;
  final void Function(List<EMMessage> messages)? onMessagesRecalledCallback;
  final void Function(List<EMMessage> messages)? onMessagesReceivedCallback;
  final VoidCallback? onReadAckForGroupMessageUpdatedCallback;
  EMChatManagerListenerCallback({
    this.onCmdMessagesReceivedCallback,
    this.onConversationReadCallback,
    this.onConversationsUpdateCallback,
    this.onGroupMessageReadCallback,
    this.onMessageReactionDidChangeCallback,
    this.onMessagesDeliveredCallback,
    this.onMessagesReadCallback,
    this.onMessagesRecalledCallback,
    this.onMessagesReceivedCallback,
    this.onReadAckForGroupMessageUpdatedCallback,
  });

  @override
  void onCmdMessagesReceived(List<EMMessage> messages) {
    this.onCmdMessagesReceivedCallback?.call(messages);
  }

  @override
  void onConversationRead(String from, String to) {
    this.onConversationReadCallback?.call(from, to);
  }

  @override
  void onConversationsUpdate() {
    this.onConversationsUpdateCallback?.call();
  }

  @override
  void onGroupMessageRead(List<EMGroupMessageAck> groupMessageAcks) {
    this.onGroupMessageReadCallback?.call(groupMessageAcks);
  }

  @override
  void onMessageReactionDidChange(List<EMMessageReactionEvent> list) {
    this.onMessageReactionDidChangeCallback?.call(list);
  }

  @override
  void onMessagesDelivered(List<EMMessage> messages) {
    this.onMessagesDeliveredCallback?.call(messages);
  }

  @override
  void onMessagesRead(List<EMMessage> messages) {
    this.onMessagesReadCallback?.call(messages);
  }

  @override
  void onMessagesRecalled(List<EMMessage> messages) {
    this.onMessagesRecalledCallback?.call(messages);
  }

  @override
  void onMessagesReceived(List<EMMessage> messages) {
    this.onMessagesReceivedCallback?.call(messages);
  }

  @override
  void onReadAckForGroupMessageUpdated() {
    this.onReadAckForGroupMessageUpdatedCallback?.call();
  }
}

class EMChatRoomManagerListenerCallback implements EMChatRoomManagerListener {
  final void Function(
    String roomId,
    String admin,
  )? onAdminAddedFromChatRoomCallback;

  final void Function(
    String roomId,
    String admin,
  )? onAdminRemovedFromChatRoomCallback;

  final void Function(
    String roomId,
    bool isAllMuted,
  )? onAllChatRoomMemberMuteStateChangedCallback;

  final void Function(
    String roomId,
    List<String> members,
  )? onAllowListAddedFromChatRoomCallback;

  final void Function(
    String roomId,
    List<String> members,
  )? onAllowListRemovedFromChatRoomCallback;

  final void Function(
    String roomId,
    String announcement,
  )? onAnnouncementChangedFromChatRoomCallback;

  final void Function(
    String roomId,
    String? roomName,
  )? onChatRoomDestroyedCallback;

  final void Function(
    String roomId,
    String? roomName,
    String participant,
  )? onMemberExitedFromChatRoomCallback;

  final void Function(
    String roomId,
    String participant,
  )? onMemberJoinedFromChatRoomCallback;

  final void Function(
    String roomId,
    List<String> mutes,
    String? expireTime,
  )? onMuteListAddedFromChatRoomCallback;

  final void Function(
    String roomId,
    List<String> mutes,
  )? onMuteListRemovedFromChatRoomCallback;

  final void Function(
    String roomId,
    String newOwner,
    String oldOwner,
  )? onOwnerChangedFromChatRoomCallback;

  final void Function(
    String roomId,
    String? roomName,
    String? participant,
  )? onRemovedFromChatRoomCallback;

  EMChatRoomManagerListenerCallback({
    this.onAdminAddedFromChatRoomCallback,
    this.onAdminRemovedFromChatRoomCallback,
    this.onAllChatRoomMemberMuteStateChangedCallback,
    this.onAllowListAddedFromChatRoomCallback,
    this.onAllowListRemovedFromChatRoomCallback,
    this.onAnnouncementChangedFromChatRoomCallback,
    this.onChatRoomDestroyedCallback,
    this.onMemberExitedFromChatRoomCallback,
    this.onMemberJoinedFromChatRoomCallback,
    this.onMuteListAddedFromChatRoomCallback,
    this.onMuteListRemovedFromChatRoomCallback,
    this.onOwnerChangedFromChatRoomCallback,
    this.onRemovedFromChatRoomCallback,
  });

  @override
  void onAdminAddedFromChatRoom(
    String roomId,
    String admin,
  ) {
    this.onAdminAddedFromChatRoomCallback?.call(
          roomId,
          admin,
        );
  }

  @override
  void onAdminRemovedFromChatRoom(
    String roomId,
    String admin,
  ) {
    this.onAdminRemovedFromChatRoomCallback?.call(
          roomId,
          admin,
        );
  }

  @override
  void onAllChatRoomMemberMuteStateChanged(
    String roomId,
    bool isAllMuted,
  ) {
    this.onAllChatRoomMemberMuteStateChangedCallback?.call(
          roomId,
          isAllMuted,
        );
  }

  @override
  void onAllowListAddedFromChatRoom(
    String roomId,
    List<String> members,
  ) {
    this.onAllowListAddedFromChatRoomCallback?.call(
          roomId,
          members,
        );
  }

  @override
  void onAllowListRemovedFromChatRoom(
    String roomId,
    List<String> members,
  ) {
    this.onAllowListRemovedFromChatRoomCallback?.call(
          roomId,
          members,
        );
  }

  @override
  void onAnnouncementChangedFromChatRoom(
    String roomId,
    String announcement,
  ) {
    this.onAnnouncementChangedFromChatRoomCallback?.call(
          roomId,
          announcement,
        );
  }

  @override
  void onChatRoomDestroyed(
    String roomId,
    String? roomName,
  ) {
    this.onChatRoomDestroyedCallback?.call(
          roomId,
          roomName,
        );
  }

  @override
  void onMemberExitedFromChatRoom(
    String roomId,
    String? roomName,
    String participant,
  ) {
    this.onMemberExitedFromChatRoomCallback?.call(
          roomId,
          roomName,
          participant,
        );
  }

  @override
  void onMemberJoinedFromChatRoom(
    String roomId,
    String participant,
  ) {
    this.onMemberJoinedFromChatRoomCallback?.call(
          roomId,
          participant,
        );
  }

  @override
  void onMuteListAddedFromChatRoom(
    String roomId,
    List<String> mutes,
    String? expireTime,
  ) {
    this.onMuteListAddedFromChatRoomCallback?.call(
          roomId,
          mutes,
          expireTime,
        );
  }

  @override
  void onMuteListRemovedFromChatRoom(
    String roomId,
    List<String> mutes,
  ) {
    this.onMuteListRemovedFromChatRoomCallback?.call(
          roomId,
          mutes,
        );
  }

  @override
  void onOwnerChangedFromChatRoom(
    String roomId,
    String newOwner,
    String oldOwner,
  ) {
    this.onOwnerChangedFromChatRoomCallback?.call(
          roomId,
          newOwner,
          oldOwner,
        );
  }

  @override
  void onRemovedFromChatRoom(
    String roomId,
    String? roomName,
    String? participant,
  ) {
    this.onRemovedFromChatRoomCallback?.call(
          roomId,
          roomName,
          participant,
        );
    ;
  }
}

class EMChatThreadManagerListenerCallback
    implements EMChatThreadManagerListener {
  final void Function(
    EMChatThreadEvent event,
  )? onChatThreadCreateCallback;

  final void Function(
    EMChatThreadEvent event,
  )? onChatThreadDestroyCallback;

  final void Function(
    EMChatThreadEvent event,
  )? onChatThreadUpdateCallback;

  final void Function(
    EMChatThreadEvent event,
  )? onUserKickOutOfChatThreadCallback;

  EMChatThreadManagerListenerCallback({
    this.onChatThreadCreateCallback,
    this.onChatThreadDestroyCallback,
    this.onChatThreadUpdateCallback,
    this.onUserKickOutOfChatThreadCallback,
  });

  @override
  void onChatThreadCreate(EMChatThreadEvent event) {
    this.onChatThreadCreateCallback?.call(event);
  }

  @override
  void onChatThreadDestroy(EMChatThreadEvent event) {
    this.onChatThreadDestroyCallback?.call(event);
  }

  @override
  void onChatThreadUpdate(EMChatThreadEvent event) {
    this.onChatThreadUpdateCallback?.call(event);
  }

  @override
  void onUserKickOutOfChatThread(EMChatThreadEvent event) {
    this.onUserKickOutOfChatThreadCallback?.call(event);
  }
}

class EMContactManagerListenerCallback implements EMContactManagerListener {
  final void Function(
    String userId,
  )? onContactAddedCallback;

  final void Function(
    String userId,
  )? onContactDeletedCallback;

  final void Function(
    String userId,
    String? reason,
  )? onContactInvitedCallback;

  final void Function(
    String userId,
  )? onFriendRequestAcceptedCallback;

  final void Function(
    String userId,
  )? onFriendRequestDeclinedCallback;

  EMContactManagerListenerCallback({
    this.onContactAddedCallback,
    this.onContactDeletedCallback,
    this.onContactInvitedCallback,
    this.onFriendRequestAcceptedCallback,
    this.onFriendRequestDeclinedCallback,
  });

  @override
  void onContactAdded(String userName) {
    this.onContactAddedCallback?.call(userName);
  }

  @override
  void onContactDeleted(String userName) {
    this.onContactDeletedCallback?.call(userName);
  }

  @override
  void onContactInvited(String userName, String? reason) {
    this.onContactInvitedCallback?.call(userName, reason);
  }

  @override
  void onFriendRequestAccepted(String userName) {
    this.onFriendRequestAcceptedCallback?.call(userName);
  }

  @override
  void onFriendRequestDeclined(String userName) {
    this.onFriendRequestDeclinedCallback?.call(userName);
  }
}

class EMGroupManagerListenerCallback implements EMGroupManagerListener {
  final void Function(
    String groupId,
    String admin,
  )? onAdminAddedFromGroupCallback;

  final void Function(
    String groupId,
    String admin,
  )? onAdminRemovedFromGroupCallback;

  final void Function(
    String groupId,
    bool isAllMuted,
  )? onAllGroupMemberMuteStateChangedCallback;

  final void Function(
    String groupId,
    List<String> members,
  )? onAllowListAddedFromGroupCallback;

  final void Function(
    String groupId,
    List<String> members,
  )? onAllowListRemovedFromGroupCallback;

  final void Function(
    String groupId,
    String announcement,
  )? onAnnouncementChangedFromGroupCallback;

  final void Function(
    String groupId,
    String inviter,
    String? inviteMessage,
  )? onAutoAcceptInvitationFromGroupCallback;

  final void Function(
    String groupId,
    String? groupName,
  )? onGroupDestroyedCallback;

  final void Function(
    String groupId,
    String invitee,
    String? reason,
  )? onInvitationAcceptedFromGroupCallback;

  final void Function(
    String groupId,
    String invitee,
    String? reason,
  )? onInvitationDeclinedFromGroupCallback;

  final void Function(
    String groupId,
    String? groupName,
    String inviter,
    String? reason,
  )? onInvitationReceivedFromGroupCallback;

  final void Function(
    String groupId,
    String member,
  )? onMemberExitedFromGroupCallback;

  final void Function(
    String groupId,
    String member,
  )? onMemberJoinedFromGroupCallback;

  final void Function(
    String groupId,
    List<String> mutes,
    int? muteExpire,
  )? onMuteListAddedFromGroupCallback;

  final void Function(
    String groupId,
    List<String> mutes,
  )? onMuteListRemovedFromGroupCallback;

  final void Function(
    String groupId,
    String newOwner,
    String oldOwner,
  )? onOwnerChangedFromGroupCallback;

  final void Function(
    String groupId,
    String? groupName,
    String accepter,
  )? onRequestToJoinAcceptedFromGroupCallback;

  final void Function(
    String groupId,
    String? groupName,
    String decliner,
    String? reason,
  )? onRequestToJoinDeclinedFromGroupCallback;

  final void Function(
    String groupId,
    String? groupName,
    String applicant,
    String? reason,
  )? onRequestToJoinReceivedFromGroupCallback;

  final void Function(
    String groupId,
    EMGroupSharedFile sharedFile,
  )? onSharedFileAddedFromGroupCallback;

  final void Function(
    String groupId,
    String fileId,
  )? onSharedFileDeletedFromGroupCallback;

  final void Function(
    String groupId,
    String? groupName,
  )? onUserRemovedFromGroupCallback;

  EMGroupManagerListenerCallback({
    this.onAdminAddedFromGroupCallback,
    this.onAdminRemovedFromGroupCallback,
    this.onAllGroupMemberMuteStateChangedCallback,
    this.onAllowListAddedFromGroupCallback,
    this.onAllowListRemovedFromGroupCallback,
    this.onAnnouncementChangedFromGroupCallback,
    this.onAutoAcceptInvitationFromGroupCallback,
    this.onGroupDestroyedCallback,
    this.onInvitationAcceptedFromGroupCallback,
    this.onInvitationDeclinedFromGroupCallback,
    this.onInvitationReceivedFromGroupCallback,
    this.onMemberExitedFromGroupCallback,
    this.onMemberJoinedFromGroupCallback,
    this.onMuteListAddedFromGroupCallback,
    this.onMuteListRemovedFromGroupCallback,
    this.onOwnerChangedFromGroupCallback,
    this.onRequestToJoinAcceptedFromGroupCallback,
    this.onRequestToJoinDeclinedFromGroupCallback,
    this.onRequestToJoinReceivedFromGroupCallback,
    this.onSharedFileAddedFromGroupCallback,
    this.onSharedFileDeletedFromGroupCallback,
    this.onUserRemovedFromGroupCallback,
  });

  @override
  void onAdminAddedFromGroup(
    String groupId,
    String admin,
  ) {
    this.onAdminAddedFromGroupCallback?.call(
          groupId,
          admin,
        );
  }

  @override
  void onAdminRemovedFromGroup(
    String groupId,
    String admin,
  ) {
    this.onAdminRemovedFromGroupCallback?.call(
          groupId,
          admin,
        );
  }

  @override
  void onAllGroupMemberMuteStateChanged(
    String groupId,
    bool isAllMuted,
  ) {
    this.onAllGroupMemberMuteStateChangedCallback?.call(
          groupId,
          isAllMuted,
        );
  }

  @override
  void onAllowListAddedFromGroup(
    String groupId,
    List<String> members,
  ) {
    this.onAllowListAddedFromGroupCallback?.call(
          groupId,
          members,
        );
  }

  @override
  void onAllowListRemovedFromGroup(
    String groupId,
    List<String> members,
  ) {
    this.onAllowListRemovedFromGroupCallback?.call(
          groupId,
          members,
        );
  }

  @override
  void onAnnouncementChangedFromGroup(
    String groupId,
    String announcement,
  ) {
    this.onAnnouncementChangedFromGroupCallback?.call(
          groupId,
          announcement,
        );
  }

  @override
  void onAutoAcceptInvitationFromGroup(
    String groupId,
    String inviter,
    String? inviteMessage,
  ) {
    this.onAutoAcceptInvitationFromGroupCallback?.call(
          groupId,
          inviter,
          inviteMessage,
        );
  }

  @override
  void onGroupDestroyed(
    String groupId,
    String? groupName,
  ) {
    this.onGroupDestroyedCallback?.call(
          groupId,
          groupName,
        );
  }

  @override
  void onInvitationAcceptedFromGroup(
    String groupId,
    String invitee,
    String? reason,
  ) {
    this.onInvitationAcceptedFromGroupCallback?.call(
          groupId,
          invitee,
          reason,
        );
  }

  @override
  void onInvitationDeclinedFromGroup(
    String groupId,
    String invitee,
    String? reason,
  ) {
    this.onInvitationDeclinedFromGroupCallback?.call(
          groupId,
          invitee,
          reason,
        );
  }

  @override
  void onInvitationReceivedFromGroup(
    String groupId,
    String? groupName,
    String inviter,
    String? reason,
  ) {
    this.onInvitationReceivedFromGroupCallback?.call(
          groupId,
          groupName,
          inviter,
          reason,
        );
  }

  @override
  void onMemberExitedFromGroup(
    String groupId,
    String member,
  ) {
    this.onMemberExitedFromGroupCallback?.call(
          groupId,
          member,
        );
  }

  @override
  void onMemberJoinedFromGroup(
    String groupId,
    String member,
  ) {
    this.onMemberJoinedFromGroupCallback?.call(
          groupId,
          member,
        );
  }

  @override
  void onMuteListAddedFromGroup(
    String groupId,
    List<String> mutes,
    int? muteExpire,
  ) {
    this.onMuteListAddedFromGroupCallback?.call(
          groupId,
          mutes,
          muteExpire,
        );
  }

  @override
  void onMuteListRemovedFromGroup(
    String groupId,
    List<String> mutes,
  ) {
    this.onMuteListRemovedFromGroupCallback?.call(
          groupId,
          mutes,
        );
  }

  @override
  void onOwnerChangedFromGroup(
    String groupId,
    String newOwner,
    String oldOwner,
  ) {
    this.onOwnerChangedFromGroupCallback?.call(
          groupId,
          newOwner,
          oldOwner,
        );
  }

  @override
  void onRequestToJoinAcceptedFromGroup(
    String groupId,
    String? groupName,
    String accepter,
  ) {
    this.onRequestToJoinAcceptedFromGroupCallback?.call(
          groupId,
          groupName,
          accepter,
        );
  }

  @override
  void onRequestToJoinDeclinedFromGroup(
    String groupId,
    String? groupName,
    String decliner,
    String? reason,
  ) {
    this.onRequestToJoinDeclinedFromGroupCallback?.call(
          groupId,
          groupName,
          decliner,
          reason,
        );
  }

  @override
  void onRequestToJoinReceivedFromGroup(
    String groupId,
    String? groupName,
    String applicant,
    String? reason,
  ) {
    this.onRequestToJoinReceivedFromGroupCallback?.call(
          groupId,
          groupName,
          applicant,
          reason,
        );
  }

  @override
  void onSharedFileAddedFromGroup(
    String groupId,
    EMGroupSharedFile sharedFile,
  ) {
    this.onSharedFileAddedFromGroupCallback?.call(
          groupId,
          sharedFile,
        );
  }

  @override
  void onSharedFileDeletedFromGroup(
    String groupId,
    String fileId,
  ) {
    this.onSharedFileDeletedFromGroupCallback?.call(
          groupId,
          fileId,
        );
  }

  @override
  void onUserRemovedFromGroup(
    String groupId,
    String? groupName,
  ) {
    this.onUserRemovedFromGroupCallback?.call(
          groupId,
          groupName,
        );
  }
}

class EMPresenceManagerListenerCallback implements EMPresenceManagerListener {
  final Function(List<EMPresence> list)? onPresenceStatusChangedCallback;

  EMPresenceManagerListenerCallback({
    this.onPresenceStatusChangedCallback,
  });

  @override
  void onPresenceStatusChanged(List<EMPresence> list) {
    this.onPresenceStatusChangedCallback?.call(list);
  }
}
