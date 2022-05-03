import '../im_flutter_sdk.dart';
import 'models/em_presence.dart';

///
/// The chat connection listener.
///
/// For the occasion of onDisconnected during unstable network condition, you don't need to reconnect manually,
/// the chat SDK will handle it automatically.
///
/// There are only two states: onConnected, onDisconnected.
///
/// Note: We recommend not to update UI based on those methods, because this method is called on worker thread. If you update UI in those methods, other UI errors might be invoked.
/// Also do not insert heavy computation work here, which might invoke other listeners to handle this connection event.
///
/// Register:
///   ```dart
///     EMClient.getInstance.addConnectionListener(mConnectionListener);
///   ```
///
/// Unregister:
///   ```dart
///     EMClient.getInstance.removeConnectionListener(mConnectionListener);
///   ```
///
abstract class EMConnectionListener {
  ///
  /// Occurs when the SDK connects to the chat server successfully.
  ///
  void onConnected();

  ///
  /// Occurs when the SDK disconnect from the chat server.
  ///
  /// Note that the logout may not be performed at the bottom level when the SDK is disconnected.
  ///
  void onDisconnected();

  ///
  /// Occurs when the current user account is logged in to another device.
  ///
  void onUserDidLoginFromOtherDevice();

  ///
  /// Occurs when the current chat user is removed from the server.
  ///
  void onUserDidRemoveFromServer();

  ///
  /// Occurs when the current chat user is forbid from the server.
  ///
  void onUserDidForbidByServer();

  ///
  /// Occurs when the current chat user is changed password.
  ///
  void onUserDidChangePassword();

  ///
  /// Occurs when the current chat user logged to many devices.
  ///
  void onUserDidLoginTooManyDevice();

  ///
  /// Occurs when the current chat user kicked by other device.
  ///
  void onUserKickedByOtherDevice();

  ///
  /// Occurs when the current chat user authentication failed.
  ///
  void onUserAuthenticationFailed();

  ///
  /// Occurs when the token is about to expire.
  ///
  void onTokenWillExpire();

  ///
  /// Occurs when the token has expired.
  ///
  void onTokenDidExpire();
}

///
/// The multi-device event listener.
/// Listens for callback for the current user's actions on other devices, including contact changes and group changes.
///
/// Registers a multi-device event listener:
/// ```dart
///   EMClient.getInstance.addMultiDeviceListener(mMultiDeviceListener);
/// ```
///
/// Removes a multi-device event listener:
/// ```dart
///   EMClient.getInstance.removeMultiDeviceListener(mMultiDeviceListener);
/// ```
abstract class EMMultiDeviceListener {
  ///
  /// The multi-device event callback of contact.
  ///
  /// Param [event] The event type.
  ///
  /// Param [username] The username.
  ///
  /// Param [ext] The extended Information.
  ///
  void onContactEvent(
    EMMultiDevicesEvent event,
    String username,
    String? ext,
  );

  ///
  /// The multi-device event callback of group.
  ///
  /// Param [event] The event type.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [usernames] The array of usernames.
  ///
  void onGroupEvent(
    EMMultiDevicesEvent event,
    String groupId,
    List<String>? usernames,
  );
}

abstract class EMCustomListener {
  void onDataReceived(Map map);
}

///
/// The contact updates listener.
///
/// Occurs when the contact changes, including requests to add friends, notifications to delete friends,
/// requests to accept friends, and requests to reject friends.
///
/// Register the listener：
/// ```dart
///   EMClient.getInstance.contactManager.addContactListener(contactListener);
/// ```
///
/// Unregister the listener：
/// ```dart
///   EMClient.getInstance.contactManager.removeContactListener(contactListener);
/// ```
///
abstract class EMContactManagerListener {
  ///
  /// Occurs when user is added as a contact by another user.
  ///
  /// Param [userName] The new contact to be added.
  ///
  void onContactAdded(String userName);

  ///
  /// Occurs when a user is removed from the contact list by another user.
  ///
  /// Param [userName] The user who is removed from the contact list by another user.
  ///
  void onContactDeleted(String? userName);

