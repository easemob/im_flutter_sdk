import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

///
///  The chat connection listener callback.
///
/// For the occasion of onDisconnected during unstable network condition, you don't need to reconnect manually,
/// the chat SDK will handle it automatically.
///
/// There are only two states: onConnected, onDisconnected.
///
/// Note: We recommend not to update UI based on those methods, because this method is called on worker thread. If you update UI in those methods, other UI errors might be invoked.
/// Also do not insert heavy computation work here, which might invoke other listeners to handle this connection event.
///
/// Adds the chat connection listener callback:
///   ```dart
///     EMClient.getInstance.addConnectionListener(EMConnectionListenerCallback());
///   ```
///
/// Clear all chat connection listener:
///   ```dart
///     EMClient.getInstance.clearAllConnectionListeners();
///   ```
///
class EMConnectionListenerCallback implements EMConnectionListener {
  ///
  /// Occurs when the SDK connects to the chat server successfully.
  ///
  final VoidCallback? onConnectedCallback;

  ///
  /// Occurs when the SDK disconnect from the chat server.
  ///
  /// Note that the logout may not be performed at the bottom level when the SDK is disconnected.
  ///
  final VoidCallback? onDisconnectedCallback;

  ///
  /// Occurs when the current user account is logged in to another device.
  ///
  final VoidCallback? onUserDidLoginFromOtherDeviceCallback;

  ///
  /// Occurs when the current chat user is removed from the server.
  ///
  final VoidCallback? onUserDidRemoveFromServerCallback;

  ///
  /// Occurs when the current chat user is forbid from the server.
  ///
  final VoidCallback? onUserDidForbidByServerCallback;

  ///
  /// Occurs when the current chat user is changed password.
  ///
  final VoidCallback? onUserDidChangePasswordCallback;

  ///
  /// Occurs when the current chat user logged to many devices.
  ///
  final VoidCallback? onUserDidLoginTooManyDeviceCallback;

  ///
  /// Occurs when the current chat user kicked by other device.
  ///
  final VoidCallback? onUserKickedByOtherDeviceCallback;

  ///
  /// Occurs when the current chat user authentication failed.
  ///
  final VoidCallback? onUserAuthenticationFailedCallback;

  ///
  /// Occurs when the token is about to expire.
  ///
  final VoidCallback? onTokenWillExpireCallback;

  ///
  /// Occurs when the token has expired.
  ///
  final VoidCallback? onTokenDidExpireCallback;

  ///
  /// The chat connection listener callback.
  ///
  /// Param [onConnectedCallback] The SDK connects to the chat server successfully callback.
  ///
  /// Param [onDisconnectedCallback] The SDK disconnect from the chat server callback.
  ///
  /// Param [onUserDidLoginFromOtherDeviceCallback] Current user account is logged in to another device callback.
  ///
  /// Param [onUserDidRemoveFromServerCallback] Current chat user is removed from the server callback.
  ///
  /// Param [onUserDidForbidByServerCallback] Current chat user is forbid from the server callback.
  ///
  /// Param [onUserDidChangePasswordCallback] Current chat user is changed password callback.
  ///
  /// Param [onUserDidLoginTooManyDeviceCallback] Current chat user logged to many devices callback.
  ///
  /// Param [onUserKickedByOtherDeviceCallback] Current chat user kicked by other device callback.
  ///
  /// Param [onUserAuthenticationFailedCallback] Current chat user authentication failed callback.
  ///
  /// Param [onTokenWillExpireCallback] The token is about to expire callback.
  ///
  /// Param [onTokenDidExpireCallback] The token has expired callback.
  ///
  EMConnectionListenerCallback({
    this.onConnectedCallback,
    this.onDisconnectedCallback,
    this.onUserDidLoginFromOtherDeviceCallback,
    this.onUserDidRemoveFromServerCallback,
    this.onUserDidForbidByServerCallback,
    this.onUserDidChangePasswordCallback,
    this.onUserDidLoginTooManyDeviceCallback,
    this.onUserKickedByOtherDeviceCallback,
    this.onUserAuthenticationFailedCallback,
    this.onTokenWillExpireCallback,
    this.onTokenDidExpireCallback,
  });

  @override
  void onConnected() {
    this.onConnectedCallback?.call();
  }

  @override
  void onDisconnected() {
    this.onDisconnectedCallback?.call();
  }

