import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

///
/// The connection event handler.
///
/// For the occasion of onDisconnected during unstable network condition, you don't need to reconnect manually,
/// the chat SDK will handle it automatically.
///
/// Note: We recommend not to update UI based on those methods, because this method is called on worker thread. If you update UI in those methods, other UI errors might be invoked.
/// Also do not insert heavy computation work here, which might invoke other listeners to handle this connection event.
///
/// Adds connection event handler:
/// ```dart
///   EMClient.getInstance.addConnectionEventHandler(UNIQUE_HANDLER_ID, EMConnectionEventHandler());
/// ```
///
/// Remove a connection event handler:
/// ```dart
///   EMClient.getInstance.removeConnectionEventHandler(UNIQUE_HANDLER_ID);
/// ```
///
class EMConnectionEventHandler {
  ///
  /// Occurs when the SDK connects to the chat server successfully.
  ///
  final VoidCallback? onConnected;

  ///
  /// Occurs when the SDK disconnect from the chat server.
  ///
  /// Note that the logout may not be performed at the bottom level when the SDK is disconnected.
  ///
  final VoidCallback? onDisconnected;

  ///
  /// Occurs when the current user account is logged in to another device.
  ///
  final VoidCallback? onUserDidLoginFromOtherDevice;

  ///
  /// Occurs when the current chat user is removed from the server.
  ///
  final VoidCallback? onUserDidRemoveFromServer;

  ///
  /// Occurs when the current chat user is forbid from the server.
  ///
  final VoidCallback? onUserDidForbidByServer;

  ///
  /// Occurs when the current chat user is changed password.
  ///
  final VoidCallback? onUserDidChangePassword;

  ///
  /// Occurs when the current chat user logged to many devices.
  ///
  final VoidCallback? onUserDidLoginTooManyDevice;

  ///
  /// Occurs when the current chat user kicked by other device.
  ///
  final VoidCallback? onUserKickedByOtherDevice;

  ///
  /// Occurs when the current chat user authentication failed.
  ///
  final VoidCallback? onUserAuthenticationFailed;

  ///
  /// Occurs when the token is about to expire.
  ///
  final VoidCallback? onTokenWillExpire;

  ///
  /// Occurs when the token has expired.
  ///
  final VoidCallback? onTokenDidExpire;

  ///
  /// The chat connection listener callback.
  ///
  /// Param [onConnected] The SDK connects to the chat server successfully callback.
  ///
  /// Param [onDisconnected] The SDK disconnect from the chat server callback.
  ///
  /// Param [onUserDidLoginFromOtherDevice] Current user account is logged in to another device callback.
  ///
  /// Param [onUserDidRemoveFromServer] Current chat user is removed from the server callback.
  ///
  /// Param [onUserDidForbidByServer] Current chat user is forbid from the server callback.
  ///
  /// Param [onUserDidChangePassword] Current chat user is changed password callback.
  ///
  /// Param [onUserDidLoginTooManyDevice] Current chat user logged to many devices callback.
  ///
  /// Param [onUserKickedByOtherDevice] Current chat user kicked by other device callback.
  ///
  /// Param [onUserAuthenticationFailed] Current chat user authentication failed callback.
  ///
  /// Param [onTokenWillExpire] The token is about to expire callback.
  ///
  /// Param [onTokenDidExpire] The token has expired callback.
  ///
  EMConnectionEventHandler({
    this.onConnected,
    this.onDisconnected,
    this.onUserDidLoginFromOtherDevice,
    this.onUserDidRemoveFromServer,
    this.onUserDidForbidByServer,
    this.onUserDidChangePassword,
    this.onUserDidLoginTooManyDevice,
    this.onUserKickedByOtherDevice,
    this.onUserAuthenticationFailed,
    this.onTokenWillExpire,
    this.onTokenDidExpire,
  });
}