  ///
  /// Occurs when a user receives a friend request.
  ///
  /// Param [userName] The user who initiated the friend request.
  ///
  /// Param [reason] The invitation message.
  ///
  void onContactInvited(String userName, String? reason);

  ///
  /// Occurs when a friend request is approved.
  ///
  /// Param [userName] The user who initiated the friend request.
  ///
  void onFriendRequestAccepted(String userName);

  ///
  /// Occurs when a friend request is declined.
  ///
  /// Param [userName] The user who initiated the friend request.
  ///
  void onFriendRequestDeclined(String userName);
}

// abstract class EMConversationListener {
//   void onConversationUpdate();
// }

///
/// The chat room change listener.
///
/// Register the chat room change listener:
/// ```dart
///   EMClient.getInstance.chatRoomManager.addChatRoomChangeListener(listener);
/// ```
///
///Unregister the chat room change listener:
/// ```dart
///   EMClient.getInstance.chatRoomManager.removeChatRoomListener(listener);
/// ```
///
abstract class EMChatRoomEventListener {
  ///
  /// Occurs when the chat room is destroyed.
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [roomName] The chatroom subject.
  ///
  void onChatRoomDestroyed(String roomId, String? roomName);

  ///
  /// Occurs when a member join the chatroom.
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [participant] The new member's username.
  ///
  void onMemberJoinedFromChatRoom(String roomId, String participant);

  ///
  /// Occurs when a member leaves the chatroom.
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [participant] The new member's username.
  ///
  void onMemberExitedFromChatRoom(
      String roomId, String? roomName, String participant);

  ///
  /// Occurs when a member is dismissed from a chat room.
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [roomName] The chatroom subject.
  ///
  /// Param [participant] The member is dismissed from a chat room.
  ///
  void onRemovedFromChatRoom(
    String roomId,
    String? roomName,
    String? participant,
  );

  ///
  /// Occurs when there are chat room member(s) muted (added to mute list),
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [mutes] The members to be muted.
  ///
  /// Param [expireTime] The mute duration.
  ///
  void onMuteListAddedFromChatRoom(
    String roomId,
    List<String> mutes,
    String? expireTime,
  );

  ///
  /// Occurs when there are chat room member(s) unmuted (removed from mute list).
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [mutes] The member(s) muted is removed from the mute list.
  ///
  void onMuteListRemovedFromChatRoom(
    String roomId,
    List<String> mutes,
  );

  ///
  /// Occurs when a member has been changed to an admin.
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [admin] The member who has been changed to an admin.
  ///
  void onAdminAddedFromChatRoom(String roomId, String admin);

  ///
  /// Occurs when an admin is been removed.
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [admin] The member whose admin permission is removed.
  ///
  void onAdminRemovedFromChatRoom(String roomId, String admin);

  ///
  ///  Occurs when the chat room ownership has been transferred.
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [newOwner] The new owner.
  ///
  /// Param [oldOwner] The previous owner.
  ///
  void onOwnerChangedFromChatRoom(
      String roomId, String newOwner, String oldOwner);

  ///
  /// Occurs when the announcement changed.
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [announcement] The changed announcement.
  ///
  void onAnnouncementChangedFromChatRoom(String roomId, String announcement);

  ///
  /// Occurs when the chat room member(s) is added to the allowlist.
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [members] The member(s) to be added to the allowlist.
  ///
  void onWhiteListAddedFromChatRoom(String roomId, List<String> members);

  ///
  /// Occurs when the chat room member(s) is removed from the allowlist.
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [members] The member(s) is removed from the allowlist.
  ///
  void onWhiteListRemovedFromChatRoom(String roomId, List<String> members);

  ///
  /// Occurs when all members in the chat room are muted or unmuted.
  ///
  /// Param [roomId] The chatroom ID.
  ///
  /// Param [isAllMuted] Whether all chat room members is muted or unmuted.
  /// - `true`: Yes;
  /// - `false`: No.
  ///
  void onAllChatRoomMemberMuteStateChanged(String roomId, bool isAllMuted);
}

