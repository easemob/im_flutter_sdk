import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'log/log_store.dart';
import 'registry/api_entry.dart';

/// init 成功后统一注册全部事件监听，所有回调写入日志（悬浮 + stdout + 落盘）。
/// 已废弃的回调（onMessagesRecalled、onMemberExited/JoinedFromGroup 单数版）不注册。
void registerAllListeners() {
  const id = 'api_tester';
  void log(String source, [Map<String, Object?>? args]) =>
      LogStore.instance.log(source, args ?? {});

  EMClient.getInstance.addConnectionEventHandler(
    id,
    EMConnectionEventHandler(
      onConnected: () => log('EMConnectionEventHandler.onConnected'),
      onDisconnected: () => log('EMConnectionEventHandler.onDisconnected'),
      onUserDidLoginFromOtherDevice: (info) => log(
        'EMConnectionEventHandler.onUserDidLoginFromOtherDevice',
        {'info': toJsonSafe(info)},
      ),
      onUserDidRemoveFromServer: () =>
          log('EMConnectionEventHandler.onUserDidRemoveFromServer'),
      onUserDidForbidByServer: () =>
          log('EMConnectionEventHandler.onUserDidForbidByServer'),
      onUserDidChangePassword: () =>
          log('EMConnectionEventHandler.onUserDidChangePassword'),
      onUserDidLoginTooManyDevice: () =>
          log('EMConnectionEventHandler.onUserDidLoginTooManyDevice'),
      onUserKickedByOtherDevice: () =>
          log('EMConnectionEventHandler.onUserKickedByOtherDevice'),
      onUserAuthenticationFailed: () =>
          log('EMConnectionEventHandler.onUserAuthenticationFailed'),
      onTokenWillExpire: () =>
          log('EMConnectionEventHandler.onTokenWillExpire'),
      onTokenDidExpire: () => log('EMConnectionEventHandler.onTokenDidExpire'),
      onAppActiveNumberReachLimit: () =>
          log('EMConnectionEventHandler.onAppActiveNumberReachLimit'),
      onOfflineMessageSyncStart: () =>
          log('EMConnectionEventHandler.onOfflineMessageSyncStart'),
      onOfflineMessageSyncFinish: () =>
          log('EMConnectionEventHandler.onOfflineMessageSyncFinish'),
    ),
  );

  EMClient.getInstance.addMultiDeviceEventHandler(
    id,
    EMMultiDeviceEventHandler(
      onContactEvent: (event, userId, ext) => log(
        'EMMultiDeviceEventHandler.onContactEvent',
        {'event': event.name, 'userId': userId, 'ext': ext},
      ),
      onGroupEvent: (event, groupId, userIds) => log(
        'EMMultiDeviceEventHandler.onGroupEvent',
        {'event': event.name, 'groupId': groupId, 'userIds': userIds},
      ),
      onChatThreadEvent: (event, chatThreadId, userIds) => log(
        'EMMultiDeviceEventHandler.onChatThreadEvent',
        {'event': event.name, 'chatThreadId': chatThreadId, 'userIds': userIds},
      ),
      onRemoteMessagesRemoved: (conversationId, deviceId) => log(
        'EMMultiDeviceEventHandler.onRemoteMessagesRemoved',
        {'conversationId': conversationId, 'deviceId': deviceId},
      ),
      onConversationEvent: (event, conversationId, type) => log(
        'EMMultiDeviceEventHandler.onConversationEvent',
        {
          'event': event.name,
          'conversationId': conversationId,
          'type': type.name,
        },
      ),
    ),
  );

  EMClient.getInstance.chatManager.addEventHandler(
    id,
    EMChatEventHandler(
      onMessagesReceived: (messages) => log(
        'EMChatEventHandler.onMessagesReceived',
        {'messages': toJsonSafe(messages)},
      ),
      onStreamMessagesReceived: (messages) => log(
        'EMChatEventHandler.onStreamMessagesReceived',
        {'messages': toJsonSafe(messages)},
      ),
      onCmdMessagesReceived: (messages) => log(
        'EMChatEventHandler.onCmdMessagesReceived',
        {'messages': toJsonSafe(messages)},
      ),
      onMessagesRead: (messages) => log(
        'EMChatEventHandler.onMessagesRead',
        {'messages': toJsonSafe(messages)},
      ),
      onGroupMessageRead: (acks) => log(
        'EMChatEventHandler.onGroupMessageRead',
        {'groupMessageAcks': toJsonSafe(acks)},
      ),
      onReadAckForGroupMessageUpdated: () =>
          log('EMChatEventHandler.onReadAckForGroupMessageUpdated'),
      onMessagesDelivered: (messages) => log(
        'EMChatEventHandler.onMessagesDelivered',
        {'messages': toJsonSafe(messages)},
      ),
      onMessagesRecalledInfo: (infos) => log(
        'EMChatEventHandler.onMessagesRecalledInfo',
        {'recallMessageInfos': toJsonSafe(infos)},
      ),
      onConversationsUpdate: () =>
          log('EMChatEventHandler.onConversationsUpdate'),
      onConversationRead: (from, to) => log(
        'EMChatEventHandler.onConversationRead',
        {'from': from, 'to': to},
      ),
      onMessageReactionDidChange: (events) => log(
        'EMChatEventHandler.onMessageReactionDidChange',
        {'events': toJsonSafe(events)},
      ),
      onMessageContentChanged: (message, operatorId, operationTime) => log(
        'EMChatEventHandler.onMessageContentChanged',
        {
          'message': toJsonSafe(message),
          'operatorId': operatorId,
          'operationTime': operationTime,
        },
      ),
      onMessagePinChanged: (messageId, conversationId, pinOperation, pinInfo) =>
          log(
        'EMChatEventHandler.onMessagePinChanged',
        {
          'messageId': messageId,
          'conversationId': conversationId,
          'pinOperation': pinOperation.name,
          'pinInfo': toJsonSafe(pinInfo),
        },
      ),
    ),
  );

  EMClient.getInstance.chatRoomManager.addEventHandler(
    id,
    EMChatRoomEventHandler(
      onAdminAddedFromChatRoom: (roomId, admin) => log(
        'EMChatRoomEventHandler.onAdminAddedFromChatRoom',
        {'roomId': roomId, 'admin': admin},
      ),
      onAdminRemovedFromChatRoom: (roomId, admin) => log(
        'EMChatRoomEventHandler.onAdminRemovedFromChatRoom',
        {'roomId': roomId, 'admin': admin},
      ),
      onAllChatRoomMemberMuteStateChanged: (roomId, isAllMuted) => log(
        'EMChatRoomEventHandler.onAllChatRoomMemberMuteStateChanged',
        {'roomId': roomId, 'isAllMuted': isAllMuted},
      ),
      onAllowListAddedFromChatRoom: (roomId, members) => log(
        'EMChatRoomEventHandler.onAllowListAddedFromChatRoom',
        {'roomId': roomId, 'members': members},
      ),
      onAllowListRemovedFromChatRoom: (roomId, members) => log(
        'EMChatRoomEventHandler.onAllowListRemovedFromChatRoom',
        {'roomId': roomId, 'members': members},
      ),
      onAnnouncementChangedFromChatRoom: (roomId, announcement) => log(
        'EMChatRoomEventHandler.onAnnouncementChangedFromChatRoom',
        {'roomId': roomId, 'announcement': announcement},
      ),
      onChatRoomDestroyed: (roomId, roomName) => log(
        'EMChatRoomEventHandler.onChatRoomDestroyed',
        {'roomId': roomId, 'roomName': roomName},
      ),
      onMemberExitedFromChatRoom: (roomId, roomName, participant) => log(
        'EMChatRoomEventHandler.onMemberExitedFromChatRoom',
        {'roomId': roomId, 'roomName': roomName, 'participant': participant},
      ),
      onMemberJoinedFromChatRoom: (roomId, participant, ext) => log(
        'EMChatRoomEventHandler.onMemberJoinedFromChatRoom',
        {'roomId': roomId, 'participant': participant, 'ext': ext},
      ),
      onMuteListAddedFromChatRoom: (roomId, mutes) => log(
        'EMChatRoomEventHandler.onMuteListAddedFromChatRoom',
        {'roomId': roomId, 'mutes': mutes},
      ),
      onMuteListRemovedFromChatRoom: (roomId, mutes) => log(
        'EMChatRoomEventHandler.onMuteListRemovedFromChatRoom',
        {'roomId': roomId, 'mutes': mutes},
      ),
      onOwnerChangedFromChatRoom: (roomId, newOwner, oldOwner) => log(
        'EMChatRoomEventHandler.onOwnerChangedFromChatRoom',
        {'roomId': roomId, 'newOwner': newOwner, 'oldOwner': oldOwner},
      ),
      onRemovedFromChatRoom: (roomId, roomName, participant, reason) => log(
        'EMChatRoomEventHandler.onRemovedFromChatRoom',
        {
          'roomId': roomId,
          'roomName': roomName,
          'participant': participant,
          'reason': reason?.name,
        },
      ),
      onSpecificationChanged: (room) => log(
        'EMChatRoomEventHandler.onSpecificationChanged',
        {'room': toJsonSafe(room)},
      ),
      onAttributesUpdated: (roomId, attributes, from) => log(
        'EMChatRoomEventHandler.onAttributesUpdated',
        {'roomId': roomId, 'attributes': attributes, 'from': from},
      ),
      onAttributesRemoved: (roomId, removedKeys, from) => log(
        'EMChatRoomEventHandler.onAttributesRemoved',
        {'roomId': roomId, 'removedKeys': removedKeys, 'from': from},
      ),
    ),
  );

  EMClient.getInstance.chatThreadManager.addEventHandler(
    id,
    EMChatThreadEventHandler(
      onChatThreadCreate: (event) => log(
        'EMChatThreadEventHandler.onChatThreadCreate',
        {'event': toJsonSafe(event)},
      ),
      onChatThreadDestroy: (event) => log(
        'EMChatThreadEventHandler.onChatThreadDestroy',
        {'event': toJsonSafe(event)},
      ),
      onChatThreadUpdate: (event) => log(
        'EMChatThreadEventHandler.onChatThreadUpdate',
        {'event': toJsonSafe(event)},
      ),
      onUserKickOutOfChatThread: (event) => log(
        'EMChatThreadEventHandler.onUserKickOutOfChatThread',
        {'event': toJsonSafe(event)},
      ),
    ),
  );

  EMClient.getInstance.contactManager.addEventHandler(
    id,
    EMContactEventHandler(
      onContactAdded: (userId) =>
          log('EMContactEventHandler.onContactAdded', {'userId': userId}),
      onContactDeleted: (userId) =>
          log('EMContactEventHandler.onContactDeleted', {'userId': userId}),
      onContactInvited: (userId, reason) => log(
        'EMContactEventHandler.onContactInvited',
        {'userId': userId, 'reason': reason},
      ),
      onFriendRequestAccepted: (userId) => log(
        'EMContactEventHandler.onFriendRequestAccepted',
        {'userId': userId},
      ),
      onFriendRequestDeclined: (userId) => log(
        'EMContactEventHandler.onFriendRequestDeclined',
        {'userId': userId},
      ),
      onContactSyncStart: () => log('EMContactEventHandler.onContactSyncStart'),
      onContactSyncFinish: (error) => log(
        'EMContactEventHandler.onContactSyncFinish',
        {'error': error == null ? null : errorToJson(error)},
      ),
      onContactInfoUpdate: (contact) => log(
        'EMContactEventHandler.onContactInfoUpdate',
        {'contact': toJsonSafe(contact)},
      ),
    ),
  );

  EMClient.getInstance.groupManager.addEventHandler(
    id,
    EMGroupEventHandler(
      onAdminAddedFromGroup: (groupId, admin) => log(
        'EMGroupEventHandler.onAdminAddedFromGroup',
        {'groupId': groupId, 'admin': admin},
      ),
      onAdminRemovedFromGroup: (groupId, admin) => log(
        'EMGroupEventHandler.onAdminRemovedFromGroup',
        {'groupId': groupId, 'admin': admin},
      ),
      onAllGroupMemberMuteStateChanged: (groupId, isAllMuted) => log(
        'EMGroupEventHandler.onAllGroupMemberMuteStateChanged',
        {'groupId': groupId, 'isAllMuted': isAllMuted},
      ),
      onAllowListAddedFromGroup: (groupId, members) => log(
        'EMGroupEventHandler.onAllowListAddedFromGroup',
        {'groupId': groupId, 'members': members},
      ),
      onAllowListRemovedFromGroup: (groupId, members) => log(
        'EMGroupEventHandler.onAllowListRemovedFromGroup',
        {'groupId': groupId, 'members': members},
      ),
      onAnnouncementChangedFromGroup: (groupId, announcement) => log(
        'EMGroupEventHandler.onAnnouncementChangedFromGroup',
        {'groupId': groupId, 'announcement': announcement},
      ),
      onAutoAcceptInvitationFromGroup: (groupId, inviter, inviteMessage) => log(
        'EMGroupEventHandler.onAutoAcceptInvitationFromGroup',
        {
          'groupId': groupId,
          'inviter': inviter,
          'inviteMessage': inviteMessage
        },
      ),
      onGroupDestroyed: (groupId, groupName) => log(
        'EMGroupEventHandler.onGroupDestroyed',
        {'groupId': groupId, 'groupName': groupName},
      ),
      onInvitationAcceptedFromGroup: (groupId, invitee, reason) => log(
        'EMGroupEventHandler.onInvitationAcceptedFromGroup',
        {'groupId': groupId, 'invitee': invitee, 'reason': reason},
      ),
      onInvitationDeclinedFromGroup: (groupId, invitee, reason) => log(
        'EMGroupEventHandler.onInvitationDeclinedFromGroup',
        {'groupId': groupId, 'invitee': invitee, 'reason': reason},
      ),
      onInvitationReceivedFromGroup: (groupId, groupName, inviter, reason) =>
          log(
        'EMGroupEventHandler.onInvitationReceivedFromGroup',
        {
          'groupId': groupId,
          'groupName': groupName,
          'inviter': inviter,
          'reason': reason,
        },
      ),
      onMuteListAddedFromGroup: (groupId, mutes, muteExpire) => log(
        'EMGroupEventHandler.onMuteListAddedFromGroup',
        {'groupId': groupId, 'mutes': mutes, 'muteExpire': muteExpire},
      ),
      onMuteListRemovedFromGroup: (groupId, mutes) => log(
        'EMGroupEventHandler.onMuteListRemovedFromGroup',
        {'groupId': groupId, 'mutes': mutes},
      ),
      onOwnerChangedFromGroup: (groupId, newOwner, oldOwner) => log(
        'EMGroupEventHandler.onOwnerChangedFromGroup',
        {'groupId': groupId, 'newOwner': newOwner, 'oldOwner': oldOwner},
      ),
      onRequestToJoinAcceptedFromGroup: (groupId, groupName, accepter) => log(
        'EMGroupEventHandler.onRequestToJoinAcceptedFromGroup',
        {'groupId': groupId, 'groupName': groupName, 'accepter': accepter},
      ),
      onRequestToJoinDeclinedFromGroup:
          (groupId, groupName, decliner, reason, applicant) => log(
        'EMGroupEventHandler.onRequestToJoinDeclinedFromGroup',
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
        'EMGroupEventHandler.onRequestToJoinReceivedFromGroup',
        {
          'groupId': groupId,
          'groupName': groupName,
          'applicant': applicant,
          'reason': reason,
        },
      ),
      onSharedFileAddedFromGroup: (groupId, sharedFile) => log(
        'EMGroupEventHandler.onSharedFileAddedFromGroup',
        {'groupId': groupId, 'sharedFile': toJsonSafe(sharedFile)},
      ),
      onSharedFileDeletedFromGroup: (groupId, fileId) => log(
        'EMGroupEventHandler.onSharedFileDeletedFromGroup',
        {'groupId': groupId, 'fileId': fileId},
      ),
      onUserRemovedFromGroup: (groupId, groupName) => log(
        'EMGroupEventHandler.onUserRemovedFromGroup',
        {'groupId': groupId, 'groupName': groupName},
      ),
      onSpecificationDidUpdate: (group) => log(
        'EMGroupEventHandler.onSpecificationDidUpdate',
        {'group': toJsonSafe(group)},
      ),
      onDisableChanged: (groupId, isDisable) => log(
        'EMGroupEventHandler.onDisableChanged',
        {'groupId': groupId, 'isDisable': isDisable},
      ),
      onAttributesChangedOfGroupMember:
          (groupId, userId, attributes, operatorId) => log(
        'EMGroupEventHandler.onAttributesChangedOfGroupMember',
        {
          'groupId': groupId,
          'userId': userId,
          'attributes': attributes,
          'operatorId': operatorId,
        },
      ),
      onMembersJoinedFromGroup: (groupId, userIds) => log(
        'EMGroupEventHandler.onMembersJoinedFromGroup',
        {'groupId': groupId, 'userIds': userIds},
      ),
      onMembersExitedFromGroup: (groupId, userIds) => log(
        'EMGroupEventHandler.onMembersExitedFromGroup',
        {'groupId': groupId, 'userIds': userIds},
      ),
      onUserGroupNamecardChanged: (groupId, userId, namecard) => log(
        'EMGroupEventHandler.onUserGroupNamecardChanged',
        {'groupId': groupId, 'userId': userId, 'namecard': namecard},
      ),
    ),
  );

  EMClient.getInstance.presenceManager.addEventHandler(
    id,
    EMPresenceEventHandler(
      onPresenceStatusChanged: (list) => log(
        'EMPresenceEventHandler.onPresenceStatusChanged',
        {'list': toJsonSafe(list)},
      ),
    ),
  );

  EMClient.getInstance.userInfoManager.addEventHandler(
    id,
    EMUserInfoEventHandler(
      onSelfUserInfoUpdate: (userInfo) => log(
        'EMUserInfoEventHandler.onSelfUserInfoUpdate',
        {'userInfo': toJsonSafe(userInfo)},
      ),
      onUserInfoUpdate: (userInfos) => log(
        'EMUserInfoEventHandler.onUserInfoUpdate',
        {'userInfos': toJsonSafe(userInfos)},
      ),
    ),
  );

  log('listeners.registered', {'handlerId': id});
}