///
/// The multi-device event handler.
/// Listens for callback for the current user's actions on other devices, including contact changes and group changes.
///
/// Adds multi-device event handler:
/// ```dart
///   EMClient.getInstance.addMultiDeviceEventHandler((UNIQUE_HANDLER_ID, EMMultiDeviceEventHandler());
/// ```
///
/// Remove a multi-device event handler:
/// ```dart
///   EMClient.getInstance.removeMultiDeviceEventHandler(UNIQUE_HANDLER_ID);
/// ```
///
class EMMultiDeviceEventHandler {
  /// The multi-device event of contact.
  final void Function(
    EMMultiDevicesEvent event,
    String userId,
    String? ext,
  )? onContactEvent;

  /// The multi-device event of group.
  final void Function(
    EMMultiDevicesEvent event,
    String groupId,
    List<String>? userIds,
  )? onGroupEvent;

  /// The multi-device event of thread.
  final void Function(
    EMMultiDevicesEvent event,
    String chatThreadId,
    List<String> userIds,
  )? onChatThreadEvent;

  /// The multi-device event handler.
  ///
  /// Param [onContactEvent] The multi-device event of contact.
  ///
  /// Param [onGroupEvent] The multi-device event of group.
  ///
  /// Param [onChatThreadEvent] The multi-device event of thread.
  ///
  EMMultiDeviceEventHandler({
    this.onContactEvent,
    this.onGroupEvent,
    this.onChatThreadEvent,
  });
}

///
/// The chat event handler.
///
/// This handler is used to check whether messages are received. If messages are sent successfully, a delivery receipt will be returned (delivery receipt needs to be enabled: [EMOptions.requireDeliveryAck].
/// If the peer reads the received message, a read receipt will be returned (read receipt needs to be enabled: [EMOptions.requireAck]).
/// During message delivery, the message ID will be changed from a local uuid to a global unique ID that is generated by the server to uniquely identify a message on all devices using the SDK.
/// This API should be implemented in the app to listen for message status changes.
///
/// Adds chat event handler:
/// ```dart
///   EMClient.getInstance.chatManager.addEventHandler(UNIQUE_HANDLER_ID, EMChatEventHandler());
/// ```
///
/// Remove a chat event handler:
/// ```dart
///   EMClient.getInstance.chatManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
///
class EMChatEventHandler {
  ///
  /// Occurs when a message is received callback.
  ///
  /// This callback is triggered to notify the user when a message such as texts or an image, video, voice, location, or file is received.
  ///
  final void Function(List<EMMessage> messages)? onMessagesReceived;

  ///
  /// Occurs when a command message is received.
  ///
  /// This callback only contains a command message body that is usually invisible to users.
  ///
  final void Function(List<EMMessage> messages)? onCmdMessagesReceived;

  ///
  /// Occurs when a read receipt is received for a message.
  ///
  final void Function(List<EMMessage> messages)? onMessagesRead;

  ///
  /// Occurs when a read receipt is received for a group message.
  ///
  final void Function(List<EMGroupMessageAck> groupMessageAcks)?
      onGroupMessageRead;

  ///
  /// Occurs when the update for the group message read status is received.
  ///
  final VoidCallback? onReadAckForGroupMessageUpdated;

  ///
  /// Occurs when a delivery receipt is received.
  ///
  final void Function(List<EMMessage> messages)? onMessagesDelivered;

  ///
  /// Occurs when a received message is recalled.
  ///
  final void Function(List<EMMessage> messages)? onMessagesRecalled;

  ///
  /// Occurs when the conversation updated.
  ///
  final VoidCallback? onConversationsUpdate;

  ///
  /// Occurs when a conversation read receipt is received.
  ///
  /// Occurs in the following scenarios:
  /// (1) The message is read by the receiver (The conversation receipt is sent).
  /// Upon receiving this event, the SDK sets the [EMMessage.hasReadAck] property of the message in the conversation to `true` in the local database.
  /// (2) In the multi-device login scenario, when one device sends a Conversation receipt,
  /// the server will set the number of unread messages to 0, and the callback occurs on the other devices.
  /// and sets the [EMMessage.hasReadAck] property of the message in the conversation to `true` in the local database.
  ///
  final void Function(String from, String to)? onConversationRead;