@Deprecated('Use EMGroupEventListener.')
abstract class EMGroupChangeListener {
  ///
  /// Occurs when an invitation is rejected by the inviter.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [groupName] The group name.
  ///
  /// Param [inviter] The username of the inviter.
  ///
  /// Param [reason] The reason.
  ///
  void onInvitationReceivedFromGroup(
      String groupId, String? groupName, String inviter, String? reason);

  ///
  /// Occurs when a group join application is received from an applicant.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [groupName] The group name.
  ///
  /// Param [applicant] The username of the applicant.
  ///
  /// Param [reason] The reason.
  ///
  void onRequestToJoinReceivedFromGroup(
      String groupId, String? groupName, String applicant, String? reason);

  ///
  /// Occurs when a group-join application is accepted.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [groupName] The group name.
  ///
  /// Param [accepter] The username of the accepter.
  ///
  void onRequestToJoinAcceptedFromGroup(
      String groupId, String? groupName, String accepter);

  ///
  /// Occurs when a group-join application is declined.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [groupName] The group name.
  ///
  /// Param [decliner] The username of the decliner.
  ///
  /// Param [reason] The reason.
  ///
  void onRequestToJoinDeclinedFromGroup(
      String groupId, String? groupName, String decliner, String? reason);

  ///
  /// Occurs when a group invitation is approved.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [groupName] The group name.
  ///
  /// Param [invitee] The username of the invitee.
  ///
  /// Param [reason] The reason.
  ///
  void onInvitationAcceptedFromGroup(
      String groupId, String invitee, String? reason);

  ///
  /// Occurs when a group invitation is declined.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [invitee] The username of the invitee.
  ///
  /// Param [reason] The reason.
  ///
  void onInvitationDeclinedFromGroup(
      String groupId, String invitee, String? reason);

  /// Occurs when a group member is removed from the group.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [groupName] The group name.
  ///
  void onUserRemovedFromGroup(String groupId, String? groupName);

  /// Occurs when a group is destroyed.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [groupName] The group name.
  ///
  void onGroupDestroyed(String groupId, String? groupName);

  /// Occurs when the group invitation is accepted automatically.
  /// The SDK will join the group before notifying the app of the acceptance of the group invitation.
  /// For settings, see {@link EMOptions#autoAcceptGroupInvitation(boolean value)}.
  ///
  /// Param [groupId]			The group ID.
  /// Param [inviter]			The inviter ID.
  /// Param [inviteMessage]		The invitation message.
  ///
  void onAutoAcceptInvitationFromGroup(
      String groupId, String inviter, String? inviteMessage);

  /// Occurs when members are added to the mute list of the group.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [mutes] The members to be muted.
  ///
  /// Param [muteExpire] Reserved parameter. The time when the mute state expires.
  ///
  void onMuteListAddedFromGroup(
      String groupId, List<String> mutes, int? muteExpire);

  /// Occurs when members are removed from the mute list of the group.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [mutes] The members to be removed from the mute list.
  ///
  void onMuteListRemovedFromGroup(String groupId, List<String> mutes);

  ///
  /// Occurs when members are changed to admins.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [admin] The members changed to be admins.
  ///
  void onAdminAddedFromGroup(String groupId, String admin);

  ///
  /// Occurs when an admin permission is removed.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [admin] The member whose admin permission is removed.
  void onAdminRemovedFromGroup(String groupId, String admin);

  ///
  /// Occurs when the chat room ownership is transferred.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [newOwner] The new owner.
  ///
  /// Param [oldOwner] The previous owner.
  void onOwnerChangedFromGroup(
      String groupId, String newOwner, String oldOwner);

  ///
  /// Occurs when a member joins the group.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [member] The new member.
  void onMemberJoinedFromGroup(String groupId, String member);

  ///
  /// Occurs when a member exits the group.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [member] The member who exits the group.
  void onMemberExitedFromGroup(String groupId, String member);

  ///
  /// Occurs when the announcement changed.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [member] The new announcement.
  void onAnnouncementChangedFromGroup(String groupId, String announcement);

