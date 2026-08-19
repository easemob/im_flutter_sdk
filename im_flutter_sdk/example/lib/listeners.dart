import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'log/log_store.dart';
import 'registry/api_entry.dart';

/// init 成功后统一注册全部事件监听，所有回调写入日志（悬浮 + stdout + 落盘）。
/// 已废弃的回调（onMessagesRecalled、onMemberExited/JoinedFromGroup 单数版）不注册。
void registerAllListeners() {
  const id = 'api_tester';
  void log(String source, [Map<String, Object?>? args]) =>
      LogStore.instance.log(source, args ?? {});

  ChatClient.getInstance.addConnectionEventHandler(
    id,
    ConnectionEventHandler(
      onConnected: () => log('ConnectionEventHandler.onConnected'),
      onDisconnected: () => log('ConnectionEventHandler.onDisconnected'),
      onUserDidLoginFromOtherDevice: (info) => log(
        'ConnectionEventHandler.onUserDidLoginFromOtherDevice',
        {'info': toJsonSafe(info)},
      ),
      onUserDidRemoveFromServer: () =>
          log('ConnectionEventHandler.onUserDidRemoveFromServer'),
      onUserDidForbidByServer: () =>
          log('ConnectionEventHandler.onUserDidForbidByServer'),
      onUserDidChangePassword: () =>
          log('ConnectionEventHandler.onUserDidChangePassword'),
      onUserDidLoginTooManyDevice: () =>
          log('ConnectionEventHandler.onUserDidLoginTooManyDevice'),
      onUserKickedByOtherDevice: () =>
          log('ConnectionEventHandler.onUserKickedByOtherDevice'),
      onUserAuthenticationFailed: () =>
          log('ConnectionEventHandler.onUserAuthenticationFailed'),
      onTokenWillExpire: () =>
          log('ConnectionEventHandler.onTokenWillExpire'),
      onTokenDidExpire: () => log('ConnectionEventHandler.onTokenDidExpire'),
      onAppActiveNumberReachLimit: () =>
          log('ConnectionEventHandler.onAppActiveNumberReachLimit'),
      onOfflineMessageSyncStart: () =>
          log('ConnectionEventHandler.onOfflineMessageSyncStart'),
      onOfflineMessageSyncFinish: () =>
          log('ConnectionEventHandler.onOfflineMessageSyncFinish'),
    ),
  );

  ChatClient.getInstance.addMultiDeviceEventHandler(
    id,
    ChatMultiDeviceEventHandler(
      onContactEvent: (event, userId, ext) => log(
        'ChatMultiDeviceEventHandler.onContactEvent',
        {'event': event.name, 'userId': userId, 'ext': ext},
      ),
      onGroupEvent: (event, groupId, userIds) => log(
        'ChatMultiDeviceEventHandler.onGroupEvent',
        {'event': event.name, 'groupId': groupId, 'userIds': userIds},
      ),
      onChatThreadEvent: (event, chatThreadId, userIds) => log(
        'ChatMultiDeviceEventHandler.onChatThreadEvent',
        {'event': event.name, 'chatThreadId': chatThreadId, 'userIds': userIds},
      ),
      onRemoteMessagesRemoved: (conversationId, deviceId) => log(
        'ChatMultiDeviceEventHandler.onRemoteMessagesRemoved',
        {'conversationId': conversationId, 'deviceId': deviceId},
      ),
      onConversationEvent: (event, conversationId, type) => log(
        'ChatMultiDeviceEventHandler.onConversationEvent',
        {
          'event': event.name,
          'conversationId': conversationId,
          'type': type.name,
        },
      ),
    ),
  );

  ChatClient.getInstance.chatManager.addEventHandler(
    id,
    ChatEventHandler(
      onMessagesReceived: (messages) => log(
        'ChatEventHandler.onMessagesReceived',
        {'messages': toJsonSafe(messages)},
      ),
      onStreamMessagesReceived: (messages) => log(
        'ChatEventHandler.onStreamMessagesReceived',
        {'messages': toJsonSafe(messages)},
      ),
      onCmdMessagesReceived: (messages) => log(
        'ChatEventHandler.onCmdMessagesReceived',
        {'messages': toJsonSafe(messages)},
      ),
      onMessagesRead: (messages) => log(
        'ChatEventHandler.onMessagesRead',
        {'messages': toJsonSafe(messages)},
      ),
      onGroupMessageRead: (acks) => log(
        'ChatEventHandler.onGroupMessageRead',
        {'groupMessageAcks': toJsonSafe(acks)},
      ),
      onReadAckForGroupMessageUpdated: () =>
          log('ChatEventHandler.onReadAckForGroupMessageUpdated'),
      onMessagesDelivered: (messages) => log(
        'ChatEventHandler.onMessagesDelivered',
        {'messages': toJsonSafe(messages)},
      ),
      onMessagesRecalledInfo: (infos) => log(
        'ChatEventHandler.onMessagesRecalledInfo',
        {'recallMessageInfos': toJsonSafe(infos)},
      ),
      onConversationsUpdate: () =>
          log('ChatEventHandler.onConversationsUpdate'),
      onConversationRead: (from, to) => log(
        'ChatEventHandler.onConversationRead',
        {'from': from, 'to': to},
      ),
      onMessageReactionDidChange: (events) => log(
        'ChatEventHandler.onMessageReactionDidChange',
        {'events': toJsonSafe(events)},
      ),
      onMessageContentChanged: (message, operatorId, operationTime) => log(
        'ChatEventHandler.onMessageContentChanged',
        {
          'message': toJsonSafe(message),
          'operatorId': operatorId,
          'operationTime': operationTime,
        },
      ),
      onMessagePinChanged: (messageId, conversationId, pinOperation, pinInfo) =>
          log(
        'ChatEventHandler.onMessagePinChanged',
        {
          'messageId': messageId,
          'conversationId': conversationId,
          'pinOperation': pinOperation.name,
          'pinInfo': toJsonSafe(pinInfo),
        },
      ),
    ),
  );

  ChatClient.getInstance.chatRoomManager.addEventHandler(
    id,
    ChatRoomEventHandler(
      onAdminAddedFromChatRoom: (roomId, admin) => log(
        'ChatRoomEventHandler.onAdminAddedFromChatRoom',
        {'roomId': roomId, 'admin': admin},
      ),
      onAdminRemovedFromChatRoom: (roomId, admin) => log(
        'ChatRoomEventHandler.onAdminRemovedFromChatRoom',
        {'roomId': roomId, 'admin': admin},
      ),
      onAllChatRoomMemberMuteStateChanged: (roomId, isAllMuted) => log(
        'ChatRoomEventHandler.onAllChatRoomMemberMuteStateChanged',
        {'roomId': roomId, 'isAllMuted': isAllMuted},
      ),
      onAllowListAddedFromChatRoom: (roomId, members) => log(
        'ChatRoomEventHandler.onAllowListAddedFromChatRoom',
        {'roomId': roomId, 'members': members},
      ),
      onAllowListRemovedFromChatRoom: (roomId, members) => log(
        'ChatRoomEventHandler.onAllowListRemovedFromChatRoom',
        {'roomId': roomId, 'members': members},
      ),
      onAnnouncementChangedFromChatRoom: (roomId, announcement) => log(
        'ChatRoomEventHandler.onAnnouncementChangedFromChatRoom',
        {'roomId': roomId, 'announcement': announcement},
      ),
      onChatRoomDestroyed: (roomId, roomName) => log(
        'ChatRoomEventHandler.onChatRoomDestroyed',
        {'roomId': roomId, 'roomName': roomName},
      ),
      onMemberExitedFromChatRoom: (roomId, roomName, participant) => log(
        'ChatRoomEventHandler.onMemberExitedFromChatRoom',
        {'roomId': roomId, 'roomName': roomName, 'participant': participant},
      ),
      onMemberJoinedFromChatRoom: (roomId, participant, ext) => log(
        'ChatRoomEventHandler.onMemberJoinedFromChatRoom',
        {'roomId': roomId, 'participant': participant, 'ext': ext},
      ),
      onMuteListAddedFromChatRoom: (roomId, mutes) => log(
        'ChatRoomEventHandler.onMuteListAddedFromChatRoom',
        {'roomId': roomId, 'mutes': mutes},
      ),
      onMuteListRemovedFromChatRoom: (roomId, mutes) => log(
        'ChatRoomEventHandler.onMuteListRemovedFromChatRoom',
        {'roomId': roomId, 'mutes': mutes},
      ),
      onOwnerChangedFromChatRoom: (roomId, newOwner, oldOwner) => log(
        'ChatRoomEventHandler.onOwnerChangedFromChatRoom',
        {'roomId': roomId, 'newOwner': newOwner, 'oldOwner': oldOwner},
      ),
      onRemovedFromChatRoom: (roomId, roomName, participant, reason) => log(
        'ChatRoomEventHandler.onRemovedFromChatRoom',
        {
          'roomId': roomId,
          'roomName': roomName,
          'participant': participant,
          'reason': reason?.name,
        },
      ),
      onSpecificationChanged: (room) => log(
        'ChatRoomEventHandler.onSpecificationChanged',
        {'room': toJsonSafe(room)},
      ),
      onAttributesUpdated: (roomId, attributes, from) => log(
        'ChatRoomEventHandler.onAttributesUpdated',
        {'roomId': roomId, 'attributes': attributes, 'from': from},
      ),
      onAttributesRemoved: (roomId, removedKeys, from) => log(
        'ChatRoomEventHandler.onAttributesRemoved',
        {'roomId': roomId, 'removedKeys': removedKeys, 'from': from},
      ),
    ),
  );

  ChatClient.getInstance.chatThreadManager.addEventHandler(
    id,
    ChatThreadEventHandler(
      onChatThreadCreate: (event) => log(
        'ChatThreadEventHandler.onChatThreadCreate',
        {'event': toJsonSafe(event)},
      ),
      onChatThreadDestroy: (event) => log(
        'ChatThreadEventHandler.onChatThreadDestroy',
        {'event': toJsonSafe(event)},
      ),
      onChatThreadUpdate: (event) => log(
        'ChatThreadEventHandler.onChatThreadUpdate',
        {'event': toJsonSafe(event)},
      ),
      onUserKickOutOfChatThread: (event) => log(
        'ChatThreadEventHandler.onUserKickOutOfChatThread',
        {'event': toJsonSafe(event)},
      ),
    ),
  );

  ChatClient.getInstance.contactManager.addEventHandler(
    id,
    ChatContactEventHandler(
      onContactAdded: (userId) =>
          log('ChatContactEventHandler.onContactAdded', {'userId': userId}),
      onContactDeleted: (userId) =>
          log('ChatContactEventHandler.onContactDeleted', {'userId': userId}),
      onContactInvited: (userId, reason) => log(
        'ChatContactEventHandler.onContactInvited',
        {'userId': userId, 'reason': reason},
      ),
      onFriendRequestAccepted: (userId) => log(
        'ChatContactEventHandler.onFriendRequestAccepted',
        {'userId': userId},
      ),
      onFriendRequestDeclined: (userId) => log(
        'ChatContactEventHandler.onFriendRequestDeclined',
        {'userId': userId},
      ),
      onContactSyncStart: () => log('ChatContactEventHandler.onContactSyncStart'),
      onContactSyncFinish: (error) => log(
        'ChatContactEventHandler.onContactSyncFinish',
        {'error': error == null ? null : errorToJson(error)},
      ),
      onContactInfoUpdate: (contact) => log(
        'ChatContactEventHandler.onContactInfoUpdate',
        {'contact': toJsonSafe(contact)},
      ),
    ),
  );

  ChatClient.getInstance.groupManager.addEventHandler(
    id,
    ChatGroupEventHandler(
      onAdminAddedFromGroup: (groupId, admin) => log(
        'ChatGroupEventHandler.onAdminAddedFromGroup',
        {'groupId': groupId, 'admin': admin},
      ),
      onAdminRemovedFromGroup: (groupId, admin) => log(
        'ChatGroupEventHandler.onAdminRemovedFromGroup',
        {'groupId': groupId, 'admin': admin},
      ),
      onAllGroupMemberMuteStateChanged: (groupId, isAllMuted) => log(
        'ChatGroupEventHandler.onAllGroupMemberMuteStateChanged',
        {'groupId': groupId, 'isAllMuted': isAllMuted},
      ),
      onAllowListAddedFromGroup: (groupId, members) => log(
        'ChatGroupEventHandler.onAllowListAddedFromGroup',
        {'groupId': groupId, 'members': members},
      ),
      onAllowListRemovedFromGroup: (groupId, members) => log(
        'ChatGroupEventHandler.onAllowListRemovedFromGroup',
        {'groupId': groupId, 'members': members},
      ),
      onAnnouncementChangedFromGroup: (groupId, announcement) => log(
        'ChatGroupEventHandler.onAnnouncementChangedFromGroup',
        {'groupId': groupId, 'announcement': announcement},
      ),
      onAutoAcceptInvitationFromGroup: (groupId, inviter, inviteMessage) => log(
        'ChatGroupEventHandler.onAutoAcceptInvitationFromGroup',
        {
          'groupId': groupId,
          'inviter': inviter,
          'inviteMessage': inviteMessage
        },
      ),
      onGroupDestroyed: (groupId, groupName) => log(
        'ChatGroupEventHandler.onGroupDestroyed',
        {'groupId': groupId, 'groupName': groupName},
      ),
      onInvitationAcceptedFromGroup: (groupId, invitee, reason) => log(
        'ChatGroupEventHandler.onInvitationAcceptedFromGroup',
        {'groupId': groupId, 'invitee': invitee, 'reason': reason},
      ),
      onInvitationDeclinedFromGroup: (groupId, invitee, reason) => log(
        'ChatGroupEventHandler.onInvitationDeclinedFromGroup',
        {'groupId': groupId, 'invitee': invitee, 'reason': reason},
      ),
      onInvitationReceivedFromGroup: (groupId, groupName, inviter, reason) =>
          log(
        'ChatGroupEventHandler.onInvitationReceivedFromGroup',
        {
          'groupId': groupId,
          'groupName': groupName,
          'inviter': inviter,
          'reason': reason,
        },
      ),
      onMuteListAddedFromGroup: (groupId, mutes, muteExpire) => log(
        'ChatGroupEventHandler.onMuteListAddedFromGroup',
        {'groupId': groupId, 'mutes': mutes, 'muteExpire': muteExpire},
      ),
      onMuteListRemovedFromGroup: (groupId, mutes) => log(
        'ChatGroupEventHandler.onMuteListRemovedFromGroup',
        {'groupId': groupId, 'mutes': mutes},
      ),
      onOwnerChangedFromGroup: (groupId, newOwner, oldOwner) => log(
        'ChatGroupEventHandler.onOwnerChangedFromGroup',
        {'groupId': groupId, 'newOwner': newOwner, 'oldOwner': oldOwner},
      ),
      onRequestToJoinAcceptedFromGroup: (groupId, groupName, accepter) => log(
        'ChatGroupEventHandler.onRequestToJoinAcceptedFromGroup',
        {'groupId': groupId, 'groupName': groupName, 'accepter': accepter},
      ),
      onRequestToJoinDeclinedFromGroup:
          (groupId, groupName, decliner, reason, applicant) => log(
        'ChatGroupEventHandler.onRequestToJoinDeclinedFromGroup',
        {
          'groupId': groupId,
          'groupName': groupName,
          'decliner': decliner,
          'reason': reason,
          'applicant': applicant,
        },
      ),
      onRequestToJoinReceivedFromGroup:
          (groupId, groupName, applicant, reason) => log(
        'ChatGroupEventHandler.onRequestToJoinReceivedFromGroup',
        {
          'groupId': groupId,
          'groupName': groupName,
          'applicant': applicant,
          'reason': reason,
        },
      ),
      onSharedFileAddedFromGroup: (groupId, sharedFile) => log(
        'ChatGroupEventHandler.onSharedFileAddedFromGroup',
        {'groupId': groupId, 'sharedFile': toJsonSafe(sharedFile)},
      ),
      onSharedFileDeletedFromGroup: (groupId, fileId) => log(
        'ChatGroupEventHandler.onSharedFileDeletedFromGroup',
        {'groupId': groupId, 'fileId': fileId},
      ),
      onUserRemovedFromGroup: (groupId, groupName) => log(
        'ChatGroupEventHandler.onUserRemovedFromGroup',
        {'groupId': groupId, 'groupName': groupName},
      ),
      onSpecificationDidUpdate: (group) => log(
        'ChatGroupEventHandler.onSpecificationDidUpdate',
        {'group': toJsonSafe(group)},
      ),
      onDisableChanged: (groupId, isDisable) => log(
        'ChatGroupEventHandler.onDisableChanged',
        {'groupId': groupId, 'isDisable': isDisable},
      ),
      onAttributesChangedOfGroupMember:
          (groupId, userId, attributes, operatorId) => log(
        'ChatGroupEventHandler.onAttributesChangedOfGroupMember',
        {
          'groupId': groupId,
          'userId': userId,
          'attributes': attributes,
          'operatorId': operatorId,
        },
      ),
      onMembersJoinedFromGroup: (groupId, userIds) => log(
        'ChatGroupEventHandler.onMembersJoinedFromGroup',
        {'groupId': groupId, 'userIds': userIds},
      ),
      onMembersExitedFromGroup: (groupId, userIds) => log(
        'ChatGroupEventHandler.onMembersExitedFromGroup',
        {'groupId': groupId, 'userIds': userIds},
      ),
      onUserGroupNamecardChanged: (groupId, userId, namecard) => log(
        'ChatGroupEventHandler.onUserGroupNamecardChanged',
        {'groupId': groupId, 'userId': userId, 'namecard': namecard},
      ),
    ),
  );

  ChatClient.getInstance.presenceManager.addEventHandler(
    id,
    ChatPresenceEventHandler(
      onPresenceStatusChanged: (list) => log(
        'ChatPresenceEventHandler.onPresenceStatusChanged',
        {'list': toJsonSafe(list)},
      ),
    ),
  );

  ChatClient.getInstance.userInfoManager.addEventHandler(
    id,
    ChatUserInfoEventHandler(
      onSelfUserInfoUpdate: (userInfo) => log(
        'ChatUserInfoEventHandler.onSelfUserInfoUpdate',
        {'userInfo': toJsonSafe(userInfo)},
      ),
      onUserInfoUpdate: (userInfos) => log(
        'ChatUserInfoEventHandler.onUserInfoUpdate',
        {'userInfos': toJsonSafe(userInfos)},
      ),
    ),
  );

  log('listeners.registered', {'handlerId': id});
}