  ///
  /// Occurs when the Reaction data changes.
  ///
  final void Function(List<EMMessageReactionEvent> events)?
      onMessageReactionDidChange;

  ///
  /// The chat event handler.
  ///
  /// Param [onMessagesReceived] Message is received callback.
  ///
  /// Param [onCmdMessagesReceived] Command message is received callback.
  ///
  /// Param [onMessagesRead] Read receipt is received for a message callback.
  ///
  /// Param [onGroupMessageRead] Read receipt is received for a group message callback.
  ///
  /// Param [onReadAckForGroupMessageUpdated] Group message read status is received callback.
  ///
  /// Param [onMessagesDelivered] Delivery receipt is received callback.
  ///
  /// Param [onMessagesRecalled] Received message is recalled callback.
  ///
  /// Param [onConversationsUpdate] Conversation updated callback.
  ///
  /// Param [onConversationRead] Conversation read receipt is received callback.
  ///
  /// Param [onMessageReactionDidChange] Reaction data changes callback.
  ///
  EMChatEventHandler({
    this.onMessagesReceived,
    this.onCmdMessagesReceived,
    this.onMessagesRead,
    this.onGroupMessageRead,
    this.onReadAckForGroupMessageUpdated,
    this.onMessagesDelivered,
    this.onMessagesRecalled,
    this.onConversationsUpdate,
    this.onConversationRead,
    this.onMessageReactionDidChange,
  });
}

///
/// The chat room event handler.
///
/// Adds chat event handler:
/// ```dart
///   EMClient.getInstance.chatRoomManager.addEventHandler(UNIQUE_HANDLER_ID, EMChatRoomEventHandler());
/// ```
///
/// Remove a chat room event handler:
/// ```dart
///   EMClient.getInstance.chatRoomManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
///
class EMChatRoomEventHandler {
  ///
  /// Occurs when a member has been changed to an admin.
  ///
  final void Function(
    String roomId,
    String admin,
  )? onAdminAddedFromChatRoom;

  ///
  /// Occurs when an admin is been removed.
  ///
  final void Function(
    String roomId,
    String admin,
  )? onAdminRemovedFromChatRoom;

  ///
  /// Occurs when all members in the chat room are muted or unmuted.
  ///
  final void Function(
    String roomId,
    bool isAllMuted,
  )? onAllChatRoomMemberMuteStateChanged;

  ///
  /// Occurs when the chat room member(s) is added to the allowlist.
  ///
  final void Function(
    String roomId,
    List<String> members,
  )? onAllowListAddedFromChatRoom;

  ///
  /// Occurs when the chat room member(s) is removed from the allowlist.
  ///
  final void Function(
    String roomId,
    List<String> members,
  )? onAllowListRemovedFromChatRoom;

  ///
  /// Occurs when the announcement changed.
  ///
  final void Function(
    String roomId,
    String announcement,
  )? onAnnouncementChangedFromChatRoom;

  ///
  /// Occurs when the chat room is destroyed.
  ///
  final void Function(
    String roomId,
    String? roomName,
  )? onChatRoomDestroyed;

  ///
  /// Occurs when a member leaves the chatroom.
  ///
  final void Function(
    String roomId,
    String? roomName,
    String participant,
  )? onMemberExitedFromChatRoom;

  ///
  /// Occurs when a member join the chatroom.
  ///
  final void Function(String roomId, String participant)?
      onMemberJoinedFromChatRoom;

  ///
  /// Occurs when there are chat room member(s) muted (added to mute list),
  ///
  final void Function(
    String roomId,
    List<String> mutes,
    String? expireTime,
  )? onMuteListAddedFromChatRoom;

  ///
  /// Occurs when there are chat room member(s) unmuted (removed from mute list).
  ///
  final void Function(
    String roomId,
    List<String> mutes,
  )? onMuteListRemovedFromChatRoom;

  ///
  ///  Occurs when the chat room ownership has been transferred.
  ///
  final void Function(
    String roomId,
    String newOwner,
    String oldOwner,
  )? onOwnerChangedFromChatRoom;