  /// Occurs when a shared file is added to the group.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [member] The new shared File.
  ///
  void onSharedFileAddedFromGroup(String groupId, EMGroupSharedFile sharedFile);

  ///
  /// Occurs when a shared file is deleted.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [member] The ID of the shared file that is deleted.
  ///
  void onSharedFileDeletedFromGroup(String groupId, String fileId);

  ///
  /// Occurs when one or more group members are added to the allow list.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [members] The members that are added to the allow list.
  void onWhiteListAddedFromGroup(String groupId, List<String> members);

  ///
  /// Occurs when one or more group members are removed from the allow list.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [members] The members that are removed from the allow list.
  void onWhiteListRemovedFromGroup(String groupId, List<String> members);

  /// Occurs when all group members are muted or unmuted.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [isAllMuted] Whether all group members are muted or unmuted.
  /// - `true`: Yes;
  /// - `false`: No.

  void onAllGroupMemberMuteStateChanged(String groupId, bool isAllMuted);
}

///
/// The group change listener.
///
/// Occurs when the following group events happens: requesting to join a group, approving or declining a group request, and kicking a user out of a group.
///
/// Registers a group change listener:
/// ```dart
///   EMClient.getInstance.groupManager.addGroupChangeListener(listener);
/// ```
///
/// Unregisters a group change listener:
/// ```dart
///   EMClient.getInstance.groupManager.removeGroupChangeListener(listener);
/// ```
abstract class EMGroupEventListener {
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
  void onInvitationReceivedFromGroup(
      String groupId, String? groupName, String inviter, String? reason);

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
  void onRequestToJoinReceivedFromGroup(
      String groupId, String? groupName, String applicant, String? reason);

  ///
  /// Occurs when a group request is accepted.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [groupName] The group name.
  ///
  /// Param [accepter] The ID of the user that accepts the group request.
  ///
  void onRequestToJoinAcceptedFromGroup(
      String groupId, String? groupName, String accepter);

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
  void onRequestToJoinDeclinedFromGroup(
    String groupId,
    String? groupName,
    String decliner,
    String? reason,
  );

  ///
  /// Occurs when a group invitation is accepted.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [invitee] The invitee ID.
  ///
  /// Param [reason] The reason for acceptance.
  ///
  void onInvitationAcceptedFromGroup(
    String groupId,
    String invitee,
    String? reason,
  );

  ///
  /// Occurs when a group invitation is declined.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [invitee] The invitee ID.
  ///
  /// Param [reason] The reason for declining.
  ///
  void onInvitationDeclinedFromGroup(
      String groupId, String invitee, String? reason);

  ///
  /// Occurs when the current user is removed from the group by the group admin.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [groupName] The group name.
  ///
  void onUserRemovedFromGroup(String groupId, String? groupName);

  ///
  /// Occurs when a group is destroyed.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [groupName] The group name.
  ///
  void onGroupDestroyed(String groupId, String? groupName);

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
  void onAutoAcceptInvitationFromGroup(
      String groupId, String inviter, String? inviteMessage);

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
  void onMuteListAddedFromGroup(
      String groupId, List<String> mutes, int? muteExpire);

  ///
  /// Occurs when one or more group members are unmuted.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [mutes] The member(s) added to the mute list.
  ///
  void onMuteListRemovedFromGroup(String groupId, List<String> mutes);

  ///
  /// Occurs when a member is set as an admin.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [admin] The member that is set as an admin.
  ///
  void onAdminAddedFromGroup(String groupId, String admin);

  ///
  /// Occurs when a member's admin privileges are removed.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [admin] The member whose admin privileges are removed.
  ///
  void onAdminRemovedFromGroup(String groupId, String admin);

  ///
  /// Occurs when the group ownership is transferred.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [newOwner] The new owner.
  ///
  /// Param [oldOwner] The previous owner.
  ///
  void onOwnerChangedFromGroup(
      String groupId, String newOwner, String oldOwner);

  ///
  /// Occurs when a member joins a group.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [member] The ID of the new member.
  ///
  void onMemberJoinedFromGroup(String groupId, String member);