  @override
  void onTokenDidExpire() {
    this.onTokenDidExpireCallback?.call();
  }

  @override
  void onTokenWillExpire() {
    this.onTokenWillExpireCallback?.call();
  }

  @override
  void onUserAuthenticationFailed() {
    this.onUserAuthenticationFailedCallback?.call();
  }

  @override
  void onUserDidChangePassword() {
    this.onUserDidChangePasswordCallback?.call();
  }

  @override
  void onUserDidForbidByServer() {
    this.onUserDidForbidByServerCallback?.call();
  }

  @override
  void onUserDidLoginFromOtherDevice() {
    this.onUserDidLoginFromOtherDeviceCallback?.call();
  }

  @override
  void onUserDidLoginTooManyDevice() {
    this.onUserDidLoginTooManyDeviceCallback?.call();
  }

  @override
  void onUserDidRemoveFromServer() {
    this.onUserDidRemoveFromServerCallback?.call();
  }

  @override
  void onUserKickedByOtherDevice() {
    this.onUserKickedByOtherDeviceCallback?.call();
  }
}

///
/// The chat manager listener callback.
///
/// This listener callback is used to check whether messages are received. If messages are sent successfully, a delivery receipt will be returned (delivery receipt needs to be enabled: {@link EMOptions#requireDeliveryAck(boolean)}.
/// If the peer reads the received message, a read receipt will be returned (read receipt needs to be enabled: {@link EMOptions#requireAck(boolean)})
/// During message delivery, the message ID will be changed from a local uuid to a global unique ID that is generated by the server to uniquely identify a message on all devices using the SDK.
/// This API should be implemented in the app to listen for message status changes.
///
/// Adds the chat manager listener callback:
/// ```dart
///   EMClient.getInstance.chatManager.addChatManagerListener(EMChatManagerListenerCallback());
/// ```
///
/// Clear all chat manager listener:
/// ```dart
///   EMClient.getInstance.chatManager.clearAllChatManagerListeners;
/// ```
///
///
class EMChatManagerListenerCallback implements EMChatManagerListener {
  ///
  /// Occurs when a message is received callback.
  ///
  /// This callback is triggered to notify the user when a message such as texts or an image, video, voice, location, or file is received.
  ///
  /// Param [messages] The received messages callback.
  ///
  final void Function(List<EMMessage> messages)? onMessagesReceivedCallback;

  ///
  /// Occurs when a command message is received.
  ///
  /// This callback only contains a command message body that is usually invisible to users.
  ///
  /// Param [messages]The received cmd messages.
  ///
  final void Function(List<EMMessage> messages)? onCmdMessagesReceivedCallback;

  ///
  /// Occurs when a read receipt is received for a message.
  ///
  /// Param [messages] The has read messages.
  ///
  final void Function(List<EMMessage> messages)? onMessagesReadCallback;

  ///
  /// Occurs when a read receipt is received for a group message.
  ///
  /// Param [groupMessageAcks] The group message acks.
  ///
  final void Function(List<EMGroupMessageAck> groupMessageAcks)?
      onGroupMessageReadCallback;

  ///
  /// Occurs when the update for the group message read status is received.
  ///
  final VoidCallback? onReadAckForGroupMessageUpdatedCallback;

  ///
  /// Occurs when a delivery receipt is received.
  ///
  /// Param [messages] The has delivered messages.
  ///
  final void Function(List<EMMessage> messages)? onMessagesDeliveredCallback;

  ///
  /// Occurs when a received message is recalled.
  ///
  /// Param [messages]  The recalled messages.
  ///
  final void Function(List<EMMessage> messages)? onMessagesRecalledCallback;

  ///
  /// Occurs when the conversation updated.
  ///
  final VoidCallback? onConversationsUpdateCallback;

  ///
  /// Occurs when a conversation read receipt is received.
  ///
  /// Occurs in the following scenarios:
  /// (1) The message is read by the receiver (The conversation receipt is sent).
  /// Upon receiving this event, the SDK sets the `isAcked` property of the message in the conversation to `true` in the local database.
  /// (2) In the multi-device login scenario, when one device sends a Conversation receipt,
  /// the server will set the number of unread messages to 0, and the callback occurs on the other devices.
  /// and sets the `isRead` property of the message in the conversation to `true` in the local database.
  ///
  /// Param [from] The user who sends the read receipt.
  /// Param [to]   The user who receives the read receipt.
  ///
  final void Function(String from, String to)? onConversationReadCallback;