  ///
  /// Occurs when a member is dismissed from a chat room.
  ///
  final void Function(
    String roomId,
    String? roomName,
    String? participant,
  )? onRemovedFromChatRoom;
  
  /// Occurs when the chat room specifications changes. All chat room members receive this event.
  final void Function(EMChatRoom room)? onSpecificationChanged;

  /// Occurs when the custom chat room attributes (key-value) are updated.
  final void Function(
    String roomId,
    Map<String, String> attributes,
    String from,
  )? onAttributesUpdated;

  /// Occurs when the custom chat room attributes (key-value) are removed.
  final void Function(
    String roomId,
    List<String> removedKeys,
    String from,
  )? onAttributesRemoved;

  ///
  /// The chat room manager listener callback.
  ///
  /// Param [onAdminAddedFromChatRoom] A member has been changed to an admin callback.
  ///
  /// Param [onAdminRemovedFromChatRoom] An admin is been removed callback callback.
  ///
  /// Param [onAllChatRoomMemberMuteStateChanged] All members in the chat room are muted or unmuted callback.
  ///
  /// Param [onAllowListAddedFromChatRoom] The chat room member(s) is added to the allowlist callback.
  ///
  /// Param [onAllowListRemovedFromChatRoom] The chat room member(s) is removed from the allowlist callback.
  ///
  /// Param [onAnnouncementChangedFromChatRoom] The announcement changed callback.
  ///
  /// Param [onChatRoomDestroyed] The chat room is destroyed callback.
  ///
  /// Param [onMemberExitedFromChatRoom] A member leaves the chatroom callback.
  ///
  /// Param [onMemberJoinedFromChatRoom] A member join the chatroom callback.
  ///
  /// Param [onMuteListAddedFromChatRoom] The chat room member(s) muted (added to mute list) callback.
  ///
  /// Param [onMuteListRemovedFromChatRoom] The chat room member(s) unmuted (removed from mute list) callback.
  ///
  /// Param [onOwnerChangedFromChatRoom] The chat room ownership has been transferred callback.
  ///
  /// Param [onRemovedFromChatRoom] The chat room member(s) is removed from the allowlist callback.
  ///
  /// Param [onSpecificationChanged] The chat room specification changed callback.
  ///
  /// Param [onAttributesUpdated] The chat room attributes updated callback.
  ///
  /// Param [onAttributesRemoved] The chat room attributes removed callback.
  ///
  EMChatRoomEventHandler({
    this.onAdminAddedFromChatRoom,
    this.onAdminRemovedFromChatRoom,
    this.onAllChatRoomMemberMuteStateChanged,
    this.onAllowListAddedFromChatRoom,
    this.onAllowListRemovedFromChatRoom,
    this.onAnnouncementChangedFromChatRoom,
    this.onChatRoomDestroyed,
    this.onMemberExitedFromChatRoom,
    this.onMemberJoinedFromChatRoom,
    this.onMuteListAddedFromChatRoom,
    this.onMuteListRemovedFromChatRoom,
    this.onOwnerChangedFromChatRoom,
    this.onRemovedFromChatRoom,
    this.onSpecificationChanged,
    this.onAttributesUpdated,
    this.onAttributesRemoved,
  });
}

///
/// The message thread event handler. which handle for message thread events such as creating or leaving a message thread.
///
/// Adds a message thread event handler:
/// ```dart
///   EMClient.getInstance.chatThreadManager.addEventHandler(UNIQUE_HANDLER_ID, EMChatThreadEventHandler());
/// ```
///
/// Remove a chat event handler:
/// ```dart
/// EMClient.getInstance.chatThreadManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
///
class EMChatThreadEventHandler {
  ///
  /// Occurs when a message thread is created.
  ///
  /// Each member of the group to which the message thread belongs can receive the callback.
  ///
  final void Function(
    EMChatThreadEvent event,
  )? onChatThreadCreate;

  ///
  /// Occurs when a message thread is destroyed.
  ///
  /// Each member of the group to which the message thread belongs can receive the callback.
  ///
  final void Function(
    EMChatThreadEvent event,
  )? onChatThreadDestroy;