  ///
  /// Occurs when a member proactively leaves the group.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [member] The member leaving the group.
  ///
  void onMemberExitedFromGroup(String groupId, String member);

  ///
  /// Occurs when the announcement is updated.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [announcement] The updated announcement content.
  ///
  void onAnnouncementChangedFromGroup(String groupId, String announcement);

  ///
  /// Occurs when a shared file is added to a group.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [sharedFile] The new shared file.
  ///
  void onSharedFileAddedFromGroup(String groupId, EMGroupSharedFile sharedFile);

  ///
  /// Occurs when a shared file is removed from a group.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [fileId] The ID of the removed shared file.
  ///
  void onSharedFileDeletedFromGroup(String groupId, String fileId);

  ///
  /// Occurs when one or more group members are added to the allowlist.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [members] The member(s) removed from the allowlist.
  ///
  void onWhiteListAddedFromGroup(String groupId, List<String> members);

  ///
  /// Occurs when one or more members are removed from the allowlist.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [members] The member(s) added to the allowlist.
  ///
  void onWhiteListRemovedFromGroup(String groupId, List<String> members);

  ///
  /// Occurs when all group members are muted or unmuted.
  ///
  /// Param [groupId] The group ID.
  ///
  /// Param [isAllMuted] Whether all group members are muted or unmuted.
  /// - `true`: Yes;
  /// - `false`: No.
  ///
  void onAllGroupMemberMuteStateChanged(String groupId, bool isAllMuted);
}

///
/// The message event listener.
///
/// This listener is used to check whether messages are received. If messages are sent successfully, a delivery receipt will be returned (delivery receipt needs to be enabled: {@link EMOptions#requireDeliveryAck(boolean)}.
/// If the peer reads the received message, a read receipt will be returned (read receipt needs to be enabled: {@link EMOptions#requireAck(boolean)})
/// During message delivery, the message ID will be changed from a local uuid to a global unique ID that is generated by the server to uniquely identify a message on all devices using the SDK.
/// This API should be implemented in the app to listen for message status changes.
///
/// Adds the message listener:
/// ```dart
///   EMClient.getInstance.chatManager.addChatManagerListener(listener);
/// ```
///
/// Removes the message listener:
/// ```dart
///   EMClient.getInstance.chatManager.removeChatManagerListener(listener);
/// ```
///
abstract class EMChatManagerListener {
  ///
  /// Occurs when a message is received.
  ///
  /// This callback is triggered to notify the user when a message such as texts or an image, video, voice, location, or file is received.
  ///
  /// Param [messages] The received messages.
  ///
  void onMessagesReceived(List<EMMessage> messages) {}

  ///
  /// Occurs when a command message is received.
  ///
  /// This callback only contains a command message body that is usually invisible to users.
  ///
  /// Param [messages]The received cmd messages.
  ///
  void onCmdMessagesReceived(List<EMMessage> messages) {}

  ///
  /// Occurs when a read receipt is received for a message.
  ///
  /// Param [messages] The has read messages.
  ///
  void onMessagesRead(List<EMMessage> messages) {}

  ///
  /// Occurs when a read receipt is received for a group message.
  ///
  /// Param [groupMessageAcks] The group message acks.
  ///
  void onGroupMessageRead(List<EMGroupMessageAck> groupMessageAcks) {}

  ///
  /// Occurs when a delivery receipt is received.
  ///
  /// Param [messages] The has delivered messages.
  ///
  void onMessagesDelivered(List<EMMessage> messages) {}

  ///
  /// Occurs when a received message is recalled.
  ///
  /// Param [messages]  The recalled messages.
  ///
  void onMessagesRecalled(List<EMMessage> messages) {}

  ///
  /// Occurs when the conversation updated.
  ///
  void onConversationsUpdate() {}

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
  void onConversationRead(String from, String to) {}
}

///
/// The delegate protocol that defines presence callbacks.
///
class EMPresenceManagerListener {
  ///
  /// Occurs when the presence state of a subscribed user changes.
  ///
  /// Param [list] The new presence state of a subscribed user.
  ///
  void onPresenceStatusChanged(List<EMPresence> list) {}
}