  ///
  /// Occurs when the Reaction data changes.
  ///
  /// Param [events] The Reaction which is changed
  ///
  final void Function(List<EMMessageReactionEvent> events)?
      onMessageReactionDidChangeCallback;

  ///
  /// The chat manager listener callback.
  ///
  /// Param[onMessagesReceivedCallback] Message is received callback.
  ///
  /// Param[onCmdMessagesReceivedCallback] Command message is received callback.
  ///
  /// Param[onMessagesReadCallback] Read receipt is received for a message callback.
  ///
  /// Param[onGroupMessageReadCallback] Read receipt is received for a group message callback.
  ///
  /// Param[onReadAckForGroupMessageUpdatedCallback] Group message read status is received callback.
  ///
  /// Param[onMessagesDeliveredCallback] Delivery receipt is received callback.
  ///
  /// Param[onMessagesRecalledCallback] Received message is recalled callback.
  ///
  /// Param[onConversationsUpdateCallback] Conversation updated callback.
  ///
  /// Param[onConversationReadCallback] Conversation read receipt is received callback.
  ///
  /// Param[onMessageReactionDidChangeCallback] Reaction data changes callback.
  ///
  EMChatManagerListenerCallback({
    this.onMessagesReceivedCallback,
    this.onCmdMessagesReceivedCallback,
    this.onMessagesReadCallback,
    this.onGroupMessageReadCallback,
    this.onReadAckForGroupMessageUpdatedCallback,
    this.onMessagesDeliveredCallback,
    this.onMessagesRecalledCallback,
    this.onConversationsUpdateCallback,
    this.onConversationReadCallback,
    this.onMessageReactionDidChangeCallback,
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

///
/// The chat room manager listener callback.
///
/// Adds the chat room manager listener callback:
/// ```dart
///   EMClient.getInstance.chatRoomManager.addChatRoomManagerListener(EMChatRoomManagerListenerCallback());
/// ```
///
/// Clear all chat room manager listener callback:
/// ```dart
///   EMClient.getInstance.chatRoomManager.clearAllChatRoomManagerListeners();
/// ```
///
class EMChatRoomManagerListenerCallback implements EMChatRoomManagerListener {
  ///
  /// Occurs when a member has been changed to an admin.
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [admin] The member who has been changed to an admin.
  ///
  final void Function(
    String roomId,
    String admin,
  )? onAdminAddedFromChatRoomCallback;

  ///
  /// Occurs when an admin is been removed.
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [admin] The member whose admin permission is removed.
  ///
  final void Function(
    String roomId,
    String admin,
  )? onAdminRemovedFromChatRoomCallback;

  ///
  /// Occurs when all members in the chat room are muted or unmuted.
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [isAllMuted] Whether all chat room members is muted or unmuted.
  /// - `true`: Yes;
  /// - `false`: No.
  ///
  final void Function(
    String roomId,
    bool isAllMuted,
  )? onAllChatRoomMemberMuteStateChangedCallback;

  ///
  /// Occurs when the chat room member(s) is added to the allowlist.
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [members] The member(s) to be added to the allowlist.
  ///
  final void Function(
    String roomId,
    List<String> members,
  )? onAllowListAddedFromChatRoomCallback;

  ///
  /// Occurs when the chat room member(s) is removed from the allowlist.
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [members] The member(s) is removed from the allowlist.
  ///
  final void Function(
    String roomId,
    List<String> members,
  )? onAllowListRemovedFromChatRoomCallback;

  ///
  /// Occurs when the announcement changed.
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [announcement] The changed announcement.
  ///
  final void Function(
    String roomId,
    String announcement,
  )? onAnnouncementChangedFromChatRoomCallback;

  ///
  /// Occurs when the chat room is destroyed.
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [roomName] The chatroom name.
  ///
  final void Function(
    String roomId,
    String? roomName,
  )? onChatRoomDestroyedCallback;

  ///
  /// Occurs when a member leaves the chatroom.
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [participant] The exited member's username.
  ///
  final void Function(
    String roomId,
    String? roomName,
    String participant,
  )? onMemberExitedFromChatRoomCallback;

  ///
  /// Occurs when a member join the chatroom.
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [participant] The new member's username.
  ///
  final void Function(
    String roomId,
    String participant,
  )? onMemberJoinedFromChatRoomCallback;

  ///
  /// Occurs when there are chat room member(s) muted (added to mute list),
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [mutes] The members to be muted.
  ///
  /// Param [expireTime] The mute duration.
  ///
  final void Function(
    String roomId,
    List<String> mutes,
    String? expireTime,
  )? onMuteListAddedFromChatRoomCallback;

  ///
  /// Occurs when there are chat room member(s) unmuted (removed from mute list).
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [mutes] The member(s) muted is removed from the mute list.
  ///
  final void Function(
    String roomId,
    List<String> mutes,
  )? onMuteListRemovedFromChatRoomCallback;

  ///
  ///  Occurs when the chat room ownership has been transferred.
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [newOwner] The new owner.
  ///
  /// Param [oldOwner] The previous owner.
  ///
  final void Function(
    String roomId,
    String newOwner,
    String oldOwner,
  )? onOwnerChangedFromChatRoomCallback;

  ///
  /// Occurs when a member is dismissed from a chat room.
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [roomName] The chatroom name.
  ///
  /// Param [participant] The member is dismissed from a chat room.
  ///
  final void Function(
    String roomId,
    String? roomName,
    String? participant,
  )? onRemovedFromChatRoomCallback;

  ///
  /// The chat room manager listener callback.
  ///
  /// Param [onAdminAddedFromChatRoomCallback] A member has been changed to an admin callback.
  ///
  /// Param [onAdminRemovedFromChatRoomCallback] An admin is been removed callback callback.
  ///
  /// Param [onAllChatRoomMemberMuteStateChangedCallback] All members in the chat room are muted or unmuted callback.
  ///
  /// Param [onAllowListAddedFromChatRoomCallback] The chat room member(s) is added to the allowlist callback.
  ///
  /// Param [onAllowListRemovedFromChatRoomCallback] The chat room member(s) is removed from the allowlist callback.
  ///
  /// Param [onAnnouncementChangedFromChatRoomCallback] The announcement changed callback.
  ///
  /// Param [onChatRoomDestroyedCallback] The chat room is destroyed callback.
  ///
  /// Param [onMemberExitedFromChatRoomCallback] A member leaves the chatroom callback.
  ///
  /// Param [onMemberJoinedFromChatRoomCallback] A member join the chatroom callback.
  ///
  /// Param [onMuteListAddedFromChatRoomCallback] The chat room member(s) muted (added to mute list) callback.
  ///
  /// Param [onMuteListRemovedFromChatRoomCallback] The chat room member(s) unmuted (removed from mute list) callback.
  ///
  /// Param [onOwnerChangedFromChatRoomCallback] The chat room ownership has been transferred callback.
  ///
  /// Param [onRemovedFromChatRoomCallback] The chat room member(s) is removed from the allowlist callback.
  ///
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
    this.onRemovedFromChatRoomCallback?.call(roomId, roomName, participant);
  }
}

///
/// The message thread listener callback, which listens for message thread events such as creating or leaving a message thread.
///
/// Adds a message thread listener callback:
/// EMClient.getInstance.chatThreadManager.addChatThreadManagerListener(EMChatThreadManagerListenerCallback());
///
/// Clear all message thread listener callback:
/// EMClient.getInstance.chatThreadManager.clearAllChatThreadManagerListeners();
///
class EMChatThreadManagerListenerCallback
    implements EMChatThreadManagerListener {
  ///
  /// Occurs when a message thread is created.
  ///
  /// Each member of the group to which the message thread belongs can receive the callback.
  ///
  /// Param [event] The event;
  ///
  final void Function(
    EMChatThreadEvent event,
  )? onChatThreadCreateCallback;

  ///
  /// Occurs when a message thread is destroyed.
  ///
  /// Each member of the group to which the message thread belongs can receive the callback.
  ///
  /// Param [event] The event;
  ///
  final void Function(
    EMChatThreadEvent event,
  )? onChatThreadDestroyCallback;

  ///
  /// Occurs when a message thread is updated.
  ///
  /// This callback is triggered when the message thread name is changed or a threaded reply is added or recalled.
  ///
  /// Each member of the group to which the message thread belongs can receive the callback.
  ///
  /// Param [event] The event;
  ///
  final void Function(
    EMChatThreadEvent event,
  )? onChatThreadUpdateCallback;

  ///
  /// Occurs when the current user is removed from the message thread by the group owner or a group admin to which the message thread belongs.
  ///
  /// Param [event] The event;
  ///
  final void Function(
    EMChatThreadEvent event,
  )? onUserKickOutOfChatThreadCallback;

  ///
  /// The message thread listener callback
  ///
  /// Param [onChatThreadCreateCallback] A message thread is created callback.
  ///
  /// Param [onChatThreadDestroyCallback] A message thread is destroyed callback.
  ///
  /// Param [onChatThreadUpdateCallback] A message thread is updated callback.
  ///
  /// Param [onUserKickOutOfChatThreadCallback] Current user is removed from the message thread by the group owner or a group admin to which the message thread belongs callback.
  ///
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

///
/// The contact updates listener callback.
///
/// Occurs when the contact changes, including requests to add friends, notifications to delete friends,
/// requests to accept friends, and requests to reject friends.
///
/// Adds a contact manager listener callback:
/// ```dart
///   EMClient.getInstance.contactManager.addContactManagerListener(EMContactManagerListenerCallback());
/// ```
///
/// Clear all contact manager listener callback:
/// ```dart
///   EMClient.getInstance.contactManager.clearContactManagerListeners();
/// ```
///
class EMContactManagerListenerCallback implements EMContactManagerListener {
  ///
  /// Occurs when user is added as a contact by another user.
  ///
  /// Param [userName] The new contact to be added.
  ///
  final void Function(
    String userId,
  )? onContactAddedCallback;

  ///
  /// Occurs when a user is removed from the contact list by another user.
  ///
  /// Param [userName] The user who is removed from the contact list by another user.
  ///
  final void Function(
    String userId,
  )? onContactDeletedCallback;

  ///
  /// Occurs when a user receives a friend request.
  ///
  /// Param [userName] The user who initiated the friend request.
  ///
  /// Param [reason] The invitation message.
  ///
  final void Function(
    String userId,
    String? reason,
  )? onContactInvitedCallback;

  ///
  /// Occurs when a friend request is approved.
  ///
  /// Param [userName] The user who initiated the friend request.
  ///
  final void Function(
    String userId,
  )? onFriendRequestAcceptedCallback;

  ///
  /// Occurs when a friend request is declined.
  ///
  /// Param [userName] The user who initiated the friend request.
  ///
  final void Function(
    String userId,
  )? onFriendRequestDeclinedCallback;

  ///
  /// The contact updates listener callback.
  ///
  /// Param [onContactAddedCallback] Current user is added as a contact by another user callback.
  ///
  /// Param [onContactDeletedCallback] Current user is removed from the contact list by another user callback.
  ///
  /// Param [onContactInvitedCallback] Current user receives a friend request callback.
  ///
  /// Param [onFriendRequestAcceptedCallback] A friend request is approved callback.
  ///
  /// Param [onFriendRequestDeclinedCallback] A friend request is declined callback.
  ///
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

///
/// The group manager listener callback.
///
/// Occurs when the following group events happens: requesting to join a group, approving or declining a group request, and kicking a user out of a group.
///
/// Adds a group manager listener callback:
/// ```dart
///   EMClient.getInstance.groupManager.addGroupManagerListener(EMGroupManagerListenerCallback());
/// ```
///
/// Clear all group manager listener callback:
/// ```dart
///   EMClient.getInstance.groupManager.clearAllGroupManagerListeners();
/// ```
///
class EMGroupManagerListenerCallback implements EMGroupManagerListener {
  ///
  /// Occurs when a member is set as an admin.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [admin] The member that is set as an admin.
  ///
  final void Function(
    String groupId,
    String admin,
  )? onAdminAddedFromGroupCallback;

  ///
  /// Occurs when a member's admin privileges are removed.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [admin] The member whose admin privileges are removed.
  ///
  final void Function(
    String groupId,
    String admin,
  )? onAdminRemovedFromGroupCallback;

  ///
  /// Occurs when all group members are muted or unmuted.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [isAllMuted] Whether all group members are muted or unmuted.
  /// - `true`: Yes;
  /// - `false`: No.
  ///
  final void Function(
    String groupId,
    bool isAllMuted,
  )? onAllGroupMemberMuteStateChangedCallback;

  ///
  /// Occurs when one or more group members are added to the allowlist.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [members] The member(s) removed from the allowlist.
  ///
  final void Function(
    String groupId,
    List<String> members,
  )? onAllowListAddedFromGroupCallback;

  ///
  /// Occurs when one or more members are removed from the allowlist.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [members] The member(s) added to the allowlist.
  ///
  final void Function(
    String groupId,
    List<String> members,
  )? onAllowListRemovedFromGroupCallback;

  ///
  /// Occurs when the announcement is updated.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [announcement] The updated announcement content.
  ///
  final void Function(
    String groupId,
    String announcement,
  )? onAnnouncementChangedFromGroupCallback;

  ///
  /// Occurs when the group invitation is accepted automatically.
  /// For settings, see {@link EMOptions#autoAcceptGroupInvitation(boolean value)}.
  /// The SDK will join the group before notifying the app of the acceptance of the group invitation.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [inviter] The inviter ID.
  ///
  /// Param [inviteMessage] The invitation message.
  ///
  final void Function(
    String groupId,
    String inviter,
    String? inviteMessage,
  )? onAutoAcceptInvitationFromGroupCallback;

  ///
  /// Occurs when a group is destroyed.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [groupName] The group name.
  ///
  final void Function(
    String groupId,
    String? groupName,
  )? onGroupDestroyedCallback;

  ///
  /// Occurs when a group invitation is accepted.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [invitee] The invitee ID.
  ///
  /// Param [reason] The reason for acceptance.
  ///
  final void Function(
    String groupId,
    String invitee,
    String? reason,
  )? onInvitationAcceptedFromGroupCallback;

  ///
  /// Occurs when a group invitation is declined.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [invitee] The invitee ID.
  ///
  /// Param [reason] The reason for declining.
  ///
  final void Function(
    String groupId,
    String invitee,
    String? reason,
  )? onInvitationDeclinedFromGroupCallback;

  ///
  /// Occurs when the user receives a group invitation.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [groupName] The group name.
  ///
  /// Param [inviter] The invitee ID.
  ///
  /// Param [reason] The reason for invitation.
  ///
  final void Function(
    String groupId,
    String? groupName,
    String inviter,
    String? reason,
  )? onInvitationReceivedFromGroupCallback;

  ///
  /// Occurs when a member proactively leaves the group.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [member] The member leaving the group.
  ///
  final void Function(
    String groupId,
    String member,
  )? onMemberExitedFromGroupCallback;

  ///
  /// Occurs when a member joins a group.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [member] The ID of the new member.
  ///
  final void Function(
    String groupId,
    String member,
  )? onMemberJoinedFromGroupCallback;

  ///
  /// Occurs when one or more group members are muted.
  ///
  /// Note: The mute function is different from a block list.
  /// A user, when muted, can still see group messages, but cannot send messages in the group.
  /// However, a user on the block list can neither see nor send group messages.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [mutes] The member(s) added to the mute list.
  ///
  /// Param [muteExpire] The mute duration in milliseconds.
  ///
  final void Function(
    String groupId,
    List<String> mutes,
    int? muteExpire,
  )? onMuteListAddedFromGroupCallback;

  ///
  /// Occurs when one or more group members are unmuted.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [mutes] The member(s) added to the mute list.
  ///
  final void Function(
    String groupId,
    List<String> mutes,
  )? onMuteListRemovedFromGroupCallback;

  ///
  /// Occurs when the group ownership is transferred.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [newOwner] The new owner.
  ///
  /// Param [oldOwner] The previous owner.
  ///
  final void Function(
    String groupId,
    String newOwner,
    String oldOwner,
  )? onOwnerChangedFromGroupCallback;

  ///
  /// Occurs when a group request is accepted.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [groupName] The group name.
  ///
  /// Param [accepter] The ID of the user that accepts the group request.
  ///
  final void Function(
    String groupId,
    String? groupName,
    String accepter,
  )? onRequestToJoinAcceptedFromGroupCallback;

  ///
  /// Occurs when a group request is declined.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [groupName] The group name.
  ///
  /// Param [decliner] The ID of the user that declines the group request.
  ///
  /// Param [reason] The reason for declining.
  ///
  final void Function(
    String groupId,
    String? groupName,
    String decliner,
    String? reason,
  )? onRequestToJoinDeclinedFromGroupCallback;

  ///
  /// Occurs when the group owner or administrator receives a group request from a user.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [groupName] The group name.
  ///
  /// Param [applicant] The ID of the user requesting to join the group.
  ///
  /// Param [reason] The reason for requesting to join the group.
  ///
  final void Function(
    String groupId,
    String? groupName,
    String applicant,
    String? reason,
  )? onRequestToJoinReceivedFromGroupCallback;

  ///
  /// Occurs when a shared file is added to a group.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [sharedFile] The new shared file.
  ///
  final void Function(
    String groupId,
    EMGroupSharedFile sharedFile,
  )? onSharedFileAddedFromGroupCallback;

  ///
  /// Occurs when a shared file is removed from a group.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [fileId] The ID of the removed shared file.
  ///
  final void Function(
    String groupId,
    String fileId,
  )? onSharedFileDeletedFromGroupCallback;

  ///
  /// Occurs when the current user is removed from the group by the group admin.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [groupName] The group name.
  ///
  final void Function(
    String groupId,
    String? groupName,
  )? onUserRemovedFromGroupCallback;

  ///
  /// The group manager listener callback.
  ///
  /// Param [onAdminAddedFromGroupCallback] A member is set as an admin callback.
  ///
  /// Param [onAdminRemovedFromGroupCallback] A member's admin privileges are removed callback.
  ///
  /// Param [onAllGroupMemberMuteStateChangedCallback] All group members are muted or unmuted callback.
  ///
  /// Param [onAllowListAddedFromGroupCallback] Ane or more group members are muted callback.
  ///
  /// Param [onAllowListRemovedFromGroupCallback] Ane or more group members are unmuted callback.
  ///
  /// Param [onAnnouncementChangedFromGroupCallback] The announcement is updated callback.
  ///
  /// Param [onAutoAcceptInvitationFromGroupCallback] The group invitation is accepted automatically callback.
  ///
  /// Param [onGroupDestroyedCallback] A group is destroyed callback.
  ///
  /// Param [onInvitationAcceptedFromGroupCallback] A group invitation is accepted callback.
  ///
  /// Param [onInvitationDeclinedFromGroupCallback] A group invitation is declined callback.
  ///
  /// Param [onInvitationReceivedFromGroupCallback] The user receives a group invitation callback.
  ///
  /// Param [onMemberExitedFromGroupCallback] A member proactively leaves the group callback.
  ///
  /// Param [onMemberJoinedFromGroupCallback] A member joins a group callback.
  ///
  /// Param [onMuteListAddedFromGroupCallback] One or more group members are muted callback.
  ///
  /// Param [onMuteListRemovedFromGroupCallback] One or more group members are unmuted callback.
  ///
  /// Param [onOwnerChangedFromGroupCallback] The group ownership is transferred callback.
  ///
  /// Param [onRequestToJoinAcceptedFromGroupCallback] A group request is accepted callback.
  ///
  /// Param [onRequestToJoinDeclinedFromGroupCallback] A group request is declined callback.
  ///
  /// Param [onRequestToJoinReceivedFromGroupCallback] The group owner or administrator receives a group request from a user callback.
  ///
  /// Param [onSharedFileAddedFromGroupCallback] A shared file is added to a group callback.
  ///
  /// Param [onSharedFileDeletedFromGroupCallback] A shared file is removed from a group callback.
  ///
  /// Param [onUserRemovedFromGroupCallback] Current user is removed from the group by the group admin callback.
  ///
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

///
/// The presence manager listener callback.
///
/// Adds a presence manager listener callback:
/// ```dart
///   EMClient.getInstance.presenceManager.addPresenceManagerListener(EMPresenceManagerListenerCallback());
/// ```
///
/// Clear all presence manager listener callback:
/// ```dart
///   EMClient.getInstance.presenceManager.clearAllPresenceManagerListener();
/// ```
///
class EMPresenceManagerListenerCallback implements EMPresenceManagerListener {
  ///
  /// Occurs when the presence state of a subscribed user changes.
  ///
  /// Param [list] The new presence state of a subscribed user.
  ///
  final Function(List<EMPresence> list)? onPresenceStatusChangedCallback;

  ///
  /// The presence manager listener callback.
  ///
  /// Param [onPresenceStatusChangedCallback] The presence state of a subscribed user changes callback.
  EMPresenceManagerListenerCallback({
    this.onPresenceStatusChangedCallback,
  });

  @override
  void onPresenceStatusChanged(List<EMPresence> list) {
    this.onPresenceStatusChangedCallback?.call(list);
  }
}