  ///
  /// Occurs when a message thread is updated.
  ///
  /// This callback is triggered when the message thread name is changed or a threaded reply is added or recalled.
  ///
  /// Each member of the group to which the message thread belongs can receive the callback.
  ///
  final void Function(
    EMChatThreadEvent event,
  )? onChatThreadUpdate;

  ///
  /// Occurs when the current user is removed from the message thread by the group owner or a group admin to which the message thread belongs.
  ///
  final void Function(
    EMChatThreadEvent event,
  )? onUserKickOutOfChatThread;

  ///
  /// The message thread listener callback
  ///
  /// Param [onChatThreadCreate] A message thread is created callback.
  ///
  /// Param [onChatThreadDestroy] A message thread is destroyed callback.
  ///
  /// Param [onChatThreadUpdate] A message thread is updated callback.
  ///
  /// Param [onUserKickOutOfChatThread] Current user is removed from the message thread by the group owner or a group admin to which the message thread belongs callback.
  ///
  EMChatThreadEventHandler({
    this.onChatThreadCreate,
    this.onChatThreadDestroy,
    this.onChatThreadUpdate,
    this.onUserKickOutOfChatThread,
  });
}

///
/// The contact event handler.
///
/// Occurs when the contact changes, including requests to add friends, notifications to delete friends,
/// requests to accept friends, and requests to reject friends.
///
/// Adds a contact event handler:
/// ```dart
///   EMClient.getInstance.contactManager.addEventHandler(UNIQUE_HANDLER_ID, EMContactEventHandler());
/// ```
///
/// Remove a contact event handler:
/// ```dart
///   EMClient.getInstance.contactManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
///
class EMContactEventHandler {
  ///
  /// Occurs when user is added as a contact by another user.
  ///
  final void Function(
    String userId,
  )? onContactAdded;

  ///
  /// Occurs when a user is removed from the contact list by another user.
  ///
  final void Function(
    String userId,
  )? onContactDeleted;

  ///
  /// Occurs when a user receives a friend request.
  ///
  final void Function(
    String userId,
    String? reason,
  )? onContactInvited;

  ///
  /// Occurs when a friend request is approved.
  ///
  final void Function(
    String userId,
  )? onFriendRequestAccepted;

  ///
  /// Occurs when a friend request is declined.
  ///
  final void Function(
    String userId,
  )? onFriendRequestDeclined;

  ///
  /// The contact updates listener callback.
  ///
  /// Param [onContactAdded] Current user is added as a contact by another user callback.
  ///
  /// Param [onContactDeleted] Current user is removed from the contact list by another user callback.
  ///
  /// Param [onContactInvited] Current user receives a friend request callback.
  ///
  /// Param [onFriendRequestAccepted] A friend request is approved callback.
  ///
  /// Param [onFriendRequestDeclined] A friend request is declined callback.
  ///
  EMContactEventHandler({
    this.onContactAdded,
    this.onContactDeleted,
    this.onContactInvited,
    this.onFriendRequestAccepted,
    this.onFriendRequestDeclined,
  });
}

///
/// The group event handler.
///
/// Occurs when the following group events happens: requesting to join a group, approving or declining a group request, and kicking a user out of a group.
///
/// Adds a group event handler:
/// ```dart
///   EMClient.getInstance.groupManager.addEventHandler(UNIQUE_HANDLER_ID, EMGroupEventHandler());
/// ```
///
/// Remove a group event handler:
/// ```dart
///   EMClient.getInstance.groupManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
///
class EMGroupEventHandler {
  ///
  /// Occurs when a member is set as an admin.
  ///
  final void Function(
    String groupId,
    String admin,
  )? onAdminAddedFromGroup;

  ///
  /// Occurs when a member's admin privileges are removed.
  ///
  final void Function(
    String groupId,
    String admin,
  )? onAdminRemovedFromGroup;

  ///
  /// Occurs when all group members are muted or unmuted.
  ///
  final void Function(
    String groupId,
    bool isAllMuted,
  )? onAllGroupMemberMuteStateChanged;

  ///
  /// Occurs when one or more group members are added to the allowlist.
  ///
  final void Function(
    String groupId,
    List<String> members,
  )? onAllowListAddedFromGroup;

  ///
  /// Occurs when one or more members are removed from the allowlist.
  ///
  final void Function(
    String groupId,
    List<String> members,
  )? onAllowListRemovedFromGroup;

  ///
  /// Occurs when the announcement is updated.
  ///
  final void Function(
    String groupId,
    String announcement,
  )? onAnnouncementChangedFromGroup;

  ///
  /// Occurs when the group invitation is accepted automatically.
  /// For settings, See [EMOptions.autoAcceptGroupInvitation].
  /// The SDK will join the group before notifying the app of the acceptance of the group invitation.
  ///
  final void Function(
    String groupId,
    String inviter,
    String? inviteMessage,
  )? onAutoAcceptInvitationFromGroup;

  ///
  /// Occurs when a group is destroyed.
  ///
  final void Function(
    String groupId,
    String? groupName,
  )? onGroupDestroyed;

  ///
  /// Occurs when a group invitation is accepted.
  ///
  final void Function(
    String groupId,
    String invitee,
    String? reason,
  )? onInvitationAcceptedFromGroup;

  ///
  /// Occurs when a group invitation is declined.
  ///
  final void Function(
    String groupId,
    String invitee,
    String? reason,
  )? onInvitationDeclinedFromGroup;

  ///
  /// Occurs when the user receives a group invitation.
  ///
  final void Function(
    String groupId,
    String? groupName,
    String inviter,
    String? reason,
  )? onInvitationReceivedFromGroup;

  ///
  /// Occurs when a member proactively leaves the group.
  ///
  final void Function(
    String groupId,
    String member,
  )? onMemberExitedFromGroup;

  ///
  /// Occurs when a member joins a group.
  ///
  final void Function(
    String groupId,
    String member,
  )? onMemberJoinedFromGroup;

  ///
  /// Occurs when one or more group members are muted.
  ///
  /// Note: The mute function is different from a block list.
  /// A user, when muted, can still see group messages, but cannot send messages in the group.
  /// However, a user on the block list can neither see nor send group messages.
  ///
  final void Function(
    String groupId,
    List<String> mutes,
    int? muteExpire,
  )? onMuteListAddedFromGroup;

  ///
  /// Occurs when one or more group members are unmuted.
  ///
  final void Function(
    String groupId,
    List<String> mutes,
  )? onMuteListRemovedFromGroup;

  ///
  /// Occurs when the group ownership is transferred.
  ///
  final void Function(
    String groupId,
    String newOwner,
    String oldOwner,
  )? onOwnerChangedFromGroup;

  ///
  /// Occurs when a group request is accepted.
  ///
  final void Function(
    String groupId,
    String? groupName,
    String accepter,
  )? onRequestToJoinAcceptedFromGroup;

  ///
  /// Occurs when a group request is declined.
  ///
  final void Function(
    String groupId,
    String? groupName,
    String decliner,
    String? reason,
  )? onRequestToJoinDeclinedFromGroup;

  ///
  /// Occurs when the group owner or administrator receives a group request from a user.
  ///
  final void Function(
    String groupId,
    String? groupName,
    String applicant,
    String? reason,
  )? onRequestToJoinReceivedFromGroup;

  ///
  /// Occurs when a shared file is added to a group.
  ///
  final void Function(
    String groupId,
    EMGroupSharedFile sharedFile,
  )? onSharedFileAddedFromGroup;

  ///
  /// Occurs when a shared file is removed from a group.
  ///
  final void Function(
    String groupId,
    String fileId,
  )? onSharedFileDeletedFromGroup;

  ///
  /// Occurs when the current user is removed from the group by the group admin.
  ///
  final void Function(
    String groupId,
    String? groupName,
  )? onUserRemovedFromGroup;

  ///
  /// The group manager listener callback.
  ///
  /// Param [onAdminAddedFromGroup] A member is set as an admin callback.
  ///
  /// Param [onAdminRemovedFromGroup] A member's admin privileges are removed callback.
  ///
  /// Param [onAllGroupMemberMuteStateChanged] All group members are muted or unmuted callback.
  ///
  /// Param [onAllowListAddedFromGroup] Ane or more group members are muted callback.
  ///
  /// Param [onAllowListRemovedFromGroup] Ane or more group members are unmuted callback.
  ///
  /// Param [onAnnouncementChangedFromGroup] The announcement is updated callback.
  ///
  /// Param [onAutoAcceptInvitationFromGroup] The group invitation is accepted automatically callback.
  ///
  /// Param [onGroupDestroyed] A group is destroyed callback.
  ///
  /// Param [onInvitationAcceptedFromGroup] A group invitation is accepted callback.
  ///
  /// Param [onInvitationDeclinedFromGroup] A group invitation is declined callback.
  ///
  /// Param [onInvitationReceivedFromGroup] The user receives a group invitation callback.
  ///
  /// Param [onMemberExitedFromGroup] A member proactively leaves the group callback.
  ///
  /// Param [onMemberJoinedFromGroup] A member joins a group callback.
  ///
  /// Param [onMuteListAddedFromGroup] One or more group members are muted callback.
  ///
  /// Param [onMuteListRemovedFromGroup] One or more group members are unmuted callback.
  ///
  /// Param [onOwnerChangedFromGroup] The group ownership is transferred callback.
  ///
  /// Param [onRequestToJoinAcceptedFromGroup] A group request is accepted callback.
  ///
  /// Param [onRequestToJoinDeclinedFromGroup] A group request is declined callback.
  ///
  /// Param [onRequestToJoinReceivedFromGroup] The group owner or administrator receives a group request from a user callback.
  ///
  /// Param [onSharedFileAddedFromGroup] A shared file is added to a group callback.
  ///
  /// Param [onSharedFileDeletedFromGroup] A shared file is removed from a group callback.
  ///
  /// Param [onUserRemovedFromGroup] Current user is removed from the group by the group admin callback.
  ///
  EMGroupEventHandler({
    this.onAdminAddedFromGroup,
    this.onAdminRemovedFromGroup,
    this.onAllGroupMemberMuteStateChanged,
    this.onAllowListAddedFromGroup,
    this.onAllowListRemovedFromGroup,
    this.onAnnouncementChangedFromGroup,
    this.onAutoAcceptInvitationFromGroup,
    this.onGroupDestroyed,
    this.onInvitationAcceptedFromGroup,
    this.onInvitationDeclinedFromGroup,
    this.onInvitationReceivedFromGroup,
    this.onMemberExitedFromGroup,
    this.onMemberJoinedFromGroup,
    this.onMuteListAddedFromGroup,
    this.onMuteListRemovedFromGroup,
    this.onOwnerChangedFromGroup,
    this.onRequestToJoinAcceptedFromGroup,
    this.onRequestToJoinDeclinedFromGroup,
    this.onRequestToJoinReceivedFromGroup,
    this.onSharedFileAddedFromGroup,
    this.onSharedFileDeletedFromGroup,
    this.onUserRemovedFromGroup,
  });
}

///
/// The presence event handler.
///
/// Occurs when the following presence events happens: presence status changed.
///
/// Adds a presence event handler:
/// ```dart
///   EMClient.getInstance.presenceManager.addEventHandler(UNIQUE_HANDLER_ID, EMPresenceEventHandler());
/// ```
///
/// Remove a presence event handler:
/// ```dart
///   EMClient.getInstance.presenceManager.removeEventHandler(UNIQUE_HANDLER_ID);
/// ```
///
class EMPresenceEventHandler {
  ///
  /// Occurs when the presence state of a subscribed user changes.
  ///
  final Function(List<EMPresence> list)? onPresenceStatusChanged;

  ///
  /// The presence manager listener callback.
  ///
  /// Param [onPresenceStatusChanged] The presence state of a subscribed user changes callback.
  ///
  EMPresenceEventHandler({
    this.onPresenceStatusChanged,
  });
}
